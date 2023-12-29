/**
* ----------------------------------------------------------------------
* Change Request: Uganda Data Migration - COMM_HIST (LS-1519)
*
* Description  : Migrate Commission history from Medware
* Author       : Sarel Eybers
* Date         : 2018-07-06
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Load Journal History
*   2) Load Invoice History
*   3) Load Invoices to Be Paid
*   4) Load Commissions History
*                                                                         */

/* Sample Code
select get_System_parameter('LB_HEALTH_COMMS','SYSTEM','MEDWARE_LINK') from dual;
delete from comms_calc_snapshot where trunc(last_update_datetime) = trunc(SYSDATE) and username = 'Medware';
*/

SET SERVEROUTPUT ON;
define p_db_link = MEDWARE_PROD.LIBERTY.CO.ZA;
define p_upd_ccs = false;
define p_upd_inv_jnl = false;
define p_upd_inv_his = false;
define p_upd_unp_inv = true;
/
declare

lv_medware_agent_code    varchar2(100);
ln_company_id_no         company.company_id_no%type;
ln_broker_id_no          broker.broker_id_no%type;
lv_username              varchar2(100) := 'Medware';
lv_db_link               varchar2(200) := get_System_parameter('LB_HEALTH_COMMS','SYSTEM','MEDWARE_LINK');
ld_last_update_date      date := sysdate;
ln_exist_number          company.company_id_no%type;
lv_contact_exist         char(1);
lv_country_code          varchar2(5) := 'UG';
ln_contact_type_id_no    company_contact.company_contact_type_id_no%type;
lv_passport_code         broker.passport_code%type;
ln_id_no                 broker.id_no%type;
lv_home_tell             broker.HOME_TELEPHONE_NO%type;
lv_work_tell             broker.WORK_TELEPHONE_NO%type;
lv_cell_no               broker.CELLPHONE_NO%type;
lv_email_addres          broker.EMAIL_ADDRESS%type;
ln_invoice_number        invoice.invoice_no%type;

cursor c_comms_history is
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
  where  floor(months_between(sysdate, to_date(trim(sa_dt_subs),'yyyy-mm-dd'))) <= 24
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
          ,to_date(trim(cm_dt_run),'yyyy-mm-dd');

cursor c_journal_history is
  select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
         to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
         trim(co_street_country) country_code,
         trim(ag_code) company_id_no,
         case when cm_dt_pay > 0 THEN to_date(trim(cm_dt_pay),'yyyy-mm-dd')
              else null end as payment_date,
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
     and trim(cm_rectr_type) = 'JNL'
     and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(s_scheme,0,1) not in ('A','O','U')
     and trim(co_street_country) = 'UG'
     and floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
   group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            trim(co_street_country) ,
            trim(ag_code) ,
            cm_dt_pay,
            trim(cur_key) ,
            trim(cm_narration) ,
            trim(u_user)
  having     sum(to_number(trim(cm_conv_amt_excl))) = 0
         AND sum(to_number(trim(cm_amt_excl_vat))) <> 0
  order by 4, 5;

cursor c_invoice_history is
  select to_date(trim(ad_dt_stamp),'yyyy-mm-dd') invoice_date,
         to_date(trim(ad_dt_stamp),'yyyy-mm-dd') contribution_date,
         trim(co_street_country) country_code,
         trim(ag_code) company_id_no,
         case when cm_dt_pay > 0 THEN to_date(trim(cm_dt_pay),'yyyy-mm-dd')
              else null end as payment_date,
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
     and trim(cm_rectr_type) = 'PAYM'
     and trim(s_scheme) in ('IBUG', 'LBLU')     -- LS in ('LHLS')--not in ('BMIR','IMED','ESMA','HERI','CFC')
     and substr(s_scheme,0,1) not in ('A','O','U')
     and trim(co_street_country) = 'UG'
     and floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
   group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            trim(co_street_country) ,
            trim(ag_code) ,
            cm_dt_pay,
            trim(cur_key) ,
            trim(cm_narration) ,
            trim(u_user)
  having     sum(to_number(trim(cm_conv_amt_excl))) = 0
         AND sum(to_number(trim(cm_amt_excl_vat))) <> 0
  order by 4, 5;
	
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
    from saghist@&&p_db_link com,
         contacts@&&p_db_link c
   where 'SC'||trim(com.s_scheme) = trim(c.k_common_key)
      and trim(cm_rectr_type) <> 'RUN'
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
  having     sum(to_number(trim(cm_conv_amt_excl))) <> 0
         OR  sum(to_number(trim(cm_amt_excl_vat))) <> 0
  order by 4, 1;
	
begin
   
-- COMMS_CALC_SNAPSHOT
  dbms_output.put_line('COMMS_CALC_SNAPSHOT - Update? (&&p_upd_ccs)');
  for x in c_comms_history loop
     begin
       IF &&p_upd_ccs = true then
    	   insert into comms_calc_snapshot 
                   (comms_calc_snapshot_no,
                    country_code,
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
                    payment_currency,
                    comms_calculated_amt,
                    exchange_rate,
                    exchange_rate_currency_code,
                    comms_calculated_exch_amt,
                    invoice_no,
                    last_update_datetime,
                    username)
            values (comms_calc_snapshot_seq.nextval,
                    x.country_code,
		  						  x.product_code,
		  							NVL(CASE WHEN isvalid_person_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_person => X.PERSON_CODE)
                             WHEN isvalid_policy_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_policy => X.PERSON_CODE)
                        END, 0),
			  						x.person_code,
			  						x.policy_code,
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
                    x.base_cur,
			  						x.comms_calculated_amt,
			  						x.exch_rate,
			  						x.cur_key,
			  						x.comms_calculated_exc_amt,
			  						0,
			  						sysdate,
			  						'Medware');
       END IF;
						 
	   exception
	     when others then 
	       dbms_output.put_line('Error with COMMS_CALC_SNAPSHOT: '|| sqlerrm);
	       dbms_output.put_line('   Detail: Person(' || x.person_code || '), Date (' || x.contribution_date || ') and Amount (' || x.payment_receive_amt || ')');
	   end;
   end loop;

-- INVOICE - Journal History
  dbms_output.put_line('INVOICE - Journal History - Update? (&&p_upd_inv_jnl)');
  for p in c_journal_history loop
    begin
      ln_id_no := check_if_number(trim(p.company_id_no));  
      if ln_id_no is null then
        ln_company_id_no := trim(p.company_id_no);
	    else
	      ln_company_id_no := get_company_id_no(trim(p.company_id_no));
      end if;
	    if ln_company_id_no is not null then
        dbms_output.put_line(' Insert Invoice with Date (' || p.invoice_date || '), Company (' || ln_company_id_no || ') and Amount (' || p.payment_amt || ' ' || p.currency_code || ')');
        IF &&p_upd_inv_jnl = true then
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
                                      p.payment_amt*-1,
				  					                  p.comms_calculated_excg_amt*-1,
                                      p.fee_desc,
                                      sysdate,
                                      p.username);
        end if;
      end if;
	  exception
	    when others then 
		    dbms_output.put_line('Error with Journal History: '||sqlerrm);
        dbms_output.put_line('   Detail: Invoice(' || ln_invoice_number || '), Date (' || p.invoice_date || ') and Amount (' || p.payment_amt || ')');
	  end;
  end loop;

-- INVOICE - Invoice History
  dbms_output.put_line('INVOICE - Invoice History - Update? (&&p_upd_inv_his)');
  for p in c_invoice_history loop
    begin
      ln_id_no := check_if_number(trim(p.company_id_no));  
 	    if ln_id_no is null then
        ln_company_id_no := trim(p.company_id_no);
	    else
	      ln_company_id_no := get_company_id_no(trim(p.company_id_no));
      end if;
 	    if ln_company_id_no is not null then
        dbms_output.put_line(' Insert Invoice with Date (' || p.invoice_date || '), Company (' || ln_company_id_no || ') and Amount (' || p.payment_amt || ' ' || p.currency_code || ')');
        IF &&p_upd_inv_his = true then
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
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Comms Invoice History: '||sqlerrm);
       dbms_output.put_line('   Detail: Invoice(' || ln_invoice_number || '), Date (' || p.invoice_date || ') and Amount (' || p.payment_amt || ')');
	  end;
   end loop;

-- INVOICE - Unpaid Invoices
  dbms_output.put_line('INVOICE - Unpaid Invoices - Update? (&&p_upd_unp_inv)');
   for p in c_invoices_to_be_paid loop
     begin
       ln_id_no := check_if_number(trim(p.company_id_no));  
       
	   if ln_id_no is null then
         ln_company_id_no := trim(p.company_id_no);
	   else
	     ln_company_id_no := get_company_id_no(trim(p.company_id_no));
       end if;
	   
	   if ln_company_id_no is not null then
        dbms_output.put_line(' Insert Invoice with Date (' || p.invoice_date || '), Company (' || ln_company_id_no || ') and Amount (' || p.payment_amt || ' ' || p.currency_code || ')');
        IF &&p_upd_unp_inv = true then
   	      ln_invoice_number := invoice_no_seq.nextval;
          insert into invoice (invoice_no,
                               invoice_date,
	 						                 invoice_type_id_no,
                               payment_receive_date,
                               country_code,
                               company_id_no,
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
       end if;
	  exception
	    when others then 
		   dbms_output.put_line('Error with Comms Invoice To Be Paid: '||sqlerrm);
       dbms_output.put_line('   Detail: Invoice(' || ln_invoice_number || '), Date (' || p.invoice_date || ') and Amount (' || p.payment_amt || ')');
	  end;
   end loop;  

exception 
  when others then
    dbms_output.put_line('General Error: ' || sqlerrm);
end;

/