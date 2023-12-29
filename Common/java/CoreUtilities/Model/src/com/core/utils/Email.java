package com.core.utils;

import java.io.UnsupportedEncodingException;

import java.util.Date;
import java.util.Properties;
import java.util.logging.Logger;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;

import javax.mail.Address;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

public class Email
{
  private static String emailServerName = "smtp.libertyhealth.net";
  private static String emailServerPort = "25";
  private String emailUser = null;
  private String emailPassword = null;
  private String[] recipients = null;
  private String senderAddress = "noreply@libertyhealth.net";
  private String attachedFile = null;
  private String subject = null;
  private boolean isBodyHtml = false;
  private String body = null;
  private Logger logger = null;
  
  public void setUser(String emailUser, String emailPassword)
  {
    this.emailUser = emailUser;
    this.emailPassword = emailPassword;
  }
  
  public void setAttachment(String attachedFile)
  {
    this.attachedFile = attachedFile;
  }
  
  public void setRecipients(String[] recipients)
  {
    this.recipients = recipients;
  }
  
  public void setSenderAddress(String senderAddress)
  {
    this.senderAddress = senderAddress;
  }
  
  public void setSubject(String subject)
  {
    this.subject = subject;
  }
  
  public String getSubject()
  {
    return this.subject;
  }
  
  public void setBody(String body, boolean isHtml)
  {
    this.isBodyHtml = isHtml;
    this.body = body;
  }
  
  public String getBody()
  {
    return this.body;
  }
  
  public void send()
    throws MessagingException, UnsupportedEncodingException
  {
    if (this.senderAddress == null) {
      this.senderAddress = this.emailUser;
    }
    if (this.subject == null) {
      this.subject = "System email";
    }
    if ((this.body == null) && 
      (this.attachedFile != null))
    {
      this.isBodyHtml = true;
      this.body = ("The file \"" + this.attachedFile + "\" has been attached to this mail." + "<br><br>" + "This is an automated message.  Please do not reply to this message.");
    }
    Properties properties = new Properties();
    properties.put("mail.host", emailServerName);
    emailServerPort = null;
    if (emailServerPort != null) {
      properties.put("mail.port", emailServerPort);
    }
    Session session = Session.getInstance(properties, null);
    
    MimeMessage message = new MimeMessage(session);
    message.setFrom(new InternetAddress(this.senderAddress));
    
    Address[] recipientAddresses = new Address[this.recipients.length];
    
    int foo = 0;
    for (String recepient : this.recipients)
    {
      recipientAddresses[foo] = new InternetAddress(recepient, recepient);
      foo++;
    }
    message.setRecipients(Message.RecipientType.TO, recipientAddresses);
    
    message.setSubject(this.subject);
    message.setSentDate(new Date());
    
    MimeBodyPart messagePart = new MimeBodyPart();
    if (this.isBodyHtml) {
      messagePart.setContent(this.body, "text/html");
    } else {
      messagePart.setContent(this.body, "text/plain");
    }
    MimeBodyPart attachmentPart = null;
    if (this.attachedFile != null)
    {
      FileDataSource fileDataSource = new FileDataSource(this.attachedFile)
      {
        public String getContentType()
        {
          return "application/octet-stream";
        }
      };
      attachmentPart = new MimeBodyPart();
      attachmentPart.setDataHandler(new DataHandler(fileDataSource));
      
      String shortFilename = this.attachedFile;
      Integer bar = Integer.valueOf(this.attachedFile.lastIndexOf(System.getProperty("file.separator")));
      if (bar.intValue() > 0) {
        shortFilename = this.attachedFile.substring(bar.intValue() + 1, this.attachedFile.length());
      }
      attachmentPart.setFileName(shortFilename);
    }
    Multipart multipart = new MimeMultipart();
    multipart.addBodyPart(messagePart);
    if (this.attachedFile != null) {
      multipart.addBodyPart(attachmentPart);
    }
    message.setContent(multipart);
    
    Transport.send(message);
  }
}
