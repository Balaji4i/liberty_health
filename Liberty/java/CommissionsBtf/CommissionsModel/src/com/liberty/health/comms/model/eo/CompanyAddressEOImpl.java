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
// ---    Tue Aug 14 09:27:38 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyAddressEOImpl extends EntityImpl {
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
        AddressType,
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
    public static final int ADDRESSTYPE = AttributesEnum.AddressType.index();
    public static final int COMPANYCOUNTRY = AttributesEnum.CompanyCountry.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyAddressEOImpl() {
    }

    /**
     * Gets the attribute value for CompanyIdNo, using the alias name CompanyIdNo.
     * @return the value of CompanyIdNo
     */
    public Integer getCompanyIdNo() {
        return (Integer) getAttributeInternal(COMPANYIDNO);
    }

    public boolean isAttributeUpdateable(int i) {
            //Date currentDate = DateUtils.currentDateTruncated();
            /*
             * Changes made by T.Percy allow for updating of address information
             * for start date greater than or equal to the current date
             */
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
            /* T.Perc commented out original code which only opens up the record for effective date equal to today's date 
            if (this.getEffectiveStartDate().equals(currentDate) || i == AttributesEnum.EffectiveEndDate.index()) {
                return true;
            } else {
                return false;
            }*/
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
     * Gets the attribute value for AddressTypeCode, using the alias name AddressTypeCode.
     * @return the value of AddressTypeCode
     */
    public String getAddressTypeCode() {
        return (String) getAttributeInternal(ADDRESSTYPECODE);
    }

    /**
     * Sets <code>value</code> as the attribute value for AddressTypeCode.
     * @param value value to set the AddressTypeCode
     */
    public void setAddressTypeCode(String value) {
        setAttributeInternal(ADDRESSTYPECODE, value);
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
     * Gets the attribute value for AddressLine1, using the alias name AddressLine1.
     * @return the value of AddressLine1
     */
    public String getAddressLine1() {
        return (String) getAttributeInternal(ADDRESSLINE1);
    }

    /**
     * Sets <code>value</code> as the attribute value for AddressLine1.
     * @param value value to set the AddressLine1
     */
    public void setAddressLine1(String value) {
        setAttributeInternal(ADDRESSLINE1, value);
    }

    /**
     * Gets the attribute value for AddressLine2, using the alias name AddressLine2.
     * @return the value of AddressLine2
     */
    public String getAddressLine2() {
        return (String) getAttributeInternal(ADDRESSLINE2);
    }

    /**
     * Sets <code>value</code> as the attribute value for AddressLine2.
     * @param value value to set the AddressLine2
     */
    public void setAddressLine2(String value) {
        setAttributeInternal(ADDRESSLINE2, value);
    }

    /**
     * Gets the attribute value for AddressLine3, using the alias name AddressLine3.
     * @return the value of AddressLine3
     */
    public String getAddressLine3() {
        return (String) getAttributeInternal(ADDRESSLINE3);
    }

    /**
     * Sets <code>value</code> as the attribute value for AddressLine3.
     * @param value value to set the AddressLine3
     */
    public void setAddressLine3(String value) {
        setAttributeInternal(ADDRESSLINE3, value);
    }

    /**
     * Gets the attribute value for PostalCode, using the alias name PostalCode.
     * @return the value of PostalCode
     */
    public String getPostalCode() {
        return (String) getAttributeInternal(POSTALCODE);
    }

    /**
     * Sets <code>value</code> as the attribute value for PostalCode.
     * @param value value to set the PostalCode
     */
    public void setPostalCode(String value) {
        setAttributeInternal(POSTALCODE, value);
    }

    /**
     * Gets the attribute value for AddressCountryCode, using the alias name AddressCountryCode.
     * @return the value of AddressCountryCode
     */
    public String getAddressCountryCode() {
        return (String) getAttributeInternal(ADDRESSCOUNTRYCODE);
    }

    /**
     * Sets <code>value</code> as the attribute value for AddressCountryCode.
     * @param value value to set the AddressCountryCode
     */
    public void setAddressCountryCode(String value) {
        setAttributeInternal(ADDRESSCOUNTRYCODE, value);
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
    public EntityImpl getAddressType() {
        return (EntityImpl) getAttributeInternal(ADDRESSTYPE);
    }

    /**
     * Sets <code>value</code> as the associated entity oracle.jbo.server.EntityImpl.
     */
    public void setAddressType(EntityImpl value) {
        setAttributeInternal(ADDRESSTYPE, value);
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
     * @param addressTypeCode key constituent
     * @param effectiveStartDate key constituent

     * @return a Key object based on given key constituents.
     */
    public static Key createPrimaryKey(Integer companyIdNo, String countryCode, String addressTypeCode,
                                       Date effectiveStartDate) {
        return new Key(new Object[] { companyIdNo, countryCode, addressTypeCode, effectiveStartDate });
    }

    /**
     * @return the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        return EntityDefImpl.findDefObject("com.liberty.health.comms.model.eo.CompanyAddressEO");
    }
}

