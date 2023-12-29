create or replace TRIGGER "LHHCOM"."OHI_ENRLMNT_PRDCTS_AUDIT_TRG" 

/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Sarel Eybers
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User     Change Description
========    ======== =================================================
29/08/2017  SE       Create Trigger 
29/11/2017  Helen    added recalc process
07/02/2018  Helen    corrected recalc cursor to include more poep_ids
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_ENROLLMENT_PRODUCTS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_ENROLLMENT_PRODUCTS_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
             := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'); 
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  
BEGIN    

--dbms_output.put_line('In trigger for POEP OHI_ENROLLMENT_PRODUCTS '); 
  l_write_aud := 'N';

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.poep_id;
  	l_recalc := 'Y';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.poep_id;
    IF :OLD.poep_id <> :NEW.poep_id OR 
      (:OLD.poep_id IS NULL AND :NEW.poep_id IS NOT NULL) OR 
      (:OLD.poep_id IS NOT NULL AND :NEW.poep_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POEP_ID from ' ||
        :OLD.poep_id || ' to ' || :NEW.poep_id, 1, 550);
      l_write_aud := 'Y';
   END IF;
    IF :OLD.poen_id <> :NEW.poen_id OR 
      (:OLD.poen_id IS NULL AND :NEW.poen_id IS NOT NULL) OR 
      (:OLD.poen_id IS NOT NULL AND :NEW.poen_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POEN_ID from ' ||
        :OLD.poen_id || ' to ' || :NEW.poen_id, 1, 550);
      l_recalc := 'Y';   
      l_write_aud := 'Y';
    END IF;
    IF :OLD.enpr_id <> :NEW.enpr_id OR 
      (:OLD.enpr_id IS NULL AND :NEW.enpr_id IS NOT NULL) OR 
      (:OLD.enpr_id IS NOT NULL AND :NEW.enpr_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ENPR_ID from ' ||
        :OLD.enpr_id || ' to ' || :NEW.enpr_id, 1, 550);
      l_recalc := 'Y'; 
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date OR 
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR 
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_recalc := 'Y'; 
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date OR 
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR 
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_recalc := 'Y';  
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.poep_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.poep_id                          := :NEW.poep_id;
    aud.poen_id                          := :NEW.poen_id;
    aud.enpr_id                          := :NEW.enpr_id;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  ELSIF DELETING THEN
    aud.poep_id                          := :OLD.poep_id;
    aud.poen_id                          := :OLD.poen_id;
    aud.enpr_id                          := :OLD.enpr_id;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := :NEW.USERNAME;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  IF l_write_aud = 'Y' THEN
    INSERT INTO OHI_ENROLLMENT_PRODUCTS_AUDIT VALUES aud;
  END IF;
  
      -- Setting the Commissions_Recalc row values (at this level should only pick up one in the loop.)

--	 dbms_output.put_line('Just before update for POEP_ID OHI_POLICY_BROKERS_AUDIT_TRG ' || :OLD.poep_id); 

   IF       l_recalc = 'Y'   
     THEN 
  
       BEGIN
 
        IF :OLD.poep_id IS NOT NULL THEN 
         INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
               VALUES (:OLD.poep_id, to_date(lv_sys_param_date), 'Source : OHI_ENROLLMENT_PRODUCTS ', SYSDATE, USER); 
        END IF;
    
       IF :NEW.poep_id IS NOT NULL THEN
        INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
               VALUES (:NEW.poep_id, to_date(lv_sys_param_date), 'Source : OHI_ENROLLMENT_PRODUCTS ', SYSDATE, USER); 
       END IF;         
               
              EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                         NULL;     
		    
       END;    
      END IF;  

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END OHI_ENRLMNT_PRDCTS_AUDIT_TRG;
/