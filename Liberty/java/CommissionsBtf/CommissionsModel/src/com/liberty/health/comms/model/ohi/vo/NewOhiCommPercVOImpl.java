package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.ohi.vo.common.NewOhiCommPercVO;

import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 13 10:47:27 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class NewOhiCommPercVOImpl extends CoreViewObjectImpl implements NewOhiCommPercVO {
    /**
     * This is the default constructor (do not remove).
     */
    public NewOhiCommPercVOImpl() {
    }

    /**
     * Returns the variable value for pProductCode.
     * @return variable value for pProductCode
     */
    public String getpProductCode() {
        return (String) ensureVariableManager().getVariableValue("pProductCode");
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
    public void setNewOhiCommPercVOCriteria(String productCode, Number brokerIdNo, Number companyIdNo, String groupCode,
                                            String inseCode, String policyCode) {
        this.setpProductCode(productCode);
        this.setpBrokerIdNo(brokerIdNo);
        this.setpCompanyIdNo(companyIdNo);
        this.setpGroupCode(groupCode);
        this.setpInseCode(inseCode);
        this.setpPolicyCode(policyCode);
        this.executeQuery();
    }

    /**
     * Sets <code>value</code> for variable pProductCode.
     * @param value value to bind as pProductCode
     */
    public void setpProductCode(String value) {
        ensureVariableManager().setVariableValue("pProductCode", value);
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
        String viewCriteriaName = "NewOhiGroupCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.executeQuery();
    }

    public void setProductVc(String groupCode, String productCode) {
        String viewCriteriaName = "NewOhiProductCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.executeQuery();
    }

    public void setBrokerVc(Number brokerIdNo) {
        String viewCriteriaName = "NewOhiBrokerCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.executeQuery();
    }

    public void setPolicyVc(String policyCode) {
        String viewCriteriaName = "NewOhiPolicyCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.executeQuery();
    }

    public void setPersonVc(String personCode) {
        String viewCriteriaName = "NewOhiPersonCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pInseCode", personCode);
        vo.executeQuery();
    }

    public void setCompanyVc(Number companyIdNo) {
        String viewCriteriaName = "NewOhiCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo);
        vo.executeQuery();
    }


    public String setAuthUsername(String username) {
        String returnMsg = null;
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();
        NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) vo.getCurrentRow();

        if (row.getCreatedUsername().compareTo(username) == 0) {
            returnMsg = "You created the record and therefore cannot approve the change as well.";
        } else {
            row.setAuthUsername(username);
            row.setRejectUsername(null);
            this.getDBTransaction().commit();
            this.executeQuery();
        }
        return returnMsg;
    }

    public String resubmitForApproval() {
        String returnMsg = null;
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();
        NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) vo.getCurrentRow();

        if (row.getAuthUsername() != null && row.getRejectUsername() != null) {
            returnMsg = "Record cannot be resubmitted. Contact your manager for assistance";
        } else {
            row.setAuthUsername(null);
            row.setRejectUsername(null);
            this.getDBTransaction().commit();
            this.executeQuery();
        }
        return returnMsg;
    }

    public String setRejectUsername(String username, String comment) {
        String returnMsg = null;
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();
        NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) vo.getCurrentRow();

        if (row.getAuthUsername() != null) {
            returnMsg = "The record has already been approved. Cannot reject approved records.";
        } else {
            row.setRejectUsername(username);
            row.setCommDesc(comment);
            this.getDBTransaction().commit();
            this.executeQuery();
        }
        return returnMsg;
    }

    public String removeUserRecord() {
        String returnMsg = null;
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();
        NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) vo.getCurrentRow();

        if (row.getAuthUsername() != null) {
            returnMsg = "The record has already been approved. Cannot reject approved records.";
        } else {
            row.remove();
            this.getDBTransaction().commit();
            this.executeQuery();
        }
        return returnMsg;
    }

    public void updateEffDates(Integer compIdNo, Integer brokerIdNo, String groupCode, String productCode,
                               String policyCode, String memberCode) {
        

        String viewCriteriaName = "UpdateEffectiveEndDateViewCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

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

            NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) rowIt.next();
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

    public void setUpdateGroupVc(String groupCode, Date startDate) {
        String viewCriteriaName = "UpdateGroupCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateProductVc(String groupCode, String productCode, Date startDate) {
        String viewCriteriaName = "UpdateProductCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdatePolicyVc(String policyCode, Date startDate) {
        String viewCriteriaName = "UpdatePolicyCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdatePersonVc(String personCode, Date startDate) {
        String viewCriteriaName = "UpdatePersonCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pInseCode", personCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateCompanyVc(Number companyIdNo, Date startDate) {
        String viewCriteriaName = "UpdateCompanyCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateBrokerVc(Number brokerIdNo, Date startDate) {
        String viewCriteriaName = "UpdateBrokerCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }


    public void setUpdateRejectGroupVc(String groupCode, Date startDate) {
        String viewCriteriaName = "UpdateRejectGroupCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateRejectProductVc(String groupCode, String productCode, Date startDate) {
        String viewCriteriaName = "UpdateRejectProductCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pGroupCode", groupCode);
        vo.setNamedWhereClauseParam("pProductCode", productCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateRejectPolicyVc(String policyCode, Date startDate) {
        String viewCriteriaName = "UpdateRejectPolicyCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pPolicyCode", policyCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateRejectPersonVc(String personCode, Date startDate) {
        String viewCriteriaName = "UpdateRejectPersonCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pInseCode", personCode);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateRejectCompanyVc(Number companyIdNo, Date startDate) {
        String viewCriteriaName = "UpdateRejectCompanyCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    public void setUpdateRejectBrokerVc(Number brokerIdNo, Date startDate) {
        String viewCriteriaName = "UpdateRejectBrokerCommPercVOCriteria";
        NewOhiCommPercVOImpl vo = (NewOhiCommPercVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pStartDate", startDate);
        vo.executeQuery();
    }

    /**
     * Returns the variable value for pStartDate.
     * @return variable value for pStartDate
     */
    public Date getpStartDate() {
        return (Date) ensureVariableManager().getVariableValue("pStartDate");
    }

    /**
     * Sets <code>value</code> for variable pStartDate.
     * @param value value to bind as pStartDate
     */
    public void setpStartDate(Date value) {
        ensureVariableManager().setVariableValue("pStartDate", value);
    }
}

