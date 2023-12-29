SELECT comm_inv.*, cct.* FROM 
  (SELECT * FROM 
     lhhcom.comms_calc_snapshot ccs
       INNER JOIN 
--Brokerage and wht amounts, summed per commission invoice.       
    (SELECT 
       inv1.invoice_no, 
       MAX(inv1.company_name) company_name,
       sum(inv1.brokerage_amount) brokerage_amount,
       sum(inv1.wht_amount) wht_amount
       FROM  
--calculate brokerage and wht amounts       
       (SELECT 
          inv.invoice_no,
          comp.company_name,
          CASE 
            WHEN invp.line_type_lookup_code!= 'AWT'
              THEN nvl(invp.invoice_line_amount,0)
            ELSE 0   
          END brokerage_amount,
          CASE 
            WHEN invp.line_type_lookup_code= 'AWT'
              THEN nvl(invp.invoice_line_amount,0)
            ELSE 0   
          END wht_amount
          FROM   
            lhhcom.invoice inv
              LEFT JOIN lhhcom.company comp
                ON inv.company_id_no = comp.company_id_no                  
              LEFT JOIN lhhcom.invoice_payments invp
                ON inv.invoice_no = invp.invoice_no
             ) inv1
       group by inv1.invoice_no) inv2
        ON ccs.invoice_no = inv2.invoice_no
           AND ccs.comms_calc_type_code IN ('P','A','R')) comm_inv
-- Link to comms_calc_trace to determine old version number           
   LEFT JOIN lhhcom.comms_calc_trace cct 
     ON comm_inv.comms_calc_snapshot_no = cct.comms_calc_snapshot_no
-- Tried to join to comms_payments_received. Try three times.     
   LEFT JOIN lhhcom.comms_payments_received cpr 
     ON (comm_inv.comms_calc_snapshot_no = cpr.comms_calc_snapshot_no 
      OR cct.trace_base_snapshot_no = cpr.comms_calc_snapshot_no
      or cct.trace_original_snapshot_no = cpr.comms_calc_snapshot_no      )     
     WHERE cpr.comms_calc_snapshot_no IS NULL
       AND comm_inv.finance_receipt_no != '0'
   order by comms_calc_type_code, comm_inv.finance_receipt_no    
;

Select * from lhhcom.comms_payments_received
 where group_code = 'INTERSWITCHU';

--select *
select ccs.person_code
      ,ccs.contribution_date
      ,ccs.product_code
      ,ccs.comms_calc_snapshot_no ccs_snap
      ,cpr.comms_calc_snapshot_no cpr_snap
      ,cct.comms_calc_snapshot_no cct_snap
      ,cct.trace_base_snapshot_no cct_base
      ,cct.trace_original_snapshot_no cct_orig
      ,ccs.company_id_no
      ,ccs.comms_perc
      ,to_char(ccs.last_update_datetime, 'YYYY-MM-DD HH:MI:SS') last_updated_ccs
      ,to_char(ccs.calculation_datetime, 'YYYY-MM-DD HH:MI:SS') last_updated_ccs
  from lhhcom.comms_calc_snapshot ccs
  left outer
  join lhhcom.comms_payments_received cpr
    on ccs.comms_calc_snapshot_no = cpr.comms_calc_snapshot_no
  left outer
  join lhhcom.comms_calc_trace cct
    on cct.comms_calc_snapshot_no = ccs.comms_calc_snapshot_no
 where     
           ccs.comms_calc_type_code in ('A', 'P', 'R', 'X')
       and ccs.person_code = '05067766-00'
       and ccs.contribution_date = to_date('01/OCT/18', 'DD/MON/YY')
       and ccs.product_code = 'ELUG'
/*
       and ccs.person_code = '5987407-00'
       and ccs.contribution_date = to_date('01/FEB/18', 'DD/MON/YY')
       and ccs.product_code = 'LSES'
*/
 order by 
       ccs.person_code
      ,ccs.contribution_date
      ,ccs.product_code
      ,ccs.comms_calc_snapshot_no;

select *
  from lhhcom.comms_payments_received cpr

/*
 where     
           cpr.person_code = '5987407-00'
       and cpr.contribution_date = to_date('01/FEB/18', 'DD/MON/YY')
       and cpr.product_code = 'LSES'
*/
where     cpr.group_code = 'INTERSWITCHU'
       and cpr.person_code = '05067766-00'
       and cpr.contribution_date = to_date('01/OCT/18', 'DD/MON/YY')
       and cpr.product_code = 'ELUG'
;