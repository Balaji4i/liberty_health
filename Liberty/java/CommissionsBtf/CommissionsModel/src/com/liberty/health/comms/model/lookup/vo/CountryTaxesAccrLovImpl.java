package com.liberty.health.comms.model.lookup.vo;

import com.liberty.health.comms.model.lookup.vo.common.CountryTaxesAccrLov;

import oracle.jbo.server.ViewObjectImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Sep 18 14:56:48 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CountryTaxesAccrLovImpl extends ViewObjectImpl implements CountryTaxesAccrLov {
    /**
     * This is the default constructor (do not remove).
     */
    public CountryTaxesAccrLovImpl() {
    }

    /**
     * Returns the bind variable value for pCountryFilter.
     * @return bind variable value for pCountryFilter
     */
    public String getpCountryFilter() {
        return (String) getNamedWhereClauseParam("pCountryFilter");
    }

    /**
     * Sets <code>value</code> for bind variable pCountryFilter.
     * @param value value to bind as pCountryFilter
     */
    public void setpCountryFilter(String value) {
        setNamedWhereClauseParam("pCountryFilter", value);
    }
}

