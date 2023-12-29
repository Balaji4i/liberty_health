package com.core.reports;

import com.core.generic.CoreActions;
import com.core.utils.Email;
import com.core.utils.FileDownloader;

import java.awt.print.PrinterJob;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.sql.Connection;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.Date;
import java.util.Iterator;
import java.util.Map;

import javax.faces.context.FacesContext;

import javax.print.PrintService;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.print.attribute.standard.Copies;
import javax.print.attribute.standard.MediaPrintableArea;
import javax.print.attribute.standard.MediaSize;
import javax.print.attribute.standard.MediaSizeName;
import javax.print.attribute.standard.PageRanges;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JRExporterParameter;
import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.design.JasperDesign;
import net.sf.jasperreports.engine.export.JRPrintServiceExporter;
import net.sf.jasperreports.engine.export.JRPrintServiceExporterParameter;
import net.sf.jasperreports.engine.export.JRXlsExporter;
import net.sf.jasperreports.engine.export.JRXlsExporterParameter;
import net.sf.jasperreports.engine.xml.JRXmlLoader;

import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;

import oracle.jbo.JboException;

public class ReportPrinter
  extends CoreActions
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(ReportPrinter.class);
  private static final String JASPER_UNCOMPILED_EXT = ".jrxml";
  private static final String JASPER_COMPILED_EXT = ".jasper";
  public ReportPrinter() {}
  
  public static enum ReportType
  {
    REPORT_TYPE_XLS,  REPORT_TYPE_PDF;
    
    private static final long serialVersionUID = 0L;
    
    private ReportType() {}
  }
  
  private static float CM_TO_INCHES = 2.54F;
  private String clientName;
  private Boolean useTempPath = Boolean.valueOf(false);
  
  public ReportPrinter(String clientName)
  {
    this.clientName = clientName;
  }
  
  public void extractFile(String resourceName, String destinationFilename)
    throws FileNotFoundException, IOException
  {
    InputStream inputStream = getClass().getResourceAsStream(resourceName);
    File f = new File(destinationFilename);
    
    OutputStream out = new FileOutputStream(f);
    byte[] buf = new byte['?'];
    int len;
    while ((len = inputStream.read(buf)) > 0) {
      out.write(buf, 0, len);
    }
    out.close();
    inputStream.close();
  }
  
  public String getTempPath()
  {
    String clientBasedTemp = "/reports/" + this.clientName + "/temp";
    File file = new File(clientBasedTemp);
    String tempDir = null;
    
    _logger.info("Testing " + clientBasedTemp + "...");
    if (file.exists())
    {
      tempDir = clientBasedTemp;
    }
    else
    {
      _logger.info("Using system temp folder...");
      tempDir = System.getProperty("java.io.tmpdir");
    }
    _logger.info("Setting temp to: " + tempDir);
    if (!tempDir.endsWith(System.getProperty("file.separator"))) {
      tempDir = tempDir + System.getProperty("file.separator");
    }
    return tempDir;
  }
  
  public void extractReportFiles(String[] reportFiles)
  {
    try
    {
      String tempPath = getTempPath();
      for (int foo = 0; foo < reportFiles.length; foo++) {
        extractFile(getResourceLocation() + reportFiles[foo], tempPath + reportFiles[foo]);
      }
    }
    catch (FileNotFoundException e)
    {
      e.printStackTrace();
    }
    catch (IOException e)
    {
      e.printStackTrace();
    }
  }
  
  private void setPrinterPaperSize(JasperPrint jasperPrint, PrintRequestAttributeSet printRequestAttributeSet)
  {
    float x = jasperPrint.getPageWidth() / 72;
    float y = jasperPrint.getPageHeight() / 72;
    
    float mediaX = x;
    float mediaY = y;
    if (x < 3.2D) {
      mediaY = 40.0F * CM_TO_INCHES;
    }
    if ((x == 4.0F) && (y == 4.0F))
    {
      mediaX = (float)(10.5D / CM_TO_INCHES);
      mediaY = (float)(14.8D / CM_TO_INCHES);
    }
    MediaSizeName mediaSizeName = MediaSize.findMedia(mediaX, mediaY, 25400);
    printRequestAttributeSet.add(mediaSizeName);
    
    x += 6.0F;
    y += 6.0F;
    
    String prnInfo = "x=" + x + ", " + "y=" + y + ", " + "mediaX=" + mediaX + ", " + "mediaY=" + mediaY + ", " + "mediaSizeName=" + mediaSizeName;
    _logger.info(prnInfo);
    
    MediaPrintableArea mediaPrintableArea = new MediaPrintableArea(0.0F, 0.0F, x, y, 25400);
    printRequestAttributeSet.add(mediaPrintableArea);
    
    printRequestAttributeSet.add(new PageRanges(1, Integer.MAX_VALUE));
  }
  
  public int printReport(String username, PrinterUtils.ReportType reportType, String clientName, String reportFile, Connection connection, Map reportParameters, String[] reportFiles)
    throws JRException, Exception
  {
    int numPages = 0;
    
    setClientName(clientName);
    if (reportFiles != null) {
      extractReportFiles(reportFiles);
    }
    String reportsPath = null;
    if (this.useTempPath.booleanValue())
    {
      reportsPath = getTempPath();
      reportFile = reportsPath + reportFile;
    }
    if (!new File(reportFile).exists())
    {
      reportsPath = getResourceLocation();
      reportFile = reportsPath + reportFile;
    }
    if ((!reportFile.toUpperCase().endsWith(".jrxml".toUpperCase())) && (!reportFile.toUpperCase().endsWith(".jasper".toUpperCase()))) {
      reportFile = reportFile + ".jrxml";
    }
    JasperDesign jasperDesign = JRXmlLoader.load(reportFile);
    JasperReport jasperReport = JasperCompileManager.compileReport(jasperDesign);
    jasperReport.setWhenNoDataType((byte)3);
    
    reportParameters.put("tempFolder", getTempPath());
    reportParameters.put("SUBREPORT_DIR", reportsPath);
    reportParameters.put("reportImages", reportsPath + "images" + System.getProperty("file.separator"));
    reportParameters.put("userName", username);
    
    JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParameters, connection);
    
    PrinterJob job = PrinterJob.getPrinterJob();
    PrinterUtils printerUtils = new PrinterUtils();
    
    PrintService printService = printerUtils.getPrintService(username, reportType);
    if (printService == null)
    {
      String errorMessage = reportType + ": No suitable printer exists for user \"" + username + "\"";
      _logger.info(errorMessage);
      throw new JboException(errorMessage);
    }
    job.setPrintService(printService);
    PrintRequestAttributeSet printRequestAttributeSet = new HashPrintRequestAttributeSet();
    printRequestAttributeSet.add(MediaSizeName.ISO_A4);
    printRequestAttributeSet.add(new Copies(1));
    numPages = jasperPrint.getPages().size();
    _logger.info("No.of pages: " + numPages);
    
    setPrinterPaperSize(jasperPrint, printRequestAttributeSet);
    
    JRPrintServiceExporter exporter = new JRPrintServiceExporter();
    exporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
    
    exporter.setParameter(JRPrintServiceExporterParameter.PRINT_SERVICE, printService);
    exporter.setParameter(JRPrintServiceExporterParameter.PRINT_SERVICE_ATTRIBUTE_SET, printService.getAttributes());
    exporter.setParameter(JRPrintServiceExporterParameter.PRINT_REQUEST_ATTRIBUTE_SET, printRequestAttributeSet);
    exporter.setParameter(JRPrintServiceExporterParameter.DISPLAY_PAGE_DIALOG, Boolean.FALSE);
    exporter.setParameter(JRPrintServiceExporterParameter.DISPLAY_PRINT_DIALOG, Boolean.FALSE);
    
    exporter.exportReport();
    
    return numPages;
  }
  
  @Deprecated
  public int printReport(String username, String printerName, String clientName, String reportFile, Connection connection, Map reportParameters, String[] reportFiles)
  {
    int numPages = 0;
    
    setClientName(clientName);
    if (reportFiles != null) {
      extractReportFiles(reportFiles);
    }
    String reportsPath = null;
    if (this.useTempPath.booleanValue())
    {
      reportsPath = getTempPath();
      reportFile = reportsPath + reportFile;
    }
    if (!new File(reportFile).exists())
    {
      reportsPath = getResourceLocation();
      reportFile = reportsPath + reportFile;
    }
    try
    {
      JasperDesign jasperDesign = JRXmlLoader.load(reportFile);
      JasperReport jasperReport = JasperCompileManager.compileReport(jasperDesign);
      jasperReport.setWhenNoDataType((byte)3);
      
      reportParameters.put("tempFolder", getTempPath());
      reportParameters.put("SUBREPORT_DIR", reportsPath);
      reportParameters.put("reportImages", reportsPath + "images" + System.getProperty("file.separator"));
      reportParameters.put("userName", username);
      
      JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParameters, connection);
      
      PrinterJob job = PrinterJob.getPrinterJob();
      
      PrintService[] services = PrinterJob.lookupPrintServices();
      PrintService printService = null;
      for (int count = 0; count < services.length; count++)
      {
        PrintService ps = services[count];
        if (ps.getName().equalsIgnoreCase(printerName)) {
          printService = ps;
        }
      }
      if (printService == null) {
        printService = services[0];
      }
      job.setPrintService(printService);
      PrintRequestAttributeSet printRequestAttributeSet = new HashPrintRequestAttributeSet();
      printRequestAttributeSet.add(MediaSizeName.ISO_A4);
      printRequestAttributeSet.add(new Copies(1));
      numPages = jasperPrint.getPages().size();
      _logger.info("No.of pages: " + numPages);
      
      JRPrintServiceExporter exporter = new JRPrintServiceExporter();
      exporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
      
      exporter.setParameter(JRPrintServiceExporterParameter.PRINT_SERVICE, printService);
      exporter.setParameter(JRPrintServiceExporterParameter.PRINT_SERVICE_ATTRIBUTE_SET, printService.getAttributes());
      exporter.setParameter(JRPrintServiceExporterParameter.PRINT_REQUEST_ATTRIBUTE_SET, printRequestAttributeSet);
      exporter.setParameter(JRPrintServiceExporterParameter.DISPLAY_PAGE_DIALOG, Boolean.FALSE);
      exporter.setParameter(JRPrintServiceExporterParameter.DISPLAY_PRINT_DIALOG, Boolean.FALSE);
      
      exporter.exportReport();
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
    return numPages;
  }
  
  public int emailReport(String username, String[] recipients, String subject, String body, String clientName, String reportFile, Connection connection, Map reportParameters, String[] reportFiles)
  {
    int numPages = 0;
    
    DateFormat df = new SimpleDateFormat("yyyyMMdd_HH'h'mm");
    String outFile = System.getProperty("file.separator") + reportFile + "_" + username + "_" + df.format(new Date()) + ".pdf";
    
    setClientName(clientName);
    if (reportFiles != null) {
      extractReportFiles(reportFiles);
    }
    String reportsPath = null;
    if (this.useTempPath.booleanValue())
    {
      reportsPath = getTempPath();
      reportFile = reportsPath + reportFile;
    }
    if (!new File(reportFile).exists())
    {
      reportsPath = getResourceLocation();
      reportFile = reportsPath + reportFile;
    }
    reportFile = reportFile + ".jrxml";
    try
    {
      JasperDesign jasperDesign = JRXmlLoader.load(reportFile);
      JasperReport jasperReport = JasperCompileManager.compileReport(jasperDesign);
      jasperReport.setWhenNoDataType((byte)3);
      
      reportParameters.put("tempFolder", getTempPath());
      reportParameters.put("SUBREPORT_DIR", reportsPath);
      reportParameters.put("reportImages", reportsPath + "images" + System.getProperty("file.separator"));
      reportParameters.put("userName", username);
      
      JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParameters, connection);
      
      JasperExportManager.exportReportToPdfFile(jasperPrint, getTempPath() + outFile);
      
      Email email = new Email();
      email.setRecipients(recipients);
      email.setSubject(subject);
      email.setBody(body, body.toUpperCase().contains("<BR>"));
      email.setAttachment(getTempPath() + outFile);
      email.send();
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
    return numPages;
  }
  
  public void downloadReport(String reportFile, ReportType reportType, Map reportParameters, String[] reportFiles, OutputStream outputStream)
    throws JRException
  {
    String outFile = saveReport(reportFile, reportType, reportParameters, reportFiles);
    FileDownloader.sendFileToOutputStream(outFile, outputStream, Boolean.valueOf(true));
    
    FacesContext facesContext = FacesContext.getCurrentInstance();
    facesContext.responseComplete();
  }
  
  public String saveReport(String reportFile, ReportType reportType, Map reportParameters, String[] reportFiles)
    throws JRException
  {
    String username = ADFContext.getCurrent().getSecurityContext().getUserName();
    
    Connection connection = (Connection)callOperation("getCurrentDatabaseConnection");
    _logger.info("Database connection : " + connection);
    
    return saveReport(username, reportFile, reportType, connection, reportParameters, reportFiles);
  }
  
  public String saveReport(String reportFile, ReportType reportType, Connection connection, Map reportParameters, String[] reportFiles)
    throws JRException
  {
    String username = ADFContext.getCurrent().getSecurityContext().getUserName();
    
    return saveReport(username, reportFile, reportType, connection, reportParameters, reportFiles);
  }
  
  public String saveReport(String username, String reportFile, ReportType reportType, Connection connection, Map reportParameters, String[] reportFiles)
    throws JRException
  {
    int numPages = 0;
    
    DateFormat df = new SimpleDateFormat("yyyyMMdd_HH'h'mm");
    String ext = ".pdf";
    if (reportType == ReportType.REPORT_TYPE_XLS) {
      ext = ".xls";
    }
    String outFile = getTempPath() + reportFile + "_" + username + "_" + df.format(new Date()) + ext;
    
    setClientName(this.clientName);
    if (reportFiles != null) {
      extractReportFiles(reportFiles);
    }
    String reportsPath = null;
    if (this.useTempPath.booleanValue())
    {
      reportsPath = getTempPath();
      reportFile = reportsPath + reportFile;
    }
    if (!new File(reportFile).exists())
    {
      reportsPath = getResourceLocation();
      reportFile = reportsPath + reportFile;
    }
    reportFile = reportFile + ".jrxml";
    _logger.info("Reportfile: " + reportFile);
    
    JasperDesign jasperDesign = JRXmlLoader.load(reportFile);
    JasperReport jasperReport = JasperCompileManager.compileReport(jasperDesign);
    jasperReport.setWhenNoDataType((byte)3);
    
    reportParameters.put("tempFolder", getTempPath());
    reportParameters.put("SUBREPORT_DIR", reportsPath);
    reportParameters.put("reportImages", reportsPath + "images" + System.getProperty("file.separator"));
    reportParameters.put("userName", username);
    
    Iterator iterator = reportParameters.keySet().iterator();
    _logger.info("Report Parameters:");
    _logger.info("  Report type: " + ext);
    while (iterator.hasNext())
    {
      Object key = iterator.next();
      
      String keyString = key.toString();
      Object value = reportParameters.get(key);
      if (keyString != null)
      {
        keyString = keyString.toUpperCase();
        if ((keyString.contains("PASSWORD")) || (keyString.contains("PWD"))) {
          value = "***********";
        }
      }
      _logger.info("  " + key + "=" + value);
    }
    JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, reportParameters, connection);
    if (reportType == ReportType.REPORT_TYPE_PDF) {
      JasperExportManager.exportReportToPdfFile(jasperPrint, outFile);
    }
    if (reportType == ReportType.REPORT_TYPE_XLS)
    {
      JRXlsExporter exporter = new JRXlsExporter();
      exporter.setParameter(JRExporterParameter.OUTPUT_FILE_NAME, outFile);
      exporter.setParameter(JRExporterParameter.JASPER_PRINT, jasperPrint);
      exporter.setParameter(JRXlsExporterParameter.IS_WHITE_PAGE_BACKGROUND, Boolean.FALSE);
      exporter.setParameter(JRXlsExporterParameter.IS_DETECT_CELL_TYPE, Boolean.TRUE);
      exporter.exportReport();
    }
    _logger.info("report saved to: " + outFile);
    return outFile;
  }
  
  public String getResourceLocation()
  {
    String uFileString = "/reports/" + getClientName() + "/reports/";
    String sFileString = "s:\\reports\\" + getClientName() + "\\";
    String cFileString = "c:\\jasperreports\\" + getClientName() + "\\reports\\";
    
    File sFile = new File(sFileString);
    File uFile = new File(uFileString);
    File cFile = new File(cFileString);
    if (sFile.exists()) {
      return sFileString;
    }
    if (uFile.exists()) {
      return uFileString;
    }
    return cFileString;
  }
  
  public void useTempPath(boolean b)
  {
    this.useTempPath = Boolean.valueOf(b);
  }
  
  public void setClientName(String clientName)
  {
    this.clientName = clientName;
  }
  
  public String getClientName()
  {
    return this.clientName;
  }
}
