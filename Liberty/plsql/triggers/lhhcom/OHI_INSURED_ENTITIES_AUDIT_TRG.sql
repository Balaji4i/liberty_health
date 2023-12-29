CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_INSURED_ENTITIES_AUDIT_TRG" 

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
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_INSURED_ENTITIES

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_INSURED_ENTITIES_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
             := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_inse_id NUMBER (14,0);
  
    CURSOR c_get_changes_to_recalc (l_inse_id NUMBER) IS	
	  SELECT distinct 
            poep.poep_id
           ,poli.policy_code
           ,poli.poli_id AS old_poli_id
           ,alipoli.poli_id
	    FROM ohi_policies                              poli
      JOIN  ohi_policies                             alipoli
        ON alipoli.policy_code = poli.policy_code
      JOIN  ohi_policy_enrollments                   poen
        ON poen.poli_id = alipoli.poli_id
	  JOIN ohi_enrollment_products                     poep
	    ON poen.poen_id = poep.poen_id	 
      WHERE poen.inse_id = l_inse_id;
	  
  BEGIN   

   --dbms_output.put_line('In trigger for INSE OHI_INSURED_ENTITIES '); 
  l_write_aud := 'N';

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.inse_id;
    l_recalc := 'Y';	
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.inse_id;
    IF :OLD.inse_id <> :NEW.inse_id OR 
      (:OLD.inse_id IS NULL AND :NEW.inse_id IS NOT NULL) OR 
      (:OLD.inse_id IS NOT NULL AND :NEW.inse_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INSE_ID from ' ||
        :OLD.inse_id || ' to ' || :NEW.inse_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.inse_code <> :NEW.inse_code OR 
      (:OLD.inse_code IS NULL AND :NEW.inse_code IS NOT NULL) OR 
      (:OLD.inse_code IS NOT NULL AND :NEW.inse_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INSE_CODE from ' ||
        :OLD.inse_code || ' to ' || :NEW.inse_code, 1, 550);
      l_recalc := 'Y';        
      l_write_aud := 'Y';
    END IF;
    IF :OLD.rela_id_pers <> :NEW.rela_id_pers OR 
      (:OLD.rela_id_pers IS NULL AND :NEW.rela_id_pers IS NOT NULL) OR 
      (:OLD.rela_id_pers IS NOT NULL AND :NEW.rela_id_pers IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', RELA_ID_PERS from ' ||
        :OLD.rela_id_pers || ' to ' || :NEW.rela_id_pers, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.title <> :NEW.title OR 
      (:OLD.title IS NULL AND :NEW.title IS NOT NULL) OR 
      (:OLD.title IS NOT NULL AND :NEW.title IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', TITLE from ' ||
        :OLD.title || ' to ' || :NEW.title, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.initials <> :NEW.initials OR 
      (:OLD.initials IS NULL AND :NEW.initials IS NOT NULL) OR 
      (:OLD.initials IS NOT NULL AND :NEW.initials IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INITIALS from ' ||
        :OLD.initials || ' to ' || :NEW.initials, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.first_name <> :NEW.first_name OR 
      (:OLD.first_name IS NULL AND :NEW.first_name IS NOT NULL) OR 
      (:OLD.first_name IS NOT NULL AND :NEW.first_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', FIRST_NAME from ' ||
        :OLD.first_name || ' to ' || :NEW.first_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.surname <> :NEW.surname OR 
      (:OLD.surname IS NULL AND :NEW.surname IS NOT NULL) OR 
      (:OLD.surname IS NOT NULL AND :NEW.surname IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', SURNAME from ' ||
        :OLD.surname || ' to ' || :NEW.surname, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.gender <> :NEW.gender OR 
      (:OLD.gender IS NULL AND :NEW.gender IS NOT NULL) OR 
      (:OLD.gender IS NOT NULL AND :NEW.gender IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GENDER from ' ||
        :OLD.gender || ' to ' || :NEW.gender, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.inse_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.inse_id                          := :NEW.inse_id;
    aud.inse_code                        := :NEW.inse_code;
    aud.rela_id_pers                     := :NEW.rela_id_pers;
    aud.title                            := :NEW.title;
    aud.initials                         := :NEW.initials;
    aud.first_name                       := :NEW.first_name;
    aud.surname                          := :NEW.surname;
    aud.gender                           := :NEW.gender;
  ELSIF DELETING THEN
    aud.inse_id                          := :OLD.inse_id;
    aud.inse_code                        := :OLD.inse_code;
    aud.rela_id_pers                     := :OLD.rela_id_pers;
    aud.title                            := :OLD.title;
    aud.initials                         := :OLD.initials;
    aud.first_name                       := :OLD.first_name;
    aud.surname                          := :OLD.surname;
    aud.gender                           := :OLD.gender;
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
    INSERT INTO OHI_INSURED_ENTITIES_AUDIT VALUES aud;
  END IF;
  
  -- Setting the Commissions_Recalc row values

   l_inse_id := :OLD.inse_id;
	 --dbms_output.put_line('Just before loop  for POEP_ID OHI_INSURED_ENTITIES_AUDIT_TRG ' || l_inse_id); 

    FOR x IN c_get_changes_to_recalc (l_inse_id) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
 
           BEGIN
 
              -- dbms_output.put_line('inse_id,Poep_id ' || l_inse_id || ' ' || x.poep_id); 
              INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id, to_date(lv_sys_param_date), 'Source : OHI_INSURED_ENTITIES ', SYSDATE, USER); 
		
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
END OHI_INSURED_ENTITIES_AUDIT_TRG;
/