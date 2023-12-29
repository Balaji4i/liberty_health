select inv.invoice_no
      ,non_commissionable_amt
      ,commissionable_amt
      ,comms_calculated_amt
      ,payment_currency
      ,comms_calculated_exch_amt
      ,exchange_rate_currency_code
      ,invoice_amount
      ,payment_amt
      ,item_amount
      ,awt_amount
      ,other_amount
  FROM (
select invoice_no
      ,payment_currency
      ,exchange_rate_currency_code
      ,sum(non_commissionable_amt) non_commissionable_amt
      ,sum(commissionable_amt) commissionable_amt
      ,sum(comms_calculated_amt) comms_calculated_amt
      ,sum(comms_calculated_exch_amt) comms_calculated_exch_amt
  from (
select snapshot, sum(non_commissionable_amt) non_commissionable_amt, sum(commissionable_amt) commissionable_amt from (
SELECT 
--       country_code
--      ,product_code
       group_code
      ,policy_code
      ,person_code
      ,contribution_date
      ,application_id
      ,finance_receipt_no                         receipt_no
--      ,finance_receipt_date
      ,finance_invoice_no                         invoice_no
--      ,finance_invoice_date
      ,comms_calc_snapshot_no                     snapshot
      ,payment_type                               type
      ,sum(non_commissionable_amt)                non_commissionable_amt
      ,sum(commissionable_amt)                    commissionable_amt
  FROM (
    SELECT 
           cpr.country_code                       country_code
          ,cpr.product_code                       product_code
          ,cpr.group_code                         group_code
          ,cpr.policy_code                        policy_code
          ,cpr.person_code                        person_code
          ,cpr.contribution_date                  contribution_date
          ,cpr.application_id                     application_id
          ,cpr.finance_receipt_no                 finance_receipt_no
          ,cpr.finance_receipt_date               finance_receipt_date
          ,cpr.finance_invoice_no                 finance_invoice_no
          ,cpr.finance_invoice_date               finance_invoice_date
          ,cpr.comms_calc_snapshot_no             comms_calc_snapshot_no
          ,cpr.payment_type                       payment_type
          ,0                                      non_commissionable_amt
          ,finance_receipt_amt                    commissionable_amt
      FROM comms_payments_received                cpr
     WHERE     processed_ind = 'Y'
           AND country_code IN ('UG')
           AND comms_calc_snapshot_no IS NOT NULL
    UNION
    SELECT 
           cpr.country_code                       country_code
          ,cpr.product_code                       product_code
          ,cpr.group_code                         group_code
          ,cpr.policy_code                        policy_code
          ,cpr.person_code                        person_code
          ,cpr.contribution_date                  contribution_date
          ,cpr.application_id                     application_id
          ,cpr.finance_receipt_no                 finance_receipt_no
          ,cpr.finance_receipt_date               finance_receipt_date
          ,cpr.finance_invoice_no                 finance_invoice_no
          ,cpr.finance_invoice_date               finance_invoice_date
          ,(SELECT max(comms_calc_snapshot_no)
              FROM comms_payments_received
             WHERE     person_code = cpr.person_code
                   AND contribution_date = cpr.contribution_date
                   AND application_id = cpr.application_id
                   AND finance_receipt_no = cpr.finance_receipt_no
                   AND finance_invoice_no = cpr.finance_invoice_no
                                    )             comms_calc_snapshot_no
          ,cpr.payment_type                       payment_type
          ,finance_receipt_amt                    non_commissionable_amt
          ,0                                      commissionable_amt
      FROM comms_payments_received                cpr
     WHERE     processed_ind = 'Y'
           AND country_code IN ('UG')
           AND comms_calc_snapshot_no IS NULL)
 GROUP BY 
--           country_code                        
--          ,product_code                        
           group_code                        
          ,policy_code                        
          ,person_code                        
          ,contribution_date                  
          ,application_id
          ,finance_receipt_no
--          ,finance_receipt_date
          ,finance_invoice_no
--          ,finance_invoice_date
          ,comms_calc_snapshot_no             
          ,payment_type
 ORDER BY 1, 2, 3, 4, 8, 9)
 GROUP BY snapshot) cpr
 join comms_calc_snapshot ccs
   ON cpr.snapshot = ccs.comms_calc_snapshot_no
group by invoice_no
      ,payment_currency
      ,exchange_rate_currency_code) ccs
  JOIN invoice inv
    ON inv.invoice_no = ccs.invoice_no
  LEFT OUTER
  JOIN (SELECT invoice_no
              ,sum(fee_type_exch_amt) as Invoice_amount 
          FROM invoice_detail
          group by invoice_no) id
    ON id.invoice_no = inv.invoice_no
  LEFT OUTER
  JOIN (SELECT invoice_no
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE IN ('ITEM') THEN invoice_line_amount ELSE 0 END) as item_amount 
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE IN ('AWT') THEN invoice_line_amount ELSE 0 END)  as awt_amount 
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE NOT IN ('ITEM', 'AWT') THEN invoice_line_amount ELSE 0 END) as other_amount
          FROM invoice_payments
          group by invoice_no) ip
    ON ip.invoice_no = inv.invoice_no;

 WHERE invoice_no = 443;  

SELECT invoice_no
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE IN ('ITEM') THEN invoice_line_amount ELSE 0 END) as item_amount 
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE IN ('AWT') THEN invoice_line_amount ELSE 0 END)  as awt_amount 
      ,sum(CASE WHEN LINE_TYPE_LOOKUP_CODE NOT IN ('ITEM', 'AWT') THEN invoice_line_amount ELSE 0 END) as other_amount
          FROM invoice_payments
          group by invoice_no;


/


SELECT *
  FROM comms_payments_received                cpr;

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
