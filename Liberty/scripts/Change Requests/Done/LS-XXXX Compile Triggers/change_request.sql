/**
* ----------------------------------------------------------------------
* Change Request: LS-XXXX Compile Triggers for DNLD_COMPANY
*
* Description  : LS-XXXX Compile Triggers for DNLD_COMPANY
* Author       : Sarel Eybers
* Date         : 2018-09-20
* Call Syntax  : Just run this code (F5)
*
* Steps
*   1) Compile Triggers
**                */

--  1) Compile triggers
@../../../../plsql/triggers/lhhcom/COMPANY_COUNTRY_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_AUDIT_BEFORE_TRG.sql;
@../../../../plsql/triggers/lhhcom/COMPANY_COUNTRY_AUDIT_TRG.sql;

/*

*/