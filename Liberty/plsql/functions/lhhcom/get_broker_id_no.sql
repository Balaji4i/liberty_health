create or replace function get_broker_id_no(p_string in varchar2) return number is
 v_num number;
begin
 begin
   select company_id_no into v_num from TEMP_AGENT_BROKER_TABLE
   where trim(ag_code) = trim(p_string);   
 exception
   when invalid_number then
   return null;
 end;
 return v_num;
 exception  
    when others then
	  return null;
end;