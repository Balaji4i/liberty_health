/**
* ----------------------------------------------------------------------
* Change Request: Create Country Taxes Table in commissions selfbuild (LS-1339)
*
* Description  : Create two tables with indexes and a trigger
* Author       : Sarel Eybers
* Date         : 2018-05-17
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Create Tables
*   2) Create Indexes
*   3) Create Triggers
*   4) Insert record for Uganda
*                */

--  1) Create Tables

--DROP TABLE "LHHCOM"."COUNTRY_TAXES";
--DROP TABLE "LHHCOM"."COUNTRY_TAXES_AUDIT";
@../../../../plsql/tables/lhhcom/country_taxes.sql;
@../../../../plsql/tables/lhhcom/country_taxes_audit.sql;

--  2) Create Indexes

@../../../../plsql/Indexes/lhhcom/country_taxes_idx.sql;
@../../../../plsql/Indexes/lhhcom/country_taxes_aud_idx.sql;

--  3) Create Triggers

@../../../../plsql/triggers/lhhcom/COUNTRY_TAXES_AUDIT_TRG.sql;

--  4) Insert record for Uganda

Insert into LHHCOM.COUNTRY_TAXES 
           (COUNTRY_CODE,ACCREDITATION_TYPE_ID_NO,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,ACCRED_LOCAL,ACCRED_MULTI,NO_ACCR_LOCAL,NO_ACCR_MULTI,LAST_UPDATE_DATETIME,USERNAME) 
    values ('UG',3,to_date('01/JAN/1900','DD/MON/YYYY'),to_date('31/JAN/3100','DD/MON/YYYY'),NULL,NULL,'UG_06','UG_10',SYSDATE,'LHHCOM');
    
COMMIT;

/