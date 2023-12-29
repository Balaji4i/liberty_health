package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;
import com.core.utils.ADFUtils;
import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.layout.RichPanelGroupLayout;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.event.QueryEvent;
import oracle.jbo.Row;
import oracle.jbo.ViewObject;

public class PartialPayments extends CoreActions {
    private RichPanelGroupLayout bv_pg;
    private RichButton bv_viewButton;

    public PartialPayments() {
        super();
    }


    public void validateNewEntry(ActionEvent actionEvent) {
        callOperation("setCreatedBy");
        callOperation("Commit");
        /*String returnMsg = (String)callOperation("validatePartialRec");
        if(returnMsg.equals("Success")) {
            callOperation("Commit");
        } else {
            callOperation("Rollback");
        }*/
        
        
        
       
    }


    public void setBv_pg(RichPanelGroupLayout bv_pg) {
        this.bv_pg = bv_pg;
    }

    public RichPanelGroupLayout getBv_pg() {
        return bv_pg;
    }

    public void onClickViewPage(ActionEvent actionEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        ADFContext adfCtx = ADFContext.getCurrent();
        Map sessionScope = adfCtx.getSessionScope();
        System.out.println("users countryList access is " + sessionScope.get("countryList"));
        String s = sessionScope.get("countryList").toString();
        System.out.println("s: " +s);
        String sArr[] = s.split("[,]",0);
        System.out.println(sArr.length);
        ViewObject periodVO = ADFUtils.findIterator("SystemParameter1Iterator").getViewObject();
        Row firstRow = periodVO.first();
        String pV = (String) firstRow.getAttribute("ParameterValue");
        System.out.println("pV: " +pV);
        System.out.println("currentRow.getAttribute(\"first ParameterValue\"): "+firstRow.getAttribute("ParameterValue"));
        if(s.contains("KE") && sArr.length == 1 && pV.equalsIgnoreCase("KE")){
           System.out.println("inside if");
            bv_pg.setVisible(false);
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "You have no access to view the details");
            fc.addMessage(null, message);
        }
        else{
            System.out.println("inside else");
            bv_pg.setVisible(true);
            bv_viewButton.setDisabled(true);
        }
        
    }

    public void setBv_viewButton(RichButton bv_viewButton) {
        this.bv_viewButton = bv_viewButton;
    }

    public RichButton getBv_viewButton() {
        return bv_viewButton;
    }
}
