create or replace function get_comm_hub_template_name (pv_template_code in varchar2) return varchar2 is
 v_varchar varchar2(250);
begin
 select comm_hub_template_type_desc
   into v_varchar
   from Comm_Hub_Template_Type
  where Comm_Hub_Template_Type_Code = pv_template_code;
  
  return v_varchar;
  
 exception
   when others then
   return null;
end;
