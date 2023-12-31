package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import com.liberty.health.comms.model.eo.CompanyAddressEOImpl;

import java.sql.Timestamp;

import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 01 09:40:03 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyAddressVORowImpl extends CoreViewRowImpl {


    public static final int ENTITY_COMPANYADDRESSEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        CountryCode,
        AddressTypeCode,
        EffectiveStartDate,
        EffectiveEndDate,
        AddressLine1,
        AddressLine2,
        AddressLine3,
        PostalCode,
        AddressCountryCode,
        LastUpdateDatetime,
        Username,
        CompanyAddressAuditRoView,
        AddressTypeLovView1;
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


    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int ADDRESSTYPECODE = AttributesEnum.AddressTypeCode.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int ADDRESSLINE1 = AttributesEnum.AddressLine1.index();
    public static final int ADDRESSLINE2 = AttributesEnum.AddressLine2.index();
    public static final int ADDRESSLINE3 = AttributesEnum.AddressLine3.index();
    public static final int POSTALCODE = AttributesEnum.PostalCode.index();
    public static final int ADDRESSCOUNTRYCODE = AttributesEnum.AddressCountryCode.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int COMPANYADDRESSAUDITROVIEW = AttributesEnum.CompanyAddressAuditRoView.index();
    public static final int ADDRESSTYPELOVVIEW1 = AttributesEnum.AddressTypeLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyAddressVORowImpl() {
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
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Timestamp getLastUpdateDatetime() {
        return (Timestamp) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the associated <code>RowIterator</code> using master-detail link CompanyAddressAuditRoView.
     */
    public RowIterator getCompanyAddressAuditRoView() {
        return (RowIterator) getAttributeInternal(COMPANYADDRESSAUDITROVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> AddressTypeLovView1.
     */
    public RowSet getAddressTypeLovView1() {
        return (RowSet) getAttributeInternal(ADDRESSTYPELOVVIEW1);
    }
}

