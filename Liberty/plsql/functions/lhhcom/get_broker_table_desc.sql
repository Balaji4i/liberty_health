create or replace function get_broker_table_desc (pn_broker_table_id_no in number) return varchar2 is
 v_varchar varchar2(250);
 begin
   select broker_table_desc into v_varchar from broker_table
   where broker_table_id_no = pn_broker_table_id_no;  
 
  return v_varchar;
  
 exception
   when invalid_number then
   return null;
 end;
