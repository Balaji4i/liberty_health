package com.liberty.health.comms.lov;

import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
import oracle.jbo.server.ViewRowImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Oct 26 10:54:53 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommHubJobsLovViewRowImpl extends ViewRowImpl {
    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        JobId,
        JobName,
        JobDesc,
        JobExecutable,
        JobType,
        FromDate,
        ToDate,
        Enabled,
        FacetName;
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

    public static final int JOBID = AttributesEnum.JobId.index();
    public static final int JOBNAME = AttributesEnum.JobName.index();
    public static final int JOBDESC = AttributesEnum.JobDesc.index();
    public static final int JOBEXECUTABLE = AttributesEnum.JobExecutable.index();
    public static final int JOBTYPE = AttributesEnum.JobType.index();
    public static final int FROMDATE = AttributesEnum.FromDate.index();
    public static final int TODATE = AttributesEnum.ToDate.index();
    public static final int ENABLED = AttributesEnum.Enabled.index();
    public static final int FACETNAME = AttributesEnum.FacetName.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CommHubJobsLovViewRowImpl() {
    }
}
