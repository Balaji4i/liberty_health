create or replace function get_broker_from_comp(p_var in number) return number is
 v_num number;
 
 cursor c_info is
select broker_id_no
from broker
where company_id_no = p_var;

 begin
    
    open c_info;
      fetch c_info into v_num;
    close c_info;
    
       return v_num;
 end;