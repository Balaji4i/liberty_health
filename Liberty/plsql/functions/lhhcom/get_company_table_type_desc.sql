create or replace function get_company_table_type_desc (pn_company_table_type_id_no in number) return varchar2 is
 v_varchar varchar2(250);
begin
 begin
   select company_table_type_desc into v_varchar from company_table_type
   where company_table_type_id_no = pn_company_table_type_id_no;  
 
 exception
   when invalid_number then
   return null;
 end;
 return v_varchar;
end;