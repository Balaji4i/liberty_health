/**
* ----------------------------------------------------------------------
* Change Request: LS-1361 WHT Interface to Fusion
*
* Description  : LS-1361 WHT Interface to Fusion
* Author       : Sarel Eybers
* Date         : 2018-06-28
* Call Syntax  : Just run this code (F5)
*
* Steps
*   1) Add columns to Table
*   2) Compile Audit Trigger
*   3) Compile COMS CALC package
**                */

--  1) Add columns to Table

ALTER TABLE "LHHCOM"."INVOICE" 
ADD "INVOICE_TAX_CODES" VARCHAR2(50 BYTE);
ALTER TABLE "LHHCOM"."INVOICE_AUDIT" 
ADD "INVOICE_TAX_CODES" VARCHAR2(50 BYTE);
/

--  2) Compile Audit Trigger - - - ************* Still to Do ****************
@../../../../plsql/triggers/lhhcom/INVOICE_AUDIT_BEFORE_TRG.sql;

--  3) Compile COMS CALC package
@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;

-- Ad Hoc Code
/*

*/