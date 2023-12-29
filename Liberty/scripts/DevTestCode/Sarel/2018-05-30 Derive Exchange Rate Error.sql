define p_date = '01/JAN/2018';
define p_comparam = '(10000061)';
define p_polparam = '(''6096379'')';
define p_grpparam = '(''MATEKANE'')';
define p_curparam = '(''LSL'', ''LSL'')';
define p_tocurparam = '(''ZAR'')';
define p_frmcurparam = '(''LSL'')';
-- Company Currency Required
select c.company_id_no, company_table_type_desc, preferred_currency_code        
  from lhhcom.company c,            
       (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,       
               rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no        
          from lhhcom.company_function bf, lhhcom.company_table bt, lhhcom.company_table_type btt              
         where     bf.company_table_id_no = bt.company_table_id_no              
               and bf.company_table_id_no = 6            
               and bf.company_table_type_id_no = btt.company_table_type_id_no              
               and sysdate between bf.effective_start_date and bf.effective_end_date ) b_multi_net   
 where     c.company_id_no = b_multi_net.company_id_no(+)       
       and nvl(b_multi_net.rank_no,1) = 1
		   and c.company_id_no IN &&p_comparam;
-- Policy Currency
SELECT a.code Policy, a.prefcur_id Pol_Cur_ID, c.code
  FROM POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA a,
       FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
 WHERE     tec_ind_last_version = 'Y'
       AND a.code IN &&p_polparam
       AND a.prefcur_id = c.id(+);
-- Group Currency
SELECT a.code Group_Code, a.prefcur_id Grp_Cur_ID, c.code
  FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA a,
       FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA c
 WHERE     object_version_number = (SELECT MAX(object_version_number)
                                      FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                     WHERE a.code = code)
       AND a.code IN &&p_grpparam
       AND a.prefcur_id = c.id(+);
-- Determin Exchange Rate
SELECT c_from.code from_code, c_to.code to_code, e.start_date, e.end_date, e.rate
  FROM OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_from,    
       OHI_CLAIMS_VIEWS_OWNER.OHI_EXCHANGE_RATES_V@CLAIMS.LIBERTY.CO.ZA e,    
       OHI_CLAIMS_VIEWS_OWNER.OHI_CURRENCIES_V@CLAIMS.LIBERTY.CO.ZA c_to
 WHERE     e.curr_id_from = c_from.id    
       AND e.curr_id_to = c_to.id
       AND e.rate_context is null
       AND c_from.code IN &&p_curparam
       AND c_to.code IN &&p_curparam
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN e.start_date AND NVL(e.end_Date,TRUNC(SYSDATE))
 ORDER BY 1, 2, 3;
