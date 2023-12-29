create or replace function get_group_id_no(p_var in varchar2) return number is
 v_num number;
 
 cursor c_info is
select group_id_no
from ohi_group
where group_code = replace((p_var),'	','');

 begin
    
    open c_info;
      fetch c_info into v_num;
    close c_info;
    
       return v_num;
 end;