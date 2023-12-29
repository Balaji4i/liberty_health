package com.liberty.health.comms.model.ohi.services;

import com.core.model.services.classes.CoreApplicationModuleImpl;

import com.core.model.vo.classes.CoreViewObjectImpl;

import com.liberty.health.comms.model.ohi.services.common.OhiStructureAM;
import com.liberty.health.comms.model.ohi.vo.CurrencyLovView_NImpl;
import com.liberty.health.comms.model.ohi.vo.HoldIndicatorViewImpl;
import com.liberty.health.comms.model.ohi.vo.NewOhiCommPercVOImpl;
import com.liberty.health.comms.model.ohi.vo.OhiGroupsParentVOImpl;
import com.liberty.health.comms.model.ohi.vo.OhiGroupsRoViewImpl;
import com.liberty.health.comms.model.ohi.vo.OhiParentGroupLovViewImpl;
import com.liberty.health.comms.model.ohi.vo.OhiPolicyBrokerRoViewImpl;
import com.liberty.health.comms.model.ohi.vo.OhiPolicyEnrollmentPersonsRoViewImpl;
import com.liberty.health.comms.model.ohi.vo.OhiPolicyEnrollmentRoViewImpl;
import com.liberty.health.comms.model.ohi.vo.OhiProductsRoViewImpl;

import com.liberty.health.comms.model.ohi.vo.PolicyCodeVOImpl;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;

import oracle.jbo.JboException;
import oracle.jbo.server.ViewLinkImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed Nov 29 11:16:46 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class OhiStructureAMImpl extends CoreApplicationModuleImpl implements OhiStructureAM {
    /**
     * This is the default constructor (do not remove).
     */
    public OhiStructureAMImpl() {
    }

    /**
     * Container's getter for OhiPolicyBrokerRoView1.
     * @return OhiPolicyBrokerRoView1
     */
    public OhiPolicyBrokerRoViewImpl getOhiPolicyBrokerRoView1() {
        return (OhiPolicyBrokerRoViewImpl) findViewObject("OhiPolicyBrokerRoView1");
    }
    
    public String fixBackDatedChanges(oracle.jbo.domain.Number polId, String userame) {
        String sqlStmnt = null;
        CallableStatement cs = null;
        String result = null;
        System.out.println("Calling fixbackdated changes + "+polId);
        try {
            sqlStmnt =
                "BEGIN LHHCOM.OHI_POLICIES_LOAD_PKG.BACK_DATED_DATES_FIX (P_POLI_ID =>?,  P_USERNAME =>?, PV_MESSAGE =>?); END;";
            cs = this.getDBTransaction().createCallableStatement(sqlStmnt, this.getDBTransaction().DEFAULT);
            //Set procedure paramaters
            if (polId != null) {
                cs.setInt(1, polId.intValue());
            } else {
                cs.setString(1, null);
            }
            if (userame != null) {
                cs.setString(2, userame);
            } else {
                cs.setString(2, null);
            }

            //Register out parameters
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();
            result = cs.getString(3);
        } catch (SQLException e) {
            e.printStackTrace();
            e.getLocalizedMessage();
        } finally {
            if (cs != null) {
                try {
                    cs.close();
                } catch (SQLException e) {
                    throw new JboException(e);
                }
            }
        }
        System.out.println("Results fixbackdated changes:"+result);
        return result;
    }


    /**
     * Container's getter for OhiGroupsRoView1.
     * @return OhiGroupsRoView1
     */
    public OhiGroupsRoViewImpl getOhiGroupsRoView1() {
        return (OhiGroupsRoViewImpl) findViewObject("OhiGroupsRoView1");
    }

    /**
     * Container's getter for OhiProductsRoView1.
     * @return OhiProductsRoView1
     */
    public OhiProductsRoViewImpl getOhiProductsRoView1() {
        return (OhiProductsRoViewImpl) findViewObject("OhiProductsRoView1");
    }

    /**
     * Container's getter for OhiPolicyEnrollmentRoView1.
     * @return OhiPolicyEnrollmentRoView1
     */
    public OhiPolicyEnrollmentRoViewImpl getOhiPolicyEnrollmentRoView1() {
        return (OhiPolicyEnrollmentRoViewImpl) findViewObject("OhiPolicyEnrollmentRoView1");
    }

    /**
     * Container's getter for OhiPolicyEnrollmentPersonsRoView1.
     * @return OhiPolicyEnrollmentPersonsRoView1
     */
    public OhiPolicyEnrollmentPersonsRoViewImpl getOhiPolicyEnrollmentPersonsRoView1() {
        return (OhiPolicyEnrollmentPersonsRoViewImpl) findViewObject("OhiPolicyEnrollmentPersonsRoView1");
    }

    /**
     * Container's getter for MaintainOhiCommPercentageView.
     * @return MaintainOhiCommPercentageView
     */
    public NewOhiCommPercVOImpl getMaintainOhiCommPercentageView() {
        return (NewOhiCommPercVOImpl) findViewObject("MaintainOhiCommPercentageView");
    }

    /**
     * Container's getter for MaintainHoldIndicatorView.
     * @return MaintainHoldIndicatorView
     */
    public HoldIndicatorViewImpl getMaintainHoldIndicatorView() {
        return (HoldIndicatorViewImpl) findViewObject("MaintainHoldIndicatorView");
    }


    /**
     * Container's getter for PolicyBrokerGroupViewLink.
     * @return PolicyBrokerGroupViewLink
     */
    public ViewLinkImpl getPolicyBrokerGroupViewLink() {
        return (ViewLinkImpl) findViewLink("PolicyBrokerGroupViewLink");
    }

    /**
     * Container's getter for GroupsProductsViewLink1.
     * @return GroupsProductsViewLink1
     */
    public ViewLinkImpl getGroupsProductsViewLink1() {
        return (ViewLinkImpl) findViewLink("GroupsProductsViewLink1");
    }

    /**
     * Container's getter for ProductsPolicyEnrolmentsViewLink1.
     * @return ProductsPolicyEnrolmentsViewLink1
     */
    public ViewLinkImpl getProductsPolicyEnrolmentsViewLink1() {
        return (ViewLinkImpl) findViewLink("ProductsPolicyEnrolmentsViewLink1");
    }

    /**
     * Container's getter for PolicyEnrolPersonsViewLink1.
     * @return PolicyEnrolPersonsViewLink1
     */
    public ViewLinkImpl getPolicyEnrolPersonsViewLink1() {
        return (ViewLinkImpl) findViewLink("PolicyEnrolPersonsViewLink1");
    }

    /**
     * Container's getter for AllOhiCountryLovView1.
     * @return AllOhiCountryLovView1
     */
    public CoreViewObjectImpl getAllOhiCountryLovView1() {
        return (CoreViewObjectImpl) findViewObject("AllOhiCountryLovView1");
    }

    /**
     * Container's getter for CountryLovView_N1.
     * @return CountryLovView_N1
     */
    public CoreViewObjectImpl getCountryLovView_N1() {
        return (CoreViewObjectImpl) findViewObject("CountryLovView_N1");
    }

    /**
     * Container's getter for OhiGroupLovView_P1.
     * @return OhiGroupLovView_P1
     */
    public CoreViewObjectImpl getOhiGroupLovView_P1() {
        return (CoreViewObjectImpl) findViewObject("OhiGroupLovView_P1");
    }

    /**
     * Container's getter for OhiProductLovView_P1.
     * @return OhiProductLovView_P1
     */
    public CoreViewObjectImpl getOhiProductLovView_P1() {
        return (CoreViewObjectImpl) findViewObject("OhiProductLovView_P1");
    }

    /**
     * Container's getter for OhiGroupsVO_N1.
     * @return OhiGroupsVO_N1
     */
    public CoreViewObjectImpl getOhiGroupsVO_N1() {
        return (CoreViewObjectImpl) findViewObject("OhiGroupsVO_N1");
    }

    /**
     * Container's getter for CompanyRoView_N1.
     * @return CompanyRoView_N1
     */
    public CoreViewObjectImpl getCompanyRoView_N1() {
        return (CoreViewObjectImpl) findViewObject("CompanyRoView_N1");
    }

    /**
     * Container's getter for CommsCalcTypeLovView_N1.
     * @return CommsCalcTypeLovView_N1
     */
    public CoreViewObjectImpl getCommsCalcTypeLovView_N1() {
        return (CoreViewObjectImpl) findViewObject("CommsCalcTypeLovView_N1");
    }

    /**
     * Container's getter for PolicyCode1.
     * @return PolicyCode1
     */
    public PolicyCodeVOImpl getPolicyCode1() {
        return (PolicyCodeVOImpl) findViewObject("PolicyCode1");
    }

    /**
     * Container's getter for Invoice1.
     * @return Invoice1
     */
    public CoreViewObjectImpl getInvoice1() {
        return (CoreViewObjectImpl) findViewObject("Invoice1");
    }

    /**
     * Container's getter for CurrencyLovView_N1.
     * @return CurrencyLovView_N1
     */
    public CurrencyLovView_NImpl getCurrencyLovView_N1() {
        return (CurrencyLovView_NImpl) findViewObject("CurrencyLovView_N1");
    }

    /**
     * Container's getter for OhiParentGroupLovView1.
     * @return OhiParentGroupLovView1
     */
    public OhiParentGroupLovViewImpl getOhiParentGroupLovView1() {
        return (OhiParentGroupLovViewImpl) findViewObject("OhiParentGroupLovView1");
    }

    /**
     * Container's getter for OhiGroupsParent1.
     * @return OhiGroupsParent1
     */
    public OhiGroupsParentVOImpl getOhiGroupsParent1() {
        return (OhiGroupsParentVOImpl) findViewObject("OhiGroupsParent1");
    }
}
