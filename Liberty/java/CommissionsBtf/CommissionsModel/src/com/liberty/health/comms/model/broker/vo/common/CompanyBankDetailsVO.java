package com.liberty.health.comms.model.broker.vo.common;

import oracle.jbo.ViewObject;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue May 16 11:14:45 CAT 2017
// ---------------------------------------------------------------------
public interface CompanyBankDetailsVO extends ViewObject {
    void setByPkViewCritiera(Integer companyIdNo, String countryCode);

    void updateEffDates(Integer compIdNo, String countryCode, Date currentDate);
}

