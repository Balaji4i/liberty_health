package com.liberty.health.comms.model.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.vo.common.CompanyVO;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Dec 21 22:22:03 IST 2022
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyVOImpl extends CoreViewObjectImpl implements CompanyVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyVOImpl() {
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
    }
}

