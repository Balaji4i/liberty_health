package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.broker.vo.common.CompanyBankDetailsVO;

import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue May 16 11:13:26 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyBankDetailsVOImpl extends CoreViewObjectImpl implements CompanyBankDetailsVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyBankDetailsVOImpl() {
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

    /**
     * Returns the variable value for pCountryCode.
     * @return variable value for pCountryCode
     */
    public String getpCountryCode() {
        return (String) ensureVariableManager().getVariableValue("pCountryCode");
    }

    /**
     * Sets <code>value</code> for variable pCountryCode.
     * @param value value to bind as pCountryCode
     */
    public void setpCountryCode(String value) {
        ensureVariableManager().setVariableValue("pCountryCode", value);
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


    /**
     *Method sets all required bind variables for ByPrimaryKeyViewCriteria
     * @param companyIdNo
     * @param countryCode
     */
    public void setByPkViewCritiera(Integer companyIdNo, String countryCode) {
        this.setpCompanyIdNo(companyIdNo);
        this.setpCountryCode(countryCode);
        this.executeQuery();
    }

    public void updateEffDates(Integer compIdNo, String countryCode, Date currentDate) {
        String viewCriteriaName = "CompanyBankDetailsByPKViewCritiera";
        CompanyBankDetailsVOImpl vo = (CompanyBankDetailsVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("pCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", "");

        vo.setSortBy("CompanyIdNo, CountryCode, EffectiveStartDate desc");
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();

        Date startDate = DateUtils.getLibertyMinDate();
        Integer companyIdNo = 0;

        while (rowIt.hasNext()) {

            CompanyBankDetailsVORowImpl row = (CompanyBankDetailsVORowImpl) rowIt.next();
            Date endDate = row.getEffectiveEndDate();
            Date newEndDate = DateUtils.getLibertyMaxDate();
            if (companyIdNo.compareTo(row.getCompanyIdNo()) != 0) {
                row.setEffectiveEndDate(newEndDate);
            } else if (endDate != newEndDate) {
                row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
                System.out.println("Setting end date " + DateConversionUtil.subtractDays(startDate, 1));
            }
            companyIdNo = row.getCompanyIdNo();
            startDate = row.getEffectiveStartDate();

        }
        rowIt.closeRowSetIterator();
        this.getDBTransaction().commit();
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("pCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", currentDate);
        vo.executeQuery();

    }

}

