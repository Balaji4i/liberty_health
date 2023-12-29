package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;

import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.jbo.Row;

import org.apache.myfaces.trinidad.event.AttributeChangeEvent;

public class BrokerFees extends CoreActions {
    Integer brokerFeeTypeIdNo;
    oracle.jbo.domain.Number brokerAmt;
    oracle.jbo.domain.Number brokerPerc;
    oracle.jbo.domain.Number brokerFreq;
    private RichPopup addBrokerFeePopUp;
    private RichInputText feeAmtInputText;
    private RichInputText feePercInputText;

    public BrokerFees() {
        super();
    }

    public void addBrokerFeeDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("Commit");
            callOperation("updateEffDates");
            this.setBrokerFeeTypeIdNo(null);
            this.setBrokerAmt(new oracle.jbo.domain.Number(0));
            this.setBrokerFreq(new oracle.jbo.domain.Number(0));
            this.setBrokerPerc(new oracle.jbo.domain.Number(0));
        }
    }

    public void popUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateWithParams");
    }

    public void popUpCancelListener(PopupCanceledEvent popupCanceledEvent) {
        this.setBrokerFeeTypeIdNo(null);
        this.setBrokerAmt(new oracle.jbo.domain.Number(0));
        this.setBrokerFreq(new oracle.jbo.domain.Number(0));
        this.setBrokerPerc(new oracle.jbo.domain.Number(0));
        callOperation("Rollback");
    }

    public void setBrokerFeeTypeIdNo(Integer brokerFeeTypeIdNo) {
        this.brokerFeeTypeIdNo = brokerFeeTypeIdNo;
    }

    public Integer getBrokerFeeTypeIdNo() {
        return brokerFeeTypeIdNo;
    }

    public void setBrokerAmt(oracle.jbo.domain.Number brokerAmt) {
        this.brokerAmt = brokerAmt;
    }

    public oracle.jbo.domain.Number getBrokerAmt() {
        return brokerAmt;
    }

    public void setBrokerPerc(oracle.jbo.domain.Number brokerPerc) {
        this.brokerPerc = brokerPerc;
    }

    public oracle.jbo.domain.Number getBrokerPerc() {
        return brokerPerc;
    }

    public void setBrokerFreq(oracle.jbo.domain.Number brokerFreq) {
        this.brokerFreq = brokerFreq;
    }

    public oracle.jbo.domain.Number getBrokerFreq() {
        return brokerFreq;
    }

    public void tableContextMenuActionListener(ActionEvent actionEvent) {
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("BrokerFeeByBrokerViewIterator");
        Row row = dcIb.getCurrentRow();
        this.setBrokerFeeTypeIdNo((Integer) row.getAttribute("CompanyFeeTypeIdNo"));
        this.setBrokerAmt((oracle.jbo.domain.Number) row.getAttribute("FeeAmt"));
        this.setBrokerFreq((oracle.jbo.domain.Number) row.getAttribute("FeeFreqNo"));
        this.setBrokerPerc((oracle.jbo.domain.Number) row.getAttribute("FeePerc"));

        RichPopup.PopupHints hints = new RichPopup.PopupHints();
        this.getAddBrokerFeePopUp().show(hints);
    }

    public void setAddBrokerFeePopUp(RichPopup addBrokerFeePopUp) {
        this.addBrokerFeePopUp = addBrokerFeePopUp;
    }

    public RichPopup getAddBrokerFeePopUp() {
        return addBrokerFeePopUp;
    }

    public void setFeeAmtInputText(RichInputText feeAmtInputText) {
        if (feePercInputText != null) {
            this.setFeePercInputText(null);
        }
        this.feeAmtInputText = feeAmtInputText;
    }

    public RichInputText getFeeAmtInputText() {
        return feeAmtInputText;
    }

    public void setFeePercInputText(RichInputText feePercInputText) {
        if (feePercInputText != null) {
    
            this.setFeeAmtInputText(null);
        }
        this.feePercInputText = feePercInputText;
    }

    public RichInputText getFeePercInputText() {
        return feePercInputText;
    }

    public void test(AttributeChangeEvent attributeChangeEvent) {
       
    }

    public void test2(ValueChangeEvent valueChangeEvent) {
      
    }
}
