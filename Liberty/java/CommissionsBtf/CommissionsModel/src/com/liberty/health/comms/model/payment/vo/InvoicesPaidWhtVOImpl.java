package com.liberty.health.comms.model.payment.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;


import com.liberty.health.comms.model.payment.vo.common.InvoicesPaidWhtVO;

import java.util.Date;

import javax.faces.context.FacesContext;

import oracle.jbo.ViewCriteria;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Oct 09 08:28:05 CAT 2018
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class InvoicesPaidWhtVOImpl extends CoreViewObjectImpl implements InvoicesPaidWhtVO {
    /**
     * This is the default constructor (do not remove).
     */
    public InvoicesPaidWhtVOImpl() {
    }
    
    public void setCriteriaParms(String companyIdNo, 
                                 String companyName,
                                 String countryCode,
                                 Integer invoiceTypeIdNo,    
                                 Date paymentDateFrom,
                                 Date paymentDateTo
                                 ) {

           System.out.println("in run query for invoices paid WHT - companyid"+ companyIdNo);
           System.out.println("in run query for invoices paid WHT - companyName "+ companyName);
           System.out.println("in run query for invoices paid WHT - country Code "+ countryCode);
           System.out.println("in run query for invoices paid WHT - invoiceTypeIdNo"+ invoiceTypeIdNo);
           System.out.println("in run query for invoices paid WHT - paymentDateFrom"+paymentDateFrom);
           System.out.println("in run query for invoices paid WHT - paymentDateTo"+paymentDateTo);
           
           
           FacesContext fc = FacesContext.getCurrentInstance();
           String viewCriteriaName = "InvoicesPaidWhtVOCriteria";
           InvoicesPaidWhtVOImpl vo = (InvoicesPaidWhtVOImpl) this.getViewObject();
           
           
           ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
           vo.removeViewCriteria(viewCriteriaName);
           vc.resetCriteria();
           vo.applyViewCriteria(vc);
               
           vo.setNamedWhereClauseParam("pCompanyIdNo", companyIdNo);
           vo.setNamedWhereClauseParam("pCompanyName", companyName);
           vo.setNamedWhereClauseParam("pCountryCode", countryCode);
           vo.setNamedWhereClauseParam("pInvoiceTypeId", invoiceTypeIdNo);
           vo.setNamedWhereClauseParam("pPaymentFromDate", paymentDateFrom);
           vo.setNamedWhereClauseParam("pPaymentToDate", paymentDateTo);
       
          // vo.setSortBy("BrokerIdNo, BrokerTableIdNo, EffectiveStartDate desc");
           vo.executeQuery();
    }


    /**
     * Returns the variable value for pCompanyIdNo.
     * @return variable value for pCompanyIdNo
     */
    public String getpCompanyIdNo() {
        return (String) ensureVariableManager().getVariableValue("pCompanyIdNo");
    }

    /**
     * Sets <code>value</code> for variable pCompanyIdNo.
     * @param value value to bind as pCompanyIdNo
     */
    public void setpCompanyIdNo(String value) {
        ensureVariableManager().setVariableValue("pCompanyIdNo", value);
    }

    /**
     * Returns the variable value for pCompanyName.
     * @return variable value for pCompanyName
     */
    public String getpCompanyName() {
        return (String) ensureVariableManager().getVariableValue("pCompanyName");
    }

    /**
     * Sets <code>value</code> for variable pCompanyName.
     * @param value value to bind as pCompanyName
     */
    public void setpCompanyName(String value) {
        ensureVariableManager().setVariableValue("pCompanyName", value);
    }

    /**
     * Returns the variable value for pPaymentDate.
     * @return variable value for pPaymentDate
     */
    public oracle.jbo.domain.Date getpPaymentFromDate() {
        return (oracle.jbo.domain.Date) ensureVariableManager().getVariableValue("pPaymentFromDate");
    }

    /**
     * Sets <code>value</code> for variable pPaymentDate.
     * @param value value to bind as pPaymentDate
     */
    public void setpPaymentFromDate(oracle.jbo.domain.Date value) {
        ensureVariableManager().setVariableValue("pPaymentFromDate", value);
    }

    /**
     * Returns the variable value for pInvoiceTypeId.
     * @return variable value for pInvoiceTypeId
     */
    public Integer getpInvoiceTypeId() {
        return (Integer) ensureVariableManager().getVariableValue("pInvoiceTypeId");
    }

    /**
     * Sets <code>value</code> for variable pInvoiceTypeId.
     * @param value value to bind as pInvoiceTypeId
     */
    public void setpInvoiceTypeId(Integer value) {
        ensureVariableManager().setVariableValue("pInvoiceTypeId", value);
    }

    /**
     * Returns the variable value for pCountryCode.
     * @return variable value for pCountryCode
     */
    public String getpCountryCode() {
        return (String) ensureVariableManager().getVariableValue("pCountryCode");
    }

    /**
     * Sets <code>value</code> for variable pCountryCode.
     * @param value value to bind as pCountryCode
     */
    public void setpCountryCode(String value) {
        ensureVariableManager().setVariableValue("pCountryCode", value);
    }

    /**
     * Returns the variable value for pPaymentToDate.
     * @return variable value for pPaymentToDate
     */
    public oracle.jbo.domain.Date getpPaymentToDate() {
        return (oracle.jbo.domain.Date) ensureVariableManager().getVariableValue("pPaymentToDate");
    }

    /**
     * Sets <code>value</code> for variable pPaymentToDate.
     * @param value value to bind as pPaymentToDate
     */
    public void setpPaymentToDate(oracle.jbo.domain.Date value) {
        ensureVariableManager().setVariableValue("pPaymentToDate", value);
    }


    /**
     * Returns the bind variable value for pCountryList.
     * @return bind variable value for pCountryList
     */
    public String getpCountryList() {
        return (String) getNamedWhereClauseParam("pCountryList");
    }

    /**
     * Sets <code>value</code> for bind variable pCountryList.
     * @param value value to bind as pCountryList
     */
    public void setpCountryList(String value) {
        setNamedWhereClauseParam("pCountryList", value);
    }
}
