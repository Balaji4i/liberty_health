select * --ccs.poep_id
--      ,ccs.comms_calc_snapshot_no CCS_no
--      ,cct.comms_calc_snapshot_no CCT_no
--      ,ccs.COMMS_CALC_TYPE_CODE
--      ,cct.TRACE_BASE_SNAPSHOT_NO
--      ,cct.TRACE_ORIGINAL_SNAPSHOT_NO
  from comms_calc_snapshot ccs
  left outer join comms_calc_trace cct
    on ccs.comms_calc_snapshot_no = cct.comms_calc_snapshot_no
 where ccs.person_code = '16432';
 
 delete from COMMS_CALC_TRACE cct
  where cct.comms_calc_snapshot_no in (select comms_calc_snapshot_no
                                        from COMMS_CALC_SNAPSHOT
                                       where COMMS_CALC_TYPE_CODE = 'X'
                                         AND person_code = '16432');
 delete from COMMS_CALC_SNAPSHOT ccs
  where ccs.comms_calc_snapshot_no in (select comms_calc_snapshot_no
                                        from COMMS_CALC_SNAPSHOT
                                       where COMMS_CALC_TYPE_CODE = 'X'
                                         AND person_code = '16432');

Select * from comms_calc_trace where trace_base_snapshot_no in (select comms_calc_snapshot_no
                                        from COMMS_CALC_SNAPSHOT
                                       where COMMS_CALC_TYPE_CODE = 'X'
                                         AND PERSON_CODE = '10445' and contribution_date = '01/FEB/18');

-- Delete Orphaned Trace records
 delete from COMMS_CALC_TRACE cct
  where cct.comms_calc_snapshot_no in (
Select cct.comms_calc_snapshot_no     CCT_no
--      ,ccs1.comms_calc_snapshot_no    CCT_MATCH
--      ,cct.TRACE_BASE_SNAPSHOT_NO     TB_NO
--      ,ccs2.comms_calc_snapshot_no    TB_MATCH
--      ,cct.TRACE_ORIGINAL_SNAPSHOT_NO TO_NO
--      ,ccs3.comms_calc_snapshot_no    TO_MATCH
  from comms_calc_trace cct
  left outer
  join comms_calc_snapshot ccs1
    on cct.comms_calc_snapshot_no = ccs1.comms_calc_snapshot_no
  left outer
  join comms_calc_snapshot ccs2
    on cct.trace_base_snapshot_no = ccs2.comms_calc_snapshot_no
  left outer
  join comms_calc_snapshot ccs3
    on cct.trace_original_snapshot_no = ccs3.comms_calc_snapshot_no
 where (cct.comms_calc_snapshot_no IS NOT NULL     and ccs1.comms_calc_snapshot_no IS NULL)
    or (cct.trace_base_snapshot_no IS NOT NULL     and ccs2.comms_calc_snapshot_no IS NULL)
    or (cct.trace_original_snapshot_no IS NOT NULL and ccs3.comms_calc_snapshot_no IS NULL)
    );
    
-- Find Orpahned trace Records
Select cct.comms_calc_snapshot_no     CCT_no
      ,ccs1.comms_calc_snapshot_no    CCT_MATCH
      ,cct.TRACE_BASE_SNAPSHOT_NO     TB_NO
      ,ccs2.comms_calc_snapshot_no    TB_MATCH
      ,cct.TRACE_ORIGINAL_SNAPSHOT_NO TO_NO
      ,ccs3.comms_calc_snapshot_no    TO_MATCH
  from comms_calc_trace cct
  left outer
  join comms_calc_snapshot ccs1
    on cct.comms_calc_snapshot_no = ccs1.comms_calc_snapshot_no
  left outer
  join comms_calc_snapshot ccs2
    on cct.trace_base_snapshot_no = ccs2.comms_calc_snapshot_no
  left outer
  join comms_calc_snapshot ccs3
    on cct.trace_original_snapshot_no = ccs3.comms_calc_snapshot_no
 where (cct.comms_calc_snapshot_no IS NOT NULL     and ccs1.comms_calc_snapshot_no IS NULL)
    or (cct.trace_base_snapshot_no IS NOT NULL     and ccs2.comms_calc_snapshot_no IS NULL)
    or (cct.trace_original_snapshot_no IS NOT NULL and ccs3.comms_calc_snapshot_no IS NULL);
    
select 
 INV.INVOICE_NO
,INV.INVOICE_DATE
,INV.PAYMENT_RECEIVE_DATE
,INV.COUNTRY_CODE
,INV.COMPANY_ID_NO
,INV.INVOICE_TYPE_ID_NO
,INV.RELEASE_DATE
,INV.RELEASE_HOLD_REASON
,INV.PAYMENT_DATE
,INV.PAYMENT_REJECT_DATE
,INV.PAYMENT_REJECT_DESC
,INV.PAYMENT_AMT
,INV.PAYMENT_EXCH_RATE
,INV.CURRENCY_CODE
,INV.LAST_UPDATE_DATETIME
,INV.USERNAME
,INV.INVOICE_TAX_CODES
,IND.INVOICE_NO
,IND.FEE_TYPE_ID_NO
,IND.FEE_TYPE_AMT
,IND.FEE_TYPE_EXCH_AMT
,IND.FEE_TYPE_DESC
,IND.LAST_UPDATE_DATETIME
,IND.USERNAME
  from INVOICE inv left outer join invoice_detail ind on inv.invoice_no = ind.invoice_no
where inv.invoice_no = 322;

delete from COMMS_CALC_SNAPSHOT where COMMS_CALC_TYPE_CODE = 'T';

select POEP_ID
,PERSON_CODE
,GROUP_CODE
,BROKER_ID_NO
,COMPANY_ID_NO
,COMMS_PERC
,CONTRIBUTION_DATE
,CALCULATION_DATETIME
,COMMS_CALC_TYPE_CODE
,PAYMENT_RECEIVE_AMT
,PAYMENT_CURRENCY
,COMMS_CALCULATED_AMT
,EXCHANGE_RATE
,EXCHANGE_RATE_CURRENCY_CODE
,COMMS_CALCULATED_EXCH_AMT
,INVOICE_NO
,LAST_UPDATE_DATETIME
,USERNAME
from COMMS_CALC_SNAPSHOT WHERE PERSON_CODE = '10445' and contribution_date = '01/FEB/18';
/
select * from COMMS_RECALC where POEP_ID = 14104;
/
DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Group
  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'JHPIEGOLESO', 'LSES', 'SARELTST1', l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
-- To Approve for a Group
--  comms_calc_pkg.approve_comms_run(NULL, NULL, 'SAREL2TST', 'JHPIEGOLESO', 'LSES', 'SARELTST2', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for re-calculation (all records)
--  comms_calc_pkg.recalc_changes_run(l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
END;
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
      LEFT OUTER JOIN ohi_enrollment_products  poep
        ON poep.poep_id = get_poep_id(p_date    => to_date(oldccs.contribution_date), p_person  => oldccs.person_code, p_product => oldccs.product_code)
                LEFT OUTER JOIN ohi_policy_enrollments   poen
                      ON (poep.poen_id = poen.poen_id)
                LEFT OUTER JOIN ohi_policies             poli
                      ON (poen.poli_id = poli.poli_id )
      LEFT OUTER JOIN ohi_policy_brokers       pobr
        ON (poli.poli_id = pobr.poli_id) 
       AND (oldccs.contribution_date BETWEEN pobr.effective_start_date and pobr.effective_end_date)
                LEFT OUTER JOIN ohi_policy_groups        grac
                      ON (poli.poli_id = grac.poli_id)
                    LEFT OUTER JOIN ohi_groups               grps
                      ON (grac.grac_id = grps.grac_id)
                LEFT OUTER JOIN ohi_insured_entities     inse
                      ON (poen.inse_id = inse.inse_id)
                LEFT OUTER JOIN ohi_products             prod
                      ON (poep.enpr_id = prod.enpr_id)  
                LEFT OUTER JOIN comms_calc_trace         oldcct                           --LS-1061
                      ON (oldccs.comms_calc_snapshot_no = oldcct.comms_calc_snapshot_no)  --LS-1061                    
     WHERE oldccs.comms_calc_type_code in ( 'P', 'A') 
       AND oldccs.poep_id = 14104
  	   AND oldccs.invoice_no IS NOT NULL
     ORDER BY oldccs_contribution_date;
/
    SELECT DISTINCT(trecalc.poep_id) AS poep_id
      FROM COMMS_RECALC              trecalc
     WHERE trunc(processed_date) = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'));
/
delete from COMMS_CALC_TRACE
 WHERE trunc(calculation_datetime) = trunc(sysdate) and PERSON_CODE = '10463' and contribution_date = '01/MAR/18';

update COMMS_RECALC 
   set processed_date = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'))
 WHERE poep_id = 14104 and trunc(processed_date) = trunc(sysdate);

update COMMS_CALC_SNAPSHOT
   set COMMS_CALC_TYPE_CODE = 'P'
 WHERE COMMS_CALC_TYPE_CODE = 'X' and PERSON_CODE = '10463' and contribution_date = '01/MAR/18';

delete from COMMS_CALC_SNAPSHOT
 WHERE trunc(calculation_datetime) = trunc(sysdate) and PERSON_CODE = '10463' and contribution_date = '01/MAR/18';
/
select * from invoice where invoice_no = '1234343';
select * from invoice_detail where invoice_no = '1234343';

