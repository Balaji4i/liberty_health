package com.core.utils;

import java.io.DataInputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import oracle.adf.share.logging.ADFLogger;
import oracle.ord.im.OrdDocDomain;
import org.apache.myfaces.trinidad.model.UploadedFile;

public class UploadedFileConvertor
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(UploadedFileConvertor.class);
  private static final Object[][] sMimeTypeList = { { "7z", "application/x-7z-compressed" }, { "bmp", "image/bmp" }, { "doc", "application/msword" }, { "docx", "application/msword" }, { "gif", "image/gif" }, { "jpg", "image/jpeg" }, { "jpeg", "image/jpeg" }, { "msg", "application/vnd.ms-outlook" }, { "rar", "application/x-rar-compressed" }, { "sql", "text/plain" }, { "txt", "text/plain" }, { "xls", "application/excel" }, { "xlsx", "application/excel" }, { "zip", "application/x-zip-compressed" } };
  
  public static String getMimeType(UploadedFile file)
  {
    String mimeType = file.getContentType();
    String filename = file.getFilename();
    if ("application/octet-stream".equalsIgnoreCase(mimeType))
    {
      for (int foo = 0; foo < sMimeTypeList.length; foo++)
      {
        String[] sMimeTypeItem = (String[])sMimeTypeList[foo];
        if (filename.toLowerCase().endsWith(sMimeTypeItem[0])) {
          mimeType = sMimeTypeItem[1];
        }
      }
      _logger.info("Changing mime type to: " + mimeType);
    }
    return mimeType;
  }
  
  public static OrdDocDomain convertToOrdDocDomain(UploadedFile file, boolean setMimeType)
  {
    SimpleDateFormat formatter = new SimpleDateFormat("HH:mm:ss:SSS");
    if (file == null) {
      return null;
    }
    _logger.info("convertToOrdDocDomain start: " + file.getFilename() + " (set mimetype: " + setMimeType + ")");
    _logger.info("Start: " + formatter.format(new Date()));
    
    OrdDocDomain ordDoc = null;
    try
    {
      byte[] b = new byte[(int)file.getLength()];
      DataInputStream in = new DataInputStream(file.getInputStream());
      
      int byteRead = 0;
      int totalBytesRead = 0;
      while (totalBytesRead < file.getLength())
      {
        byteRead = in.read(b, totalBytesRead, (int)file.getLength());
        totalBytesRead += byteRead;
      }
      ordDoc = new OrdDocDomain(b);
      ordDoc.setContentLength((int)file.getLength());
      ordDoc.setSource(file.getContentType(), null, file.getFilename());
      if (setMimeType)
      {
        String mimeType = getMimeType(file);
        ordDoc.setMimeType(mimeType);
      }
    }
    catch (SQLException _sqle)
    {
      _sqle.printStackTrace();
    }
    catch (IOException _ioe)
    {
      _ioe.printStackTrace();
    }
    _logger.info("convertToOrdDocDomain done.");
    _logger.info("End: " + formatter.format(new Date()));
    
    return ordDoc;
  }
}
