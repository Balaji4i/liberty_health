create or replace function get_company_id_no(p_number in number) return number is
 v_num number;
 
 cursor c_info is
  select company_id_no  from company
   where company_id_no =  p_number;   
 begin
    
    open c_info;
      fetch c_info into v_num;
    close c_info;
    
       return v_num;
 end;