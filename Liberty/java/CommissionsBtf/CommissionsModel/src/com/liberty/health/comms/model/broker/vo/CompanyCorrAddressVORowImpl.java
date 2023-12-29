package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import com.liberty.health.comms.model.eo.CompanyAddressEOImpl;

import java.sql.Timestamp;

import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Aug 13 11:10:10 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyCorrAddressVORowImpl extends CoreViewRowImpl {


    public static final int ENTITY_COMPANYADDRESSEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        AddressCountryCode,
        AddressLine1,
        AddressLine2,
        AddressLine3,
        AddressTypeCode,
        CompanyIdNo,
        CountryCode,
        EffectiveEndDate,
        EffectiveStartDate,
        LastUpdateDatetime,
        PostalCode,
        Username,
        AllOhiCountryLovView1,
        CompanyCountryVO1,
        CountryLovView_N1;
        private static AttributesEnum[] vals = null;
        ;
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


    public static final int ADDRESSCOUNTRYCODE = AttributesEnum.AddressCountryCode.index();
    public static final int ADDRESSLINE1 = AttributesEnum.AddressLine1.index();
    public static final int ADDRESSLINE2 = AttributesEnum.AddressLine2.index();
    public static final int ADDRESSLINE3 = AttributesEnum.AddressLine3.index();
    public static final int ADDRESSTYPECODE = AttributesEnum.AddressTypeCode.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int POSTALCODE = AttributesEnum.PostalCode.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int ALLOHICOUNTRYLOVVIEW1 = AttributesEnum.AllOhiCountryLovView1.index();
    public static final int COMPANYCOUNTRYVO1 = AttributesEnum.CompanyCountryVO1.index();
    public static final int COUNTRYLOVVIEW_N1 = AttributesEnum.CountryLovView_N1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyCorrAddressVORowImpl() {
    }

    /**
     * Gets CompanyAddressEO entity object.
     * @return the CompanyAddressEO
     */
    public CompanyAddressEOImpl getCompanyAddressEO() {
        return (CompanyAddressEOImpl) getEntity(ENTITY_COMPANYADDRESSEO);
    }
    
   /* @Override
       public boolean isAttributeUpdateable(int index) {
           boolean isUpdateable = super.isAttributeUpdateable(index);
           
           // do not allow updating first and last name
           if (index == ADDRESSLINE1  || index == ADDRESSLINE2 
                                     || index == ADDRESSLINE3
                                     || index == POSTALCODE) {
               isUpdateable = true;
           }
           
           return isUpdateable;
       }*/

    /**
     * Gets the attribute value for ADDRESS_COUNTRY_CODE using the alias name AddressCountryCode.
     * @return the ADDRESS_COUNTRY_CODE
     */
    public String getAddressCountryCode() {
        return (String) getAttributeInternal(ADDRESSCOUNTRYCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for ADDRESS_COUNTRY_CODE using the alias name AddressCountryCode.
     * @param value value to set the ADDRESS_COUNTRY_CODE
     */
    public void setAddressCountryCode(String value) {
        setAttributeInternal(ADDRESSCOUNTRYCODE, value);
    }

    /**
     * Gets the attribute value for ADDRESS_LINE1 using the alias name AddressLine1.
     * @return the ADDRESS_LINE1
     */
    public String getAddressLine1() {
        return (String) getAttributeInternal(ADDRESSLINE1);
    }

    /**
     * Sets <code>value</code> as attribute value for ADDRESS_LINE1 using the alias name AddressLine1.
     * @param value value to set the ADDRESS_LINE1
     */
    public void setAddressLine1(String value) {
        setAttributeInternal(ADDRESSLINE1, value);
    }

    /**
     * Gets the attribute value for ADDRESS_LINE2 using the alias name AddressLine2.
     * @return the ADDRESS_LINE2
     */
    public String getAddressLine2() {
        return (String) getAttributeInternal(ADDRESSLINE2);
    }

    /**
     * Sets <code>value</code> as attribute value for ADDRESS_LINE2 using the alias name AddressLine2.
     * @param value value to set the ADDRESS_LINE2
     */
    public void setAddressLine2(String value) {
        setAttributeInternal(ADDRESSLINE2, value);
    }

    /**
     * Gets the attribute value for ADDRESS_LINE3 using the alias name AddressLine3.
     * @return the ADDRESS_LINE3
     */
    public String getAddressLine3() {
        return (String) getAttributeInternal(ADDRESSLINE3);
    }

    /**
     * Sets <code>value</code> as attribute value for ADDRESS_LINE3 using the alias name AddressLine3.
     * @param value value to set the ADDRESS_LINE3
     */
    public void setAddressLine3(String value) {
        setAttributeInternal(ADDRESSLINE3, value);
    }

    /**
     * Gets the attribute value for ADDRESS_TYPE_CODE using the alias name AddressTypeCode.
     * @return the ADDRESS_TYPE_CODE
     */
    public String getAddressTypeCode() {
        return (String) getAttributeInternal(ADDRESSTYPECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for ADDRESS_TYPE_CODE using the alias name AddressTypeCode.
     * @param value value to set the ADDRESS_TYPE_CODE
     */
    public void setAddressTypeCode(String value) {
        setAttributeInternal(ADDRESSTYPECODE, value);
    }

    /**
     * Gets the attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @return the COMPANY_ID_NO
     */
    public Integer getCompanyIdNo() {
        return (Integer) getAttributeInternal(COMPANYIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @param value value to set the COMPANY_ID_NO
     */
    public void setCompanyIdNo(Integer value) {
        setAttributeInternal(COMPANYIDNO, value);
    }

    /**
     * Gets the attribute value for COUNTRY_CODE using the alias name CountryCode.
     * @return the COUNTRY_CODE
     */
    public String getCountryCode() {
        return (String) getAttributeInternal(COUNTRYCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for COUNTRY_CODE using the alias name CountryCode.
     * @param value value to set the COUNTRY_CODE
     */
    public void setCountryCode(String value) {
        setAttributeInternal(COUNTRYCODE, value);
    }

    /**
     * Gets the attribute value for EFFECTIVE_END_DATE using the alias name EffectiveEndDate.
     * @return the EFFECTIVE_END_DATE
     */
    public Date getEffectiveEndDate() {
        return (Date) getAttributeInternal(EFFECTIVEENDDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for EFFECTIVE_END_DATE using the alias name EffectiveEndDate.
     * @param value value to set the EFFECTIVE_END_DATE
     */
    public void setEffectiveEndDate(Date value) {
        setAttributeInternal(EFFECTIVEENDDATE, value);
    }

    /**
     * Gets the attribute value for EFFECTIVE_START_DATE using the alias name EffectiveStartDate.
     * @return the EFFECTIVE_START_DATE
     */
    public Date getEffectiveStartDate() {
        return (Date) getAttributeInternal(EFFECTIVESTARTDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for EFFECTIVE_START_DATE using the alias name EffectiveStartDate.
     * @param value value to set the EFFECTIVE_START_DATE
     */
    public void setEffectiveStartDate(Date value) {
        setAttributeInternal(EFFECTIVESTARTDATE, value);
    }

    /**
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Timestamp getLastUpdateDatetime() {
        return (Timestamp) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for POSTAL_CODE using the alias name PostalCode.
     * @return the POSTAL_CODE
     */
    public String getPostalCode() {
        return (String) getAttributeInternal(POSTALCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for POSTAL_CODE using the alias name PostalCode.
     * @param value value to set the POSTAL_CODE
     */
    public void setPostalCode(String value) {
        setAttributeInternal(POSTALCODE, value);
    }

    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the view accessor <code>RowSet</code> AllOhiCountryLovView1.
     */
    public RowSet getAllOhiCountryLovView1() {
        return (RowSet) getAttributeInternal(ALLOHICOUNTRYLOVVIEW1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CompanyCountryVO1.
     */
    public RowSet getCompanyCountryVO1() {
        return (RowSet) getAttributeInternal(COMPANYCOUNTRYVO1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CountryLovView_N1.
     */
    public RowSet getCountryLovView_N1() {
        return (RowSet) getAttributeInternal(COUNTRYLOVVIEW_N1);
    }
}

