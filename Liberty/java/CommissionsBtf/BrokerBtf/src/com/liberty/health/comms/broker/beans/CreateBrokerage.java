package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;

import java.math.BigDecimal;

import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.input.RichSelectBooleanCheckbox;
import oracle.adf.view.rich.component.rich.input.RichSelectOneChoice;
import oracle.adf.view.rich.component.rich.layout.RichPanelLabelAndMessage;
import oracle.adf.view.rich.component.rich.nav.RichButton;

import oracle.adf.view.rich.component.rich.output.RichOutputText;

import oracle.binding.BindingContainer;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaRow;
import oracle.jbo.domain.Timestamp;

public class CreateBrokerage extends CoreActions {
    Integer companyIdNo;
    String countryCode;
    private RichSelectBooleanCheckbox multiNationalInd;
    private RichInputListOfValues currencyCodeInputLov;
    private RichButton addCountryButton;
    Integer companyTableTypeIdNo;
    Timestamp timestamp = new Timestamp(System.currentTimeMillis());
    private String onlyForKE = "Y";
    private RichSelectOneChoice selectedCountry;
    private RichInputText bv_valueToApprove;
    private RichButton bv_savePrefCurrButton;
    private RichPopup bv_prefPopUp;
    private RichInputListOfValues bv_prefCurrCode;
    private RichOutputText bv_compId;


    public CreateBrokerage() {
        super();
    }

    public void createNewRecord(ActionEvent actionEvent) {
        ADFContext adfCtx = ADFContext.getCurrent();
        Map sessionScope = adfCtx.getSessionScope();
        System.out.println("users countryList access is " + sessionScope.get("countryList"));
        String s = sessionScope.get("countryList").toString();
        System.out.println("s: " +s);
        String sArr[] = s.split("[,]",0);
        System.out.println(sArr.length);
        if(s.contains("KE") && sArr.length==1){
            onlyForKE = "Y";
        }
        else{
            onlyForKE = "N";
        }
        System.out.println("onlyForKE: " +onlyForKE);
        callOperation("CreateInsert");
        this.currencyCodeInputLov.setVisible(false);
        this.addCountryButton.setDisabled(false);
    }

   


    public void saveButtonActionListener(ActionEvent actionEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();

        DCIteratorBinding dcIbCompany = dcBc.findIteratorBinding("CaptureCompanyViewIterator");
        Row rowCompany = dcIbCompany.getCurrentRow();

        String multinet = (String) rowCompany.getAttribute("MultinationalInd");
        if (multinet.compareTo("Y") == 0) {
            this.setCompanyTableTypeIdNo(1);
        } else {
            this.setCompanyTableTypeIdNo(2);
        }
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("CaptureCompanyCountryViewIterator");
        Row row = dcIb.getCurrentRow();
        RowSetIterator rsi = dcIb.getViewObject().createRowSetIterator(null);
        if (row == null) {
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please add a country");
            fc.addMessage(null, message);
        } else{
            int noOfRows1 = rsi.getRowCount();
            System.out.println("noOfRows1  "+noOfRows1);
            if(this.chkCountryRestriction()){
                    System.out.println("inside the error msg");
                    FacesMessage message1 = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Entered Country Code KE is not allowed for multinational");
                    fc.addMessage(null, message1);
            }else{
                if(!this.checkMultinationalCondition() && noOfRows1 > 1){
                    System.out.println("inside the checkMultinationalCondition error msg1");
                    FacesMessage message1 = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please checkin Multinational");
                    fc.addMessage(null, message1);
                }else {
                    if (this.checkMaxPayAmt()) {
                        this.currencyCodeInputLov.setVisible(false);
                        this.addCountryButton.setDisabled(true);        
                        companyIdNo = (Integer) row.getAttribute("CompanyIdNo");
                        countryCode = (String) row.getAttribute("CountryCode");
                        System.out.println("CompanyIdNo " + this.getCompanyIdNo() + ", " + row.getAttribute("CompanyIdNo"));
                        System.out.println("CountryCode " + this.getCountryCode() + ", " + row.getAttribute("CountryCode"));
                        callOperation("createCompanyFunction");
                        callOperation("Commit");
                        
                        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                                .getApplication()
                                                                .getNavigationHandler();
                        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "goDetails");
                    } else {
                        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error",
                                                        "The total country minimum pay amount is more than the allowed for a multinational broker. ");
                        fc.addMessage(null, message);
                    }
                }
            }
        }
    }
    
    public boolean checkMultinationalCondition(){
        Boolean multiNetInd = (Boolean) this.getMultiNationalInd().getValue();
        System.out.println("inside the checkMultinationalCondition"+multiNetInd);
        return multiNetInd;
    }


    public boolean chkCountryRestriction(){
        System.out.println("inside the chkCountryRestriction");
        FacesContext fc = FacesContext.getCurrentInstance();
        String mN1 = multiNationalInd.getValue().toString();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        Boolean notAllowed = false;
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("CaptureCompanyCountryViewIterator");
        Row row = dcIb.getCurrentRow();
        RowSetIterator rsi = dcIb.getViewObject().createRowSetIterator(null);
        int noOfRows = rsi.getRowCount();
        System.out.println("chkCountryRestriction, noOfRows  "+noOfRows);
        String countryCodeSelected;
        if(noOfRows > 1){
            while(rsi.hasNext()){
                Row row1 = rsi.next();
                String CountryCode = (String) row1.getAttribute("CountryCode");
                System.out.println("checking the CountryCode  "+CountryCode);
                if (CountryCode.equalsIgnoreCase("KE")) {
                  notAllowed = true;
                }
            }
            rsi.closeRowSetIterator();
        }
       System.out.println("row.getAttribute(\"CountryCode\")  "+row.getAttribute("CountryCode"));
       System.out.println("mN1  "+mN1);
        if(noOfRows == 1 && row.getAttribute("CountryCode").equals("KE") && mN1.equals("true")){
            System.out.println("Inside new condition for multinational and single row KE ");
            multiNationalInd.resetValue();
            System.out.println("Inside new condition for multinational and single row KE, multiNationalInd.getValue().toString()" + multiNationalInd.getValue().toString());
            notAllowed = true;
        }
        System.out.println("notAllowed: "+notAllowed);
        return notAllowed;
    }
    
    public void attributeDetailSaveActionListener(ActionEvent actionEvent) {
        callOperation("Commit");
        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                .getApplication()
                                                .getNavigationHandler();
        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "back");
    }

    public void rollbackActionListener(ActionEvent actionEvent) {
        callOperation("Rollback");
        this.currencyCodeInputLov.setVisible(true);
        this.addCountryButton.setDisabled(true);
    }

    public void setCompanyIdNo(Integer companyIdNo) {
        this.companyIdNo = companyIdNo;
    }

    public Integer getCompanyIdNo() {
        return companyIdNo;
    }

    public void setCountryCode(String countryCode) {
        this.countryCode = countryCode;
    }

    public String getCountryCode() {
        return countryCode;
    }


    public void multiNetValueChangeListener(ValueChangeEvent valueChangeEvent) {
        Boolean condition = false;
        if (valueChangeEvent.getNewValue().equals(condition)) {
            this.currencyCodeInputLov.setVisible(false);
        } else {
            this.currencyCodeInputLov.setVisible(false);
        }
    }

    public void setMultiNationalInd(RichSelectBooleanCheckbox multiNationalInd) {
        this.multiNationalInd = multiNationalInd;
    }

    public RichSelectBooleanCheckbox getMultiNationalInd() {
        return multiNationalInd;
    }

    public void setCurrencyCodeInputLov(RichInputListOfValues currencyCodeInputLov) {
        this.currencyCodeInputLov = currencyCodeInputLov;
    }

    public RichInputListOfValues getCurrencyCodeInputLov() {
        return currencyCodeInputLov;
    }

    public void setAddCountryButton(RichButton addCountryButton) {
        this.addCountryButton = addCountryButton;
    }

    public RichButton getAddCountryButton() {
        return addCountryButton;
    }

    public void save(ActionEvent actionEvent) {
        callOperation("Rollback");
        this.currencyCodeInputLov.setVisible(true);
        this.addCountryButton.setDisabled(true);
    }

    public Integer getTotalCountryPayAmt() {
        Integer totalMinPayAmt = new Integer(0);
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("CaptureCompanyCountryViewIterator");
        RowSetIterator rsi = dcIb.getViewObject().createRowSetIterator(null);
        while (rsi.hasNext()) {
            Row row = rsi.next();
            BigDecimal minPayAmount = (BigDecimal) row.getAttribute("MinPayoutAmt");
            if (minPayAmount != null) {
                totalMinPayAmt = totalMinPayAmt + minPayAmount.intValue();
            }
        }
        rsi.closeRowSetIterator();
        return totalMinPayAmt;
    }

    public Boolean checkMaxPayAmt() {
        Boolean pass = true;
        String sysParam = (String) callOperation("getMaxMultinetAmount");
        Integer maxPayAmt = 0;
        Boolean multiNetInd = (Boolean) this.getMultiNationalInd().getValue();
        FacesContext fc = FacesContext.getCurrentInstance();

        if (multiNetInd) {
            if (sysParam != null) {
                maxPayAmt = Integer.parseInt(sysParam);
                System.out.println("Max pay amount = " + maxPayAmt + " and total country = " +
                                   this.getTotalCountryPayAmt());
                if (maxPayAmt < this.getTotalCountryPayAmt()) {
                    pass = false;
                }
            } else {
                FacesMessage message =
                    new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error",
                                     "The maximum value for multinationals aren't set. Please contact");
                fc.addMessage(null, message);
            }
        }
        return pass;
    }

    public void setCompanyTableTypeIdNo(Integer companyTableTypeIdNo) {
        this.companyTableTypeIdNo = companyTableTypeIdNo;
    }

    public Integer getCompanyTableTypeIdNo() {
        return companyTableTypeIdNo;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    

    

    public void checkBrokerageName(ValueChangeEvent valueChangeEvent) {
        
        FacesContext fc = FacesContext.getCurrentInstance();
        
        System.out.println("in value change event old "+valueChangeEvent.getOldValue());
        System.out.println("in value change event new "+valueChangeEvent.getNewValue());
        
        if (valueChangeEvent.getNewValue() != null) {
                
               System.out.println("in value change event calling setBoundAttributeValue");
                String companyNo = valueChangeEvent.getNewValue().toString();
                ADFUtils.setBoundAttributeValue("pCompanyName1",companyNo);
                
                String possibleMatches = (String) callOperation("checkBrokerageName");

                if (possibleMatches != null) {
        
                    FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Possible Brokerages already exist", possibleMatches);
                    fc.addMessage(null, message);
                }
        }
    }


    public void checkCurrencyChangeAllowed(ValueChangeEvent valueChangeEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        String msg;
        String currencyDifferent = "";
        System.out.println("in value change event old "+valueChangeEvent.getOldValue());
        System.out.println("in value change event new "+valueChangeEvent.getNewValue());
        System.out.println("currencyDifferent "+currencyDifferent);
        if (valueChangeEvent.getNewValue() != null) {      
            ADFUtils.setBoundAttributeValue("preferredCurrencyCode1",valueChangeEvent.getNewValue());
            currencyDifferent = (String) callOperation("CheckPreferredCurrency");
            if (currencyDifferent != null) {
                System.out.println("Finished CheckPref Currency Call" +currencyDifferent);
                System.out.println("Raising the error message");
                msg = "You cannot change the currency broker already paid in "+ currencyDifferent;
                bv_savePrefCurrButton.setDisabled(true);
               System.out.println("Broker already paid in a different currency");
               bv_prefCurrCode.setValue(valueChangeEvent.getOldValue());
               System.out.println("bv_prefCurrCode old value: "+bv_prefCurrCode.getValue());
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", msg );
                System.out.println("showing the message on the screen");
                fc.addMessage(null, message); 
//                callOperation("Rollback");
//                callOperation("Execute");

            }
            else{
                BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
                ViewObject periodVO = ADFUtils.findIterator("Approvals2Iterator").getViewObject();
                Row rowSelected = periodVO.getCurrentRow(); 
                if(rowSelected != null){
                    System.out.println("inside the onclicksave");
                    //String valueToApprove = rowSelected.getAttribute("ValueToApprove").toString();
                    rowSelected.setAttribute("ApprovalUser", null);
                    rowSelected.setAttribute("RejectUser", null);
                    rowSelected.setAttribute("Responded", null);
                }
                callOperation("Commit");
            }
        }
    }

    public void setOnlyForKE(String onlyForKE) {
        this.onlyForKE = onlyForKE;
    }

    public String getOnlyForKE() {
        return onlyForKE;
    }

    public void setSelectedCountry(RichSelectOneChoice selectedCountry) {
        this.selectedCountry = selectedCountry;
    }

    public RichSelectOneChoice getSelectedCountry() {
        return selectedCountry;
    }

    public void onChangeCountry(ValueChangeEvent valueChangeEvent) {
        System.out.println("selectedCountry: "+selectedCountry.getValue().toString());
        String selectedCountryValue = selectedCountry.getValue().toString();
        FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcIb = dcBc.findIteratorBinding("CaptureCompanyCountryViewIterator");
        RowSetIterator rsi1 = dcIb.getViewObject().createRowSetIterator(null);
        Row row = dcIb.getCurrentRow();
        if(row!=null && rsi1.getRowCount() >=1 && selectedCountryValue.equalsIgnoreCase("KE") && selectedCountryValue.equalsIgnoreCase("Kenya")){
            System.out.println("inside selected country: ");
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","The selected country is not allowed for multinational");
            fc.addMessage(null, message);    
        }
    }

    public void setBv_valueToApprove(RichInputText bv_valueToApprove) {
        this.bv_valueToApprove = bv_valueToApprove;
    }

    public RichInputText getBv_valueToApprove() {
        return bv_valueToApprove;
    }

    public void onClickSavePrefCurrCode(ActionEvent actionEvent) {
        System.out.println("opened");
        callOperation("Commit");
        callOperation("Execute");
        bv_prefPopUp.hide();
        System.out.println("closed");
        this.getBv_prefPopUp().hide();
    }

    public void setBv_savePrefCurrButton(RichButton bv_savePrefCurrButton) {
        this.bv_savePrefCurrButton = bv_savePrefCurrButton;
    }

    public RichButton getBv_savePrefCurrButton() {
        return bv_savePrefCurrButton;
        
    }

    public void setBv_prefPopUp(RichPopup bv_prefPopUp) {
        this.bv_prefPopUp = bv_prefPopUp;
    }

    public RichPopup getBv_prefPopUp() {
        return bv_prefPopUp;
    }

    public void setBv_prefCurrCode(RichInputListOfValues bv_prefCurrCode) {
        this.bv_prefCurrCode = bv_prefCurrCode;
    }

    public RichInputListOfValues getBv_prefCurrCode() {
        return bv_prefCurrCode;
    }

    public void setBv_compId(RichOutputText bv_compId) {
        this.bv_compId = bv_compId;
    }

    public RichOutputText getBv_compId() {
        return bv_compId;
    }

   
}
