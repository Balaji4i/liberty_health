package com.liberty.health.comms.model.payment.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Apr 27 16:39:53 IST 2023
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class BrokPaymentsAdjustVORowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        InvoiceNo,
        FeeTypeAmt,
        FeeTypeDesc,
        FeeTypeExchAmt,
        FeeTypeIdNo,
        LastUpdateDatetime,
        Username,
        CompanyIdNo,
        CompanyName,
        PaymentReceiveDate,
        CountryCode,
        CurrencyCode,
        InvoiceDate,
        InvoiceNo1,
        InvoiceTaxCodes,
        InvoiceTypeIdNo,
        LastUpdateDatetime1,
        PaymentAmt,
        PaymentDate,
        PaymentExchRate,
        PaymentRejectDate,
        PaymentRejectDesc,
        ReleaseDate,
        ReleaseHoldReason,
        Username1,
        Bu;
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


    public static final int INVOICENO = AttributesEnum.InvoiceNo.index();
    public static final int FEETYPEAMT = AttributesEnum.FeeTypeAmt.index();
    public static final int FEETYPEDESC = AttributesEnum.FeeTypeDesc.index();
    public static final int FEETYPEEXCHAMT = AttributesEnum.FeeTypeExchAmt.index();
    public static final int FEETYPEIDNO = AttributesEnum.FeeTypeIdNo.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COMPANYNAME = AttributesEnum.CompanyName.index();
    public static final int PAYMENTRECEIVEDATE = AttributesEnum.PaymentReceiveDate.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int CURRENCYCODE = AttributesEnum.CurrencyCode.index();
    public static final int INVOICEDATE = AttributesEnum.InvoiceDate.index();
    public static final int INVOICENO1 = AttributesEnum.InvoiceNo1.index();
    public static final int INVOICETAXCODES = AttributesEnum.InvoiceTaxCodes.index();
    public static final int INVOICETYPEIDNO = AttributesEnum.InvoiceTypeIdNo.index();
    public static final int LASTUPDATEDATETIME1 = AttributesEnum.LastUpdateDatetime1.index();
    public static final int PAYMENTAMT = AttributesEnum.PaymentAmt.index();
    public static final int PAYMENTDATE = AttributesEnum.PaymentDate.index();
    public static final int PAYMENTEXCHRATE = AttributesEnum.PaymentExchRate.index();
    public static final int PAYMENTREJECTDATE = AttributesEnum.PaymentRejectDate.index();
    public static final int PAYMENTREJECTDESC = AttributesEnum.PaymentRejectDesc.index();
    public static final int RELEASEDATE = AttributesEnum.ReleaseDate.index();
    public static final int RELEASEHOLDREASON = AttributesEnum.ReleaseHoldReason.index();
    public static final int USERNAME1 = AttributesEnum.Username1.index();
    public static final int BU = AttributesEnum.Bu.index();

    /**
     * This is the default constructor (do not remove).
     */
    public BrokPaymentsAdjustVORowImpl() {
    }

    /**
     * Gets the attribute value for the calculated attribute FeeTypeAmt.
     * @return the FeeTypeAmt
     */
    public Number getFeeTypeAmt() {
        return (Number) getAttributeInternal(FEETYPEAMT);
    }

    /**
     * Gets the attribute value for the calculated attribute FeeTypeDesc.
     * @return the FeeTypeDesc
     */
    public String getFeeTypeDesc() {
        return (String) getAttributeInternal(FEETYPEDESC);
    }

    /**
     * Gets the attribute value for the calculated attribute FeeTypeExchAmt.
     * @return the FeeTypeExchAmt
     */
    public Number getFeeTypeExchAmt() {
        return (Number) getAttributeInternal(FEETYPEEXCHAMT);
    }

    /**
     * Gets the attribute value for the calculated attribute FeeTypeIdNo.
     * @return the FeeTypeIdNo
     */
    public Number getFeeTypeIdNo() {
        return (Number) getAttributeInternal(FEETYPEIDNO);
    }

    /**
     * Gets the attribute value for the calculated attribute InvoiceNo.
     * @return the InvoiceNo
     */
    public Number getInvoiceNo() {
        return (Number) getAttributeInternal(INVOICENO);
    }

    /**
     * Gets the attribute value for the calculated attribute LastUpdateDatetime.
     * @return the LastUpdateDatetime
     */
    public Date getLastUpdateDatetime() {
        return (Date) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for the calculated attribute Username.
     * @return the Username
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the attribute value for the calculated attribute CompanyIdNo.
     * @return the CompanyIdNo
     */
    public Number getCompanyIdNo() {
        return (Number) getAttributeInternal(COMPANYIDNO);
    }

    /**
     * Gets the attribute value for the calculated attribute CompanyName.
     * @return the CompanyName
     */
    public String getCompanyName() {
        return (String) getAttributeInternal(COMPANYNAME);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentReceiveDate.
     * @return the PaymentReceiveDate
     */
    public Date getPaymentReceiveDate() {
        return (Date) getAttributeInternal(PAYMENTRECEIVEDATE);
    }

    /**
     * Gets the attribute value for the calculated attribute CountryCode.
     * @return the CountryCode
     */
    public String getCountryCode() {
        return (String) getAttributeInternal(COUNTRYCODE);
    }

    /**
     * Gets the attribute value for the calculated attribute CurrencyCode.
     * @return the CurrencyCode
     */
    public String getCurrencyCode() {
        return (String) getAttributeInternal(CURRENCYCODE);
    }

    /**
     * Gets the attribute value for the calculated attribute InvoiceDate.
     * @return the InvoiceDate
     */
    public Date getInvoiceDate() {
        return (Date) getAttributeInternal(INVOICEDATE);
    }

    /**
     * Gets the attribute value for the calculated attribute InvoiceNo1.
     * @return the InvoiceNo1
     */
    public Number getInvoiceNo1() {
        return (Number) getAttributeInternal(INVOICENO1);
    }

    /**
     * Gets the attribute value for the calculated attribute InvoiceTaxCodes.
     * @return the InvoiceTaxCodes
     */
    public String getInvoiceTaxCodes() {
        return (String) getAttributeInternal(INVOICETAXCODES);
    }

    /**
     * Gets the attribute value for the calculated attribute InvoiceTypeIdNo.
     * @return the InvoiceTypeIdNo
     */
    public Number getInvoiceTypeIdNo() {
        return (Number) getAttributeInternal(INVOICETYPEIDNO);
    }

    /**
     * Gets the attribute value for the calculated attribute LastUpdateDatetime1.
     * @return the LastUpdateDatetime1
     */
    public Date getLastUpdateDatetime1() {
        return (Date) getAttributeInternal(LASTUPDATEDATETIME1);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentAmt.
     * @return the PaymentAmt
     */
    public Number getPaymentAmt() {
        return (Number) getAttributeInternal(PAYMENTAMT);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentDate.
     * @return the PaymentDate
     */
    public Date getPaymentDate() {
        return (Date) getAttributeInternal(PAYMENTDATE);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentExchRate.
     * @return the PaymentExchRate
     */
    public Number getPaymentExchRate() {
        return (Number) getAttributeInternal(PAYMENTEXCHRATE);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentRejectDate.
     * @return the PaymentRejectDate
     */
    public Date getPaymentRejectDate() {
        return (Date) getAttributeInternal(PAYMENTREJECTDATE);
    }

    /**
     * Gets the attribute value for the calculated attribute PaymentRejectDesc.
     * @return the PaymentRejectDesc
     */
    public String getPaymentRejectDesc() {
        return (String) getAttributeInternal(PAYMENTREJECTDESC);
    }

    /**
     * Gets the attribute value for the calculated attribute ReleaseDate.
     * @return the ReleaseDate
     */
    public Date getReleaseDate() {
        return (Date) getAttributeInternal(RELEASEDATE);
    }

    /**
     * Gets the attribute value for the calculated attribute ReleaseHoldReason.
     * @return the ReleaseHoldReason
     */
    public String getReleaseHoldReason() {
        return (String) getAttributeInternal(RELEASEHOLDREASON);
    }

    /**
     * Gets the attribute value for the calculated attribute Username1.
     * @return the Username1
     */
    public String getUsername1() {
        return (String) getAttributeInternal(USERNAME1);
    }

    /**
     * Gets the attribute value for the calculated attribute Bu.
     * @return the Bu
     */
    public String getBu() {
        return (String) getAttributeInternal(BU);
    }
}

