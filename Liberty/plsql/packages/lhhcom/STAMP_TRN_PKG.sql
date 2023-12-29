CREATE OR REPLACE PACKAGE "LHHCOM"."STAMP_TRN_PKG" AS 
/*****************************************************************************************************************
Description  : Package contains procedures to generate datalines for interfaces 
Author       : Jaco Bosman
Requirements : 
Amendments   : 
Date       User     Change Description
========   ======== =================================================
18/04/10   Sarel    Removed References to old DNLD_BROKER

*******************************************************************************************************************/

procedure insert_dnld_trn (pn_interf_system_id_no in number, pn_detail_seq_no in number, pn_batch_no in number, pn_trn_type_no in number, pn_trn_sub_type_code in char, pn_dataline in varchar2, pn_username in varchar2);
-- procedure stamp_dnld_broker (pn_batch_no in number);
procedure stamp_dnld_company_address (pn_batch_no in number);
procedure stamp_dnld_company_contact (pn_batch_no in number);              
procedure stamp_all;
END STAMP_TRN_PKG;
/


CREATE OR REPLACE PACKAGE BODY          "STAMP_TRN_PKG" AS

/**********************************************************************************************************************************/
procedure insert_dnld_trn (pn_interf_system_id_no in number, pn_detail_seq_no in number, pn_batch_no in number, pn_trn_type_no in number, pn_trn_sub_type_code in char, pn_dataline in varchar2, pn_username in varchar2) as

ln_dnld_trn_no            dnld_trn.dnld_trn_no%type;

begin
  ln_dnld_trn_no := dnld_trn_seq_no.nextval;
  
  insert into dnld_trn (interf_system_id_no,dnld_trn_no,detail_seq_no,batch_no,trn_type_no,trn_sub_type_code,dataline,last_update_datetime,username)
	            values (pn_interf_system_id_no,ln_dnld_trn_no,pn_detail_seq_no,pn_batch_no,pn_trn_type_no,pn_trn_sub_type_code,pn_dataline,sysdate,pn_username);
 
exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
/**********************************************************************************************************************************/
/*
procedure stamp_dnld_broker (pn_batch_no in number) as

lv_username               dnld_broker.username%type              := 'dnld_broker';
ld_stamp_datetime         dnld_broker.stamp_datetime%type;
ln_broker_id_no           dnld_broker.broker_id_no%type;
ln_detail_no_no           dnld_trn.detail_seq_no%type;

cursor c_get_dnld_brokers is
  select broker_id_no, stamp_ind, max(stamp_datetime) stamp_date_time
    from dnld_broker
   where batch_no = pn_batch_no
   group by broker_id_no, stamp_ind;
   
cursor c_dnld_brokers_data is
  select rownum,
         case
            when stamp_ind = 'I' then 'CREATE'
         else
           'UPDATE'
         end||','||                                       --import_action
         b.broker_name||','||                             -- supplier_name
         null||','||                                      -- supplier_name_new
         b.broker_id_no||','||                            -- supplier_number
         c.company_name||','||                            -- alternate_name
         null||','||                                      -- tax_org_type,
         b_type.broker_table_type_desc||','||             -- supplier_type,
         null||','||                                      -- inactive_date,
         null||','||                                      -- business_relationship,
         null||','||                                      -- parent_supplier,
         null||','||                                      -- parent_alias,
         null||','||                                      -- duns_number,
         'N'||','||                                       -- one_time_supplier,
         null||','||                                      -- customer_number,
         null||','||                                      -- sic, 
         null||','||                                      -- ni_number,
         null||','||                                      -- corp_web_site,
         null||','||                                      -- chief_exec_title,
         null||','||                                      -- chief_exec_name,
         'N'||','||                                       -- bus_class_not_applicable,
         cc.country_code||','||                           -- tax_payer_country,
         comp_reg.reg_no||','||                           -- taxpayer_id_no,
         null||','||                                      -- fed_reportable,
         null||','||                                      -- fed_income_tax_type,
         null||','||                                      -- state_reportable,
         null||','||                                      -- tax_report_name,
         null||','||                                      -- name_control,
         null||','||                                      -- tax_verify_date,
      --   cc.WHT_CERT_IND||','||                           -- use_wht,
         null||','||                                      -- wht_group,
         comp_reg.vat_no||','||                           -- vat_code,
         comp_reg.reg_no||','||                           -- taxpayer_reg_no,
         null||','||                                      -- auto_tax_calc_ovrd,
         null||','||                                      -- payment_method,
         null||','||                                      -- delivery_channel,
         null||','||                                      -- bank_instrc_1,
         null||','||                                      -- bank_instrc_2,
         null||','||                                      -- bank_instrc,
         null||','||                                      -- settle_priority,
         null||','||                                      -- pay_text_msg_1,
         null||','||                                      -- pay_text_msg_2,
         null||','||                                      -- pay_text_msg_3,
         null||','||                                      -- bank_charge_bearer,
         null||','||                                      -- payment_reason,
         null||','||                                      -- payment_reason_comment,
         null dataline                                     -- pay_format       
  from dnld_broker db, broker b, company c, company_country cc,
       (select fb.broker_id_no, broker_table_type_desc
          from broker_function fb, broker_table_type bt
         where fb.broker_table_id_no = 3
           and fb.broker_table_id_no = bt.broker_table_id_no
           and fb.broker_table_type_id_no = bt.broker_table_type_id_no
           and trunc(ld_stamp_datetime) between fb.effective_start_date and fb.effective_end_date) b_type,
        (select company_id_no, country_code, vat_no, reg_no, fais_no
           from company_reg
          where trunc(ld_stamp_datetime) between effective_start_date and effective_end_date) comp_reg
  where db.broker_id_no = ln_broker_id_no
     and db.broker_id_no = b.broker_id_no
     and b.company_id_no = c.company_id_no
     and c.company_id_no = cc.company_id_no
     and b.broker_id_no = b_type.broker_id_no(+)
     and cc.company_id_no = comp_reg.company_id_no(+)
     and cc.country_code = comp_reg.country_code(+);   

begin

   update dnld_broker
      set batch_no = pn_batch_no,
	      last_update_datetime = sysdate,
		  username = lv_username
	where batch_no = 0;

	
	for x in c_get_dnld_brokers loop
	  ln_broker_id_no := x.broker_id_no;
	  ld_stamp_datetime := x.stamp_date_time;
	  
	  for y in c_dnld_brokers_data loop
        ln_detail_no_no := y.rownum;      
	    insert_dnld_trn(1,ln_detail_no_no,pn_batch_no,1,'D',y.dataline,lv_username);
	  end loop;
	end loop;
	
	commit;

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
*/
/**********************************************************************************************************************************/

procedure stamp_dnld_company_address (pn_batch_no in number) as

lv_username               dnld_company.username%type      := 'dnld_comp_address';
ln_detail_no_no           dnld_trn.detail_seq_no%type;

  
cursor c_dnld_company_address_data is
select rownum,
         case
            when stamp_ind = 'I' then 'CREATE'
         else
           'UPDATE'
         end||','||                                  -- import_action,
         c.company_name||','||                       -- supplier_name,
         at.address_type_desc||','||                 -- address_name,
         ca.address_country_code||','||              -- country,
         ca.address_line1||','||                     -- address_line1,
         ca.address_line3||','||                     -- city,
         null||','||                                 -- state,
         postal_code||','||                          -- postal_code,
         null||','||                                 -- phone_country_code,
         null||','||                                 -- phone,
         null||','||                                 -- rqf_binding,
         null||','||                                 -- ordering,
         null||','||                                 -- pay,
         null dataline                               -- email
from dnld_company_address dca,
     company_address ca,
     company c,
     address_type at
where batch_no = pn_batch_no
  and dca.company_id_no = ca.company_id_no
  and dca.country_code = ca.country_code
  and dca.address_type_code = ca.address_type_code
  and dca.effective_start_date = ca.effective_start_date
  and dca.company_id_no = c.company_id_no
  and dca.address_type_code = at.address_type_code;  

begin

   update dnld_company_address
      set batch_no = pn_batch_no,
	        last_update_datetime = sysdate,
		      username = lv_username
	  where batch_no = 0;


	  for x in c_dnld_company_address_data loop       
        ln_detail_no_no := x.rownum;      
	    insert_dnld_trn(1,ln_detail_no_no,pn_batch_no,5,'D',x.dataline,lv_username);
	  end loop;
	
	commit;

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
/**********************************************************************************************************************************/
procedure stamp_dnld_company_contact (pn_batch_no in number) as

lv_username               dnld_company.username%type      := 'dnld_comp_contact';
ln_detail_no_no           dnld_trn.detail_seq_no%type;
   
cursor c_dnld_company_contact_data is
  select rownum,
           case
              when stamp_ind = 'I' then 'CREATE'
           else
             'UPDATE'
           end||','||                                     -- import_action,
           c.company_name||','||                          -- supplier_name,
           ca.contact_name||','||                         -- first_name,
           null||','||                                    -- last_name,
           at.company_contact_type_desc||','||            -- job_title,
           null||','||                                    -- admin_contact,
           contact_email||','||                           -- email,
           null||','||                                    -- phone_country_code,
           null||','||                                    -- phone_area_code,
           CONTACT_TELEPHONE_NO||','||                    -- phone,
           null||','||                                    -- mobile_country_code,
           null||','||                                    -- mobile_area_code,
           CONTACT_CELLPHONE_NO dataline                   -- mobile
  from dnld_company_contact dca,
       company_contact ca,
       company c,
       company_contact_type at
  where batch_no = pn_batch_no
    and dca.company_id_no = ca.company_id_no
    and dca.country_code = ca.country_code
    and dca.company_contact_type_id_no = ca.company_contact_type_id_no
    and dca.effective_start_date = ca.effective_start_date
    and dca.company_id_no = c.company_id_no
    and dca.company_contact_type_id_no = at.company_contact_type_id_no;   

begin

   update dnld_company_contact
      set batch_no = pn_batch_no,
	        last_update_datetime = sysdate,
		      username = lv_username
	  where batch_no = 0;

	  for x in c_dnld_company_contact_data loop
        ln_detail_no_no := x.rownum;    
	    insert_dnld_trn (1,ln_detail_no_no,pn_batch_no,4,'D',x.dataline,lv_username);
	  end loop;
	
	commit;

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
/**********************************************************************************************************************************/
procedure stamp_all is

ln_batch_no        dnld_batch.batch_no%type      := dnld_batch_no_seq.nextval;
lv_username        dnld_batch.username%type      := 'stamp_all';

  cursor c_batch_no is
    select max(batch_no)
      from util.dnld_batch
     where process_datetime is null;
     
begin
  
  open c_batch_no;
    fetch c_batch_no into ln_batch_no;
  close c_batch_no;
  
  if ln_batch_no is null then
	  insert into util.dnld_batch (batch_no, process_datetime, last_update_datetime, username) values (ln_batch_no, null, sysdate,lv_username);
  end if;
 
  commit;

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
/**********************************************************************************************************************************/
END STAMP_TRN_PKG;
/
