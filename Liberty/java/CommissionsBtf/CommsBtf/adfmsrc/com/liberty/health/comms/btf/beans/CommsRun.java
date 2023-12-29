package com.liberty.health.comms.btf.beans;

import com.core.generic.CoreActions;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.event.DialogEvent;

public class CommsRun extends CoreActions {
    public CommsRun() {
        super();
    }

    public void searchButtonActionListener(ActionEvent actionEvent) {
        String returnMsg = (String) callOperation("executeCommissionRun");
      //  callOperation("searchCommsRun");
        callOperation("searchCommsRunResults");
         callOperation("returnAllCommsDetail");
        if (returnMsg != null) {            
            FacesContext fc = FacesContext.getCurrentInstance();
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Information", returnMsg);
            fc.addMessage(null, message);
        }
    }
    
    public void displayLastRun(ActionEvent actionEvent) {
        callOperation("searchCommsRunResults");
        callOperation("returnAllCommsDetail");
    }

    public void approveCommissionRunDialogListener(DialogEvent dialogEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            String returnMsg = (String) callOperation("approveCommissionRun");
            if (returnMsg == null) {
                FacesMessage message =
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success",
                                     "Commission run has been succesfully approved.");
                fc.addMessage(null, message);
                NavigationHandler handler = FacesContext.getCurrentInstance()
                                                        .getApplication()
                                                        .getNavigationHandler();
                handler.handleNavigation(FacesContext.getCurrentInstance(), null, "save");
            } else {
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
                fc.addMessage(null, message);
            }
        }
    }
}
