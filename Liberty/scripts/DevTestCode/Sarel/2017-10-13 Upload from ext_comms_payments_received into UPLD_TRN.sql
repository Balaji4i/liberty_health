-- Upload from ext_comms_payments_received into UPLD_TRN - Run as UTIL
DECLARE
lv_sys_param_date              varchar2(50) := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
ln_interf_system_id_no         number(2)    := 1;
ln_interf_system_trn_type_no   number(2)    := 2;

cursor c_receipts is
  select rpad(application_id,100,' ')|| 
         rpad(finance_receipt_no,100,' ')|| 
         rpad(group_code,100,' ')|| 
         rpad(country_code,4,' ')||
         rpad(product_code,100,' ')|| 
         rpad(policy_code,100,' ')|| 
         rpad(person_code,100,' ')|| 
         rpad(contribution_date,10,' ')||
         rpad(finance_receipt_date ,10 ,' ')||
         rpad(finance_invoice_no,100,' ')|| 
         rpad(finance_invoice_date, 10,' ')||
         rpad(finance_receipt_amt,100,' ') dataline,
         finance_receipt_date
    from ext_comms_payments_received;
BEGIN
   for x in c_receipts loop
   
     insert into util.upld_trn (upld_trn_no,
                           detail_seq_no,
                           interf_system_id_no,
                           trn_type_no,
                           trn_sub_type_code,
                           process_datetime,
                           trn_datetime,
                           upld_trn_date,
                           dataline,
                           error_desc,
                           last_update_datetime,
                           username)

                    values (UTIL.UPLD_TRN_SEQ_NO.nextval,
                            1,
                            ln_interf_system_id_no,
                            ln_interf_system_trn_type_no,
                            'N',
                            to_date(lv_sys_param_date),
                            x.finance_receipt_date,
							              sysdate,
                            x.dataline,
                            null,
                            sysdate,
                            user);
   end loop;
   
   commit;
   
EXCEPTION
   when dup_val_on_index then
     dbms_output.put_line('error');
END;