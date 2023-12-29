package com.liberty.health.comms.btf.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.event.DialogEvent;

import oracle.jbo.Row;
import oracle.jbo.ViewObject;

public class PaymentRun extends CoreActions {
    public PaymentRun() {
        super();
    }

    public void executePaymentRunActionListener(ActionEvent actionEvent) {
        
            String msg = (String) callOperation("executePaymentRun");
            callOperation("Execute");
            FacesContext fc = FacesContext.getCurrentInstance();
            if (msg == null) {
                FacesMessage message =
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success", "Payment run has been executed succesfully");
                fc.addMessage(null, message);
            } else {
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", msg);
                fc.addMessage(null, message);
            }
        }
        

    public void approvePaymentRunDialogListener(DialogEvent dialogEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            String returnMsg = (String) callOperation("executePaymentRun");
            if (returnMsg == null) {
                FacesMessage message =
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success",
                                     "Payment run has been succesfully executed.");
                fc.addMessage(null, message);
            } else {
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
                fc.addMessage(null, message);
            }
        }
    }

    public void submitPaymentsByBrokerageActionListener(ActionEvent actionEvent) {
      
          
            
        FacesContext fc = FacesContext.getCurrentInstance();
      
        String returnMsg = (String) callOperation("executePaymentRun");
        if (returnMsg == null) {
            callOperation("Commit");
            callOperation("Execute");
        } else {
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
            fc.addMessage(null, message);
            callOperation("Rollback");
        }
    }
    }
    

