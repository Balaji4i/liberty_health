/**
* ----------------------------------------------------------------------
* Change Request: Backdated Changes (LS-1139)
*
* Description  : Fix to OHI_load_pkg
* Author       : Helen Lane
* Date         : 2018-02-13
* Call Syntax  : Just Run (F5) this script in it's entirety
* Steps
*   1) Compile Package 
*   2) Update all possible records by running the package
*                */

-- Compile Package and Function

@../../../../plsql/packages/lhhcom/ohi_policies_load_pkg.sql;

--  3) Update all possible records

/
declare
begin
  OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true);
end;
/   



