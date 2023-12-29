package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;

import com.core.utils.ADFUtils;
import java.util.*;

import com.liberty.health.comms.model.brokerage.vo.CompanyFeeVOImpl;

import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVOImpl;
import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVORowImpl;
import com.liberty.health.comms.model.ohi.vo.OhiParentGroupLovViewImpl;
import com.liberty.health.comms.model.watchlist.vo.*;
import javax.faces.application.ViewHandler;
import javax.faces.component.UIViewRoot;
import javax.faces.context.FacesContext;

import java.util.Map;

import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.share.ADFContext;
import oracle.adf.view.rich.component.rich.RichPopup;
import oracle.adf.view.rich.component.rich.data.RichTable;
import oracle.adf.view.rich.component.rich.input.RichInputText;
import oracle.adf.view.rich.component.rich.layout.RichPanelFormLayout;
import oracle.adf.view.rich.component.rich.nav.RichButton;
import oracle.adf.view.rich.context.AdfFacesContext;
import oracle.adf.view.rich.event.DialogEvent;
import oracle.adf.view.rich.event.PopupFetchEvent;

import oracle.binding.BindingContainer;

import oracle.jbo.ApplicationModule;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.ViewCriteriaRow;
import oracle.jbo.ViewObject;

public class WatchList extends CoreActions {
    String returnMsg = null;
    private RichPopup errorMsgPopUp;
    private RichInputText rejectInputTextBox;
    FacesContext fc = FacesContext.getCurrentInstance();
    String userCode = ADFContext.getCurrent().getSecurityContext().getUserName();
    private RichTable bvApprovalTable;
    String parentgroupCode = "";
    String countryCode = "";
    String groupCode = "";
    private RichButton bv_continue;
    private RichPanelFormLayout bv_ohiForm;
    List<String> groupList = new ArrayList<String>();
    List<String> sGroupListArr = new ArrayList<String>();
    ADFContext adfCtx = ADFContext.getCurrent();
    Map sessionScope = adfCtx.getSessionScope();
    int groupListLength;
    String dummyGroupCode = "";
    private RichInputText dummyGroupCodeTextBox;

    public WatchList() {
        super();
    }

   /* public void bankDetailsApprovalDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            returnMsg = (String) callOperation("approveBankingDetails");
            if (returnMsg == null) {
                callOperation("Commit");
                callOperation("Execute");
            } else {
                callOperation("Rolback");
                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                this.getErrorMsgPopUp().show(hints);
            }
        }

    }*/

    public void refresh() {
           FacesContext context = FacesContext.getCurrentInstance();
           String currentView = context.getViewRoot().getViewId();
           ViewHandler vh = context.getApplication().getViewHandler();
           UIViewRoot x = vh.createView(context, currentView);
           x.setViewId(currentView);
           context.setViewRoot(x);
    }
    
    public void commPercApprovalDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            callOperation("setVc");
            returnMsg = (String) callOperation("setAuthUsername");
            if (returnMsg != null) {
                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                this.getErrorMsgPopUp().show(hints);
            }
            callOperation("Execute");
        }

    }
    
    public List<String> parentCountryMethod(){
        System.out.println("inside the parent country method ");
        List<String> pcList = new ArrayList<String>();
        
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding allGroupComm = dcBc.findIteratorBinding("AllGroupCommPercOutstandingApprovalViewIterator");
        ViewObject allGroupCommVO = allGroupComm.getViewObject();
        Row allGroupCommVOcurrentRow = allGroupCommVO.getCurrentRow();
        if(allGroupCommVOcurrentRow!= null && allGroupCommVOcurrentRow.getAttribute("ParentgroupCode")!= null
           && allGroupCommVOcurrentRow.getAttribute("CountryCode").toString()!= null){
               parentgroupCode = allGroupCommVOcurrentRow.getAttribute("ParentgroupCode").toString();
               countryCode = allGroupCommVOcurrentRow.getAttribute("CountryCode").toString();
           }
        pcList.add(parentgroupCode);
        pcList.add(countryCode);
        System.out.println("pcList: "+pcList);
        return pcList;
    }
    
    public RowSetIterator rsiMethod(){
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        String viewCriteriaName = "GroupCommPercOutApprovalViewNCriteria";
        DCDataControl dc = dcBc.findDataControl( "WatchListAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
        GroupCommPercOutApprovalViewNImpl vo = (GroupCommPercOutApprovalViewNImpl)appModule.findViewObject("AllGroupCommPercOutApprovalViewN");   
           ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
           vo.removeViewCriteria(viewCriteriaName);
           vc.resetCriteria();
           vo.applyViewCriteria(vc);
           vo.setNamedWhereClauseParam("pParentgroupCode", parentgroupCode);
           vo.executeQuery();
          RowSetIterator rsi = vo.createRowSetIterator(null);
          return rsi;
    }
    
    public void groupCommPercDeleteDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
            List<String> parentCountryList = parentCountryMethod();
            parentgroupCode = parentCountryList.get(0);
            countryCode = parentCountryList.get(1);
            if(countryCode.equalsIgnoreCase("KE") && !parentgroupCode.equals("")){
                System.out.println("Inside if: " + parentgroupCode);
                   RowSetIterator rsi = rsiMethod();
                   int countRow = rsi.getRowCount();
                   System.out.println("countRow: "+countRow);
                   while (rsi.hasNext()) {
                       System.out.println("inside while");
                       Row singleRow = rsi.next();
                       if(singleRow != null && singleRow.getAttribute("ParentgroupCode") != null) {
                           System.out.println("singleRow.getAttribute(\"GroupCode\"): "+singleRow.getAttribute("GroupCode"));
                           System.out.println("singleRow.getAttribute(\"EffectiveStartDate\"): "+singleRow.getAttribute("EffectiveStartDate"));
                           groupCode = singleRow.getAttribute("GroupCode").toString();
                           ADFUtils.setBoundAttributeValue("GroupCode",groupCode);
                           ADFUtils.setBoundAttributeValue("EffectiveStartDate",singleRow.getAttribute("EffectiveStartDate"));
                           System.out.println("set the group code : " + groupCode);
                           String viewCriteriaNamen = "UpdateGroupCommPercVOCriteria";
                           DCDataControl dcn = dcBc.findDataControl( "OhiStructureAMDataControl" );
                           ApplicationModule appModulen = (ApplicationModule)dcn.getDataProvider();
                           NewOhiCommPercVOImpl von = (NewOhiCommPercVOImpl)appModulen.findViewObject("MaintainOhiCommPercentageView");
                           System.out.println("von : " + von);
                           ViewCriteria vcn = von.getViewCriteria(viewCriteriaNamen);
                           von.removeViewCriteria(viewCriteriaNamen);
                           vcn.resetCriteria();
                           von.applyViewCriteria(vcn);
                           von.setNamedWhereClauseParam("pGroupCode", groupCode);
                           von.setNamedWhereClauseParam("pStartDate", singleRow.getAttribute("EffectiveStartDate"));
                           von.executeQuery();
                           System.out.println("von : " + von);
                           NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) von.getCurrentRow();
                           System.out.println("row : " + row);
                           row.remove();
                           callOperation("Commit");
                       }
                   }
                   rsi.closeRowSetIterator();
            }
            else{
                callOperation("setVc");
                returnMsg = (String) callOperation("removeUserRecord");
                if (returnMsg != null) {
                    RichPopup.PopupHints hints = new RichPopup.PopupHints();
                    this.getErrorMsgPopUp().show(hints);
                }
                callOperation("Execute");
            }
            callOperation("Execute"); 
            
        }

    }
    
    public void groupCommPercApprovalDialogListener(DialogEvent dialogEvent) {
        System.out.println("inside the groupComm approval method");
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            String createdUsername = "";
            DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
            List<String> parentCountryList = parentCountryMethod();
            parentgroupCode = parentCountryList.get(0);
            countryCode = parentCountryList.get(1);
            if(countryCode.equalsIgnoreCase("KE") && !parentgroupCode.equals("")){
                System.out.println("Inside if: " + parentgroupCode);
                   RowSetIterator rsi = rsiMethod();
                   int countRow = rsi.getRowCount();
                   System.out.println("countRow: "+countRow);
                    while (rsi.hasNext()) {
                        System.out.println("inside while");
                        Row singleRow = rsi.next();
                        if(singleRow != null && singleRow.getAttribute("ParentgroupCode") != null) {
                            System.out.println("singleRow.getAttribute(\"GroupCode\"): "+singleRow.getAttribute("GroupCode"));
                            System.out.println("singleRow.getAttribute(\"EffectiveStartDate\"): "+singleRow.getAttribute("EffectiveStartDate"));
                            groupCode = singleRow.getAttribute("GroupCode").toString();
                            createdUsername = singleRow.getAttribute("CreatedUsername").toString();
                            ADFUtils.setBoundAttributeValue("GroupCode",groupCode);
                            ADFUtils.setBoundAttributeValue("EffectiveStartDate",singleRow.getAttribute("EffectiveStartDate"));
                            System.out.println("set the group code : " + groupCode);
                            String viewCriteriaNamen = "UpdateGroupCommPercVOCriteria";
                            DCDataControl dcn = dcBc.findDataControl( "OhiStructureAMDataControl" );
                            ApplicationModule appModulen = (ApplicationModule)dcn.getDataProvider();
                            NewOhiCommPercVOImpl von = (NewOhiCommPercVOImpl)appModulen.findViewObject("MaintainOhiCommPercentageView");
                            System.out.println("von : " + von);
                            ViewCriteria vcn = von.getViewCriteria(viewCriteriaNamen);
                            von.removeViewCriteria(viewCriteriaNamen);
                            vcn.resetCriteria();
                            von.applyViewCriteria(vcn);
                            von.setNamedWhereClauseParam("pGroupCode", groupCode);
                            von.setNamedWhereClauseParam("pStartDate", singleRow.getAttribute("EffectiveStartDate"));
                            von.executeQuery();
                            System.out.println("von : " + von);
                            NewOhiCommPercVORowImpl row = (NewOhiCommPercVORowImpl) von.getCurrentRow();
                            System.out.println("row : " + row);
                            if (createdUsername.compareTo(userCode) == 0) {
                                returnMsg = "You created the record and therefore cannot approve the change as well.";
                                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                                this.getErrorMsgPopUp().show(hints);
                            } else {
                                row.setAttribute("CompanyIdNo", null);
                                row.setAttribute("AuthUsername", userCode);
                                System.out.println("row.getAttribute(\"AuthUsername\"): "+row.getAttribute("AuthUsername"));
                                row.setAuthUsername(userCode);
                                callOperation("Commit");
                            }
                            
                        }
                    }
                    rsi.closeRowSetIterator();
                }
                else{
                    callOperation("setVc");
                    returnMsg = (String) callOperation("setAuthUsername");
                    if (returnMsg != null) {
                        RichPopup.PopupHints hints = new RichPopup.PopupHints();
                        this.getErrorMsgPopUp().show(hints);
                    }
                    callOperation("Execute");
                }
            callOperation("Execute");
        }

    }
    
    
    public void commPercDeleteDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            callOperation("setVc");
            returnMsg = (String) callOperation("removeUserRecord");
            if (returnMsg != null) {
                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                this.getErrorMsgPopUp().show(hints);
            }
            callOperation("Execute");
        }

    }
    
    public void commPercRejectDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            callOperation("setVc");
            returnMsg = (String) callOperation("setRejectUsername");
            if (returnMsg != null) {
                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                this.getErrorMsgPopUp().show(hints);
            }
            callOperation("Execute");
            this.rejectInputTextBox.resetValue();
        }

    }

    public void setReturnMsg(String returnMsg) {
        this.returnMsg = returnMsg;
    }

    public String getReturnMsg() {
        return returnMsg;
    }

    public void setErrorMsgPopUp(RichPopup errorMsgPopUp) {
        this.errorMsgPopUp = errorMsgPopUp;
    }

    public RichPopup getErrorMsgPopUp() {
        return errorMsgPopUp;
    }

    public void commsRunApprovalDialogListener(DialogEvent dialogEvent) {
        FacesContext fc = FacesContext.getCurrentInstance();
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().ok) {
            String returnMsg = (String) callOperation("approveCommissionRun");
            if (returnMsg == null) {
                FacesMessage message =
                    new FacesMessage(FacesMessage.SEVERITY_INFO, "Success",
                                     "Commission run has been succesfully approved.");
                fc.addMessage(null, message);
                callOperation("Commit");
                callOperation("Execute");
            } else {
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
                fc.addMessage(null, message);
                callOperation("Rollback");
            }
        }

    }


    public void setRejectInputTextBox(RichInputText rejectInputTextBox) {
        this.rejectInputTextBox = rejectInputTextBox;
    }

    public RichInputText getRejectInputTextBox() {
        return rejectInputTextBox;
    }

    public void commPercRejecedResubmitDialogListener(DialogEvent dialogEvent) {
        if (dialogEvent.getOutcome() == dialogEvent.getOutcome().yes) {
            returnMsg = (String) callOperation("resubmitForApproval");
            if (returnMsg != null) {
                RichPopup.PopupHints hints = new RichPopup.PopupHints();
                this.getErrorMsgPopUp().show(hints);
            }
            callOperation("Execute");
        }

        }

    public void reSubmitPopUpFetchListener(PopupFetchEvent popupFetchEvent) {
        callOperation("setVc");
    }

    public void brokerageOustandingPaymentsSubmitAllActionListener(ActionEvent actionEvent) {
        
        oracle.jbo.domain.Number companyIdNo = null;
        String countryCode  = null;  
       
        System.out.println("Fetching the invoice view iterator");
        DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllBrokerageInvoicesOnHoldRoViewIterator");
        
       
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();
        System.out.println("getting the selected row");
        //get the current row
        
        if(rowSelected.getAttribute("CountryCode") != null) {
           //  System.out.println("got the country code value "+(String) rowSelected.getAttribute("CountryCode"));
            //System.out.println("got the brokerage code value "+(Integer) rowSelected.getAttribute("CompanyIdNo"));
        
            countryCode   = (String) rowSelected.getAttribute("CountryCode"); 
            System.out.println("getting the companyIdNo from the attribute value");
            companyIdNo   = (oracle.jbo.domain.Number) rowSelected.getAttribute("CompanyIdNo"); 
            
            ADFUtils.setBoundAttributeValue("pCountryCode1",countryCode);
            System.out.println("setting the bound attribute value to "+companyIdNo);
            ADFUtils.setBoundAttributeValue("pCompanyIdNo1",companyIdNo.intValue());
          
            
            String returnMsg = (String) callOperation("executePaymentRun");
            if (returnMsg == null) {
                callOperation("Commit");
                callOperation("Execute");
            } else {
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
                fc.addMessage(null, message);
                callOperation("Rollback");
            }
    }
    }

    public void approvePartialReceipt(ActionEvent actionEvent) {
        System.out.println("calling the setAuthUsername Operation");
        String returnMsg = (String)callOperation("setAuthUsername");
        System.out.println("after calling the set auth");
        if(returnMsg.equals("Success")) {
            callOperation("Commit");
        }  else {
         FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", returnMsg);
         fc.addMessage(null, message);
        } 
       }
    
    public void deletePartialReceipt(ActionEvent actionEvent) {
        System.out.println("calling the delete Record Operation");
        callOperation("Delete");
        callOperation("Commit");
       
       }

    public void preferredCurrApproval(DialogEvent dialogEvent) {
        System.out.println("inside approval method");
        System.out.println("Username ---" + userCode);
        String Responded = null;
        FacesContext fc = FacesContext.getCurrentInstance();
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        ViewObject periodVO = ADFUtils.findIterator("Approvals1Iterator").getViewObject();
        Row rowSelected = periodVO.getCurrentRow(); 
        if(rowSelected != null){
            String valueToApprove = rowSelected.getAttribute("ValueToApprove").toString();
            System.out.println("rowSelected.getAttribute(\"ValueToApprove\"): "+rowSelected.getAttribute("ValueToApprove"));
            System.out.println("rowSelected.getAttribute(\"CreatedBy\"): "+rowSelected.getAttribute("CreatedBy"));
            String compId = rowSelected.getAttribute("CompanyIdNo").toString();
            System.out.println("compId: "+compId);
            int checkUser = rowSelected.getAttribute("CreatedBy").toString().compareTo(userCode);
            System.out.println("checkUser: "+checkUser);
            if(rowSelected.getAttribute("Responded") != null){
                Responded = rowSelected.getAttribute("Responded").toString();
                System.out.println("rowSelected.getAttribute(\"Responded\"): "+rowSelected.getAttribute("Responded"));
                
            }
            System.out.println("Responded: "+Responded);
            if(Responded != null){
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","This request cannot be approved/rejected since it is responded.");
                fc.addMessage(null, message);
            }
            else{
                if (checkUser == 0) {
                    FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","You created the record and therefore cannot approve the change as well.");
                    fc.addMessage(null, message);
                }
                else{
                    if(rowSelected != null && rowSelected.getAttribute("CompanyIdNo") != null) {
                        System.out.println("rowSelected.getAttribute(\"CompanyIdNo\"): "+rowSelected.getAttribute("CompanyIdNo"));
                        rowSelected.setAttribute("ApprovalUser", userCode);
                        rowSelected.setAttribute("RejectUser", "");
                        rowSelected.setAttribute("Responded", "Y");
                    }
                    callOperation("Commit");
                    callOperation("Execute");
                    AdfFacesContext.getCurrentInstance().addPartialTarget(this.getBvApprovalTable());
                    DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
                    DCIteratorBinding iterCountryTax = dcBc.findIteratorBinding("CompanyByPkViewIterator");
                    ViewObject rowSelected1 = iterCountryTax.getViewObject();
                    rowSelected1.ensureVariableManager().setVariableValue("pCompanyIdNo", compId);
                    rowSelected1.executeQuery();
                    RowSetIterator rsi = rowSelected1.createRowSetIterator(null);
                    int countRow = rsi.getRowCount();
                    while (rsi.hasNext()) {
                        System.out.println("inside while");
                        Row singleRow = rsi.next();
                        System.out.println("countRow: "+countRow);
                        if(singleRow != null && singleRow.getAttribute("CompanyIdNo") != null) {
                            System.out.println("singleRow.getAttribute(\"PreferredCurrencyCode\"): "+singleRow.getAttribute("PreferredCurrencyCode"));
                            singleRow.setAttribute("PreferredCurrencyCode", valueToApprove);
                        }
                    }
                    rsi.closeRowSetIterator();
                    callOperation("Commit");
                }
            }
        }
    }

    public void preferredCurrReject(DialogEvent dialogEvent) {
        System.out.println("inside reject method");
        FacesContext fc = FacesContext.getCurrentInstance();
        String Responded = null;
        BindingContainer bindings = BindingContext.getCurrent().getCurrentBindingsEntry();
        ViewObject periodVO = ADFUtils.findIterator("Approvals1Iterator").getViewObject();
        Row rowSelected = periodVO.getCurrentRow(); 
        if(rowSelected != null){
            int checkUser = rowSelected.getAttribute("CreatedBy").toString().compareTo(userCode);
            System.out.println("checkUser: "+checkUser);
            if(rowSelected.getAttribute("Responded") != null){
                Responded = rowSelected.getAttribute("Responded").toString();
                System.out.println("rowSelected.getAttribute(\"Responded\"): "+rowSelected.getAttribute("Responded"));
                
            }
            if(Responded != null){
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","This request cannot be approved/rejected since it is responded.");
                fc.addMessage(null, message);
            }
            else{
                if (checkUser == 0) {
                    FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error","You created the record and therefore cannot reject the change as well.");
                    fc.addMessage(null, message);
                }
                else{
                    if(rowSelected != null && rowSelected.getAttribute("CompanyIdNo") != null) {
                        System.out.println("rowSelected.getAttribute(\"CompanyIdNo\"): "+rowSelected.getAttribute("CompanyIdNo"));
                        rowSelected.setAttribute("RejectUser", userCode);
                        rowSelected.setAttribute("ApprovalUser", "");
                        rowSelected.setAttribute("Responded", "Y");
                    }
                    callOperation("Commit");
                    callOperation("Execute");
                    AdfFacesContext.getCurrentInstance().addPartialTarget(this.getBvApprovalTable());
                }
            }
        }
    }

    public void setBvApprovalTable(RichTable bvApprovalTable) {
        this.bvApprovalTable = bvApprovalTable;
    }

    public RichTable getBvApprovalTable() {
        return bvApprovalTable;
    }

    public void onChangeParentGroupLov(ValueChangeEvent valueChangeEvent) {
        java.lang.String selparentgroupCode = (java.lang.String)valueChangeEvent.getNewValue();
        if(!selparentgroupCode.equalsIgnoreCase("")){
            parentgroupCode = selparentgroupCode.toString();
            String viewCriteriaName = "OhiParentGroupLovViewCriteria";
            String groupCode = null;
            DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
            DCDataControl dc = dcBc.findDataControl( "OhiStructureAMDataControl" );
            ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
            OhiParentGroupLovViewImpl vo = (OhiParentGroupLovViewImpl)appModule.findViewObject("OhiParentGroupLovView1");  
            System.out.println("vo: "+vo); 
            ViewCriteria vc1 = vo.getViewCriteria(viewCriteriaName);
            vo.removeViewCriteria(viewCriteriaName);
            vc1.resetCriteria();
            vo.applyViewCriteria(vc1);
            vo.setNamedWhereClauseParam("pParentgroupCode", parentgroupCode);
            vo.executeQuery();
            RowSetIterator rsi = vo.createRowSetIterator(null);
            int countRow = rsi.getRowCount();
            System.out.println("countRow: "+countRow);
            while (rsi.hasNext()) {
                    System.out.println("inside while");
                    Row singleRow = rsi.next();
                    if(singleRow != null && singleRow.getAttribute("ParentgroupCode") != null) {
                            System.out.println("singleRow.getAttribute(\"GroupCode\"): "+singleRow.getAttribute("GroupCode"));
                            groupCode = singleRow.getAttribute("GroupCode").toString();
                            groupList.add(groupCode);
                    }
            }
            System.out.println("groupList: "+groupList);
            groupListLength = groupList.size();
            Object val = sessionScope.put("sGroupList", groupList);
            Object val1 = sessionScope.put("sGroupListLength", groupListLength);
            bv_ohiForm.setVisible(true);
            bv_continue.setVisible(true);
            callOperation("Create");
            sGroupListArr = (List<String>) sessionScope.get("sGroupList");
            dummyGroupCode = sGroupListArr.get(0);
            dummyGroupCodeTextBox.setValue(dummyGroupCode);
            
        }
        else{
            
        }
    }

   

    public void onClickContinue(ActionEvent actionEvent) {
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        FacesContext fc = FacesContext.getCurrentInstance();
        sGroupListArr = (List<String>) sessionScope.get("sGroupList");
        System.out.println("Begin inside onClickContinue sGroupListArr : "+sGroupListArr);
        DCIteratorBinding ohiCommPerc = dcBc.findIteratorBinding("MaintainOhiCommPercentageViewIterator");
        ViewObject ohiCommPercVO = ohiCommPerc.getViewObject();
        Row ohiCommPercVOcurrentRow = ohiCommPercVO.getCurrentRow();
        groupCode = sGroupListArr.get(0);
        if(groupCode != null){
            ohiCommPercVOcurrentRow.setAttribute("GroupCode", groupCode);
            ohiCommPercVOcurrentRow.setAttribute("CompanyIdNo", null);
            callOperation("Commit");
            System.out.println("Begin onClickContinue groupListLength : "+groupListLength);
            sGroupListArr = (List<String>) sessionScope.get("sGroupList");
            System.out.println("Begin inside onClickContinue sGroupListArr : "+sGroupListArr);
            sGroupListArr.remove(0);
            Object valgrp = sessionScope.put("sGroupList", sGroupListArr);
            System.out.println("End onClickContinue sGroupList : "+sessionScope.get("sGroupList"));
            int s = sGroupListArr.size();
            if(s != 0){
                callOperation("Create");
                sGroupListArr = (List<String>) sessionScope.get("sGroupList");
                dummyGroupCode = sGroupListArr.get(0);
                dummyGroupCodeTextBox.setValue(dummyGroupCode);
            }
            else{
                bv_continue.setVisible(false);
                bv_ohiForm.setVisible(false);
                System.out.println("All subgroups saved successfully");
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Info","All subgroups entries has been saved successfully");
                fc.addMessage(null, message);
            }
            
        }
        else{
            System.out.println("else of  onClickContinue: ");
        }
    }

    public void setDummyGroupCodeTextBox(RichInputText dummyGroupCodeTextBox) {
        this.dummyGroupCodeTextBox = dummyGroupCodeTextBox;
    }

    public RichInputText getDummyGroupCodeTextBox() {
        return dummyGroupCodeTextBox;
    }
    
    public void setBv_continue(RichButton bv_continue) {
        this.bv_continue = bv_continue;
    }

    public RichButton getBv_continue() {
        return bv_continue;
    }

    public void setBv_ohiForm(RichPanelFormLayout bv_ohiForm) {
        this.bv_ohiForm = bv_ohiForm;
    }

    public RichPanelFormLayout getBv_ohiForm() {
        return bv_ohiForm;
    }
}
