package com.liberty.health.comms.model.lookup.vo.common;

import oracle.jbo.ViewObject;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 21 09:56:08 CAT 2018
// ---------------------------------------------------------------------
public interface CountryTaxesVO extends ViewObject {
    void setpCountryCode(String value);

    void updateEffDates(String countryCode);
}

