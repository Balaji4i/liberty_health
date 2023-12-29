DECLARE
BEGIN
  dbms_output.put_line('NULL Parameters ' || get_comm_percentage());
  dbms_output.put_line('p_poep => 3304 1 May 18 ' || get_comm_percentage(p_poep => 3304, p_date => '01-MAY-18'));
  dbms_output.put_line('p_poep => 3288 ' || get_comm_percentage(p_poep => 3288));
  dbms_output.put_line('company 10000061 ' || get_comm_percentage(p_company => 10000061));
  dbms_output.put_line('company 10000061, p_poep => 3288 ' || get_comm_percentage(p_poep => 3288, p_company => 10000061));
END;
/
select company_id_no, get_comm_percentage(p_company => company_id_no) as comm_perc from company;
/
select broker_id_no, get_comm_percentage(p_broker => broker_id_no) as comm_perc from broker;
/
select group_code, get_comm_percentage(p_group => group_code) as comm_perc from ohi_groups;
/
select policy_code, get_comm_percentage(p_policy => policy_code) as comm_perc from ohi_policies;
/
select inse_code, get_comm_percentage(p_person => inse_code) as comm_perc from ohi_insured_entities;
/
select poep_id, get_comm_percentage(p_poep => poep_id, p_date => effective_start_date) as comm_perc from ohi_enrollment_products;
/
select group_code, 
       country_code, 
       product_code, 
       policy_code, 
       person_code, 
       get_comm_percentage(p_person => person_code, p_policy => policy_code, p_product => product_code, p_group => group_code, p_date => contribution_date) as comm_perc 
  from comms_payments_received
 where finance_receipt_no like 'LES%';
/
