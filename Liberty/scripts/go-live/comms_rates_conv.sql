drop table temp_medware_comm_perc;
drop table temp_rates;

 create table temp_rates as
  select s_scheme, o_option, g_comm_rate, cm_eff_from_Dt, to_date(trim(cm_eff_from_Dt),'yyyy-mm-dd') effective_start_date, cm_1st_recu_amt comm_perc
    from cmrates@MEDWARE_UAT.LIBERTY.CO.ZA
--    from cmrates@MEDWARE_DEV.LIBERTY.CO.ZA
   where trim(cm_comm_pay_ind) = 'PD'
   order by s_scheme, g_comm_rate, cm_eff_from_dt;

create or replace function get_medware_comms_rate(p_scheme in varchar2, p_option in varchar2, p_comm_rate in varchar2, p_date in date) return number is
 v_num number;
 
cursor c_info is
  select to_number(comm_perc)
  from temp_rates
  where s_scheme = p_scheme
    and o_option = p_option
    and trim(g_comm_rate) = p_comm_rate
    and p_date >= effective_start_date
    order by effective_start_date desc;

 begin
    
    open c_info;
      fetch c_info into v_num;
    close c_info;
    
    if v_num IS NULL then 
      return null;
    else 
    return v_num;
    end if;
    
exception 
  when no_data_found then
     return null;
 end;
 
 /
 
 
create table temp_medware_comm_perc as
  select distinct group_code, option_code, comm_perc, effective_start_date
    from (select  trim(grp_st.g_group) group_code ,rates.o_option option_code,  -- to_date(trim(grp_st.sa_dt_subs),'yyyy-mm-dd') start_date,
                  get_medware_comms_rate(trim(s_scheme), rates.o_option,  trim(grp_st.g_comm_rate), to_date(trim(grp_st.sa_dt_subs),'yyyy-mm-dd') ) comm_perc,
                  to_date(trim(cm_eff_from_Dt),'yyyy-mm-dd') effective_start_date
            from groups@MEDWARE_UAT.LIBERTY.CO.ZA grp,
                 grpstat@MEDWARE_UAT.LIBERTY.CO.ZA grp_st,
                 cmrates@MEDWARE_UAT.LIBERTY.CO.ZA rates
--            from groups@MEDWARE_DEV.LIBERTY.CO.ZA grp,
--                 grpstat@MEDWARE_DEV.LIBERTY.CO.ZA grp_st,
--                 cmrates@MEDWARE_DEV.LIBERTY.CO.ZA rates
           where grp.g_group = grp_st.g_group
             and trim(cm_comm_pay_ind) = 'PD'
             and trim(grp_st.g_comm_rate) is not null
             and g_scheme = s_scheme
             and g_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
             and g_scheme in ('IBUG', 'LBLU')
             and grp_st.g_comm_rate = rates.g_comm_rate
             and to_date(trim(grp_st.sa_dt_subs),'yyyy-mm-dd') >= '01-JAN-2016'
  order by trim(grp_st.g_group) ,rates.o_option,   to_date(trim(grp_st.sa_dt_subs),'yyyy-mm-dd'))
  where comm_perc is not null
;

/
/*
Ad Hoc Code

select group_code, option_code, comm_perc, 'Converted from Medware', effective_Start_date, effective_end_date, user,user,sysdate,'SARELTST'
from (
select distinct group_code,  option_code, comm_perc, effective_start_date,
       nvl(lead(effective_Start_date-1) over (partition by group_code, option_code, comm_perc  order by effective_start_date),'31-JAN-3100') effective_end_date
from temp_medware_comm_perc)
where group_code NOT in (select group_code from ohi_groups)
  or option_code NOT in (select product_code from ohi_products);

select group_code, option_code, comm_perc, 'Converted from Medware', effective_Start_date, effective_end_date, user,user,sysdate,'SARELTST'
from (
select distinct group_code,  option_code, comm_perc, effective_start_date,
       nvl(lead(effective_Start_date-1) over (partition by group_code, option_code, comm_perc  order by effective_start_date),'31-JAN-3100') effective_end_date
from temp_medware_comm_perc)
where group_code in (select group_code from ohi_groups)
  and option_code in (select product_code from ohi_products);

*/
/
declare
begin
insert into ohi_comm_perc (
GROUP_CODE,
PRODUCT_CODE,
COMM_PERC,
COMM_DESC,
EFFECTIVE_START_DATE,
EFFECTIVE_END_DATE,
CREATED_USERNAME,
AUTH_USERNAME,
LAST_UPDATE_DATETIME,
USERNAME)
select group_code, option_code, comm_perc, 'Converted from Medware', effective_Start_date, effective_end_date, user,user,sysdate,'LHHCOM'
from (
select distinct group_code, trim(option_code) as option_code, comm_perc, effective_start_date,
       nvl(lead(effective_Start_date-1) over (partition by group_code, option_code, comm_perc  order by effective_start_date),'31-JAN-3100') effective_end_date
from temp_medware_comm_perc)
where group_code in (select group_code from ohi_groups)
  and option_code in (select product_code from ohi_products);
exception  
  when dup_val_on_index then
    null;
end;
/*
drop table temp_medware_comm_perc;
drop table temp_rates;
*/