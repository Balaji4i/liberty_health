package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewObjectImpl;
import com.core.utils.DateConversionUtil;
import com.core.utils.DateUtils;

import com.liberty.health.comms.model.broker.vo.common.BrokerAccreditationVO;

import oracle.jbo.RowSetIterator;
import oracle.jbo.ViewCriteria;
import oracle.jbo.domain.Date;
import oracle.jbo.domain.Number;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Jul 04 15:52:18 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class BrokerAccreditationVOImpl extends CoreViewObjectImpl implements BrokerAccreditationVO {
    /**
     * This is the default constructor (do not remove).
     */
    public BrokerAccreditationVOImpl() {
    }
    
    public String checkAccreditationExists(Integer accreditationIdNo) {
        System.out.println("in the vo broker accreditation checking if accred exists "+accreditationIdNo);
        String viewCriteriaName = "BrokerAccreditationCheck";
        BrokerAccreditationVOImpl vo = (BrokerAccreditationVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pAccredTypeIdNo", accreditationIdNo);
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();


        while (rowIt.hasNext()) {
            System.out.println("it has a row so pass message back "); 
           
           return "Cannot delete as a Broker has this accreditation!";
           
        }
        System.out.println("no row has been found so return null "); 
        
        rowIt.closeRowSetIterator();
        return null;
    }   
        

    public void updateEffDates(Integer brokerIdNo, Date currentDate) {
        String viewCriteriaName = "BrokerAccredByPrimaryKeyViewCriteria";
        BrokerAccreditationVOImpl vo = (BrokerAccreditationVOImpl) this.getViewObject();

        ViewCriteria vc = vo.getViewCriteria(viewCriteriaName);
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pCurrentDate", "");

        vo.setSortBy("BrokerIdNo, AccreditationTypeIdNo, EffectiveStartDate desc");
        vo.executeQuery();

        RowSetIterator rowIt = vo.createRowSetIterator(null);
        rowIt.reset();

        Date startDate = DateUtils.getLibertyMinDate();
        Integer brokerNo = 0;
        Integer accredtypeIdNo = 0;

        while (rowIt.hasNext()) {

            BrokerAccreditationVORowImpl row = (BrokerAccreditationVORowImpl) rowIt.next();
            Date endDate = row.getEffectiveEndDate();
            Date newEndDate = DateUtils.getLibertyMaxDate();
            if (brokerNo.compareTo(row.getBrokerIdNo()) != 0 ||
                accredtypeIdNo.compareTo(row.getAccreditationTypeIdNo()) != 0) {
                row.setEffectiveEndDate(newEndDate);
            } else if (endDate != newEndDate) {
                row.setEffectiveEndDate(DateConversionUtil.subtractDays(startDate, 1));
                System.out.println("Setting end date " + DateConversionUtil.subtractDays(startDate, 1));
            }
            brokerNo = row.getBrokerIdNo();
            accredtypeIdNo = row.getAccreditationTypeIdNo();
            startDate = row.getEffectiveStartDate();

        }
        rowIt.closeRowSetIterator();
        this.getDBTransaction().commit();
        vo.removeViewCriteria(viewCriteriaName);
        vc.resetCriteria();
        vo.applyViewCriteria(vc);
        vo.setNamedWhereClauseParam("pBrokerIdNo", brokerIdNo);
        vo.setNamedWhereClauseParam("pCurrentDate", currentDate);
        vo.executeQuery();

    }

    /**
     * Returns the variable value for pBrokerIdNo.
     * @return variable value for pBrokerIdNo
     */
    public Number getpBrokerIdNo() {
        return (Number) ensureVariableManager().getVariableValue("pBrokerIdNo");
    }

    /**
     * Sets <code>value</code> for variable pBrokerIdNo.
     * @param value value to bind as pBrokerIdNo
     */
    public void setpBrokerIdNo(Number value) {
        ensureVariableManager().setVariableValue("pBrokerIdNo", value);
        this.executeQuery();
    }

    /**
     * Returns the variable value for pCurrentDate.
     * @return variable value for pCurrentDate
     */
    public Date getpCurrentDate() {
        return (Date) ensureVariableManager().getVariableValue("pCurrentDate");
    }

    /**
     * Sets <code>value</code> for variable pCurrentDate.
     * @param value value to bind as pCurrentDate
     */
    public void setpCurrentDate(Date value) {
        ensureVariableManager().setVariableValue("pCurrentDate", value);
    }


    /**
     * Returns the variable value for pAccredTypeIdNo.
     * @return variable value for pAccredTypeIdNo
     */
    public Integer getpAccredTypeIdNo() {
        return (Integer) ensureVariableManager().getVariableValue("pAccredTypeIdNo");
    }

    /**
     * Sets <code>value</code> for variable pAccredTypeIdNo.
     * @param value value to bind as pAccredTypeIdNo
     */
    public void setpAccredTypeIdNo(Integer value) {
        ensureVariableManager().setVariableValue("pAccredTypeIdNo", value);
    }
}

