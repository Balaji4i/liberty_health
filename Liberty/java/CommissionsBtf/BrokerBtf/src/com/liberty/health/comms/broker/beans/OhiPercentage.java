package com.liberty.health.comms.broker.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;

import com.liberty.health.comms.lov.MedwareSchemesImpl;
import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVOImpl;

import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVORowImpl;

import java.math.BigDecimal;

import java.util.Date;

import javax.faces.application.FacesMessage;
import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;

import oracle.binding.AttributeBinding;
import oracle.binding.BindingContainer;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewObject;

public class OhiPercentage extends CoreActions {
    String ohiPercFaceName = "view";
    
    public OhiPercentage() {
        super();
    }


    /**
     * @param actionEvent
     */
    @SuppressWarnings("oracle.jdeveloper.java.tag-is-missing")
    public void linkActionListener(@SuppressWarnings("unused") ActionEvent actionEvent) {

        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding row = (DCIteratorBinding) bindings.get("MaintainOhiCommPercentageViewIterator");
        ViewObject voTableData = row.getViewObject();
        Row rowSelected = voTableData.getCurrentRow();
        rowSelected.setAttribute("AutUsername", ADFContext.getCurrent()
                                                          .getSecurityContext()
                                                          .getUserName());

    }

    /**
     * @param actionEvent
     */
    @SuppressWarnings("unused")
    public void test() {
        // Add event code here...
    }



    public void setOhiPercFaceName(String ohiPercFaceName) {
        this.ohiPercFaceName = ohiPercFaceName;
    }

    public String getOhiPercFaceName() {
        return ohiPercFaceName;
    }

    public void createActionListener(ActionEvent actionEvent) {
       callOperation("CreateWithParams");
       this.setOhiPercFaceName("maintain");
    }

    @SuppressWarnings("oracle.jdeveloper.java.tag-is-missing")
    public void doneActionListener(ActionEvent actionEvent) {
        this.setOhiPercFaceName("view");
    }

    public void saveButtonActionListener(ActionEvent actionEvent) {
        System.out.println("Inside Save method");
        FacesContext fc             = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc     = (DCBindingContainer) ADFUtils.getBindingContainer();
        BindingContainer bindings   = BindingContext.getCurrent().getCurrentBindingsEntry();
        DCDataControl dc            = dcBc.findDataControl( "CommsRunAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();        
        
        oracle.jbo.domain.Date     effStartDate;
        oracle.jbo.domain.Date     effEndtDate;
        java.sql.Date newEffSdate  = null; 
        java.sql.Date newEffEdate  = null;
        boolean noErrorRaised      = true;
        java.sql.Date newEffDate   = null;
        oracle.jbo.domain.Date currStartDate;
        float commPercNew;
       
        AttributeBinding commPerc          = (AttributeBinding) bindings.getControlBinding("CommPerc");
        AttributeBinding effStartDateBind  = (AttributeBinding) bindings.getControlBinding("EffectiveStartDate");
        AttributeBinding effEndDateBind    = (AttributeBinding) bindings.getControlBinding("EffectiveEndDate");
        //first get all current rows for the combination of information
        commPercNew = Float.parseFloat(commPerc.toString());
        
        if (commPercNew >= 20)
        {
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_WARN, "Error", "Warning please ensure that the Percentage entered is correct");
            fc.addMessage(null, message); 
        }
        
        
        if ((AttributeBinding) bindings.getControlBinding("EffectiveStartDate") != null) {
           
            effStartDate = (oracle.jbo.domain.Date) effStartDateBind.getInputValue();
            effEndtDate  = (oracle.jbo.domain.Date) effEndDateBind.getInputValue();
            System.out.println("in the binding values - start date is "+effStartDate);
            newEffSdate  = effStartDate.dateValue();
            newEffEdate  = effEndtDate.dateValue();
        }
        
      //  String viewCriteriaName = "UpdateEffectiveEndDateViewCriteria";
        
        DCIteratorBinding ohiPerc = dcBc.findIteratorBinding("MaintainOhiCommPercentageViewIterator");
        RowSetIterator rsi = ohiPerc.getViewObject().createRowSetIterator(null);
        // ignore current row being added as got values from the bindings
        rsi.getCurrentRow();
        System.out.println("moved onto the next row");
        Row row = rsi.next();
        while (rsi.hasNext()) {
            row = rsi.next();
            currStartDate = (oracle.jbo.domain.Date) row.getAttribute("EffectiveStartDate");
           
            newEffDate  = currStartDate.dateValue();
            System.out.println("the iterator value is "+newEffDate);
            System.out.println("the end date value is "+ (oracle.jbo.domain.Date) row.getAttribute("EffectiveEndDate"));
     
//            if (newEffSdate.equals(newEffDate) ||
//                newEffSdate.before(newEffDate)) {
//                noErrorRaised = false;
//                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please ensure the new start date is greater than existing record start dates");
//                fc.addMessage(null, message); 
//            }
            
        }
        rsi.closeRowSetIterator();
        
        if (noErrorRaised)
        {
          System.out.println("no errors update the dates  ");    
          callOperation("Commit");
          callOperation("updateEffDates");

       
         
            NavigationHandler handler = FacesContext.getCurrentInstance()
                                                    .getApplication()
                                                    .getNavigationHandler();
            handler.handleNavigation(FacesContext.getCurrentInstance(), null, "save");
       
         }
    }

    public void poliyBrokerSaveActionListener(ActionEvent actionEvent) {
        callOperation("Commit");
        callOperation("fixBackDatedChanges");
        NavigationHandler handler = FacesContext.getCurrentInstance()
                                                .getApplication()
                                                .getNavigationHandler();
        handler.handleNavigation(FacesContext.getCurrentInstance(), null, "save");

    }

    public void recalculatePolicyBrokersDates(ActionEvent actionEvent) {
        callOperation("Commit");
        callOperation("fixBackDatedChanges");
        callOperation("Execute");
    }
}
