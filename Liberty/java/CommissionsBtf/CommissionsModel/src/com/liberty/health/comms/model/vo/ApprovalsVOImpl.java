package com.liberty.health.comms.model.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;

import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Apr 14 18:13:27 IST 2023
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class ApprovalsVOImpl extends CoreViewObjectImpl {
    /**
     * This is the default constructor (do not remove).
     */
    public ApprovalsVOImpl() {
    }

    /**
     * Returns the bind variable value for pcountrylist.
     * @return bind variable value for pcountrylist
     */
    public String getpcountrylist() {
        return (String) getNamedWhereClauseParam("pcountrylist");
    }

    /**
     * Sets <code>value</code> for bind variable pcountrylist.
     * @param value value to bind as pcountrylist
     */
    public void setpcountrylist(String value) {
        setNamedWhereClauseParam("pcountrylist", value);
    }

    /**
     * Returns the variable value for pCompanyIdNo.
     * @return variable value for pCompanyIdNo
     */
    public Number getpCompanyIdNo() {
        return (Number) ensureVariableManager().getVariableValue("pCompanyIdNo");
    }

    /**
     * Sets <code>value</code> for variable pCompanyIdNo.
     * @param value value to bind as pCompanyIdNo
     */
    public void setpCompanyIdNo(Number value) {
        ensureVariableManager().setVariableValue("pCompanyIdNo", value);
    }
}
