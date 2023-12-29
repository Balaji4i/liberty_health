create or replace function check_if_number(p_string in varchar2) return number is
 v_num number;
begin
 begin
   select to_number(p_string) into v_num from dual;
 exception
   when invalid_number then
   return null;
 end;
 return v_num;
end;