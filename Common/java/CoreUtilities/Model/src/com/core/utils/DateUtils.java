package com.core.utils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import java.util.Calendar;
import java.util.GregorianCalendar;

import oracle.jbo.ValidationException;
import oracle.jbo.domain.Timestamp;

public class DateUtils {
    public static oracle.jbo.domain.Date currentDateTruncated() {
        java.util.Date currentDate = new java.util.Date();
        DateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
        String formatedDateStr = dateFormat.format(currentDate);
        java.util.Date truncatedDate;
        try {
            truncatedDate = dateFormat.parse(formatedDateStr);
        } catch (ParseException pe) {
            truncatedDate = currentDate;
            throw new ValidationException("com.core.utils.DateUtils ERROR: could not parse date in string \"" +
                                          formatedDateStr + "\"");
        }
        java.sql.Date sqlDate = new java.sql.Date(truncatedDate.getTime());
        oracle.jbo.domain.Date oraDate = new oracle.jbo.domain.Date(sqlDate);
        return oraDate;
    }

    public static oracle.jbo.domain.Date currentDateFormatted(String pformatStr) {
        java.util.Date currentDate = new java.util.Date();
        if ((pformatStr != null) || (pformatStr.length() <= 0)) {
            pformatStr = "dd-MMM-yyyy";
        }
        DateFormat dateFormat = new SimpleDateFormat(pformatStr);
        String formatedDateStr = dateFormat.format(currentDate);
        java.util.Date formattedDate;
        try {
            formattedDate = dateFormat.parse(formatedDateStr);
        } catch (ParseException pe) {
            formattedDate = currentDate;
            throw new ValidationException("com.score.utils.DateUtils ERROR: could not parse date in string \"" +
                                          formatedDateStr + "\"");
        }
        java.sql.Date sqlDate = new java.sql.Date(formattedDate.getTime());
        oracle.jbo.domain.Date oraDate = new oracle.jbo.domain.Date(sqlDate);
        return oraDate;
    }

    public static oracle.jbo.domain.Date getLibertyMinDate() {
        Calendar sratingCal = new GregorianCalendar(1652, 4, 6);
        java.util.Date utlDate = sratingCal.getTime();

        java.sql.Date sqlDate = new java.sql.Date(utlDate.getTime());
        oracle.jbo.domain.Date minDate = new oracle.jbo.domain.Date(sqlDate);

        return minDate;
    }

    public static oracle.jbo.domain.Date getLibertyMaxDate() {
        Calendar sratingCal = new GregorianCalendar(3099, 12, 31);
        java.util.Date utlDate = sratingCal.getTime();

        java.sql.Date sqlDate = new java.sql.Date(utlDate.getTime());
        oracle.jbo.domain.Date maxDate = new oracle.jbo.domain.Date(sqlDate);

        return maxDate;
    }
    
    public static Timestamp getLibertyMaxDatetime() {
        Timestamp newEndDate = new Timestamp();
        String dateString = "3100/01/31";       
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/mm/dd");
        try {
            java.util.Date convertedDate = dateFormat.parse(dateString);
            newEndDate = new Timestamp(convertedDate);
        } catch (ParseException e) {
        }
        return newEndDate;
    }

    public static java.util.Date currentUtilDateTruncated() {
        java.util.Date currentDate = new java.util.Date();
        DateFormat dateFormat = new SimpleDateFormat("dd-MMM-yyyy");
        String formatedDateStr = dateFormat.format(currentDate);
        java.util.Date truncatedDate;
        try {
            truncatedDate = dateFormat.parse(formatedDateStr);
        } catch (ParseException pe) {
            truncatedDate = currentDate;
            throw new ValidationException("com.core.utils.DateUtils ERROR: could not parse date in string \"" +
                                          formatedDateStr + "\"");
        }
        return truncatedDate;
    }
}
