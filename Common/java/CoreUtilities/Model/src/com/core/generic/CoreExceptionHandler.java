package com.core.generic;

import com.core.utils.ExceptionMailer;

import java.sql.SQLException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

import javax.servlet.http.HttpServletRequest;

import oracle.adf.model.BindingContext;
import oracle.adf.model.RegionBinding;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCErrorHandlerImpl;
import oracle.adf.model.binding.DCErrorMessage;
import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.SecurityContext;

import oracle.jbo.JboException;

public class CoreExceptionHandler
  extends DCErrorHandlerImpl
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(CoreExceptionHandler.class);
  private MessageWrappingCodes messageWrappingCodes = new MessageWrappingCodes();
  
  public CoreExceptionHandler()
  {
    super(true);
  }
  
  public CoreExceptionHandler(boolean setToThrow)
  {
    super(setToThrow);
  }
  
  public DCErrorMessage getDetailedDisplayMessage(BindingContext bindingContext, RegionBinding regionBinding, Exception exception)
  {
    Throwable rootCauseEx = getRootCause(exception);
    if ((rootCauseEx instanceof JboException))
    {
      JboException jboexception = (JboException)rootCauseEx;
      String oraCode = getCode(jboexception);
      String message = this.messageWrappingCodes.getMessage(oraCode);
      if (message != null) {
        return new CustomDCErrorMesssage(message);
      }
    }
    else if ((rootCauseEx instanceof SQLException))
    {
      SQLException sqlEx = (SQLException)rootCauseEx;
      String oraCode = "ORA-0" + sqlEx.getErrorCode();
      
      String message = this.messageWrappingCodes.getMessage(oraCode);
      if (message != null) {
        return new CustomDCErrorMesssage(message);
      }
    }
    return super.getDetailedDisplayMessage(bindingContext, regionBinding, exception);
  }
  
  public void reportException(DCBindingContainer dCBindingContainer, Exception exception)
  {
    if (((exception instanceof JboException)) && (((JboException)exception).getErrorCode().equals("PITWARN")))
    {
      FacesContext context = FacesContext.getCurrentInstance();
      context.addMessage(null, new FacesMessage(FacesMessage.SEVERITY_WARN, ((JboException)exception).getBaseMessage(), null));
    }
    else if (((exception instanceof JboException)) && (((JboException)exception).getErrorCode().equals("PITINFO")))
    {
      FacesContext context = FacesContext.getCurrentInstance();
      context.addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, ((JboException)exception).getBaseMessage(), null));
    }
    else
    {
      Throwable rootException = getRootCause(exception);
      Map errorContext = getErrorContext(dCBindingContainer);
      handleAutomaticReporting(rootException, errorContext);
      super.reportException(dCBindingContainer, exception);
    }
  }
  
  private Throwable getRootCause(Exception exception)
  {
    Throwable rootException = exception;
    while (rootException.getCause() != null) {
      rootException = rootException.getCause();
    }
    return rootException;
  }
  
  private void handleAutomaticReporting(Throwable rootException, Map errorContext)
  {
    if ((rootException instanceof JboException))
    {
      AutomaticReportingList automaticReportingList = new AutomaticReportingList();
      
      JboException jboRootException = (JboException)rootException;
      if (automaticReportingList.contains(getCode(jboRootException)))
      {
        ExceptionMailer em = new ExceptionMailer();
        em.sendEmail(rootException, errorContext);
      }
    }
    else
    {
      ExceptionMailer em = new ExceptionMailer();
      em.sendEmail(rootException, errorContext);
    }
  }
  
  private String getCode(JboException jboRootException)
  {
    return jboRootException.getProductCode() + "-" + jboRootException.getErrorCode();
  }
  
  private Map getErrorContext(DCBindingContainer dCBindingContainer)
  {
    Map map = new HashMap();
    SecurityContext context = ADFContext.getCurrent().getSecurityContext();
    
    map.put("pageDefinition", dCBindingContainer.toString());
    map.put("username", context.getUserName());
    
    HttpServletRequest req = (HttpServletRequest)FacesContext.getCurrentInstance().getExternalContext().getRequest();
    
    map.put("url", req.getRequestURL());
    return map;
  }
  
  private static class AutomaticReportingList<JboException>
    extends HashSet
  {
    private AutomaticReportingList()
    {
      add("ORA-02292");
      add("ORA-02293");
      add("ORA-02294");
      add("ORA-02295");
    }
  }
  
  private class MessageWrappingCodes
  {
    private ResourceBundle resourceBundle = ResourceBundle.getBundle("com.core.resources.properties.oracodes.OraCodes_en_ZA");
    
    private MessageWrappingCodes() {}
    
    String getMessage(String oraCode)
    {
      try
      {
        return this.resourceBundle.getString(oraCode);
      }
      catch (MissingResourceException e) {}
      return null;
    }
  }
  
  public final class CustomDCErrorMesssage
    implements DCErrorMessage
  {
    String message;
    
    public CustomDCErrorMesssage(String message)
    {
      this.message = message;
    }
    
    public String getText()
    {
      return this.message;
    }
    
    public String getHTMLText()
    {
      return this.message;
    }
  }
}
