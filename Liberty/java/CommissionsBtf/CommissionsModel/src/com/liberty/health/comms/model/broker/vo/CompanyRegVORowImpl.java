package com.liberty.health.comms.model.broker.vo;

import com.core.model.eo.classes.CoreEntityImpl;
import com.core.model.vo.classes.CoreViewRowImpl;

import com.liberty.health.comms.model.eo.CompanyRegEOImpl;

import java.sql.Timestamp;

import oracle.jbo.RowIterator;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed May 17 17:05:58 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyRegVORowImpl extends CoreViewRowImpl {


    public static final int ENTITY_COMPANYREGEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        CountryCode,
        EffectiveStartDate,
        EffectiveEndDate,
        ExpiryDate,
        ApplicationDate,
        AuthoriseDate,
        LastUpdateDatetime,
        Username,
        RegNo,
        VatNo,
        TaxIdentificationNo,
        CompanyRegAuditRoView;
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
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int EXPIRYDATE = AttributesEnum.ExpiryDate.index();
    public static final int APPLICATIONDATE = AttributesEnum.ApplicationDate.index();
    public static final int AUTHORISEDATE = AttributesEnum.AuthoriseDate.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int REGNO = AttributesEnum.RegNo.index();
    public static final int VATNO = AttributesEnum.VatNo.index();
    public static final int TAXIDENTIFICATIONNO = AttributesEnum.TaxIdentificationNo.index();
    public static final int COMPANYREGAUDITROVIEW = AttributesEnum.CompanyRegAuditRoView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyRegVORowImpl() {
    }

    /**
     * Gets CompanyRegEO entity object.
     * @return the CompanyRegEO
     */
    public CompanyRegEOImpl getCompanyRegEO() {
        return (CompanyRegEOImpl) getEntity(ENTITY_COMPANYREGEO);
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
     * Gets the attribute value for VAT_NO using the alias name VatNo.
     * @return the VAT_NO
     */
    public String getVatNo() {
        return (String) getAttributeInternal(VATNO);
    }

    /**
     * Sets <code>value</code> as attribute value for VAT_NO using the alias name VatNo.
     * @param value value to set the VAT_NO
     */
    public void setVatNo(String value) {
        setAttributeInternal(VATNO, value);
    }

    /**
     * Gets the attribute value for TAX_IDENTIFICATION_NO using the alias name TaxIdentificationNo.
     * @return the TAX_IDENTIFICATION_NO
     */
    public String getTaxIdentificationNo() {
        return (String) getAttributeInternal(TAXIDENTIFICATIONNO);
    }

    /**
     * Sets <code>value</code> as attribute value for TAX_IDENTIFICATION_NO using the alias name TaxIdentificationNo.
     * @param value value to set the TAX_IDENTIFICATION_NO
     */
    public void setTaxIdentificationNo(String value) {
        setAttributeInternal(TAXIDENTIFICATIONNO, value);
    }

    /**
     * Gets the attribute value for REG_NO using the alias name RegNo.
     * @return the REG_NO
     */
    public String getRegNo() {
        return (String) getAttributeInternal(REGNO);
    }

    /**
     * Sets <code>value</code> as attribute value for REG_NO using the alias name RegNo.
     * @param value value to set the REG_NO
     */
    public void setRegNo(String value) {
        setAttributeInternal(REGNO, value);
    }


    /**
     * Gets the attribute value for EXPIRY_DATE using the alias name ExpiryDate.
     * @return the EXPIRY_DATE
     */
    public Date getExpiryDate() {
        return (Date) getAttributeInternal(EXPIRYDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for EXPIRY_DATE using the alias name ExpiryDate.
     * @param value value to set the EXPIRY_DATE
     */
    public void setExpiryDate(Date value) {
        setAttributeInternal(EXPIRYDATE, value);
    }

    /**
     * Gets the attribute value for APPLICATION_DATE using the alias name ApplicationDate.
     * @return the APPLICATION_DATE
     */
    public Date getApplicationDate() {
        return (Date) getAttributeInternal(APPLICATIONDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for APPLICATION_DATE using the alias name ApplicationDate.
     * @param value value to set the APPLICATION_DATE
     */
    public void setApplicationDate(Date value) {
        setAttributeInternal(APPLICATIONDATE, value);
    }

    /**
     * Gets the attribute value for AUTHORISE_DATE using the alias name AuthoriseDate.
     * @return the AUTHORISE_DATE
     */
    public Date getAuthoriseDate() {
        return (Date) getAttributeInternal(AUTHORISEDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for AUTHORISE_DATE using the alias name AuthoriseDate.
     * @param value value to set the AUTHORISE_DATE
     */
    public void setAuthoriseDate(Date value) {
        setAttributeInternal(AUTHORISEDATE, value);
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
     * Gets the associated <code>RowIterator</code> using master-detail link CompanyRegAuditRoView.
     */
    public RowIterator getCompanyRegAuditRoView() {
        return (RowIterator) getAttributeInternal(COMPANYREGAUDITROVIEW);
    }
}

