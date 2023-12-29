package com.liberty.health.comms.model.eo;

import com.core.utils.DateUtils;

import oracle.jbo.Key;
import oracle.jbo.domain.Date;
import oracle.jbo.server.EntityDefImpl;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Aug 04 11:54:45 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyFeeEOImpl extends EntityImpl {
    /**
     * Validation method for EffectiveStartDate.
     */
    public boolean validateEffectiveStartDate(Date effectivestartdate) {
        Date brokerStartDate = this.getCompany().getEffectiveStartDate();
        java.sql.Date brokerDate = brokerStartDate.dateValue();
        java.sql.Date accredDate = effectivestartdate.dateValue();

        if (brokerDate.after(accredDate)) {
            return false;
        }
        return true;
    }

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        CompanyFeeTypeIdNo,
        EffectiveStartDate,
        EffectiveEndDate,
        FeeAmt,
        FeePerc,
        FeeFreqNo,
        FeeCommentDesc,
        LastUpdateDatetime,
        Username,
        LastRunDate,
        CompanyFeeType,
        Company;
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
    public static final int COMPANYFEETYPEIDNO = AttributesEnum.CompanyFeeTypeIdNo.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int FEEAMT = AttributesEnum.FeeAmt.index();
    public static final int FEEPERC = AttributesEnum.FeePerc.index();
    public static final int FEEFREQNO = AttributesEnum.FeeFreqNo.index();
    public static final int FEECOMMENTDESC = AttributesEnum.FeeCommentDesc.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int LASTRUNDATE = AttributesEnum.LastRunDate.index();
    public static final int COMPANYFEETYPE = AttributesEnum.CompanyFeeType.index();
    public static final int COMPANY = AttributesEnum.Company.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyFeeEOImpl() {
    }

    /**
     * @return the definition object for this instance class.
     */
    public static synchronized EntityDefImpl getDefinitionObject() {
        return EntityDefImpl.findDefObject("com.liberty.health.comms.model.eo.CompanyFeeEO");
    }


    public boolean isAttributeUpdateable(int i) {
        Date currentDate = DateUtils.currentDateTruncated();
        if (this.getEffectiveStartDate().equals(currentDate) || i == AttributesEnum.EffectiveEndDate.index()) {
            return true;
        } else {
            return false;
        }
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
     * Gets the attribute value for CompanyFeeTypeIdNo, using the alias name CompanyFeeTypeIdNo.
     * @return the value of CompanyFeeTypeIdNo
     */
    public Integer getCompanyFeeTypeIdNo() {
        return (Integer) getAttributeInternal(COMPANYFEETYPEIDNO);
    }

    /**
     * Sets <code>value</code> as the attribute value for CompanyFeeTypeIdNo.
     * @param value value to set the CompanyFeeTypeIdNo
     */
    public void setCompanyFeeTypeIdNo(Integer value) {
        setAttributeInternal(COMPANYFEETYPEIDNO, value);
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
     * Gets the attribute value for FeeAmt, using the alias name FeeAmt.
     * @return the value of FeeAmt
     */
    public Integer getFeeAmt() {
        return (Integer) getAttributeInternal(FEEAMT);
    }

    /**
     * Sets <code>value</code> as the attribute value for FeeAmt.
     * @param value value to set the FeeAmt
     */
    public void setFeeAmt(Integer value) {
        setAttributeInternal(FEEAMT, value);
    }

    /**
     * Gets the attribute value for FeePerc, using the alias name FeePerc.
     * @return the value of FeePerc
     */
    public Integer getFeePerc() {
        return (Integer) getAttributeInternal(FEEPERC);
    }

    /**
     * Sets <code>value</code> as the attribute value for FeePerc.
     * @param value value to set the FeePerc
     */
    public void setFeePerc(Integer value) {
        setAttributeInternal(FEEPERC, value);
    }

    /**
     * Gets the attribute value for FeeFreqNo, using the alias name FeeFreqNo.
     * @return the value of FeeFreqNo
     */
    public Integer getFeeFreqNo() {
        return (Integer) getAttributeInternal(FEEFREQNO);
    }

    /**
     * Sets <code>value</code> as the attribute value for FeeFreqNo.
     * @param value value to set the FeeFreqNo
     */
    public void setFeeFreqNo(Integer value) {
        setAttributeInternal(FEEFREQNO, value);
    }

    /**
     * Gets the attribute value for FeeCommentDesc, using the alias name FeeCommentDesc.
     * @return the value of FeeCommentDesc
     */
    public String getFeeCommentDesc() {
        return (String) getAttributeInternal(FEECOMMENTDESC);
    }

    /**
     * Sets <code>value</code> as the attribute value for FeeCommentDesc.
     * @param value value to set the FeeCommentDesc
     */
    public void setFeeCommentDesc(String value) {
        setAttributeInternal(FEECOMMENTDESC, value);
    }

    /**
     * Gets the attribute value for LastUpdateDatetime, using the alias name LastUpdateDatetime.
     * @return the value of LastUpdateDatetime
     */
    public Date getLastUpdateDatetime() {
        return (Date) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for Username, using the alias name Username.
     * @return the value of Username
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the attribute value for LastRunDate, using the alias name LastRunDate.
     * @return the value of LastRunDate
     */
    public Date getLastRunDate() {
        return (Date) getAttributeInternal(LASTRUNDATE);
    }

    /**
     * Sets <code>value</code> as the attribute value for LastRunDate.
     * @param value value to set the LastRunDate
     */
    public void setLastRunDate(Date value) {
        setAttributeInternal(LASTRUNDATE, value);
    }

    /**
     * @return the associated entity oracle.jbo.server.EntityImpl.
     */
    public EntityImpl getCompanyFeeType() {
        return (EntityImpl) getAttributeInternal(COMPANYFEETYPE);
    }

    /**
     * Sets <code>value</code> as the associated entity oracle.jbo.server.EntityImpl.
     */
    public void setCompanyFeeType(EntityImpl value) {
        setAttributeInternal(COMPANYFEETYPE, value);
    }


    /**
     * @return the associated entity CompanyEOImpl.
     */
    public CompanyEOImpl getCompany() {
        return (CompanyEOImpl) getAttributeInternal(COMPANY);
    }

    /**
     * Sets <code>value</code> as the associated entity CompanyEOImpl.
     */
    public void setCompany(CompanyEOImpl value) {
        setAttributeInternal(COMPANY, value);
    }


    /**
     * @param companyIdNo key constituent
     * @param companyFeeTypeIdNo key constituent
     * @param effectiveStartDate key constituent

     * @return a Key object based on given key constituents.
     */
    public static Key createPrimaryKey(Integer companyIdNo, Integer companyFeeTypeIdNo, Date effectiveStartDate) {
        return new Key(new Object[] { companyIdNo, companyFeeTypeIdNo, effectiveStartDate });
    }

    /**
     * Validation method for CompanyFeeEO.
     */
    public boolean validateCompanyStartDate() {
        try {
            Date brokerStartDate = this.getCompany().getEffectiveStartDate();

            java.sql.Date brokerDate = brokerStartDate.dateValue();

            java.sql.Date accredDate = this.getEffectiveStartDate().dateValue();

            if (brokerDate.after(accredDate)) {
                return false;
            }
        } catch (NullPointerException e) {
            return false;
        }
        return true;
    }


    /**
     * Validation method for CompanyFeeEO.
     */
    public boolean validateCompanyFeeEO() {
        Boolean returnValue = true;
        if (this.getFeeAmt() != null && this.getFeePerc() != null) {
            if (this.getFeeAmt().compareTo(0) != 0 && this.getFeePerc().compareTo(0) != 0) {
                returnValue = false;
            }
        }
        return returnValue;
    }


}
