SET SERVEROUTPUT ON;
define p_db_link = MEDWARE_PROD.LIBERTY.CO.ZA;
select 
 COMMS_CALC_SNAPSHOT_NO
,ccs.COUNTRY_CODE
,PRODUCT_CODE
,POEP_ID
,PERSON_CODE
,POLICY_CODE
,ccs.GROUP_CODE
,BROKER_ID_NO
,COMPANY_ID_NO
,COMMS_PERC
,CONTRIBUTION_DATE
,PAYMENT_RECEIVE_DATE
,FINANCE_RECEIPT_NO
,CALCULATION_DATETIME
,COMMS_CALC_TYPE_CODE
,PAYMENT_RECEIVE_AMT
,PAYMENT_CURRENCY
,COMMS_CALCULATED_AMT
,EXCHANGE_RATE
,EXCHANGE_RATE_CURRENCY_CODE
,COMMS_CALCULATED_EXCH_AMT
,INVOICE_NO
,ccs.LAST_UPDATE_DATETIME
,ccs.USERNAME
from comms_calc_snapshot ccs
-- where     COMMS_CALC_TYPE_CODE = 'X';
 where     calculation_datetime < to_date('01/SEP/2016', 'DD/MON/YYYY')
       AND contribution_date    >= to_date('01/SEP/2016', 'DD/MON/YYYY')
       AND country_code = 'UG';
-- Gonna get removed
--  where (sa_dt_subs >= 20160901 and cm_dt_run < 20160901)

select sum(counter) counter, count(*) records from (
select poep_id, count(*) counter from comms_recalc group by poep_id)
where counter > 1;

/

select 
       payment_receive_amt medware_pay
      ,comms_calculated_amt medware_comms
      ,comms_calculated_exc_amt medware_exch
      ,medware
      ,(select max(inse_code) from ohi_insured_entities where inse_code = medware) OHI_POLICIES 
      ,(select max(person_code) from comms_calc_snapshot where person_code = medware) CCS_PERSON
      ,(select sum(payment_receive_amt) from comms_calc_snapshot where person_code = medware) CCS_PAY
      ,(select sum(comms_calculated_amt) from comms_calc_snapshot where person_code = medware) CCS_COMMS
      ,(select sum(comms_calculated_exch_amt) from comms_calc_snapshot where person_code = medware) CCS_EXCH
  from (
select a.person_code MEDWARE
      ,sum(payment_receive_amt) payment_receive_amt
      ,sum(comms_calculated_exc_amt) comms_calculated_exc_amt
      ,sum(comms_calculated_amt) comms_calculated_amt
  from (
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
--  where  floor(months_between(sysdate, to_date(trim(cm_dt_run),'yyyy-mm-dd'))) <= 24
  where  cm_dt_run >= 20160901
     and trim(com.s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(com.s_scheme,0,1) not in ('A','O','U')
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
          ,to_date(trim(cm_dt_run),'yyyy-mm-dd')
) a 
group by a.person_code) 
order by 4;

/

delete 
from comms_calc_snapshot ccs
-- where     COMMS_CALC_TYPE_CODE = 'X';
 where     calculation_datetime < to_date('01/SEP/2016', 'DD/MON/YYYY')
       AND contribution_date    >= to_date('01/SEP/2016', 'DD/MON/YYYY')
       AND country_code = 'UG';

/

05097513-00