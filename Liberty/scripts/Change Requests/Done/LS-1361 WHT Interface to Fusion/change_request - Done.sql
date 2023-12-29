/**
* ----------------------------------------------------------------------
* Change Request: Enlarge Amount columns
*
* Description  : Enlarge Amount Columns
* Author       : Sarel Eybers
* Date         : 2018-09-18
* Call Syntax  : Just run this code (F5)
*
* Steps
*   1) Alter Table                                          - Done
*   2) Update COMMS_PAYMENTS_RECEIVED Currency and Exchange - Done
*   3) Ad Hoc
**                */

--  1) Alter Table

  ALTER TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT"
    MODIFY
      (
       PAYMENT_RECEIVE_AMT         NUMBER(22,9)
      ,COMMS_CALCULATED_AMT        NUMBER(22,9)
      ,COMMS_CALCULATED_EXCH_AMT   NUMBER(22,9)
      );
  ALTER TABLE "LHHCOM"."INVOICE"
    MODIFY
      (
       PAYMENT_AMT                 NUMBER(22,9)
      );
  ALTER TABLE "LHHCOM"."INVOICE_AUDIT"
    MODIFY
      (
       PAYMENT_AMT                 NUMBER(22,9)
      );
  ALTER TABLE "LHHCOM"."INVOICE_DETAIL"
    MODIFY
      (
       FEE_TYPE_AMT                NUMBER(22,9)
      ,FEE_TYPE_EXCH_AMT           NUMBER(22,9)
      );
  ALTER TABLE "LHHCOM"."INVOICE_DETAIL_AUDIT"
    MODIFY
      (
       FEE_TYPE_AMT                NUMBER(22,9)
      ,FEE_TYPE_EXCH_AMT           NUMBER(22,9)
      );

--  2) Update COMMS_PAYMENTS_RECEIVED Currency and Exchange

UPDATE comms_payments_received
   SET currency_code = 'LSL'
 WHERE currency_code IS NULL
   AND country_code = 'LS';

UPDATE comms_payments_received
   SET exchange_rate = 1
 WHERE exchange_rate IS NULL
   AND country_code = 'LS';

--  3) Ad Hoc
/*
SELECT country_code, currency_code, exchange_rate, count(*)
  FROM comms_payments_received
-- WHERE currency_code IS NULL
--    OR exchange_rate IS NULL
 GROUP BY country_code, currency_code, exchange_rate;
*/
