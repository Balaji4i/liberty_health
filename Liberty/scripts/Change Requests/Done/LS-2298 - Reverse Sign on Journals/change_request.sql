/**
* ----------------------------------------------------------------------
* Change Request: LS-2298 - Reverse Sign on Journals
*
* Description  : LS-2298 - Reverse Sign on Journals
* Author       : Sarel Eybers
* Date         : 2018-10-30
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup Data
*   2) Process Payments
*                                                                         */

-- DROP TABLE "LHHCOM"."DATAFIX_BACKUP_LS2298";
CREATE TABLE "LHHCOM"."DATAFIX_BACKUP_LS2298" AS
  SELECT *
    FROM INVOICE_DETAIL
   WHERE     invoice_no IN (SELECT invoice_no
                              FROM invoice
                             WHERE     country_code = 'UG'
                                   AND invoice_type_id_no = 2
                                   AND release_date IS NULL);

COMMIT;

/

  UPDATE INVOICE_DETAIL
     SET fee_type_amt = fee_type_amt * -1,
         fee_type_exch_amt = fee_type_exch_amt * -1
   WHERE     invoice_no IN (SELECT invoice_no
                              FROM invoice
                             WHERE     country_code = 'UG'
                                   AND invoice_type_id_no = 2
                                   AND release_date IS NULL);

/* Ad Hoc Code
  SELECT *
    FROM INVOICE inv
    JOIN INVOICE_DETAIL ind
      on inv.invoice_no = ind.invoice_no
   WHERE     inv.country_code = 'UG'
         AND inv.invoice_type_id_no = 2
         AND inv.release_date IS NULL;

*/