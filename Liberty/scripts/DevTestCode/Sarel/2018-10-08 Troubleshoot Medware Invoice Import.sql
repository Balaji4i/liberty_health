SET SERVEROUTPUT ON;
define p_db_link = MEDWARE_PROD.LIBERTY.CO.ZA;

  select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
         to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
         trim(co_street_country) country_code,
         trim(ag_code) company_id_no,
         trim(cur_key) currency_code,
         trim(cm_narration) fee_desc,
         trim(u_user) username,
         trim(cm_rectr_type) cm_rectr_type,
         trim(cm_dt_pay) cm_dt_pay,
         sum(to_number(trim(cm_conv_amt_excl))) header_amt,
         sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
         sum(to_number(trim(ag_rate_used))) exchange_rate,
         sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
    from saghist@&&p_db_link com,
         contacts@&&p_db_link c
   where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
--      and trim(cm_rectr_type) = 'RUN'
--      and trim(cm_dt_pay) = 0
--      and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
--      and substr(s_scheme,0,1) not in ('A','O','U')
--      and trim(co_street_country) = 'UG'
      and trim(ag_code) = '803000000'
    group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
             to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
             trim(co_street_country),
             trim(ag_code),
             trim(cur_key),
             trim(cm_narration),
             trim(u_user),
             trim(cm_rectr_type),
             trim(cm_dt_pay)
--  having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
--         OR sum(to_number(trim(cm_amt_excl_vat))) <> 0
  order by 4, 1;

select DISTINCT i.payment_date from   invoice i 
  join invoice_detail id 
    on i.invoice_no = id.invoice_no;
select 
       i.country_code
      ,i.company_id_no
      ,i.invoice_no
      ,i.invoice_type_id_no
      ,i.release_date
      ,i.payment_date
      ,i.payment_amt
      ,id.fee_type_desc
      ,id.fee_type_amt
      ,id.fee_type_exch_amt
  from invoice i 
  join invoice_detail id 
    on i.invoice_no = id.invoice_no
-- where     i.company_id_no = 803000000;
 where     i.payment_date is null
       and i.release_date is not null
       and i.invoice_type_id_no = 2
 order by 1, 2, 3;
 
   select trim(com.ag_code)                               broker_id_no
        ,trim(com.g_group)                               group_code
        ,trim(co_street_country)                         country_code
        ,trim(com.o_option)                              product_code
        ,trim(com.m_member)                              policy_code
        ,trim(mem.m_member) || '-' || trim(mem.b_depend) person_code
        ,sch.s_base_cur                                  base_cur
        ,cur_key
        ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')          contribution_date
        ,to_date(trim(cm_dt_run),'yyyy-mm-dd')           calculation_datetime
        ,round(sum(to_number(trim(cm_conv_amt_excl)))
              /sum(to_number(trim(cm_amt_excl_vat))),9)  exch_rate
        ,sum(to_number(trim(cm_1st_recu_amt)))           comms_perc
        ,case when trim(cm_tran_type)= 'PADJ' then
           (sum(to_number(trim(cm_amt_excl_vat))) * sum(to_number(trim(cm_1st_recu_amt))))
         else 
           sum(to_number(trim(cm_subs_paid*-1)))
         end                                             payment_receive_amt
        ,sum(to_number(trim(cm_conv_amt_excl)))          comms_calculated_exc_amt
        ,sum(to_number(trim(cm_amt_excl_vat)))           comms_calculated_amt
  from   commhist@&&p_db_link com
  left outer
  join   contacts@&&p_db_link con
    on   'SC'||trim(com.s_scheme) = trim(con.k_common_key)
  left outer
  join   scheme@&&p_db_link   sch
    on   trim(sch.s_scheme) = trim(com.s_scheme)
  left outer
  join   member@&&p_db_link mem
    on   com.m_member = mem.m_member
  where  1=1 -- floor(months_between(sysdate, to_date(trim(sa_dt_subs),'yyyy-mm-dd'))) <= 24
     and trim(com.s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(com.s_scheme,0,1) not in ('A','O','U')
     and com.ag_code = '803000000'
     and to_date(trim(cm_dt_run),'yyyy-mm-dd') between to_date('2016-06-25','yyyy-mm-dd') and to_date('2016-07-01','yyyy-mm-dd')
     and 0 <> (select sum(to_number(trim(cm_amt_excl_vat))) from commhist@&&p_db_link
                where ag_code = com.ag_code
                  and g_group = com.g_group
                  and o_option = com.o_option
                  and m_member = com.m_member
                  and cur_key = com.cur_key
                  and cm_tran_type = com.cm_tran_type
                  and sa_dt_subs = com.sa_dt_subs
                  and cm_dt_run = com.cm_dt_run)
  group by trim(com.ag_code) 
          ,trim(com.g_group)
          ,trim(co_street_country)
          ,trim(com.o_option)
          ,trim(com.m_member)
          ,trim(mem.m_member) || '-' || trim(mem.b_depend)
          ,sch.s_base_cur
          ,cur_key
          ,trim(cm_tran_type)
          ,to_date(trim(sa_dt_subs),'yyyy-mm-dd')
          ,to_date(trim(cm_dt_run),'yyyy-mm-dd');
