package com.liberty.health.comms.model.eo;

import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import java.sql.Timestamp;

import oracle.jbo.Key;
import oracle.jbo.domain.Date;
import oracle.jbo.server.EntityDefImpl;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Oct 19 10:14:47 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyContactEOImpl extends EntityImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        CountryCode,
        CompanyContactTypeIdNo,
        EffectiveStartDate,
        EffectiveEndDate,
        ContactName,
        ContactCellphoneNo,
        ContactEmail,
        ContactFaxNo,
        ContactTelephoneNo,
        ContactDesc,
        LastUpdateDatetime,
        Username,
        CompanyContactType,
        CompanyCountry;
        private static AttributesEnum[] vals = null;
        private static final int firstIndex = 0;

        protected int index() {
            return AttributesEnum.firstIndex() + ordinal();
        }

        protected static final int firstIndex() {
            return firstIndex;
        }

        protected static int count() {
            return AttributesEnum.firstIndex() + AttributesEnum.staticValues().length;
        }

        protected static final AttributesEnum[] staticValues() {
            if (vals == null) {
                vals = AttributesEnum.values();
            }
            return vals;
        }
    }


    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int COMPANYCONTACTTYPEIDNO = AttributesEnum.CompanyContactTypeIdNo.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int CONTACTNAME = AttributesEnum.ContactName.index();
    public static final int CONTACTCELLPHONENO = AttributesEnum.ContactCellphoneNo.index();
    public static final int CONTACTEMAIL = AttributesEnum.ContactEmail.index();
    public static final int CONTACTFAXNO = AttributesEnum.ContactFaxNo.index();
    public static final int CONTACTTELEPHONENO = AttributesEnum.ContactTelephoneNo.index();
    public static final int CONTACTDESC = AttributesEnum.ContactDesc.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int COMPANYCONTACTTYPE = AttributesEnum.CompanyContactType.index();
    public static final int COMPANYCOUNTRY = AttributesEnum.CompanyCountry.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyContactEOImpl() {
    }

    /**
     * @return the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        return EntityDefImpl.findDefObject("com.liberty.health.comms.model.eo.CompanyContactEO");
    }


    public boolean isAttributeUpdateable(int i) {
     /**
      * T.Percy changes to allow for updating of information if the start date is less than the current date
      * and the end date is after the current date
      */
     
     //   Date currentDate = DateUtils.currentDateTruncated();
        java.sql.Date startDateSql = DateConversionUtil.convertToJSDate(this.getEffectiveStartDate());
        java.sql.Date endDateSql = DateConversionUtil.convertToJSDate(this.getEffectiveEndDate());
        java.sql.Date currDateSql  = DateConversionUtil.convertToJSDate(DateUtils.currentDateTruncated()); 
        
        if (
            (startDateSql.before(currDateSql) || 
             startDateSql.equals(currDateSql)) &&
             endDateSql.after(currDateSql)
           ) {
              return true;
            } else {
              return false;
            }
        
        
     /*   if (this.getEffectiveStartDate().equals(currentDate) || i == AttributesEnum.EffectiveEndDate.index()) {
            return true;
        } else {
            return false;
        }*/
    }

    /**
     * Gets the attribute value for CompanyIdNo, using the alias name CompanyIdNo.
     * @return the value of CompanyIdNo
     */
    public Integer getCompanyIdNo() {
        return (Integer) getAttributeInternal(COMPANYIDNO);
    }

    /**
     * Sets <code>value</code> as the attribute value for CompanyIdNo.
     * @param value value to set the CompanyIdNo
     */
    public void setCompanyIdNo(Integer value) {
        setAttributeInternal(COMPANYIDNO, value);
    }

    /**
     * Gets the attribute value for CountryCode, using the alias name CountryCode.
     * @return the value of CountryCode
     */
    public String getCountryCode() {
        return (String) getAttributeInternal(COUNTRYCODE);
    }


    /**
     * Sets <code>value</code> as the attribute value for CountryCode.
     * @param value value to set the CountryCode
     */
    public void setCountryCode(String value) {
        setAttributeInternal(COUNTRYCODE, value);
    }

    /**
     * Gets the attribute value for CompanyContactTypeIdNo, using the alias name CompanyContactTypeIdNo.
     * @return the value of CompanyContactTypeIdNo
     */
    public Integer getCompanyContactTypeIdNo() {
        return (Integer) getAttributeInternal(COMPANYCONTACTTYPEIDNO);
    }

    /**
     * Sets <code>value</code> as the attribute value for CompanyContactTypeIdNo.
     * @param value value to set the CompanyContactTypeIdNo
     */
    public void setCompanyContactTypeIdNo(Integer value) {
        setAttributeInternal(COMPANYCONTACTTYPEIDNO, value);
    }

    /**
     * Gets the attribute value for EffectiveStartDate, using the alias name EffectiveStartDate.
     * @return the value of EffectiveStartDate
     */
    public Date getEffectiveStartDate() {
        return (Date) getAttributeInternal(EFFECTIVESTARTDATE);
    }

    /**
     * Sets <code>value</code> as the attribute value for EffectiveStartDate.
     * @param value value to set the EffectiveStartDate
     */
    public void setEffectiveStartDate(Date value) {
        setAttributeInternal(EFFECTIVESTARTDATE, value);
    }

    /**
     * Gets the attribute value for EffectiveEndDate, using the alias name EffectiveEndDate.
     * @return the value of EffectiveEndDate
     */
    public Date getEffectiveEndDate() {
        return (Date) getAttributeInternal(EFFECTIVEENDDATE);
    }

    /**
     * Sets <code>value</code> as the attribute value for EffectiveEndDate.
     * @param value value to set the EffectiveEndDate
     */
    public void setEffectiveEndDate(Date value) {
        setAttributeInternal(EFFECTIVEENDDATE, value);
    }

    /**
     * Gets the attribute value for ContactName, using the alias name ContactName.
     * @return the value of ContactName
     */
    public String getContactName() {
        return (String) getAttributeInternal(CONTACTNAME);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactName.
     * @param value value to set the ContactName
     */
    public void setContactName(String value) {
        setAttributeInternal(CONTACTNAME, value);
    }

    /**
     * Gets the attribute value for ContactCellphoneNo, using the alias name ContactCellphoneNo.
     * @return the value of ContactCellphoneNo
     */
    public String getContactCellphoneNo() {
        return (String) getAttributeInternal(CONTACTCELLPHONENO);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactCellphoneNo.
     * @param value value to set the ContactCellphoneNo
     */
    public void setContactCellphoneNo(String value) {
        setAttributeInternal(CONTACTCELLPHONENO, value);
    }

    /**
     * Gets the attribute value for ContactEmail, using the alias name ContactEmail.
     * @return the value of ContactEmail
     */
    public String getContactEmail() {
        return (String) getAttributeInternal(CONTACTEMAIL);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactEmail.
     * @param value value to set the ContactEmail
     */
    public void setContactEmail(String value) {
        setAttributeInternal(CONTACTEMAIL, value);
    }

    /**
     * Gets the attribute value for ContactFaxNo, using the alias name ContactFaxNo.
     * @return the value of ContactFaxNo
     */
    public String getContactFaxNo() {
        return (String) getAttributeInternal(CONTACTFAXNO);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactFaxNo.
     * @param value value to set the ContactFaxNo
     */
    public void setContactFaxNo(String value) {
        setAttributeInternal(CONTACTFAXNO, value);
    }

    /**
     * Gets the attribute value for ContactTelephoneNo, using the alias name ContactTelephoneNo.
     * @return the value of ContactTelephoneNo
     */
    public String getContactTelephoneNo() {
        return (String) getAttributeInternal(CONTACTTELEPHONENO);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactTelephoneNo.
     * @param value value to set the ContactTelephoneNo
     */
    public void setContactTelephoneNo(String value) {
        setAttributeInternal(CONTACTTELEPHONENO, value);
    }

    /**
     * Gets the attribute value for ContactDesc, using the alias name ContactDesc.
     * @return the value of ContactDesc
     */
    public String getContactDesc() {
        return (String) getAttributeInternal(CONTACTDESC);
    }

    /**
     * Sets <code>value</code> as the attribute value for ContactDesc.
     * @param value value to set the ContactDesc
     */
    public void setContactDesc(String value) {
        setAttributeInternal(CONTACTDESC, value);
    }

    /**
     * Gets the attribute value for LastUpdateDatetime, using the alias name LastUpdateDatetime.
     * @return the value of LastUpdateDatetime
     */
    public Timestamp getLastUpdateDatetime() {
        return (Timestamp) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for Username, using the alias name Username.
     * @return the value of Username
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * @return the associated entity oracle.jbo.server.EntityImpl.
     */
    public EntityImpl getCompanyContactType() {
        return (EntityImpl) getAttributeInternal(COMPANYCONTACTTYPE);
    }

    /**
     * Sets <code>value</code> as the associated entity oracle.jbo.server.EntityImpl.
     */
    public void setCompanyContactType(EntityImpl value) {
        setAttributeInternal(COMPANYCONTACTTYPE, value);
    }

    /**
     * @return the associated entity CompanyCountryEOImpl.
     */
    public CompanyCountryEOImpl getCompanyCountry() {
        return (CompanyCountryEOImpl) getAttributeInternal(COMPANYCOUNTRY);
    }

    /**
     * Sets <code>value</code> as the associated entity CompanyCountryEOImpl.
     */
    public void setCompanyCountry(CompanyCountryEOImpl value) {
        setAttributeInternal(COMPANYCOUNTRY, value);
    }

    /**
     * @param companyIdNo key constituent
     * @param countryCode key constituent
     * @param companyContactTypeIdNo key constituent
     * @param effectiveStartDate key constituent

     * @return a Key object based on given key constituents.
     */
    public static Key createPrimaryKey(Integer companyIdNo, String countryCode, Integer companyContactTypeIdNo,
                                       Date effectiveStartDate) {
        return new Key(new Object[] { companyIdNo, countryCode, companyContactTypeIdNo, effectiveStartDate });
    }


}

