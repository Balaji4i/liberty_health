package com.liberty.health.comms.model.dashboard.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Mon Jul 08 13:51:33 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class FusionPaymentsReconVORowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        InvoiceNo,
        Bu,
        Source,
        LineTypeLookupCode,
        FusionPayment,
        ReleaseDate,
        CommissionsPayment,
        CountryCode;
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
    public static final int INVOICENO = AttributesEnum.InvoiceNo.index();
    public static final int BU = AttributesEnum.Bu.index();
    public static final int SOURCE = AttributesEnum.Source.index();
    public static final int LINETYPELOOKUPCODE = AttributesEnum.LineTypeLookupCode.index();
    public static final int FUSIONPAYMENT = AttributesEnum.FusionPayment.index();
    public static final int RELEASEDATE = AttributesEnum.ReleaseDate.index();
    public static final int COMMISSIONSPAYMENT = AttributesEnum.CommissionsPayment.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();

    /**
     * This is the default constructor (do not remove).
     */
    public FusionPaymentsReconVORowImpl() {
    }
}

