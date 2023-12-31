package com.liberty.health.comms.model.dashboard.vo;

import com.core.model.vo.classes.CoreViewRowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed May 29 10:32:18 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OhiGroupCodesVORowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        GroupCode,
        GroupName,
        CountryCode,
        OhiGroupLovView_P1;
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


    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int GROUPNAME = AttributesEnum.GroupName.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int OHIGROUPLOVVIEW_P1 = AttributesEnum.OhiGroupLovView_P1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public OhiGroupCodesVORowImpl() {
    }
}

