package com.liberty.health.comm.vc.view.beans;

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
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.RichPoll;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.input.RichInputListOfValues;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.component.rich.nav.RichCommandLink;
import oracle.adf.view.rich.component.rich.output.RichOutputText;

import oracle.adf.view.rich.context.AdfFacesContext;

import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;
import oracle.adf.view.rich.event.QueryEvent;

import oracle.binding.BindingContainer;

import oracle.binding.OperationBinding;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Row;

import oracle.jbo.ViewObject;
import oracle.jbo.server.ViewObjectImpl;

import org.apache.myfaces.trinidad.context.RequestContext;
import org.apache.myfaces.trinidad.event.AttributeChangeEvent;
import org.apache.myfaces.trinidad.event.DisclosureEvent;
import org.apache.myfaces.trinidad.event.PollEvent;

public class DashBoard extends CoreActions {
    private RichOutputText runMethodsOnPageLoad;
    private RichOutputText runWs;
    private Object parent;
    private String invoiceNumber;
    private RichInputListOfValues bv_brokerageCode;
    private RichInputListOfValues bv_invoiceNo;
    private RichTable bv_tab;
    private RichButton bv_submit;
    private RichPopup bv_parentpopup;

    public DashBoard() {
        super();
    }
    
    DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
    //FacesContext fc = FacesContext.getCurrentInstance();
    DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
    RequestContext afContext = RequestContext.getCurrentInstance();

    public void setParent(Object parent) {
        this.parent = parent;
        
        System.out.println("in setting parameters");
        
        UIComponent comp = (UIComponent) parent;
        
        String param1 = (String) comp.getAttributes().get("param1");
        
        DCDataControl dc = dcBc.findDataControl( "DashBoardAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        
        FusionPremInvoiceMedReceiptVOImpl vo = (FusionPremInvoiceMedReceiptVOImpl)appModule.findViewObject("FusionPremInvoiceMedReceipt1");
             
         System.out.println("after get Medware receipt Information");
        
        
        if(param1 != null) {
            
            vo.setNamedWhereClauseParam("pInvNo",param1);
            vo.executeQuery();
        }      
        
       this.setInvoiceNumber(param1);
       
    }
    
    

    public Object getParent() {
        return parent;
    }
    
    public void setInvoiceNumber(String invoiceNumber) {
        DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        //FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        RequestContext afContext = RequestContext.getCurrentInstance();
        System.out.println("in set invoice number Information - 1");
        System.out.println("in set invoice number Information - inv no "+invoiceNumber);
       // this.invoiceNumber = invoiceNumber;
        DCDataControl dc = dcBc.findDataControl("DashboardAMDataControl");
        
        System.out.println("Found the Dashboard Application Module");
        
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        
        System.out.println("calling the fusion prem invoice med receipt process "+invoiceNumber);
        FusionPremInvoiceMedReceiptVOImpl vo = (FusionPremInvoiceMedReceiptVOImpl)appModule.findViewObject("FusionPremInvoiceMedReceipt1");
             
         System.out.println("in set invoice number Information - check the result");
        
        
        if(invoiceNumber != null) {
            
            vo.setNamedWhereClauseParam("pInvNo",invoiceNumber);
            vo.executeQuery();
            System.out.println("executed the query successfully");
        }      
    }

    public String getInvoiceNumber() {
        
        DCDataControl dc = dcBc.findDataControl( "DashBoardAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        
        FusionPremInvoiceMedReceiptVOImpl vo = (FusionPremInvoiceMedReceiptVOImpl)appModule.findViewObject("FusionPremInvoiceMedReceipt1");
             
         System.out.println("after get Medware receipt Information");
        
        
        if(invoiceNumber != null) {
            
            vo.setNamedWhereClauseParam("pInvNo",invoiceNumber);
            vo.executeQuery();
        }      
        return invoiceNumber;
    }

    
    
    public void refreshActionListener(ActionEvent actionEvent) {
        callOperation("Execute");
        callOperation("Execute1");
        callOperation("Execute2");
        callOperation("Execute3");
        callOperation("Execute4");
        callOperation("Execute5");
        callOperation("Execute6");
        callOperation("Execute7");
        callOperation("Execute8");
        callOperation("Execute9");
        callOperation("Execute10");
        callOperation("Execute11");
        callOperation("Execute12");
        callOperation("Execute13");
        callOperation("Execute14");
        callOperation("Execute15");
        callOperation("Execute16");
        callOperation("Execute17");
        callOperation("Execute18");
        callOperation("Execute19");
    }

    public void setRunVar () {
        System.out.println("INTIAL VALUE ON ENTRY IS "+afContext.getPageFlowScope().get("checkRun"));
        afContext.getPageFlowScope().put("checkRun","Y");
        System.out.println("Value set to "+afContext.getPageFlowScope().get("checkRun"));
    }

    public void refreshBillingInfo(ActionEvent actionEvent) {
        FacesContext facesContext = FacesContext.getCurrentInstance();
        Application app = facesContext.getApplication();
        ExpressionFactory elFactory = app.getExpressionFactory();
        ELContext elContext = facesContext.getELContext();
        ValueExpression valueExp = elFactory.createValueExpression(elContext, "#{bindings}", Object.class);
        BindingContainer binding= (BindingContainer)valueExp.getValue(elContext);
        OperationBinding operationBinding=binding.getOperationBinding("callWsbilling");
          // Set the Input parameters to the operation bindings as below
       // operationBinding.getParamsMap().put("pCustomerID", "100");  
         // Invoke the Application module method
        operationBinding.execute();
          // Get the result from operation bindings
        Object obj = operationBinding.getResult();
        
        callOperation("refreshPremiums");
        
    }

    public void setRunWs(RichOutputText runWs) {
        this.runWs = runWs;
    }

    public RichOutputText getRunWs() {
        return runWs;
    }

    public void callFusionGroupRecon(ActionEvent actionEvent) {
        callOperation("submitFusionGroupReconJob");
        callOperation("Execute");
    }

    public void submitPaymentReconJob(ActionEvent actionEvent) {
        callOperation("submitFusionPayReconJob");
        bv_submit.setDisabled(false);
    }
    
    public void onClickRefresh(ActionEvent actionEvent) {
        System.out.println("before execute");
        callOperation("Execute");
        bv_tab.setRendered(true);
        bv_tab.setVisible(true);
        System.out.println("After execute");
    }

    public void setFromDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        if(dateVal!=null){
            String datetime = dateFormat.format(dateVal);
            System.out.println("Date Time: " + datetime);
            ADFUtils.setBoundAttributeValue("FromDate1",datetime);
        }
        
    }

    public void setToDateAttribute(ValueChangeEvent valueChangeEvent) {
        java.util.Date dateVal = (java.util.Date)valueChangeEvent.getNewValue();
        System.out.println("Date Time - original value: " + dateVal);
        DateFormat dateFormat = new SimpleDateFormat("MM-dd-YYYY");
        if(dateVal!=null){
            System.out.println("Date Time: " + dateFormat);
            String datetime = dateFormat.format(dateVal);
            System.out.println("Date Time: " + datetime);
            ADFUtils.setBoundAttributeValue("ToDate1",datetime);
        }
    }
    
    public void onChangebusinessUnit(ValueChangeEvent valueChangeEvent) {
        java.lang.String busUnit = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("BusinessUnit1",busUnit);
        System.out.println("set the buciness Unit: " + busUnit);
        //bv_submit.setDisabled(false);
    }

    public void setCompanyIdNo(ValueChangeEvent valueChangeEvent) {
//        java.lang.Integer compIdNo = (java.lang.Integer)valueChangeEvent.getNewValue();
//        ADFUtils.setBoundAttributeValue("CompanyIdNo",String.valueOf(compIdNo));
        java.lang.String compIdNo = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("CompanyIdNoRun1",compIdNo);
        System.out.println("set the company Id No: " + compIdNo);
    }

    public void setInvoiceNo(ValueChangeEvent valueChangeEvent) {
        java.lang.String invNo = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("InvoiceNoRun1",invNo);
        System.out.println("set the invoice  No: " + invNo);
    }
    
    public void deptPopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        AdfFacesContext context = AdfFacesContext.getCurrentInstance();
        String invNumber = null;  
        
        System.out.println("calling the popupFetchEvent");
        Map vScope = context.getViewScope();
        
        if ((String)vScope.get("id") != null) 
        {
           invNumber = (String)vScope.get("id");     
            System.out.println("got the value for the id "+invNumber);
        }
        
        DCDataControl dc = dcBc.findDataControl( "DashBoardAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        
        FusionPremInvoiceMedReceiptVOImpl vo = (FusionPremInvoiceMedReceiptVOImpl)appModule.findViewObject("FusionPremInvoiceMedReceipt1");
             
         System.out.println("after get Medware receipt Information");
        
        
        if(invNumber != null) {
            
            vo.setNamedWhereClauseParam("pInvNo",invNumber);
            vo.executeQuery();
        }      
        
        
        
    }

    public void setBv_brokerageCode(RichInputListOfValues bv_brokerageCode) {
        this.bv_brokerageCode = bv_brokerageCode;
    }

    public RichInputListOfValues getBv_brokerageCode() {
        return bv_brokerageCode;
    }

    public void setBv_invoiceNo(RichInputListOfValues bv_invoiceNo) {
        this.bv_invoiceNo = bv_invoiceNo;
    }

    public RichInputListOfValues getBv_invoiceNo() {
        return bv_invoiceNo;
    }

    public void onClickOnShowDetailItem(DisclosureEvent disclosureEvent) {
        
    }


    public void setGroupCode(ValueChangeEvent valueChangeEvent) {
        java.lang.String selGroupCode = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("SelectedGroupCode1",selGroupCode);
        System.out.println("set the selected group code : " + selGroupCode);
    }

    public void setParentgroupCode(ValueChangeEvent valueChangeEvent) {
        java.lang.String selParentgroupCode = (java.lang.String)valueChangeEvent.getNewValue();
        ADFUtils.setBoundAttributeValue("SelectedParentgroupCode1",selParentgroupCode);
        System.out.println("set the selected group code : " + selParentgroupCode);
    }

    public void setBv_tab(RichTable bv_tab) {
        this.bv_tab = bv_tab;
    }

    public RichTable getBv_tab() {
        return bv_tab;
    }

    public void setBv_submit(RichButton bv_submit) {
        this.bv_submit = bv_submit;
    }

    public RichButton getBv_submit() {
        return bv_submit;
    }

    public void popupdialogListen(DialogEvent dialogEvent) {
        
        
    }

    public void setBv_parentpopup(RichPopup bv_parentpopup) {
        this.bv_parentpopup = bv_parentpopup;
    }

    public RichPopup getBv_parentpopup() {
        return bv_parentpopup;
    }

    public void onClickParentLinkPerGroup(ActionEvent actionEvent) {
        System.out.println("inside popup listener");
        Row rowSelected = null;
        ViewObject paymentsPerGroupVO = ADFUtils.findIterator("CommissionPaymentsPerGroupVO1Iterator").getViewObject();
        if(paymentsPerGroupVO != null){
            rowSelected = paymentsPerGroupVO.getCurrentRow(); 
        }
        if(rowSelected != null){
            getParentSubgroups(rowSelected);
            callOperation("Execute");
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getBv_parentpopup().show(hints);
        } 
    }
    
    public void onClickParentLinkRecon(ActionEvent actionEvent) {
        System.out.println("inside popup listener");
        Row rowSelected = null;
        ViewObject fusionPremiumsReconVO = ADFUtils.findIterator("FusionPremiumsRecon1Iterator").getViewObject();
        if(fusionPremiumsReconVO != null){
            rowSelected = fusionPremiumsReconVO.getCurrentRow(); 
        }
        if(rowSelected != null){
            getParentSubgroups(rowSelected);
            callOperation("Execute1");
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getBv_parentpopup().show(hints);
        } 
    }
    
    public void onClickParentLinkGroupHistory(ActionEvent actionEvent) {
        System.out.println("inside popup listener");
        Row rowSelected = null;
        ViewObject fusionPremiumsReconVO = ADFUtils.findIterator("FusionGroupPremiumsReconVO1Iterator").getViewObject();
        if(fusionPremiumsReconVO != null){
            rowSelected = fusionPremiumsReconVO.getCurrentRow(); 
        }
        if(rowSelected != null){
            getParentSubgroups(rowSelected);
            callOperation("Execute1");
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getBv_parentpopup().show(hints);
        } 
    }
    
    public void getParentSubgroups(Row rowSelected){
        System.out.println("inside getParentSubgroups");
        String parentgroupCode = null;
        parentgroupCode = rowSelected.getAttribute("ParentgroupCode").toString();
        ADFContext adfCtx = ADFContext.getCurrent();
        Map sessionScope = adfCtx.getSessionScope();
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        System.out.println("set the ParentgroupCode : " + parentgroupCode);
        Object val = sessionScope.put("parentgroupCode", parentgroupCode);
        System.out.println("parentgroupCode access is " + sessionScope.get("parentgroupCode"));
        
    }


    public void onClickRefreshPreGroup(ActionEvent actionEvent) {
        System.out.println("inside onClickRefreshPreGroup");
        callOperation("Execute");
    }
}
