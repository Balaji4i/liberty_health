/**
* ----------------------------------------------------------------------
* Change Request: ARP-558 Recalc Affected POEP_IDs
*
* Description  : ARP-558 Recalc Affected POEP_IDs
* Author       : Sarel Eybers
* Date         : 2021-03-03
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup old Production package source
*   2) Compile Packages
*                */

--  1) Compile Packages

@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;
    
COMMIT;

/
