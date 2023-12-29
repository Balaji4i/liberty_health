package com.liberty.health.comms.model.lookup.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import com.liberty.health.comms.model.eo.CountryTaxesEOImpl;

import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Sep 21 09:55:50 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CountryTaxesVORowImpl extends CoreViewRowImpl {

    public static final int ENTITY_COUNTRYTAXESEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CountryCode,
        AccreditationTypeIdNo,
        EffectiveStartDate,
        EffectiveEndDate,
        AccredLocal,
        AccredMulti,
        NoAccrLocal,
        NoAccrMulti,
        LastUpdateDatetime,
        Username,
        CountryLovView1,
        CountryTaxAccredLov1,
        CountryTaxesAccrLov1,
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

    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int ACCREDITATIONTYPEIDNO = AttributesEnum.AccreditationTypeIdNo.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int ACCREDLOCAL = AttributesEnum.AccredLocal.index();
    public static final int ACCREDMULTI = AttributesEnum.AccredMulti.index();
    public static final int NOACCRLOCAL = AttributesEnum.NoAccrLocal.index();
    public static final int NOACCRMULTI = AttributesEnum.NoAccrMulti.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int COUNTRYLOVVIEW1 = AttributesEnum.CountryLovView1.index();
    public static final int COUNTRYTAXACCREDLOV1 = AttributesEnum.CountryTaxAccredLov1.index();
    public static final int COUNTRYTAXESACCRLOV1 = AttributesEnum.CountryTaxesAccrLov1.index();
    public static final int COUNTRYLOVVIEW_N1 = AttributesEnum.CountryLovView_N1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CountryTaxesVORowImpl() {
    }

    /**
     * Gets CountryTaxesEO entity object.
     * @return the CountryTaxesEO
     */
    public CountryTaxesEOImpl getCountryTaxesEO() {
        return (CountryTaxesEOImpl) getEntity(ENTITY_COUNTRYTAXESEO);
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
     * Gets the attribute value for ACCREDITATION_TYPE_ID_NO using the alias name AccreditationTypeIdNo.
     * @return the ACCREDITATION_TYPE_ID_NO
     */
    public Number getAccreditationTypeIdNo() {
        return (Number) getAttributeInternal(ACCREDITATIONTYPEIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for ACCREDITATION_TYPE_ID_NO using the alias name AccreditationTypeIdNo.
     * @param value value to set the ACCREDITATION_TYPE_ID_NO
     */
    public void setAccreditationTypeIdNo(Number value) {
        setAttributeInternal(ACCREDITATIONTYPEIDNO, value);
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
     * Gets the attribute value for ACCRED_LOCAL using the alias name AccredLocal.
     * @return the ACCRED_LOCAL
     */
    public String getAccredLocal() {
        return (String) getAttributeInternal(ACCREDLOCAL);
    }

    /**
     * Sets <code>value</code> as attribute value for ACCRED_LOCAL using the alias name AccredLocal.
     * @param value value to set the ACCRED_LOCAL
     */
    public void setAccredLocal(String value) {
        setAttributeInternal(ACCREDLOCAL, value);
    }

    /**
     * Gets the attribute value for ACCRED_MULTI using the alias name AccredMulti.
     * @return the ACCRED_MULTI
     */
    public String getAccredMulti() {
        return (String) getAttributeInternal(ACCREDMULTI);
    }

    /**
     * Sets <code>value</code> as attribute value for ACCRED_MULTI using the alias name AccredMulti.
     * @param value value to set the ACCRED_MULTI
     */
    public void setAccredMulti(String value) {
        setAttributeInternal(ACCREDMULTI, value);
    }

    /**
     * Gets the attribute value for NO_ACCR_LOCAL using the alias name NoAccrLocal.
     * @return the NO_ACCR_LOCAL
     */
    public String getNoAccrLocal() {
        return (String) getAttributeInternal(NOACCRLOCAL);
    }

    /**
     * Sets <code>value</code> as attribute value for NO_ACCR_LOCAL using the alias name NoAccrLocal.
     * @param value value to set the NO_ACCR_LOCAL
     */
    public void setNoAccrLocal(String value) {
        setAttributeInternal(NOACCRLOCAL, value);
    }

    /**
     * Gets the attribute value for NO_ACCR_MULTI using the alias name NoAccrMulti.
     * @return the NO_ACCR_MULTI
     */
    public String getNoAccrMulti() {
        return (String) getAttributeInternal(NOACCRMULTI);
    }

    /**
     * Sets <code>value</code> as attribute value for NO_ACCR_MULTI using the alias name NoAccrMulti.
     * @param value value to set the NO_ACCR_MULTI
     */
    public void setNoAccrMulti(String value) {
        setAttributeInternal(NOACCRMULTI, value);
    }

    /**
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Date getLastUpdateDatetime() {
        return (Date) getAttributeInternal(LASTUPDATEDATETIME);
    }


    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }


    /**
     * Gets the view accessor <code>RowSet</code> CountryLovView1.
     */
    public RowSet getCountryLovView1() {
        return (RowSet) getAttributeInternal(COUNTRYLOVVIEW1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CountryTaxAccredLov1.
     */
    public RowSet getCountryTaxAccredLov1() {
        return (RowSet) getAttributeInternal(COUNTRYTAXACCREDLOV1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CountryTaxesAccrLov1.
     */
    public RowSet getCountryTaxesAccrLov1() {
        return (RowSet) getAttributeInternal(COUNTRYTAXESACCRLOV1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CountryLovView_N1.
     */
    public RowSet getCountryLovView_N1() {
        return (RowSet) getAttributeInternal(COUNTRYLOVVIEW_N1);
    }
}

