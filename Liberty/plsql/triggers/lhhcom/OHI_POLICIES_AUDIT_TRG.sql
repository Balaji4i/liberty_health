CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_POLICIES_AUDIT_TRG" 

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
30/11/2017  Helen    added recalc process
07/02/2018  Helen    corrected recalc cursor to include more poep_ids
05/03/2018  Helen    simplified cursor to eliminate mutating.
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_POLICIES

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_POLICIES_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
             := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_poli_id NUMBER (14,0);

    CURSOR c_get_changes_to_recalc (l_poli_id NUMBER) IS	
	  SELECT distinct poep.poep_id
      FROM ohi_policy_enrollments                 poen
	    JOIN ohi_enrollment_products                poep
	       ON poep.poen_id = poen.poen_id
      WHERE poen.poli_id = l_poli_id ;  
         
         
/*
    CURSOR c_get_changes_to_recalc (l_poli_id NUMBER) IS	
	  SELECT poep.poep_id
          ,poli.policy_code
          ,alipoli.poli_id
	    FROM ohi_policy_enrollments                 poen
	    JOIN ohi_enrollment_products                poep
	       ON poep.poen_id = poen.poen_id	 
	    JOIN ohi_policies                           poli
        ON poli.poli_id = poen.poli_id
      JOIN  ohi_policies                          alipoli
        ON alipoli.policy_code = poli.policy_code
      WHERE alipoli.poli_id = l_poli_id;
*/

BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Added new record ' || :NEW.poli_id;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.poli_id;
    IF :OLD.poli_id <> :NEW.poli_id OR 
      (:OLD.poli_id IS NULL AND :NEW.poli_id IS NOT NULL) OR 
      (:OLD.poli_id IS NOT NULL AND :NEW.poli_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLI_ID from ' ||
        :OLD.poli_id || ' to ' || :NEW.poli_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.policy_code <> :NEW.policy_code OR 
      (:OLD.policy_code IS NULL AND :NEW.policy_code IS NOT NULL) OR 
      (:OLD.policy_code IS NOT NULL AND :NEW.policy_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLICY_CODE from ' ||
        :OLD.policy_code || ' to ' || :NEW.policy_code, 1, 550);
      l_recalc := 'Y';        
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.poli_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.poli_id                          := :NEW.poli_id;
    aud.policy_code                      := :NEW.policy_code;
  ELSIF DELETING THEN
    aud.poli_id                          := :OLD.poli_id;
    aud.policy_code                      := :OLD.policy_code;
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
    INSERT INTO OHI_POLICIES_AUDIT VALUES aud;
  END IF;

  -- Setting the Commissions_Recalc row values

   l_poli_id := :OLD.poli_id;
	 --dbms_output.put_line('Just before loop  for POLI_ID OHI_POLICES_AUDIT_TRG ' || l_poli_id); 

    FOR x IN c_get_changes_to_recalc (l_poli_id) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
  
         BEGIN
  
               --dbms_output.put_line('Poli_id,Poep_id ' || l_poli_id || ' ' || x.poep_id); 
              INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id, to_date(lv_sys_param_date), 'Source : OHI_POLICIES ', SYSDATE, USER); 
               
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
END OHI_POLICIES_AUDIT_TRG;
/