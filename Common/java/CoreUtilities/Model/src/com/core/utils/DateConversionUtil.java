package com.core.utils;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class DateConversionUtil
{
  public static java.util.Date convertStringToUtilDate(String dateStr, String dateFormat)
  {
    DateFormat df = new SimpleDateFormat(dateFormat);
    java.util.Date returnDate = null;
    try
    {
      returnDate = df.parse(dateStr);
    }
    catch (ParseException e)
    {
      e.printStackTrace();
    }
    return returnDate;
  }
  
  public static Timestamp convertStringToTimeStamp(String dateStr, String dateFormat)
  {
    java.util.Date utilDate = convertStringToUtilDate(dateStr, dateFormat);
    Timestamp returnDate = new Timestamp(utilDate.getTime());
    return returnDate;
  }
  
  public static java.sql.Date convertStringToSqlDate(String dateStr, String dateFormat)
  {
    java.util.Date utilDate = convertStringToUtilDate(dateStr, dateFormat);
    java.sql.Date sqlDate = new java.sql.Date(utilDate.getTime());
    
    return sqlDate;
  }
  
  public static oracle.jbo.domain.Date addDays(oracle.jbo.domain.Date inDate, int numOfDays)
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = inDate.getValue();
    cal.setTime(utilDate);
    cal.add(5, numOfDays);
    utilDate = cal.getTime();
    java.sql.Date sValue = new java.sql.Date(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static oracle.jbo.domain.Date subtractDays(oracle.jbo.domain.Date inDate, int numOfDays)
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = inDate.getValue();
    cal.setTime(utilDate);
    cal.add(5, numOfDays * -1);
    utilDate = cal.getTime();
    java.sql.Date sValue = new java.sql.Date(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static oracle.jbo.domain.Date subtractSeconds(oracle.jbo.domain.Date inDate, int numOfSeconds)
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = inDate.getValue();
    cal.setTime(utilDate);
    cal.add(13, numOfSeconds * -1);
    utilDate = cal.getTime();
    Timestamp sValue = new Timestamp(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static oracle.jbo.domain.Date addSeconds(oracle.jbo.domain.Date inDate, int numOfSeconds)
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = inDate.getValue();
    cal.setTime(utilDate);
    cal.add(13, numOfSeconds);
    utilDate = cal.getTime();
    Timestamp sValue = new Timestamp(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static oracle.jbo.domain.Date subtractDays(java.sql.Date inDate, int numOfDays)
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = new java.util.Date(inDate.getTime());
    
    cal.setTime(utilDate);
    cal.add(5, numOfDays * -1);
    utilDate = cal.getTime();
    java.sql.Date sValue = new java.sql.Date(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static int getDayOfWeek(oracle.jbo.domain.Date inDate)
  {
    Calendar cal = Calendar.getInstance();
    cal.setTime(inDate.getValue());
    int dayOfWeek = cal.get(7);
    return dayOfWeek;
  }
  
  public static oracle.jbo.domain.Date convertToOJDDate(java.util.Date inDate)
  {
    if (inDate != null)
    {
      java.sql.Date sqlDate = new java.sql.Date(inDate.getTime());
      return new oracle.jbo.domain.Date(sqlDate);
    }
    return null;
  }
  
  public static oracle.jbo.domain.Date convertToOJDDate(java.sql.Date inDate)
  {
    if (inDate != null) {
      return new oracle.jbo.domain.Date(inDate);
    }
    return null;
  }
  
  public static java.sql.Date convertToJSDate(java.util.Date inDate)
  {
    if (inDate != null) {
      return new java.sql.Date(inDate.getTime());
    }
    return null;
  }
  
  public static java.sql.Date convertToJSDate(Object value)
  {
    java.sql.Date sqlDate = null;
    if (value == null)
    {
      sqlDate = null;
    }
    else if ((value instanceof java.sql.Date))
    {
      sqlDate = (java.sql.Date)value;
    }
    else if ((value instanceof java.util.Date))
    {
      java.util.Date utilValue = (java.util.Date)value;
      sqlDate = new java.sql.Date(utilValue.getTime());
    }
    else if ((value instanceof oracle.jbo.domain.Date))
    {
      oracle.jbo.domain.Date oraDate = (oracle.jbo.domain.Date)value;
      
      java.util.Date utilDate = oraDate.getValue();
      sqlDate = new java.sql.Date(utilDate.getTime());
    }
    else if ((value instanceof String))
    {
      try
      {
        sqlDate = java.sql.Date.valueOf((String)value);
      }
      catch (Exception e)
      {
        sqlDate = null;
      }
    }
    return sqlDate;
  }
  
  public static java.sql.Date convertToJSDate(oracle.jbo.domain.Date inDate)
  {
    if (inDate != null)
    {
      java.util.Date utilDate = inDate.getValue();
      return new java.sql.Date(utilDate.getTime());
    }
    return null;
  }
  
  public static java.util.Date convertToJUDate(oracle.jbo.domain.Date inDate)
  {
    if (inDate != null) {
      return inDate.getValue();
    }
    return null;
  }
  
  public static java.util.Date convertToJUDate(java.sql.Date inDate)
  {
    if (inDate != null) {
      return new java.util.Date(inDate.getTime());
    }
    return null;
  }
  
  public static oracle.jbo.domain.Date now()
  {
    oracle.jbo.domain.Date retDate = null;
    Calendar cal = Calendar.getInstance();
    java.util.Date utilDate = cal.getTime();
    Timestamp sValue = new Timestamp(utilDate.getTime());
    retDate = new oracle.jbo.domain.Date(sValue);
    return retDate;
  }
  
  public static oracle.jbo.domain.Date truncateOJDDate(oracle.jbo.domain.Date dateTime, String fmt)
  {
    oracle.jbo.domain.Date truncatedDate = null;
    SimpleDateFormat sdf = new SimpleDateFormat(fmt);
    if (fmt == null) {
      fmt = "dd.MM.yyyy";
    }
    String fmtStr = sdf.format(dateTime.getValue());
    try
    {
      Timestamp ts = new Timestamp(sdf.parse(fmtStr).getTime());
      truncatedDate = new oracle.jbo.domain.Date(ts);
    }
    catch (ParseException e)
    {
      truncatedDate = dateTime;
    }
    return truncatedDate;
  }
  
  public static Integer NumberOfDaysInMonth(Integer year, Integer month)
  {
    GregorianCalendar cal = new GregorianCalendar(year.intValue(), month.intValue(), 1);
    return Integer.valueOf(cal.getActualMaximum(5));
  }
  
  public static Integer NumberOfDaysInMonth(java.sql.Date date)
  {
    GregorianCalendar calendar = new GregorianCalendar();
    calendar.setTime(date);
    
    return NumberOfDaysInMonth(Integer.valueOf(calendar.get(1)), Integer.valueOf(calendar.get(2)));
  }
}
