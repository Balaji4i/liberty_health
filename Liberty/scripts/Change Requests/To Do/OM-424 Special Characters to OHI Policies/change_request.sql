/**
* ----------------------------------------------------------------------
* Change Request: OM-424 Special Characters to OHI Policies
*
* Description  : OM-424 Special Characters to OHI Policies
* Author       : Sarel Eybers
* Date         : 2020-12-28
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup old Production package source
*   2) Compile Packages
*                */

--  1) Compile Packages

@../../../../plsql/packages/lhhcom/dnld_ohi_policies_pkg.sql;
    
COMMIT;

/
