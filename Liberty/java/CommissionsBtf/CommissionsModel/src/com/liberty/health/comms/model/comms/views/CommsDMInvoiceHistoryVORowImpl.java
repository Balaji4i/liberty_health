package com.liberty.health.comms.model.comms.views;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 26 11:09:21 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsDMInvoiceHistoryVORowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CountryCode,
        CompanyIdNo,
        InvoiceTypeDesc,
        InvoiceNumber,
        InvoiceDate,
        PaymentReceiveDate,
        ReleaseDate,
        ReleaseHoldReason,
        PaymentDate,
        PaymentRejectDate,
        PaymentRejectDesc,
        InvoicePaymentAmt,
        PaymentExchRate,
        CurrencyCode,
        LastUpdateDatetime,
        Username,
        InvoiceTaxCodes,
        InvDetailAmt,
        InvDetailExchAmt,
        InvDetailDescription;
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
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int INVOICETYPEDESC = AttributesEnum.InvoiceTypeDesc.index();
    public static final int INVOICENUMBER = AttributesEnum.InvoiceNumber.index();
    public static final int INVOICEDATE = AttributesEnum.InvoiceDate.index();
    public static final int PAYMENTRECEIVEDATE = AttributesEnum.PaymentReceiveDate.index();
    public static final int RELEASEDATE = AttributesEnum.ReleaseDate.index();
    public static final int RELEASEHOLDREASON = AttributesEnum.ReleaseHoldReason.index();
    public static final int PAYMENTDATE = AttributesEnum.PaymentDate.index();
    public static final int PAYMENTREJECTDATE = AttributesEnum.PaymentRejectDate.index();
    public static final int PAYMENTREJECTDESC = AttributesEnum.PaymentRejectDesc.index();
    public static final int INVOICEPAYMENTAMT = AttributesEnum.InvoicePaymentAmt.index();
    public static final int PAYMENTEXCHRATE = AttributesEnum.PaymentExchRate.index();
    public static final int CURRENCYCODE = AttributesEnum.CurrencyCode.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int INVOICETAXCODES = AttributesEnum.InvoiceTaxCodes.index();
    public static final int INVDETAILAMT = AttributesEnum.InvDetailAmt.index();
    public static final int INVDETAILEXCHAMT = AttributesEnum.InvDetailExchAmt.index();
    public static final int INVDETAILDESCRIPTION = AttributesEnum.InvDetailDescription.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CommsDMInvoiceHistoryVORowImpl() {
    }
}

