package com.liberty.health.comms.lookup.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;

import org.apache.myfaces.trinidad.context.RequestContext;

public class CountryTaxes extends CoreActions {
    public CountryTaxes() {
        super();
    }


    public void CountrySelected(ValueChangeEvent valueChangeEvent) {
        String countryCode = "";  
        String countryCode1 = "";
        
        RequestContext afContext = RequestContext.getCurrentInstance();
        
        if (valueChangeEvent.getNewValue() != null) {
            countryCode = valueChangeEvent.getNewValue().toString();    
            System.out.println("in the value change listener new val is "+countryCode);
        }
        
        if (valueChangeEvent.getOldValue() != null) {
            countryCode1 = valueChangeEvent.getOldValue().toString();    
            System.out.println("in the value change listener new val is "+countryCode1);
        }
        
        if (countryCode != null) {
            DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
            
            
            DCIteratorBinding iterCountryTax = dcBc.findIteratorBinding("CountryTaxAccredLov1Iterator");
            ViewObject accredLov = iterCountryTax.getViewObject();
             accredLov.ensureVariableManager().setVariableValue("pCountryFilter", countryCode);
             accredLov.executeQuery();
                 
            RowSetIterator rsi = accredLov.createRowSetIterator(null);
            
            
            DCIteratorBinding iterCountryTaxAccr = dcBc.findIteratorBinding("CountryTaxesAccrLov1Iterator");
            ViewObject accrLov = iterCountryTaxAccr.getViewObject();
             accrLov.ensureVariableManager().setVariableValue("pCountryFilter", countryCode);
             accrLov.executeQuery();
             
             accredLov.closeRowSetIterator();
             accrLov.closeRowSetIterator();
             
             //set pageflowscope item
             afContext.getPageFlowScope().put("CountryCode", countryCode);
             
             System.out.println("page flow scope is now "+afContext.getPageFlowScope().get("CountryCode").toString());
            
        }
    }

    public void setEffectiveDates(ActionEvent actionEvent) {
        //add the updating of effective dates
        //need to expose the method on the view object via java class
        callOperation("Commit");
        callOperation("updateEffDates");
    }
}
