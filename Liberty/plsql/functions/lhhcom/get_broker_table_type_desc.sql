create or replace function get_broker_table_type_desc (pn_broker_table_type_id_no in number) return varchar2 is
 v_varchar varchar2(250);

 begin
   select broker_table_type_desc into v_varchar from broker_table_type
   where broker_table_type_id_no = pn_broker_table_type_id_no;  
 
  return v_varchar;
  
 exception
   when invalid_number then
   return null;
 end;
