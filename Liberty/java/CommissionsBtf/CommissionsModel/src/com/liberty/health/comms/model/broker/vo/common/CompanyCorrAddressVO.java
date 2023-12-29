package com.liberty.health.comms.model.broker.vo.common;

import java.util.ArrayList;

import oracle.jbo.AttributeList;
import oracle.jbo.Row;
import oracle.jbo.ViewObject;
import oracle.jbo.domain.Date;
import oracle.jbo.server.TransactionEvent;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Aug 13 11:24:36 CAT 2018
// ---------------------------------------------------------------------
public interface CompanyCorrAddressVO extends ViewObject {
    void afterRollback(TransactionEvent param);

    void beforeRollback(TransactionEvent param);

    AttributeList copyRow(Row param, ArrayList<String> param2);

    void enableQueryLimit(boolean param, int param2);

    Integer getpCompanyIdNo();

    Date getpCurrentDate();

    void refreshCurrentRow();

    void requeryAndReturnToCurrentRow();

    void setCorrViewCriteria(Integer companyIdNo);

    void setViewCriteriaAutoExecute(Boolean param, String param2);

    void setpCompanyIdNo(Integer value);

    void setpCurrentDate(Date value);

    void updateCorrEffDates(Integer compIdNo, Date currentDate);

    String getpAddressTypeCode();

    void setpAddressTypeCode(String value);
}

