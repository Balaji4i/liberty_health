/**
* ----------------------------------------------------------------------
* Change Request: LS-1925 Cater for Payment Transaction Types
*
* Description  : LS-1925 Cater for Payment Transaction Types
* Author       : Sarel Eybers
* Date         : 2018-09-06
* Call Syntax  : Just run this code (F5)
*
* Steps
*   1) Alter Table (add columns, update data and fix constraint
*   2) Compile Packages
**                */

--  1) Add columns to Table

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
                       "PAYMENT_TYPE")
;

/

--  2) Compile COMS CALC package
@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;
@../../../../plsql/packages/lhhcom/commissions_pkg.sql;
@../../../../plsql/procedures/lhhcom/get_corr_address_prc.sql;
@../../../../plsql/procedures/lhhcom/get_corr_contact_prc.sql;
@../../../../plsql/functions/lhhcom/get_comp_template.sql;

-- Ad Hoc Code
GRANT EXECUTE ON LHHCOM.get_comp_template TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_address TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_contact TO LHHCORR;
/*

*/