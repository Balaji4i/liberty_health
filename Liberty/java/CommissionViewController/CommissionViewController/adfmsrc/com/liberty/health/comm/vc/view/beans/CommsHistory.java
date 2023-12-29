package com.liberty.health.comm.vc.view.beans;

import com.core.generic.CoreActions;
import com.core.utils.ADFUtils;
import com.liberty.health.comm.vc.view.beans.MedwareSchemesLOV;


import com.liberty.health.comms.broker.beans.GenericTableSelectionHandler;

import com.liberty.health.comms.lov.GroupPerCountryLOVImpl;
import com.liberty.health.comms.lov.GroupPerCountryLOVRowImpl;
import com.liberty.health.comms.lov.MedwareSchemesImpl;
import com.liberty.health.comms.lov.MedwareSchemesRowImpl;

import java.io.ByteArrayOutputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.sql.SQLException;

import java.text.DateFormat;
import java.text.SimpleDateFormat;

import java.util.ArrayList;

import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;

import javax.faces.event.ValueChangeEvent;

import oracle.adf.model.BindingContext;
import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCIteratorBinding;
import oracle.adf.view.rich.component.rich.RichPopup;

import oracle.adf.view.rich.event.PopupCanceledEvent;

import oracle.jbo.Row;
import java.util.List;


import javax.faces.application.FacesMessage;
import javax.faces.model.SelectItem;

import oracle.adf.model.binding.DCDataControl;

import oracle.jbo.ApplicationModule;
import oracle.jbo.JboException;
import oracle.jbo.ViewObject;

import oracle.jbo.domain.BlobDomain;

import oracle.jbo.domain.Date;

import org.apache.myfaces.trinidad.context.RequestContext;
import org.apache.myfaces.trinidad.event.SelectionEvent;

public class CommsHistory extends CoreActions {
    private String pkeyId;
    String countryAttrib;
    String returnMsg; DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
    //FacesContext fc = FacesContext.getCurrentInstance();
    DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
    RequestContext afContext = RequestContext.getCurrentInstance();
    private RichPopup errorMsgPopUp;
    private RichPopup successMsgPopUp;

   

    public CommsHistory()  {
        super();
        
    }
    

    public void showDetailInformation(SelectionEvent selectionEvent) {
        //BindingContext bindingContext = BindingContext.getCurrent(); 
       
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsCalcSnapShotSummaryVO1Iterator");
        
        
        
        GenericTableSelectionHandler.makeCurrent(selectionEvent);
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();
        
        if(rowSelected.getAttribute("KeyField") != null) {
            pkeyId   = (String) rowSelected.getAttribute("KeyField");  
            
          //  System.out.println("Key value for the VO object is "+pkeyId);
            
            callOperation("setpKeyId");
        }
        
       
    }

    public void setPkeyId(String pkeyId) {
        this.pkeyId = pkeyId;
    }

    public String getPkeyId() {
        return pkeyId;
    }

    public void refreshDetail(ActionEvent actionEvent) {
       
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsCalcSnapShotSummaryVO1Iterator");
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        System.out.println("The value for the VO object is voTableData "+voTableData);
        Row rowSelected = voTableData.getCurrentRow();
        System.out.println("rowSelected "+rowSelected);
        if(rowSelected!=null && rowSelected.getAttribute("KeyField") != null) {
            pkeyId   = (String) rowSelected.getAttribute("KeyField");
          //System.out.println("Key value for the VO object is "+pkeyId);
            callOperation("setpKeyId");
        }
    }
    
    

    public void submitDmJob(ActionEvent actionEvent) {
        String jobName = null;
        
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsJobSubmitVO1Iterator");
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("JobName") != null) {
            jobName = (String) rowSelected.getAttribute("JobName");
          //  System.out.println("job name is "+jobName);
            if (jobName.equals("DATA_MIGRATION")) {
                callOperation("executeDmJob");
            } else 
            {
                callOperation("executeScheduledJob");
            } 
           
        }
        
      //  System.out.println("In comms history backing bean about to call execute DM Job");
       // System.out.println("FINISHED");
     //  returnMsg = (String) callOperation("executeDmJob");
     
     // RichPopup.PopupHints hints = new RichPopup.PopupHints();
     // this.getSuccessMsgPopUp().show(hints);
            

    }
    
    public void approveDmJob(ActionEvent actionEvent) {
      //  System.out.println("In comms history backing bean about to call execute DM Job");
        returnMsg = (String) callOperation("approveDmJob");
        if (returnMsg == null) {
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getSuccessMsgPopUp().show(hints);
            callOperation("Commit");
        } else {
            callOperation("Rollback");
            RichPopup.PopupHints hints = new RichPopup.PopupHints();
            this.getSuccessMsgPopUp().show(hints);
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

    public void setSuccessMsgPopUp(RichPopup successMsgPopUp) {
        this.successMsgPopUp = successMsgPopUp;
    }

    public RichPopup getSuccessMsgPopUp() {
        return successMsgPopUp;
    }
    
    public void cancelActionListener(PopupCanceledEvent popupCanceledEvent) {
        callOperation("Rollback");
        callOperation("Execute");
    }

    public void SchemeTypeValueChange(ValueChangeEvent valueChangeEvent) {
       String delimList = null;
       ArrayList<Object> selType = (ArrayList<Object>)valueChangeEvent.getNewValue();
      // System.out.println(selType);
     //   System.out.println("put into delimited list for input into proc "+selType.size());
       for (int i = 0; i < selType.size(); i++) {
          
         if (delimList != null) {
             delimList = delimList+","+selType.get(i).toString();
      //       System.out.println("delimlist "+delimList);
         } else {
             delimList = selType.get(i).toString();    
      //       System.out.println("delimlist "+delimList);
         }  
       }
       this.schemesDelimited = delimList;
    }
    
    
    public void GroupCodeValueChange(ValueChangeEvent valueChangeEvent) {
       String delimList = null;
       ArrayList<Object> selType = (ArrayList<Object>)valueChangeEvent.getNewValue();
      // System.out.println(selType);
      //  System.out.println("put into delimited list for input into proc "+selType.size());
       for (int i = 0; i < selType.size(); i++) {
          
         if (delimList != null) {
             delimList = delimList+","+selType.get(i).toString();
          //   System.out.println("delimlist "+delimList);
         } else {
             delimList = selType.get(i).toString();    
         //    System.out.println("delimlist "+delimList);
         }  
       }
       this.groupDelimited = delimList;
    }

    
    public void dateValueChange(ValueChangeEvent valueChangeEvent) {
       // System.out.println("Value Change Listener has fired");
      //  System.out.println("Value Change Listener has fired - old :"+valueChangeEvent.getOldValue().toString());
       // System.out.println("Value Change Listener has fired - new :"+valueChangeEvent.getNewValue().toString());
       
        if (valueChangeEvent.getNewValue() != null) {
            Date fromDateVal = (Date)valueChangeEvent.getNewValue();
            java.util.Date dateVal = fromDateVal.dateValue();
          //  System.out.println("Date Time - original value: " + dateVal);
            DateFormat dateFormat = new SimpleDateFormat("YYYYMMdd");
            String datetime = dateFormat.format(dateVal);
          //  System.out.println("Date Time: " + datetime);
            afContext.getPageFlowScope().put("pFromDate",datetime);
            
         }       
         this.GroupLOV();
       
    }
    
    public void CountryValueChange(ValueChangeEvent valueChangeEvent) {
       // System.out.println("Value Change Listener has fired");
       // System.out.println("Value Change Listener has fired - old :"+valueChangeEvent.getOldValue().toString());
       // System.out.println("Value Change Listener has fired - new :"+valueChangeEvent.getNewValue().toString());
       
        
       
         if (valueChangeEvent.getNewValue() != null) {
         //   System.out.println("selected country lov "+(String)valueChangeEvent.getNewValue().toString());
            String country = (String)valueChangeEvent.getNewValue().toString();
            afContext.getPageFlowScope().put("pCountryCode",country);
         }       
         this.MedwareLOV();
         this.GroupLOV();
       
    }
    
    public void MedwareLOV()
    {
   // System.out.println("after **** get Medware Schemes information - before anything");

    DCDataControl dc = dcBc.findDataControl( "CommsRunAMDataControl" );
    ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
    
    MedwareSchemesImpl vo = (MedwareSchemesImpl)appModule.findViewObject("MedwareSchemesVO1");
         
   // System.out.println("after get Medware Schemes information");
    
    
    if(afContext.getPageFlowScope().get("pCountryCode") != null) {
        
        
        countryAttrib = afContext.getPageFlowScope().get("pCountryCode").toString();
          
     //   System.out.println("after get Country "+countryAttrib);

        vo.setNamedWhereClauseParam("pCountry",countryAttrib);
        vo.executeQuery();

        list.clear(); 

          while (vo.hasNext()) {  
              MedwareSchemesRowImpl row = (MedwareSchemesRowImpl)vo.next();
         //     System.out.println("scheme value is "+row.getSScheme().toString());
            //   System.out.println("scheme name value is "+row.getSName().toString());
             // System.out.println("scheme is "+vo.getCurrentRow().getAttribute("SScheme").toString());
              list.add(new SelectItem(row.getSScheme().toString(),
                                      row.getSScheme().toString()+'-'+row.getSName().toString()
                                     )
                      );
          }      
       
      }
    }
    
    public void GroupLOV()
    {
  //  System.out.println("after **** getGroup Code information - before anything");

    DCDataControl dc = dcBc.findDataControl( "CommsRunAMDataControl" );
    ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
    
     GroupPerCountryLOVImpl Groupvo = (GroupPerCountryLOVImpl)appModule.findViewObject("GroupPerCountryLOV1");
        
  //  System.out.println("after get Group information");
    
    
    if(countryAttrib != null) {
        
        String fromDate     =  afContext.getPageFlowScope().get("pFromDate").toString();   
        System.out.println("after get Country "+countryAttrib);
        System.out.println("after get fromDate "+fromDate);

        Groupvo.setNamedWhereClauseParam("pCountryCode",countryAttrib);
        Groupvo.setNamedWhereClauseParam("pFromDate",fromDate);  
        Groupvo.executeQuery();
        
      //  System.out.println("Query Executed "+fromDate);
    
        Countrylist.clear();
        
        while (Groupvo.hasNext()) {  
            GroupPerCountryLOVRowImpl groupRow = (GroupPerCountryLOVRowImpl)Groupvo.next();
             
             
          //  System.out.println("Group value is "+groupRow.getGroupCode().toString());
           // System.out.println("scheme is "+vo.getCurrentRow().getAttribute("SScheme").toString());
            Countrylist.add(new SelectItem(groupRow.getGroupCode().toString(),
                                    groupRow.getGroupCode().toString()+'-'+groupRow.getGroupName().toString()
                                   )
                    );
        }      
      }
    }
    
    public List<SelectItem> list = new ArrayList<SelectItem>();
    
    public List<SelectItem> Countrylist = new ArrayList<SelectItem>();
    
    public void setList(List<SelectItem> list) {
    
    }
    public synchronized List<SelectItem> getList() {
    return list;
    }
    
    public synchronized List<SelectItem> getCountrylist() {
    return Countrylist;
    }
    
    public String schemesDelimited = new String();
    
    public String groupDelimited = new String();
    
    public synchronized String getDelimtedString() {
        return schemesDelimited;
    }
    
    public synchronized String getGroupDelimtedString() {
        return groupDelimited;
    }

    public void refreshJobData(ActionEvent actionEvent) {
        DCBindingContainer bindings = (DCBindingContainer)BindingContext.getCurrent().getCurrentBindingsEntry();
        //FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        dcItteratorBindings.executeQuery();
        
        
    }
    
    public void downloadLogFile(FacesContext facesContext, OutputStream outputStream) {
        //outputStream = this.downloadFile("log");
        System.out.println("called the download log file");
        String JobId = null;
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

            
      //      if( afContext.getPageFlowScope().get("pFileName").toString() != null){       
        if(rowSelected.getAttribute("JobName") != null) {
            JobId = (String) rowSelected.getAttribute("JobId").toString();
      //      System.out.println("job id is "+JobId);
        //    System.out.println("Actual download log File Name is "+JobId+"."+"html");
            afContext.getPageFlowScope().put("pFileName",JobId+"."+"html");
            
            BlobDomain blob = (BlobDomain)callOperation("getFile");
                    
            InputStream in = blob.getBinaryStream();
            
            byte[] buff = blob.getBytes(1,(int)blob.getLength());
            
            try {
                outputStream.write(buff);
                outputStream.close();
            } catch (java.io.IOException e) {
                FacesContext fc = FacesContext.getCurrentInstance();
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Information", "File Not Found");
                fc.addMessage(null, message);
                e.printStackTrace();
                e.getLocalizedMessage();
            } 
        }
    }

    public void downloadOutputFile(FacesContext facesContext, OutputStream outputStream) {
     //   System.out.println("called the download output file");
        String JobId = null;
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("JobName") != null) {
       //   if( afContext.getPageFlowScope().get("pOutFileName").toString() != null){
       
            JobId = (String) rowSelected.getAttribute("JobId").toString();
          //  System.out.println("job id is "+JobId);
          //  System.out.println("File Name is "+JobId+"."+"csv");
           // afContext.getPageFlowScope().put("pFileName",JobId+"."+"csv");
            afContext.getPageFlowScope().put("pOutFileName",JobId+"."+"csv");
            
            BlobDomain blob = (BlobDomain)callOperation("getOutputFile");
                    
            InputStream in = blob.getBinaryStream();
            
            byte[] buff = blob.getBytes(1,(int)blob.getLength());
            
            try {
                outputStream.write(buff);
                outputStream.close();
            } catch (java.io.IOException e) {
                FacesContext fc = FacesContext.getCurrentInstance();
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Information", "File Not Found");
                fc.addMessage(null, message);
                e.printStackTrace();
                e.getLocalizedMessage();
            } 
        }
        }

    public OutputStream downloadFile(String fileExtension) {
        OutputStream outputStream = new ByteArrayOutputStream();
        String JobId = null;
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("JobName") != null) {
       // if( afContext.getPageFlowScope().get("pOutFileName").toString() != null){
            JobId = (String) rowSelected.getAttribute("JobId").toString();
          //  System.out.println("job id is "+JobId);
          //  System.out.println("File Name is "+JobId+"."+fileExtension);
            afContext.getPageFlowScope().put("pFileName",JobId+".html");
            BlobDomain blob = (BlobDomain)callOperation("getOutputFile");
                    
            InputStream in = blob.getBinaryStream();
            
            byte[] buff = blob.getBytes(1,(int)blob.getLength());
            
            try {
                outputStream.write(buff);
                outputStream.close();
            } catch (java.io.IOException e) {
                FacesContext fc = FacesContext.getCurrentInstance();
                FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Information", "File Not Found");
                fc.addMessage(null, message);
                e.printStackTrace();
                e.getLocalizedMessage();
            } 
        }
        return outputStream;
    }


    public String approveCommsHistDM() {
        
       // DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsDMCommsHistoryVO1Iterator");
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsDMSnapshotHistoryVO1Iterator");
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("CountryCode") != null) {
            
         //   System.out.println("submitting the dm approval run");
            afContext.getPageFlowScope().put("pCountryCode",(String) rowSelected.getAttribute("CountryCode").toString()); 
            afContext.getPageFlowScope().put("pStage",4);
            
         //   System.out.println("submitting the dm approval run");
            callOperation("executeApproveDMRun");
        }    
        return null;
    }
    
    public String approveInvoicesDM() {
        
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsDMInvoiceHistoryVO1Iterator");
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("CountryCode") != null) {
            
          //  System.out.println("submitting the dm approval run");
            afContext.getPageFlowScope().put("pCountryCode",(String) rowSelected.getAttribute("CountryCode").toString()); 
            afContext.getPageFlowScope().put("pStage",6);
            
         //   System.out.println("submitting the dm approval run");
            callOperation("executeApproveDMRun");
        }    
        return null;
    }
    
    public String approveCommsUpdateDM() {
        
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("CommsDMInvoiceNoUpdateVO1Iterator");
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("CountryCode") != null) {
            
        //    System.out.println("submitting the dm approval run");
            afContext.getPageFlowScope().put("pCountryCode",(String) rowSelected.getAttribute("CountryCode").toString()); 
            afContext.getPageFlowScope().put("pStage",5);
            
         //   System.out.println("submitting the dm update comms invoice approval run");
            callOperation("executeApproveDMRun");
        }    
        return null;
    }

    public String getLogFileName() {
    //    System.out.println("setting log file name");
        String JobId = null;
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("JobName") != null) {
            JobId = (String) rowSelected.getAttribute("JobId").toString();
      //      System.out.println("job id is "+JobId);
      //      System.out.println("File Name is "+JobId+"."+"html");
            afContext.getPageFlowScope().put("pFileName",JobId+"."+"html");
        //    afContext.getPageFlowScope().put("pOutFileName",JobId+"."+"html");
          return JobId+"."+"html";
        }   
        return null;
    }
    
    public String getOutputFileName() {
        System.out.println("**setting log file name");
        String JobId = null;
        DCIteratorBinding dcItteratorBindings = bindings.findIteratorBinding("AllJobsSubmittedRunDetailsVO1Iterator");
        
        
        ViewObject voTableData = dcItteratorBindings.getViewObject();
        
        Row rowSelected = voTableData.getCurrentRow();

        
        if(rowSelected.getAttribute("JobName") != null) {
            JobId = (String) rowSelected.getAttribute("JobId").toString();
       //     System.out.println("** am i set first job id is "+JobId);
       //     System.out.println("** am i set first File Name is "+JobId+"."+"csv");
          //  afContext.getPageFlowScope().put("pFileName",JobId+"."+"csv");
            afContext.getPageFlowScope().put("pOutFileName",JobId+"."+"csv");
          return JobId+"."+"csv";
        }   
        return null;
    }
    
    public void submitFusionPremiums(ActionEvent actionEvent) {
       
        callOperation("submitJob");
         
        
     //   System.out.println("In comms history backing bean about to call execute DM Job");
     //   System.out.println("FINISHED");

            

    }

    public void submitPayablesJob(ActionEvent actionEvent) {
        callOperation("submitFusionPayablesImport");
    }
}
