package com.liberty.health.comms.model.lookup.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.lookup.vo.common.CompanyFeeTypeVO;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jul 20 11:37:02 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyFeeTypeVOImpl extends CoreViewObjectImpl implements CompanyFeeTypeVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyFeeTypeVOImpl() {
    }

    /**
     * Returns the variable value for pCompanyFeeTypeIdNo.
     * @return variable value for pCompanyFeeTypeIdNo
     */
    public Integer getpCompanyFeeTypeIdNo() {
        return (Integer) ensureVariableManager().getVariableValue("pCompanyFeeTypeIdNo");
    }

    /**
     * Sets <code>value</code> for variable pCompanyFeeTypeIdNo.
     * @param value value to bind as pCompanyFeeTypeIdNo
     */
    public void setpCompanyFeeTypeIdNo(Integer value) {
        ensureVariableManager().setVariableValue("pCompanyFeeTypeIdNo", value);
        this.executeQuery();
    }
}

