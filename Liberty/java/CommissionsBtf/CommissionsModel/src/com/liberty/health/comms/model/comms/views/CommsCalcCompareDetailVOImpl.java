package com.liberty.health.comms.model.comms.views;

import com.core.model.vo.classes.CoreViewObjectImpl;

// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Sep 12 11:42:14 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsCalcCompareDetailVOImpl extends CoreViewObjectImpl {
    /**
     * This is the default constructor (do not remove).
     */
    public CommsCalcCompareDetailVOImpl() {
    }

    /**
     * Returns the bind variable value for pCountryList.
     * @return bind variable value for pCountryList
     */
    public String getpCountryList() {
        return (String) getNamedWhereClauseParam("pCountryList");
    }

    /**
     * Sets <code>value</code> for bind variable pCountryList.
     * @param value value to bind as pCountryList
     */
    public void setpCountryList(String value) {
        setNamedWhereClauseParam("pCountryList", value);
    }
}

