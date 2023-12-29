/**
* ----------------------------------------------------------------------
* Change Request: Create Cognos package in commissions selfbuild (LS-1116)
*
* Description  : Create two functions based on the commissions self-build functions get_poep_id and get_percentage.
                 The functions are in the new package commissions_cognos_pkg.pkg
* Author       : Adriaan boot
* Date         : 2018-02-28
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Compile Package
*                */

--  1) Compile Package and Function

@../../../../plsql/packages/lhhcom/commissions_cognos_pkg.sql;

