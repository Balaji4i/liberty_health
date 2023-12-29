package com.liberty.health.comms.model.brokerage.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.broker.vo.BrokerAccreditationVOImpl;

import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Sat Nov 05 21:49:31 IST 2022
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyAccreditationVOImpl extends CoreViewObjectImpl implements com.liberty.health.comms.model.brokerage.vo.common.CompanyAccreditationVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyAccreditationVOImpl() {
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


    public String checkCompanyAccredExists(Integer accreditationIdNo) {
        System.out.println("in the vo broker accreditation checking if accred exists "+accreditationIdNo);
        String viewCriteriaName = "CompanyAccreditationVOCheckExists";
        CompanyAccreditationVOImpl vo = (CompanyAccreditationVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pAccredTypeIdNo", accreditationIdNo);
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();


        while (rowIt.hasNext()) {
            System.out.println("it has a row so pass message back "); 
           
           return "Cannot delete as a Brokerage has this accreditation!";
           
        }
        System.out.println("no row has been found so return null "); 
        
        rowIt.closeRowSetIterator();
        return null;
        
    }
    
    
    public void updateEffDates(Integer compIdNo, String countryCode, Date currentDate) {
        String viewCriteriaName = "CurrentCompanyAccreditationViewCriteria";
        CompanyAccreditationVOImpl vo = (CompanyAccreditationVOImpl) this.getViewObject();
        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("pCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", "");

        vo.setSortBy("CompanyIdNo, CountryCode, AccreditationTypeIdNo, EffectiveStartDate desc");
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();

        Date startDate = DateUtils.getLibertyMinDate();
        Integer companyIdNo = 0;
        String cntryCode = "";
        Integer accredtypeIdNo = 0;

        while (rowIt.hasNext()) {

            CompanyAccreditationVORowImpl row = (CompanyAccreditationVORowImpl) rowIt.next();
            Date endDate = row.getEffectiveEndDate();
            System.out.println("endDate: "+endDate);
            Date newEndDate = DateUtils.getLibertyMaxDate();
            System.out.println("newEndDate: "+newEndDate);

            if (companyIdNo.compareTo(row.getCompanyIdNo()) != 0 || cntryCode.compareTo(row.getCountryCode()) != 0 ||
                accredtypeIdNo.compareTo(row.getAccreditationTypeIdNo()) != 0) {
                row.setEffectiveEndDate(newEndDate);
                System.out.println("newEndDate: "+newEndDate);
            } else if (endDate != newEndDate) {
                row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
                //String EffectiveEndDate1 = row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
                //System.out.println("EffectiveEndDate1: "+EffectiveEndDate1);
            }
            companyIdNo = row.getCompanyIdNo();
            cntryCode = row.getCountryCode();
            accredtypeIdNo = row.getAccreditationTypeIdNo();
            startDate = row.getEffectiveStartDate();
            System.out.println("startDate: "+startDate);

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

    /**
     *Method sets bind variables required for by primary key view criteria
     * @param companyIdNo
     * @param countryCode
     */
    public void setByPkViewCriteria(Number companyIdNo, String countryCode) {
        this.setpCompanyIdNo(companyIdNo);
        this.setpCountryCode(countryCode);
        this.executeQuery();
    }
    

    /**     
     * * Returns the variable value for pAccredTypeIdNo.
     * @return variable value for pAccredTypeIdNo
     */
    public Integer getpAccredTypeIdNo() {
        return (Integer) ensureVariableManager().getVariableValue("pAccredTypeIdNo");
    }

    /**
     * Sets <code>value</code> for variable pAccredTypeIdNo.
     * @param value value to bind as pAccredTypeIdNo
     */
    public void setpAccredTypeIdNo(Integer value) {
        ensureVariableManager().setVariableValue("pAccredTypeIdNo", value);
    }


}
