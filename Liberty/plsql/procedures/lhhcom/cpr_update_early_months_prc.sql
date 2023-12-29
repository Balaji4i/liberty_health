CREATE OR REPLACE PROCEDURE cpr_update_early_months_prc(
  p_input_month_from IN VARCHAR2, 
  p_input_month_to IN VARCHAR2,   
  p_input_row_choice INTEGER)                            
is

-- This code works for November 2016, December 2016, January 2017, February 2017, March 2017 at the same time
-- It takes an instance count parameter (row number 1 or 2) and calculation month from and to parameters.
-- The date input parameters must thus be '2016-11-01' and '2017-03-01'

  l_params logger.tab_param := logger.gc_empty_tab_param;
  
  v_contribution_from_date DATE := to_date(p_input_month_from,'YYYY-MM-DD');
  v_contribution_to_date DATE := to_date(p_input_month_to,'YYYY-MM-DD');
  
  CURSOR CPR_FK IS           
         (SELECT           
              ccs_single.comms_calc_snapshot_no
            , cpr_all_single.application_id  
            , cpr_all_single.contribution_date
            , cpr_all_single.country_code
            , cpr_all_single.finance_receipt_no
            , cpr_all_single.group_code
            , cpr_all_single.finance_receipt_amt
            , cpr_all_single.finance_receipt_date
            , cpr_all_single.person_code
            , cpr_all_single.policy_code
            , cpr_all_single.product_code 
            , cpr_all_single.finance_invoice_no
            , cpr_all_single.finance_invoice_date
            , cpr_all_single.processed_ind
            , cpr_all_single.processed_desc
            , cpr_all_single.last_update_datetime
            , cpr_all_single.username              
            FROM
             (SELECT 
               cpr_aggr_val.application_id             
             , cpr_aggr_val.contribution_date
             , cpr_aggr_val.country_code
             , cpr_aggr_val.finance_receipt_no
             , cpr_aggr_val.group_code
             , cpr_aggr_val.finance_receipt_amt             
             , cpr_aggr_val.finance_receipt_date
             , cpr_aggr_val.person_code
             , cpr_aggr_val.policy_code
             , cpr_aggr_val.product_code
             , cpr_aggr_val.finance_invoice_no
             , cpr_aggr_val.finance_invoice_date
             , cpr_aggr_val.processed_ind
             , cpr_aggr_val.processed_desc
             , cpr_aggr_val.last_update_datetime
             , cpr_aggr_val.username                 
             , cpr_aggr_val.rn             
             , cpr_aggr_val.pos_neg
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
                 , finance_invoice_no
                 , finance_invoice_date
                 , processed_ind
                 , processed_desc
                 , last_update_datetime
                 , username                                
                 , row_number() over(partition by 
                     country_code, 
                     group_code, 
                     product_code,
                     policy_code,
                     person_code,
                     finance_receipt_no,
                     finance_receipt_amt,
                     finance_receipt_date,
                     contribution_date
                       order by finance_invoice_no desc) as rn                 
                 , CASE
                    WHEN finance_receipt_amt < 0 THEN 'NEG'
                    WHEN finance_receipt_amt > 0 THEN 'POS'
                    ELSE 'ZERO'
                    END pos_neg  
                 FROM lhhcom.temp_backup_ls1061b
                   WHERE processed_ind = 'Y' 
                     AND contribution_date >= v_contribution_from_date 
                     AND contribution_date <= v_contribution_to_date                      
                     ) cpr_aggr_val            
            WHERE rn = p_input_row_choice
             ) cpr_all_single                                           
              INNER JOIN  
             (SELECT 
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
                         AND contribution_date >= v_contribution_from_date
                         AND contribution_date <= v_contribution_to_date
                    ) comms_calc_snapshot_ord
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
                      (select
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
                         AND contribution_date >= v_contribution_from_date 
                         AND contribution_date <= v_contribution_to_date                          
                      ) comms_calc_snapshot_ord2
                       WHERE rn > 1)                       
                ) comms_calc_snapshot_first   
              where comms_calc_snapshot_first.rn = p_input_row_choice) ccs_single                                   
               ON cpr_all_single.contribution_date = ccs_single.contribution_date
              AND cpr_all_single.country_code = ccs_single.country_code
              AND cpr_all_single.finance_receipt_no = ccs_single.finance_receipt_no
              AND cpr_all_single.group_code = ccs_single.group_code
              AND cpr_all_single.finance_receipt_amt = ccs_single.payment_receive_amt
              AND cpr_all_single.finance_receipt_date = ccs_single.payment_receive_date
              AND cpr_all_single.person_code = ccs_single.person_code
              AND cpr_all_single.policy_code = ccs_single.policy_code
              AND cpr_all_single.product_code = ccs_single.product_code);

begin
   
   FOR rec IN cpr_fk loop
     begin
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
         (application_id 
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
         VALUES(rec.application_id
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
          logger.log('Row already on comms_payments_received', NULL, NULL, l_params);
     end;   
    end loop;        
                                                                 
    COMMIT;
end cpr_update_early_months_prc;                  