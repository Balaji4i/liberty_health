declare
ln_curr_no     company.company_id_no%type;
ln_max_no      company.company_id_no%type;
ln_new_no      number(9);

Cursor c_broker_table is
  select broker_table_id_no_seq.nextval
    from broker_Table;
    
Cursor c_broker_table_type is
  select broker_table_Type_id_no_seq.nextval
    from broker_Table_type;
    
Cursor c_company_contact_type is
  select COMPANY_CONTACT_TYPE_ID_NO_SEQ.nextval
    from company_contact_type;
  
cursor c_company_table_type is
   select COMPANY_TABLE_TYPE_ID_NO_SEQ.nextval
     from company_table_type
   where rownum < 3;

begin
  
  for x in c_broker_table loop
    null;
  end loop;
  
  for x in c_broker_table_type loop
    null;
  end loop;
  
  for x in c_company_contact_type loop
    null;
  end loop;
  
  for x in c_company_table_type loop
    null;
  end loop;

  --set company_id_no sequence
  ln_max_no  := 0;
  ln_curr_no := 0;
  ln_new_no  := 0;
 
  SELECT MAX(company_id_no) INTO ln_max_no FROM company;
  ln_curr_no := company_id_no_seq.NEXTVAL;
  ln_new_no := (ln_max_no-ln_curr_no);
  EXECUTE IMMEDIATE 'ALTER SEQUENCE lhhcom.company_id_no_seq INCREMENT BY ' || ln_new_no;
  ln_curr_no := company_id_no_seq.NEXTVAL;
  EXECUTE IMMEDIATE 'ALTER SEQUENCE lhhcom.company_id_no_seq INCREMENT BY 1';
  dbms_output.put_line('Current Company val:'||ln_curr_no);
 
  --set broker sequence 
  ln_max_no  := 0;
  ln_curr_no := 0;
  ln_new_no  := 0;

  SELECT MAX(broker_id_no) INTO ln_max_no FROM broker;
  ln_curr_no := broker_id_no_seq.NEXTVAL;
  ln_new_no := (ln_max_no-ln_curr_no);
  EXECUTE IMMEDIATE 'ALTER SEQUENCE lhhcom.broker_id_no_seq INCREMENT BY ' || ln_new_no;
  ln_curr_no := broker_id_no_seq.NEXTVAL;
  EXECUTE IMMEDIATE 'ALTER SEQUENCE lhhcom.broker_id_no_seq INCREMENT BY 1';
  dbms_output.put_line('Current Broker val:'||ln_curr_no);
  
end;
