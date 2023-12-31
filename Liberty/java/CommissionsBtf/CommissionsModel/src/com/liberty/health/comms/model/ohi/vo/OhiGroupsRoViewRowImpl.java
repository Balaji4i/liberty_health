package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 06 09:37:45 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OhiGroupsRoViewRowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        GracId,
        GroupCode,
        GroupName,
        CompanyIdNo,
        CompanyName,
        ParentgroupCode,
        GroupType,
        GroupClass,
        PreferredCurrencyCode,
        CountryCode,
        CommPerc,
        CommDesc,
        HoldInd,
        HoldReason,
        NoOfPolicies,
        NoLives,
        OhiProductsRoView1,
        CountryLovView1,
        CountryLovView_N1;
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
    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int GROUPNAME = AttributesEnum.GroupName.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COMPANYNAME = AttributesEnum.CompanyName.index();
    public static final int PARENTGROUPCODE = AttributesEnum.ParentgroupCode.index();
    public static final int GROUPTYPE = AttributesEnum.GroupType.index();
    public static final int GROUPCLASS = AttributesEnum.GroupClass.index();
    public static final int PREFERREDCURRENCYCODE = AttributesEnum.PreferredCurrencyCode.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int COMMPERC = AttributesEnum.CommPerc.index();
    public static final int COMMDESC = AttributesEnum.CommDesc.index();
    public static final int HOLDIND = AttributesEnum.HoldInd.index();
    public static final int HOLDREASON = AttributesEnum.HoldReason.index();
    public static final int NOOFPOLICIES = AttributesEnum.NoOfPolicies.index();
    public static final int NOLIVES = AttributesEnum.NoLives.index();
    public static final int OHIPRODUCTSROVIEW1 = AttributesEnum.OhiProductsRoView1.index();
    public static final int COUNTRYLOVVIEW1 = AttributesEnum.CountryLovView1.index();
    public static final int COUNTRYLOVVIEW_N1 = AttributesEnum.CountryLovView_N1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public OhiGroupsRoViewRowImpl() {
    }
}

