package com.core.utils;

import java.awt.Dimension;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import oracle.adf.view.faces.bi.component.graph.UIGraph;
import oracle.dss.dataView.ImageView;

public class GraphUtils
{
  public static void exportGraphToPng(UIGraph graphic, OutputStream outputStream)
    throws FileNotFoundException, IOException
  {
    Integer foo = Integer.valueOf(9000 + (int)(Math.random() * 1000.0D));
    String graphName = "graphic" + foo;
    
    ImageView imgView = graphic.getImageView();
    
    Dimension originalDim = imgView.getImageSize();
    
    imgView.setImageSize(new Dimension(800, 600));
    if (!graphName.contains(".")) {
      graphName = graphName + ".png";
    }
    String tempDir = System.getProperty("java.io.tmpdir");
    if (!tempDir.endsWith(System.getProperty("file.separator"))) {
      tempDir = tempDir + System.getProperty("file.separator");
    }
    graphName = tempDir + graphName;
    
    File file = new File(graphName);
    FileOutputStream fos = new FileOutputStream(file);
    imgView.exportToPNG(fos);
    fos.close();
    
    imgView.setImageSize(originalDim);
    FileDownloader.sendFileToOutputStream(graphName, outputStream, Boolean.valueOf(true));
  }
}
