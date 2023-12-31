package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.broker.vo.common.CompanyContactVO;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue May 23 14:57:23 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyContactVOImpl extends CoreViewObjectImpl implements CompanyContactVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CompanyContactVOImpl() {
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

    public void setByPrimaryKeyViewCriteria(Integer companyIdNo) {
        this.setpCompanyIdNo(companyIdNo);

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
     * Returns the variable value for pCompanyContactIdNo.
     * @return variable value for pCompanyContactIdNo
     */
    public Integer getpCompanyContactIdNo() {
        return (Integer) ensureVariableManager().getVariableValue("pCompanyContactIdNo");
    }

    /**
     * Sets <code>value</code> for variable pCompanyContactIdNo.
     * @param value value to bind as pCompanyContactIdNo
     */
    public void setpCompanyContactIdNo(Integer value) {
        ensureVariableManager().setVariableValue("pCompanyContactIdNo", value);
    }


    public void setByPrimaryKeyViewCriteria(Integer companyIdNo, String countryCode) {
        this.setpCompanyIdNo(companyIdNo);
        this.setPCountryCode(countryCode);
        this.setpCompanyContactIdNo(3);
        this.executeQuery();
    }

    /**
     * Returns the variable value for PCountryCode.
     * @return variable value for PCountryCode
     */
    public String getPCountryCode() {
        return (String) ensureVariableManager().getVariableValue("PCountryCode");
    }

    /**
     * Sets <code>value</code> for variable PCountryCode.
     * @param value value to bind as PCountryCode
     */
    public void setPCountryCode(String value) {
        ensureVariableManager().setVariableValue("PCountryCode", value);
    }


    public void updateEffDates(Integer compIdNo, String countryCode, Date currentDate) {
        
        
        String viewCriteriaName = "CompanyContactByPrimaryKeyViewCriteria";
        CompanyContactVOImpl vo = (CompanyContactVOImpl) this.getViewObject();

        Row contactRow              = vo.getCurrentRow();
        
        Date effectiveStartDate       = (Date) contactRow.getAttribute("EffectiveStartDate");
        Date effectiveEndDate         = (Date) contactRow.getAttribute("EffectiveEndDate");
        Integer currContactTypeIdNo    = (Integer) contactRow.getAttribute("CompanyContactTypeIdNo");
        
        
        java.sql.Date currDateSql  = DateConversionUtil.convertToJSDate(DateUtils.currentDateTruncated());
        java.sql.Date checkEndDate = DateConversionUtil.convertToJSDate(effectiveEndDate);
        java.sql.Date checkStartDate = DateConversionUtil.convertToJSDate(effectiveStartDate); 
        
        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("PCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", "");

        vo.setSortBy("CompanyIdNo, CountryCode, CompanyContactTypeIdNo, EffectiveStartDate desc");
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();

     //   Date startDate = DateUtils.getLibertyMinDate();
        Integer companyIdNo = 0;
        String cntryCode = "";
        Integer contactTypeIdNo = 0;

        while (rowIt.hasNext()) {

          CompanyContactVORowImpl row = (CompanyContactVORowImpl) rowIt.next();
          //  Date endDate = row.getEffectiveEndDate();
          java.sql.Date endDate = DateConversionUtil.convertToJSDate(row.getEffectiveEndDate());
          
            Date newEndDate = DateUtils.getLibertyMaxDate();
            Date startDate = row.getEffectiveStartDate();
            /**
             * T.Percy commented out old code as does not allow for updating of existing records
             */
            System.out.println("in the contact vo impl updating the effective start dates ");
            System.out.println(companyIdNo.compareTo(row.getCompanyIdNo()));
            System.out.println(cntryCode.compareTo(row.getCountryCode()));
            System.out.println(currContactTypeIdNo.compareTo(row.getCompanyContactTypeIdNo()));
            
            System.out.println("start date "+startDate+" and check start date"+checkStartDate);
            System.out.println("current date "+currDateSql+" end date "+endDate);
            System.out.println("curr row contact type id  "+currContactTypeIdNo);
            System.out.println("row iterator contact type id "+row.getCompanyContactTypeIdNo());
            
            if (companyIdNo.equals(row.getCompanyIdNo()) && 
                cntryCode.equals(row.getCountryCode()) &&
                currContactTypeIdNo.equals(row.getCompanyContactTypeIdNo())
               ) {
                
                if (startDate.equals(checkStartDate)) {
                    row.setEffectiveEndDate(newEndDate);
                } else if  (currDateSql.before(endDate)) {
                    System.out.println("new end date is "+DateConversionUtil.subtractDays(effectiveStartDate, 1));
                    row.setEffectiveEndDate(DateConversionUtil.subtractDays(effectiveStartDate, 1));
                         
                }
                
            }
            
            
           /* if (companyIdNo.compareTo(row.getCompanyIdNo()) != 0 || cntryCode.compareTo(row.getCountryCode()) != 0 ||
                contactTypeIdNo.compareTo(row.getCompanyContactTypeIdNo()) != 0) {
                row.setEffectiveEndDate(newEndDate);
            } else if (endDate != newEndDate) {
                row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
                System.out.println("Setting end date " + DateConversionUtil.subtractDays(startDate, 1));
            }*/
            
            companyIdNo = row.getCompanyIdNo();
            startDate = row.getEffectiveStartDate();
            cntryCode = row.getCountryCode();
            contactTypeIdNo = row.getCompanyContactTypeIdNo();
        }
        rowIt.closeRowSetIterator();
        this.getDBTransaction().commit();
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pCompanyIdNo", compIdNo);
        vo.setNamedWhereClauseParam("PCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", currentDate);
        vo.executeQuery();
    }
}
