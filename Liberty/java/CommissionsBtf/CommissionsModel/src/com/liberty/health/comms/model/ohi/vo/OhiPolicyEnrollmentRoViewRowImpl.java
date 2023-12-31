package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 06 09:48:07 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OhiPolicyEnrollmentRoViewRowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        GracId,
        PoliId,
        PolicyCode,
        ProductCode,
        CountryCode,
        ProductName,
        ProductDescr,
        CommPerc,
        CommDesc,
        HoldInd,
        HoldReason,
        NoOfDependants,
        EnprId,
        OhiPolicyEnrollmentPersonsRoView;
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


    public static final int GRACID = AttributesEnum.GracId.index();
    public static final int POLIID = AttributesEnum.PoliId.index();
    public static final int POLICYCODE = AttributesEnum.PolicyCode.index();
    public static final int PRODUCTCODE = AttributesEnum.ProductCode.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int PRODUCTNAME = AttributesEnum.ProductName.index();
    public static final int PRODUCTDESCR = AttributesEnum.ProductDescr.index();
    public static final int COMMPERC = AttributesEnum.CommPerc.index();
    public static final int COMMDESC = AttributesEnum.CommDesc.index();
    public static final int HOLDIND = AttributesEnum.HoldInd.index();
    public static final int HOLDREASON = AttributesEnum.HoldReason.index();
    public static final int NOOFDEPENDANTS = AttributesEnum.NoOfDependants.index();
    public static final int ENPRID = AttributesEnum.EnprId.index();
    public static final int OHIPOLICYENROLLMENTPERSONSROVIEW = AttributesEnum.OhiPolicyEnrollmentPersonsRoView.index();

    /**
     * This is the default constructor (do not remove).
     */
    public OhiPolicyEnrollmentRoViewRowImpl() {
    }
}

