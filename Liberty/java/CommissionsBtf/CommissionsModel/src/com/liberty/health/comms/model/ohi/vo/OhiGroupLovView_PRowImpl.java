package com.liberty.health.comms.model.ohi.vo;

import com.core.model.vo.classes.CoreViewRowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 09 14:06:33 IST 2023
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OhiGroupLovView_PRowImpl extends CoreViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        ParentgroupCode,
        GroupCode,
        GroupName,
        CountryCode,
        OhiStructureAM_CountryLovView_N1_1,
        CountryLovView_N1,
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
    public static final int PARENTGROUPCODE = AttributesEnum.ParentgroupCode.index();
    public static final int GROUPCODE = AttributesEnum.GroupCode.index();
    public static final int GROUPNAME = AttributesEnum.GroupName.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int OHISTRUCTUREAM_COUNTRYLOVVIEW_N1_1 =
        AttributesEnum.OhiStructureAM_CountryLovView_N1_1.index();
    public static final int COUNTRYLOVVIEW_N1 = AttributesEnum.CountryLovView_N1.index();
    public static final int OHIPARENTGROUPLOVVIEW1 = AttributesEnum.OhiParentGroupLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public OhiGroupLovView_PRowImpl() {
    }
}

