package com.core.reports;

import java.awt.print.PrinterJob;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import javax.print.PrintService;
import javax.print.PrintServiceLookup;
import oracle.adf.share.logging.ADFLogger;

public class PrinterUtils
{
  protected static ADFLogger _logger = ADFLogger.createADFLogger(PrinterUtils.class);
  
  public static enum ReportType
  {
    RT_DEFAULT,  RT_UNKNOWN,  RT_LASER,  RT_LABEL,  RT_SLIP,  RT_COLOR_LASER;
    
    private ReportType() {}
  }
  
  private static String soundex(String s)
  {
    char[] x = s.toUpperCase().toCharArray();
    char firstLetter = x[0];
    for (int i = 0; i < x.length; i++) {
      switch (x[i])
      {
      case 'B': 
      case 'F': 
      case 'P': 
      case 'V': 
        x[i] = '1';
        break;
      case 'C': 
      case 'G': 
      case 'J': 
      case 'K': 
      case 'Q': 
      case 'S': 
      case 'X': 
      case 'Z': 
        x[i] = '2';
        break;
      case 'D': 
      case 'T': 
        x[i] = '3';
        break;
      case 'L': 
        x[i] = '4';
        break;
      case 'M': 
      case 'N': 
        x[i] = '5';
        break;
      case 'R': 
        x[i] = '6';
        break;
      case 'E': 
      case 'H': 
      case 'I': 
      case 'O': 
      case 'U': 
      case 'W': 
      case 'Y': 
      default: 
        x[i] = '0';
      }
    }
    String output = "" + firstLetter;
    for (int i = 1; i < x.length; i++) {
      if ((x[i] != x[(i - 1)]) && (x[i] != '0')) {
        output = output + x[i];
      }
    }
    output = output + "0000";
    return output.substring(0, 4);
  }
  
  private static String replaceAll(String target, String from, String to)
  {
    int start = target.indexOf(from);
    if (start == -1) {
      return target;
    }
    int lf = from.length();
    char[] targetChars = target.toCharArray();
    StringBuffer buffer = new StringBuffer();
    int copyFrom = 0;
    while (start != -1)
    {
      buffer.append(targetChars, copyFrom, start - copyFrom);
      buffer.append(to);
      copyFrom = start + lf;
      start = target.indexOf(from, copyFrom);
    }
    buffer.append(targetChars, copyFrom, targetChars.length - copyFrom);
    return buffer.toString();
  }
  
  public static Map getLocalPrinters()
  {
    Map printers = new HashMap();
    
    PrintService[] services = PrinterJob.lookupPrintServices();
    for (int foo = 0; foo < services.length; foo++)
    {
      PrintService printService = services[foo];
      String printerName = printService.getName();
      
      printers.put(printerName, printService);
    }
    return printers;
  }
  
  public PrintService matchPrinter(String printerToMatch)
  {
    PrintService matchedService = null;
    String printer = printerToMatch;
    printer = replaceAll(printer, "PRINTERS_", "");
    printer = replaceAll(printer, "PKIT_", "");
    
    Map localPrinters = getLocalPrinters();
    Iterator it = localPrinters.keySet().iterator();
    
    Integer matchedScore = Integer.valueOf(0);
    while (it.hasNext())
    {
      String printerName = (String)it.next();
      if (printer.equalsIgnoreCase(printerName))
      {
        matchedService = (PrintService)localPrinters.get(printerName);
        matchedScore = Integer.valueOf(10);
      }
      if ((printerName.toUpperCase().contains(printer.toUpperCase())) && (matchedScore.intValue() <= 5))
      {
        matchedService = (PrintService)localPrinters.get(printerName);
        matchedScore = Integer.valueOf(7);
      }
      if ((soundex(printer).equalsIgnoreCase(soundex(printerName))) && (matchedScore.intValue() <= 7))
      {
        matchedService = (PrintService)localPrinters.get(printerName);
        matchedScore = Integer.valueOf(5);
      }
      if ((printerName.toUpperCase().startsWith(printer.toUpperCase())) && (matchedScore.intValue() <= 2))
      {
        matchedService = (PrintService)localPrinters.get(printerName);
        matchedScore = Integer.valueOf(2);
      }
    }
    if (matchedService == null) {
      _logger.info("-> Could not match " + printer);
    } else {
      _logger.info("Match info: Active Directory: " + printerToMatch + " Local: " + matchedService.getName() + " (Score: " + matchedScore + ")");
    }
    return matchedService;
  }
  
  private static ReportType getPrinterTypeFromName(String printerName)
  {
    ReportType printerType = ReportType.RT_UNKNOWN;
    
    printerName = printerName.toUpperCase();
    if (printerName.contains("LASER")) {
      printerType = ReportType.RT_LASER;
    }
    if ((printerName.contains("LABEL")) || (printerName.contains("BARCODE"))) {
      printerType = ReportType.RT_LABEL;
    }
    if (printerName.contains("SLIP")) {
      printerType = ReportType.RT_SLIP;
    }
    if ((printerName.contains("COLOR")) || (printerName.contains("COLOUR"))) {
      printerType = ReportType.RT_COLOR_LASER;
    }
    if (printerType == ReportType.RT_UNKNOWN)
    {
      _logger.info("WARNING: Printer type could not be determined for \"" + printerName + "\", assuming laser.");
      printerType = ReportType.RT_LASER;
    }
    return printerType;
  }
  
  public PrintService getPrintService(String userId, ReportType reportType)
    throws Exception
  {
    PrintService printService = null;
    
    _logger.info(userId);
    if (reportType == ReportType.RT_DEFAULT) {
      return PrintServiceLookup.lookupDefaultPrintService();
    }
    ActiveDirectoryReader activeDirectoryReader = new ActiveDirectoryReader();
    List adPrinters = activeDirectoryReader.getPrintersByNetworkId(userId);
    
    String requiredPrinter = null;
    Iterator foo = adPrinters.iterator();
    while (foo.hasNext())
    {
      String printerName = (String)foo.next();
      if (reportType == getPrinterTypeFromName(printerName))
      {
        requiredPrinter = printerName;
        break;
      }
    }
    if (requiredPrinter != null) {
      printService = matchPrinter(requiredPrinter);
    }
    return printService;
  }
}
