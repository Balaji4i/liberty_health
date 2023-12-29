/**
* ----------------------------------------------------------------------
* Change Request: LS-2152 - Populate Invoice No on CCS
*
* Description  : LS-2152 - Populate Invoice No on CCS
* Author       : Sarel Eybers
* Date         : 2018-10-18
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Backup Data
*   2) Link missing Invoice Numbers
*                                                                         */

-- DROP TABLE "LHHCOM"."DATAFIX_BACKUP_LS2152";
CREATE TABLE "LHHCOM"."DATAFIX_BACKUP_LS2152" AS
  SELECT * FROM comms_calc_snapshot WHERE invoice_no = 0;
COMMIT;

/

SET SERVEROUTPUT ON;
DECLARE

  ln_company_id_no         company.company_id_no%type;
  ld_previous_date         date;
  ld_invoice_date          date;
  lv_currency_pay          comms_calc_snapshot.payment_currency%type;
  lv_currency_exch         comms_calc_snapshot.exchange_rate_currency_code%type;

  CURSOR c_invoices_to_match IS
    SELECT inv.country_code
          ,inv.currency_code
          ,inv.company_id_no
          ,inv.payment_receive_date
          ,inv.invoice_no
          ,inv.payment_exch_rate
          ,inv.invoice_date
          ,ind.fee_type_amt
          ,ind.fee_type_exch_amt
      FROM invoice                                                 inv
      LEFT OUTER
      JOIN invoice_detail                                          ind
        ON ind.invoice_no = inv.invoice_no
      LEFT OUTER
      JOIN comms_calc_snapshot                                     ccs
        ON ccs.invoice_no = inv.invoice_no
     WHERE     inv.invoice_type_id_no = 1
           AND ccs.invoice_no IS NULL
     ORDER BY 1, 2, 3, 4, 5;

  CURSOR c_snapshot_not_matched IS
    SELECT matched, comms_calc_type_code, calculation_datetime, payment_currency, exchange_rate_currency_code, sum(comms_calculated_amt) comms_calculated_amt, sum(comms_calculated_exch_amt) comms_calculated_exch_amt
      FROM (
    SELECT 
           CASE WHEN     trunc(calculation_datetime) BETWEEN ld_previous_date AND ld_invoice_date
                     AND TRIM(payment_currency) = NVL(lv_currency_pay, TRIM(payment_currency))
                     AND TRIM(exchange_rate_currency_code) = lv_currency_exch
                     AND comms_calc_type_code IN ('P', 'X')
                     AND (invoice_no IS NULL or invoice_no = 0) THEN 'M'
                ELSE 'U' END matched
          ,comms_calc_type_code
          ,calculation_datetime
          ,comms_calc_snapshot_no
          ,invoice_no
          ,comms_calculated_amt
          ,payment_currency
          ,comms_calculated_exch_amt
          ,exchange_rate_currency_code
      FROM comms_calc_snapshot
     WHERE     company_id_no = ln_company_id_no
           AND trunc(calculation_datetime) BETWEEN ld_previous_date AND ld_invoice_date
     ORDER BY 1, 2, 3, 4
           ) GROUP BY matched, comms_calc_type_code, calculation_datetime, payment_currency, exchange_rate_currency_code
             ORDER BY 1, 3, 4, 5;

  lv_fee_amt               invoice_detail.fee_type_amt%type;
  lv_fee_exch_amt          invoice_detail.fee_type_exch_amt%type;
  lv_update                BOOLEAN := TRUE;

BEGIN
  ln_company_id_no         := 0;
  FOR x IN c_invoices_to_match LOOP
    BEGIN -- Initialize . . .
      ld_invoice_date            := trunc(x.invoice_date);
      lv_currency_pay            := NULL;
      lv_currency_exch           := TRIM(x.currency_code);
      IF ln_company_id_no <> x.company_id_no THEN
        ln_company_id_no         := x.company_id_no;
        ld_previous_date         := to_date('01/JAN/2014' , 'DD/MON/YYYY');
        dbms_output.put_line('Processing . . Brokerage (' || ln_company_id_no || 
                                      ') for Currency (' || lv_currency_exch || ')');
      END IF;
    END;
    CASE
      WHEN x.invoice_no =   1 THEN ld_invoice_date  := to_date('23/NOV/2016' , 'DD/MON/YYYY');
      WHEN x.invoice_no =  13 THEN ld_previous_date := to_date('18/SEP/2017' , 'DD/MON/YYYY');
      WHEN x.invoice_no = 479 THEN lv_currency_pay  := 'USD';
      WHEN x.invoice_no = 480 THEN lv_currency_pay  := 'UGX';
                                   ld_previous_date := to_date('16/SEP/2015' , 'DD/MON/YYYY');
      WHEN x.invoice_no = 485 THEN lv_currency_pay  := 'USD';
      WHEN x.invoice_no = 486 THEN lv_currency_pay  := 'UGX';
                                   ld_previous_date := to_date('26/FEB/2016' , 'DD/MON/YYYY');
      WHEN x.invoice_no = 487 THEN lv_currency_pay  := 'USD';
      WHEN x.invoice_no = 488 THEN lv_currency_pay  := 'UGX';
                                   ld_previous_date := to_date('18/MAY/2016' , 'DD/MON/YYYY');
      ELSE NULL;
    END CASE;
    BEGIN -- Balance . . .
      SELECT sum(comms_calculated_amt), sum(comms_calculated_exch_amt)
        INTO lv_fee_amt, lv_fee_exch_amt
        FROM comms_calc_snapshot
       WHERE     company_id_no = ln_company_id_no
             AND trunc(calculation_datetime) BETWEEN ld_previous_date AND ld_invoice_date
             AND TRIM(payment_currency) = NVL(lv_currency_pay, TRIM(payment_currency))
             AND TRIM(exchange_rate_currency_code) = lv_currency_exch
             AND comms_calc_type_code IN ('P', 'X')
             AND (invoice_no IS NULL or invoice_no = 0);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Exception: ' || sqlerrm);
    END;
    IF     x.fee_type_amt = lv_fee_amt
       AND x.fee_type_exch_amt = lv_fee_exch_amt THEN
      dbms_output.put_line(' Balanced:     Invoice Date (' || ld_previous_date || ' - ' || ld_invoice_date || 
                                    ') and Invoice No (' || x.invoice_no ||
                                    ') for Amounts (' || x.fee_type_amt || ' --> ' || x.fee_type_exch_amt || ' ' || x.currency_code || ')');
      IF lv_update = TRUE THEN
        UPDATE comms_calc_snapshot
           SET invoice_no = x.invoice_no
         WHERE     company_id_no = ln_company_id_no
               AND trunc(calculation_datetime) BETWEEN ld_previous_date AND ld_invoice_date
               AND TRIM(payment_currency) = NVL(lv_currency_pay, TRIM(payment_currency))
               AND TRIM(exchange_rate_currency_code) = lv_currency_exch
               AND comms_calc_type_code IN ('P', 'X')
               AND (invoice_no IS NULL or invoice_no = 0);
      END IF;
    ELSIF x.invoice_no IN (37, 400, 406) THEN
      dbms_output.put_line(' Part Balance: Invoice Date (' || ld_previous_date || ' - ' || x.invoice_date || 
                                    ') and Invoice No (' || x.invoice_no ||
                                    ') for Amounts (Fee: ' || x.fee_type_amt || ' - ' || lv_fee_amt || ' and Exch Fee ' || x.fee_type_exch_amt || ' - ' || lv_fee_exch_amt || ')');
      IF lv_update = TRUE THEN
        UPDATE comms_calc_snapshot
           SET invoice_no = x.invoice_no
         WHERE     company_id_no = ln_company_id_no
               AND trunc(calculation_datetime) BETWEEN ld_previous_date AND ld_invoice_date
               AND TRIM(payment_currency) = NVL(lv_currency_pay, TRIM(payment_currency))
               AND TRIM(exchange_rate_currency_code) = lv_currency_exch
               AND comms_calc_type_code IN ('P', 'X')
               AND (invoice_no IS NULL or invoice_no = 0);
      END IF;
    ELSE
      dbms_output.put_line(' Not Balanced: Invoice Date (' || ld_previous_date || ' - ' || x.invoice_date || 
                                    ') and Invoice No (' || x.invoice_no ||
                                    ') for Amounts (Fee: ' || x.fee_type_amt || ' - ' || lv_fee_amt || ' and Exch Fee ' || x.fee_type_exch_amt || ' - ' || lv_fee_exch_amt || ')');
      FOR y IN c_snapshot_not_matched LOOP
        dbms_output.put_line('            ' || y.matched || ': ' || y.comms_calc_type_code || ', ' || y.calculation_datetime || ', ' || 
                             y.comms_calculated_amt || ' ' || y.payment_currency || ', ' || y.comms_calculated_exch_amt || ' ' || y.exchange_rate_currency_code);
      END LOOP;
    END IF;
    ld_previous_date             := ld_invoice_date + 1;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Exception: ' || sqlerrm);
END;

/

/* Ad Hoc Code
select * from Invoice inv join invoice_detail ind on inv.invoice_no = ind.invoice_no where inv.invoice_type_id_no = 1 and company_id_no = 741000000 and country_code = 'UG' order by 2;
select * from comms_calc_snapshot where company_id_no = 741000000 and country_code = 'UG' and trunc(calculation_datetime) between to_date('01/JUL/2014', 'DD/MON/YYYY') and to_date('31/JUL/2014', 'DD/MON/YYYY');
*/