-- Count unprocessed payments
    SELECT 
           country_code
          ,CASE
             WHEN payment_type LIKE '%-SUPL%' THEN 'Derived SUPL Tax'
             WHEN payment_type LIKE '%-TRN%'  THEN 'Derived TRN Tax'
             WHEN payment_type LIKE '%-TAX%'  THEN 'Derived TAX Tax'
             WHEN payment_type LIKE '%-TRAL%' THEN 'Derived TRAL Tax'
             WHEN payment_type LIKE 'SUPL%'   THEN 'SUPL Tax'
             WHEN payment_type LIKE 'TRN%'    THEN 'TRN Tax'
             WHEN payment_type LIKE 'TAX%'    THEN 'TAX Tax'
             WHEN payment_type LIKE 'TRAL%'   THEN 'TRAL Tax'
             ELSE  'Commisionable Amount' END AS main_type
          ,payment_type                       AS payment_type
          ,count(*)
      FROM comms_payments_received
     GROUP BY
           country_code
          ,payment_type
     ORDER BY 1, 2, 3;
     
/
-- Check Fusion data
  SELECT vendor_type_lookup_code, fusion_report_reference, line_type_lookup_code, count(*)
    FROM fusion_report@fusion
   GROUP BY vendor_type_lookup_code, fusion_report_reference, line_type_lookup_code
   ORDER BY 1, 2, 3;

  SELECT *
    FROM fusion_report@fusion
   WHERE fusion_report_reference = 'Commission_run'
--     AND supplier_number = 832000040
     AND INVOICE_ID IN (456, 457, 458, 905, 978, 979, 980)
   ORDER BY invoice_id desc, line_type_lookup_code desc, fusion_report_uid;

SELECT * FROM invoice_payments;

  SELECT --* /*
         fusion_report_uid
        ,fusion_report_reference
        ,p_business_unit
        ,supplier_number
        ,invoice_id
        ,vendor_site_code
        ,invoice_num
        ,invoice_line_amount
        ,line_number
        ,line_type_lookup_code
        ,invoice_line_description
        ,reversal_flag
        ,exchange_rate_type
        ,exchange_rate
        ,invoice_currency_code
        ,payment_currency_code
        ,date_actioned
        ,date_stamp
--        ,to_char(date_actioned, 'YYYY/MM/DD HH24:MI:SS') DA
--        ,to_char(date_stamp, 'YYYY/MM/DD HH24:MI:SS') DS
-- */
    FROM fusion_report@fusion
   WHERE fusion_report_reference = 'Commission_run'
--     AND p_from_date >= ld_last_process_date
     AND vendor_type_lookup_code like '%Broker%'
   ORDER BY invoice_num, line_type_lookup_code DESC, date_stamp;

/
-- Comms run for UGIND
-- Error on Policy 2377017193
-- Failed: Unhandled exception: ORA-06502: PL/SQL: numeric or value error: number precision too large
SET SERVEROUTPUT ON;
DECLARE
  l_return_msg VARCHAR2(500);
BEGIN
-- To Run for a Group
--  comms_calc_pkg.proof_of_payment_update_run('SARELONE', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'MICROFINANCE', 'CLUG', 'SARELONE', l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
END;

/

SELECT --*
       invoice_no
      ,company_id_no
      ,payment_amt
      ,currency_code
      ,invoice_tax_codes
      ,to_char(invoice_date, 'YYYY/MM/DD HH24:MI:SS') invoice_date
      ,to_char(release_date, 'YYYY/MM/DD HH24:MI:SS') release_date
      ,to_char(last_update_datetime, 'YYYY/MM/DD HH24:MI:SS') last_update_datetime
-- */
  FROM invoice
 ORDER BY 1 desc;
 
SELECT
       COMPANY_ID_NO
      ,COUNTRY_CODE
      ,EFFECTIVE_START_DATE
      ,EFFECTIVE_END_DATE
      ,ACCREDITATION_TYPE_ID_NO
      ,COMPANY_ACCRED_NO
      ,COMPANY_ACCRED_START_DATE
      ,COMPANY_ACCRED_END_DATE
      ,to_char(last_update_datetime, 'YYYY/MM/DD HH24:MI:SS') last_update_datetime
      ,USERNAME
  FROM COMPANY_ACCREDITATION;
  
/

SELECT *
  FROM all_tab_columns
 WHERE owner = 'LHHCOM'
   AND data_scale > 2
   AND data_precision < 20;
   
/

SELECT DISTINCT *
  FROM comms_recalc
 WHERE description <> 'SUCCESS';
 GROUP BY POEP_ID
 ORDER BY 1, 2;
 
UPDATE COMMS_RECALC
   SET PROCESSED_DATE = SYSDATE, USERNAME = 'SARELBulk'
 WHERE description <> 'SUCCESS';
 
 /
 
    SELECT 
           oldccs.rowid                       AS old_record_id,
           poli.poli_id, 
           oldccs.poep_id                     AS oldccs_poep_id,
           oldccs.group_code                  AS oldccs_group_code,
           oldccs.country_code                AS oldccs_country_code,
           oldccs.product_code                AS oldccs_product_code,
           oldccs.policy_code                 AS oldccs_policy_code,                        
           oldccs.person_code                 AS oldccs_person_code,                               
           oldccs.broker_id_no                AS oldccs_broker_id_no,
           oldccs.company_id_no               AS oldccs_company_id_no,
           oldccs.payment_currency            AS oldccs_payment_currency,
           oldccs.comms_perc                  AS oldccs_comms_perc,
           oldccs.finance_receipt_no          AS oldccs_finance_receipt_no,
           oldccs.payment_receive_amt         AS oldccs_payment_receive_amt,
           oldccs.payment_receive_date        AS oldccs_payment_receive_date,
           oldccs.contribution_date           AS oldccs_contribution_date,
           oldccs.exchange_rate_currency_code AS oldccs_exch_rate_curr_code,
           oldccs.calculation_datetime        AS oldccs_calculation_datetime,
           pobr.company_id_no                 AS pobr_company_id_no,
           poli.policy_code                   AS poli_policy_code,
           grps.group_code                    AS grps_group_code,
           prod.product_code                  AS prod_product_code,
           poli.poli_id                       AS poli_poli_id,
           pobr.poli_id                       AS pobr_poli_id,
           oldccs.comms_calculated_amt        AS oldccs_comms_calculated_amt,
           oldccs.comms_calculated_exch_amt   AS oldccs_comms_calc_exch_amt,
           oldccs.exchange_rate               AS oldccs_exchange_rate,
           oldccs.comms_calc_snapshot_no      AS oldccs_comms_calc_snapshot_no,  --LS-1061
           oldcct.trace_original_snapshot_no  AS old_trace_original_snapshot_no  --LS-1061       
      FROM comms_calc_snapshot                 oldccs
      LEFT OUTER 
      JOIN ohi_enrollment_products  poep
        ON poep.poep_id = get_poep_id(p_date    => to_date(oldccs.contribution_date), p_person  => oldccs.person_code, p_product => oldccs.product_code)
      LEFT OUTER 
      JOIN ohi_policy_enrollments   poen
        ON (poep.poen_id = poen.poen_id)
      LEFT OUTER 
      JOIN ohi_policies             poli
        ON (poen.poli_id = poli.poli_id )
      LEFT OUTER 
      JOIN ohi_policy_brokers       pobr
        ON (poli.poli_id = pobr.poli_id) 
       AND (oldccs.contribution_date BETWEEN pobr.effective_start_date and pobr.effective_end_date)
      LEFT OUTER 
      JOIN ohi_policy_groups        grac
        ON (poli.poli_id = grac.poli_id)
      LEFT OUTER 
      JOIN ohi_groups               grps
        ON (grac.grac_id = grps.grac_id)
      LEFT OUTER 
      JOIN ohi_insured_entities     inse
        ON (poen.inse_id = inse.inse_id)
      LEFT OUTER 
      JOIN ohi_products             prod
        ON (poep.enpr_id = prod.enpr_id)  
      LEFT OUTER 
      JOIN comms_calc_trace         oldcct                           --LS-1061
        ON (oldccs.comms_calc_snapshot_no = oldcct.comms_calc_snapshot_no)  --LS-1061                    
     WHERE oldccs.comms_calc_type_code in ( 'P', 'A') 
       AND oldccs.poep_id = 80366
  	   AND oldccs.invoice_no IS NOT NULL
     ORDER BY oldccs_contribution_date;
/
SELECT * FROM util.system_parameter;
select get_system_parameter('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE') d1
       ,to_date(get_system_parameter('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE'),'dd-MON-yyyy') d2
--       ,to_char(get_system_parameter('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE'), 'YYYY/MM/DD HH24:MI:SS') d3
       ,to_char(to_date(get_system_parameter('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE'),'dd-MON-yy'), 'YYYY/MM/DD HH24:MI:SS') d4
  from Dual;

	  UPDATE system_parameter  --this is to catch any date format errors as the users can manually update the date via the application.
       SET parameter_value = trunc(sysdate)-100,
           last_update_datetime = sysdate,
           username = 'SAREL'
     WHERE parameter_key = 'LAST_REMITTANCE_CHECK_DATE'
       AND parameter_section = 'FUSION'
       AND system_name = 'LB_HEALTH_COMMS';
    COMMIT;

  SELECT invoice_no
        ,min(date_actioned)       payment_date
        ,sum(invoice_line_amount) payment_amount
    FROM invoice_payments
   WHERE     invoice_no IN (SELECT DISTINCT invoice_no
                              FROM invoice_payments)
         AND line_type_lookup_code = 'ITEM'
   GROUP BY invoice_no;
