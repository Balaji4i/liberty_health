create or replace function get_broker_name(p_broker_id_no in number) return varchar2 is
 v_varchar varchar2(500);
 
 CURSOR C_BROKER IS
 SELECT broker_name||' '||broker_last_name INTO v_varchar
   FROM broker 
  WHERE broker_id_no = p_broker_id_no;
  
 CURSOR C_COMPANY IS
     SELECT company_name INTO v_varchar
     FROM company 
    WHERE company_id_no = p_broker_id_no;  
  
  
begin
 
  OPEN C_BROKER;
    FETCH C_BROKER INTO v_varchar;
  CLOSE C_BROKER;
  
  IF v_varchar IS NULL THEN
    OPEN C_COMPANY;
      FETCH C_COMPANY INTO v_varchar;
    CLOSE C_COMPANY;
  END IF;

  return v_varchar;
 exception  
    when others then
	  return null;
end;