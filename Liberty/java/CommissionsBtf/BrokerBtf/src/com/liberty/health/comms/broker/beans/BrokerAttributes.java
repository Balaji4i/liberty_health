package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import java.util.Date;

import javax.faces.application.NavigationHandler;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;

import oracle.adf.view.rich.component.rich.input.RichInputDate;
import oracle.adf.view.rich.component.rich.input.RichInputText;

import oracle.binding.BindingContainer;

import oracle.binding.OperationBinding;

import oracle.jbo.Row;
import oracle.jbo.Key;



public class BrokerAttributes extends CoreActions {
    String commentDesc;
    private RichInputText commentDescInputTextBox;
    private Date pNewDate;
    oracle.jbo.domain.Date currentDate = DateUtils.currentDateTruncated();
    java.util.Date minDatePickerDate = DateUtils.currentUtilDateTruncated();
    public void setCommentDesc(String commentDesc) {

        this.commentDesc = commentDesc;
    }

    public String getCommentDesc() {
        return commentDesc;
    }
    
    public void setCommentDescInputTextBox(RichInputText commentDescInputTextBox) {
        this.commentDescInputTextBox = commentDescInputTextBox;
    }

    public RichInputText getCommentDescInputTextBox() {
        return commentDescInputTextBox;
    }
    public BrokerAttributes() {
        super();
    }

    public void saveAndEffectiveDateActionListener(ActionEvent e) {
        callOperation("Commit");
        callOperation("updateEffDates");
    }
    public void saveAndEffectiveDateActionFunctionListener(ActionEvent e) {
        //callOperation("setpBrokerIdNo");
//        if (this.getCommentDesc() != null) {
//            callOperation("createComment");
//        }
        callOperation("Commit");
        
        callOperation("updateEffDates");
        //this.setCommentDesc(null);
        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                .getApplication()
                                                .getNavigationHandler();
        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "goExecute");
        
    }
    
    public void commentDescValueChangeListener(ValueChangeEvent valueChangeEvent) {
        this.setCommentDesc(commentDescInputTextBox.getValue().toString());
    }
    public void saveAndsetBrokerActionListener(ActionEvent e) {
        callOperation("Commit");
        callOperation("setpBrokerIdNo1");
    }

    public void setCurrentDate(oracle.jbo.domain.Date currentDate) {
        this.currentDate = currentDate;
    }

    public oracle.jbo.domain.Date getCurrentDate() {
        return currentDate;
    }

    public void setMinDatePickerDate(Date minDatePickerDate) {
        this.minDatePickerDate = minDatePickerDate;
    }

    public Date getMinDatePickerDate() {
        return minDatePickerDate;
    }

    public String callCommunicationHub() {
        String link = null;
        String server = (String) callOperation("getCommunicationHubLink");
        String brokerCode = "0";
        System.out.println("in the broker attributes bean getting brokerIdNo**step1");
        
        
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("BrokerByPkViewIterator");
        Row row = dcIb.getCurrentRow();
        //note T.Percy added to handle a no row found need to show error message stating that the
        // broker is not allocated to a brokerage in else section otherwise nothing is returned to the 
        // screen
        if (row != null)
        {
        
            brokerCode = row.getAttribute("BrokerIdNo").toString();
        
            link = server + "pEntityType=AG&pEntityNo=" + brokerCode;
        }

      // System.out.println("in the broker attributes bean getting brokerIdNo**step2");
      
       // System.out.println("in the broker attributes bean getting brokerIdNo*step3 "+link);
        return link;
    }


    public String getLinkWithParams() {
        String base = this.callCommunicationHub();
        return base;
    }
    
    public void setpNewDate(Date pNewDate) {
        this.pNewDate = pNewDate;
    }

    public Date getpNewDate() {
        return pNewDate;
    }

    public BindingContainer getBindings() {
        return BindingContext.getCurrent().getCurrentBindingsEntry();
    }

    public void refreshBackDatingView(ActionEvent actionEvent) {
       /* DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("BrokerAttributesByBrokerView1Iterator");
        Key brokerKey = dcIb.getCurrentRow().get
        BindingContainer bindings = getBindings();
        OperationBinding operationBinding = bindings.getOperationBinding("Rollback");
        operationBinding.execute();
        System.out.println("run the rollback resetting the key");
        reset key value
        System.out.println("key is "+brokerKey.toString());
        dcIb.setCurrentRowWithKey(brokerKey.toStringFormat(true));*/
        callOperation("Rollback");
        callOperation("setpBrokerIdNo1");
        
    }
}
