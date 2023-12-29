package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;
import java.lang.Math;
import com.core.utils.ADFUtils;

import com.core.utils.DateUtils;

import com.sun.org.apache.xalan.internal.xsltc.runtime.Operators;

import com.tangosol.coherence.dslquery.operator.BetweenOperator;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import java.util.Map;

import javax.el.ELContext;

import javax.el.ExpressionFactory;

import javax.el.MethodExpression;

import javax.faces.application.Application;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.input.RichInputDate;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.layout.RichPanelFormLayout;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.event.QueryEvent;

import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.AttributeDescriptor;
import oracle.adf.view.rich.model.ConjunctionCriterion;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.QueryDescriptor;

import oracle.binding.BindingContainer;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;

import oracle.jbo.ViewCriteriaRow;
import oracle.jbo.ViewObject;
import oracle.jbo.uicli.binding.JUSearchBindingCustomizer;

import org.apache.myfaces.trinidad.event.DisclosureEvent;

public class Payments extends CoreActions {
    private RichInputListOfValues bv_compId;
    oracle.jbo.domain.Date currentDate = DateUtils.currentDateTruncated();
    private RichPanelFormLayout bv_form;
    private RichInputText bv_currCode;
    private RichInputText bv_compIdEmpty;
    private RichInputText bv_paymentExchRate;
    private RichInputText bv_feeTypeAmt;
    private RichInputText bv_feeTypeExchAmt;
    FacesContext fc = FacesContext.getCurrentInstance();
    private RichInputListOfValues bv_compIdLov;
    private RichInputListOfValues bv_countryCode;
    private RichInputText bv_releaseHoldReason;
    private RichInputText bv_reason4Adjust;
    private RichPanelFormLayout bvForm;
    private RichInputText ss_compId;
    private RichInputText ss_erCurrCode;
    private RichInputText ss_payCurrCode;
    private RichInputText ss_countryCode;
    private RichInputText bv_invNo;
    private RichInputText ss_invNo;
    private RichInputText ss_brokerCurr;
    private RichInputText ss_localCurr;
    private RichInputText ss_exchRate;
    private RichButton bv_saveButon;

    public Payments() {
        super();
    }


    public void setBv_currCode(RichInputText bv_currCode) {
        this.bv_currCode = bv_currCode;
    }

    public RichInputText getBv_currCode() {
        return bv_currCode;
    }

    public void setBv_compIdEmpty(RichInputText bv_compIdEmpty) {
        this.bv_compIdEmpty = bv_compIdEmpty;
    }

    public RichInputText getBv_compIdEmpty() {
        return bv_compIdEmpty;
    }

    

    public void setBv_paymentExchRate(RichInputText bv_paymentExchRate) {
        this.bv_paymentExchRate = bv_paymentExchRate;
    }

    public RichInputText getBv_paymentExchRate() {
        return bv_paymentExchRate;
    }

    public void setBv_feeTypeAmt(RichInputText bv_feeTypeAmt) {
        this.bv_feeTypeAmt = bv_feeTypeAmt;
    }

    public RichInputText getBv_feeTypeAmt() {
        return bv_feeTypeAmt;
    }

    public void setBv_feeTypeExchAmt(RichInputText bv_feeTypeExchAmt) {
        this.bv_feeTypeExchAmt = bv_feeTypeExchAmt;
    }

    public RichInputText getBv_feeTypeExchAmt() {
        return bv_feeTypeExchAmt;
    }

    public void setBv_compIdLov(RichInputListOfValues bv_compIdLov) {
        this.bv_compIdLov = bv_compIdLov;
    }

    public RichInputListOfValues getBv_compIdLov() {
        return bv_compIdLov;
    }
    
    public void setBv_countryCode(RichInputListOfValues bv_countryCode) {
        this.bv_countryCode = bv_countryCode;
    }

    public RichInputListOfValues getBv_countryCode() {
        return bv_countryCode;
    }
    
    public void setBv_compId(RichInputListOfValues bv_compId) {
        this.bv_compId = bv_compId;
    }

    public RichInputListOfValues getBv_compId() {
        return bv_compId;
    }

    public void setBv_form(RichPanelFormLayout bv_form) {
        this.bv_form = bv_form;
    }

    public RichPanelFormLayout getBv_form() {
        return bv_form;
    }
    
    private Object processMethodExpression(String methodExpression, Object[] parameters, Class[] expectedParamTypes) { 
        FacesContext fctx = FacesContext.getCurrentInstance(); 
        ELContext elctx = fctx.getELContext(); 
        Application app = fctx.getApplication(); 
        ExpressionFactory exprFactory = app.getExpressionFactory(); 
        MethodExpression methodExpr = exprFactory.createMethodExpression(elctx,
        methodExpression, Object.class, expectedParamTypes); 
        return methodExpr.invoke(elctx, parameters); 
    }

    public void processQuery(QueryEvent queryEvent) {
        
         System.out.println("in the query event process");
         String mexpr           = "#{bindings.SearchInvoiceVOCriteriaQuery.processQuery}";
         String countryCode     = "";
         oracle.jbo.domain.Number companyIdNo;
         String companyName     = "";
         String paymentDate     = "";
         Integer invoiceTypeId;   
         String attributeName   = "";
         Date effectiveFromDate = new Date();
         Date effectiveToDate   = new Date();
         
         System.out.println("in queryEvent");
         
         QueryDescriptor qd = queryEvent.getDescriptor();

         ConjunctionCriterion conCrit = qd.getConjunctionCriterion();
         List<Criterion> criterionList = conCrit.getCriterionList();

         for (Criterion criterion : criterionList) {
              AttributeDescriptor attrDescriptor = ((AttributeCriterion)criterion).getAttribute();
              System.out.println("name is before get value "+attrDescriptor.getName());
             
             if (attrDescriptor.getName().equalsIgnoreCase("CountryCode")){
                 
                  countryCode = (String)((AttributeCriterion)criterion).getValues().get(0);
                  
                  if(countryCode != null) {
                      ADFUtils.setBoundAttributeValue("countryCodeWht1", countryCode);
                  }
                  
             }
             if (attrDescriptor.getName().equalsIgnoreCase("CompanyIdNo")){
                 
                companyIdNo = (oracle.jbo.domain.Number)((AttributeCriterion)criterion).getValues().get(0);
                if (companyIdNo != null) {    
                     System.out.println("company id no is "+companyIdNo);
                     System.out.println("setting the companyIdNoWht1 value "+companyIdNo);
                     ADFUtils.setBoundAttributeValue("companyIdNoWht1", companyIdNo.stringValue());
                     System.out.println("after setting the companyIdNoWht1 value "+companyIdNo);
                 }
                      
             }
             
             if (attrDescriptor.getName().equalsIgnoreCase("CompanyName")){
                               
                 companyName = (String)((AttributeCriterion)criterion).getValues().get(0);
                           
                 if(companyName != null) {
                    ADFUtils.setBoundAttributeValue("companyNameWht1", companyName);
                 }
             }
          /*   if (attrDescriptor.getName().equalsIgnoreCase("PaymentDate")){
                                        
                 // Checking whether it is advanced mode
                // if (qd.getUIHints().get(QueryDescriptor.UIHINT_MODE).equals(QueryDescriptor.QueryMode.ADVANCED)) {
                                 
                   Map<AttributeCriterion, AttributeDescriptor.Operator> changedAttrs = new HashMap<AttributeCriterion, AttributeDescriptor.Operator>();
                    AttributeCriterion ac = (AttributeCriterion) criterion;
                    AttributeDescriptor.Operator operator = ac.getOperator();
                    System.out.println("the operator is "+operator.getValue().toString());
                    if ("BETWEEN".equalsIgnoreCase(operator.getValue().toString())) {
                        oracle.jbo.domain.Date effFromDate1 = (oracle.jbo.domain.Date) ((AttributeCriterion) criterion).getValues().get(0);

                         if (null != effFromDate1) {
                                         
                            effectiveFromDate = effFromDate1.getValue();
                         }


                         oracle.jbo.domain.Date effToDate1 = (oracle.jbo.domain.Date) ((AttributeCriterion) criterion).getValues().get(1);

                         if (null != effToDate1) {
                                         
                            effectiveToDate = effToDate1.getValue();
                         }
                             ADFUtils.setBoundAttributeValue("paymentDateWhtFrom1", effectiveFromDate);
                             ADFUtils.setBoundAttributeValue("paymentDateWhtTo1", effectiveToDate);
                         } else {
                           oracle.jbo.domain.Date effFromDate1 = (oracle.jbo.domain.Date) ((AttributeCriterion) criterion).getValues().get(0);

                           if (null != effFromDate1) {
                                         
                               effectiveFromDate = effFromDate1.getValue();
                               ADFUtils.setBoundAttributeValue("paymentDateWhtFrom1", effectiveFromDate);
                           }
                           }

                      
                        // }
                  } */
            
                  
                  if (attrDescriptor.getName().equalsIgnoreCase("InvoiceTypeIdNo")){
                                        
                     invoiceTypeId = (Integer)((AttributeCriterion)criterion).getValues().get(0);
                                    
                     if(invoiceTypeId != null) {
                        ADFUtils.setBoundAttributeValue("invoiceTypeIdWht1", invoiceTypeId);
                     } 
                  }
               
                             
                  }
              
                  callOperation("setCriteriaParms");
                  
                  processMethodExpression(mexpr, new Object[] {queryEvent}, new Class[] {QueryEvent.class}); 
                  
                 
                  
                  
              }


    public void filterDates(ActionEvent actionEvent) {
        //get all the bound variables and call the operation binding
        callOperation("setCriteriaParms");
       
      /*  ADFUtils.getBoundAttributeValue("invoiceTypeIdWht1");
        ADFUtils.setBoundAttributeValue("countryCodeWht1");
        ADFUtils.setBoundAttributeValue("companyIdNoWht1");
        ADFUtils.setBoundAttributeValue("companyNameWht1");
        ADFUtils.setBoundAttributeValue("invoiceTypeIdWht1");
        ADFUtils.setBoundAttributeValue("paymentDateWhtFrom1");
        ADFUtils.setBoundAttributeValue("paymentDateWhtTo1");*/
    }
    
    public void submitFusionPayablesIntRecon(ActionEvent actionEvent) {
        callOperation("submitFusionPayablesRecon");
    }
    
    public void setFromDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        String datetime = dateFormat.format(dateVal);
        System.out.println("Date Time: " + datetime);
        ADFUtils.setBoundAttributeValue("IntFromDate1",datetime);
    }

    public void setToDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        System.out.println("Date Time: " + dateFormat);
        String datetime = dateFormat.format(dateVal);
        System.out.println("Date Time: " + datetime);
        ADFUtils.setBoundAttributeValue("IntToDate1",datetime);
    }

    public void createButtonmethod(ActionEvent actionEvent) {
        System.out.println("insode create button method");
        callOperation("CreateWithParams");
        callOperation("CreateWithParams1");
        callOperation("CreateWithParams2");
        bv_form.setVisible(true);
    }

    public void onSubmitBrokPaymentsAdjustments(ActionEvent actionEvent) {
        System.out.println("insode onsubmit");
        String invNo;
        if(bv_invNo.getValue() != null){
            invNo = bv_invNo.getValue().toString();
            System.out.println("Seq invNo: "+invNo);
            ss_invNo.setValue(invNo);
        }
        FacesContext fc = FacesContext.getCurrentInstance();
        float ExchRate = 0;
        float localCurrency = 0;
        float brokerCurrency = 0;
        if(bv_paymentExchRate.getValue() != null){
            ExchRate = Float.parseFloat( bv_paymentExchRate.getValue().toString());
        }
        System.out.println("ExchRate: "+ExchRate);
        if(bv_feeTypeAmt.getValue() != null){
            localCurrency = Float.parseFloat( bv_feeTypeAmt.getValue().toString());
            ss_localCurr.setValue(localCurrency);
        }
        
        System.out.println("localCurrency: "+localCurrency);
        if(bv_feeTypeExchAmt.getValue() != null){
            brokerCurrency = Float.parseFloat( bv_feeTypeExchAmt.getValue().toString());
        }
        
        System.out.println("brokerCurrency: "+brokerCurrency);
        if(ExchRate == 0 && brokerCurrency  == 0){
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please enter either exchange rate or broker currency");
            fc.addMessage(null, message);  
        }
        
        if(ExchRate != 0 && brokerCurrency  == 0 && localCurrency != 0){
            float b = ExchRate * localCurrency ;
            System.out.println("b: "+b);
            bv_feeTypeExchAmt.setValue(b);
        }
        
        if((localCurrency > 0 && brokerCurrency < 0) || (localCurrency < 0 && brokerCurrency > 0) ){
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Check amounts - signs are different");
            fc.addMessage(null, message); 
        }
        else{
            if(ExchRate == 0){
                float f = brokerCurrency / localCurrency;
                System.out.println("f: "+f);
                bv_paymentExchRate.setValue(f);
            }
        }
        if(ExchRate != 0 && brokerCurrency  != 0 && localCurrency != 0){
            System.out.println("insode the check");
            float bc = ExchRate * localCurrency ;
            System.out.println("bc: "+bc);
            System.out.println("localCurrency: "+localCurrency);
            int bcr = Math.round(bc);
            int brokerCurrencyr = Math.round(brokerCurrency);
            if(bcr == brokerCurrencyr){
                System.out.println("Entered values of correct");
            }
            else{
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Check amounts and exchange rate");
                fc.addMessage(null, message);
            }
        }
        ss_brokerCurr.setValue(bv_feeTypeExchAmt.getValue());
        ss_exchRate.setValue(bv_paymentExchRate.getValue());
        ss_compId.setValue(bv_compIdLov.getValue());
        ss_countryCode.setValue(bv_countryCode.getValue());       
        ss_payCurrCode.setValue(bv_currCode.getValue());
        ss_erCurrCode.setValue(bv_currCode.getValue());
        bv_saveButon.setDisabled(false);
        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Info", "Please submit your changes");
        fc.addMessage(null, message);
    }


    public void onChangeCompId(ValueChangeEvent valueChangeEvent) {
        System.out.println("inside onChangeCompId method");
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        String selectedCurrCode = null;
        String compId = bv_compIdLov.getValue().toString();
        System.out.println("compId: "+compId);
        ss_compId.setValue(compId);
        DCIteratorBinding iterCountryTax = dcBc.findIteratorBinding("CompanyByPkViewIterator");
        ViewObject CompanySelectedRow = iterCountryTax.getViewObject();
        CompanySelectedRow.ensureVariableManager().setVariableValue("pCompanyIdNo", compId);
        CompanySelectedRow.executeQuery();
        RowSetIterator rsi = CompanySelectedRow.createRowSetIterator(null);
        int countRow = rsi.getRowCount();
        System.out.println("countRow: "+countRow);
        while (rsi.hasNext()) {
            System.out.println("inside while");
            Row singleRow = rsi.next();
            System.out.println("countRow: "+countRow);
            if(singleRow != null && singleRow.getAttribute("CompanyIdNo") != null) {
                System.out.println("singleRow.getAttribute(\"PreferredCurrencyCode\"): "+singleRow.getAttribute("PreferredCurrencyCode"));
                selectedCurrCode = singleRow.getAttribute("PreferredCurrencyCode").toString();
                bv_currCode.setValue(selectedCurrCode);
                ss_erCurrCode.setValue(selectedCurrCode);
                ss_payCurrCode.setValue(selectedCurrCode);
            }
        }
        rsi.closeRowSetIterator();
    }

    public void onClickNewButton(ActionEvent actionEvent) {
        System.out.println("inside new button");
        bvForm.setVisible(true);
        callOperation("CreateWithParams3");
        callOperation("CreateWithParams4");
        callOperation("CreateWithParams2");
        bv_saveButon.setDisabled(true);
    }
    
    public void enterFeeTypeAmt(ValueChangeEvent valueChangeEvent) {
        
    }

    public void enterFeeTypeExchAmt(ValueChangeEvent valueChangeEvent) {

    }

    public void enterCountryCode(ValueChangeEvent valueChangeEvent) {
        System.out.println("inside onChangeCompId method");
        FacesContext fc = FacesContext.getCurrentInstance();
        List<String> CountryList = new ArrayList<String>();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        String countryCode = "";
        String compId = "";
        String selectedCurrCode = bv_countryCode.getValue().toString();
        System.out.println("selectedCurrCode: "+selectedCurrCode);  
        System.out.println("inside onChangeCompId method, bv_compIdLov.getValue()"+bv_compIdLov.getValue());
        if(bv_compIdLov.getValue() != null){
            compId = bv_compIdLov.getValue().toString();
            System.out.println("compId: "+compId);
            DCIteratorBinding iterCountryTax = dcBc.findIteratorBinding("CompanyCountryByCompanyViewIterator");
            ViewObject CompanySelectedRow = iterCountryTax.getViewObject();
            CompanySelectedRow.ensureVariableManager().setVariableValue("pCompanyIdNo", compId);
            CompanySelectedRow.executeQuery();
            RowSetIterator rsi = CompanySelectedRow.createRowSetIterator(null);
            int countRow = rsi.getRowCount();
            System.out.println("countRow: "+countRow);
            while (rsi.hasNext()) {
                System.out.println("inside while");
                Row singleRow = rsi.next();
                if(singleRow != null && singleRow.getAttribute("CompanyIdNo") != null) {
                    System.out.println("singleRow.getAttribute(\"CountryCode\"): "+singleRow.getAttribute("CountryCode"));
                    countryCode = singleRow.getAttribute("CountryCode").toString();
                    CountryList.add(countryCode);
                }
            }
            if(!CountryList.contains(selectedCurrCode)){
                System.out.println("inside contains");
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Brokerage does not contract with this country. Please click search icon.");
                fc.addMessage(null, message); 
                bv_countryCode.resetValue();
                bv_countryCode.setValue(null);
            }
            rsi.closeRowSetIterator();
        }
        else{
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please enter brokerage code.");
            fc.addMessage(null, message); 
        }
    }

    public void setBv_releaseHoldReason(RichInputText bv_releaseHoldReason) {
        this.bv_releaseHoldReason = bv_releaseHoldReason;
    }

    public RichInputText getBv_releaseHoldReason() {
        return bv_releaseHoldReason;
    }

    public void onEnterReason4Adjust(ValueChangeEvent valueChangeEvent) {
        String reason4Adjust = bv_reason4Adjust.getValue().toString();
        bv_releaseHoldReason.setValue(reason4Adjust);
    }

    public void setBv_reason4Adjust(RichInputText bv_reason4Adjust) {
        this.bv_reason4Adjust = bv_reason4Adjust;
    }

    public RichInputText getBv_reason4Adjust() {
        return bv_reason4Adjust;
    }

    public void onEnterExchangeRate(ValueChangeEvent valueChangeEvent) {
        System.out.println("inside enterFeeTypeAmt");
        FacesContext fc = FacesContext.getCurrentInstance();
        String exch = bv_paymentExchRate.getValue().toString();
        float exchRate = Float.parseFloat(exch);
        System.out.println("inside bv_paymentExchRate.getValue().toString() : "+bv_paymentExchRate.getValue().toString());
            if(exchRate < 0){
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "The exchange rate can't be negative.");
                fc.addMessage(null, message); 
            }
    }

    public void setBvForm(RichPanelFormLayout bvForm) {
        this.bvForm = bvForm;
    }

    public RichPanelFormLayout getBvForm() {
        return bvForm;
    }

    public void setSs_compId(RichInputText ss_compId) {
        this.ss_compId = ss_compId;
    }

    public RichInputText getSs_compId() {
        return ss_compId;
    }

    public void setSs_erCurrCode(RichInputText ss_erCurrCode) {
        this.ss_erCurrCode = ss_erCurrCode;
    }

    public RichInputText getSs_erCurrCode() {
        return ss_erCurrCode;
    }

    public void setSs_payCurrCode(RichInputText ss_payCurrCode) {
        this.ss_payCurrCode = ss_payCurrCode;
    }

    public RichInputText getSs_payCurrCode() {
        return ss_payCurrCode;
    }

    public void setSs_countryCode(RichInputText ss_countryCode) {
        this.ss_countryCode = ss_countryCode;
    }

    public RichInputText getSs_countryCode() {
        return ss_countryCode;
    }

    public void setBv_invNo(RichInputText bv_invNo) {
        this.bv_invNo = bv_invNo;
    }

    public RichInputText getBv_invNo() {
        return bv_invNo;
    }

    public void setSs_invNo(RichInputText ss_invNo) {
        this.ss_invNo = ss_invNo;
    }

    public RichInputText getSs_invNo() {
        return ss_invNo;
    }

    public void setSs_brokerCurr(RichInputText ss_brokerCurr) {
        this.ss_brokerCurr = ss_brokerCurr;
    }

    public RichInputText getSs_brokerCurr() {
        return ss_brokerCurr;
    }

    public void setSs_localCurr(RichInputText ss_localCurr) {
        this.ss_localCurr = ss_localCurr;
    }

    public RichInputText getSs_localCurr() {
        return ss_localCurr;
    }

    public void setSs_exchRate(RichInputText ss_exchRate) {
        this.ss_exchRate = ss_exchRate;
    }

    public RichInputText getSs_exchRate() {
        return ss_exchRate;
    }

    public void setBv_saveButon(RichButton bv_saveButon) {
        this.bv_saveButon = bv_saveButon;
    }

    public RichButton getBv_saveButon() {
        return bv_saveButon;
    }

    public void onSubmit(ActionEvent actionEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        callOperation("Commit");
        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Info", "The entries has been submitted successfully.");
        fc.addMessage(null, message);
        bvForm.setVisible(false);
    }
}
