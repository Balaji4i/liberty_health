package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.ohi.vo.common.HoldIndicatorView;

import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 20 10:09:20 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class HoldIndicatorViewImpl extends CoreViewObjectImpl implements HoldIndicatorView {
    /**
     * This is the default constructor (do not remove).
     */
    public HoldIndicatorViewImpl() {
    }

    /**
     *
     * @param productCode
     * @param brokerIdNo
     * @param companyIdNo
     * @param groupCode
     * @param inseCode
     * @param policyCode
     */
    public void setHoldIndicatorViewCriteria(String productCode, Number brokerIdNo, Number companyIdNo, String groupCode,
                                            String inseCode, String policyCode) {
        this.setpProductCode(productCode);
        this.setpBrokerIdNo(brokerIdNo);
        this.setpCompanyIdNo(companyIdNo);
        this.setpGroupCode(groupCode);
        this.setpInseCode(inseCode);
        this.setpPolicyCode(policyCode);
        this.executeQuery();
    }

    public void updateEffDates(Integer compIdNo, Integer brokerIdNo, String groupCode, String productCode,
                               String policyCode, String memberCode) {
        String viewCriteriaName = "UpdateEffectiveEndDateViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.setNamedWhereClauseParam("pInseCode", memberCode);

        vo.setSortBy("CompanyIdNo, BrokerIdNo, GroupCode, ProductCode, PolicyCode, InseCode, EffectiveStartDate desc");
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();

        Date startDate = DateUtils.getLibertyMinDate();
        Boolean rowCheck = false;

        while (rowIt.hasNext()) {

            HoldIndicatorViewRowImpl row = (HoldIndicatorViewRowImpl) rowIt.next();
            Date endDate = row.getEffectiveEndDate();
            Date newEndDate = DateUtils.getLibertyMaxDate();

            if (!rowCheck) {
                System.out.println("Setting 31-jan end date");
                row.setEffectiveEndDate(newEndDate);
                rowCheck = true;
            } else {
                System.out.println("Setting new end date");
                row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
            }

            startDate = row.getEffectiveStartDate();

        }
        rowIt.closeRowSetIterator();
        this.getDBTransaction().commit();
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.setNamedWhereClauseParam("pInseCode", memberCode);
        vo.executeQuery();
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

    /**
     * Returns the variable value for pGroupCode.
     * @return variable value for pGroupCode
     */
    public String getpGroupCode() {
        return (String) ensureVariableManager().getVariableValue("pGroupCode");
    }

    /**
     * Sets <code>value</code> for variable pGroupCode.
     * @param value value to bind as pGroupCode
     */
    public void setpGroupCode(String value) {
        ensureVariableManager().setVariableValue("pGroupCode", value);
    }

    /**
     * Returns the variable value for pInseCode.
     * @return variable value for pInseCode
     */
    public String getpInseCode() {
        return (String) ensureVariableManager().getVariableValue("pInseCode");
    }

    /**
     * Sets <code>value</code> for variable pInseCode.
     * @param value value to bind as pInseCode
     */
    public void setpInseCode(String value) {
        ensureVariableManager().setVariableValue("pInseCode", value);
    }

    /**
     * Returns the variable value for pPolicyCode.
     * @return variable value for pPolicyCode
     */
    public String getpPolicyCode() {
        return (String) ensureVariableManager().getVariableValue("pPolicyCode");
    }

    /**
     * Sets <code>value</code> for variable pPolicyCode.
     * @param value value to bind as pPolicyCode
     */
    public void setpPolicyCode(String value) {
        ensureVariableManager().setVariableValue("pPolicyCode", value);
    }

    /**
     * Returns the variable value for pProductCode.
     * @return variable value for pProductCode
     */
    public String getpProductCode() {
        return (String) ensureVariableManager().getVariableValue("pProductCode");
    }

    /**
     * Sets <code>value</code> for variable pProductCode.
     * @param value value to bind as pProductCode
     */
    public void setpProductCode(String value) {
        ensureVariableManager().setVariableValue("pProductCode", value);
    }

    /**
     * Returns the variable value for pBrokerIdNo.
     * @return variable value for pBrokerIdNo
     */
    public Number getpBrokerIdNo() {
        return (Number) ensureVariableManager().getVariableValue("pBrokerIdNo");
    }

    /**
     * Sets <code>value</code> for variable pBrokerIdNo.
     * @param value value to bind as pBrokerIdNo
     */
    public void setpBrokerIdNo(Number value) {
        ensureVariableManager().setVariableValue("pBrokerIdNo", value);
    }
    
    public void setGroupVc(String groupCode) {
        String viewCriteriaName = "HoldIndicatorViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.executeQuery();
    }              
        
    public void setProductVc(String groupCode, String productCode) {
        String viewCriteriaName = "HoldIndicatorViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.executeQuery();
    }
    
    public void setPolicyVc(String policyCode) {
        String viewCriteriaName = "HoldIndicatorViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.executeQuery();
    }
    
    public void setPersonVc(String personCode) {
        String viewCriteriaName = "HoldIndicatorViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pInseCode", personCode);
        vo.executeQuery();
    }
    
    public void setCompanyVc(Number companyIdNo) {
        String viewCriteriaName = "HoldIndicatorViewCriteria";
        HoldIndicatorViewImpl vo = (HoldIndicatorViewImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo);
        vo.executeQuery();
    }

    /**
     * Returns the variable value for pCurrentDate.
     * @return variable value for pCurrentDate
     */
    public Date getpCurrentDate() {
        return (Date) ensureVariableManager().getVariableValue("pCurrentDate");
    }

    /**
     * Sets <code>value</code> for variable pCurrentDate.
     * @param value value to bind as pCurrentDate
     */
    public void setpCurrentDate(Date value) {
        ensureVariableManager().setVariableValue("pCurrentDate", value);
    }
}
