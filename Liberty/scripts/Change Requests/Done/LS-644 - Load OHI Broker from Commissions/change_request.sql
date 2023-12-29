/**
* ----------------------------------------------------------------------
* Change Request: Load OHI Broker from Commissions (LS-644)
*
* Description  : Add and Update the OHI Policies Broker data
* Author       : Sarel Eybers / Johan Fourie
* Date         : 2018-02-26
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Change Table
*   2) Compile Package
*   3) Compile Triggers
*   4) Update all possible records once off
*   5) Ad Hoc
*                */

--  1) Change Table

-- Table Changes Compiled First in Commissions Audit Triggers Housekeeping (LS-1074)
-- Before Compiling this change

--  2) Compile Package

@../../../../plsql/packages/lhhcom/dnld_ohi_policies_pkg.sql;
@../../../../plsql/packages/lhhcom/commissions_pkg.sql;

--  3) Compile Triggers

-- Table Changes Compiled First in Commissions Audit Triggers Housekeeping (LS-1074)
-- Before Compiling this change

--  4) Update all possible records once off

EXEC dnld_ohi_policies_pkg.bulk_broker_load;
   
--  5) Ad Hoc Code

/* 
-- Check all the errors in the newest LOGGER Log
select * from logger_logs order by id desc;
-- Check all the records that have not yet been sent
SELECT * FROM dnld_company;
-- DROP Fields
ALTER TABLE "LHHCOM"."COMPANY_AUDIT"
DROP (
"EFFECTIVE_START_DATE", 
"EFFECTIVE_END_DATE");
*/