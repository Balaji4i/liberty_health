/**
* ----------------------------------------------------------------------
* Change Request: LS-2261 - Fix Baylor Lesotho data
*
* Description  : LS-2261 - Fix Baylor Lesotho data
* Author       : Sarel Eybers
* Date         : 2018-10-23
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup Data
*   2) Link missing Invoice Numbers
*                                                                         */

-- DROP TABLE "LHHCOM"."TEMP_BACKUP_LS2261";
CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS2261" AS
  SELECT *
    FROM comms_payments_received 
   WHERE     group_code = 'BAYLORLESOTH' 
         AND country_code = 'UG';

COMMIT;

/

  UPDATE comms_payments_received
     SET country_code = 'LS',
         currency_code = 'LSL',
         exchange_rate = 1,
         username = 'LS-2261'
   WHERE     group_code = 'BAYLORLESOTH' 
         AND country_code = 'UG';

/

/* Ad Hoc Code
  SELECT * FROM TEMP_BACKUP_LS2XXX;
  SELECT sum(finance_receipt_amt) FROM TEMP_BACKUP_LS2XXX;

select * from Invoice inv join invoice_detail ind on inv.invoice_no = ind.invoice_no where inv.invoice_type_id_no = 1 and company_id_no = 741000000 and country_code = 'UG' order by 2;
select * from comms_calc_snapshot where company_id_no = 741000000 and country_code = 'UG' and trunc(calculation_datetime) between to_date('01/JUL/2014', 'DD/MON/YYYY') and to_date('31/JUL/2014', 'DD/MON/YYYY');
*/