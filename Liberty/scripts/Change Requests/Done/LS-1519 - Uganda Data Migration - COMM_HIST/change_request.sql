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
define p_upd_ccs = FALSE;
define p_upd_inv_jnl = FALSE;
define p_upd_inv_his = FALSE;
define p_upd_unp_inv = FALSE;

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
  ccs                      comms_calc_snapshot%ROWTYPE;
  cct                      comms_calc_trace%ROWTYPE;

CURSOR c_comms_history IS
  SELECT 
         country_code
        ,product_code
        ,person_code
        ,policy_code
        ,group_code
        ,broker_id_no
        ,contribution_date
        ,calculation_datetime
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
           WHERE     (    floor(months_between(sysdate, to_date(trim(cm_dt_run),'yyyy-mm-dd'))) <= 24
                      OR  cm_dt_pay = 0)
--           WHERE     (    cm_dt_run >= 20160901 
--                      OR  cm_dt_pay = 0)
                 AND cm_post_status = 'P'
                 AND trim(com.s_scheme) in ('IBUG', 'LBLU')
                 AND substr(com.s_scheme,0,1) not in ('A','O','U')
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
           ,base_cur
           ,cur_key;

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
     and (    floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
          or trim(cm_dt_pay) = 0)
   group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            trim(co_street_country) ,
            trim(ag_code) ,
            cm_dt_pay,
            trim(cur_key) ,
            trim(cm_narration) ,
            trim(u_user)
  having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
         OR sum(to_number(trim(cm_amt_excl_vat))) <> 0
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
     and (    floor(months_between(sysdate, to_date(trim(ad_dt_stamp),'yyyy-mm-dd'))) <= 24
          or trim(cm_dt_pay) = 0)
   group by to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            to_date(trim(ad_dt_stamp),'yyyy-mm-dd') ,
            trim(co_street_country) ,
            trim(ag_code) ,
            cm_dt_pay,
            trim(cur_key) ,
            trim(cm_narration) ,
            trim(u_user)
  having    sum(to_number(trim(cm_conv_amt_excl))) <> 0
         OR sum(to_number(trim(cm_amt_excl_vat))) <> 0
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
	
begin
   
-- COMMS_CALC_SNAPSHOT
  dbms_output.put_line('COMMS_CALC_SNAPSHOT - Update? (&&p_upd_ccs)');
  for x in c_comms_history loop
    BEGIN
      dbms_output.put_line(' Insert CCS for Person ' || x.person_code || ' with Dates (' || x.contribution_date || '/' || x.calculation_datetime || '), Company (' || x.broker_id_no || ') and Amount (' || x.payment_receive_amt || ' ' || x.base_cur || ')');
      IF &&p_upd_ccs = TRUE THEN
        BEGIN
          ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.nextval;
          ccs.country_code                := x.country_code;
          ccs.product_code                := x.product_code;
          ccs.poep_id                     := NVL(CASE WHEN isvalid_person_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_person => X.PERSON_CODE)
                                                      WHEN isvalid_policy_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_policy => X.PERSON_CODE)
                                                  END, 0);
          ccs.person_code                 := x.person_code;
          ccs.policy_code                 := x.policy_code;
          ccs.group_code                  := x.group_code;
          ccs.broker_id_no                := x.broker_id_no;
          ccs.company_id_no               := x.broker_id_no;
          ccs.comms_perc                  := x.comms_perc;
          ccs.contribution_date           := x.contribution_date;
          ccs.payment_receive_date        := x.contribution_date;
          ccs.finance_receipt_no          := 0;
          ccs.calculation_datetime        := x.calculation_datetime;
          ccs.comms_calc_type_code        := 'P';
          ccs.payment_receive_amt         := x.payment_receive_amt;
          ccs.payment_currency            := x.base_cur;
          ccs.comms_calculated_amt        := x.comms_calculated_amt;
          ccs.exchange_rate               := x.exch_rate;
          ccs.exchange_rate_currency_code := x.cur_key;
          ccs.comms_calculated_exch_amt   := x.comms_calculated_exc_amt;
          ccs.invoice_no                  := 0;
          ccs.last_update_datetime        := SYSDATE;
          ccs.username                    := 'Medware';
     	    INSERT INTO comms_calc_snapshot VALUES ccs;
          cct.comms_calc_snapshot_no := ccs.comms_calc_snapshot_no;
          INSERT INTO comms_calc_trace    VALUES cct;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            UPDATE comms_calc_snapshot 
              SET payment_receive_amt       = payment_receive_amt+x.payment_receive_amt,
                  comms_calculated_amt      = comms_calculated_amt+x.comms_calculated_amt,
                  comms_calculated_exch_amt = comms_calculated_exch_amt+x.comms_calculated_exc_amt,
	                last_update_datetime      = SYSDATE,
                  username                  = 'Medware'
            WHERE country_code                = x.country_code
              AND product_code                = x.product_code
              AND poep_id                     = NVL(CASE WHEN isvalid_person_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_person => X.PERSON_CODE)
                                                         WHEN isvalid_policy_code(X.PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => x.CONTRIBUTION_DATE, p_policy => X.PERSON_CODE)
                                                     END, 0)
              AND person_code                 = x.person_code
              AND policy_code                 = x.policy_code
              AND group_code                  = x.group_code
              AND broker_id_no                = x.broker_id_no
              AND company_id_no               = x.broker_id_no
              AND contribution_date           = x.contribution_date
              AND payment_receive_date        = x.contribution_date
              AND finance_receipt_no          = 0
              AND calculation_datetime        = x.calculation_datetime
              AND comms_calc_type_code        = 'P'
              AND payment_currency            = x.base_cur
              AND exchange_rate_currency_code = x.cur_key;   
          dbms_output.put_line(' Duplicate CCS for Person ' || x.person_code || ' with Date (' || x.contribution_date || '), Company (' || x.broker_id_no || ') and Amount (' || x.payment_receive_amt || ' ' || x.base_cur || ')');
        END;
      END IF;
	  EXCEPTION
	    WHEN OTHERS THEN
        dbms_output.put_line('Error with COMMS_CALC_SNAPSHOT: '|| sqlerrm);
        dbms_output.put_line('   Detail: Person(' || x.person_code || '), Date (' || x.contribution_date || ') and Amount (' || x.payment_receive_amt || ')');
    END;
  END LOOP;

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
        dbms_output.put_line(' Insert Invoice with Date (' || p.invoice_date || '), Company (' || ln_company_id_no || ') and Amount (' || p.payment_amt || ' ' || p.currency_code || ' * -1)');
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
		  							           CASE WHEN p.payment_date IS NULL THEN NULL
                                    ELSE p.contribution_date
                               END,
                               p.payment_date,
		  							           CASE WHEN p.payment_date IS NULL THEN NULL
                                    ELSE p.header_amt * -1
                               END,
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
                                      CASE WHEN p.payment_date IS NULL THEN p.payment_amt
                                           ELSE p.payment_amt * -1,
                                      CASE WHEN p.payment_date IS NULL THEN p.comms_calculated_excg_amt
                                           ELSE p.comms_calculated_excg_amt * -1,
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
        dbms_output.put_line(' Insert Invoice with Date (' || p.invoice_date || '), Company (' || ln_company_id_no || ') and Amount (' || p.payment_amt || ' ' || p.currency_code || ' * -1)');
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
		  							           CASE WHEN p.payment_date IS NULL THEN NULL
                                    ELSE p.contribution_date
                               END,
                               p.payment_date,
		  							           CASE WHEN p.payment_date IS NULL THEN NULL
                                    ELSE p.header_amt * -1
                               END,
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