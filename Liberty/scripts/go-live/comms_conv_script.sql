declare

lv_medware_agent_code    varchar2(100);
ln_company_id_no         company.company_id_no%type;
ln_broker_id_no          broker.broker_id_no%type;
lv_username              varchar2(100) := 'MedWare';
lv_db_link               varchar2(200) := get_System_parameter('LB_HEALTH_COMMS','SYSTEM','MEDWARE_LINK');
ld_last_update_date      date := sysdate;
ln_exist_number          company.company_id_no%type;
lv_contact_exist         char(1);
lv_country_code          varchar2(5) := 'LS';
ln_contact_type_id_no    company_contact.company_contact_type_id_no%type;
lv_passport_code         broker.passport_code%type;
ln_id_no                 broker.id_no%type;
lv_home_tell             broker.HOME_TELEPHONE_NO%type;
lv_work_tell             broker.WORK_TELEPHONE_NO%type;
lv_cell_no               broker.CELLPHONE_NO%type;
lv_email_addres          broker.EMAIL_ADDRESS%type;
ln_invoice_number        invoice.invoice_no%type;

cursor c_agent is
  select trim(AG_CODE) AG_CODE,
    trim(AG_PARENT_CODE) AG_PARENT_CODE,
    trim(AG_NAME) AG_NAME,
    case
      when trim(AG_TYPE) is null then 31   ---company_table = 4
      when trim(AG_TYPE) = 'AGCY' then 31 ---company_table = 4
      when trim(AG_TYPE) = 'AGEN' then 1 --broker_Table = 1
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is not null then 1 --broker_Table = 1 
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is null then 31 ---company_table = 4
      when trim(AG_TYPE) = 'BROK' then 31   ---company_table = 4
      when trim(AG_TYPE) = 'CONS' then 1 --broker_Table = 1 
      when trim(AG_TYPE) = 'DRCT' then 31 ---company_table = 4
      when trim(AG_TYPE) = 'HSE' then 31 ---company_table = 4
    end AG_TYPE,
    case
      when trim(AG_TYPE) is null then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'AGCY' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'AGEN' then 'N'  --broker_Table = 1
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is not null then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'AGNT' and trim(AG_PARENT_CODE) is null then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'BROK' then 'Y'   ---company_table = 4
      when trim(AG_TYPE) = 'CONS' then 'N' --broker_Table = 1 
      when trim(AG_TYPE) = 'DRCT' then 'Y' ---company_table = 4
      when trim(AG_TYPE) = 'HSE' then 'Y' ---company_table = 4
    end IS_COMPANY_RECORD,
    trim(AG_COMPANY_CODE) AG_COMPANY_CODE,
    trim(AG_CONSULTANT) AG_CONSULTANT, --KAM BROKER
    case 
      when length(trim(AG_DT_FROM)) = 8 then to_date(trim(AG_DT_FROM),'yyyymmdd')
     else
       to_date('20000101','yyyymmdd')
    end effective_start_date,
    
    case 
      when length(trim(AG_DT_TO)) = 8 then to_date(trim(AG_DT_TO),'yyyymmdd')
     else
       to_date('31000131','yyyymmdd')
    end effective_end_date,
    AG_DT_TYPE,
    nvl(trim(AG_REG_VAT),'N') AG_REG_VAT,
    trim(AG_PIN) AG_PIN,
    decode(trim(AG_PAY_MODE),'EFT',61,62) AG_PAY_MODE,  --company_table_type + company_table id = 5
    nvl(trim(AG_LANGUAGE),'E') AG_LANGUAGE,
    trim(U_USER) U_USER,
    trim(WEB_EXTENDED) WEB_EXTENDED,
    trim(AG_CONTACT) AG_CONTACT,
    case
      when trim(AG_STATUS)  = 'ACTIVE' then 25
      when trim(AG_STATUS) = 'RESIGN' then 27
      when trim(AG_STATUS) = 'PREREG' then 24
     end AG_STATUS,     -- company table type, company_table id no = 2
    AG_COMM_PCT,
    nvl(trim(AG_INHOUSE),'N') as AG_INHOUSE,
    trim(AG_ACCRED) AG_ACCRED,
    AG_DT_ACCRED,
    AG_DT_EXPIRY,
    trim(AG_REASON) AG_REASON,
    trim(AG_REG_VAT_NO) AG_REG_VAT_NO,
    trim(AG_P_ACCRED) AG_P_ACCRED,
    AG_P_DT_ACCRED,
    AG_P_DT_EXPIRE,
    trim(AG_ID_NO) AG_ID_NO,
    case 
      when nvl(trim(AG_STMNT_IND),'PP') = 'PP' then 21
      when nvl(trim(AG_STMNT_IND),'PP') = 'EM' then 23
      when nvl(trim(AG_STMNT_IND),'PP') = 'FX' then 22
     end AG_STMNT_IND,   --company table type, company table id no = 1
    trim(AG_FAIS) AG_FAIS,
    decode(AG_FAIS_DT_EXP,0,null, to_date(trim(AG_FAIS_DT_EXP),'yyyymmdd')) AG_FAIS_DT_EXP,
    decode(AG_FAIS_DT_START,0,null, to_date(trim(AG_FAIS_DT_START),'yyyymmdd')) AG_FAIS_DT_START,
    trim(AG_CO_REG) AG_CO_REG,
    nvl(trim(AG_TITLE),'MR') AG_TITLE,
    trim(AG_INITLS) AG_INITLS,
    nvl(trim(AG_FIRST_NAME),trim(ag_name)) AG_FIRST_NAME,
    trim(AG_SURNAME) AG_SURNAME,
    --AG_KEY_IND_1,
    --AG_DT_AUTH_KEY_1,
    --AG_DT_AB_AUTH_1,
    --AG_KEY_IND_2,
    --AG_DT_AUTH_KEY_2,
    --AG_DT_AB_AUTH_2,
    trim(AG_TAX_REF) AG_TAX_REF,
    trim(AG_PREFER_CUR) AG_PREFER_CUR,
    decode(trim(AG_MULTINAT),null,'N','Y') AG_MULTINAT,
    trim(substr(trim(AG_NAME),instr(trim(AG_NAME),' ')+1, length(trim(AG_NAME)))) last_name
  from agent@lv_db_link
  where trim(ag_dt_to) = 0
    and trim(ag_code) in (select trim(ag_code)
                      from agschem@lv_db_link
                     where s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
                       and substr(s_scheme,0,1) not in ('A','O','U'))    
  order by is_company_record, ag_parent_code desc, 1;
 
cursor c_country is
 select ag_code, 
        cm_hold_credit,
        sum(cm_start_amt) cm_start_amt,
        country_code
  from (
    select trim(a.AG_CODE) AG_CODE,
           nvl(trim(a.CM_HOLD_CREDIT),'N') CM_HOLD_CREDIT,
           trim(a.CM_START_AMT) CM_START_AMT,
           trim(co_postal_country) country_code,
           count(*)
    from agschem@lv_db_link a,
         contacts@lv_db_link c
   where 'SC'||a.s_scheme = c.k_common_key
     and  a.s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(s_scheme,0,1) not in ('A','O','U') 
     and trim(a.ag_code) = trim(lv_medware_agent_code)
   group by trim(a.AG_CODE) ,
           nvl(trim(a.CM_HOLD_CREDIT),'N') ,
           trim(a.CM_START_AMT) ,
           co_postal_country
  union all
      select trim(a.AG_CODE) AG_CODE,
           nvl(trim(a.CM_HOLD_CREDIT),'N') CM_HOLD_CREDIT,
           trim(a.CM_START_AMT) CM_START_AMT,
           trim(co_postal_country) country_code,
           count(*)
    from agschem@lv_db_link a,
         contacts@lv_db_link c
   where 'AG'||trim(a.ag_code) = trim(c.k_common_key)
     and  a.s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(s_scheme,0,1) not in ('A','O','U') 
     and trim(a.ag_code) = trim(lv_medware_agent_code)
   group by trim(a.AG_CODE) ,
           nvl(trim(a.CM_HOLD_CREDIT),'N') ,
           trim(a.CM_START_AMT) ,
           co_postal_country
  union all
      select trim(a.AG_CODE) AG_CODE,
           nvl(trim(a.CM_HOLD_CREDIT),'N') CM_HOLD_CREDIT,
           trim(a.CM_START_AMT) CM_START_AMT,
           trim(co_street_country) country_code,
           count(*)
    from agschem@lv_db_link a,
         contacts@lv_db_link c
   where 'AG'||trim(a.ag_code) = trim(c.k_common_key)
     and  a.s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(s_scheme,0,1) not in ('A','O','U') 
     and trim(a.ag_code) = trim(lv_medware_agent_code)
   group by trim(a.AG_CODE) ,
           nvl(trim(a.CM_HOLD_CREDIT),'N') ,
           trim(a.CM_START_AMT) ,
           co_street_country)
  group by ag_code, 
        cm_hold_credit,
        country_code;
		
cursor c_contacts (pv_agent_code varchar2, pv_country_code varchar2) is
 select  trim(a.AG_CODE) AG_CODE,
         trim(co_postal_country) co_postal_country,
         trim(co_street_country) co_street_country,
         trim(a.S_SCHEME) S_SCHEME,
         trim(a.AG_SCHM_KEY) AG_SCHM_KEY,
         trim(a.CM_START_AMT) CM_START_AMT,
         trim(a.AG_CONTACT) AG_CONTACT,
         nvl(trim(a.CO_EMAIL),trim(c.CO_EMAIL)) CO_EMAIL,
         nvl(trim(a.CO_SUB_ACCT_TYPE),trim( c.CO_SUB_ACCT_TYPE)) CO_SUB_ACCT_TYPE,
         nvl(trim(a.CO_SUB_ACCT_BR),trim(c.CO_SUB_ACCT_BR)) CO_SUB_ACCT_BR,
         nvl(trim(a.CO_SUB_ACCT),trim(c.CO_SUB_ACCT)) CO_SUB_ACCT,
         trim(a.AG_CONSULTANT) AG_CONSULTANT,
         trim(a.AG_PREFER_CUR) AG_PREFER_CUR,
         nvl(trim(a.AB_SWIFT_CODE),trim(c.AB_SUB_SWIFT_CODE)) AB_SWIFT_CODE,
         trim(a.AG_ACCT_NAME) AG_ACCT_NAME,
         trim(c.CO_STREET_L1) CO_STREET_L1,
         trim(c.CO_STREET_L2) CO_STREET_L2,
         trim(c.CO_STREET_L3) CO_STREET_L3,
         trim(c.CO_STREET_TOWN) CO_STREET_TOWN,
         trim(c.CO_STREET_PCODE) CO_STREET_PCODE ,
         trim(c.CO_POSTAL_L1) CO_POSTAL_L1,
         trim(c.CO_POSTAL_L2) CO_POSTAL_L2,
         trim(c.CO_POSTAL_L3) CO_POSTAL_L3,
         trim(c.CO_POSTAL_TOWN) CO_POSTAL_TOWN,
         trim(c.CO_POSTAL_PCODE) CO_POSTAL_PCODE ,
         trim(c.CO_FAX) CO_FAX,
         trim(c.CO_TEL_WORK) CO_TEL_WORK,
         trim(c.CO_TEL_HOME) CO_TEL_HOME,
         trim(c.CO_CELL) CO_CELL,        
         trim(c.CO_SUB_DT_FROM) CO_SUB_DT_FROM,
         trim(c.CO_CELL2) CO_CELL2,
         trim(c.CO_SMS_ALLOW) CO_SMS_ALLOW,
         trim(c.CO_NO_EMAIL) CO_NO_EMAIL,
         trim(c.CO_DATE_FROM) CO_DATE_FROM,
         trim(c.AB_SUB_IBAN_NO) AB_SUB_IBAN_NO
  from agschem@lv_db_link a,
       contacts@lv_db_link c
 where 'SC'||trim(a.s_scheme) = trim(c.k_common_key)
   and  a.s_scheme not in ('BMIR','IMED','ESMA','HERI','CFC')
   and substr(s_scheme,0,1) not in ('A','O','U')
   and trim(ag_code) = trim(pv_agent_code)
   and trim(co_postal_country) = trim(pv_country_code);

cursor c_address(pv_agent_code varchar2) is
 select  trim(a.AG_CODE) AG_CODE,
         trim(co_postal_country) co_postal_country,
         trim(co_street_country) co_street_country,
         trim(c.CO_STREET_L1) CO_STREET_L1,
         trim(c.CO_STREET_L2) CO_STREET_L2,
         trim(c.CO_STREET_L3) CO_STREET_L3,
         trim(c.CO_STREET_TOWN) CO_STREET_TOWN,
         trim(c.CO_STREET_PCODE) CO_STREET_PCODE ,
         trim(c.CO_POSTAL_L1) CO_POSTAL_L1,
         trim(c.CO_POSTAL_L2) CO_POSTAL_L2,
         trim(c.CO_POSTAL_L3) CO_POSTAL_L3,
         trim(c.CO_POSTAL_TOWN) CO_POSTAL_TOWN,
         trim(c.CO_POSTAL_PCODE) CO_POSTAL_PCODE 
  from agent@lv_db_link a,
       contacts@lv_db_link c
 where 'AG'||trim(a.ag_code) = trim(c.k_common_key)
   and trim(a.ag_code) = trim(pv_agent_code);

cursor c_broker_contact(pv_agent_code varchar2) is
select trim(CO_TEL_WORK) work_tell,
       trim(CO_TEL_home) home_tell,
       nvl(trim(co_cell), trim(CO_CELL2)) cell_no,
       trim(CO_EMAIL) email
from agent@lv_db_link a,
       contacts@lv_db_link c
 where 'AG'||trim(a.ag_code) = trim(c.k_common_key)
 --  and  trim(AG_TYPE) in ('AGEN','CONS','AGNT')
   and trim(a.ag_code) = trim(pv_agent_code);
   
cursor c_company_contact (pn_company_id_no number, pv_country_code varchar2) is
  select rowid, contact_name
    from company_contact
   where company_id_no = pn_company_id_no
     and country_code = pv_country_code;
  
cursor c_comms_history is
select trim(ag_code) broker_id_no, 
       trim(g_group) group_code,
       trim(co_street_country) country_code,
       trim(o_option) product_code,
       trim(m_member) person_code,
       cur_key,
       to_date(trim(sa_dt_subs),'yyyy-mm-dd') contribution_date,       
       to_date(trim(cm_dt_run),'yyyy-mm-dd') calculation_datetime,
       round(sum(to_number(trim(cm_conv_amt_excl)))/sum(to_number(trim(cm_amt_excl_vat))),9) exch_rate,
       sum(to_number(trim(cm_1st_recu_amt))) comms_perc,
       case
         when trim(cm_tran_type)= 'PADJ' then
          (sum(to_number(trim(cm_amt_excl_vat))) * sum(to_number(trim(cm_1st_recu_amt))))
       else 
       sum(to_number(trim(cm_subs_paid*-1)))
       end payment_receive_amt,
       sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_exc_amt,
       sum(to_number(trim(cm_amt_excl_vat))) comms_calculated_amt,
       'Medware' username
from commhist@lv_db_link com,
      contacts@lv_db_link c
where floor(months_between(sysdate, to_date(trim(sa_dt_subs),'yyyy-mm-dd'))) <= 24
  and 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
  and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
  and substr(s_scheme,0,1) not in ('A','O','U')
group by trim(ag_code) , 
       trim(g_group) ,
       trim(co_street_country) ,
       trim(o_option) ,
       trim(m_member) ,
       trim(cm_tran_type),
       to_date(trim(sa_dt_subs),'yyyy-mm-dd') ,       
       to_date(trim(cm_dt_run),'yyyy-mm-dd'),
       cur_key;

 cursor c_journal_history is
   select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
       to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
       trim(co_street_country) country_code,
       trim(ag_code) company_id_no,
       to_date(trim(cm_dt_pay),'yyyy-mm-dd') payment_date,
       trim(cur_key) currency_code,
       trim(cm_narration) fee_desc,
       trim(u_user) username,
       sum(to_number(trim(cm_conv_amt_excl))) header_amt,
       sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
       sum(to_number(trim(ag_rate_used))) exchange_rate,
       sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
from saghist@lv_db_link com,
      contacts@lv_db_link c
where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
  and trim(cm_rectr_type) = 'JNL'
  and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
  and substr(s_scheme,0,1) not in ('A','O','U')
  and trim(co_street_country) = lv_country_code
  and floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
       to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
       trim(co_street_country) ,
       trim(ag_code) ,
       to_date(trim(cm_dt_pay),'yyyy-mm-dd') ,
       trim(cur_key) ,
       trim(cm_narration) ,
       trim(u_user)
having sum(to_number(trim(cm_conv_amt_excl))) <> 0;

 cursor c_invoice_history is
  select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
       to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
       trim(co_street_country) country_code,
       trim(ag_code) company_id_no,
       to_date(trim(cm_dt_pay),'yyyy-mm-dd') payment_date,
       trim(cur_key) currency_code,
       trim(cm_narration) fee_desc,
       trim(u_user) username,
       sum(to_number(trim(cm_conv_amt_excl))) header_amt,
       sum(to_number(trim(cm_amt_excl_vat))) payment_amt,
       sum(to_number(trim(ag_rate_used))) exchange_rate,
       sum(to_number(trim(cm_conv_amt_excl))) comms_calculated_excg_amt
from saghist@lv_db_link com,
      contacts@lv_db_link c
where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
  and trim(cm_rectr_type) = 'PAYM'
  and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
  and substr(s_scheme,0,1) not in ('A','O','U')
  and trim(co_street_country) = lv_country_code
  and floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
       to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
       trim(co_street_country) ,
       trim(ag_code) ,
       to_date(trim(cm_dt_pay),'yyyy-mm-dd') ,
       trim(cur_key) ,
       trim(cm_narration) ,
       trim(u_user)
having sum(to_number(trim(cm_conv_amt_excl))) <> 0;
	
 cursor c_invoices_to_be_paid is
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
from saghist@lv_db_link com,
      contacts@lv_db_link c
where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
  and trim(cm_rectr_type) = 'RUN'
  and trim(cm_dt_pay) = 0
  and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
  and substr(s_scheme,0,1) not in ('A','O','U')
  and trim(co_street_country) = lv_country_code
group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
       to_date(trim(ad_dt_stamp),'yyyy-mm-dd'),
       trim(co_street_country),
       trim(ag_code),
       trim(cur_key),
       trim(cm_narration),
       trim(u_user)
having sum(to_number(trim(cm_conv_amt_excl))) <> 0;

cursor c_brokers_notes is
    select  trim(ag_code) company_id_no,
            to_timestamp(trim(ad_dt_stamp)||' '||trim(ad_tm_stamp),'yyyymmdd HH24MISSFF') datetime,
            u_user username,
            n_text comment_desc
    from agschem@lv_db_link a,
         notes@lv_db_link c
   where 'AG'||a.ag_code = c.n_key
     and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
    order by n_line_no desc;
	
begin
   
   delete from temp_agent_company_table;  --empty table if there was a previous run. Table is used to hold medware values with new commissions values for refernce
   delete from temp_agent_broker_table;   --empty table if there was a previous run. Table is used to hold medware values with new commissions values for refernce
   lhhcom.alter_all_triggers('DISABLE');
   for x in c_agent loop
     lv_medware_agent_code := trim(x.ag_code);
     
     if x.is_company_record = 'Y' then --If Y then the current record is a brokerage and should be added to the company table
           
       --check to see if agent code is a valid number. If not, function returns null
       ln_company_id_no := check_if_number(lv_medware_agent_code);     
	   --If the check_if_number function did return a number, check to see if the brokerage record has been created	   
       ln_exist_number := get_company_id_no(ln_company_id_no);
       --If the get_company_id_no function did return a number,  if means the brokerage already exists and we will exclude further conversion	 
       if ln_exist_number is not null then
         dbms_output.put_line('Company record already exists: '||ln_exist_number);
       else
         --If the get_company_id_no function did not return a number,  if means the brokerage doesn't exist and a new sequence needs to be fetched.       
         if ln_company_id_no is null then   
           ln_company_id_no := company_id_no_seq.nextval;
		   --insert the non numeric agent code and the new matching company_id_no into temp table for reference
           insert into temp_agent_company_table values (lv_medware_agent_code,ln_company_id_no);
         end if;
        
         insert into company (company_id_no,                            company_name,
                                                                        preferred_currency_code,
                              internal_broker_ind,                      vat_reg_ind,
                              wht_cert_ind,                             company_agreement_ind,
                              referral_agreement_ind,                   company_reg_doc_ind,
                              bank_details_ind,                         id_doc_ind,
                              letter_of_intent_ind,                     dis_agreement_application_ind,
                              address_ind,                              tax_id_no_ind,
                              consultant_id_no,                         
                              last_update_datetime,                     username)
                       values (ln_company_id_no,                        x.ag_name, 
                                                                        x.ag_prefer_cur, 
                               x.ag_inhouse,                            x.AG_REG_VAT, 
                               'N',                                     'N',
                               'N',                                     decode(x.ag_co_reg,null,'N','Y'),
                               'N',                                     decode(x.ag_id_no,null,'N','Y'),
                               'N',                                     'N',
                               'N',                                     decode(x.ag_tax_ref,null,'N','Y'),
                               GET_BROKER_ID_NO(trim(x.ag_consultant)),
                               ld_last_update_date,      	            lv_username); 
                            
         --insert company commissions percentage
         insert into ohi_comm_perc (company_id_no,
                                        effective_start_date,      effective_end_date,
                                        comm_perc,         comm_desc,
                                        created_username,   auth_username,
                                        last_update_datetime,      username)
                                values (ln_company_id_no,
                                        x.effective_start_date,    x.effective_end_date,
                                        trim(x.ag_comm_pct),       'Converted',
                                        'Converted',               'Converted',
                                        ld_last_update_date,       lv_username); 
                                       
         --fetch all the countries for the agent
         for yy in c_country loop
           begin
             insert into company_country (company_id_no,             country_code,
                                          effective_start_date,      effective_end_date,
                                          hold_ind,                  min_payout_amt,
                                          last_update_datetime,      username)
                                   values (ln_company_id_no,         yy.country_code,
                                           x.effective_start_date,   x.effective_end_date,
                                           trim(yy.cm_hold_credit),  trim(yy.cm_start_amt),
                                           ld_last_update_date,      lv_username); 
                                            
           exception
             when dup_val_on_index then
                dbms_output.put_line('DUPLICATE COUNTRY: '||ln_company_id_no||','||yy.country_code);
                update company_country
                   set hold_ind        = nvl(hold_ind, trim(yy.cm_hold_credit)),
                       min_payout_amt  = nvl(min_payout_amt,trim(yy.cm_start_amt))
                 where company_id_no   = ln_company_id_no
                   and country_code    = yy.country_code;
           end;
           
		    begin
            insert into company_reg (company_id_no,
                         country_code,
                         effective_start_date,
                         effective_end_date,
                         vat_no,
                         reg_no,
                         fais_no,
                         expiry_date,
                         application_date,
                         authorise_date,
                         last_update_datetime,
                         username)
				values (ln_company_id_no,
				        yy.country_code,
						x.effective_start_date,  
						x.effective_end_date,
						x.AG_REG_VAT_NO,
						x.AG_CO_REG,
						x.AG_FAIS,
						null,
						x.AG_FAIS_DT_START,
						x.AG_FAIS_DT_EXP,
						sysdate,
						'Medware');
          exception
            when others then
              dbms_output.put_line('Error with company: '||ln_company_id_no||' with error:'||sqlerrm);
           end;
		   
           -- insert company contact 
           begin
		   
		     lv_home_tell     := null;
		     lv_work_tell     := null;
		     lv_cell_no       := null;
		     lv_email_addres  := null;
		     
		     open c_broker_contact(lv_medware_agent_code);
		       fetch c_broker_contact into lv_work_tell, lv_home_tell, lv_cell_no,lv_email_addres ;
		     close c_broker_contact;
			 
             insert into company_contact (company_id_no,
                                          country_code,			company_contact_type_id_no,
                                          effective_start_date,	effective_end_date,
                                          contact_name,			contact_cellphone_no,
                                          contact_email,		contact_fax_no,
                                          contact_telephone_no,	contact_desc,
                                          last_update_datetime,	username)
                                  values (ln_company_id_no,
                                          YY.COUNTRY_CODE,      1,
                                          x.effective_start_date,        '31-JAN-3100',
                                          trim(x.ag_contact),   lv_cell_no,
                                          lv_email_addres,      null,
                                          lv_work_tell,         'Converted',                                 
                                          ld_last_update_date,  lv_username);
                                        
           exception
             when dup_val_on_index then
                dbms_output.put_line('COMPANY CONTACT DUPLICATE: '||ln_company_id_no||','||yy.country_code||',');
				--there is no update on duplicate value here as none of the fields in the data has values. These will be populated further down the script
           end;                   
             
		   --Loop through c_contacts to find matching records and update their details accordingly
         /*  for a in c_contacts (lv_medware_agent_code, trim(yy.country_code)) loop
             lv_contact_exist := 'N';
             ln_contact_type_id_no := 1;
             
             for z in c_company_contact (ln_company_id_no, YY.COUNTRY_CODE) loop
                update company_contact
                   set contact_cellphone_no = nvl(trim(a.co_cell),trim(a.co_tel_home)),
                       contact_email = nvl(contact_email,trim(a.co_email)),
                       contact_fax_no = trim(a.co_fax),
                       contact_telephone_no = nvl(trim(a.co_tel_work),trim(a.co_tel_home)),
                       contact_name = nvl(trim(a.ag_contact),nvl(trim(contact_name),x.ag_name))
                 where rowid = z.rowid;
                 lv_contact_exist := 'Y';
                  
             end loop;
           
             if lv_contact_exist = 'Y' then
			   --if a previous record exists and was updated, then we need to insert a new contact person for the current record we're working with. Inserting new row with type secondary [contact type = 2]
               ln_contact_type_id_no := 2;
             end if;
             
             begin
               insert into company_contact (company_id_no,
                                            country_code,			                                        company_contact_type_id_no,
                                            effective_start_date,	                                        effective_end_date,
                                            contact_name,			                                        contact_cellphone_no,
                                            contact_email,			                                        contact_fax_no,
                                            contact_telephone_no,	                                        contact_desc,
                                            last_update_datetime,	                                        username)
                                    values (ln_company_id_no,                     
                                            YY.COUNTRY_CODE,                                                ln_contact_type_id_no,
                                            x.effective_start_date,                                         x.effective_end_date,
                                            nvl(trim(a.ag_contact),trim(x.ag_name)),                        nvl(trim(a.co_cell),trim(a.co_tel_home)),
                                            trim(a.co_email),                                               trim(a.co_fax),
                                            nvl(trim(a.co_tel_work),trim(a.co_tel_home)),                   'Converted',                                 
                                            ld_last_update_date,                                            lv_username);

             exception
               when dup_val_on_index then
                  dbms_output.put_line('SECOND COMPANY CONTACT DUPLICATE: '||ln_company_id_no||','||yy.country_code||',');
				  --there is no update on duplicate value here as none of the fields in the data has values.
             end;   */           
             /*
             
             --insert banking details
             begin
               insert into company_bank_details  (company_id_no,
                                                 country_code,                 effective_start_date,
                                                 effective_end_date,						bank_acc_type_id_no,
                                                 acc_holder_name,							bank_acc_name,
                                                 bank_acc_no,								  bank_name,
                                                 bank_branch_code,							bank_branch_name,
                                                 bank_swift_code,							iban_nib_no,
                                                 created_username,							auth_username,
                                                 last_update_datetime,					username)
                                         values (ln_company_id_no,                         
                                                 yy.country_code,              x.effective_start_date,
                                        x.effective_end_date,                1,
                                                 trim(a.AG_ACCT_NAME),         trim(a.AG_ACCT_NAME),
                                                 trim(a.CO_SUB_ACCT),          null,
                                                 trim(a.CO_SUB_ACCT_BR),       null,
                                                 trim(a.AB_SWIFT_CODE),        trim(a.AB_SUB_IBAN_NO),
                                                 lv_username,                  'Convert',
                                                 ld_last_update_date,          lv_username);
           
             exception
               when dup_val_on_index then
                  dbms_output.put_line('COMPANY BANKING DETAILS DUPLICATE: '||ln_company_id_no||','||yy.country_code||',');
                  update company_bank_details
                     set acc_holder_name  = nvl(acc_holder_name  ,trim(a.AG_ACCT_NAME)),    
                         bank_acc_name    = nvl(bank_acc_name    ,trim(a.AG_ACCT_NAME)),    
                         bank_acc_no      = nvl(bank_acc_no      ,trim(a.CO_SUB_ACCT)),    
                         bank_name        = nvl(bank_name        ,null),    
                         bank_branch_code = nvl(bank_branch_code ,trim(a.CO_SUB_ACCT_BR)),    
                         bank_branch_name = nvl(bank_branch_name ,null),    
                         bank_swift_code  = nvl(bank_swift_code  ,trim(a.AB_SWIFT_CODE)),    
                         iban_nib_no      = nvl(iban_nib_no      ,trim(a.AB_SUB_IBAN_NO))     
                   where company_id_no = ln_company_id_no
                     and country_code = yy.country_code
                     and bank_acc_type_id_no = 1;                
             end;*/                 
           end loop; -- for a in c_contacts
          
          begin
		   --insert the company function record for the ag_type. The type has been converted to the commission self built type in the select statement
           insert into company_function (company_id_no,               
                                         company_table_id_no,         effective_start_date,
                                         effective_end_date,          company_table_type_id_no,
                                         last_update_datetime,        username)
                                 values (ln_company_id_no,             
                                         4,                           x.effective_start_date,
                                x.effective_end_date,               x.ag_type, 
                                         ld_last_update_date,         lv_username);
            exception
               when dup_val_on_index then
                 null;
            end;
            
            begin
           --insert the company function record for the ag_status. The status has been converted to the commission self built type in the select statement
           insert into company_function (company_id_no,company_table_id_no,effective_start_date,effective_end_date,company_table_type_id_no,last_update_datetime,username)
                                 values (ln_company_id_no, 2, x.effective_start_date,'31-JAN-3100', x.ag_status, ld_last_update_date, lv_username); 
            exception
               when dup_val_on_index then
                 null;
            end;
            
            begin
           --insert the company function record for the payment method. The pay method has been converted to the commission self built type in the select statement
           insert into company_function (company_id_no,company_table_id_no,effective_start_date,effective_end_date,company_table_type_id_no,last_update_datetime,username)
                                 values (ln_company_id_no, 5, x.effective_start_date,'31-JAN-3100', x.ag_pay_mode, ld_last_update_date, lv_username); 
            exception
               when dup_val_on_index then
                 null;
            end;
            
            begin
           --insert the company function record for the payment method. The pay method has been converted to the commission self built type in the select statement
           insert into company_function (company_id_no,company_table_id_no,effective_start_date,effective_end_date,company_table_type_id_no,last_update_datetime,username)
                                 values (ln_company_id_no, 6, x.effective_start_date,'31-JAN-3100', decode(x.AG_MULTINAT,'Y',1,2), ld_last_update_date, lv_username); 
            exception
               when dup_val_on_index then
                 null;
            end;
            
            begin
           --insert the company function record for the ag_statement_ind. The statement has been converted to the commission self built type in the select statement
           insert into company_function (company_id_no,company_table_id_no,effective_start_date,effective_end_date,company_table_type_id_no,last_update_datetime,username)
                                 values (ln_company_id_no, 1, x.effective_start_date,'31-JAN-3100', x.ag_stmnt_ind, ld_last_update_date, lv_username); 
            exception
               when dup_val_on_index then
                 null;
            end;                    
         end loop; -- end country loop
         
                   for s in c_address(lv_medware_agent_code)  loop
           --insert postal addresses
             begin
               insert into company_address  (company_id_no,                                            country_code,
                                             address_type_code,                                        effective_start_date,
                                             effective_end_date,                                       address_line1,
                                             address_line2,                                            address_line3,
                                             address_country_code,                                     postal_code,
                                             last_update_datetime,                                     username)
                                      values (ln_company_id_no,                                        trim(s.co_postal_country),
                                              'P',                                                     x.effective_start_date,
                                              x.effective_end_date,                                    trim(s.co_postal_l1),
                                              nvl(trim(s.co_postal_l2),trim(s.co_postal_l3)),          nvl(trim(s.co_postal_town),trim(s.co_postal_l3)),
                                              trim(s.co_postal_country),                               trim(s.co_postal_pcode),
                                              ld_last_update_date,                                     lv_username);
            
             exception
               when dup_val_on_index then
                  dbms_output.put_line('COMPANY POSTAL ADDRESS DUPLICATE: '||ln_company_id_no||','||trim(s.co_postal_country)||',');
                  update company_address
                     set address_line1        = nvl(address_line1         ,trim(s.co_postal_l1)),
                         address_line2        = nvl(address_line2         ,nvl(trim(s.co_postal_l2),trim(s.co_postal_l3))),
                         address_line3        = nvl(address_line3         ,nvl(trim(s.co_postal_town),trim(s.co_postal_l3))),
                         address_country_code = nvl(address_country_code  ,trim(s.co_postal_country)),
                         postal_code          = nvl(postal_code           ,trim(s.co_postal_pcode))
                   where company_id_no = ln_company_id_no
                     and country_code = trim(s.co_postal_country)
                     and address_type_code = 'P';
             end;
             
             --insert street addresses
             begin
               insert into company_address  (company_id_no,                                            country_code,
                                             address_type_code,                                        effective_start_date,
                                             effective_end_date,                                       address_line1,
                                             address_line2,                                            address_line3,
                                             address_country_code,                                     postal_code,
                                             last_update_datetime,                                     username)
                                      values (ln_company_id_no,                                        trim(s.co_street_country),
                                              'S',                                                     x.effective_start_date,
                                              x.effective_end_date,                                    trim(s.co_street_l1),
                                              nvl(trim(s.co_street_l2),trim(s.co_street_l3)),          nvl(trim(s.co_street_town),trim(s.co_street_l3)),
                                              trim(s.co_street_country),                               trim(s.co_street_pcode),
                                              ld_last_update_date,                                     lv_username);
               
             exception
               when dup_val_on_index then
                  dbms_output.put_line('COMPANY STREET ADDRESS DUPLICATE: '||ln_company_id_no||','||trim(s.co_street_country)||',');
                  update company_address
                     set address_line1        = nvl(address_line1         ,trim(s.co_street_l1)),
                         address_line2        = nvl(address_line2         ,nvl(trim(s.co_street_l2),trim(s.co_street_l3))),
                         address_line3        = nvl(address_line3         ,nvl(trim(s.co_street_town),trim(s.co_street_l3))),
                         address_country_code = nvl(address_country_code  ,trim(s.co_street_country)),
                         postal_code          = nvl(postal_code           ,trim(s.co_street_pcode))
                   where company_id_no = ln_company_id_no
                     and country_code = trim(s.co_street_country)
                     and address_type_code = 'S';
             end;
          end loop;
          
         ln_id_no := null;
         lv_passport_code := null;
         
         ln_broker_id_no := ln_company_id_no;
          
         ln_id_no := check_if_number(trim(x.ag_id_no));  --some of the data from medware looks like passport numbers. so check if it's a digit number only, if not, add it as passport no
         
         if ln_id_no is null then
           lv_passport_code := trim(x.ag_id_no);
         end if;
         
		 lv_home_tell     := null;
		 lv_work_tell     := null;
		 lv_cell_no       := null;
		 lv_email_addres  := null;
		 
		 open c_broker_contact(lv_medware_agent_code);
		   fetch c_broker_contact into lv_work_tell, lv_home_tell, lv_cell_no,lv_email_addres ;
		 close c_broker_contact;
		 
         --insert broker record
         insert into broker (broker_id_no, 		     person_title_code, 
                             initials, 				 broker_name, 
                             broker_last_name, 		 passport_code, 
                             language_code, 		 id_no, 
                             sms_notification_ind, 	 email_notification_ind, 
                             company_id_no,
                             business_dev_mgr_name,	 web_password,
							 home_telephone_no,      work_telephone_no,
							 cellphone_no,           email_address,
							 effective_start_date,   effective_end_date,
                             last_update_datetime,	 username)
                     values (ln_broker_id_no,        trim(x.ag_title),
                             trim(x.AG_INITLS),      trim(x.AG_FIRST_NAME),
                             nvl(trim(x.AG_SURNAME),trim(x.last_name)),     lv_passport_code,
                             'EN',                   ln_id_no,
                             'N',                    'N',
                             ln_company_id_no,
                             null,                   trim(x.ag_pin),
							 
							 lv_home_tell,           lv_work_tell,
							 lv_cell_no,             lv_email_addres,
							 x.effective_start_date,'31-JAN-3100',
                             ld_last_update_date,    lv_username);
           
         --insert the broker function record for the type
         insert into broker_function (broker_id_no,broker_table_id_no,effective_start_date,effective_end_date,broker_table_type_id_no,last_update_datetime,username)
                               values (ln_broker_id_no, 1, x.effective_start_date,'31-JAN-3100', 1, ld_last_update_date, lv_username); 
		 		
         --insert the broker function record for the status
         insert into broker_function (broker_id_no,broker_table_id_no,effective_start_date,effective_end_date,broker_table_type_id_no,last_update_datetime,username)
                               values (ln_broker_id_no, 2, x.effective_start_date,'31-JAN-3100', 5, ld_last_update_date, lv_username); 	
                              
       end if;
     
     else  -- x.is_company_record = 'N'. The else means its indivual. Add to broker table 
   
     null;
         
       --check to see if agent code is a valid number. If not, function returns null
       ln_broker_id_no := check_if_number(lv_medware_agent_code); 
       --if null agent code is not a number then a new sequence needs to be fetched.
       if ln_broker_id_no is null then    
         ln_broker_id_no := broker_id_no_seq.nextval;
		 --insert the non numeric agent code and the new matching broker_id_no into temp table for reference
         insert into temp_agent_broker_table values (lv_medware_agent_code,ln_broker_id_no);
       end if;

         ln_id_no := null;
         lv_passport_code := null;

         ln_id_no := check_if_number(trim(x.ag_id_no));  --some of the data from medware looks like passport numbers. so check if it's a digit number only, if not, add it as passport no
         
         if ln_id_no is null then
           lv_passport_code := trim(x.ag_id_no);
         end if;
		 
		 lv_home_tell     := null;
		 lv_work_tell     := null;
		 lv_cell_no       := null;
		 lv_email_addres  := null;
		 
		 open c_broker_contact(lv_medware_agent_code);
		   fetch c_broker_contact into lv_work_tell, lv_home_tell, lv_cell_no,lv_email_addres ;
		 close c_broker_contact;
         
       insert into broker (broker_id_no, 		   person_title_code, 
                           initials, 			   broker_name, 
                           broker_last_name, 	   passport_code, 
                           language_code, 		   id_no, 
                           sms_notification_ind,   email_notification_ind, 
                           business_dev_mgr_name,  web_password,
						   home_telephone_no,      work_telephone_no,
						   cellphone_no,           email_address,
						   effective_start_date,   effective_end_date,
                           last_update_datetime,	 username)
                   values (ln_broker_id_no,        nvl(trim(x.ag_title),'MR'),
                           trim(x.AG_INITLS),      trim(x.ag_code),
                           trim(x.last_name),      lv_passport_code,
                           'EN',                   ln_id_no,
                           'N',                    'N',
                           null,                   trim(x.ag_pin),
						   lv_home_tell,           lv_work_tell,
						   lv_cell_no,             lv_email_addres,	
                           x.effective_start_date,'31-JAN-3100',				   
                           ld_last_update_date,    lv_username);
         
       --insert the broker function record for the type as consultant [type_id_no = 2]
       insert into broker_function (broker_id_no,broker_table_id_no,effective_start_date,effective_end_date,broker_table_type_id_no,last_update_datetime,username)
                            values (ln_broker_id_no, 1, x.effective_start_date,'31-JAN-3100', 2, ld_last_update_date, lv_username); 
			  
       --insert the broker function record for the status active [type_id_no = 5]
       insert into broker_function (broker_id_no,broker_table_id_no,effective_start_date,effective_end_date,broker_table_type_id_no,last_update_datetime,username)
                            values (ln_broker_id_no, 2, x.effective_start_date,'31-JAN-3100', 5, ld_last_update_date, lv_username); 	                            
     end if;  -- if x.IS_COMPANY_RECORD 
    
   end loop;  -- for x in c_agent loop
   
   
for p in c_journal_history loop
     begin
       ln_id_no := check_if_number(trim(p.company_id_no));  
       
	   if ln_id_no is null then
         ln_company_id_no := trim(p.company_id_no);
	   else
	     ln_company_id_no := get_company_id_no(trim(p.company_id_no));
       end if;
	   
	   if ln_company_id_no is not null then
	     ln_invoice_number := invoice_no_seq.nextval;
	     
         insert into invoice (invoice_no,
                              invoice_date,
							  invoice_type_id_no,
                              payment_receive_date,
                              country_code,
                              company_id_no,
                              release_date,
                              payment_date,
                              payment_amt,
                              payment_exch_rate,
                              currency_code,
                              last_update_datetime,
                              username)
         
                       values (ln_invoice_number,
                               p.invoice_date,
							   2,
                               p.contribution_date,
                               p.country_code,
                               ln_company_id_no,
                               p.contribution_date,
                               p.payment_date,
                               p.header_amt*-1,
                               p.exchange_rate,
                               p.currency_code,
                               sysdate,
                               p.username);
	    					 
	      insert into invoice_detail (invoice_no,
                                      fee_type_id_no,
                                      fee_type_amt,
									  fee_type_exch_amt,
                                      fee_type_desc,
                                      last_update_datetime,
                                      username) 
         
                               values (ln_invoice_number,
                                       1,
                                       p.payment_amt*-1
									   p.comms_calculated_excg_amt*-1,
                                       p.fee_desc,
                                       sysdate,
                                       p.username);
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Journal History: '||sqlerrm);
	  end;
   end loop;

for p in c_invoice_history loop
     begin
       ln_id_no := check_if_number(trim(p.company_id_no));  
       
	   if ln_id_no is null then
         ln_company_id_no := trim(p.company_id_no);
	   else
	     ln_company_id_no := get_company_id_no(trim(p.company_id_no));
       end if;
	   
	   if ln_company_id_no is not null then
	     ln_invoice_number := invoice_no_seq.nextval;
	     
         insert into invoice (invoice_no,
                              invoice_date,
							  invoice_type_id_no,
                              payment_receive_date,
                              country_code,
                              company_id_no,
                              release_date,
                              payment_date,
                              payment_amt,
                              payment_exch_rate,
                              currency_code,
                              last_update_datetime,
                              username)
         
                       values (ln_invoice_number,
                               p.invoice_date,
							   1,
                               p.contribution_date,
                               p.country_code,
                               ln_company_id_no,
                               p.contribution_date,
                               p.payment_date,
                               p.header_amt,
                               p.exchange_rate,
                               p.currency_code,
                               sysdate,
                               p.username);
	    					 
	      insert into invoice_detail (invoice_no,
                                      fee_type_id_no,
                                      fee_type_amt,
									  fee_type_exch_amt,
                                      fee_type_desc,
                                      last_update_datetime,
                                      username) 
         
                               values (ln_invoice_number,
                                       1,
                                       p.payment_amt,
									   p.comms_calculated_excg_amt,
                                       p.fee_desc,
                                       sysdate,
                                       p.username);
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Comms Invoice History: '||sqlerrm);
	  end;
   end loop;


   for p in c_invoices_to_be_paid loop
     begin
       ln_id_no := check_if_number(trim(p.company_id_no));  
       
	   if ln_id_no is null then
         ln_company_id_no := trim(p.company_id_no);
	   else
	     ln_company_id_no := get_company_id_no(trim(p.company_id_no));
       end if;
	   
	   if ln_company_id_no is not null then
	     ln_invoice_number := invoice_no_seq.nextval;
	     
         insert into invoice (invoice_no,
                              invoice_date,
							  invoice_type_id_no,
                              payment_receive_date,
                              country_code,
                              company_id_no,
                              last_update_datetime,
                              username)
         
                       values (ln_invoice_number,
                               p.invoice_date,
							   1,
                               p.contribution_date,
                               p.country_code,
                               ln_company_id_no,
                               sysdate,
                               p.username);
	    					 
	      insert into invoice_detail (invoice_no,
                                      fee_type_id_no,
                                      fee_type_amt,
									  fee_type_exch_amt,
                                      fee_type_desc,
                                      last_update_datetime,
                                      username) 
         
                               values (ln_invoice_number,
                                       1,
                                       p.payment_amt,
									   p.comms_calculated_excg_amt,
                                       p.fee_desc,
                                       sysdate,
                                       p.username);
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Comms Invoice To Be Paid: '||sqlerrm);
	  end;
   end loop;  
  
   for x in c_comms_history loop
     begin
	   
	   insert into comms_calc_snapshot 
                 (country_code,
                  product_code,
                  poep_id,
                  person_code,
                  policy_code,
                  group_code,
                  broker_id_no,
                  company_id_no,
                  comms_perc,
                  contribution_date,
                  payment_receive_date,
                  finance_receipt_no,
                  calculation_datetime,
                  comms_calc_type_code,
                  payment_receive_amt,
                  comms_calculated_amt,
                  exchange_rate,
                  exchange_rate_currency_code,
                  comms_calculated_exch_amt,
                  invoice_no,
                  last_update_datetime,
                  username)
          values (x.country_code,
								  x.product_code,
									NVL(CASE WHEN isvalid_person_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_person => X.PERSON_CODE)
                           WHEN isvalid_policy_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_policy => X.PERSON_CODE)
                      END, 0),
									x.person_code,
									x.person_code,
									x.group_code,
									x.broker_id_no,
									x.broker_id_no,
									x.comms_perc,
									x.contribution_date,
									x.contribution_date,
									0,
									x.calculation_datetime,
									'P',
									x.payment_receive_amt,
									x.comms_calculated_amt,
									exch_rate,
									x.cur_key,
									x.comms_calculated_exc_amt,
									0,
									sysdate,
									'Medware');
						 
	 exception
	   when others then 
	   dbms_output.put_line('Error with Comms Invoice To Be Paid: '||sqlerrm);
	 end;
   end loop;
 
 ln_id_no := null;
 ln_company_id_no := null;
 
 for a in c_brokers_notes loop
     begin
       ln_id_no := check_if_number(trim(a.company_id_no));  
       
	   if ln_id_no is null then
         ln_company_id_no := trim(a.company_id_no);
	   else
	     ln_company_id_no := get_company_id_no(trim(a.company_id_no));
       end if;
	   
	   if ln_company_id_no is not null then
          insert into company_comments (company_id_no,
                                        comment_datetime,
                                        comment_desc,
                                        last_update_datetime,
                                        username)

                               values (ln_company_id_no,
							           a.datetime,
									   a.comment_desc,
									   sysdate,
									   a.username);
       else
	     dbms_output.put_line('Company '||a.company_id_no||' could not be found.');
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Company Notes: '||sqlerrm);
	  end;
   end loop; 
   -- Load all the OHI Policies data
   OHI_POLICIES_LOAD_PKG.POPULATE_ALL (true);
      
    dbms_output.put_line('end');
exception 
  when others then
    dbms_output.put_line('Error with company '||ln_company_id_no||', '||sqlerrm);
end;
