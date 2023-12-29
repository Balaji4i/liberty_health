package com.core.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import oracle.jbo.JboException;

public class FileDownloader
{
  public static void sendFileToOutputStream(String filename, OutputStream outputStream, Boolean delete)
  {
    File srcdoc = new File(filename);
    if (srcdoc.exists())
    {
      try
      {
        FileInputStream fis = new FileInputStream(srcdoc);
        int n;
        while ((n = fis.available()) > 0)
        {
          byte[] b = new byte[n];
          int result = fis.read(b);
          outputStream.write(b, 0, b.length);
          if (result == -1) {
            break;
          }
        }
        fis.close();
        outputStream.flush();
        outputStream.close();
      }
      catch (IOException e)
      {
        e.printStackTrace();
        throw new JboException(e.getMessage());
      }
      if (delete.booleanValue()) {
        srcdoc.delete();
      }
    }
  }
}
