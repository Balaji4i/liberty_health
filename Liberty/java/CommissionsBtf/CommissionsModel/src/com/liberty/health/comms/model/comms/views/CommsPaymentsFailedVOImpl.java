package com.liberty.health.comms.model.comms.views;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.comms.views.common.CommsPaymentsFailedVO;
import com.liberty.health.comms.model.payment.vo.InvoicesPaidWhtVOImpl;

import java.util.Date;

import javax.faces.context.FacesContext;

import oracle.jbo.ViewCriteria;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Jan 08 08:39:22 CAT 2019
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CommsPaymentsFailedVOImpl extends CoreViewObjectImpl implements CommsPaymentsFailedVO {
    /**
     * This is the default constructor (do not remove).
     */
    public CommsPaymentsFailedVOImpl() {
    }

    /**
     * Returns the variable value for pCountry.
     * @return variable value for pCountry
     */
    public String getpCountry() {
        return (String) ensureVariableManager().getVariableValue("pCountry");
    }

    /**
     * Sets <code>value</code> for variable pCountry.
     * @param value value to bind as pCountry
     */
    public void setpCountry(String value) {
        ensureVariableManager().setVariableValue("pCountry", value);
    }

    /**
     * Returns the variable value for pGroup.
     * @return variable value for pGroup
     */
    public String getpGroup() {
        return (String) ensureVariableManager().getVariableValue("pGroup");
    }

    /**
     * Sets <code>value</code> for variable pGroup.
     * @param value value to bind as pGroup
     */
    public void setpGroup(String value) {
        ensureVariableManager().setVariableValue("pGroup", value);
    }

    /**
     * Returns the variable value for pProduct.
     * @return variable value for pProduct
     */
    public String getpProduct() {
        return (String) ensureVariableManager().getVariableValue("pProduct");
    }

    /**
     * Sets <code>value</code> for variable pProduct.
     * @param value value to bind as pProduct
     */
    public void setpProduct(String value) {
        ensureVariableManager().setVariableValue("pProduct", value);
    }

    /**
     * Returns the variable value for pPerson.
     * @return variable value for pPerson
     */
    public String getpPerson() {
        return (String) ensureVariableManager().getVariableValue("pPerson");
    }

    /**
     * Sets <code>value</code> for variable pPerson.
     * @param value value to bind as pPerson
     */
    public void setpPerson(String value) {
        ensureVariableManager().setVariableValue("pPerson", value);
    }
    
    public void setCriteriaParms(String countryCode, 
                                 String groupCode,
                                 String productCode,
                                 String personCode
                                 ) {


           System.out.println("in run query for invoices paid WHT - country Code "+ countryCode);
           System.out.println("in run query for invoices paid WHT - invoiceTypeIdNo"+ groupCode);
           System.out.println("in run query for invoices paid WHT - paymentDateFrom"+productCode);
           System.out.println("in run query for invoices paid WHT - paymentDateTo"+personCode);
           
           
           FacesContext fc = FacesContext.getCurrentInstance();
           String viewCriteriaName = "CommsPaymentsFailedVOCriteria";
           InvoicesPaidWhtVOImpl vo = (InvoicesPaidWhtVOImpl) this.getViewObject();
           
           
           ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
           vo.removeViewCriteria(viewCriteriaName);
           vc.resetCriteria();
           vo.applyViewCriteria(vc);
               
           vo.setNamedWhereClauseParam("pCountryCode", countryCode);
           vo.setNamedWhereClauseParam("pGroupCode", groupCode);
           vo.setNamedWhereClauseParam("pProductCode", productCode);
           vo.setNamedWhereClauseParam("pPersonCode", personCode);
          
       
          // vo.setSortBy("BrokerIdNo, BrokerTableIdNo, EffectiveStartDate desc");
           vo.executeQuery();
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

