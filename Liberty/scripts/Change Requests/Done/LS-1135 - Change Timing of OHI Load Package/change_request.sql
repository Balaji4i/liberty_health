/**
* ----------------------------------------------------------------------
* Change Request: Change Timing of OHI Load Package
*                 (LS-1135)
*
* Description  : Change Timing of OHI Load Package
*                
* Author       : Sarel Eybers
* Date         : 2018-03-20
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Drop Job
*   2) Compile Package
*   3) Compile Jobs
*   3) Ad Hoc Code
*                */

--  1) Drop Job

SET SERVEROUTPUT ON;
EXEC dbms_scheduler.drop_job   ('COMMISSIONS_HOURLY_JOB');
-- EXEC dbms_scheduler.drop_job   ('COMMISSIONS_HALFHOURLY_JOB');

--  2) Compile Package

@../../../../plsql/packages/lhhcom/dnld_ohi_policies_pkg.sql;
@../../../../plsql/packages/lhhcom/commissions_pkg.sql;

--  3) Compile Jobs

@../../../../plsql/jobs/lhhcom/commissions_hourly_job.sql;
@../../../../plsql/jobs/lhhcom/commissions_halfhourly_job.sql;

--  4) Ad Hoc Code

/*
  Nothing here . . . Now
-- query to see the job you setup scheduled
SELECT * FROM ALL_SCHEDULER_JOBS WHERE job_NAME like 'COMMISSIONS_%';

-- query to see the job run history where you can check your frequency is working
SELECT * FROM USER_SCHEDULER_JOB_RUN_DETAILS where JOB_NAME like 'COMMISSIONS_%' ORDER BY req_start_date DESC;

-- check logger to see the log output from job execution
SELECT * FROM LOGGER_LOGS order by time_stamp desc;

*/