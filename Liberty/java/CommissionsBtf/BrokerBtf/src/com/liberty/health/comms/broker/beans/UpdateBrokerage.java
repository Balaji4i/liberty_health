package com.liberty.health.comms.broker.beans;

import com.core.utils.DateUtils;
import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;



import oracle.jbo.domain.Date;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichSelectBooleanCheckbox;
import oracle.adf.view.rich.component.rich.nav.RichButton;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.domain.Timestamp;

import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import java.sql.SQLException;


public class UpdateBrokerage extends CoreActions {
    private RichInputListOfValues bv_enteredCountryCode;

    public UpdateBrokerage() {
        super();
    }
    
    //t.percy validation for the adding of another country to a local brokerage i.e. not a multinational - do not allow if an existing country is added to the country 
       // ask them to end date all other countries before adding a new country with the effective start date of current date or greater
       
       public void addCountryToBrokerage(ActionEvent actionEvent) {
           BindingContext bindingContext = BindingContext.getCurrent(); 
           FacesContext fc = FacesContext.getCurrentInstance();
           DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
           String selectedCountryCodeText = bv_enteredCountryCode.getValue().toString();           
           System.out.println("updateBrokerage, selectedCountryCodeText: "+selectedCountryCodeText);
           
           //if the add button for the country has been selected the bound variable value will be Y only fire the validation in that case otherwise it means existing
           //records are being updated in which case we do not want to fire the validation
           //System.out.println("the save button has been selected "+ADFUtils.getBoundAttributeValue("addCountry1").toString());
           if(selectedCountryCodeText.equalsIgnoreCase("KE")){
               FacesMessage message1 = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Entered Country Code KE is not allowed for multinational");
               fc.addMessage(null, message1);
           }else{
               if (ADFUtils.getBoundAttributeValue("addCountry1") != null && ADFUtils.getBoundAttributeValue("addCountry1").toString().equals("Y"))
               {
                   DCIteratorBinding dcIbCompany = dcBc.findIteratorBinding("CompanyByPkViewIterator");
                   Row rowCompany = dcIbCompany.getCurrentRow();    
                   System.out.println("calling checking Multinational stored proc from AM module");                   
                   /* get the multinational indicator as now stored on attribute level*/
                   String MultiInd     = (String) callOperation("CheckMultinational");
                   Integer companyId   = (Integer) rowCompany.getAttribute("CompanyIdNo");
                   String validInsert  = "Y";
                   Date currDate       = DateUtils.currentDateTruncated();
                   
                   //next get the country being added
                   DCIteratorBinding CompCountry = dcBc.findIteratorBinding("CompanyCountryByCompanyViewIterator");
                   Row rowCountry                = CompCountry.getCurrentRow();
                   String compCountry            = (String) rowCountry.getAttribute("CountryCode");
                   RowSetIterator rsi1 = CompCountry.getViewObject().createRowSetIterator(null);
                   
                   
                   int noOfRows2 = rsi1.getRowCount();
                   System.out.println("noOfRows2: "+noOfRows2);
                   if(noOfRows2 > 2){
                       System.out.println("inide noOfRows2: ");
                       MultiInd = "Y";
                   }
                   
                   System.out.println("companyId is - "+companyId);
                   System.out.println("MultiInd is - "+MultiInd);
                   System.out.println("currdate is - "+currDate);
                
                   /**
                    * if the brokerage is not a multinational then you cannot add another country 
                    * until all other country records are end dated
                    */
                   if (MultiInd.toString().equals("N") && MultiInd.toString() != null) {
                       System.out.println("In The MultiInd check value is"+MultiInd);
                       DCIteratorBinding cdBrokCountry = dcBc.findIteratorBinding("CompanyCountryByCompanyViewIterator");
                       RowSetIterator rsi = cdBrokCountry.getViewObject().createRowSetIterator(null);
                       while (rsi.hasNext()) {
                           Row row = rsi.next();
                           Date effEndDate = (Date) row.getAttribute("EffectiveEndDate");
                           String PrevCountry = (String) row.getAttribute("CountryCode");
                           
                           java.sql.Date newEffDate  = effEndDate.dateValue();
                           java.sql.Date newCurrDate = currDate.dateValue(); 
                           
                           System.out.println("checking the effective end date "+effEndDate);
                           
                           if (PrevCountry.toString().equals(compCountry)) {
                              System.out.println("current record insert do not validate against "+PrevCountry); 
                              System.out.println("current record insert do not validate against "+compCountry); 
                           } else
                           {                       
                               if (newEffDate.after(newCurrDate) || newEffDate.equals(newCurrDate) ){
                                   validInsert = "N";
                                   FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please ensure all other country records are end dated before adding another operating country, as this brokerage is not a multinational");
                                   fc.addMessage(null, message); 
                                   break; //on first error exit the while loop
                               }
                           }
               
                       }
                       rsi.closeRowSetIterator();
                       
                   }
                   System.out.println("validInsert - "+validInsert);
                   if (validInsert == "Y") {
                           System.out.println("this commit 1111");
                           callOperation("Commit");
                       }
                   
               } else {
                   System.out.println("this commit 2222");
                   callOperation("Commit");
               }
           }
       }

    public String setAddCountry() {
        System.out.println("the add button has been selected");
        ADFUtils.setBoundAttributeValue("addCountry1", "Y");
        return null;
    }
    
    public String setCancelCountry() {
        System.out.println("the cancel button has been selected");
        ADFUtils.setBoundAttributeValue("addCountry1", "N");
        return null;
    }

    public void enteredCountryCode(ValueChangeEvent valueChangeEvent) {
        String enteredCountryCodeText = bv_enteredCountryCode.getValue().toString();
        System.out.println("Country code entered inside the current details tab: "+enteredCountryCodeText);    
        FacesContext fc = FacesContext.getCurrentInstance();
        if(enteredCountryCodeText.equalsIgnoreCase("KE")){
            bv_enteredCountryCode.resetValue();
            FacesMessage message2 = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Entered country code KE does not allow multinational.");
            fc.addMessage(null, message2); 
        }
    }

    public void setBv_enteredCountryCode(RichInputListOfValues bv_enteredCountryCode) {
        this.bv_enteredCountryCode = bv_enteredCountryCode;
    }

    public RichInputListOfValues getBv_enteredCountryCode() {
        return bv_enteredCountryCode;
    }

    public void onClickAddButton(ActionEvent actionEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        String MultiInd     = (String) callOperation("CheckMultinational");
        System.out.println("the add button has been selected: MultiInd"+MultiInd);
        if (MultiInd.toString().equals("N") && MultiInd.toString() != null) {
            System.out.println("ADD: In The MultiInd check value is"+MultiInd);
            FacesMessage message2 = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please ensure all other country records are end dated before adding another operating country, as this brokerage is not a multinational");
            fc.addMessage(null, message2); 
        }
        else{
            ADFUtils.setBoundAttributeValue("addCountry1", "Y");
            callOperation("CreateWithParams");
        }
    }

    public void onClickSaveButton(ActionEvent actionEvent) {
        callOperation("Commit");
    }
}
