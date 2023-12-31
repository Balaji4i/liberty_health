package com.liberty.health.comms.model.broker.vo;

import com.core.model.vo.classes.CoreViewRowImpl;

import java.sql.Timestamp;

import oracle.jbo.RowSet;
import oracle.jbo.domain.Date;
import oracle.jbo.server.EntityImpl;
// ---------------------------------------------------------------------
// ---    File generated by Oracle ADF Business Components Design Time.
// ---    Tue Jul 25 12:26:10 CAT 2017
// ---    Custom code may be added to this class.
// ---    Warning: Do not modify method signatures of generated methods.
// ---------------------------------------------------------------------
public class CompanyBankDetailsVORowImpl extends CoreViewRowImpl {
    public static final int ENTITY_COMPANYBANKDETAILSEO = 0;
    public static final int ENTITY_BANKACCOUNTTYPEEO = 1;

    /**
     * AttributesEnum: generated enum for identifying attributes and accessors. DO NOT MODIFY.
     */
    protected enum AttributesEnum {
        CompanyIdNo,
        CountryCode,
        EffectiveStartDate,
        EffectiveEndDate,
        BankAccTypeIdNo,
        AccHolderName,
        BankAccName,
        BankAccNo,
        BankName,
        BankBranchCode,
        BankBranchName,
        BankSwiftCode,
        IbanNibNo,
        CreatedUsername,
        AuthUsername,
        LastUpdateDatetime,
        Username,
        BankAccTypeDesc,
        BankAccTypeIdNoFk,
        BankAccountTypeLovView1;
        private static AttributesEnum[] vals = null;
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
    public static final int COMPANYIDNO = AttributesEnum.CompanyIdNo.index();
    public static final int COUNTRYCODE = AttributesEnum.CountryCode.index();
    public static final int EFFECTIVESTARTDATE = AttributesEnum.EffectiveStartDate.index();
    public static final int EFFECTIVEENDDATE = AttributesEnum.EffectiveEndDate.index();
    public static final int BANKACCTYPEIDNO = AttributesEnum.BankAccTypeIdNo.index();
    public static final int ACCHOLDERNAME = AttributesEnum.AccHolderName.index();
    public static final int BANKACCNAME = AttributesEnum.BankAccName.index();
    public static final int BANKACCNO = AttributesEnum.BankAccNo.index();
    public static final int BANKNAME = AttributesEnum.BankName.index();
    public static final int BANKBRANCHCODE = AttributesEnum.BankBranchCode.index();
    public static final int BANKBRANCHNAME = AttributesEnum.BankBranchName.index();
    public static final int BANKSWIFTCODE = AttributesEnum.BankSwiftCode.index();
    public static final int IBANNIBNO = AttributesEnum.IbanNibNo.index();
    public static final int CREATEDUSERNAME = AttributesEnum.CreatedUsername.index();
    public static final int AUTHUSERNAME = AttributesEnum.AuthUsername.index();
    public static final int LASTUPDATEDATETIME = AttributesEnum.LastUpdateDatetime.index();
    public static final int USERNAME = AttributesEnum.Username.index();
    public static final int BANKACCTYPEDESC = AttributesEnum.BankAccTypeDesc.index();
    public static final int BANKACCTYPEIDNOFK = AttributesEnum.BankAccTypeIdNoFk.index();
    public static final int BANKACCOUNTTYPELOVVIEW1 = AttributesEnum.BankAccountTypeLovView1.index();

    /**
     * This is the default constructor (do not remove).
     */
    public CompanyBankDetailsVORowImpl() {
    }

    /**
     * Gets CompanyBankDetailsEO entity object.
     * @return the CompanyBankDetailsEO
     */
    public EntityImpl getCompanyBankDetailsEO() {
        return (EntityImpl) getEntity(ENTITY_COMPANYBANKDETAILSEO);
    }

    /**
     * Gets BankAccountTypeEO entity object.
     * @return the BankAccountTypeEO
     */
    public EntityImpl getBankAccountTypeEO() {
        return (EntityImpl) getEntity(ENTITY_BANKACCOUNTTYPEEO);
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
     * Gets the attribute value for COUNTRY_CODE using the alias name CountryCode.
     * @return the COUNTRY_CODE
     */
    public String getCountryCode() {
        return (String) getAttributeInternal(COUNTRYCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for COUNTRY_CODE using the alias name CountryCode.
     * @param value value to set the COUNTRY_CODE
     */
    public void setCountryCode(String value) {
        setAttributeInternal(COUNTRYCODE, value);
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
     * Gets the attribute value for BANK_ACC_TYPE_ID_NO using the alias name BankAccTypeIdNo.
     * @return the BANK_ACC_TYPE_ID_NO
     */
    public Integer getBankAccTypeIdNo() {
        return (Integer) getAttributeInternal(BANKACCTYPEIDNO);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_ACC_TYPE_ID_NO using the alias name BankAccTypeIdNo.
     * @param value value to set the BANK_ACC_TYPE_ID_NO
     */
    public void setBankAccTypeIdNo(Integer value) {
        setAttributeInternal(BANKACCTYPEIDNO, value);
    }

    /**
     * Gets the attribute value for ACC_HOLDER_NAME using the alias name AccHolderName.
     * @return the ACC_HOLDER_NAME
     */
    public String getAccHolderName() {
        return (String) getAttributeInternal(ACCHOLDERNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for ACC_HOLDER_NAME using the alias name AccHolderName.
     * @param value value to set the ACC_HOLDER_NAME
     */
    public void setAccHolderName(String value) {
        setAttributeInternal(ACCHOLDERNAME, value);
    }

    /**
     * Gets the attribute value for BANK_ACC_NAME using the alias name BankAccName.
     * @return the BANK_ACC_NAME
     */
    public String getBankAccName() {
        return (String) getAttributeInternal(BANKACCNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_ACC_NAME using the alias name BankAccName.
     * @param value value to set the BANK_ACC_NAME
     */
    public void setBankAccName(String value) {
        setAttributeInternal(BANKACCNAME, value);
    }

    /**
     * Gets the attribute value for BANK_ACC_NO using the alias name BankAccNo.
     * @return the BANK_ACC_NO
     */
    public String getBankAccNo() {
        return (String) getAttributeInternal(BANKACCNO);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_ACC_NO using the alias name BankAccNo.
     * @param value value to set the BANK_ACC_NO
     */
    public void setBankAccNo(String value) {
        setAttributeInternal(BANKACCNO, value);
    }

    /**
     * Gets the attribute value for BANK_NAME using the alias name BankName.
     * @return the BANK_NAME
     */
    public String getBankName() {
        return (String) getAttributeInternal(BANKNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_NAME using the alias name BankName.
     * @param value value to set the BANK_NAME
     */
    public void setBankName(String value) {
        setAttributeInternal(BANKNAME, value);
    }

    /**
     * Gets the attribute value for BANK_BRANCH_CODE using the alias name BankBranchCode.
     * @return the BANK_BRANCH_CODE
     */
    public String getBankBranchCode() {
        return (String) getAttributeInternal(BANKBRANCHCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_BRANCH_CODE using the alias name BankBranchCode.
     * @param value value to set the BANK_BRANCH_CODE
     */
    public void setBankBranchCode(String value) {
        setAttributeInternal(BANKBRANCHCODE, value);
    }

    /**
     * Gets the attribute value for BANK_BRANCH_NAME using the alias name BankBranchName.
     * @return the BANK_BRANCH_NAME
     */
    public String getBankBranchName() {
        return (String) getAttributeInternal(BANKBRANCHNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_BRANCH_NAME using the alias name BankBranchName.
     * @param value value to set the BANK_BRANCH_NAME
     */
    public void setBankBranchName(String value) {
        setAttributeInternal(BANKBRANCHNAME, value);
    }

    /**
     * Gets the attribute value for BANK_SWIFT_CODE using the alias name BankSwiftCode.
     * @return the BANK_SWIFT_CODE
     */
    public String getBankSwiftCode() {
        return (String) getAttributeInternal(BANKSWIFTCODE);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_SWIFT_CODE using the alias name BankSwiftCode.
     * @param value value to set the BANK_SWIFT_CODE
     */
    public void setBankSwiftCode(String value) {
        setAttributeInternal(BANKSWIFTCODE, value);
    }

    /**
     * Gets the attribute value for IBAN_NIB_NO using the alias name IbanNibNo.
     * @return the IBAN_NIB_NO
     */
    public String getIbanNibNo() {
        return (String) getAttributeInternal(IBANNIBNO);
    }

    /**
     * Sets <code>value</code> as attribute value for IBAN_NIB_NO using the alias name IbanNibNo.
     * @param value value to set the IBAN_NIB_NO
     */
    public void setIbanNibNo(String value) {
        setAttributeInternal(IBANNIBNO, value);
    }

    /**
     * Gets the attribute value for CREATED_USERNAME using the alias name CreatedUsername.
     * @return the CREATED_USERNAME
     */
    public String getCreatedUsername() {
        return (String) getAttributeInternal(CREATEDUSERNAME);
    }

    /**
     * Gets the attribute value for AUTH_USERNAME using the alias name AuthUsername.
     * @return the AUTH_USERNAME
     */
    public String getAuthUsername() {
        return (String) getAttributeInternal(AUTHUSERNAME);
    }

    /**
     * Sets <code>value</code> as attribute value for AUTH_USERNAME using the alias name AuthUsername.
     * @param value value to set the AUTH_USERNAME
     */
    public void setAuthUsername(String value) {
        setAttributeInternal(AUTHUSERNAME, value);
    }

    /**
     * Gets the attribute value for LAST_UPDATE_DATETIME using the alias name LastUpdateDatetime.
     * @return the LAST_UPDATE_DATETIME
     */
    public Timestamp getLastUpdateDatetime() {
        return (Timestamp) getAttributeInternal(LASTUPDATEDATETIME);
    }

    /**
     * Gets the attribute value for USERNAME using the alias name Username.
     * @return the USERNAME
     */
    public String getUsername() {
        return (String) getAttributeInternal(USERNAME);
    }

    /**
     * Gets the attribute value for BANK_ACC_TYPE_DESC using the alias name BankAccTypeDesc.
     * @return the BANK_ACC_TYPE_DESC
     */
    public String getBankAccTypeDesc() {
        return (String) getAttributeInternal(BANKACCTYPEDESC);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_ACC_TYPE_DESC using the alias name BankAccTypeDesc.
     * @param value value to set the BANK_ACC_TYPE_DESC
     */
    public void setBankAccTypeDesc(String value) {
        setAttributeInternal(BANKACCTYPEDESC, value);
    }

    /**
     * Gets the attribute value for BANK_ACC_TYPE_ID_NO using the alias name BankAccTypeIdNoFk.
     * @return the BANK_ACC_TYPE_ID_NO
     */
    public Integer getBankAccTypeIdNoFk() {
        return (Integer) getAttributeInternal(BANKACCTYPEIDNOFK);
    }

    /**
     * Sets <code>value</code> as attribute value for BANK_ACC_TYPE_ID_NO using the alias name BankAccTypeIdNoFk.
     * @param value value to set the BANK_ACC_TYPE_ID_NO
     */
    public void setBankAccTypeIdNoFk(Integer value) {
        setAttributeInternal(BANKACCTYPEIDNOFK, value);
    }

    /**
     * Gets the view accessor <code>RowSet</code> BankAccountTypeLovView1.
     */
    public RowSet getBankAccountTypeLovView1() {
        return (RowSet) getAttributeInternal(BANKACCOUNTTYPELOVVIEW1);
    }
}

