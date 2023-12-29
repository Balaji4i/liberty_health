CREATE OR REPLACE PROCEDURE cpr_update_receipt_no1_prc                            
is

  l_params logger.tab_param := logger.gc_empty_tab_param;

  CURSOR cpr_fk IS           
         (SELECT
            combined.comms_calc_snapshot_no
          , ls1061b_full.application_id
          , ls1061b_full.group_code
          , ls1061b_full.country_code
          , ls1061b_full.product_code
          , ls1061b_full.policy_code
          , ls1061b_full.person_code
          , ls1061b_full.contribution_date
          , ls1061b_full.finance_receipt_no
          , ls1061b_full.finance_receipt_date
          , ls1061b_full.finance_invoice_no
          , ls1061b_full.finance_invoice_date
          , ls1061b_full.finance_receipt_amt
          , ls1061b_full.processed_ind
          , ls1061b_full.processed_desc  
          , ls1061b_full.last_update_datetime
          , ls1061b_full.username
        FROM 
         (SELECT           
              ccs_single.comms_calc_snapshot_no
            , cpr_all_single.application_id_max
            , cpr_all_single.application_id_min            
            , cpr_all_single.contribution_date
            , cpr_all_single.country_code
            , cpr_all_single.finance_receipt_no
            , cpr_all_single.group_code
            , cpr_all_single.finance_receipt_amt
            , cpr_all_single.finance_receipt_date
            , cpr_all_single.person_code
            , cpr_all_single.policy_code
            , cpr_all_single.product_code 
            , cpr_all_single.line_count
            from
             (SELECT 
               MAX(application_id) application_id_max
             , MIN(application_id) application_id_min
             , cpr_aggr_val.contribution_date
             , cpr_aggr_val.country_code
             , cpr_aggr_val.finance_receipt_no
             , cpr_aggr_val.group_code
             , sum(cpr_aggr_val.finance_receipt_amt) finance_receipt_amt             
             , cpr_aggr_val.finance_receipt_date
             , cpr_aggr_val.person_code
             , cpr_aggr_val.policy_code
             , cpr_aggr_val.product_code
             , count(*) line_count
              FROM 
                (SELECT
                   application_id
                 , contribution_date
                 , country_code
                 , finance_receipt_no
                 , group_code
                 , finance_receipt_amt
                 , finance_receipt_date
                 , person_code
                 , policy_code
                 , product_code
                FROM lhhcom.temp_backup_ls1061b            
                   WHERE processed_ind = 'Y'  
                     and FINANCE_RECEIPT_NO in ('RIGHTOCARE_20180430', 'SASOLBASE_20180409')
                     ) cpr_aggr_val            
             GROUP BY   
               cpr_aggr_val.contribution_date
             , cpr_aggr_val.country_code
             , cpr_aggr_val.finance_receipt_no
             , cpr_aggr_val.group_code
             , cpr_aggr_val.finance_receipt_date
             , cpr_aggr_val.person_code
             , cpr_aggr_val.policy_code
             , cpr_aggr_val.product_code
             ) cpr_all_single                                              
              INNER JOIN  
             (select 
                comms_calc_snapshot_first.comms_calc_snapshot_no
              , comms_calc_snapshot_first.contribution_date
              , comms_calc_snapshot_first.country_code
              , comms_calc_snapshot_first.finance_receipt_no 
              , comms_calc_snapshot_first.group_code
              , comms_calc_snapshot_first.payment_receive_amt
              , comms_calc_snapshot_first.payment_receive_date
              , comms_calc_snapshot_first.person_code
              , comms_calc_snapshot_first.policy_code
              , comms_calc_snapshot_first.product_code
              , comms_calc_snapshot_first.rn
              , comms_calc_snapshot_first.comms_calc_type_code
              , comms_calc_snapshot_first.calculation_datetime              
              FROM
                (select * from    
                  (SELECT
                     comms_calc_snapshot_ord.comms_calc_snapshot_no
                   , comms_calc_snapshot_ord.contribution_date
                   , comms_calc_snapshot_ord.country_code
                   , comms_calc_snapshot_ord.finance_receipt_no 
                   , comms_calc_snapshot_ord.group_code
                   , comms_calc_snapshot_ord.payment_receive_amt
                   , comms_calc_snapshot_ord.payment_receive_date
                   , comms_calc_snapshot_ord.person_code
                   , comms_calc_snapshot_ord.policy_code
                   , comms_calc_snapshot_ord.product_code  
                   , comms_calc_snapshot_ord.rn
                   , comms_calc_snapshot_ord.comms_calc_type_code
                   , comms_calc_snapshot_ord.calculation_datetime
                   from
                    (SELECT
                       comms_calc_snapshot_no
                     , contribution_date
                     , country_code
                     , finance_receipt_no 
                     , group_code
                     , payment_receive_amt
                     , payment_receive_date
                     , person_code
                     , policy_code
                     , product_code                  
                     , row_number() over(partition by 
                         country_code, 
                         group_code, 
                         product_code,
                         policy_code,
                         person_code,
                         finance_receipt_no,
                         payment_receive_amt,
                         payment_receive_date,
                         contribution_date
                         order by calculation_datetime asc) as rn
                       , calculation_datetime
                       , comms_calc_type_code
                     from lhhcom.comms_calc_snapshot 
                       WHERE comms_calc_type_code IN ('P', 'X') AND trim(finance_receipt_no) != '0'
                         AND FINANCE_RECEIPT_NO IN ('RIGHTOCARE_20180430', 'SASOLBASE_20180409')
                    )  comms_calc_snapshot_ord
                        WHERE rn = 1)
                   UNION                   
                    (SELECT
                       comms_calc_snapshot_ord2.comms_calc_snapshot_no
                     , comms_calc_snapshot_ord2.contribution_date
                     , comms_calc_snapshot_ord2.country_code
                     , comms_calc_snapshot_ord2.finance_receipt_no 
                     , comms_calc_snapshot_ord2.group_code
                     , comms_calc_snapshot_ord2.payment_receive_amt
                     , comms_calc_snapshot_ord2.payment_receive_date
                     , comms_calc_snapshot_ord2.person_code
                     , comms_calc_snapshot_ord2.policy_code
                     , comms_calc_snapshot_ord2.product_code  
                     , comms_calc_snapshot_ord2.rn
                     , comms_calc_snapshot_ord2.comms_calc_type_code
                     , comms_calc_snapshot_ord2.calculation_datetime
                     from
                      (SELECT
                        comms_calc_snapshot_no
                      , contribution_date
                      , country_code
                      , finance_receipt_no 
                      , group_code
                      , payment_receive_amt
                      , payment_receive_date
                      , person_code
                      , policy_code
                      , product_code                  
                      , row_number() over(partition by 
                          country_code, 
                          group_code, 
                          product_code,
                          policy_code,
                          person_code,
                          finance_receipt_no,
                          payment_receive_amt,
                          payment_receive_date,
                          contribution_date
                          order by calculation_datetime asc) as rn
                      , calculation_datetime
                      , comms_calc_type_code
                       FROM lhhcom.comms_calc_snapshot 
                       WHERE 
                         comms_calc_type_code IN ('P', 'X') AND trim(finance_receipt_no) IN ('83647', 'LIQMINDEVEL_08022018') 
                         AND FINANCE_RECEIPT_NO IN ('RIGHTOCARE_20180430', 'SASOLBASE_20180409')
                      ) comms_calc_snapshot_ord2
                       WHERE rn > 1)                       
                ) comms_calc_snapshot_first   
              ) ccs_single 
              
               ON cpr_all_single.contribution_date = ccs_single.contribution_date
              AND cpr_all_single.country_code = ccs_single.country_code
              AND cpr_all_single.finance_receipt_no = ccs_single.finance_receipt_no
              AND cpr_all_single.group_code = ccs_single.group_code
              AND cpr_all_single.finance_receipt_amt = ccs_single.payment_receive_amt
              AND cpr_all_single.finance_receipt_date = ccs_single.payment_receive_date
              AND cpr_all_single.person_code = ccs_single.person_code
              AND cpr_all_single.policy_code = ccs_single.policy_code
              AND cpr_all_single.product_code = ccs_single.product_code) combined
        INNER JOIN lhhcom.temp_backup_ls1061b ls1061b_full 
          ON (combined.application_id_max >= ls1061b_full.application_id
           OR combined.application_id_min <= ls1061b_full.application_id) 
          AND combined.group_code = ls1061b_full.group_code 
          AND combined.product_code = ls1061b_full.product_code
          AND combined.country_code = ls1061b_full.country_code  
          AND combined.policy_code = ls1061b_full.policy_code  
          AND combined.person_code = ls1061b_full.person_code  
          AND combined.contribution_date = ls1061b_full.contribution_date  
          AND combined.finance_receipt_no = ls1061b_full.finance_receipt_no  
          AND combined.finance_receipt_date = ls1061b_full.finance_receipt_date);
                      
begin
   
   FOR rec IN cpr_fk loop 
       BEGIN
         l_params := logger.gc_empty_tab_param;
         logger.append_param(p_params => l_params, p_name => 'rec app id', p_val => rec.application_id); 
         logger.append_param(p_params => l_params, p_name => 'fin receipt no', p_val => rec.finance_receipt_no);     
         logger.append_param(p_params => l_params, p_name => 'fin receipt date ', p_val => rec.finance_receipt_date); 
         logger.append_param(p_params => l_params, p_name => 'rec contrib date', p_val => rec.contribution_date);     
         logger.append_param(p_params => l_params, p_name => 'person code', p_val => rec.person_code); 
         logger.append_param(p_params => l_params, p_name => 'policy code', p_val => rec.policy_code);   
         logger.append_param(p_params => l_params, p_name => 'rec group', p_val => rec.group_code); 
         logger.append_param(p_params => l_params, p_name => 'rec product', p_val => rec.product_code); 
         logger.append_param(p_params => l_params, p_name => 'rec country', p_val => rec.country_code); 

         logger.log('Cursor values to insert', NULL, NULL, l_params);       
   
         INSERT INTO comms_payments_received
           (  application_id 
            , group_code 
            , country_code
            , product_code
            , policy_code
            , person_code
            , contribution_date
            , finance_receipt_no
            , finance_receipt_date
            , finance_invoice_no
            , finance_invoice_date
            , finance_receipt_amt
            , currency_code
            , exchange_rate
            , comms_calc_snapshot_no
            , processed_ind
            , processed_desc
            , last_update_datetime
            , username)
            VALUES (rec.application_id
                  , rec.group_code
                  , rec.country_code
                  , rec.product_code  
                  , rec.policy_code
                  , rec.person_code
                  , rec.contribution_date
                  , rec.finance_receipt_no
                  , rec.finance_receipt_date
                  , rec.finance_invoice_no
                  , rec.finance_invoice_date
                  , rec.finance_receipt_amt            
                  , NULL
                  , NULL
                  , rec.comms_calc_snapshot_no
                  , rec.processed_ind
                  , rec.processed_desc
                  , rec.last_update_datetime
                  , rec.username); 
                    
      exception
        WHEN dup_val_on_index THEN
          logger.LOG('Row already on comms_payments_received', NULL, NULL, l_params);
          
     END;
    end loop;        
                                                                 
    COMMIT;
end cpr_update_receipt_no1_prc;                       