package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import javax.faces.event.ActionEvent;

import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.input.RichInputDate;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;

public class BrokerStatements extends CoreActions {
    String returnMsg;
    private RichPopup errorMsgPopUp;
    private RichPopup successMsgPopUp;
    private RichInputListOfValues brokerIdNoInput;
    private RichInputListOfValues companyIdNoInput;
    private RichInputDate statementDateInput;
    private RichInputListOfValues languageCodeInput;

    public BrokerStatements() {
        super();
    }


    public void executeBrokerStatementActionListener(ActionEvent actionEvent) {
        returnMsg = (String) callOperation("executeBrokerStatement");
        if (returnMsg == null) {
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getSuccessMsgPopUp().show(hints);
            callOperation("Commit");
        } else {
            callOperation("Rolback");
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getSuccessMsgPopUp().show(hints);
        }

    }

    public void setReturnMsg(String returnMsg) {
        this.returnMsg = returnMsg;
    }

    public String getReturnMsg() {
        return returnMsg;
    }

    public void setErrorMsgPopUp(RichPopup errorMsgPopUp) {
        this.errorMsgPopUp = errorMsgPopUp;
    }

    public RichPopup getErrorMsgPopUp() {
        return errorMsgPopUp;
    }

    public void setSuccessMsgPopUp(RichPopup successMsgPopUp) {
        this.successMsgPopUp = successMsgPopUp;
    }

    public RichPopup getSuccessMsgPopUp() {
        return successMsgPopUp;
    }

    public void setBrokerIdNoInput(RichInputListOfValues brokerIdNoInput) {
        this.brokerIdNoInput = brokerIdNoInput;
    }

    public RichInputListOfValues getBrokerIdNoInput() {
        return brokerIdNoInput;
    }

    public void setCompanyIdNoInput(RichInputListOfValues companyIdNoInput) {
        this.companyIdNoInput = companyIdNoInput;
    }

    public RichInputListOfValues getCompanyIdNoInput() {
        return companyIdNoInput;
    }

    public void setStatementDateInput(RichInputDate statementDateInput) {
        this.statementDateInput = statementDateInput;
    }

    public RichInputDate getStatementDateInput() {
        return statementDateInput;
    }

    public void setLanguageCodeInput(RichInputListOfValues languageCodeInput) {
        this.languageCodeInput = languageCodeInput;
    }

    public RichInputListOfValues getLanguageCodeInput() {
        return languageCodeInput;
    }

    public void dialogActionListener(DialogEvent dialogEvent) {
        callOperation("Rolback");
        callOperation("Execute");
    }

    public void cancelActionListener(PopupCanceledEvent popupCanceledEvent) {
        callOperation("Rolback");
        callOperation("Execute");
    }


}
