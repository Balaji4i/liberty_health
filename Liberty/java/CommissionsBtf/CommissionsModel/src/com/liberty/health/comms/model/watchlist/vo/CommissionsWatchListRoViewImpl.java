package com.liberty.health.comms.model.watchlist.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.watchlist.vo.common.CommissionsWatchListRoView;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Fri Jun 02 09:31:03 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommissionsWatchListRoViewImpl extends CoreViewObjectImpl implements CommissionsWatchListRoView {
    /**
     * This is the default constructor (do not remove).
     */
    public CommissionsWatchListRoViewImpl() {
    }

    /**
     * Returns the variable value for pLocalCode.
     * @return variable value for pLocalCode
     */
    public String getpLocalCode() {
        return (String) ensureVariableManager().getVariableValue("pLocalCode");
    }

    /**
     * Sets <code>value</code> for variable pLocalCode.
     * @param value value to bind as pLocalCode
     */
    public void setpLocalCode(String value) {
        ensureVariableManager().setVariableValue("pLocalCode", value);
        this.executeQuery();
    }
}

