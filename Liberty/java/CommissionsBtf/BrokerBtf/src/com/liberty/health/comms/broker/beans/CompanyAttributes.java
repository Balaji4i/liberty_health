package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;
import com.core.utils.DateUtils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import oracle.adf.view.rich.context.AdfFacesContext;
import java.util.Date;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.input.RichInputDate;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.output.RichOutputText;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupCanceledEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.binding.AttributeBinding;
import oracle.binding.BindingContainer;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;
import oracle.jbo.domain.Timestamp;

public class CompanyAttributes extends CoreActions {
    String commentDesc;
    private RichInputText commentDescInputTextBox;
    oracle.jbo.domain.Date currentDate = DateUtils.currentDateTruncated();
    java.util.Date minDatePickerDate = DateUtils.currentUtilDateTruncated();
    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    Timestamp maxLibertyDateTime = DateUtils.getLibertyMaxDatetime();
    private RichSelectOneChoice accredType;
    private RichInputDate effecStartDate;
    private RichOutputText countryCode;
    private RichInputDate bv_effStartDate;
    private RichInputDate bv_effEndDate;
    private RichInputDate bv_AccStartDate;
    private RichInputDate bv_accEndDate;
    private RichSelectOneChoice bv_AccTypeIdNo;
    private RichInputDate bvc_effStartDate;
    private RichTable bv_table;

    public CompanyAttributes() {
        super();
    }

    public void statusPopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateStatus");
    }

    public void statementPopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateStatement");
    }

    public void typePopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateType");
    }

    public void functionPopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("CreateFunction");
    }

    public void popUpCancelListener(PopupCanceledEvent popupCanceledEvent) {
        callOperation("Rollback");
    }

    public void setCommentDesc(String commentDesc) {

        this.commentDesc = commentDesc;
    }

    public String getCommentDesc() {
        return commentDesc;
    }

  

    public void popUpDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("createBrokerComment");
            callOperation("updateEffDates");
            //callOperation("Commi");
            commentDescInputTextBox.setValue(null);
        }
    }

    public void functionPopUpDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("createBrokerComment");
            callOperation("updateEffFunctionDates");
            //callOperation("Commi");
            commentDescInputTextBox.setValue(null);
        }
    }

    public void statementPopUpDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("createBrokerComment");
            callOperation("updateEffStatementDates");
            //callOperation("Commi");
            commentDescInputTextBox.setValue(null);
        }
    }

    public void statusPopUpDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("createBrokerComment");
            callOperation("updateEffStatusDates");
            //callOperation("Commi");
            commentDescInputTextBox.setValue(null);
        }
    }

    public void typePopUpDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            callOperation("createBrokerComment");
            callOperation("updateEffTypeDates");
            //callOperation("Commi");
            commentDescInputTextBox.setValue(null);
        }
    }

    public void setCommentDescInputTextBox(RichInputText commentDescInputTextBox) {
        this.commentDescInputTextBox = commentDescInputTextBox;
    }

    public RichInputText getCommentDescInputTextBox() {
        return commentDescInputTextBox;
    }

    public void commentDescValueChangeListener(ValueChangeEvent valueChangeEvent) {
        this.setCommentDesc(commentDescInputTextBox.getValue().toString());
    }

    public void saveAndEffectiveDateActionListener(ActionEvent e) {
            callOperation("Commit");
            callOperation("updateEffDates");
        }
    /**
     *
     * T.Percy added this section to seperate off the contact correspondencd
     * information
     */
    
    public void saveAndEffectiveDateContactCorr(ActionEvent e) {
        callOperation("Commit1");
        callOperation("updateCorrEffDates");
        callOperation("Commit1");
    }

    public void saveAndEffectiveDateActionFunctionListener(ActionEvent e) {
        if (this.getCommentDesc() != null) {
            callOperation("createComment");
        }
        callOperation("Commit");
        callOperation("updateEffDates");
        this.setCommentDesc(null);
        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                .getApplication()
                                                .getNavigationHandler();
        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "goExecute");
    }
    
    //T.Percy LS-1373
    public void saveCorrEffectiveDateActionListener(ActionEvent e) {
            System.out.println("In Save Corr Effective Dates");
            BindingContainer bindings = (BindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
            // get an ADF attributevalue from the ADF page definitions
            AttributeBinding attr = (AttributeBinding) bindings.getControlBinding("CompanyIdNo");
            if (attr != null) {
                
            }
            callOperation("Commit1");
            callOperation("updateCorrEffDates");
        }
    //END T.Percy LS-1373
    
    public void saveBrokerEffectiveDateActionFunctionListener(ActionEvent e) {
        if (this.getCommentDesc() != null) {
            callOperation("createComment");
        }
        callOperation("Commit");
        callOperation("updateEffDates");
        System.out.println("Calling update EffDates");
        this.setCommentDesc(null);
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

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public String callCommunicationHub() {
        String link = null;
        String server = (String) callOperation("getCommunicationHubLink");
        String brokerageCode = "0";
        BindingContainer bindings = (BindingContainer) BindingContext.getCurrent().getCurrentBindingsEntry();
        // get an ADF attributevalue from the ADF page definitions
        AttributeBinding attr = (AttributeBinding) bindings.getControlBinding("CompanyIdNo");
        if (attr != null) {
            brokerageCode = attr.getInputValue().toString();
        }
        link = server + "pEntityType=BR&pEntityNo=" + brokerageCode;
        return link;
    }


    public String getLinkWithParams() {
        String base = this.callCommunicationHub();
        return base;
    }

    public void setMaxLibertyDateTime(Timestamp maxLibertyDateTime) {
        this.maxLibertyDateTime = maxLibertyDateTime;
    }

    public Timestamp getMaxLibertyDateTime() {
        return maxLibertyDateTime;
    }

    public void setAccredType(RichSelectOneChoice accredType) {
        this.accredType = accredType;
    }

    public RichSelectOneChoice getAccredType() {
        return accredType;
    }

    public void setEffecStartDate(RichInputDate effecStartDate) {
        this.effecStartDate = effecStartDate;
    }

    public RichInputDate getEffecStartDate() {
        return effecStartDate;
    }

    public void setCountryCode(RichOutputText countryCode) {
        this.countryCode = countryCode;
    }

    public RichOutputText getCountryCode() {
        return countryCode;
    }

    public void setBv_effStartDate(RichInputDate bv_effStartDate) {
        this.bv_effStartDate = bv_effStartDate;
    }

    public RichInputDate getBv_effStartDate() {
        return bv_effStartDate;
    }

    public void setBv_effEndDate(RichInputDate bv_effEndDate) {
        this.bv_effEndDate = bv_effEndDate;
    }

    public RichInputDate getBv_effEndDate() {
        return bv_effEndDate;
    }

    public void setBv_AccStartDate(RichInputDate bv_AccStartDate) {
        this.bv_AccStartDate = bv_AccStartDate;
    }

    public RichInputDate getBv_AccStartDate() {
        return bv_AccStartDate;
    }

    public void setBv_accEndDate(RichInputDate bv_accEndDate) {
        this.bv_accEndDate = bv_accEndDate;
    }

    public RichInputDate getBv_accEndDate() {
        return bv_accEndDate;
    }

    public void onChangeAccEndDate(ValueChangeEvent valueChangeEvent) { 
        valueChangeEvent.getComponent().processUpdates(FacesContext.getCurrentInstance());
        System.out.println("iNSIDE onChange End DATE");
        ViewObject periodVO = ADFUtils.findIterator("CompanyAccreditationByPkViewIterator").getViewObject();
        Row currentRow = periodVO.getCurrentRow();
        RowSetIterator rs = periodVO.createRowSetIterator(null);
        String AccEndDate = "";
        SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy");
        DateFormat formatterr = new SimpleDateFormat("dd-MM-yyyy");
        if (currentRow != null && currentRow.getAttribute("CompanyAccredStartDate") == null) {
            //JSFUtils.addFacesErrorMessage("Please Select Available Start Date");
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","Please select available Start Date");
            FacesContext fc = FacesContext.getCurrentInstance();
            fc.addMessage(null, message);
            currentRow.setAttribute("CompanyAccredEndDate", "");
            currentRow.setAttribute("CompanyAccredEndDate", null);
        }
        else{   
            if(currentRow.getAttribute("CompanyAccredEndDate") != null) {
            System.out.println("currentRow.getAttribute(\"companyAccredEndDate\"): "+currentRow.getAttribute("CompanyAccredEndDate"));
            oracle.jbo.domain.Date currentcompanyAccredEndDate = (oracle.jbo.domain.Date) currentRow.getAttribute("CompanyAccredEndDate");
            java.sql.Date currentcompanyAccredEndDate1  = currentcompanyAccredEndDate.dateValue();
            AccEndDate = formatterr.format(currentcompanyAccredEndDate1);
            try{
                Date AccEndDateSet = formatter.parse(AccEndDate);
                currentRow.setAttribute("EffectiveEndDate" , AccEndDateSet);
                }
                catch(Exception e){
                }
            
            }

        }
    }

    public void setBv_AccTypeIdNo(RichSelectOneChoice bv_AccTypeIdNo) {
        this.bv_AccTypeIdNo = bv_AccTypeIdNo;
    }

    public RichSelectOneChoice getBv_AccTypeIdNo() {
        return bv_AccTypeIdNo;
    }

    public void onChangeAccStartDate(ValueChangeEvent valueChangeEvent) {

    }

    public void saveAndEffectiveDateForAccred(ActionEvent actionEvent) {
        System.out.println("iNSIDE onChange Start DATE");
        ViewObject periodVO = ADFUtils.findIterator("CompanyAccreditationByPkViewIterator").getViewObject();
        Row currentRow = periodVO.getCurrentRow();
        RowSetIterator rs = periodVO.createRowSetIterator(null);
        int rowCount = rs.getRowCount();
        System.out.println("rowCount: "+rowCount);
        String effstartDate = "";
        String accreditationType="";
        String tempDate="00-00-0000";
        String AccStartDate = "";
        int whileCount =1;
        int count=0;
        SimpleDateFormat formatter = new SimpleDateFormat("dd-MM-yyyy");
        DateFormat formatterr = new SimpleDateFormat("dd-MM-yyyy");
        if (currentRow.getAttribute("CompanyAccredStartDate") != null) {
            System.out.println("currentRow.getAttribute(\"companyAccredStartDate\"): "+currentRow.getAttribute("CompanyAccredStartDate"));
            oracle.jbo.domain.Date currentEffStartDate = (oracle.jbo.domain.Date) currentRow.getAttribute("CompanyAccredStartDate");
            java.sql.Date currentEffStartDate1  = currentEffStartDate.dateValue();
            effstartDate = formatterr.format(currentEffStartDate1);
        }
        if(currentRow.getAttribute("AccreditationTypeIdNo") != null) {
                accreditationType = currentRow.getAttribute("AccreditationTypeIdNo").toString();
                System.out.println("accreditationType: "+accreditationType);
        }
        while (rs.hasNext()) {
            System.out.println("whileCount: "+whileCount);
            whileCount++;
            Row r = rs.next();
            String startDate = "";
            String endDate = "";
            String effecstartDate = "";
            String effendDate = "";
            System.out.println("row.AccreditationTypeIdNo: "+r.getAttribute("AccreditationTypeIdNo"));
            if(accreditationType.equalsIgnoreCase(r.getAttribute("AccreditationTypeIdNo").toString())){
                if (r.getAttribute("CompanyAccredStartDate") != null) {
                    oracle.jbo.domain.Date stdate = (oracle.jbo.domain.Date) r.getAttribute("CompanyAccredStartDate");
                    System.out.println("stdate: "+stdate);
                    java.sql.Date stdate1  = stdate.dateValue();
                    startDate = formatterr.format(stdate1);
                    System.out.println("startDate: "+startDate);
                }
                if (r.getAttribute("CompanyAccredEndDate") != null) {
                    oracle.jbo.domain.Date edate = (oracle.jbo.domain.Date) r.getAttribute("CompanyAccredEndDate");
                    System.out.println("edate: "+edate);
                    java.sql.Date edate1  = edate.dateValue();
                    endDate = formatterr.format(edate1);
                    System.out.println("endDate: "+endDate);
                }
                if (r.getAttribute("EffectiveStartDate") != null) {
                    oracle.jbo.domain.Date effecstdate = (oracle.jbo.domain.Date) r.getAttribute("EffectiveStartDate");
                    System.out.println("effecstdate: "+effecstdate);
                    java.sql.Date effecstdate1  = effecstdate.dateValue();
                    effecstartDate = formatterr.format(effecstdate1);
                    System.out.println("effecstartDate: "+effecstartDate);
                }
                if (r.getAttribute("EffectiveEndDate") != null) {
                    oracle.jbo.domain.Date effedate = (oracle.jbo.domain.Date) r.getAttribute("EffectiveEndDate");
                    System.out.println("effedate: "+effedate);
                    java.sql.Date effedate1  = effedate.dateValue();
                    effendDate = formatterr.format(effedate1);
                    System.out.println("effendDate: "+effendDate);
                }
                System.out.println("insdie try block startDate: "+startDate);
                try {
                    System.out.println("indde try block");
                    Date companyAccredStartDate = formatter.parse(startDate);
                    Date companyAccredEndDate = formatter.parse(endDate);
                    Date currEffStartDate = formatter.parse(effstartDate);
                    Date tempDate2 = formatter.parse(tempDate);
                    System.out.println("currEffStartDate--------" + currEffStartDate);
                    System.out.println("companyAccredStartDate--------" + companyAccredStartDate);
                    System.out.println("companyAccredEndDate--------" + companyAccredEndDate);
                    if(count!=0){
                        if (( (r.getAttribute("CompanyAccredStartDate") != null && r.getAttribute("CompanyAccredEndDate") != null) 
                              && ( ((currEffStartDate).compareTo(companyAccredStartDate) > 0 &&
                                    (currEffStartDate).compareTo(companyAccredEndDate) < 0)||
                                    ((currEffStartDate).compareTo(companyAccredStartDate) < 0  &&
                                    (currEffStartDate).compareTo(companyAccredStartDate) != 0) ) 
                              )){
                           System.err.println("Current Start date is greater than Start date");
                            //JSFUtils.addFacesErrorMessage("Entered Available Start date is already Subscribed");
                            if(tempDate2.before(companyAccredEndDate)){
                                tempDate2 = companyAccredEndDate;
                                tempDate = tempDate2.toString();
                                System.err.println("tempDate: "+tempDate);
                                System.err.println("true");
                            }
                            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","Entered start date is already available.");
                            FacesContext fc = FacesContext.getCurrentInstance();
                            fc.addMessage(null, message); 
                            currentRow.setAttribute("CompanyAccredStartDate", "");
                            currentRow.setAttribute("CompanyAccredEndDate", "");
                            currentRow.setAttribute("CompanyAccredStartDate", null);
                            currentRow.setAttribute("CompanyAccredEndDate", null);
                        }
                    }
                }
                    catch (Exception exe) {
                        System.out.println("catched");    
                }
//                try{
//                    Date effectiveStartDate= formatter.parse(effecstartDate);
//                    Date effectiveEndDate = formatter.parse(effendDate);
//                    Date currEffStartDate = formatter.parse(effstartDate);
//                    System.out.println("effectiveStartDate--------" + effectiveStartDate);
//                    System.out.println("effectiveEndDate--------" + effectiveEndDate);
//                    System.out.println("(currEffStartDate).compareTo(effectiveStartDate)--------" + (currEffStartDate).compareTo(effectiveStartDate));
//                    System.out.println("(currEffStartDate).compareTo(effectiveEndDate)--------" + (currEffStartDate).compareTo(effectiveEndDate));
//                    System.out.println("count insde e2nd "+count);
//                    if( count!=0 && (r.getAttribute("CompanyAccredStartDate") == null && r.getAttribute("CompanyAccredEndDate") == null) 
//                                 &&( ((currEffStartDate).compareTo(effectiveStartDate) > 0 &&
//                                    (currEffStartDate).compareTo(effectiveEndDate) < 0)||
//                                    ((currEffStartDate).compareTo(effectiveStartDate) < 0  &&
//                                    (currEffStartDate).compareTo(effectiveStartDate) != 0) )){
//                        System.out.println("insdie second if");
//                        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","Entered start date is already available.");
//                        FacesContext fc = FacesContext.getCurrentInstance();
//                        fc.addMessage(null, message); 
//                        currentRow.setAttribute("CompanyAccredStartDate", "");
//                        currentRow.setAttribute("CompanyAccredEndDate", "");
//                        currentRow.setAttribute("CompanyAccredStartDate", null);
//                        currentRow.setAttribute("CompanyAccredEndDate", null);    
//                    }
//                }
//                catch(Exception exc1){  
//                    System.out.println("catched 2"); 
//                } 
            }
        count++;
        }
        rs.closeRowSetIterator();   
        if(currentRow.getAttribute("CompanyAccredStartDate") != null) {
            System.out.println("currentRow.getAttribute(\"CompanyAccredStartDate1\"): "+currentRow.getAttribute("CompanyAccredStartDate"));
            oracle.jbo.domain.Date currentcompanyAccredStartDate = (oracle.jbo.domain.Date) currentRow.getAttribute("CompanyAccredStartDate");
            java.sql.Date currentcompanyAccredStartDate1  = currentcompanyAccredStartDate.dateValue();
            AccStartDate = formatterr.format(currentcompanyAccredStartDate1);
            try{
                Date AccStartDateSet = formatter.parse(AccStartDate);
                currentRow.setAttribute("EffectiveStartDate" , AccStartDateSet);
                System.out.println("currentRow.getAttribute(\"EffectiveStartDate\"): "+currentRow.getAttribute("EffectiveStartDate"));
                bvc_effStartDate.setValue(currentRow.getAttribute("EffectiveStartDate"));
            }
            catch(Exception exe) {
            }
        }
        callOperation("Commit");
        callOperation("Execute");
        AdfFacesContext.getCurrentInstance().addPartialTarget(this.getBv_table());

    }

    public void setBvc_effStartDate(RichInputDate bvc_effStartDate) {
        this.bvc_effStartDate = bvc_effStartDate;
    }

    public RichInputDate getBvc_effStartDate() {
        return bvc_effStartDate;
    }

    public void setBv_table(RichTable bv_table) {
        this.bv_table = bv_table;
    }

    public RichTable getBv_table() {
        return bv_table;
    }
}
