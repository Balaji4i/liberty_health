package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;

import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

public class OhiHoldIndBean extends CoreActions {
    String ohiHoldFacetName = "view";
    public OhiHoldIndBean() {
        super();
    }
    
    public void saveButtonActionListener(ActionEvent actionEvent) {
        callOperation("Commit");
        callOperation("updateEffDates");
        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                .getApplication()
                                                .getNavigationHandler();
        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "save");

    }
    

    public void createActionListener(ActionEvent actionEvent) {
       callOperation("CreateWithParams");
       this.setOhiHoldFacetName("maintain");
    }

    @SuppressWarnings("oracle.jdeveloper.java.tag-is-missing")
    public void doneActionListener(ActionEvent actionEvent) {
        this.setOhiHoldFacetName("view");
    }

    public void setOhiHoldFacetName(String ohiHoldFacetName) {
        this.ohiHoldFacetName = ohiHoldFacetName;
    }

    public String getOhiHoldFacetName() {
        return ohiHoldFacetName;
    }
}
