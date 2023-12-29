package com.liberty.health.comms.model.comms.views;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Jun 25 08:44:52 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsPreApprovalChecksVORowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        FinanceInvoiceNo,
        BrokerageCode,
        CountryCode,
        CommsCalcTypeCode,
        GroupCode,
        PaymentCurrency,
        CommsCalculated,
        ExchangeRateCurrencyCode,
        ExchangeRate,
        PaymentAmt;
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


    public static final int FINANCEINVOICENO = AttributesEnum.FinanceInvoiceNo.index();
    public static final int BROKERAGECODE = AttributesEnum.BrokerageCode.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int COMMSCALCTYPECODE = AttributesEnum.CommsCalcTypeCode.index();
    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int PAYMENTCURRENCY = AttributesEnum.PaymentCurrency.index();
    public static final int COMMSCALCULATED = AttributesEnum.CommsCalculated.index();
    public static final int EXCHANGERATECURRENCYCODE = AttributesEnum.ExchangeRateCurrencyCode.index();
    public static final int EXCHANGERATE = AttributesEnum.ExchangeRate.index();
    public static final int PAYMENTAMT = AttributesEnum.PaymentAmt.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CommsPreApprovalChecksVORowImpl() {
    }
}

