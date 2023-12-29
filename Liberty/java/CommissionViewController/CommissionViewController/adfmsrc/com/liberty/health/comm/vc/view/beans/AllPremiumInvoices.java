package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import java.util.List;

import javax.el.ELContext;

import javax.faces.event.ActionEvent;

import oracle.adf.model.BindingContext;
import javax.el.ExpressionFactory;

import javax.el.MethodExpression;

import javax.faces.application.Application;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;

import oracle.binding.BindingContainer;

import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewObject;
import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.event.QueryEvent;

import oracle.adf.view.rich.model.AttributeCriterion;
import oracle.adf.view.rich.model.AttributeDescriptor;
import oracle.adf.view.rich.model.ConjunctionCriterion;
import oracle.adf.view.rich.model.Criterion;
import oracle.adf.view.rich.model.QueryDescriptor;

import oracle.jbo.ViewCriteria;

import oracle.jbo.ViewCriteriaRow;
import oracle.jbo.uicli.binding.JUSearchBindingCustomizer;

import org.apache.myfaces.trinidad.event.DisclosureEvent;

public class AllPremiumInvoices extends CoreActions {
    private RichInputText bv_proInd;

    public AllPremiumInvoices() {
        super();
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
         String mexpr           = "#{bindings.SearchCommsPaymentsReceivedVOCriteria.processQuery}";
         String countryCode     = "";
         String groupCode     = "";
         String optionCode   = "";
         String memberCode   = "";
        // Date   contribSdate  = "";
      //   Date   contribEdate  = "";
         oracle.jbo.domain.Number companyIdNo;
         String status     = "";
         Integer invoiceTypeId;   
         
         System.out.println("in queryEvent");
         
         QueryDescriptor qd = queryEvent.getDescriptor();

         ConjunctionCriterion conCrit = qd.getConjunctionCriterion();
         List<Criterion> criterionList = conCrit.getCriterionList();

         for (Criterion criterion : criterionList) {
              AttributeDescriptor attrDescriptor = ((AttributeCriterion)criterion).getAttribute();
              System.out.println("name is before get value "+attrDescriptor.getName());
             
             if (attrDescriptor.getName().equalsIgnoreCase("GroupCode")){
                 
                  groupCode = (String)((AttributeCriterion)criterion).getValues().get(0);
                  
                  if(countryCode != null) {
                      ADFUtils.setBoundAttributeValue("GroupCode1", groupCode);
                  }
                  
             }
             if (attrDescriptor.getName().equalsIgnoreCase("CountryCode")){
                 
                countryCode = (String)((AttributeCriterion)criterion).getValues().get(0);
                if (countryCode != null) {    
                     System.out.println("company id no is "+countryCode);
                     System.out.println("setting the companyIdNoWht1 value "+countryCode);
                     ADFUtils.setBoundAttributeValue("companyIdNoWht1", countryCode);
                     System.out.println("after setting the companyIdNoWht1 value "+countryCode);
                 }
                      
             }
             
             if (attrDescriptor.getName().equalsIgnoreCase("ProductCode")){
                               
                 optionCode = (String)((AttributeCriterion)criterion).getValues().get(0);
                           
                 if(optionCode != null) {
                    ADFUtils.setBoundAttributeValue("OptionCode1", optionCode);
                 }
             }
             
            if (attrDescriptor.getName().equalsIgnoreCase("PersonCode")){
                                        
                memberCode = (String)((AttributeCriterion)criterion).getValues().get(0);
                                    
                if(memberCode != null) {
                             ADFUtils.setBoundAttributeValue("MemberCode1", memberCode);
                          }
            }
             
            if (attrDescriptor.getName().equalsIgnoreCase("ProcessedInd")){
                                        
                status = (String)((AttributeCriterion)criterion).getValues().get(0);
                                    
                          if(status != null) {
                             ADFUtils.setBoundAttributeValue("Status1", status);
                          }
            }

                  
                 
               
                             
                  }
              
                  callOperation("setCriteriaParms");
                  callOperation("setCriteriaParms1");
                  
                  processMethodExpression(mexpr, new Object[] {queryEvent}, new Class[] {QueryEvent.class}); 
                  
                 
                  
                  
              }

    public String saveAndRefresh() {
        callOperation("Execute");
        callOperation("Execute1");
        return null;
    }

    public void setBv_proInd(RichInputText bv_proInd) {
        this.bv_proInd = bv_proInd;
    }

    public RichInputText getBv_proInd() {
        return bv_proInd;
    }

    public void onChkBox(ValueChangeEvent valueChangeEvent) {
        System.out.println("inside chkbx method");
        Boolean condition = true;
        System.out.println("valueChangeEvent.getNewValue(): "+valueChangeEvent.getNewValue());
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        valueChangeEvent.getComponent().processUpdates(FacesContext.getCurrentInstance());
        ViewObject periodVO = ADFUtils.findIterator("AllCommsPaymentsFailedVO1Iterator").getViewObject();
        Row rowSelected = periodVO.getCurrentRow(); 
        if (valueChangeEvent.getNewValue().equals(condition)) {
            System.out.println("inside if");
            if(rowSelected != null && rowSelected.getAttribute("ProcessedInd") != null) {
                System.out.println("rowSelected.getAttribute(\"ProcessedInd\"): "+rowSelected.getAttribute("ProcessedInd"));
                rowSelected.setAttribute("ProcessedInd", "A");
            }
        }
        else{
            System.out.println("inside else");
            if(rowSelected != null && rowSelected.getAttribute("ProcessedInd") != null) {
                System.out.println("rowSelected.getAttribute(\"ProcessedInd\"): "+rowSelected.getAttribute("ProcessedInd"));
                rowSelected.setAttribute("ProcessedInd", "TF");
            }
            
        }
    }

    public void saveAndRefresh(ActionEvent actionEvent) {
        callOperation("Commit");
        callOperation("Execute2");
        FacesContext fc = FacesContext.getCurrentInstance();
        FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Information", "Selected data are Archived");
        fc.addMessage(null, message);
    }

    public String onSelectAll() {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        ViewObject periodVO = ADFUtils.findIterator("AllCommsPaymentsFailedVO1Iterator").getViewObject();
        RowSetIterator rowSetIterator = periodVO.createRowSetIterator(null);
        if(rowSetIterator!=null){
            rowSetIterator.reset();
            while(rowSetIterator.hasNext()){
                Row currentRow = rowSetIterator.next();
                System.out.println("currentRow.getAttribute(\"ArchivedYn\"): "+currentRow.getAttribute("ArchivedYn"));
                currentRow.setAttribute("ArchivedYn", "Y");
                currentRow.setAttribute("ProcessedInd", "A");
                System.out.println("After: currentRow.getAttribute(\"ArchivedYn\"): "+currentRow.getAttribute("ArchivedYn"));
                
            }
            rowSetIterator.closeRowSetIterator();
        }
        return null;
    }
    public String onDeselectAll() {
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        ViewObject periodVO = ADFUtils.findIterator("AllCommsPaymentsFailedVO1Iterator").getViewObject();
        RowSetIterator rowSetIterator = periodVO.createRowSetIterator(null);
        if(rowSetIterator!=null){
            rowSetIterator.reset();
            while(rowSetIterator.hasNext()){
                Row currentRow = rowSetIterator.next();
                currentRow.setAttribute("ArchivedYn", "N");
                currentRow.setAttribute("ProcessedInd", "TF");
            }
            rowSetIterator.closeRowSetIterator();
        }
        return null;
    }
    
    
    
}
