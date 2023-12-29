SET SERVEROUTPUT ON;
BEGIN
--  dbms_scheduler.drop_job   ('COMMISSIONS_HOURLY_JOB');
  dbms_scheduler.create_job (
    job_name             =>  'COMMISSIONS_HOURLY_JOB',
    job_type             =>  'PLSQL_BLOCK',
    job_action           =>  'BEGIN commissions_pkg.hourly_job; END;',
    job_class            =>  'DEFAULT_JOB_CLASS',
    start_date           =>  SYSDATE, 
    repeat_interval      =>  'FREQ=DAILY; BYDAY=MON,TUE,WED,THU,FRI,SAT,SUN; BYHOUR=6,7,8,9,10,11,12,13,14,15,16,17,18,19; BYMINUTE=00;BYSECOND=00',
    enabled              =>  TRUE,
    auto_drop            =>  FALSE,
    comments             =>  'Commissions Job that runs hourly every day from 06:00-19:00');
END;
/
/* Job Related commands . . .
-- query to see the job you setup scheduled
SELECT * FROM ALL_SCHEDULER_JOBS WHERE job_NAME like 'COMMISSIONS_%';

-- query to see the job run history where you can check your frequency is working
SELECT * FROM USER_SCHEDULER_JOB_RUN_DETAILS where JOB_NAME like 'COMMISSIONS_%' ORDER BY req_start_date DESC;

-- check logger to see the log output from job execution
SELECT * FROM LOGGER_LOGS order by time_stamp desc;

-- STOP JOB
begin
 dbms_scheduler.stop_job (job_name => 'COMMISSIONS_HOURLY_JOB');
end;
/
-- DROP JOB
begin
dbms_scheduler.drop_job ('COMMISSIONS_HOURLY_JOB');
end;
/

exec logger.log_information('Sarel testing - OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true)');
*/