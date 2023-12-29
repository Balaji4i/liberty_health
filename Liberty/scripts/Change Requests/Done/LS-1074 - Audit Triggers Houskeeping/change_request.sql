/**
* ----------------------------------------------------------------------
* Change Request: Commissions Audit Triggers Housekeeping (LS-1074)
*
* Description  : Make sure the trigger doesn't fail on long descriptions
*                Implement standard Audit handling accross the system
* Author       : Sarel Eybers
* Date         : 2018-03-26
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Drop Tables
*   2) Create Tables
*   3) Compile Triggers
*   4) Ad Hoc
*                */

--  1) Drop Tables

DROP TRIGGER "LHHCOM"."BROKER_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."BROKER_FUNCTION_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_COUNTRY_AUDIT_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_REG_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_FUNCTION_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_ADDRESS_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_AUDIT_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."COMPANY_COUNTRY_BEFORE_TRG";
DROP TRIGGER "LHHCOM"."INVOICE_BEFORE_TRG";

DROP TABLE "LHHCOM"."DNLD_BROKER";
DROP TABLE "LHHCOM"."DNLD_BROKER_ACCRED";
DROP TABLE "LHHCOM"."DNLD_COMPANY";
DROP TABLE "LHHCOM"."DNLD_COMPANY_ACCRED";
DROP TABLE "LHHCOM"."DNLD_COMPANY_ADDRESS";
DROP TABLE "LHHCOM"."DNLD_COMPANY_CONTACT";
DROP TABLE "LHHCOM"."DNLD_INVOICE";
DROP TABLE "LHHCOM"."DNLD_TRN";

--  2) Create Tables

@../../../../plsql/tables/lhhcom/dnld_company.sql;
@../../../../plsql/tables/lhhcom/dnld_company_accred.sql;
@../../../../plsql/tables/lhhcom/dnld_company_address.sql;
@../../../../plsql/tables/lhhcom/dnld_company_contact.sql;
@../../../../plsql/tables/lhhcom/dnld_invoice.sql;
@../../../../plsql/tables/lhhcom/dnld_trn.sql;

ALTER TABLE "LHHCOM"."INVOICE_AUDIT"
ADD ("INVOICE_TYPE_ID_NO" NUMBER(2,0));

ALTER TABLE "LHHCOM"."COMPANY_AUDIT"
ADD (
"EFFECTIVE_START_DATE" DATE, 
"EFFECTIVE_END_DATE" DATE);

@../../../../plsql/Indexes/lhhcom/dnld_company_accred_idx.sql;
@../../../../plsql/Indexes/lhhcom/dnld_company_address_idx.sql;
@../../../../plsql/Indexes/lhhcom/dnld_company_contact_idx.sql;
@../../../../plsql/Indexes/lhhcom/dnld_company_idx.sql;
@../../../../plsql/Indexes/lhhcom/dnld_invoice_idx.sql;
@../../../../plsql/Indexes/lhhcom/dnld_trn_idx.sql;

--  3) Compile Triggers

@../../../../plsql/triggers/lhhcom/OHI_COMM_PERC_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_ENRLMNT_PRDCTS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_GROUPS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_HOLD_IND_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_INSURED_ENTITIES_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_POL_ENRLMNTS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_POLICIES_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_POLICY_BROKERS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_POLICY_GROUPS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_POLICYHOLDERS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/OHI_PRODUCTS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/BROKER_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/BROKER_TABLE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/BROKER_TABLE_TYPE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_ADDRESS_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_ADDRESS_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_FEE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_FEE_TYPE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_REG_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_TABLE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_TABLE_TYPE_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/ACCREDITATION_TYPE_AUD_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/ADDRESS_TYPE_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_ACCREDITAT_AUD_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/BROKER_ACCREDITAT_AUD_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/BROKER_FUNCTION_AUD_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_CONTACT_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_CONTACT_TYPE_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_FUNCTION_AUDIT_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_DETAIL_AUDIT_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_COUNTRY_AUDIT_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_COUNTRY_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_FUNCTION_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_REG_BEFORE_TRG.sql;

@../../../../plsql/packages/lhhcom/STAMP_TRN_PKG.sql;

--  4) Ad Hoc Code

/* 

*/