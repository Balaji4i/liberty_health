package com.core.model.eo.classes;

import com.core.utils.SqlParameter;
import com.core.utils.SqlUtils;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Timestamp;

import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Locale;
import java.util.ResourceBundle;

import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.SecurityContext;
import oracle.adf.share.security.authorization.EntityAttributePermission;

import oracle.jbo.AttributeDef;
import oracle.jbo.AttributeList;
import oracle.jbo.JboException;
import oracle.jbo.RemoveWithDetailsException;
import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.server.AttributeDefImpl;
import oracle.jbo.server.EntityImpl;
import oracle.jbo.server.SequenceImpl;

public class CoreEntityImpl
  extends EntityImpl
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(CoreEntityImpl.class);
  public String dbUsername;
  private boolean checkChildrenExists = false;
  private boolean convertAllAttributeToUpper = true;
  public final String NULL_STRING = "null";
  public final String UPPER_CASE_PROPERTY = "U";
  public final String LOWER_CASE_PROPERTY = "L";
  
  protected void create(AttributeList attributeList)
  {
    super.create(attributeList);
    for (AttributeDef def : getEntityDef().getAttributeDefs())
    {
      String sequenceName = (String)def.getProperty("SequenceName");
      if (sequenceName != null)
      {
        SequenceImpl s = new SequenceImpl(sequenceName, getDBTransaction());
        populateAttributeAsChanged(def.getIndex(), s.getSequenceNumber());
      }
    }
  }
  
  protected void setAttributeInternal(int index, Object object)
  {
    AttributeDef attrDef = getEntityDef().getAttributeDef(index);
    
    String attrName = attrDef.getJavaType().getName();
    if (attrName != null) {
      if ((attrDef != null) && (attrName.equals(String.class.getName())))
      {
        String caseProperty = getEntityDef().getAttributeDef(index).getProperty("CASE") + "";
        if ((caseProperty != null) && (!caseProperty.equals("null")))
        {
          String value = (String)object;
          if (caseProperty.equals("U")) {
            value = value.toUpperCase();
          } else if (caseProperty.equals("L")) {
            value = value.toLowerCase();
          }
          object = value;
        }
        caseProperty = null;
        caseProperty = getEntityDef().getAttributeDef(index).getProperty("Username") + "";
        if ((caseProperty != null) && (!caseProperty.equals("null")))
        {
          _logger.info("Username Property!!");
          object = "#JTest";
        }
      }
      else if ((attrDef != null) && (attrDef.getJavaType().getName().equals(oracle.jbo.domain.Date.class.getName())))
      {
        String caseProperty = getEntityDef().getAttributeDef(index).getProperty("LastUpdateDate") + "";
        if ((caseProperty != null) && (!caseProperty.equals("null")))
        {
          _logger.info("LastUpdateDate");
          SimpleDateFormat sdf = new SimpleDateFormat("dd-MMM-yy");
          String s = sdf.format(new java.util.Date());
          
          oracle.jbo.domain.Date currentDate = null;
          try
          {
            Timestamp ts = new Timestamp(sdf.parse(s).getTime());
            currentDate = new oracle.jbo.domain.Date(ts);
          }
          catch (Exception e)
          {
            e.printStackTrace();
          }
          if (currentDate != null) {
            object = currentDate;
          } else {
            _logger.info("Error getting current date for last update date.");
          }
        }
      }
    }
   /* if (((object instanceof String)) && 
      (this.convertAllAttributeToUpper))
    {
      String obj = (String)object;
      obj = obj.toUpperCase();
      object = obj;
    }*/
    super.setAttributeInternal(index, object);
  }
  
  public String callDbFunc(String dbMethod)
  {
    //ret = null;
    CallableStatement st = null;
    try
    {
      st = getDBTransaction().createCallableStatement(dbMethod, 0);
      st.registerOutParameter(1, 12);
      st.execute();
      return (String)st.getObject(1);
    }
    catch (SQLException e)
    {
      throw new JboException(getResourceMessage(Integer.toString(e.getErrorCode()), "Database Error", e.getMessage()));
    }
    finally
    {
      if (st != null) {
        try
        {
          st.close();
        }
        catch (SQLException e)
        {
          throw new JboException(e);
        }
      }
    }
  }
  
  public ArrayList<Object> callStoredObject(String storedObjectName, ArrayList<SqlParameter> parameters, boolean isFunction)
  {
    return SqlUtils.callPLSQLStoredObject(storedObjectName, parameters, isFunction, getDBTransaction());
  }
  
  public String getResourceMessage(String errorCode, String resourceBundleName, String errorDetail)
  {
    try
    {
      Locale currentLocale = Locale.getDefault();
      ResourceBundle message = ResourceBundle.getBundle(resourceBundleName, currentLocale);
      String returnMessage = message.getString(errorCode);
      if (errorDetail != null) {}
      return returnMessage + " Detail [" + errorDetail + "]";
    }
    catch (Exception e)
    {
      throw new JboException("Could not get error resource " + resourceBundleName.toString() + " for error code " + errorCode);
    }
  }
  
  protected Object getHistoryContextForAttribute(AttributeDefImpl attributeDefImpl)
  {
    if (attributeDefImpl.getHistoryKind() == 4)
    {
      String username = ADFContext.getCurrent().getSecurityContext().getUserName().toUpperCase();
      if (username.equalsIgnoreCase("anonymous"))
      {
        username = System.getenv("USERNAME");
        if (username == null) {
          username = "JVTest";
        }
        return username.toUpperCase();
      }
      return username.toUpperCase();
    }
    return super.getHistoryContextForAttribute(attributeDefImpl);
  }
  
  protected void preventRemoveIfDetailsExistInAccessor(String accessorName)
  {
    RowSet rs = (RowSet)getAttribute(accessorName);
    if ((rs != null) && (rs.first() != null)) {
      throw new RemoveWithDetailsException();
    }
  }
  
  public void remove()
  {
    if (this.checkChildrenExists) {
      restrictDeleteIfChildren();
    }
    super.remove();
  }
  
  private void restrictDeleteIfChildren()
  {
    Class clazz = getClass();
    Method[] methods = clazz.getMethods();
    for (Method method : methods)
    {
      Class returnClassType = method.getReturnType();
      if (returnClassType.equals(RowIterator.class)) {
        try
        {
          RowIterator rowIterator = (RowIterator)method.invoke(this, null);
          if (rowIterator.hasNext()) {
            throw new JboException("Delete not allowed. It contains childrens from " + method.getName());
          }
        }
        catch (IllegalAccessException e)
        {
          throw new IllegalStateException(e);
        }
        catch (InvocationTargetException e)
        {
          throw new IllegalStateException(e);
        }
      }
    }
  }
  
  public void isAttributeCreateAllowed(String action)
  {
    SecurityContext securityCtx = ADFContext.getCurrent().getSecurityContext();
    for (int i = 0; i < getEntityDef().getAttributeDefs().length; i++)
    {
      AttributeDefImpl a = getEntityDef().getAttributeDefImpl(i);
      EntityAttributePermission ep = new EntityAttributePermission(a.getFullName(), action);
      if (!securityCtx.hasPermission(ep)) {
        a.setUpdateableFlag((byte)0);
      }
    }
  }
  
  public void setCheckChildrenExists(boolean checkChildrenExists)
  {
    this.checkChildrenExists = checkChildrenExists;
  }
  
  public void setConvertAllAttributeToUpper(boolean convertAllAttributeToUpper)
  {
    this.convertAllAttributeToUpper = convertAllAttributeToUpper;
  }
  
  public void setDbUsername(String dbUsername)
  {
    this.dbUsername = dbUsername;
  }
  
  public String getSecurityUsername()
  {
    String username = null;
    if ((ADFContext.getCurrent() != null) && (ADFContext.getCurrent().getSecurityContext() != null)) {
      username = ADFContext.getCurrent().getSecurityContext().getUserName();
    } else {
      username = System.getenv("USERNAME");
    }
    return username.toUpperCase();
  }
  
  @Deprecated
  public String getDbUsername()
  {
    return getSecurityUsername();
  }
}