select * from COMMS_PAYMENTS_RECEIVED where GROUP_CODE = 'DAVISBOARDS' order by 6, 8, 1;
select * from COMMS_CALC_SNAPSHOT where GROUP_CODE = 'AFGRIKIGUGAN' order by 5, 14, 13;

select company_table_type_desc, preferred_currency_code        
      from company c,            
            (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
             rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
               from company_function bf, company_table bt, company_table_type btt              
              where bf.company_table_id_no = bt.company_table_id_no              
                and bf.company_table_id_no = 6            
                and bf.company_table_id_no = btt.company_table_id_no              
                and bf.company_table_type_id_no = btt.company_table_type_id_no              
                and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
      where  c.company_id_no = b_multi_net.company_id_no(+)       
          and nvl(b_multi_net.rank_no,1) = 1
		      and c.company_id_no = 774000000;

select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
             rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
               from company_function bf, company_table bt, company_table_type btt              
              where bf.company_table_id_no = bt.company_table_id_no              
                and bf.company_table_id_no = 6            
                and bf.company_table_id_no = btt.company_table_id_no              
                and bf.company_table_type_id_no = btt.company_table_type_id_no              
                and sysdate between bf.effective_start_date and bf.effective_end_date
                and bf.company_id_no = 774000000;
                
    		  SELECT c.code 
            FROM POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA a,
                 FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
           WHERE tec_ind_last_version = 'Y'
             AND a.code = '1781208573'
             AND A.prefcur_id = c.ID;
      		  	SELECT c.code 
                FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA a,
                     FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
               WHERE object_version_number = (SELECT MAX(object_version_number)
                                                FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                               WHERE a.code = code)
                 AND a.code = 'DAVISBOARDS'
                 AND A.prefcur_id = c.ID;
              SELECT c_from.code FROM_CURR, e.rate, e.start_date, e.end_date, c_to.code to_currency_code
                FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
                     OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
                     OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to    
               WHERE e.curr_id_from = c_from.ID    
                 AND e.curr_id_to = c_to.id
                 AND e.rate_context IS NULL
                 AND c_from.code in ('UGX', 'ZAR')
                 AND c_to.code in ('UGX', 'ZAR')
                 AND trunc(SYSDATE) BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(SYSDATE));

define p_date = '01/OCT/2018';
define p_param = '(5236)';
select * from lhhcom.ohi_insured_entities inse where inse.inse_code IN ('05328139-00');
select * from lhhcom.ohi_policy_enrollments where inse_id IN (47219);
select * from lhhcom.ohi_enrollment_products where poen_id IN (78026);
