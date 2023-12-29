declare
  l_count NUMBER DEFAULT 0;

BEGIN

 FOR c_rec IN (

select DISTINCT company_id_no, company_name,country_code, 
      country_template,
preferred_currency_code, company_table_type_desc,
(CASE WHEN country_code = 'UG' THEN
     'UGX'
  WHEN country_code = 'ZW' THEN    
     'USD'
  WHEN country_code = 'ZM' THEN
    'ZMW'
  WHEN country_code = 'ZA' THEN
    'ZAR'
  WHEN country_code = 'NG' THEN
     'NGN'
  WHEN country_code = 'MW' THEN
      'MWK'
  WHEN country_code = 'MZ' THEN
     'MZN'
  WHEN country_code = 'MU' THEN
     'MUR'
  WHEN country_code = 'LS' THEN
     'LSL'
  WHEN country_code = 'KE' THEN
     'KES'
 end) NEW_preferred_curr
from (SELECT DISTINCT cp.company_id_no, cp.company_name,cc.country_code, 
                   (CASE WHEN multi.company_table_type_desc = 'Y' THEN
                       'ZA'
                    WHEN  multi.company_table_type_desc = 'N' AND
                       COUNT(1) OVER (PARTITION BY cp.company_id_no) > 1 THEN
                         'Local but more than one country'
                    ELSE
                      cc.country_code
                    END) country_template,
preferred_currency_code, multi.company_table_type_desc
from company cp,company_country cc,
(SELECT DISTINCT cf.company_id_no, cf.effective_start_date, cf.effective_end_date,
                        ct.company_table_desc,
                        ctt.company_table_type_desc
                   FROM company_function cf,
                        company_table_type ctt,
                        company_table ct
                WHERE 1=1
                  AND ct.company_table_desc = 'Multinational'
                  AND cf.company_table_type_id_no = ctt.company_Table_type_id_no
                  AND ctt.company_table_id_no = ct.company_table_id_no
                  AND ctt.company_table_id_no = cf.company_table_id_no
                --  and cc.company_id_no  = cf.company_id_no
                  AND TRUNC(sysdate) BETWEEN TRUNC(cf.effective_start_date) AND TRUNC(cf.effective_end_date)
                 -- and trunc(sysdate) between trunc(cc.effective_start_date) and trunc(cc.effective_end_date)
                  AND TRUNC(sysdate) BETWEEN TRUNC(ct.effective_start_date) AND TRUNC(ct.effective_end_date)
                  AND TRUNC(sysdate) BETWEEN TRUNC(ctt.effective_start_date) AND TRUNC(ctt.effective_end_date)
                  ) multi
where multi.company_table_type_desc = 'N'
  and  preferred_currency_code is null
  AND multi.company_id_no = cp.company_id_no
   and cc.company_id_no = cp.company_id_no
    AND TRUNC(sysdate) BETWEEN TRUNC(cc.effective_start_date) and trunc(cc.effective_end_date)
  and cp.company_id_no > 9
  order by 1 asc)
where  country_template <> 'Local but more than one country'
order by 3 desc) LOOP

  BEGIN
  
     
        UPDATE company
          set preferred_currency_code =  c_rec.NEW_preferred_curr
          where company_id_no   = c_rec.company_id_no;
          
          dbms_output.put_line('Information Updated ');
          dbms_output.put_line('Company Name   - '||c_rec.company_name);
          dbms_output.put_line('Brokerage Code - '||c_rec.company_id_no);
          dbms_output.put_line('old currency   - '||c_Rec.preferred_currency_code);
          dbms_output.put_line('new currency   - '||c_Rec.NEW_preferred_curr);
   
        l_count := l_count +1 ;
   EXCEPTION
          WHEN OTHERS THEN
            dbms_output.put_line('UNEXPECTED ERROR -  '||SQLERRM);
   END;
   
   END LOOP;
   
   DBMS_OUTPUT.PUT_LINE('Total updates '||l_count);
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('UNEXPECTED ERROR -  '||SQLERRM);
END;