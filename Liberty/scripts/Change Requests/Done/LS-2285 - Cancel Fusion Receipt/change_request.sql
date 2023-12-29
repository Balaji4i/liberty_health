/**
* ----------------------------------------------------------------------
* Change Request: LS-2285 - Cancel Fusion Receipt
*
* Description  : LS-2285 - Cancel Fusion Receipt
* Author       : Sarel Eybers
* Date         : 2018-10-23
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup Data
*   2) Process Payments
*                                                                         */

-- DROP TABLE "LHHCOM"."TEMP_BACKUP_LS2285";
CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS2285" AS
  SELECT *
    FROM comms_payments_received 
   WHERE     finance_receipt_no = '82328'
         OR  currency_code IS NULL;

COMMIT;

/

  DELETE FROM comms_payments_received
   WHERE     finance_receipt_no = '82328';

/*
  UPDATE comms_payments_received
     SET currency_code = 'UGX',
         exchange_rate = 1,
         processed_ind = 'Y',
         processed_ind = 'Success: Medware Receipt will not be processed in CSB',
         last_updated_datetime = SYSDATE,
         username = 'LS-2285'
   WHERE     finance_receipt_no = '82328';
*/

  UPDATE comms_payments_received
     SET currency_code = 'UGX',
         exchange_rate = 1
   WHERE     currency_code IS NULL
         AND country_code = 'UG';

  UPDATE comms_payments_received
     SET currency_code = 'LSL',
         exchange_rate = 1
   WHERE     currency_code IS NULL
         AND country_code = 'LS';
/

/* Ad Hoc Code
  SELECT * FROM TEMP_BACKUP_LS2285
   WHERE     finance_receipt_no = '82328';
  SELECT sum(finance_receipt_amt) FROM TEMP_BACKUP_LS2XXX;

select * from Invoice inv join invoice_detail ind on inv.invoice_no = ind.invoice_no where inv.invoice_type_id_no = 1 and company_id_no = 741000000 and country_code = 'UG' order by 2;
select * from comms_calc_snapshot where company_id_no = 741000000 and country_code = 'UG' and trunc(calculation_datetime) between to_date('01/JUL/2014', 'DD/MON/YYYY') and to_date('31/JUL/2014', 'DD/MON/YYYY');
*/