CREATE OR REPLACE PROCEDURE load_comms_calc_trace 

IS

  gc_scope_prefix CONSTANT VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'Procedure: ' || gc_scope_prefix;
  l_params logger.tab_param := logger.gc_empty_tab_param;
  
  cct                            comms_calc_trace%rowtype;  

  cursor c_get_snapshot_no is
    select distinct(ccs.comms_calc_snapshot_no) as snapshot_no
      from comms_calc_snapshot ccs;
      
  begin  
    logger.log('Start of load_comms_calc_trace ', l_scope, NULL);  
    for x in c_get_snapshot_no loop
      begin
        l_params := logger.gc_empty_tab_param;
        logger.append_param(p_params => l_params, p_name => 'snapshot_no = ', p_val => x.snapshot_no);        
        
        cct.comms_calc_snapshot_no := x.snapshot_no;
        INSERT INTO comms_calc_trace VALUES cct; 
    
      exception
        when dup_val_on_index then
          logger.log('Snapshot no already in comms_calc_trace ', NULL, NULL, l_params);  
      end;
    end loop;  
    commit;
    logger.log('End of load_comms_calc_trace ', l_scope, NULL); 
  end load_comms_calc_trace;  