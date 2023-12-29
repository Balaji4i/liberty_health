package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.domain.RowID;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 20 10:09:18 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class HoldIndicatorViewRowImpl extends CoreViewRowImpl {


    public static final int ENTITY_OHIHOLDINDEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        BrokerIdNo,
        CompanyIdNo,
        EffectiveEndDate,
        EffectiveStartDate,
        GroupCode,
        HoldInd,
        HoldReason,
        InseCode,
        LastUpdateDatetime,
        PoepId,
        PolicyCode,
        ProductCode,
        Username,
        RowID,
        ActiveLov1;
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


    public static final int BROKERIDNO = AttributesEnum.BrokerIdNo.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int HOLDIND = AttributesEnum.HoldInd.index();
    public static final int HOLDREASON = AttributesEnum.HoldReason.index();
    public static final int INSECODE = AttributesEnum.InseCode.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int POEPID = AttributesEnum.PoepId.index();
    public static final int POLICYCODE = AttributesEnum.PolicyCode.index();
    public static final int PRODUCTCODE = AttributesEnum.ProductCode.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int ROWID = AttributesEnum.RowID.index();
    public static final int ACTIVELOV1 = AttributesEnum.ActiveLov1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public HoldIndicatorViewRowImpl() {
    }

    /**
     * Gets OhiHoldIndEO entity object.
     * @return the OhiHoldIndEO
     */
    public EntityImpl getOhiHoldIndEO() {
        return (EntityImpl) getEntity(ENTITY_OHIHOLDINDEO);
    }

    /**
     * Gets the attribute value for BROKER_ID_NO using the alias name BrokerIdNo.
     * @return the BROKER_ID_NO
     */
    public Number getBrokerIdNo() {
        return (Number) getAttributeInternal(BROKERIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_ID_NO using the alias name BrokerIdNo.
     * @param value value to set the BROKER_ID_NO
     */
    public void setBrokerIdNo(Number value) {
        setAttributeInternal(BROKERIDNO, value);
    }

    /**
     * Gets the attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @return the COMPANY_ID_NO
     */
    public Number getCompanyIdNo() {
        return (Number) getAttributeInternal(COMPANYIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @param value value to set the COMPANY_ID_NO
     */
    public void setCompanyIdNo(Number value) {
        setAttributeInternal(COMPANYIDNO, value);
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
     * Gets the attribute value for GROUP_CODE using the alias name GroupCode.
     * @return the GROUP_CODE
     */
    public String getGroupCode() {
        return (String) getAttributeInternal(GROUPCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for GROUP_CODE using the alias name GroupCode.
     * @param value value to set the GROUP_CODE
     */
    public void setGroupCode(String value) {
        setAttributeInternal(GROUPCODE, value);
    }

    /**
     * Gets the attribute value for HOLD_IND using the alias name HoldInd.
     * @return the HOLD_IND
     */
    public String getHoldInd() {
        return (String) getAttributeInternal(HOLDIND);
    }

    /**
     * Sets <code>value</code> as attribute value for HOLD_IND using the alias name HoldInd.
     * @param value value to set the HOLD_IND
     */
    public void setHoldInd(String value) {
        setAttributeInternal(HOLDIND, value);
    }

    /**
     * Gets the attribute value for HOLD_REASON using the alias name HoldReason.
     * @return the HOLD_REASON
     */
    public String getHoldReason() {
        return (String) getAttributeInternal(HOLDREASON);
    }

    /**
     * Sets <code>value</code> as attribute value for HOLD_REASON using the alias name HoldReason.
     * @param value value to set the HOLD_REASON
     */
    public void setHoldReason(String value) {
        setAttributeInternal(HOLDREASON, value);
    }

    /**
     * Gets the attribute value for INSE_CODE using the alias name InseCode.
     * @return the INSE_CODE
     */
    public String getInseCode() {
        return (String) getAttributeInternal(INSECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for INSE_CODE using the alias name InseCode.
     * @param value value to set the INSE_CODE
     */
    public void setInseCode(String value) {
        setAttributeInternal(INSECODE, value);
    }

    /**
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Date getLastUpdateDatetime() {
        return (Date) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for POEP_ID using the alias name PoepId.
     * @return the POEP_ID
     */
    public Number getPoepId() {
        return (Number) getAttributeInternal(POEPID);
    }

    /**
     * Sets <code>value</code> as attribute value for POEP_ID using the alias name PoepId.
     * @param value value to set the POEP_ID
     */
    public void setPoepId(Number value) {
        setAttributeInternal(POEPID, value);
    }

    /**
     * Gets the attribute value for POLICY_CODE using the alias name PolicyCode.
     * @return the POLICY_CODE
     */
    public String getPolicyCode() {
        return (String) getAttributeInternal(POLICYCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for POLICY_CODE using the alias name PolicyCode.
     * @param value value to set the POLICY_CODE
     */
    public void setPolicyCode(String value) {
        setAttributeInternal(POLICYCODE, value);
    }

    /**
     * Gets the attribute value for PRODUCT_CODE using the alias name ProductCode.
     * @return the PRODUCT_CODE
     */
    public String getProductCode() {
        return (String) getAttributeInternal(PRODUCTCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for PRODUCT_CODE using the alias name ProductCode.
     * @param value value to set the PRODUCT_CODE
     */
    public void setProductCode(String value) {
        setAttributeInternal(PRODUCTCODE, value);
    }

    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the attribute value for ROWID using the alias name RowID.
     * @return the ROWID
     */
    public RowID getRowID() {
        return (RowID) getAttributeInternal(ROWID);
    }

    /**
     * Gets the view accessor <code>RowSet</code> ActiveLov1.
     */
    public RowSet getActiveLov1() {
        return (RowSet) getAttributeInternal(ACTIVELOV1);
    }
}
