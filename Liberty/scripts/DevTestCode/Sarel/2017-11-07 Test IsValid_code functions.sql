select company_id_no, isvalid_company_id_no(company_id_no) as ValidCode from broker;
select broker_id_no, isvalid_broker_id_no(broker_id_no) as ValidCode from ohi_policy_brokers;
select broker_id_no, isvalid_broker_id_no(broker_id_no) as ValidCode from ohi_comm_perc;
select group_code, isvalid_group_code(group_code) as ValidCode from comms_payments_received;
select product_code, isvalid_product_code(product_code) as ValidCode from comms_payments_received;
select policy_code, isvalid_policy_code(policy_code) as ValidCode from comms_payments_received;
select person_code, isvalid_person_code(person_code) as ValidCode from comms_payments_received;
select grac_id, isvalid_poep_id(grac_id) as ValidCode from ohi_groups;
select isvalid_policy_code('123') from dual;
