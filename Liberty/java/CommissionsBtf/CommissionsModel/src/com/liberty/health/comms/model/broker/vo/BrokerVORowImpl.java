package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import com.liberty.health.comms.model.eo.BrokerEOImpl;
import com.liberty.health.comms.model.eo.CompanyEOImpl;

import java.math.BigInteger;

import java.sql.Timestamp;

import oracle.jbo.RowIterator;
import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Wed May 17 13:50:19 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class BrokerVORowImpl extends CoreViewRowImpl {


    public static final int ENTITY_BROKEREO = 0;
    public static final int ENTITY_COMPANYEO = 1;
    public static final int ENTITY_BROKEREO1 = 2;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        BrokerIdNo,
        BrokerLastName,
        BrokerName,
        BusinessDevMgrName,
        CompanyIdNo,
        EmailNotificationInd,
        IdNo,
        Initials,
        KamBrokerIdNo,
        LanguageCode,
        LastUpdateDatetime,
        ParentBrokerIdNo,
        PassportCode,
        PersonTitleCode,
        SmsNotificationInd,
        Username,
        CompanyName,
        CompanyIdNoFk,
        EffectiveEndDate,
        EffectiveStartDate,
        WorkTelephoneNo,
        HomeTelephoneNo,
        EmailAddress,
        CellphoneNo,
        BrokerName1,
        BrokerIdNo1,
        BrokerComments,
        BrokerFunction,
        Company2,
        Company1,
        BrokerAuditRoView,
        LanguageLovView1,
        PersonTitleLovView2,
        ActiveLov1,
        KamBrokerTypeLovView,
        ParentBrokerTypeLovView,
        CompanyLovView1;
        private static AttributesEnum[] vals = null;
        ;
        private static final int firstIndex = 0;

        protected int index() {
            return AttributesEnum.firstIndex() + ordinal();
        }

        protected static final int firstIndex() {
            return firstIndex;
        }

        protected static int count() {
            return AttributesEnum.firstIndex() + AttributesEnum.staticValues().length;
        }

        protected static final AttributesEnum[] staticValues() {
            if (vals == null) {
                vals = AttributesEnum.values();
            }
            return vals;
        }
    }


    public static final int BROKERIDNO = AttributesEnum.BrokerIdNo.index();
    public static final int BROKERLASTNAME = AttributesEnum.BrokerLastName.index();
    public static final int BROKERNAME = AttributesEnum.BrokerName.index();
    public static final int BUSINESSDEVMGRNAME = AttributesEnum.BusinessDevMgrName.index();
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int EMAILNOTIFICATIONIND = AttributesEnum.EmailNotificationInd.index();
    public static final int IDNO = AttributesEnum.IdNo.index();
    public static final int INITIALS = AttributesEnum.Initials.index();
    public static final int KAMBROKERIDNO = AttributesEnum.KamBrokerIdNo.index();
    public static final int LANGUAGECODE = AttributesEnum.LanguageCode.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int PARENTBROKERIDNO = AttributesEnum.ParentBrokerIdNo.index();
    public static final int PASSPORTCODE = AttributesEnum.PassportCode.index();
    public static final int PERSONTITLECODE = AttributesEnum.PersonTitleCode.index();
    public static final int SMSNOTIFICATIONIND = AttributesEnum.SmsNotificationInd.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int COMPANYNAME = AttributesEnum.CompanyName.index();
    public static final int COMPANYIDNOFK = AttributesEnum.CompanyIdNoFk.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int WORKTELEPHONENO = AttributesEnum.WorkTelephoneNo.index();
    public static final int HOMETELEPHONENO = AttributesEnum.HomeTelephoneNo.index();
    public static final int EMAILADDRESS = AttributesEnum.EmailAddress.index();
    public static final int CELLPHONENO = AttributesEnum.CellphoneNo.index();
    public static final int BROKERNAME1 = AttributesEnum.BrokerName1.index();
    public static final int BROKERIDNO1 = AttributesEnum.BrokerIdNo1.index();
    public static final int BROKERCOMMENTS = AttributesEnum.BrokerComments.index();
    public static final int BROKERFUNCTION = AttributesEnum.BrokerFunction.index();
    public static final int COMPANY2 = AttributesEnum.Company2.index();
    public static final int COMPANY1 = AttributesEnum.Company1.index();
    public static final int BROKERAUDITROVIEW = AttributesEnum.BrokerAuditRoView.index();
    public static final int LANGUAGELOVVIEW1 = AttributesEnum.LanguageLovView1.index();
    public static final int PERSONTITLELOVVIEW2 = AttributesEnum.PersonTitleLovView2.index();
    public static final int ACTIVELOV1 = AttributesEnum.ActiveLov1.index();
    public static final int KAMBROKERTYPELOVVIEW = AttributesEnum.KamBrokerTypeLovView.index();
    public static final int PARENTBROKERTYPELOVVIEW = AttributesEnum.ParentBrokerTypeLovView.index();
    public static final int COMPANYLOVVIEW1 = AttributesEnum.CompanyLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public BrokerVORowImpl() {
    }

    /**
     * Gets BrokerEO entity object.
     * @return the BrokerEO
     */
    public BrokerEOImpl getBrokerEO() {
        return (BrokerEOImpl) getEntity(ENTITY_BROKEREO);
    }

    /**
     * Gets CompanyEO entity object.
     * @return the CompanyEO
     */
    public CompanyEOImpl getCompanyEO() {
        return (CompanyEOImpl) getEntity(ENTITY_COMPANYEO);
    }


    /**
     * Gets BrokerEO1 entity object.
     * @return the BrokerEO1
     */
    public BrokerEOImpl getBrokerEO1() {
        return (BrokerEOImpl) getEntity(ENTITY_BROKEREO1);
    }

    /**
     * Gets the attribute value for BROKER_ID_NO using the alias name BrokerIdNo.
     * @return the BROKER_ID_NO
     */
    public Integer getBrokerIdNo() {
        return (Integer) getAttributeInternal(BROKERIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_ID_NO using the alias name BrokerIdNo.
     * @param value value to set the BROKER_ID_NO
     */
    public void setBrokerIdNo(Integer value) {
        setAttributeInternal(BROKERIDNO, value);
    }

    /**
     * Gets the attribute value for BROKER_LAST_NAME using the alias name BrokerLastName.
     * @return the BROKER_LAST_NAME
     */
    public String getBrokerLastName() {
        return (String) getAttributeInternal(BROKERLASTNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_LAST_NAME using the alias name BrokerLastName.
     * @param value value to set the BROKER_LAST_NAME
     */
    public void setBrokerLastName(String value) {
        setAttributeInternal(BROKERLASTNAME, value);
    }

    /**
     * Gets the attribute value for BROKER_NAME using the alias name BrokerName.
     * @return the BROKER_NAME
     */
    public String getBrokerName() {
        return (String) getAttributeInternal(BROKERNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_NAME using the alias name BrokerName.
     * @param value value to set the BROKER_NAME
     */
    public void setBrokerName(String value) {
        setAttributeInternal(BROKERNAME, value);
    }

    /**
     * Gets the attribute value for BUSINESS_DEV_MGR_NAME using the alias name BusinessDevMgrName.
     * @return the BUSINESS_DEV_MGR_NAME
     */
    public String getBusinessDevMgrName() {
        return (String) getAttributeInternal(BUSINESSDEVMGRNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BUSINESS_DEV_MGR_NAME using the alias name BusinessDevMgrName.
     * @param value value to set the BUSINESS_DEV_MGR_NAME
     */
    public void setBusinessDevMgrName(String value) {
        setAttributeInternal(BUSINESSDEVMGRNAME, value);
    }

    /**
     * Gets the attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @return the COMPANY_ID_NO
     */
    public Integer getCompanyIdNo() {
        return (Integer) getAttributeInternal(COMPANYIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for COMPANY_ID_NO using the alias name CompanyIdNo.
     * @param value value to set the COMPANY_ID_NO
     */
    public void setCompanyIdNo(Integer value) {
        setAttributeInternal(COMPANYIDNO, value);
    }

    /**
     * Gets the attribute value for EMAIL_NOTIFICATION_IND using the alias name EmailNotificationInd.
     * @return the EMAIL_NOTIFICATION_IND
     */
    public String getEmailNotificationInd() {
        return (String) getAttributeInternal(EMAILNOTIFICATIONIND);
    }

    /**
     * Sets <code>value</code> as attribute value for EMAIL_NOTIFICATION_IND using the alias name EmailNotificationInd.
     * @param value value to set the EMAIL_NOTIFICATION_IND
     */
    public void setEmailNotificationInd(String value) {
        setAttributeInternal(EMAILNOTIFICATIONIND, value);
    }

    /**
     * Gets the attribute value for ID_NO using the alias name IdNo.
     * @return the ID_NO
     */
    public BigInteger getIdNo() {
        return (BigInteger) getAttributeInternal(IDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for ID_NO using the alias name IdNo.
     * @param value value to set the ID_NO
     */
    public void setIdNo(BigInteger value) {
        setAttributeInternal(IDNO, value);
    }

    /**
     * Gets the attribute value for INITIALS using the alias name Initials.
     * @return the INITIALS
     */
    public String getInitials() {
        return (String) getAttributeInternal(INITIALS);
    }

    /**
     * Sets <code>value</code> as attribute value for INITIALS using the alias name Initials.
     * @param value value to set the INITIALS
     */
    public void setInitials(String value) {
        setAttributeInternal(INITIALS, value);
    }


    /**
     * Gets the attribute value for KAM_BROKER_ID_NO using the alias name KamBrokerIdNo.
     * @return the KAM_BROKER_ID_NO
     */
    public Integer getKamBrokerIdNo() {
        return (Integer) getAttributeInternal(KAMBROKERIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for KAM_BROKER_ID_NO using the alias name KamBrokerIdNo.
     * @param value value to set the KAM_BROKER_ID_NO
     */
    public void setKamBrokerIdNo(Integer value) {
        setAttributeInternal(KAMBROKERIDNO, value);
    }

    /**
     * Gets the attribute value for LANGUAGE_CODE using the alias name LanguageCode.
     * @return the LANGUAGE_CODE
     */
    public String getLanguageCode() {
        return (String) getAttributeInternal(LANGUAGECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for LANGUAGE_CODE using the alias name LanguageCode.
     * @param value value to set the LANGUAGE_CODE
     */
    public void setLanguageCode(String value) {
        setAttributeInternal(LANGUAGECODE, value);
    }

    /**
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Timestamp getLastUpdateDatetime() {
        return (Timestamp) getAttributeInternal(LASTUPDATEDATETIME);
    }


    /**
     * Gets the attribute value for EFFECTIVE_END_DATE using the alias name EffectiveEndDate.
     * @return the EFFECTIVE_END_DATE
     */
    public Date getEffectiveEndDate() {
        return (Date) getAttributeInternal(EFFECTIVEENDDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for EFFECTIVE_END_DATE using the alias name EffectiveEndDate.
     * @param value value to set the EFFECTIVE_END_DATE
     */
    public void setEffectiveEndDate(Date value) {
        setAttributeInternal(EFFECTIVEENDDATE, value);
    }

    /**
     * Gets the attribute value for EFFECTIVE_START_DATE using the alias name EffectiveStartDate.
     * @return the EFFECTIVE_START_DATE
     */
    public Date getEffectiveStartDate() {
        return (Date) getAttributeInternal(EFFECTIVESTARTDATE);
    }

    /**
     * Sets <code>value</code> as attribute value for EFFECTIVE_START_DATE using the alias name EffectiveStartDate.
     * @param value value to set the EFFECTIVE_START_DATE
     */
    public void setEffectiveStartDate(Date value) {
        setAttributeInternal(EFFECTIVESTARTDATE, value);
    }

    /**
     * Gets the attribute value for WORK_TELEPHONE_NO using the alias name WorkTelephoneNo.
     * @return the WORK_TELEPHONE_NO
     */
    public String getWorkTelephoneNo() {
        return (String) getAttributeInternal(WORKTELEPHONENO);
    }

    /**
     * Sets <code>value</code> as attribute value for WORK_TELEPHONE_NO using the alias name WorkTelephoneNo.
     * @param value value to set the WORK_TELEPHONE_NO
     */
    public void setWorkTelephoneNo(String value) {
        setAttributeInternal(WORKTELEPHONENO, value);
    }

    /**
     * Gets the attribute value for HOME_TELEPHONE_NO using the alias name HomeTelephoneNo.
     * @return the HOME_TELEPHONE_NO
     */
    public String getHomeTelephoneNo() {
        return (String) getAttributeInternal(HOMETELEPHONENO);
    }

    /**
     * Sets <code>value</code> as attribute value for HOME_TELEPHONE_NO using the alias name HomeTelephoneNo.
     * @param value value to set the HOME_TELEPHONE_NO
     */
    public void setHomeTelephoneNo(String value) {
        setAttributeInternal(HOMETELEPHONENO, value);
    }

    /**
     * Gets the attribute value for EMAIL_ADDRESS using the alias name EmailAddress.
     * @return the EMAIL_ADDRESS
     */
    public String getEmailAddress() {
        return (String) getAttributeInternal(EMAILADDRESS);
    }

    /**
     * Sets <code>value</code> as attribute value for EMAIL_ADDRESS using the alias name EmailAddress.
     * @param value value to set the EMAIL_ADDRESS
     */
    public void setEmailAddress(String value) {
        setAttributeInternal(EMAILADDRESS, value);
    }

    /**
     * Gets the attribute value for CELLPHONE_NO using the alias name CellphoneNo.
     * @return the CELLPHONE_NO
     */
    public String getCellphoneNo() {
        return (String) getAttributeInternal(CELLPHONENO);
    }

    /**
     * Sets <code>value</code> as attribute value for CELLPHONE_NO using the alias name CellphoneNo.
     * @param value value to set the CELLPHONE_NO
     */
    public void setCellphoneNo(String value) {
        setAttributeInternal(CELLPHONENO, value);
    }


    /**
     * Gets the attribute value for BROKER_NAME using the alias name BrokerName1.
     * @return the BROKER_NAME
     */
    public String getBrokerName1() {
        return (String) getAttributeInternal(BROKERNAME1);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_NAME using the alias name BrokerName1.
     * @param value value to set the BROKER_NAME
     */
    public void setBrokerName1(String value) {
        setAttributeInternal(BROKERNAME1, value);
    }

    /**
     * Gets the attribute value for BROKER_ID_NO using the alias name BrokerIdNo1.
     * @return the BROKER_ID_NO
     */
    public Integer getBrokerIdNo1() {
        return (Integer) getAttributeInternal(BROKERIDNO1);
    }

    /**
     * Sets <code>value</code> as attribute value for BROKER_ID_NO using the alias name BrokerIdNo1.
     * @param value value to set the BROKER_ID_NO
     */
    public void setBrokerIdNo1(Integer value) {
        setAttributeInternal(BROKERIDNO1, value);
    }

    /**
     * Gets the attribute value for PARENT_BROKER_ID_NO using the alias name ParentBrokerIdNo.
     * @return the PARENT_BROKER_ID_NO
     */
    public Integer getParentBrokerIdNo() {
        return (Integer) getAttributeInternal(PARENTBROKERIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for PARENT_BROKER_ID_NO using the alias name ParentBrokerIdNo.
     * @param value value to set the PARENT_BROKER_ID_NO
     */
    public void setParentBrokerIdNo(Integer value) {
        setAttributeInternal(PARENTBROKERIDNO, value);
    }

    /**
     * Gets the attribute value for PASSPORT_CODE using the alias name PassportCode.
     * @return the PASSPORT_CODE
     */
    public String getPassportCode() {
        return (String) getAttributeInternal(PASSPORTCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for PASSPORT_CODE using the alias name PassportCode.
     * @param value value to set the PASSPORT_CODE
     */
    public void setPassportCode(String value) {
        setAttributeInternal(PASSPORTCODE, value);
    }

    /**
     * Gets the attribute value for PERSON_TITLE_CODE using the alias name PersonTitleCode.
     * @return the PERSON_TITLE_CODE
     */
    public String getPersonTitleCode() {
        return (String) getAttributeInternal(PERSONTITLECODE);
    }

    /**
     * Sets <code>value</code> as attribute value for PERSON_TITLE_CODE using the alias name PersonTitleCode.
     * @param value value to set the PERSON_TITLE_CODE
     */
    public void setPersonTitleCode(String value) {
        setAttributeInternal(PERSONTITLECODE, value);
    }

    /**
     * Gets the attribute value for SMS_NOTIFICATION_IND using the alias name SmsNotificationInd.
     * @return the SMS_NOTIFICATION_IND
     */
    public String getSmsNotificationInd() {
        return (String) getAttributeInternal(SMSNOTIFICATIONIND);
    }

    /**
     * Sets <code>value</code> as attribute value for SMS_NOTIFICATION_IND using the alias name SmsNotificationInd.
     * @param value value to set the SMS_NOTIFICATION_IND
     */
    public void setSmsNotificationInd(String value) {
        setAttributeInternal(SMSNOTIFICATIONIND, value);
    }

    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the attribute value for COMPANY_NAME using the alias name CompanyName.
     * @return the COMPANY_NAME
     */
    public String getCompanyName() {
        return (String) getAttributeInternal(COMPANYNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for COMPANY_NAME using the alias name CompanyName.
     * @param value value to set the COMPANY_NAME
     */
    public void setCompanyName(String value) {
        setAttributeInternal(COMPANYNAME, value);
    }

    /**
     * Gets the attribute value for COMPANY_ID_NO using the alias name CompanyIdNoFk.
     * @return the COMPANY_ID_NO
     */
    public Integer getCompanyIdNoFk() {
        return (Integer) getAttributeInternal(COMPANYIDNOFK);
    }

    /**
     * Sets <code>value</code> as attribute value for COMPANY_ID_NO using the alias name CompanyIdNoFk.
     * @param value value to set the COMPANY_ID_NO
     */
    public void setCompanyIdNoFk(Integer value) {
        setAttributeInternal(COMPANYIDNOFK, value);
    }

    /**
     * Gets the associated <code>RowIterator</code> using master-detail link BrokerComments.
     */
    public RowIterator getBrokerComments() {
        return (RowIterator) getAttributeInternal(BROKERCOMMENTS);
    }


    /**
     * Gets the associated <code>RowIterator</code> using master-detail link BrokerFunction.
     */
    public RowIterator getBrokerFunction() {
        return (RowIterator) getAttributeInternal(BROKERFUNCTION);
    }


    /**
     * Gets the associated <code>RowIterator</code> using master-detail link Company2.
     */
    public RowIterator getCompany2() {
        return (RowIterator) getAttributeInternal(COMPANY2);
    }

    /**
     * Gets the associated <code>RowIterator</code> using master-detail link Company1.
     */
    public RowIterator getCompany1() {
        return (RowIterator) getAttributeInternal(COMPANY1);
    }


    /**
     * Gets the associated <code>RowIterator</code> using master-detail link BrokerAuditRoView.
     */
    public RowIterator getBrokerAuditRoView() {
        return (RowIterator) getAttributeInternal(BROKERAUDITROVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> LanguageLovView1.
     */
    public RowSet getLanguageLovView1() {
        return (RowSet) getAttributeInternal(LANGUAGELOVVIEW1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> PersonTitleLovView2.
     */
    public RowSet getPersonTitleLovView2() {
        return (RowSet) getAttributeInternal(PERSONTITLELOVVIEW2);
    }

    /**
     * Gets the view accessor <code>RowSet</code> ActiveLov1.
     */
    public RowSet getActiveLov1() {
        return (RowSet) getAttributeInternal(ACTIVELOV1);
    }

    /**
     * Gets the view accessor <code>RowSet</code> KamBrokerTypeLovView.
     */
    public RowSet getKamBrokerTypeLovView() {
        return (RowSet) getAttributeInternal(KAMBROKERTYPELOVVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> ParentBrokerTypeLovView.
     */
    public RowSet getParentBrokerTypeLovView() {
        return (RowSet) getAttributeInternal(PARENTBROKERTYPELOVVIEW);
    }

    /**
     * Gets the view accessor <code>RowSet</code> CompanyLovView1.
     */
    public RowSet getCompanyLovView1() {
        return (RowSet) getAttributeInternal(COMPANYLOVVIEW1);
    }


}

