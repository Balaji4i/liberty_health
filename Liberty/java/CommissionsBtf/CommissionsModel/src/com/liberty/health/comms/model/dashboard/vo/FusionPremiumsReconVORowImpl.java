package com.liberty.health.comms.model.dashboard.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Mar 08 13:44:03 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class FusionPremiumsReconVORowImpl extends CoreViewRowImpl {


    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        OrganizationName,
        ReceiptType,
        Status,
        ParentgroupCode,
        CustomerNumber,
        InvoiceType,
        InvoiceNo,
        TrxDate,
        InvoiceAmt,
        InvCsb,
        PaymentAmt,
        Adjustments,
        CreditMemo,
        TaxAmount,
        BalanceAmt,
        TemplColour,
        CountryCode,
        FusionActiveBuVO1,
        OhiParentGroupLovView1;
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


    public static final int ORGANIZATIONNAME = AttributesEnum.OrganizationName.index();
    public static final int RECEIPTTYPE = AttributesEnum.ReceiptType.index();
    public static final int STATUS = AttributesEnum.Status.index();
    public static final int PARENTGROUPCODE = AttributesEnum.ParentgroupCode.index();
    public static final int CUSTOMERNUMBER = AttributesEnum.CustomerNumber.index();
    public static final int INVOICETYPE = AttributesEnum.InvoiceType.index();
    public static final int INVOICENO = AttributesEnum.InvoiceNo.index();
    public static final int TRXDATE = AttributesEnum.TrxDate.index();
    public static final int INVOICEAMT = AttributesEnum.InvoiceAmt.index();
    public static final int INVCSB = AttributesEnum.InvCsb.index();
    public static final int PAYMENTAMT = AttributesEnum.PaymentAmt.index();
    public static final int ADJUSTMENTS = AttributesEnum.Adjustments.index();
    public static final int CREDITMEMO = AttributesEnum.CreditMemo.index();
    public static final int TAXAMOUNT = AttributesEnum.TaxAmount.index();
    public static final int BALANCEAMT = AttributesEnum.BalanceAmt.index();
    public static final int TEMPLCOLOUR = AttributesEnum.TemplColour.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int FUSIONACTIVEBUVO1 = AttributesEnum.FusionActiveBuVO1.index();
    public static final int OHIPARENTGROUPLOVVIEW1 = AttributesEnum.OhiParentGroupLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public FusionPremiumsReconVORowImpl() {
    }
}

