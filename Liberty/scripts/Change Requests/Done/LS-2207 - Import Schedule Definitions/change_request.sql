/**
* ----------------------------------------------------------------------
* Change Request: Import and use Commissionable Flag (LS-2207)
*
* Description  : Import and use Commissionable Flag
* Author       : Sarel Eybers
* Date         : 2018-12-12
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Create Table
*   2) Compile Procedure
*   3) Compile Function
*   4) Compile COMMS Calc package
*   5) Any Data fixes that need to be run before go-live ? ? ?
*                                                                         */

--DROP TABLE globaltemp_json_workspace PURGE;
CREATE GLOBAL TEMPORARY TABLE globaltemp_json_workspace
  (interface                  VARCHAR2(30)
  ,data                       CLOB
  ,CONSTRAINT ensure_json     CHECK (data IS JSON (STRICT))
  ) ON COMMIT DELETE ROWS;

ALTER TABLE "LHHCOM"."COMMS_PAYMENTS_RECEIVED" 
        ADD "COMMISSIONABLE" VARCHAR2(1 BYTE);

@../../../../plsql/procedures/lhhcom/refresh_pay_comms.sql;
@../../../../plsql/functions/lhhcom/iscommissionable_prem_code.sql;
@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;

/

/* Ad Hoc Code
-- Run to check a code
SET SERVEROUTPUT ON;
DECLARE
BEGIN
--  lhhcom.refresh_pay_comms;
--  lhhcom.refresh_pay_comms('Y');
--END;
  dbms_output.put_line('Is CORE/LS/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('CORE', to_date('2015/06/30', 'YYYY/MM/DD'), 'LS'));
  dbms_output.put_line('Is CORE/LS/today commissionable? ' || lhhcom.iscommissionable_prem_code('CORE', SYSDATE, 'LS'));
  dbms_output.put_line('Is CORE/UG/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('CORE', to_date('2015/06/30', 'YYYY/MM/DD'), 'UG'));
  dbms_output.put_line('Is CORE/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('CORE', SYSDATE, 'UG'));
  dbms_output.put_line('Is CORE/  /2015  commissionable? ' || lhhcom.iscommissionable_prem_code('CORE', to_date('2015/06/30', 'YYYY/MM/DD')));
  dbms_output.put_line('Is CORE/  /today commissionable? ' || lhhcom.iscommissionable_prem_code('CORE'));
  dbms_output.put_line('Is FUNL/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', SYSDATE, 'UG'));
  dbms_output.put_line('Is FUNL/UG/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', to_date('2015/06/30', 'YYYY/MM/DD'), 'UG'));
  dbms_output.put_line('Is FUNL/NG/today commissionable? ' || lhhcom.iscommissionable_prem_code('FUNL', SYSDATE, 'NG'));
  dbms_output.put_line('Is LSCD/LS/today commissionable? ' || lhhcom.iscommissionable_prem_code('LSCD', SYSDATE, 'LS'));
  dbms_output.put_line('Is ACQ /UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ ', SYSDATE, 'UG'));
  dbms_output.put_line('Is ACQ /NG/today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ ', SYSDATE, 'NG'));
  dbms_output.put_line('Is ACQ /  /today commissionable? ' || lhhcom.iscommissionable_prem_code('ACQ'));
  dbms_output.put_line('Is SUPL/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('SUPL', SYSDATE, 'UG'));
  dbms_output.put_line('Is UGSD/UG/2015  commissionable? ' || lhhcom.iscommissionable_prem_code('UGSD', to_date('2015/06/30', 'YYYY/MM/DD'), 'UG'));
  dbms_output.put_line('Is UGSD/UG/today commissionable? ' || lhhcom.iscommissionable_prem_code('UGSD', SYSDATE, 'UG'));
  dbms_output.put_line('Is UGSD/UG/2018  commissionable? ' || lhhcom.iscommissionable_prem_code('UGSD', to_date('2018/06/30', 'YYYY/MM/DD'), 'UG'));
END;
/
SELECT * FROM globaltemp_pay_comms;
SELECT * FROM globaltemp_json_workspace;
SELECT * FROM LHHCOM.comms_payments_received;
SELECT processed_ind
      ,country_code
      ,payment_type
      ,processed_desc
      ,count(*) Cnt 
SELECT *
  FROM LHHCOM.comms_payments_received 
 WHERE     country_code = 'UG'
       AND payment_type > ' '
       AND (    processed_desc LIKE '%No Commission%'
            OR  processed_ind IN ('TY', 'TF'))
-- GROUP BY processed_ind
--         ,country_code
--         ,payment_type 
--         ,processed_desc
 ORDER BY processed_desc;
UPDATE LHHCOM.comms_payments_received
   SET processed_ind = 'TY'
 WHERE country_code = 'UG' and processed_ind = 'Y';
-- */
/*
DECLARE
BEGIN
  COMMS_CALC_PKG.commissions_calc_run (NULL, 'UG', NULL, NULL, 'SVETEST1');
END;
*/
