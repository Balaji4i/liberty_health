package com.core.utils;

import java.lang.annotation.Annotation;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import oracle.adf.share.logging.ADFLogger;

@CoreLogging(teamLeader="LEOND", lastModified="LENG")
public class ExceptionMailer
{
  private static final String LIBERTY = "com.liberty";
  private final String appAdminEmail = "jaco.bosman@libertyhealth.net";
  private final String emailSuffix = "@libertyhealth.net";
  private static ADFLogger _logger = ADFLogger.createADFLogger(ExceptionMailer.class);
  private int recursionLevel;
  private Map errorContext;
  private String[] mailRecipients = { "jaco.bosman@libertyhealth.net" };
  Email email;
  
  public ExceptionMailer()
  {
    this.email = new Email();
    this.recursionLevel = 0;
  }
  
  public void setRecipients(String[] recipients)
  {
    this.mailRecipients = recipients;
  }
  
  public void sendEmail(Throwable rootException, Map errorContext)
  {
    this.errorContext = errorContext;
    this.recursionLevel = 0;
    try
    {
      if (rootException != null)
      {
        StackTraceElement str = getLibertyStackTraceElement(rootException);
        if (str == null)
        {
          sendExceptionToAppAdmin(rootException);
        }
        else
        {
          Class source = Class.forName(str.getClassName());
          if (source.isAnnotationPresent(CoreLogging.class)) {
            for (Annotation annotation : source.getAnnotations()) {
              if ((annotation instanceof CoreLogging))
              {
                CoreLogging doc = (CoreLogging)annotation;
                if (((doc.teamLeader() == null) || (doc.teamLeader().isEmpty())) && ((doc.lastModified() == null) || (doc.lastModified().isEmpty())))
                {
                  sendExceptionToAppAdmin(rootException); break;
                }
                sendExceptionToTeam(rootException, doc.teamLeader(), doc.lastModified());
                
                break;
              }
            }
          } else {
            sendExceptionToAppAdmin(rootException);
          }
        }
      }
      else
      {
        _logger.warning("Unable to get Exception from controllerContext - instance is null");
      }
    }
    catch (Exception e)
    {
      _logger.severe("Unable to notify development/appadmin team.", e);
    }
    finally
    {
      _logger.severe(rootException);
    }
  }
  
  public StackTraceElement getLibertyStackTraceElement(Throwable t)
  {
    if (t != null)
    {
      for (StackTraceElement element : t.getStackTrace()) {
        if (containsRecognisedPackage(element)) {
          return element;
        }
      }
      if ((t instanceof Exception))
      {
        Exception e = (Exception)t;
        if (this.recursionLevel == 3)
        {
          this.recursionLevel = 0;
          return null;
        }
        StackTraceElement element = getLibertyStackTraceElement(e.getCause());
        this.recursionLevel += 1;
        if (element != null) {
          return element;
        }
      }
    }
    return null;
  }
  
  static String getExceptionDetails(Throwable exception)
  {
    StringBuffer result = new StringBuffer();
    for (StackTraceElement element : exception.getStackTrace())
    {
      if (containsRecognisedPackage(element)) {
        result.append("<div style=\"color:#FF00FF\">" + element.toString() + "</div>");
      } else {
        result.append(element.toString());
      }
      result.append("\n");
    }
    String exToString = result.toString();
    exToString = exToString.replaceAll("\n", "<br>");
    return exToString;
  }
  
  public static void main(String[] args)
  {
    Exception ex = new Exception("asdadads");
    _logger.info(getExceptionDetails(ex));
    
    ExceptionMailer em = new ExceptionMailer();
    em.sendEmail(ex, new HashMap());
  }
  
  private void sendExceptionToAppAdmin(Throwable exception)
    throws Exception
  {
    sendEmail(exception, new String[] { "jaco.bosman@libertyhealth.net" });
  }
  
  private void sendExceptionToTeam(Throwable exception, String teamLeader, String lastModifiedBy)
    throws Exception
  {
    sendEmail(exception, new String[] { teamLeader + "@libertyhealth.net", lastModifiedBy + "@libertyhealth.net" });
  }
  
  private void sendEmail(Throwable exception, String[] recipients)
    throws Exception
  {
    Email email = new Email();
    email.setSubject("ADF Runtime Exceptions");
    email.setRecipients(recipients);
    email.setBody(getFormattedMessage(exception), true);
    email.send();
    
    _logger.info("Exception error sent to: " + recipients);
  }
  
  static boolean containsRecognisedPackage(StackTraceElement element)
  {
    String declaringClass = element.getClassName();
    if ((declaringClass.toString().contains("com.liberty"))) {
      return true;
    }
    return false;
  }
  
  private String getFormattedMessage(Throwable exception)
  {
    StringBuffer msg = new StringBuffer();
    msg.append("<b>Exception notification</b> <br>").append("\n");
    msg.append("<table border=\"1\">").append("\n");
    
    msg.append("<tr>").append("\n");
    msg.append("<th>").append("Occurred at").append("</th>").append("\n");
    msg.append("<td>").append(new Date()).append("</td>").append("\n");
    msg.append("</tr>").append("\n");
    
    msg.append("<tr>").append("\n");
    msg.append("<th>").append("URL").append("</th>").append("\n");
    msg.append("<td>").append(this.errorContext.get("url")).append("</td>").append("\n");
    msg.append("</tr>").append("\n");
    
    msg.append("<tr>").append("\n");
    msg.append("<th>").append("Username").append("</th>").append("\n");
    msg.append("<td>").append(this.errorContext.get("username")).append("</td>").append("\n");
    msg.append("</tr>").append("\n");
    
    msg.append("<tr>").append("\n");
    msg.append("<th>").append("PageDefinition").append("</th>").append("\n");
    msg.append("<td>").append(this.errorContext.get("pageDefinition")).append("</td>").append("\n");
    msg.append("</tr>").append("\n");
    
    msg.append("<tr>").append("\n");
    msg.append("<th>").append("Stacktrace").append("</th>").append("\n");
    msg.append("<td>").append(getExceptionDetails(exception)).append("</td>").append("\n");
    msg.append("</tr>").append("\n");
    
    msg.append("</table>").append("\n");
    
    return msg.toString();
  }
}
