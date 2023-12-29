package com.liberty.health.comm.vc.view;

import com.core.utils.ADFUtils;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import com.liberty.health.comms.lov.MedwareSchemesImpl;

import com.liberty.health.comms.model.dashboard.vo.FusionPremInvoiceMedReceiptVOImpl;

import java.text.DateFormat;

import java.text.SimpleDateFormat;

import java.util.Date;

import java.util.HashMap;
import java.util.Map;

import javax.el.ELContext;
import javax.el.ExpressionFactory;

import javax.el.MethodExpression;
import javax.el.ValueExpression;

import javax.faces.application.Application;
import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;


import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;

import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPoll;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.nav.RichCommandLink;
import oracle.adf.view.rich.component.rich.output.RichOutputText;

import oracle.adf.view.rich.context.AdfFacesContext;

import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.event.QueryEvent;

import oracle.binding.BindingContainer;

import oracle.binding.OperationBinding;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Row;

import oracle.jbo.server.ViewObjectImpl;

import org.apache.myfaces.trinidad.context.RequestContext;
import org.apache.myfaces.trinidad.event.AttributeChangeEvent;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.PollEvent;

public class Fusion extends CoreActions {
    private RichInputText bv_companyIdNo;
    private RichInputListOfValues bv_invoiceNo;

    public Fusion() {
        super();
    }
    
    DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
    //FacesContext fc = FacesContext.getCurrentInstance();
    DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
    RequestContext afContext = RequestContext.getCurrentInstance();
    public void submitPaymentReconJob(ActionEvent actionEvent) {
        
        callOperation("submitFusionPayReconJob");
    }

    public void setFromDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        String datetime = dateFormat.format(dateVal);
        System.out.println("Date Time: " + datetime);
        ADFUtils.setBoundAttributeValue("FromDate1",datetime);
    }

    public void setToDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        System.out.println("Date Time: " + dateFormat);
        String datetime = dateFormat.format(dateVal);
        System.out.println("Date Time: " + datetime);
        ADFUtils.setBoundAttributeValue("ToDate1",datetime);
    }

    public void setCompanyIdNo(ValueChangeEvent valueChangeEvent) {
        //java.lang.Integer compIdNo = (java.lang.Integer)valueChangeEvent.getNewValue();
        //ADFUtils.setBoundAttributeValue("CompanyIdNo",String.valueOf(compIdNo));
        java.lang.String compIdNo = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("CompanyIdNo",compIdNo);
        System.out.println("set the company Id No: " + compIdNo);
    }
    
    public void setCompanyIdNoF(ValueChangeEvent valueChangeEvent) {
        java.lang.Integer compIdNo = (java.lang.Integer)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("CompanyIdNo",String.valueOf(compIdNo));
//        java.lang.String compIdNo = (java.lang.String)valueChangeEvent.getNewValue();
//        ADFUtils.setBoundAttributeValue("CompanyIdNo",compIdNo);
        System.out.println("set the company Id No: " + compIdNo);
    }

    public void setInvoiceNo(ValueChangeEvent valueChangeEvent) {
        java.lang.String invNo = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("InvoiceNo",invNo);
        System.out.println("set the invoice  No: " + invNo);
    }

    public void setBv_companyIdNo(RichInputText bv_companyIdNo) {
        this.bv_companyIdNo = bv_companyIdNo;
    }

    public RichInputText getBv_companyIdNo() {
        return bv_companyIdNo;
    }

    public void setBv_invoiceNo(RichInputListOfValues bv_invoiceNo) {
        this.bv_invoiceNo = bv_invoiceNo;
    }

    public RichInputListOfValues getBv_invoiceNo() {
        return bv_invoiceNo;
    }

    public void resetCall(ActionEvent actionEvent) {
        // Add event code here...
        bv_companyIdNo.setValue(0);
        bv_companyIdNo.resetValue();
        bv_invoiceNo.setValue("");
        bv_invoiceNo.resetValue();
    }
}
