/**
* ----------------------------------------------------------------------
* Change Request: LS-1362 Interface Fusion to Self-Build
*
* Description  : LS-1362 Interface Fusion to Self-Build
* Author       : Sarel Eybers
* Date         : 2018-09-18
* Call Syntax  : Just run this code (F5)
*
* Steps
*   1) Create Tables
*   2) Create Indexes
*   3) Create Triggers
*   4) Compile Packages
*   5) Ad Hoc
*                */

--  1) Create Tables

--DROP TABLE "LHHCOM"."INVOICE_PAYMENTS";
--DROP TABLE "LHHCOM"."INVOICE_PAYMENTS_AUDIT";
@../../../../plsql/tables/lhhcom/invoice_payments.sql;
@../../../../plsql/tables/lhhcom/invoice_payments_audit.sql;

--  2) Create Indexes

@../../../../plsql/Indexes/lhhcom/invoice_payments_idx.sql;
@../../../../plsql/Indexes/lhhcom/invoice_payments_aud_idx.sql;

--  3) Create Triggers

@../../../../plsql/triggers/lhhcom/INVOICE_PAYMENTS_AUDIT_BEF_TRG.sql;

--  4) Compile Packages

@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;

--  5) Ad Hoc
/*
Insert into LHHCOM.INVOICE_PAYMENTS
           (COUNTRY_CODE,ACCREDITATION_TYPE_ID_NO,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,ACCRED_LOCAL,ACCRED_MULTI,NO_ACCR_LOCAL,NO_ACCR_MULTI,LAST_UPDATE_DATETIME,USERNAME) 
    values ('UG',3,to_date('01/JAN/1900','DD/MON/YYYY'),to_date('31/JAN/3100','DD/MON/YYYY'),NULL,NULL,'UG_06','UG_10',SYSDATE,'LHHCOM');
    
COMMIT;
*/
