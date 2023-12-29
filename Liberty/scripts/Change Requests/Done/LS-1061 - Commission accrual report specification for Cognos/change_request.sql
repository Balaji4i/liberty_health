/**
* ----------------------------------------------------------------------
* Change Request: LS-1061 - Commission accrual report specification for Cognos
*
* Description  
*   : Create a one way link between COMMS_CALC_SNAPSHOT to COMMS_PAYMENTS_RECEIVED
*	  : Add a unique key based on a sequence on COMMS_CALC_SNAPSHOT
*	  : Add the unique key from comms_calc_snapshot to COMMS_PAYMENT_RECEIVED as a foreign key as COMMS_CALC_SNAPSHOT_NO.
*	  : Add the sequence related to COMMS_CALC_SNAPSHOT. 
*	    The sequence is called COMMS_CALC_SNAPSHOT_SEQ 
*	  : Add the items currency_code and exchange_rate to COMMS_PAYMENT_RECEIVED 
*	  : Create the new table COMMS_CALC_TRACE and the indexes COMMS_CALC_TRACE_BASE_IDX and COMMS_CALC_TRACE_ORIGINAL_IDX.
*   : Populate this table for existing rows in comms_calc_snapshot  
*	  : Compile the new version of COMMS_CALC_PKG. 
*     This will compile the modified version of procedure commissions_calc_run which now populates COMMS_CALC_SNAPSHOT_NO of COMMS_PAYMENT_RECEIVED. 
*	    This will also make the changes to procedure recalc_changes_run, which populates the table COMMS_CALC_REV_ADJ, live.
*	    This table will be used to link reversal and adjustment rows in COMMS_CALC_SNAPSHOT to the correct row in COMMS_PAYMENT_RECEIVED. 
* Author       : Adriaan Boot
* Date         : 2018-05-24
* Call Syntax  : Just Run (F5) this script in it's entirety
* Steps
*   1) Extract data from COMMS_CALC_SNAPSHOT
*   2) Drop and recreate COMMS_CALC_SNAPSHOT (Add COMMS_CALC_SNAPSHOT_NO)
*   3) Create Triggers and Indexes (Make COMMS_CALC_SNAPSHOT_NO the primary key. Change current primary key to unique index)
*   4) Repopulate COMMS_CALC_SNAPSHOT with COMMS_CALC_SNAPSHOT_NO
*   5) Extract data from COMMS_PAYMENTS_RECEIVED.
*   6) Drop and recreate COMMS_PAYMENTS_RECEIVED. Add the item COMMS_CALC_SNAPSHOT_NO as nullable foreign key. 
*      Add the items currency_code and exchange_rate.
*   7) Create Triggers and Indexes (Add COMMS_CALC_SNAPSHOT_NO and CURRENCY_CODE as indexes)
*   8) Repopulate COMMS_PAYMENTS_RECEIVED with COMMS_CALC_SNAPSHOT_NO, CURRENCY_CODE and EXCHANGE_RATE
*   9) Create the new table COMMS_CALC_TRACE
*   10) Create the new indexes COMMS_CALC_TRACE_BASE_IDX and COMMS_CALC_TRACE_ORIGINAL_IDX. 
*   11) Populate comms_calc_trace for rows already in comms_calc_snapshot.
*   12) Compile new version of COMMS_CALC_PKG. Changes to commissions_calc_run and recalc_changes_run procedures.
*   13) Cleanup will happen later
*                */

--  1) Extract data from COMMS_CALC_SNAPSHOT

  CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS1061" AS
  select     
    COUNTRY_CODE             
   ,PRODUCT_CODE              
   ,POEP_ID                         
   ,PERSON_CODE   
   ,POLICY_CODE   
   ,GROUP_CODE   
   ,BROKER_ID_NO        
   ,COMPANY_ID_NO 
   ,COMMS_PERC 
   ,CONTRIBUTION_DATE  
   ,PAYMENT_RECEIVE_DATE 
   ,FINANCE_RECEIPT_NO  
   ,CALCULATION_DATETIME 
   ,COMMS_CALC_TYPE_CODE 
   ,PAYMENT_RECEIVE_AMT 
   ,PAYMENT_CURRENCY 
   ,COMMS_CALCULATED_AMT 
   ,EXCHANGE_RATE  
   ,EXCHANGE_RATE_CURRENCY_CODE 
   ,COMMS_CALCULATED_EXCH_AMT 
   ,INVOICE_NO 
   ,LAST_UPDATE_DATETIME 
   ,USERNAME 
   FROM COMMS_CALC_SNAPSHOT                         CCS 
   ORDER BY LAST_UPDATE_DATETIME, INVOICE_NO;

  commit;   
/   
--  2) Drop and recreate COMMS_CALC_SNAPSHOT (Add Comms_Calc_Snapshot_No)

DROP TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT";

@../../../../plsql/tables/lhhcom/comms_calc_snapshot.sql;

--  3) Recreate Indexes (Change current primary key to unique index :
--     COUNTRY_CODE ,PRODUCT_CODE ,POEP_ID ,PERSON_CODE ,POLICY_CODE ,GROUP_CODE
--    ,BROKER_ID_NO ,COMPANY_ID_NO ,CONTRIBUTION_DATE ,PAYMENT_RECEIVE_DATE ,FINANCE_RECEIPT_NO
--    ,CALCULATION_DATETIME ,COMMS_CALC_TYPE_CODE ,PAYMENT_CURRENCY ,EXCHANGE_RATE_CURRENCY_CODE

@../../../../plsql/Indexes/lhhcom/comms_calc_snap_idx.sql;

--     Create Comms_calc_snapshot_no sequence:
--drop sequence comms_calc_snapshot_seq;
@../../../../plsql/sequences/lhhcom/comms_calc_snapshot_seq.sql;

--  4) Repopulate COMMS_CALC_SNAPSHOT with Comms_Calc_Snapshot_No

  insert into comms_calc_snapshot
          (comms_calc_snapshot_no
         ,COUNTRY_CODE
         ,PRODUCT_CODE
         ,POEP_ID
         ,PERSON_CODE
         ,POLICY_CODE
         ,GROUP_CODE
         ,BROKER_ID_NO
         ,COMPANY_ID_NO
         ,COMMS_PERC
         ,CONTRIBUTION_DATE
         ,PAYMENT_RECEIVE_DATE
         ,FINANCE_RECEIPT_NO
         ,CALCULATION_DATETIME
         ,COMMS_CALC_TYPE_CODE
         ,PAYMENT_RECEIVE_AMT
         ,PAYMENT_CURRENCY
         ,COMMS_CALCULATED_AMT
         ,EXCHANGE_RATE
         ,EXCHANGE_RATE_CURRENCY_CODE
         ,COMMS_CALCULATED_EXCH_AMT
         ,INVOICE_NO
         ,last_update_datetime
         ,username)
   select comms_calc_snapshot_seq.nextval
         ,COUNTRY_CODE
         ,PRODUCT_CODE
         ,POEP_ID
         ,PERSON_CODE
         ,POLICY_CODE
         ,GROUP_CODE
         ,BROKER_ID_NO
         ,COMPANY_ID_NO
         ,COMMS_PERC
         ,CONTRIBUTION_DATE
         ,PAYMENT_RECEIVE_DATE
         ,FINANCE_RECEIPT_NO
         ,CALCULATION_DATETIME
         ,COMMS_CALC_TYPE_CODE
         ,PAYMENT_RECEIVE_AMT
         ,PAYMENT_CURRENCY
         ,COMMS_CALCULATED_AMT
         ,EXCHANGE_RATE
         ,EXCHANGE_RATE_CURRENCY_CODE
         ,COMMS_CALCULATED_EXCH_AMT
         ,INVOICE_NO
         ,last_update_datetime
         ,username      
   from "LHHCOM"."TEMP_BACKUP_LS1061";

  commit;   
/  
-- 5) Extract data from COMMS_PAYMENTS_RECEIVED

  CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS1061B" AS
  SELECT     
    APPLICATION_ID
  , GROUP_CODE
  , COUNTRY_CODE
  , PRODUCT_CODE
  , POLICY_CODE
  , PERSON_CODE
  , CONTRIBUTION_DATE
  , FINANCE_RECEIPT_NO
  , FINANCE_RECEIPT_DATE
  , FINANCE_INVOICE_NO
  , FINANCE_INVOICE_DATE
  , FINANCE_RECEIPT_AMT
  , PROCESSED_IND
  , PROCESSED_DESC
  , LAST_UPDATE_DATETIME
  , USERNAME
  FROM COMMS_PAYMENTS_RECEIVED                         CPR ;

  commit;  
/
--  6) Drop and recreate COMMS_PAYMENTS_RECEIVED (Add Comms_Calc_Snapshot_No, Currency_Code, Exchange_Rate) 
DROP TABLE "LHHCOM"."COMMS_PAYMENTS_RECEIVED";

@../../../../plsql/tables/lhhcom/comms_payments_received.sql;


--  7) Create Indexes (Add indexes on Comms_calc_snapshot_no and Currency_code)

@../../../../plsql/indexes/lhhcom/comms_payment_rec_idx.sql;

--  8) Repopulate COMMS_PAYMENTS_RECEIVED with Comms_Calc_Snapshot_No. The items Currency_Code and Exchange_Rate will be populated later.
--     Here it is necessary to run 6 procedures to handle all the possible scenarios.

--     Compile the procedures.
@../../../../plsql/procedures/lhhcom/cpr_update_early_months_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_grouping_jhpgl_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_other_groups_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_receipt_no1_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_receipt_no2_prc.SQL
@../../../../plsql/procedures/lhhcom/cpr_update_receipt_no3_prc.SQL
@../../../../plsql/procedures/lhhcom/cpr_update_grouping_examsc_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_grouping_matek_prc.sql
@../../../../plsql/procedures/lhhcom/cpr_update_grouping_lselc_prc.sql
/
 
--     Run the procedures. 

  declare 
    
  BEGIN
   cpr_update_early_months_prc('2016-11-01','2017-03-01',1);
   cpr_update_early_months_prc('2016-11-01','2017-03-01',2);
   cpr_update_grouping_jhpgl_prc('2017-04-01','2018-05-01');
   cpr_update_other_groups_prc('2017-04-01','2018-05-01',1);
   cpr_update_other_groups_prc('2017-04-01','2018-05-01',2);
   cpr_update_receipt_no1_prc;
   cpr_update_receipt_no2_prc;
   cpr_update_receipt_no3_prc(1);
   cpr_update_receipt_no3_prc(2);
   cpr_update_grouping_examsc_prc('2017-12-01','2018-06-01');
   cpr_update_grouping_matek_prc('2018-05-01','2018-05-01');
   cpr_update_grouping_lselc_prc('2018-01-01','2018-04-01');
  end;
/
--     Drop the procedures. 

DROP PROCEDURE lhhcom.cpr_update_early_months_prc;
DROP PROCEDURE lhhcom.cpr_update_grouping_jhpgl_prc;
DROP PROCEDURE lhhcom.cpr_update_other_groups_prc;
DROP PROCEDURE lhhcom.cpr_update_receipt_no1_prc;
DROP PROCEDURE lhhcom.cpr_update_receipt_no2_prc;
DROP PROCEDURE lhhcom.cpr_update_receipt_no3_prc;
DROP PROCEDURE lhhcom.cpr_update_grouping_examsc_prc;
DROP PROCEDURE lhhcom.cpr_update_grouping_matek_prc;
DROP PROCEDURE lhhcom.cpr_update_grouping_lselc_prc;


--  9) Drop and recreate COMMS_CALC_TRACE 
--drop table "LHHCOM"."COMMS_CALC_TRACE";

@../../../../plsql/tables/lhhcom/comms_calc_trace.sql;

-- 10) Create the new indexes COMMS_CALC_TRACE_BASE_IDX and COMMS_CALC_TRACE_ORIGINAL_IDX

@../../../../plsql/indexes/lhhcom/comms_calc_trace_idx.sql;

-- 11) Populate comms_calc_trace for rows already in comms_calc_snapshot
--     Compile the procedures    
@../../../../plsql/procedures/lhhcom/load_comms_calc_trace.sql

--     Run the procedures. 

  declare 
    
  begin
   load_comms_calc_trace;
  end;
/
   
--     Drop the procedures. 

DROP PROCEDURE lhhcom.load_comms_calc_trace;   
   
-- 12) Compile new COMMS_CALC procedure. Changes to commissions_calc_run and recalc_changes_run procedures.

@comms_calc_pkg.sql;

-- 13) Cleanup

--  DROP TABLE "LHHCOM"."TEMP_BACKUP_LS1061";
--  DROP TABLE "LHHCOM"."TEMP_BACKUP_LS1061B";

--  COMMIT;
  
--  ) Ad Hoc Code

 select count(*) from lhhcom.comms_calc_snapshot where comms_calc_snapshot_no is null;

 select count(*) from comms_payments_received where comms_calc_snapshot_no is null and processed_ind = 'Y'; 

 select 
    ccs.comms_calc_snapshot_no 
  , ccs.finance_receipt_no 
  , ccs.person_code
  , ccs.policy_code
  , ccs.payment_receive_date
  , ccs.payment_receive_amt
  , ccs.contribution_date
  , ccs.group_code
  , ccs.product_code
  , cpr.comms_calc_snapshot_no foreign
    from comms_calc_snapshot ccs 
      left join comms_payments_received cpr
        ON ccs.comms_calc_snapshot_no = cpr.comms_calc_snapshot_no 
      where ccs.comms_calc_type_code in ('P', 'X') and trim(ccs.finance_receipt_no) != '0'; 
/
/* Sarel en Adriaan update laaste 1019/1679 CPR records met Snapshot ID */

@../../../../plsql/procedures/lhhcom/cpr_update_other_groups_fix_prc.sql

  CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS1061C" AS
  SELECT *
  FROM COMMS_PAYMENTS_RECEIVED                         CPR ;

  commit;  

/
  declare 
    
  BEGIN
   cpr_update_other_groups_fx_prc('2018-06-01','2018-07-01',1);
  end;
/

DROP PROCEDURE lhhcom.cpr_update_other_groups_fx_prc;
/
SELECT 
      cpr.application_id,
      cpr.group_code,
      cpr.product_code,
      cpr.country_code,
      cpr.policy_code,
      cpr.person_code,
      cpr.contribution_date,
      cpr.finance_receipt_no,
      cpr.finance_receipt_date,
      cpr.comms_calc_snapshot_no
    FROM lhhcom.comms_payments_received cpr
    left outer JOIN lhhcom.temp_backup_ls1061c ls1061c
        ON cpr.application_id = ls1061c.application_id AND 
           cpr.group_code = ls1061c.group_code AND 
           cpr.product_code = ls1061c.product_code AND
           cpr.country_code = ls1061c.country_code AND
           cpr.policy_code = ls1061c.policy_code AND
           cpr.person_code = ls1061c.person_code AND
           cpr.contribution_date = ls1061c.contribution_date AND
           cpr.finance_receipt_no = ls1061c.finance_receipt_no AND
           cpr.finance_receipt_date = ls1061c.finance_receipt_date
  WHERE cpr.comms_calc_snapshot_no <> ls1061c.comms_calc_snapshot_no
    or (cpr.comms_calc_snapshot_no is null and ls1061c.comms_calc_snapshot_no is not null)
    or (cpr.comms_calc_snapshot_no is not null and ls1061c.comms_calc_snapshot_no is null);  

select PROCESSED_IND, count(*) from comms_payments_received where comms_calc_snapshot_no is NULL group by PROCESSED_IND;