package com.liberty.health.comms.model.dashboard.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jul 18 10:50:20 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class FusionPremInvoiceMedReceiptVOImpl extends CoreViewObjectImpl {
    /**
     * This is the default constructor (do not remove).
     */
    public FusionPremInvoiceMedReceiptVOImpl() {
    }


    /**
     * Returns the bind variable value for pinvno.
     * @return bind variable value for pinvno
     */
    public String getpinvno() {
        return (String) getNamedWhereClauseParam("pinvno");
    }

    /**
     * Sets <code>value</code> for bind variable pinvno.
     * @param value value to bind as pinvno
     */
    public void setpinvno(String value) {
        setNamedWhereClauseParam("pinvno", value);
    }

    /**
     * Returns the bind variable value for pcountrylist.
     * @return bind variable value for pcountrylist
     */
    public String getpcountrylist() {
        return (String) getNamedWhereClauseParam("pcountrylist");
    }

    /**
     * Sets <code>value</code> for bind variable pcountrylist.
     * @param value value to bind as pcountrylist
     */
    public void setpcountrylist(String value) {
        setNamedWhereClauseParam("pcountrylist", value);
    }
}

