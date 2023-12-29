package com.core.utils;

import java.sql.CallableStatement;
import java.sql.SQLException;

import java.util.ArrayList;

import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.JboException;
import oracle.jbo.server.DBTransaction;

public class SqlUtils
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(SqlUtils.class);
  
  public static ArrayList<Object> callPLSQLStoredObject(String storedObjectName, ArrayList<SqlParameter> parameters, boolean isFunction, DBTransaction dbTransaction)
  {
    ArrayList ret = new ArrayList();
    CallableStatement st = null;
    String stringSqlParameters = "(";
    ArrayList<SqlParameter> outParams = new ArrayList();
    ArrayList<SqlParameter> inParams = new ArrayList();
    for (int i = 0; i < parameters.size(); i++)
    {
      String type = ((SqlParameter)parameters.get(i)).getInOutInd();
      if ("in".equalsIgnoreCase(type)) {
        inParams.add(parameters.get(i));
      }
      if ("out".equalsIgnoreCase(type)) {
        outParams.add(parameters.get(i));
      }
    }
    if (isFunction)
    {
      if (outParams.size() > 1) {
        throw new JboException("A Function can only have 1 OUT Parameter");
      }
      if (outParams.size() == 0) {
        throw new JboException("A Function must contain atleast 1 OUT Patameter");
      }
      for (int i = 0; i < inParams.size(); i++)
      {
        stringSqlParameters = stringSqlParameters + ((SqlParameter)parameters.get(i)).getParamName() + "=>?";
        if (i != inParams.size() - 1) {
          stringSqlParameters = stringSqlParameters + ", ";
        }
      }
    }
    else
    {
      for (int i = 0; i < parameters.size(); i++)
      {
        stringSqlParameters = stringSqlParameters + ((SqlParameter)parameters.get(i)).getParamName() + "=>?";
        if (i != parameters.size() - 1) {
          stringSqlParameters = stringSqlParameters + ", ";
        }
      }
    }
    if (stringSqlParameters == null) {
      stringSqlParameters = "(";
    }
    stringSqlParameters = stringSqlParameters + ");";
    String statement = null;
    try
    {
      if (isFunction)
      {
        statement = "Begin ? := " + storedObjectName + stringSqlParameters + " end;";
        st = dbTransaction.createCallableStatement(statement, 0);
        st.registerOutParameter(1, ((SqlParameter)outParams.get(0)).getDataType());
        for (int i = 0; i < inParams.size(); i++) {
          st.setObject(i + 2, ((SqlParameter)inParams.get(i)).getValue());
        }
        st.execute();
        ret.add(st.getObject(1));
      }
      else
      {
        statement = "Begin " + storedObjectName + stringSqlParameters + " end;";
        st = dbTransaction.createCallableStatement(statement, 0);
        for (int i = 0; i < parameters.size(); i++)
        {
          if (((SqlParameter)parameters.get(i)).getInOutInd().equalsIgnoreCase("OUT")) {
            st.registerOutParameter(i + 1, ((SqlParameter)parameters.get(i)).getDataType());
          }
          if (((SqlParameter)parameters.get(i)).getInOutInd().equalsIgnoreCase("IN")) {
            st.setObject(i + 1, ((SqlParameter)parameters.get(i)).getValue());
          }
        }
        st.execute();
        for (int i = 0; i < parameters.size(); i++) {
          if (((SqlParameter)parameters.get(i)).getInOutInd().equalsIgnoreCase("OUT")) {
            if (st != null)
            {
              Object obj = st.getObject(i + 1);
              if (obj != null) {
                ret.add(obj);
              }
            }
          }
        }
      }
      return ret;
    }
    catch (SQLException e)
    {
      throw new JboException("Statement called : " + statement + "\n" + e.getMessage());
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
}
