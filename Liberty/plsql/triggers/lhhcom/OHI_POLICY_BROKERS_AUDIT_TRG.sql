CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_POLICY_BROKERS_AUDIT_TRG" 

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
30/08/2017  SE       Create Trigger 
29/11/2017  Helen    added recalc process
04/02/2018  Helen    corrected recalc cursor to include more poep_ids
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_POLICY_BROKERS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_POLICY_BROKERS_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
             := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_poli_id NUMBER (14,0);
  
    CURSOR c_get_changes_to_recalc (l_poli_id NUMBER) IS	
	  SELECT  distinct 
            poep.poep_id
           ,poli.policy_code
           ,alipoli.poli_id
	    FROM ohi_policies                poli
      JOIN  ohi_policies                 alipoli
        ON alipoli.policy_code = poli.policy_code
      JOIN ohi_policy_enrollments        poen
        ON poen.poli_id = alipoli.poli_id
	   JOIN ohi_enrollment_products     poep
	    ON poep.poen_id = poen.poen_id	
      WHERE poli.poli_id = l_poli_id   ;
  
BEGIN    

-- dbms_output.put_line('In trigger for POBR OHI_POLICY_BROKERS '); 
  l_write_aud := 'N';

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.poli_id || ', ' || :NEW.pobr_id;
    l_recalc := 'Y';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.poli_id || ', ' || :OLD.pobr_id;
    IF :OLD.poli_id <> :NEW.poli_id OR 
      (:OLD.poli_id IS NULL AND :NEW.poli_id IS NOT NULL) OR 
      (:OLD.poli_id IS NOT NULL AND :NEW.poli_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLI_ID from ' ||
        :OLD.poli_id || ' to ' || :NEW.poli_id, 1, 550);
      l_recalc := 'Y';
      l_write_aud := 'Y';
    END IF;
    IF :OLD.pobr_id <> :NEW.pobr_id OR 
      (:OLD.pobr_id IS NULL AND :NEW.pobr_id IS NOT NULL) OR 
      (:OLD.pobr_id IS NOT NULL AND :NEW.pobr_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POBR_ID from ' ||
        :OLD.pobr_id || ' to ' || :NEW.pobr_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_id_no <> :NEW.broker_id_no OR 
      (:OLD.broker_id_no IS NULL AND :NEW.broker_id_no IS NOT NULL) OR 
      (:OLD.broker_id_no IS NOT NULL AND :NEW.broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ID_NO from ' ||
        :OLD.broker_id_no || ' to ' || :NEW.broker_id_no, 1, 550);
      l_recalc := 'Y'; 
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
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
    aud.transaction_desc := 'Deleted record ' || :OLD.poli_id || ', ' || :OLD.pobr_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.poli_id                          := :NEW.poli_id;
    aud.pobr_id                          := :NEW.pobr_id;
    aud.broker_id_no                     := :NEW.broker_id_no;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  ELSIF DELETING THEN
    aud.poli_id                          := :OLD.poli_id;
    aud.pobr_id                          := :OLD.pobr_id;
    aud.broker_id_no                     := :OLD.broker_id_no;
    aud.company_id_no                    := :OLD.company_id_no;
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
    INSERT INTO OHI_POLICY_BROKERS_AUDIT VALUES aud;
  END IF;

    -- Setting the Commissions_Recalc row values

   l_poli_id := :OLD.poli_id;
--	 dbms_output.put_line('Just before loop  for POEP_ID OHI_POLICY_BROKERS_AUDIT_TRG ' || l_poli_id); 

    FOR x IN c_get_changes_to_recalc (l_poli_id) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
           BEGIN
               -- dbms_output.put_line('Poli_id,Poep_id ' || l_poli_id || ' ' || x.poep_id); 
               INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                     VALUES (x.poep_id, to_date(lv_sys_param_date), 'Source : OHI_POLICY_BROKERS ', SYSDATE, USER);  
		 
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
    
          END;
  	   END IF;
	    END; 
	 END LOOP;  

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END OHI_POLICY_BROKERS_AUDIT_TRG;
/