/**
* ----------------------------------------------------------------------
* Change Request: Do not Load NULL Countries with Broker
*
* Description  : OP-110 Do not Load NULL Countries with Broker
* Author       : Sarel Eybers
* Date         : 2019-03-18
* Call Syntax  : Just Run (F5) this script in it's etirety
* Audit        : Already compiled in Dev
* Steps
*   1) Compile Commissions package
*                                                                         */

@../../../../plsql/packages/lhhcom/dnld_ohi_policies_pkg.sql;

/

/* Ad Hoc Code
SET SERVEROUTPUT ON;
DECLARE
  lv_return_msg                  VARCHAR2(500);
BEGIN 
  dnld_ohi_policies_pkg.export_company_to_ohi(832000043, lv_return_msg);
END;

*/
