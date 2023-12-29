package com.liberty.health.comms.model.brokerage.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.brokerage.vo.common.CompanyCountryVO;

// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Jun 28 15:24:53 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyCountryVOImpl extends CoreViewObjectImpl implements CompanyCountryVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyCountryVOImpl() {
    }

    /**
     * Returns the variable value for pCompanyIdNo.
     * @return variable value for pCompanyIdNo
     */
    public Integer getpCompanyIdNo() {
        return (Integer) ensureVariableManager().getVariableValue("pCompanyIdNo");
    }

    /**
     * Sets <code>value</code> for variable pCompanyIdNo.
     * @param value value to bind as pCompanyIdNo
     */
    public void setpCompanyIdNo(Integer value) {
        ensureVariableManager().setVariableValue("pCompanyIdNo", value);
        this.executeQuery();
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
}
