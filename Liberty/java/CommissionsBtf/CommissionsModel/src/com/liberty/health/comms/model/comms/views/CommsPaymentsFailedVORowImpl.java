package com.liberty.health.comms.model.comms.views;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Jan 08 08:39:19 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsPaymentsFailedVORowImpl extends CoreViewRowImpl {


    public static final int ENTITY_COMMSPAYMENTSRECEIVEDEO = 0;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        ParentgroupCode,
        ProcessedInd,
        ProcessedDesc,
        ApplicationId,
        CountryCode,
        GroupCode,
        ProductCode,
        PolicyCode,
        PersonCode,
        ContributionDate,
        FinanceReceiptNo,
        FinanceReceiptDate,
        PaymentType,
        ArchivedYn,
        CommsPremFailedArchiveLov1,
        OhiStructureAM_CountryLovView_N1_1,
        OhiStructureAM_OhiGroupsRoView1_1,
        OhiStructureAM_OhiProductsRoView1_1,
        OhiStructureAM_OhiGroupLovView_P1_1,
        OhiStructureAM_OhiProductLovView_P1_1,
        OhiProductLovView_P1,
        OhiGroupLovView_P1,
        CountryLovView_N1,
        OhiGroupsRoView1,
        OhiProductsRoView1,
        OhiParentGroupLovView1;
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


    public static final int PARENTGROUPCODE = AttributesEnum.ParentgroupCode.index();
    public static final int PROCESSEDIND = AttributesEnum.ProcessedInd.index();
    public static final int PROCESSEDDESC = AttributesEnum.ProcessedDesc.index();
    public static final int APPLICATIONID = AttributesEnum.ApplicationId.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int PRODUCTCODE = AttributesEnum.ProductCode.index();
    public static final int POLICYCODE = AttributesEnum.PolicyCode.index();
    public static final int PERSONCODE = AttributesEnum.PersonCode.index();
    public static final int CONTRIBUTIONDATE = AttributesEnum.ContributionDate.index();
    public static final int FINANCERECEIPTNO = AttributesEnum.FinanceReceiptNo.index();
    public static final int FINANCERECEIPTDATE = AttributesEnum.FinanceReceiptDate.index();
    public static final int PAYMENTTYPE = AttributesEnum.PaymentType.index();
    public static final int ARCHIVEDYN = AttributesEnum.ArchivedYn.index();
    public static final int COMMSPREMFAILEDARCHIVELOV1 = AttributesEnum.CommsPremFailedArchiveLov1.index();
    public static final int OHISTRUCTUREAM_COUNTRYLOVVIEW_N1_1 =
        AttributesEnum.OhiStructureAM_CountryLovView_N1_1.index();
    public static final int OHISTRUCTUREAM_OHIGROUPSROVIEW1_1 =
        AttributesEnum.OhiStructureAM_OhiGroupsRoView1_1.index();
    public static final int OHISTRUCTUREAM_OHIPRODUCTSROVIEW1_1 =
        AttributesEnum.OhiStructureAM_OhiProductsRoView1_1.index();
    public static final int OHISTRUCTUREAM_OHIGROUPLOVVIEW_P1_1 =
        AttributesEnum.OhiStructureAM_OhiGroupLovView_P1_1.index();
    public static final int OHISTRUCTUREAM_OHIPRODUCTLOVVIEW_P1_1 =
        AttributesEnum.OhiStructureAM_OhiProductLovView_P1_1.index();
    public static final int OHIPRODUCTLOVVIEW_P1 = AttributesEnum.OhiProductLovView_P1.index();
    public static final int OHIGROUPLOVVIEW_P1 = AttributesEnum.OhiGroupLovView_P1.index();
    public static final int COUNTRYLOVVIEW_N1 = AttributesEnum.CountryLovView_N1.index();
    public static final int OHIGROUPSROVIEW1 = AttributesEnum.OhiGroupsRoView1.index();
    public static final int OHIPRODUCTSROVIEW1 = AttributesEnum.OhiProductsRoView1.index();
    public static final int OHIPARENTGROUPLOVVIEW1 = AttributesEnum.OhiParentGroupLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CommsPaymentsFailedVORowImpl() {
    }

    /**
     * Gets CommsPaymentsReceivedEO entity object.
     * @return the CommsPaymentsReceivedEO
     */
    public EntityImpl getCommsPaymentsReceivedEO() {
        return (EntityImpl) getEntity(ENTITY_COMMSPAYMENTSRECEIVEDEO);
    }

    /**
     * Gets the attribute value for the calculated attribute ParentgroupCode.
     * @return the ParentgroupCode
     */
    public String getParentgroupCode() {
        return (String) getAttributeInternal(PARENTGROUPCODE);
    }

    /**
     * Gets the attribute value for PROCESSED_IND using the alias name ProcessedInd.
     * @return the PROCESSED_IND
     */
    public String getProcessedInd() {
        return (String) getAttributeInternal(PROCESSEDIND);
    }


    /**
     * Sets <code>value</code> as attribute value for PROCESSED_IND using the alias name ProcessedInd.
     * @param value value to set the PROCESSED_IND
     */
    public void setProcessedInd(String value) {
        setAttributeInternal(PROCESSEDIND, value);
    }

    /**
     * Gets the attribute value for PROCESSED_DESC using the alias name ProcessedDesc.
     * @return the PROCESSED_DESC
     */
    public String getProcessedDesc() {
        return (String) getAttributeInternal(PROCESSEDDESC);
    }

    /**
     * Gets the attribute value for APPLICATION_ID using the alias name ApplicationId.
     * @return the APPLICATION_ID
     */
    public Number getApplicationId() {
        return (Number) getAttributeInternal(APPLICATIONID);
    }

    /**
     * Gets the attribute value for COUNTRY_CODE using the alias name CountryCode.
     * @return the COUNTRY_CODE
     */
    public String getCountryCode() {
        return (String) getAttributeInternal(COUNTRYCODE);
    }


    /**
     * Gets the attribute value for GROUP_CODE using the alias name GroupCode.
     * @return the GROUP_CODE
     */
    public String getGroupCode() {
        return (String) getAttributeInternal(GROUPCODE);
    }


    /**
     * Gets the attribute value for PRODUCT_CODE using the alias name ProductCode.
     * @return the PRODUCT_CODE
     */
    public String getProductCode() {
        return (String) getAttributeInternal(PRODUCTCODE);
    }


    /**
     * Gets the attribute value for POLICY_CODE using the alias name PolicyCode.
     * @return the POLICY_CODE
     */
    public String getPolicyCode() {
        return (String) getAttributeInternal(POLICYCODE);
    }

    /**
     * Gets the attribute value for PERSON_CODE using the alias name PersonCode.
     * @return the PERSON_CODE
     */
    public String getPersonCode() {
        return (String) getAttributeInternal(PERSONCODE);
    }


    /**
     * Gets the attribute value for CONTRIBUTION_DATE using the alias name ContributionDate.
     * @return the CONTRIBUTION_DATE
     */
    public Date getContributionDate() {
        return (Date) getAttributeInternal(CONTRIBUTIONDATE);
    }


    /**
     * Gets the attribute value for FINANCE_RECEIPT_NO using the alias name FinanceReceiptNo.
     * @return the FINANCE_RECEIPT_NO
     */
    public String getFinanceReceiptNo() {
        return (String) getAttributeInternal(FINANCERECEIPTNO);
    }


    /**
     * Gets the attribute value for FINANCE_RECEIPT_DATE using the alias name FinanceReceiptDate.
     * @return the FINANCE_RECEIPT_DATE
     */
    public Date getFinanceReceiptDate() {
        return (Date) getAttributeInternal(FINANCERECEIPTDATE);
    }


    /**
     * Gets the attribute value for PAYMENT_TYPE using the alias name PaymentType.
     * @return the PAYMENT_TYPE
     */
    public String getPaymentType() {
        return (String) getAttributeInternal(PAYMENTTYPE);
    }

    /**
     * Gets the attribute value for ARCHIVED_YN using the alias name ArchivedYn.
     * @return the ARCHIVED_YN
     */
    public String getArchivedYn() {
        return (String) getAttributeInternal(ARCHIVEDYN);
    }

    /**
     * Sets <code>value</code> as attribute value for ARCHIVED_YN using the alias name ArchivedYn.
     * @param value value to set the ARCHIVED_YN
     */
    public void setArchivedYn(String value) {
        setAttributeInternal(ARCHIVEDYN, value);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CommsPremFailedArchiveLov1.
     */
    public RowSet getCommsPremFailedArchiveLov1() {
        return (RowSet) getAttributeInternal(COMMSPREMFAILEDARCHIVELOV1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiStructureAM_CountryLovView_N1_1.
     */
    public RowSet getOhiStructureAM_CountryLovView_N1_1() {
        return (RowSet) getAttributeInternal(OHISTRUCTUREAM_COUNTRYLOVVIEW_N1_1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiStructureAM_OhiGroupsRoView1_1.
     */
    public RowSet getOhiStructureAM_OhiGroupsRoView1_1() {
        return (RowSet) getAttributeInternal(OHISTRUCTUREAM_OHIGROUPSROVIEW1_1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiStructureAM_OhiProductsRoView1_1.
     */
    public RowSet getOhiStructureAM_OhiProductsRoView1_1() {
        return (RowSet) getAttributeInternal(OHISTRUCTUREAM_OHIPRODUCTSROVIEW1_1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiStructureAM_OhiGroupLovView_P1_1.
     */
    public RowSet getOhiStructureAM_OhiGroupLovView_P1_1() {
        return (RowSet) getAttributeInternal(OHISTRUCTUREAM_OHIGROUPLOVVIEW_P1_1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiStructureAM_OhiProductLovView_P1_1.
     */
    public RowSet getOhiStructureAM_OhiProductLovView_P1_1() {
        return (RowSet) getAttributeInternal(OHISTRUCTUREAM_OHIPRODUCTLOVVIEW_P1_1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiProductLovView_P1.
     */
    public RowSet getOhiProductLovView_P1() {
        return (RowSet) getAttributeInternal(OHIPRODUCTLOVVIEW_P1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiGroupLovView_P1.
     */
    public RowSet getOhiGroupLovView_P1() {
        return (RowSet) getAttributeInternal(OHIGROUPLOVVIEW_P1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CountryLovView_N1.
     */
    public RowSet getCountryLovView_N1() {
        return (RowSet) getAttributeInternal(COUNTRYLOVVIEW_N1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiGroupsRoView1.
     */
    public RowSet getOhiGroupsRoView1() {
        return (RowSet) getAttributeInternal(OHIGROUPSROVIEW1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiProductsRoView1.
     */
    public RowSet getOhiProductsRoView1() {
        return (RowSet) getAttributeInternal(OHIPRODUCTSROVIEW1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> OhiParentGroupLovView1.
     */
    public RowSet getOhiParentGroupLovView1() {
        return (RowSet) getAttributeInternal(OHIPARENTGROUPLOVVIEW1);
    }


}
