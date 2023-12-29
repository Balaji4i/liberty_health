create or replace function        lhhcom.get_scheduler_job_id(p_session_id in varchar2, p_slave_id in varchar2) return number is
 l_log_id number;
begin

  SELECT substr(log_id,1,instr(log_id,'.',1,1)-1)
    INTO l_log_id
    FROM all_scheduler_running_jobs
   WHERE session_id       = p_session_id
     AND slave_process_id = p_slave_id;
     
  RETURN l_log_id;

exception
  when no_data_found then
    return 0;
  when others then
    return 0;
end;
/