package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.view.rich.component.rich.input.RichInputText;

public class PercentageRejection extends CoreActions {
    private RichInputText rejectionInputTextBox;
    String inputMessage;
    
    public PercentageRejection() {
        super();
    }
    
    public void setRejectionInputTextBox(RichInputText rejectionInputTextBox) {
        this.rejectionInputTextBox = rejectionInputTextBox;
    }

    public RichInputText getRejectionInputTextBox() {
        return rejectionInputTextBox;
    }

    public void setInputMessage(String inputMessage) {
        this.inputMessage = inputMessage;
    }

    public String getInputMessage() {
        return inputMessage;
    }

    public void inputTextBoxValueChangeListener(ValueChangeEvent valueChangeEvent) {
        this.setInputMessage(valueChangeEvent.getNewValue().toString());
    }
}
