package com.core.model.services.classes;

import com.core.model.vo.classes.CoreViewRowImpl;
import com.core.utils.SqlParameter;
import com.core.utils.SqlUtils;

import java.io.ByteArrayOutputStream;
import java.io.OutputStream;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import net.sf.jasperreports.engine.JasperCompileManager;
import net.sf.jasperreports.engine.JasperExportManager;
import net.sf.jasperreports.engine.JasperFillManager;
import net.sf.jasperreports.engine.JasperPrint;
import net.sf.jasperreports.engine.JasperReport;
import net.sf.jasperreports.engine.design.JasperDesign;
import net.sf.jasperreports.engine.export.JRXlsExporter;
import net.sf.jasperreports.engine.export.JRXlsExporterParameter;
import net.sf.jasperreports.engine.util.JRLoader;
import net.sf.jasperreports.engine.xml.JRXmlLoader;

import oracle.adf.share.ADFContext;
import oracle.adf.share.logging.ADFLogger;
import oracle.adf.share.security.SecurityContext;

import oracle.jbo.Row;
import oracle.jbo.Session;
import oracle.jbo.server.ApplicationModuleImpl;

public class CoreApplicationModuleImpl
  extends ApplicationModuleImpl
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(CoreApplicationModuleImpl.class);
  private static String REPORTS_PATH = "C:\\JasperReports\\Liberty\\";
  private static String REPORT_IMAGES_PATH = "C:\\JasperReports\\Liberty\\images\\";
  
  protected void prepareSession(Session session)
  {
    super.prepareSession(session);
    getDBTransaction().setClearCacheOnRollback(false);
  }
  
  public String getRowStatus(Row row)
  {
    try
    {
      CoreViewRowImpl rwImpl = (CoreViewRowImpl)row;
      if (rwImpl != null) {
        return translateStatusToString(rwImpl.getEntity(0).getEntityState());
      }
      return "Unknown";
    }
    catch (Exception e) {}
    return "Unknown";
  }
  
  private String translateStatusToString(byte b)
  {
    String ret = null;
    switch (b)
    {
    case -1: 
      ret = "Initialized";
      break;
    case 2: 
      ret = "Modified";
      break;
    case 1: 
      ret = "Unmodified";
      break;
    case 0: 
      ret = "New";
    }
    return ret;
  }
  
  public Connection getCurrentConnection()
    throws SQLException
  {
    PreparedStatement st = getDBTransaction().createPreparedStatement("commit", 1);
    Connection conn = st.getConnection();
    st.close();
    return conn;
  }
  
  public void downloadReport(OutputStream outputStream, Map parameterMap, String reportName, String downloadType)
  {
    Connection jdbcConnection = null;
    
    _logger.info("downloadReport in CoreApplicationModuleImpl.");
    try
    {
      jdbcConnection = getCurrentConnection();
    }
    catch (Exception e)
    {
      e.printStackTrace();
    }
    if ((!reportName.toLowerCase().endsWith(".jrxml")) && (!reportName.toLowerCase().endsWith(".jasper"))) {
      reportName = reportName + ".jrxml";
    }
    String reportFile = REPORTS_PATH + reportName;
    if (parameterMap == null) {
      parameterMap = new HashMap();
    }
    SecurityContext securityContext = ADFContext.getCurrent().getSecurityContext();
    String username = securityContext.getUserName();
    
    parameterMap.put("reportImages", REPORT_IMAGES_PATH);
    parameterMap.put("userName", username);
    try
    {
      JasperDesign jasperDesign = JRXmlLoader.load(reportFile);
      JasperReport jasperReport;
      if (reportName.toLowerCase().endsWith(".jrxml")) {
        jasperReport = JasperCompileManager.compileReport(jasperDesign);
      } else {
        jasperReport = (JasperReport)JRLoader.loadObject(reportName);
      }
      JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, null, jdbcConnection);
      if ("pdf".equalsIgnoreCase(downloadType))
      {
        JasperExportManager.exportReportToPdfStream(jasperPrint, outputStream);
      }
      else if ("xls".equalsIgnoreCase(downloadType))
      {
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        
        JRXlsExporter exporterXLS = new JRXlsExporter();
        exporterXLS.setParameter(JRXlsExporterParameter.JASPER_PRINT, jasperPrint);
        exporterXLS.setParameter(JRXlsExporterParameter.OUTPUT_STREAM, byteArrayOutputStream);
        exporterXLS.exportReport();
        
        outputStream.write(byteArrayOutputStream.toByteArray());
      }
      else
      {
        throw new Exception("Export type \"" + downloadType + "\" not supported");
      }
      outputStream.flush();
      outputStream.close();
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
  }
  
  
  public ArrayList<Object> callStoredObject(String storedObjectName, ArrayList<SqlParameter> parameters, boolean isFunction)
  {
    return SqlUtils.callPLSQLStoredObject(storedObjectName, parameters, isFunction, getDBTransaction());
  }
}
