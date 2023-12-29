/**
* ----------------------------------------------------------------------
* Change Request: LS-1654
* Description   : Draaiboek - Deploy Application Code
* Author        : Sarel Eybers
* Date          : 2018-10-04
* Call Syntax   : Just run this code (F5)
*
**                */

--  Table Changes

ALTER TABLE "LHHCOM"."INVOICE" 
ADD "INVOICE_TAX_CODES" VARCHAR2(50 BYTE);
ALTER TABLE "LHHCOM"."INVOICE_AUDIT" 
ADD "INVOICE_TAX_CODES" VARCHAR2(50 BYTE);
@../../../../plsql/tables/lhhcom/invoice_payments.sql;
@../../../../plsql/tables/lhhcom/invoice_payments_audit.sql;
ALTER TABLE "LHHCOM"."COMMS_PAYMENTS_RECEIVED" 
       DROP CONSTRAINT "COMMS_PAYMENTS_RECEIVED_PK";
ALTER TABLE "LHHCOM"."COMMS_PAYMENTS_RECEIVED" 
        ADD "PAYMENT_TYPE" VARCHAR2(10 BYTE) DEFAULT 'ERROR' NOT NULL ENABLE;
UPDATE "LHHCOM"."COMMS_PAYMENTS_RECEIVED"
   SET PAYMENT_TYPE = ' ';
ALTER TABLE "LHHCOM"."COMMS_PAYMENTS_RECEIVED" 
        ADD CONSTRAINT "COMMS_PAYMENTS_RECEIVED_PK" PRIMARY KEY
                      ("APPLICATION_ID",
                       "GROUP_CODE", 
                       "PRODUCT_CODE", 
                       "COUNTRY_CODE", 
                       "POLICY_CODE", 
                       "PERSON_CODE", 
                       "CONTRIBUTION_DATE", 
                       "FINANCE_RECEIPT_NO", 
                       "FINANCE_RECEIPT_DATE",
                       "PAYMENT_TYPE");

COMMIT;
/

--  Indexes

@../../../../plsql/Indexes/lhhcom/invoice_payments_idx.sql;
@../../../../plsql/Indexes/lhhcom/invoice_payments_aud_idx.sql;

--  Triggers

@../../../../plsql/triggers/lhhcom/INVOICE_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/INVOICE_PAYMENTS_AUDIT_BEF_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_COUNTRY_AUDIT_TRG.sql
@../../../../plsql/triggers/lhhcom/COMPANY_AUDIT_BEFORE_TRG.sql

COMMIT;
/

--  Packages, Procedures and Functions

@../../../../plsql/packages/lhhcom/commissions_pkg.sql;
@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;
@../../../../plsql/procedures/lhhcom/get_corr_address_prc.sql;
@../../../../plsql/procedures/lhhcom/iscompany_multinational_prc.sql
@../../../../plsql/procedures/lhhcom/get_corr_contact_prc.sql;
@../../../../plsql/functions/lhhcom/get_comp_template.sql;

--  Grants

GRANT EXECUTE ON LHHCOM.get_comp_template TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_address TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_contact TO LHHCORR;

-- Data Updates

@insert_into_menu_tables.sql;

-- Ad Hoc Code
/*

*/