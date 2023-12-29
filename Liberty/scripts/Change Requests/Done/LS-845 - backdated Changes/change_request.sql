/**
* ----------------------------------------------------------------------
* Change Request: Backdated Changes (LS-845)
*
* Description  : Find ALL the POEP_IDs to populate COMMS_RECALC 
* Author       : Helen Lane
* Date         : 2018-02-07
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Make a Backup to delete later (if needed)
*   2) Compile Package and Triggers
*   3) Update all possible records by running the package
*   4) Cleanup (if needed)
*   5) add hoc code (if needed)
*                */

--  1) Make a Backup to delete later

 -- CREATE TABLE "LHHCOM"."TEMP_BKUP_LS-845_COMMS_RECALC" AS
 --  SELECT * FROM COMMS_RECALC;
 -- COMMIT;   
   
--  2) Compile Package and Function

@../../../../plsql/packages/lhhcom/ohi_policies_load_pkg.sql;
@../../../../plsql/triggers/lhhcom/ohi_comm_perc_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_policy_brokers_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_enrlmnt_prdcts_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_groups_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_insured_entities_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_policies_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_pol_enrlmnts_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_policy_groups_audit_trg.sql;
@../../../../plsql/triggers/lhhcom/ohi_products_audit_trg.sql;



--  3) Update all possible records

/
declare
begin
  OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true);
end;
/   
--  4) Cleanup

--  DROP TABLE "LHHCOM"."TEMP_BKUP_LS-845_COMMS_RECALC";


--  5) Ad Hoc Code


