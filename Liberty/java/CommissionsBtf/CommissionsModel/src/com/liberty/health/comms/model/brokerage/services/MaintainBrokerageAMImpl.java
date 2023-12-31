package com.liberty.health.comms.model.brokerage.services;

import com.core.model.services.classes.CoreApplicationModuleImpl;


import com.core.model.vo.classes.CoreViewObjectImpl;

import com.core.utils.ADFUtils;
import com.core.utils.DateConversionUtil;

import com.liberty.health.comms.lov.AddressTypeLovViewImpl;
import com.liberty.health.comms.lov.MedwareSchemesImpl;
import com.liberty.health.comms.model.broker.vo.BrokerVOImpl;
import com.liberty.health.comms.model.broker.vo.CompanyAddressVOImpl;
import com.liberty.health.comms.model.broker.vo.CompanyBankDetailsVOImpl;
import com.liberty.health.comms.model.broker.vo.CompanyBankDetailsVORowImpl;
import com.liberty.health.comms.model.broker.vo.CompanyContactVOImpl;
import com.liberty.health.comms.model.broker.vo.CompanyRegVOImpl;
import com.liberty.health.comms.model.brokerage.services.common.MaintainBrokerageAM;
import com.liberty.health.comms.model.brokerage.vo.CommsPartialReceiptApproveVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CommsPartialReceiptInactiveVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CommsPartialReceiptVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CommsPartialReceiptVORowImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyAccreditationVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCheckBrokerageNameVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCheckBrokerageNameVORowImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCheckPrefCurrencyVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCommentsVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCommentsVORowImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCorrMultinatVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyCountryVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyFeeVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyFunctionVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyFunctionVORowImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyMultinationalRoViewImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyRoViewImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyTableTypeVOImpl;
import com.liberty.health.comms.model.brokerage.vo.CompanyTableVOImpl;
import com.liberty.health.comms.model.brokerage.vo.SystemParameterVOImpl;
import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVOImpl;
import com.liberty.health.comms.model.vo.ApprovalsVOImpl;
import com.liberty.health.comms.model.vo.CompanyVOImpl;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import java.util.Date;

import javax.faces.application.FacesMessage;

import javax.faces.context.FacesContext;

import oracle.adf.model.binding.DCBindingContainer;
import oracle.adf.model.binding.DCDataControl;

import oracle.jbo.ApplicationModule;
import oracle.jbo.JboException;
import oracle.jbo.Row;
import oracle.jbo.RowSetIterator;
import oracle.jbo.domain.Timestamp;
import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Thu Jun 15 10:34:31 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class MaintainBrokerageAMImpl extends CoreApplicationModuleImpl implements MaintainBrokerageAM {
    private static int VARCHAR = Types.VARCHAR;

    /**
     * This is the default constructor (do not remove).
     */
    public MaintainBrokerageAMImpl() {
    }

    /**
     * Container's getter for CompanyAddressByPkView.
     * @return CompanyAddressByPkView
     */
    public CompanyAddressVOImpl getCompanyAddressByPkView() {
        return (CompanyAddressVOImpl) findViewObject("CompanyAddressByPkView");
    }


    /**
     * Container's getter for CompanyContactByPkView.
     * @return CompanyContactByPkView
     */
    public CompanyContactVOImpl getCompanyContactByPkView() {
        return (CompanyContactVOImpl) findViewObject("CompanyContactByPkView");
    }

    /**
     * Container's getter for CompanyRegByPkView.
     * @return CompanyRegByPkView
     */
    public CompanyRegVOImpl getCompanyRegByPkView() {
        return (CompanyRegVOImpl) findViewObject("CompanyRegByPkView");
    }

    /**
     * Container's getter for CompanyFeeByBrokerageView.
     * @return CompanyFeeByBrokerageView
     */
    public CompanyFeeVOImpl getCompanyFeeByBrokerageView() {
        return (CompanyFeeVOImpl) findViewObject("CompanyFeeByBrokerageView");
    }


    /**
     * Container's getter for AllCompanyRoView.
     * @return AllCompanyRoView
     */
    public CompanyRoViewImpl getAllCompanyRoView() {
        return (CompanyRoViewImpl) findViewObject("AllCompanyRoView");
    }

    /**
     * Container's getter for CompanyByPkView.
     * @return CompanyByPkView
     */
    public CompanyVOImpl getCompanyByPkView() {
        return (CompanyVOImpl) findViewObject("CompanyByPkView");
    }


    /**
     * Container's getter for BrokersByCompanyView.
     * @return BrokersByCompanyView
     */
    public BrokerVOImpl getBrokersByCompanyView() {
        return (BrokerVOImpl) findViewObject("BrokersByCompanyView");
    }

    /**
     * Container's getter for CompanyAccreditationByCompanyView.
     * @return CompanyAccreditationByCompanyView
     */
    public CompanyAccreditationVOImpl getCompanyAccreditationByCompanyView() {
        return (CompanyAccreditationVOImpl) findViewObject("CompanyAccreditationByCompanyView");
    }

    /**
     * Container's getter for CompanyCommentsByCompanyView.
     * @return CompanyCommentsByCompanyView
     */
    public CompanyCommentsVOImpl getCompanyCommentsByCompanyView() {
        return (CompanyCommentsVOImpl) findViewObject("CompanyCommentsByCompanyView");
    }


    /**
     * Container's getter for CompanyFeeByCompanyView.
     * @return CompanyFeeByCompanyView
     */
    public CompanyFeeVOImpl getCompanyFeeByCompanyView() {
        return (CompanyFeeVOImpl) findViewObject("CompanyFeeByCompanyView");
    }


    /**
     * Container's getter for FkCompanyVoBrokerVoLink1.
     * @return FkCompanyVoBrokerVoLink1
     */
    public ViewLinkImpl getFkCompanyVoBrokerVoLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyVoBrokerVoLink1");
    }

    /**
     * Container's getter for FkCompanyAccCompanyLink1.
     * @return FkCompanyAccCompanyLink1
     */
    public ViewLinkImpl getFkCompanyAccCompanyLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyAccCompanyLink1");
    }

    /**
     * Container's getter for FkCompanyCommentsCompanyLink1.
     * @return FkCompanyCommentsCompanyLink1
     */
    public ViewLinkImpl getFkCompanyCommentsCompanyLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyCommentsCompanyLink1");
    }


    /**
     * Container's getter for FkCompanyFeeCompanyLink1.
     * @return FkCompanyFeeCompanyLink1
     */
    public ViewLinkImpl getFkCompanyFeeCompanyLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyFeeCompanyLink1");
    }


    /**
     *
     *
     * @param companyIdNo
     * @param commentDesc
     */
    public void createCompanyComment(oracle.jbo.domain.Number companyIdNo, String commentDesc) {
        CompanyCommentsVOImpl vo = this.getCreateCompanyCommentsView();
        CompanyCommentsVORowImpl row = (CompanyCommentsVORowImpl) vo.createRow();
        row.setCompanyIdNo(companyIdNo);
        row.setCommentDesc(commentDesc);
    }


    /**
     *
     *
     * @param companyIdNo
     * @param commentDesc
     */
    public void createCompanyFunction(Integer companyIdNo, Integer companyTableIdNo, Integer companyTableTypeIdNo) {
        CompanyFunctionVOImpl vo = this.getCreateCompanyFunctionView();
        CompanyFunctionVORowImpl row = (CompanyFunctionVORowImpl) vo.createRow();
        row.setCompanyIdNo(companyIdNo);
        row.setCompanyTableIdNo(companyTableIdNo);
        row.setCompanyTableTypeIdNo(companyTableTypeIdNo);
        vo.updateEffDates(companyIdNo, companyTableTypeIdNo, new Timestamp(System.currentTimeMillis()));
    }


    /**
     * Container's getter for CompanyCommentsVO1.
     * @return CompanyCommentsVO1
     */
    public CompanyCommentsVOImpl getCreateCompanyCommentsView() {
        return (CompanyCommentsVOImpl) findViewObject("CreateCompanyCommentsView");
    }
    
    
    public String validatePartialRec( String companyIdNo, 
                                   String countryCode, 
                                   String groupCode,
                                   oracle.jbo.domain.Date effStartDate,
                                   oracle.jbo.domain.Date effEndDate,
                                   String username) {
        
       System.out.println(companyIdNo); 
       System.out.println(countryCode); 
       System.out.println(groupCode);
       System.out.println(effStartDate);
       System.out.println(effEndDate);
        
        java.sql.Date newEndDate;
        java.sql.Date newStartDate;
        FacesContext fc = FacesContext.getCurrentInstance();
        DCBindingContainer dcBc = (DCBindingContainer) ADFUtils.getBindingContainer();
        DCDataControl dc = dcBc.findDataControl( "MaintainBrokerageAMDataControl" );
        ApplicationModule appModule = (ApplicationModule)dc.getDataProvider();
            
        CommsPartialReceiptVOImpl vo = (CommsPartialReceiptVOImpl)appModule.findViewObject("CommsPartialReceiptVO1");
        
        vo.setWhereClause("(active_yn = 'N' and  approved_by is null)"); 
        vo.executeQuery();      
        
        RowSetIterator rowCurr = vo.createRowSetIterator(null);
        rowCurr.reset();
            
        
        while (rowCurr.hasNext()) {  
            
            CommsPartialReceiptVORowImpl rowNew = (CommsPartialReceiptVORowImpl)rowCurr.next();
            newEndDate = DateConversionUtil.convertToJSDate(rowNew.getEffectiveEndDate()); 
            newStartDate = DateConversionUtil.convertToJSDate(rowNew.getEffectiveStartDate());
            
            System.out.println("executed query first  "+rowNew.getCompanyIdNo());
            
            if (newEndDate.before(newStartDate)) {
                
               FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "The end date cannot be prior to the start date");
               fc.addMessage(null, message);     
               return "Error";
            }
            
            System.out.println("get the other records");
            CommsPartialReceiptVOImpl voPrev = (CommsPartialReceiptVOImpl)appModule.findViewObject("CommsPartialReceiptVO1");
                  
            //iterate through other combinations of old records for current
            //criteria to ensure that the data is correct
            System.out.println("get the other records comp "+rowNew.getCompanyIdNo());
            System.out.println("get the other records country "+rowNew.getCountryCode());
            System.out.println("get the other records Group "+rowNew.getGroupCode());
            voPrev.setWhereClause("(company_id_no = :1 and country_code = :2 and group_code = :3)"); 
            voPrev.setWhereClauseParam(0, rowNew.getCompanyIdNo());
            voPrev.setWhereClauseParam(1, rowNew.getCountryCode());
            voPrev.setWhereClauseParam(2, rowNew.getGroupCode());
            voPrev.executeQuery();
            
            RowSetIterator rowIt = vo.createRowSetIterator(null);
            rowIt.reset();
            
            while (rowIt.hasNext()) {  
                System.out.println("in the next section for partial receipts ");
                CommsPartialReceiptVORowImpl row = (CommsPartialReceiptVORowImpl)rowIt.next();
                
                java.sql.Date oldEndDate = DateConversionUtil.convertToJSDate(row.getEffectiveEndDate()); 
                java.sql.Date oldStartDate = DateConversionUtil.convertToJSDate(row.getEffectiveStartDate());
                System.out.println("get the end date "+oldEndDate);
                System.out.println("get the end date "+oldStartDate);
                if (newStartDate.before(oldEndDate) && newStartDate.after(oldStartDate)) {
                    FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please ensure there are no overlapping date ranges");
                    fc.addMessage(null, message);     
                    return "Error";
                }
                if (newEndDate.before(oldEndDate) && newEndDate.before(oldStartDate)) {
                    FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Please ensure there are no overlapping date ranges and end date must be after the start date");
                    fc.addMessage(null, message);    
                    return "Error";
                }   
                
            }    
        }
        
        
               
         
            System.out.println("finished "+companyIdNo);   
            return "Success";
        }    
        
    /**
         * Container's getter for CompanyBankDetailsByPkView.
         * @return CompanyBankDetailsByPkView
         */
        public CompanyBankDetailsVOImpl getCompanyBankDetailsByPkView() {
            return (CompanyBankDetailsVOImpl) findViewObject("CompanyBankDetailsByPkView");
        }
    

    public void approveBankingDetails(oracle.jbo.domain.Number companyIdNo, String countryCode, Date currentDate,
                                      String username) {
        CompanyBankDetailsVOImpl vo = this.getCompanyBankDetailsByPkView();
        //View Criteria with bind variable 'Bind_deptId'
        vo.setApplyViewCriteriaName("CompanyBankDetailsByPKViewCritiera");
        vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo.intValue());
        vo.setNamedWhereClauseParam("pCountryCode", countryCode);
        vo.setNamedWhereClauseParam("pCurrentDate", currentDate);
        vo.executeQuery();
        CompanyBankDetailsVORowImpl row = (CompanyBankDetailsVORowImpl) vo.getCurrentRow();
        row.setAuthUsername(username);
        this.createCompanyComment(companyIdNo, username + " approved Banking Details ");
    }
    
    /**
     * T.Percy added call to check if a similar brokerage name already exists 
     * to prevent capturing of duplicate brokerages
     */
    public String checkBrokerageName(String companyName) {
        System.out.println("in Check Brokerage Name "+companyName);
        String possibleMatches = null;
        
        CompanyCheckBrokerageNameVOImpl vo = this.getCompanyCheckBrokerageNameVO();
        vo.setNamedWhereClauseParam("pCompName", companyName.toString());
        vo.executeQuery();
               
        Row r = vo.first();
        
        
        if (r != null) {
           
            possibleMatches = "<html><body><p>Possible Brokerages Already Exist</p>";
            System.out.println("got first row "); 
            possibleMatches = possibleMatches + "<p>"+r.getAttribute("CompanyName").toString()+"</p>";   
            System.out.println("got first row "+companyName); 
        }
        
        
     //   RowSetIterator iter = vo.createRowSetIterator(null);
        
        while (vo.hasNext()){
            System.out.println("in next row "); 
            r = vo.next();
            possibleMatches = possibleMatches + "<p>"+r.getAttribute("CompanyName").toString()+"</p>";
            System.out.println("in next row - possible matches "+possibleMatches);
        }
        if (possibleMatches != null) {
            possibleMatches = possibleMatches+"</body></html>"; 
        }
       
       return possibleMatches;

    }
    

    /**
     * Container's getter for CompanyCommentsVO2.
     * @return CompanyCommentsVO2
     */
    public CompanyCommentsVOImpl getCompanyCommentsView() {
        return (CompanyCommentsVOImpl) findViewObject("CompanyCommentsView");
    }

    /**
     * Container's getter for CompanyAccreditationVO1.
     * @return CompanyAccreditationVO1
     */
    public CompanyAccreditationVOImpl getCompanyAccreditationByPkView() {
        return (CompanyAccreditationVOImpl) findViewObject("CompanyAccreditationByPkView");
    }


    /**
     * Container's getter for CompanyCountryVO1.
     * @return CompanyCountryVO1
     */
    public CompanyCountryVOImpl getCompanyCountryByCompanyView() {
        return (CompanyCountryVOImpl) findViewObject("CompanyCountryByCompanyView");
    }

    /**
     * Container's getter for AddressTypeLovView1.
     * @return AddressTypeLovView1
     */
    public AddressTypeLovViewImpl getAllAddressTypeLovView() {
        return (AddressTypeLovViewImpl) findViewObject("AllAddressTypeLovView");
    }


    /**
     * Container's getter for CompanyCountryVO1.
     * @return CompanyCountryVO1
     */
    public com.liberty.health.comms.model.vo.CompanyCountryVOImpl getCompanyCountryView() {
        return (com.liberty.health.comms.model.vo.CompanyCountryVOImpl) findViewObject("CompanyCountryView");
    }

    /**
     * Container's getter for FkCompanyCompanyCountryLink1.
     * @return FkCompanyCompanyCountryLink1
     */
    public ViewLinkImpl getFkCompanyCompanyCountryLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyCompanyCountryLink1");
    }

    /**
     * Calls an external stored function
     * @param sqlReturnType
     * @param stmt
     * @param bindVars
     * @return
     */
    protected Object callStoredFunction(int sqlReturnType, String stmt, Object[] bindVars) {
        CallableStatement st = null;
        try { // 1. Create a JDBC CallabledStatement
            st = getDBTransaction().createCallableStatement("BEGIN ? := " + stmt + ";END;", 0);
            // 2. Register the first bind variable for the return value
            st.registerOutParameter(1, sqlReturnType);
            if (bindVars != null) { // 3. Loop over values for the bind variables passed in, if any
                for (int z = 0; z < bindVars.length; z++) {
                    // 4. Set the value of user-supplied bind vars in the stmt
                    st.setObject(z + 2, bindVars[z]);
                }
            }
            // 5. Set the value of user-supplied bind vars in the stmt
            st.executeUpdate();
            // 6. Return the value of the first bind variable
            return st.getObject(1);
        } catch (SQLException e) {
            throw new JboException(e);
        } finally {
            if (st != null) {
                try {
                    // 7. Close the statement
                    st.close();
                } catch (SQLException e) {
                }
            }
        }
    }

    /**
     *Method calls a database function and returns a number as string
     * @return
     */
    public String getMaxMultinetAmount() {
        String returnValue = null;

        Object retObj =
            callStoredFunction(VARCHAR,
                               "GET_SYSTEM_PARAMETER(P_SYSTEM_NAME => ?, P_PARAMETER_SECTION => ?,P_PARAMETER_KEY => ?)",
                               new Object[] { "LB_HEALTH_COMMS", "BROKER", "MAX_MULTI_NET_AMT" });
        if (retObj != null) {
            returnValue = retObj.toString();
        }
        return returnValue;

    }
    
    

    /**
     *
     * @return
     */
    public String getCommunicationHubLink() {
        String returnValue = null;
        Object retObj =
            callStoredFunction(VARCHAR,
                               "GET_SYSTEM_PARAMETER(P_SYSTEM_NAME => ?, P_PARAMETER_SECTION => ?,P_PARAMETER_KEY => ?)",
                               new Object[] { "LB_HEALTH_COMMS", "COMMS_HUB", "SERVER_LINK" });
        if (retObj != null) {
            returnValue = retObj.toString();
        }
        return returnValue;
    }

    /**
     *
     * @return
     */
    public String getCommunicationHubSourceName() {
        String returnValue = null;
        Object retObj =
            callStoredFunction(VARCHAR,
                               "GET_SYSTEM_PARAMETER(P_SYSTEM_NAME => ?, P_PARAMETER_SECTION => ?,P_PARAMETER_KEY => ?)",
                               new Object[] { "LB_HEALTH_COMMS", "COMMS_HUB", "SOURCE_NAME" });
        if (retObj != null) {
            returnValue = retObj.toString();
        }
        return returnValue;
    }

    /**
     * Container's getter for CompanyTableVO1.
     * @return CompanyTableVO1
     */
    public CompanyTableVOImpl getCompanyTableByPkView() {
        return (CompanyTableVOImpl) findViewObject("CompanyTableByPkView");
    }

    /**
     * Container's getter for CompanyTableTypeVO1.
     * @return CompanyTableTypeVO1
     */
    public CompanyTableTypeVOImpl getCompanyTableTypeVO1() {
        return (CompanyTableTypeVOImpl) findViewObject("CompanyTableTypeVO1");
    }

    /**
     * Container's getter for CompanyTableTypeByTableView.
     * @return CompanyTableTypeByTableView
     */
    public CompanyTableTypeVOImpl getCompanyTableTypeByTableView() {
        return (CompanyTableTypeVOImpl) findViewObject("CompanyTableTypeByTableView");
    }

    /**
     * Container's getter for CompanyTableVO1.
     * @return CompanyTableVO1
     */
    public CompanyTableVOImpl getAllCompanyTableView() {
        return (CompanyTableVOImpl) findViewObject("AllCompanyTableView");
    }


    /**
     * Container's getter for CompanyFunctionVO1.
     * @return CompanyFunctionVO1
     */
    public CompanyFunctionVOImpl getCreateCompanyFunctionView() {
        return (CompanyFunctionVOImpl) findViewObject("CreateCompanyFunctionView");
    }


    /**
     * Container's getter for CompanyFunctionVO1.
     * @return CompanyFunctionVO1
     */
    public CompanyFunctionVOImpl getCompanyFunctionByPkView() {
        return (CompanyFunctionVOImpl) findViewObject("CompanyFunctionByPkView");
    }

    /**
     * Container's getter for CompanyFunctionVO2.
     * @return CompanyFunctionVO2
     */
    public CompanyFunctionVOImpl getCompanyStatementByPkView() {
        return (CompanyFunctionVOImpl) findViewObject("CompanyStatementByPkView");
    }

    /**
     * Container's getter for CompanyFunctionVO1.
     * @return CompanyFunctionVO1
     */
    public CompanyFunctionVOImpl getCompanyStatusByPkView() {
        return (CompanyFunctionVOImpl) findViewObject("CompanyStatusByPkView");
    }

    /**
     * Container's getter for CompanyFunctionVO2.
     * @return CompanyFunctionVO2
     */
    public CompanyFunctionVOImpl getCompanyTypeByPkView() {
        return (CompanyFunctionVOImpl) findViewObject("CompanyTypeByPkView");
    }

    /**
     * Container's getter for CompanyAddressAuditRoView1.
     * @return CompanyAddressAuditRoView1
     */
    public CoreViewObjectImpl getCompanyAddressAuditRoView() {
        return (CoreViewObjectImpl) findViewObject("CompanyAddressAuditRoView");
    }

    /**
     * Container's getter for FkCompAddressAuditCompAddressLink1.
     * @return FkCompAddressAuditCompAddressLink1
     */
    public ViewLinkImpl getFkCompAddressAuditCompAddressLink1() {
        return (ViewLinkImpl) findViewLink("FkCompAddressAuditCompAddressLink1");
    }


    /**
     * Container's getter for CompanyCountryAuditRoView1.
     * @return CompanyCountryAuditRoView1
     */
    public CoreViewObjectImpl getCompanyCountryAuditView() {
        return (CoreViewObjectImpl) findViewObject("CompanyCountryAuditView");
    }

    /**
     * Container's getter for FkCompanyCountryAuditCompanyCountryLink1.
     * @return FkCompanyCountryAuditCompanyCountryLink1
     */
    public ViewLinkImpl getFkCompanyCountryAuditCompanyCountryLink1() {
        return (ViewLinkImpl) findViewLink("FkCompanyCountryAuditCompanyCountryLink1");
    }


    /**
     * Container's getter for CompanyRegAuditRoView1.
     * @return CompanyRegAuditRoView1
     */
    public CoreViewObjectImpl getCompanyRegAuditView() {
        return (CoreViewObjectImpl) findViewObject("CompanyRegAuditView");
    }

    /**
     * Container's getter for FkCompRegAuditCompRegLink1.
     * @return FkCompRegAuditCompRegLink1
     */
    public ViewLinkImpl getFkCompRegAuditCompRegLink1() {
        return (ViewLinkImpl) findViewLink("FkCompRegAuditCompRegLink1");
    }

    /**
     * Container's getter for CompanyTableAuditRoView1.
     * @return CompanyTableAuditRoView1
     */
    public CoreViewObjectImpl getCompanyTableAuditView() {
        return (CoreViewObjectImpl) findViewObject("CompanyTableAuditView");
    }

    /**
     * Container's getter for FkCompTableAuditCompTableLink1.
     * @return FkCompTableAuditCompTableLink1
     */
    public ViewLinkImpl getFkCompTableAuditCompTableLink1() {
        return (ViewLinkImpl) findViewLink("FkCompTableAuditCompTableLink1");
    }

    /**
     * Container's getter for CompanyTableTypeAuditRoView1.
     * @return CompanyTableTypeAuditRoView1
     */
    public CoreViewObjectImpl getCompanyTableTypeAuditView() {
        return (CoreViewObjectImpl) findViewObject("CompanyTableTypeAuditView");
    }

    /**
     * Container's getter for FkCompTableTypeAuditCompTableTypeLink1.
     * @return FkCompTableTypeAuditCompTableTypeLink1
     */
    public ViewLinkImpl getFkCompTableTypeAuditCompTableTypeLink1() {
        return (ViewLinkImpl) findViewLink("FkCompTableTypeAuditCompTableTypeLink1");
    }


    /**
     * Container's getter for CompanyFeeAuditRoView1.
     * @return CompanyFeeAuditRoView1
     */
    public CoreViewObjectImpl getCompanyFeeAuditView() {
        return (CoreViewObjectImpl) findViewObject("CompanyFeeAuditView");
    }

    /**
     * Container's getter for FkCompFeeAuditCompFeeLink1_1.
     * @return FkCompFeeAuditCompFeeLink1_1
     */
    public ViewLinkImpl getFkCompFeeAuditCompFeeLink1_1() {
        return (ViewLinkImpl) findViewLink("FkCompFeeAuditCompFeeLink1_1");
    }

    /**
     * Container's getter for CompanyFunctionVO1.
     * @return CompanyFunctionVO1
     */
    public CompanyFunctionVOImpl getCompanyAttributesByCompanyView() {
        return (CompanyFunctionVOImpl) findViewObject("CompanyAttributesByCompanyView");
    }

    /**
     * Container's getter for CompanyCurrentAttributesRoView1.
     * @return CompanyCurrentAttributesRoView1
     */
    public CompanyMultinationalRoViewImpl getMultinationalAttributeView() {
        return (CompanyMultinationalRoViewImpl) findViewObject("MultinationalAttributeView");
    }

    /**
     * Container's getter for FkCompCurAttRoCompanyLink1.
     * @return FkCompCurAttRoCompanyLink1
     */
    public ViewLinkImpl getFkCompCurAttRoCompanyLink1() {
        return (ViewLinkImpl) findViewLink("FkCompCurAttRoCompanyLink1");
    }

    /**
     * Container's getter for CompanyAuditRoView1.
     * @return CompanyAuditRoView1
     */
    public CoreViewObjectImpl getCompanyAuditRoView() {
        return (CoreViewObjectImpl) findViewObject("CompanyAuditRoView");
    }

    /**
     * Container's getter for FkComAuditCompLink1.
     * @return FkComAuditCompLink1
     */
    public ViewLinkImpl getFkComAuditCompLink1() {
        return (ViewLinkImpl) findViewLink("FkComAuditCompLink1");
    }

    /**
     * Container's getter for CompanyAuditRoView1.
     * @return CompanyAuditRoView1
     */
    public CoreViewObjectImpl getCompanyAuditRoView1() {
        return (CoreViewObjectImpl) findViewObject("CompanyAuditRoView1");
    }

    /**
     * Container's getter for FkCompAuditCompRoLink1.
     * @return FkCompAuditCompRoLink1
     */
    public ViewLinkImpl getFkCompAuditCompRoLink1() {
        return (ViewLinkImpl) findViewLink("FkCompAuditCompRoLink1");
    }

    /**
     * Container's getter for CompanyAccreditationAuditRoView1.
     * @return CompanyAccreditationAuditRoView1
     */
    public CoreViewObjectImpl getCompanyAccreditationAuditRoView() {
        return (CoreViewObjectImpl) findViewObject("CompanyAccreditationAuditRoView");
    }

    /**
     * Container's getter for FkCompAccAuditCompAccredLink1.
     * @return FkCompAccAuditCompAccredLink1
     */
    public ViewLinkImpl getFkCompAccAuditCompAccredLink1() {
        return (ViewLinkImpl) findViewLink("FkCompAccAuditCompAccredLink1");
    }

    /**
     * Container's getter for CompanyContactAuditRoView1.
     * @return CompanyContactAuditRoView1
     */
    public CoreViewObjectImpl getCompanyContactAuditRoView() {
        return (CoreViewObjectImpl) findViewObject("CompanyContactAuditRoView");
    }

    /**
     * Container's getter for FkCompContactAuditCompContactLink1.
     * @return FkCompContactAuditCompContactLink1
     */
    public ViewLinkImpl getFkCompContactAuditCompContactLink1() {
        return (ViewLinkImpl) findViewLink("FkCompContactAuditCompContactLink1");
    }

    /**
     * Container's getter for CompanyFunctionAuditRoView1.
     * @return CompanyFunctionAuditRoView1
     */
    public CoreViewObjectImpl getCompanyFunctionAuditRoView() {
        return (CoreViewObjectImpl) findViewObject("CompanyFunctionAuditRoView");
    }

    /**
     * Container's getter for FkCompFuncAuditCompFuncLink1.
     * @return FkCompFuncAuditCompFuncLink1
     */
    public ViewLinkImpl getFkCompFuncAuditCompFuncLink1() {
        return (ViewLinkImpl) findViewLink("FkCompFuncAuditCompFuncLink1");
    }

    /**
     * Container's getter for NewOhiCommPercVO1.
     * @return NewOhiCommPercVO1
     */
    public NewOhiCommPercVOImpl getCompanyPercView() {
        return (NewOhiCommPercVOImpl) findViewObject("CompanyPercView");
    }

    /**
     * Container's getter for OhiCommPercAuditView1.
     * @return OhiCommPercAuditView1
     */
    public CoreViewObjectImpl getOhiCommPercAuditView() {
        return (CoreViewObjectImpl) findViewObject("OhiCommPercAuditView");
    }

    /**
     * Container's getter for FkOhiCommPercCompanyAuditLink1.
     * @return FkOhiCommPercCompanyAuditLink1
     */
    public ViewLinkImpl getFkOhiCommPercCompanyAuditLink1() {
        return (ViewLinkImpl) findViewLink("FkOhiCommPercCompanyAuditLink1");
    }
    
    /**
     * 
     */

    public String CheckMultinational
                                (Integer CompanyIdNo, 
                                 String  ErrMessage
                                 ) {
           CallableStatement st = null;
           st = getDBTransaction().createCallableStatement("begin LHHCOM.iscompany_multinational(?,?);end;",0);
              try {
                System.out.println("appmodule check Multinational Indicator**");   
                System.out.println("values"+CompanyIdNo);
                st.setInt(1, CompanyIdNo);
                st.registerOutParameter(2,java.sql.Types.VARCHAR);
                st.execute();
                
                System.out.println("output parm 1 - multinational Ind"+st.getString(2));
                  
                return st.getString(2); //return the multinational Indicator
                  
                  
              } catch (SQLException e) {
                throw new JboException(e);
              } finally {
                if (st != null) {
                  try {
                    // 7. Close the statement
                    st.close();
                  } catch (SQLException e) {
                      System.out.println("error "+e);
                  }
                }
              }    
       }


    /**
     * Container's getter for CompanyCheckBrokerageName1.
     * @return CompanyCheckBrokerageName1
     */
    public CompanyCheckBrokerageNameVOImpl getCompanyCheckBrokerageNameVO() {
        return (CompanyCheckBrokerageNameVOImpl) findViewObject("CompanyCheckBrokerageNameVO");
    }

    /**
     * Container's getter for CompanyCorrMultinat1.
     * @return CompanyCorrMultinat1
     */
    public CompanyCorrMultinatVOImpl getCompanyCorrMultinatView() {
        return (CompanyCorrMultinatVOImpl) findViewObject("CompanyCorrMultinatView");
    }

    /**
     * Container's getter for CompanyCorrExceptionReport1.
     * @return CompanyCorrExceptionReport1
     */
    public CoreViewObjectImpl getCompanyCorrExceptionView() {
        return (CoreViewObjectImpl) findViewObject("CompanyCorrExceptionView");
    }

    /**
     * Container's getter for CompCorrespExceptionsVL1.
     * @return CompCorrespExceptionsVL1
     */
    public ViewLinkImpl getCompCorrespExceptionsVL1() {
        return (ViewLinkImpl) findViewLink("CompCorrespExceptionsVL1");
    }

    /**
     * Container's getter for CompanyCorrExceptionReport1.
     * @return CompanyCorrExceptionReport1
     */
    public CoreViewObjectImpl getCompanyCorrExceptionView1() {
        return (CoreViewObjectImpl) findViewObject("CompanyCorrExceptionView1");
    }

    /**
     * Container's getter for CommsPartialReceipt1.
     * @return CommsPartialReceipt1
     */
    public CommsPartialReceiptVOImpl getCommsPartialReceiptVO1() {
        return (CommsPartialReceiptVOImpl) findViewObject("CommsPartialReceiptVO1");
    }

    /**
     * Container's getter for CommsPartialReceiptInactive1.
     * @return CommsPartialReceiptInactive1
     */
    public CommsPartialReceiptInactiveVOImpl getCommsPartialReceiptInactiveVO1() {
        return (CommsPartialReceiptInactiveVOImpl) findViewObject("CommsPartialReceiptInactiveVO1");
    }

    /**
     * Container's getter for CommsPartialReceiptApproveVO1.
     * @return CommsPartialReceiptApproveVO1
     */
    public CommsPartialReceiptApproveVOImpl getCommsPartialReceiptApproveVO1() {
        return (CommsPartialReceiptApproveVOImpl) findViewObject("CommsPartialReceiptApproveVO1");
    }


    /**
     * Container's getter for CompanyCheckPrefCurrency1.
     * @return CompanyCheckPrefCurrency1
     */
    public CompanyCheckPrefCurrencyVOImpl getCompanyCheckPrefCurrencyVO1() {
        return (CompanyCheckPrefCurrencyVOImpl) findViewObject("CompanyCheckPrefCurrencyVO1");
    }
    
    public String CheckPreferredCurrency(String companyIdNo, String newCurrencyCode) {
        String invalidCurrency = null;
        
        System.out.println("In the checkpreferred currency class ");
        
        System.out.println("In the checkpreferred currency class - companyIdNo "+companyIdNo);
        System.out.println("In the checkpreferred currency class - CURRENCY CODE "+newCurrencyCode);
        
        CompanyCheckPrefCurrencyVOImpl vo = this.getCompanyCheckPrefCurrencyVO1();
        vo.setNamedWhereClauseParam("pCompanyId", companyIdNo);
        vo.executeQuery();
               
        Row r = vo.first();
        
        
        if (r != null) {
            System.out.println("got first row "+r.getAttribute("CurrencyCode").toString()); 
            if (r.getAttribute("CurrencyCode").toString() != null) {
                if (newCurrencyCode.toString() != (r.getAttribute("CurrencyCode").toString())) {
                    invalidCurrency = r.getAttribute("CurrencyCode").toString();
                }
               
            }
           
        }
        
        
        //   RowSetIterator iter = vo.createRowSetIterator(null);
        
        while (vo.hasNext()){
            System.out.println("in next row "); 
            r = vo.next();
            System.out.println("got first row "+r.getAttribute("CurrencyCode").toString()); 
            if (r.getAttribute("CurrencyCode").toString() != null) {
                    if (newCurrencyCode.toString() != (r.getAttribute("CurrencyCode").toString())) {
                        invalidCurrency = r.getAttribute("CurrencyCode").toString();
                    }
                   
            }
        }
       
        
        return invalidCurrency;
    }

    /**
     * Container's getter for Approvals1.
     * @return Approvals1
     */
    public ApprovalsVOImpl getApprovals1() {
        return (ApprovalsVOImpl) findViewObject("Approvals1");
    }

    /**
     * Container's getter for Company1.
     * @return Company1
     */
    public CompanyVOImpl getCompany1() {
        return (CompanyVOImpl) findViewObject("Company1");
    }

    /**
     * Container's getter for Approvals2.
     * @return Approvals2
     */
    public ApprovalsVOImpl getApprovals2() {
        return (ApprovalsVOImpl) findViewObject("Approvals2");
    }

    /**
     * Container's getter for FkApprovalsCompanyLink.
     * @return FkApprovalsCompanyLink
     */
    public ViewLinkImpl getFkApprovalsCompanyLink() {
        return (ViewLinkImpl) findViewLink("FkApprovalsCompanyLink");
    }

    /**
     * Container's getter for SystemParameter1.
     * @return SystemParameter1
     */
    public SystemParameterVOImpl getSystemParameter1() {
        return (SystemParameterVOImpl) findViewObject("SystemParameter1");
    }
}

