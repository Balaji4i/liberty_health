delete from comms_calc_trace where trace_base_snapshot_no in (select comms_calc_snapshot_no
                                        from COMMS_CALC_SNAPSHOT
                                       where COMMS_CALC_TYPE_CODE = 'X');
delete from COMMS_CALC_SNAPSHOT ccs
 where COMMS_CALC_TYPE_CODE in ('A', 'R');
update COMMS_CALC_SNAPSHOT 
   set COMMS_CALC_TYPE_CODE = 'P'
 where COMMS_CALC_TYPE_CODE in ('X');
update COMMS_RECALC
   set processed_date = to_date(get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'))
 WHERE trunc(processed_date) = trunc(sysdate);

/

SET SERVEROUTPUT ON;
DECLARE
  l_return_msg VARCHAR2(100);
BEGIN
-- To Run for a Group
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, 'CENTUMGANDA', NULL, 'SARELTWO', l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for all records
--  comms_calc_pkg.commissions_calc_run(NULL, NULL, NULL, NULL, l_return_msg);
--  dbms_output.put_line('Block - ' || l_return_msg);
-- To Run for re-calculation (all records)
  comms_calc_pkg.recalc_changes_run('SRL_TEST', l_return_msg);
  dbms_output.put_line('Block - ' || l_return_msg);
END;
