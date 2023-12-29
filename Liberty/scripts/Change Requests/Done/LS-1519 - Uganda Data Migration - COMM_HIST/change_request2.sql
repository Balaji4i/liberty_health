/**
* ----------------------------------------------------------------------
* Change Request: Uganda Data Migration - COMM_HIST (LS-1519)
*
* Description  : Migrate Commission history from Medware
* Author       : Sarel Eybers
* Date         : 2018-07-06
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Load Journal History
*   2) Load Invoice History
*   3) Load Invoices to Be Paid
*   4) Load Commissions History
*                                                                         */

/* Sample Code
select 
       i.country_code
      ,i.company_id_no
      ,i.invoice_no
      ,i.invoice_type_id_no
      ,i.release_date
      ,i.payment_date
      ,i.payment_amt
      ,id.fee_type_desc
      ,id.fee_type_amt
      ,id.fee_type_exch_amt
  from invoice i 
  left outer
  join invoice_detail id 
    on i.invoice_no = id.invoice_no
-- where     i.company_id_no = 803000000;
 where     i.payment_date is null
       and i.release_date is not null
       and i.invoice_type_id_no = 2
 order by 1, 2, 3;
*/

UPDATE invoice
   SET release_date = NULL,
       payment_amt = NULL
 WHERE     payment_date is null
       and release_date is not null
       and invoice_type_id_no = 2;

/