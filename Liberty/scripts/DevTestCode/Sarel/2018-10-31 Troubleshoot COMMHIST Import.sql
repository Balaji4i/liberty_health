SET SERVEROUTPUT ON;
define p_db_link = MEDWARE_PROD.LIBERTY.CO.ZA;

    SELECT calculation_datetime, pay_datetime, base_cur, cur_key, sum(comms_calculated_amt) comms_calculated_amt, sum(comms_calculated_exc_amt) comms_calculated_exc_amt
      FROM (

  SELECT 
         country_code
        ,product_code
        ,person_code
        ,policy_code
        ,group_code
        ,broker_id_no
        ,contribution_date
        ,calculation_datetime
        ,pay_datetime
        ,base_cur
        ,cur_key
        ,max(exch_rate)                exch_rate
        ,max(comms_perc)               comms_perc
        ,sum(payment_receive_amt)      payment_receive_amt
        ,sum(comms_calculated_exc_amt) comms_calculated_exc_amt
        ,sum(comms_calculated_amt)     comms_calculated_amt
    FROM (
          SELECT trim(com.ag_code)                               broker_id_no
                ,trim(com.g_group)                               group_code
                ,trim(co_street_country)                         country_code
                ,trim(com.o_option)                              product_code
                ,trim(com.m_member)                              policy_code
                ,trim(mem.m_member) || '-' || trim(mem.b_depend) person_code
                ,sch.s_base_cur                                  base_cur
                ,cur_key
                ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')          contribution_date
                ,to_date(trim(cm_dt_run),'yyyy-mm-dd')           calculation_datetime
                ,CASE WHEN cm_dt_pay = 0 THEN NULL
                      ELSE to_date(trim(cm_dt_pay),'yyyy-mm-dd') 
                   END                                           pay_datetime
                ,CASE WHEN to_number(trim(cm_amt_excl_vat)) = 0 THEN 0
                      ELSE round(sum(to_number(trim(cm_conv_amt_excl))) / sum(to_number(trim(cm_amt_excl_vat))),9)
                  END                                            exch_rate
                ,sum(to_number(trim(cm_1st_recu_amt)))           comms_perc
                ,CASE WHEN trim(cm_tran_type)= 'PADJ' THEN (sum(to_number(trim(cm_amt_excl_vat))) * sum(to_number(trim(cm_1st_recu_amt))))
                      ELSE sum(to_number(trim(cm_subs_paid*-1)))
                  END                                            payment_receive_amt
                ,sum(to_number(trim(cm_conv_amt_excl)))          comms_calculated_exc_amt
                ,sum(to_number(trim(cm_amt_excl_vat)))           comms_calculated_amt
            FROM commhist@&&p_db_link                            com
            LEFT OUTER
            JOIN contacts@&&p_db_link                            con
              ON 'SC'||trim(com.s_scheme) = trim(con.k_common_key)
            LEFT OUTER
            JOIN scheme@&&p_db_link                              sch
              ON trim(sch.s_scheme) = trim(com.s_scheme)
            LEFT OUTER
            JOIN member@&&p_db_link                              mem
              ON com.m_member = mem.m_member
--           WHERE     (    floor(months_between(sysdate, to_date(trim(cm_dt_run),'yyyy-mm-dd'))) <= 24
--                      OR  cm_dt_pay = 0)
           WHERE     trim(com.AG_CODE) in ('781000000')
--                 AND cm_dt_run = 20150413
                 AND (    0 <> (SELECT sum(to_number(trim(cm_amt_excl_vat))) 
                                  FROM commhist@&&p_db_link
                                 WHERE     ag_code = com.ag_code
                                       AND g_group = com.g_group
                                       AND o_option = com.o_option
                                       AND m_member = com.m_member
                                       AND cur_key = com.cur_key
                                       AND cm_tran_type = com.cm_tran_type
                                       AND sa_dt_subs = com.sa_dt_subs
                                       AND cm_dt_run = com.cm_dt_run)
                      OR  0 <> (SELECT sum(to_number(trim(cm_conv_amt_excl)))
                                  FROM commhist@&&p_db_link
                                 WHERE     ag_code = com.ag_code
                                       AND g_group = com.g_group
                                       AND o_option = com.o_option
                                       AND m_member = com.m_member
                                       AND cur_key = com.cur_key
                                       AND cm_tran_type = com.cm_tran_type
                                       AND sa_dt_subs = com.sa_dt_subs
                                       AND cm_dt_run = com.cm_dt_run))
           GROUP BY trim(com.ag_code) 
                   ,trim(com.g_group)
                   ,trim(co_street_country)
                   ,trim(com.o_option)
                   ,trim(com.m_member)
                   ,trim(mem.m_member) || '-' || trim(mem.b_depend)
                   ,sch.s_base_cur
                   ,cur_key
                   ,trim(cm_tran_type)
                   ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')
                   ,to_date(trim(cm_dt_run),'yyyy-mm-dd')
                   ,cm_dt_pay
                   ,to_number(trim(cm_amt_excl_vat)))
   GROUP BY
            country_code
           ,product_code
           ,person_code
           ,policy_code
           ,group_code
           ,broker_id_no
           ,contribution_date
           ,calculation_datetime
           ,pay_datetime
           ,base_cur
           ,cur_key)
 GROUP BY calculation_datetime, pay_datetime, base_cur, cur_key
 ORDER BY 1, 2, 3, 4;

/

    SELECT matched, comms_calc_type_code, calculation_datetime, payment_currency, exchange_rate_currency_code, sum(comms_calculated_amt) comms_calculated_amt, sum(comms_calculated_exch_amt) comms_calculated_exch_amt
      FROM (
    SELECT 
           CASE WHEN     trunc(calculation_datetime) BETWEEN to_date('24/MAR/2015' , 'DD/MON/YYYY') AND to_date('14/APR/2015' , 'DD/MON/YYYY')
--                     AND TRIM(payment_currency) = NVL(NULL, TRIM(payment_currency))
--                     AND TRIM(exchange_rate_currency_code) = 'USD'
                     AND comms_calc_type_code IN ('P', 'X')
                     AND (invoice_no IS NULL or invoice_no = 0) THEN 'M'
                ELSE 'U' END matched
          ,comms_calc_type_code
          ,calculation_datetime
          ,comms_calc_snapshot_no
          ,invoice_no
          ,comms_calculated_amt
          ,payment_currency
          ,comms_calculated_exch_amt
          ,exchange_rate_currency_code
      FROM comms_calc_snapshot
     WHERE     company_id_no = 781000000
--           AND trunc(calculation_datetime) BETWEEN to_date('24/MAR/2015' , 'DD/MON/YYYY') AND to_date('14/APR/2015' , 'DD/MON/YYYY')
     ORDER BY 1, 2, 3, 4
           ) GROUP BY matched, comms_calc_type_code, calculation_datetime, payment_currency, exchange_rate_currency_code
             ORDER BY 1, 3, 4, 5;

/

          SELECT trim(com.ag_code)                               broker_id_no
                ,trim(com.g_group)                               group_code
                ,trim(co_street_country)                         country_code
                ,trim(com.o_option)                              product_code
                ,trim(com.m_member)                              policy_code
                ,trim(mem.m_member) || '-' || trim(mem.b_depend) person_code
                ,sch.s_base_cur                                  base_cur
                ,cur_key
                ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')          contribution_date
                ,to_date(trim(cm_dt_run),'yyyy-mm-dd')           calculation_datetime
                ,to_date(trim(cm_dt_pay),'yyyy-mm-dd')           pay_datetime
                ,CASE WHEN to_number(trim(cm_amt_excl_vat)) = 0 THEN 0
                      ELSE round(sum(to_number(trim(cm_conv_amt_excl))) / sum(to_number(trim(cm_amt_excl_vat))),9)
                  END                                            exch_rate
                ,sum(to_number(trim(cm_1st_recu_amt)))           comms_perc
                ,CASE WHEN trim(cm_tran_type)= 'PADJ' THEN (sum(to_number(trim(cm_amt_excl_vat))) * sum(to_number(trim(cm_1st_recu_amt))))
                      ELSE sum(to_number(trim(cm_subs_paid*-1)))
                  END                                            payment_receive_amt
                ,sum(to_number(trim(cm_conv_amt_excl)))          comms_calculated_exc_amt
                ,sum(to_number(trim(cm_amt_excl_vat)))           comms_calculated_amt
            FROM commhist@&&p_db_link                            com
            LEFT OUTER
            JOIN contacts@&&p_db_link                            con
              ON 'SC'||trim(com.s_scheme) = trim(con.k_common_key)
            LEFT OUTER
            JOIN scheme@&&p_db_link                              sch
              ON trim(sch.s_scheme) = trim(com.s_scheme)
            LEFT OUTER
            JOIN member@&&p_db_link                              mem
              ON com.m_member = mem.m_member
--           WHERE     (    floor(months_between(sysdate, to_date(trim(cm_dt_run),'yyyy-mm-dd'))) <= 24
--                      OR  cm_dt_pay = 0)
           WHERE     trim(com.AG_CODE) in ('781000000')
                 AND cm_dt_run = 20150413
                 AND (    0 <> (SELECT sum(to_number(trim(cm_amt_excl_vat))) 
                                  FROM commhist@&&p_db_link
                                 WHERE     ag_code = com.ag_code
                                       AND g_group = com.g_group
                                       AND o_option = com.o_option
                                       AND m_member = com.m_member
                                       AND cur_key = com.cur_key
                                       AND cm_tran_type = com.cm_tran_type
                                       AND sa_dt_subs = com.sa_dt_subs
                                       AND cm_dt_run = com.cm_dt_run)
                      OR  0 <> (SELECT sum(to_number(trim(cm_conv_amt_excl)))
                                  FROM commhist@&&p_db_link
                                 WHERE     ag_code = com.ag_code
                                       AND g_group = com.g_group
                                       AND o_option = com.o_option
                                       AND m_member = com.m_member
                                       AND cur_key = com.cur_key
                                       AND cm_tran_type = com.cm_tran_type
                                       AND sa_dt_subs = com.sa_dt_subs
                                       AND cm_dt_run = com.cm_dt_run))
           GROUP BY trim(com.ag_code) 
                   ,trim(com.g_group)
                   ,trim(co_street_country)
                   ,trim(com.o_option)
                   ,trim(com.m_member)
                   ,trim(mem.m_member) || '-' || trim(mem.b_depend)
                   ,sch.s_base_cur
                   ,cur_key
                   ,trim(cm_tran_type)
                   ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')
                   ,to_date(trim(cm_dt_run),'yyyy-mm-dd')
                   ,to_date(trim(cm_dt_pay),'yyyy-mm-dd')
                   ,to_number(trim(cm_amt_excl_vat));
                   
/

SELECT * FROM commhist@&&p_db_link WHERE trim(AG_CODE) in ('781000000') AND s_scheme IN ('IBUG', 'LBLU') and cm_dt_run = 20150413;
SELECT * FROM saghist@&&p_db_link WHERE trim(AG_CODE) in ('781000000') AND s_scheme IN ('IBUG', 'LBLU');
SELECT * FROM saghist@&&p_db_link WHERE cm_narration = 'IBUG - 20150414';

  select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
         to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
         trim(co_street_country) country_code,
         trim(ag_code) company_id_no,
         trim(cur_key) currency_code,
         trim(cm_narration) fee_desc,
         trim(u_user) username,
         sum(to_number(trim(cm_conv_amt_excl))) header_amt,
         sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
         sum(to_number(trim(ag_rate_used))) exchange_rate,
         sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
    from saghist@&&p_db_link com,
         contacts@&&p_db_link c
   where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
      and cm_narration = 'IBUG - 20150414'
      and trim(cm_rectr_type) = 'RUN'
      and trim(cm_dt_pay) = 0
      and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
      and substr(s_scheme,0,1) not in ('A','O','U')
      and trim(co_street_country) = 'UG'
    group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
             to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
             trim(co_street_country),
             trim(ag_code),
             trim(cur_key),
             trim(cm_narration),
             trim(u_user)
  having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
         OR sum(to_number(trim(cm_amt_excl_vat))) <> 0
  order by 4, 1;
