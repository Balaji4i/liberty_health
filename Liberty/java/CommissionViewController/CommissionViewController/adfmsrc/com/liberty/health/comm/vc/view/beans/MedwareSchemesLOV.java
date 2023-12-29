package com.liberty.health.comm.vc.view.beans;

import com.core.utils.ADFUtils;

import java.util.ArrayList;
import java.util.List;

import javax.faces.model.SelectItem;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;


import oracle.jbo.ApplicationModule;
import oracle.jbo.ViewObject;

import com.liberty.health.comms.lov.MedwareSchemesImpl;
import com.liberty.health.comms.lov.MedwareSchemesRowImpl;

import org.apache.myfaces.trinidad.context.RequestContext;

public class MedwareSchemesLOV {
        DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        //FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
    public MedwareSchemesLOV() {
        super();
        
        System.out.println("after get Medware Schemes information - before anything");
        RequestContext afContext = RequestContext.getCurrentInstance();
        DCDataControl dc = dcBc.findDataControl( "CommsRunAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        
        MedwareSchemesImpl vo = (MedwareSchemesImpl)appModule.findViewObject("MedwareSchemesVO1");
       
            
        System.out.println("after get Medware Schemes information");
        
        
        if(afContext.getPageFlowScope().get("pCountryCode") != null) {
            
            String country = afContext.getPageFlowScope().get("pCountryCode").toString();
              
            System.out.println("after get Country "+country);
            
    
            vo.setNamedWhereClauseParam("pCountry",country);
            vo.executeQuery();
        
            
            while (vo.hasNext()) {  
                MedwareSchemesRowImpl row = (MedwareSchemesRowImpl)vo.next();
                System.out.println("scheme value is "+row.getSScheme().toString());
                 System.out.println("scheme name value is "+row.getSName().toString());
               // System.out.println("scheme is "+vo.getCurrentRow().getAttribute("SScheme").toString());
                list.add(new SelectItem(row.getSScheme().toString(),
                                        row.getSName().toString()
                                       )
                        );
            }      
          }
        }
        
        public List<SelectItem> list = new ArrayList<SelectItem>();
        
        public void setList(List<SelectItem> list) {
        
        }
        public synchronized List<SelectItem> getList() {
        return list;
        }
    }
