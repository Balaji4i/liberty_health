-- Run Broker interface to OHI
DECLARE
  lv_return_msg         VARCHAR2(500);
BEGIN
  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(NULL, lv_return_msg);
  dbms_output.put_line('  Message    : ' || lv_return_msg);
--  DNLD_OHI_POLICIES_PKG.export_company_to_ohi(740000000, lv_return_msg);
--  dbms_output.put_line('  Message    : ' || lv_return_msg);
END;

/
-- Find Payments not yet processed
    SELECT *
/*
           ROWID,
--           get_system_parameter('LB_HEALTH_COMMS','COMMS_CALC','PAYMENT_TYPES') GSP,
           application_id,
           group_code,
           country_code,
           product_code,
           policy_code,
           person_code,
--           payment_type,
           trim(payment_type) PT,
           '(' || trim(get_system_parameter('LB_HEALTH_COMMS','COMMS_CALC','PAYMENT_TYPES')) || ')' GPT,
           contribution_date,
           finance_receipt_no,
           finance_receipt_date,
           finance_receipt_amt,
           currency_code
*/
      FROM comms_payments_received
     WHERE processed_ind IN (' ', 'N', 'TY', 'TF')
--       AND get_system_parameter('LB_HEALTH_COMMS','COMMS_CALC','PAYMENT_TYPES') like '%' || nvl(trim(payment_type), 'NOTHING') || '%'
       AND country_code IN ('UG')
     ORDER BY contribution_date;

/
-- Count unprocessed payments
    SELECT 
           country_code
          ,processed_ind
          ,group_code
          ,'|' || payment_type || '|' as payment_type
          ,count(*)
      FROM comms_payments_received
     WHERE processed_ind <> 'Y'
     GROUP BY
           country_code
          ,group_code
          ,processed_ind
          ,payment_type
     ORDER BY 1, 2;
     
/
-- Check Fusion data
  SELECT vendor_type_lookup_code, fusion_report_reference, count(*)
    FROM fusion_report@fusion
   GROUP BY vendor_type_lookup_code, fusion_report_reference;
   WHERE fusion_report_reference = 'Commission_run'
--     AND p_from_date >= ld_last_process_date
--     AND invoice_id in (select to_char(invoice_no) from invoice where PAYMENT_DATE is null)
     AND vendor_type_lookup_code like '%Broker%';

  SELECT *
    FROM fusion_report@fusion
   WHERE fusion_report_reference = 'Commission_run'
     AND supplier_number = 832000040
   ORDER BY date_stamp desc;

  SELECT line_type_lookup_code, count(*)
    FROM fusion_report@fusion
   GROUP BY line_type_lookup_code;

/
select *
  from grac_broker@policies
  left outer
  join company
    on BROKER = COMPANY_ID_NO
 where COMPANY_ID_NO IS NULL;
 
select *
  from company
  left outer
  join grac_broker@policies
    on BROKER = COMPANY_ID_NO
 where BROKER IS NULL;

/
-- Documaker Template Function
         select distinct 
                country.code,
                country.name
--           into p_country_code,
--                p_country_name
           from fcod_country@policies.liberty.co.za country
--           from fcod_country@ohi_policies.liberty.co.za country
          where country.code = lhhcom.get_comp_template(832000015);
--          where country.code = lhhcom.get_comp_template(p_company_id_no);

/

-- OHI Schedule Definitions
SELECT 
--       *
       ID                         AS schedule_id
      ,code                       AS code
      ,descr                      AS schedule_description
      ,type                       AS type
      ,premium_scope              AS premium_scope
      ,dylo_id_codl               AS condition
      ,surcharge_rule_evaluation  AS surcharge_rule
      ,ind_enabled                AS enabled
  FROM pol_schedule_definitions_v@policies.liberty.co.za
 ORDER BY 2;

 /

-- Call the procedure to report the address
set serveroutput on;
DECLARE
  lv_return1         VARCHAR2(500);
  lv_return2         VARCHAR2(500);
  lv_return3         VARCHAR2(500);
  lv_return4         VARCHAR2(500);
  lv_return5         VARCHAR2(500);
  lv_return_msg      VARCHAR2(500);
BEGIN
  get_corr_address(740000000, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
  get_corr_address(10000061, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
END;
/
-- Comms run for UGIND
-- Error on Policy 2377017193
-- Failed: Unhandled exception: ORA-06502: PL/SQL: numeric or value error: number precision too large
DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Group
  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'UGIND', 'IEUG', 'SARELONE', l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for re-calculation (all records)
--  comms_calc_pkg.recalc_changes_run(l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
END;
/
set serveroutput on;
DECLARE
  lv_return1         VARCHAR2(500);
  lv_return2         VARCHAR2(500);
  lv_return3         VARCHAR2(500);
  lv_return4         VARCHAR2(500);
  lv_return5         VARCHAR2(500);
  lv_return_msg      VARCHAR2(500);
BEGIN
  get_corr_contact(10000061, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
  get_corr_contact(774000000, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
  get_corr_contact(832000015, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
END;
