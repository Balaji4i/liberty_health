CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_GROUPS_AUDIT_TRG" 

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
05/03/2018  Helen    simplify cursor to eliminate mutating.
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_GROUPS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_GROUPS_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
                 := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE'); 
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_grac_id NUMBER (14,0);
  
   CURSOR c_get_changes_to_recalc (l_grac_id NUMBER) IS	
	  SELECT distinct poep.poep_id
     FROM ohi_enrollment_products   poep
     JOIN ohi_policy_enrollments    poen
       ON poen.poen_id = poep.poen_id
     JOIN ohi_policy_groups         pogr
       ON  pogr.poli_id = poen.poli_id
     WHERE pogr.grac_id = l_grac_id;
 
 /*
  CURSOR c_get_changes_to_recalc (l_grac_id NUMBER) IS	
	  SELECT  poep.poep_id,
           poen.poen_id,
           grps.group_code,
           aligrps.grac_id           
	    FROM ohi_groups                             grps
      JOIN ohi_groups                             aligrps
        ON aligrps.group_code = grps.group_code
      JOIN ohi_policy_groups                      pogr
        ON pogr.grac_id = aligrps.grac_id
      JOIN ohi_policy_enrollments                 poen
        ON poen.poli_id = pogr.poli_id
	    JOIN ohi_enrollment_products                poep
        ON poep.poen_id = poen.poen_id	 
      WHERE pogr.grac_id = l_grac_id; 
*/

BEGIN    

--dbms_output.put_line('In trigger for GRPS OHI_GROUPS '); 
  l_write_aud := 'N';

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.grac_id;
    l_recalc := 'Y';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.grac_id;
    IF :OLD.grac_id <> :NEW.grac_id OR 
      (:OLD.grac_id IS NULL AND :NEW.grac_id IS NOT NULL) OR 
      (:OLD.grac_id IS NOT NULL AND :NEW.grac_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GRAC_ID from ' ||
        :OLD.grac_id || ' to ' || :NEW.grac_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_code <> :NEW.group_code OR 
      (:OLD.group_code IS NULL AND :NEW.group_code IS NOT NULL) OR 
      (:OLD.group_code IS NOT NULL AND :NEW.group_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_CODE from ' ||
        :OLD.group_code || ' to ' || :NEW.group_code, 1, 550);
      l_recalc := 'Y';  
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_name <> :NEW.group_name OR 
      (:OLD.group_name IS NULL AND :NEW.group_name IS NOT NULL) OR 
      (:OLD.group_name IS NOT NULL AND :NEW.group_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_NAME from ' ||
        :OLD.group_name || ' to ' || :NEW.group_name, 1, 550);
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
    IF :OLD.parentgroup_code <> :NEW.parentgroup_code OR 
      (:OLD.parentgroup_code IS NULL AND :NEW.parentgroup_code IS NOT NULL) OR 
      (:OLD.parentgroup_code IS NOT NULL AND :NEW.parentgroup_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PARENTGROUP_CODE from ' ||
        :OLD.parentgroup_code || ' to ' || :NEW.parentgroup_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_type <> :NEW.group_type OR 
      (:OLD.group_type IS NULL AND :NEW.group_type IS NOT NULL) OR 
      (:OLD.group_type IS NOT NULL AND :NEW.group_type IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_TYPE from ' ||
        :OLD.group_type || ' to ' || :NEW.group_type, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_class <> :NEW.group_class OR 
      (:OLD.group_class IS NULL AND :NEW.group_class IS NOT NULL) OR 
      (:OLD.group_class IS NOT NULL AND :NEW.group_class IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_CLASS from ' ||
        :OLD.group_class || ' to ' || :NEW.group_class, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.preferred_currency_code <> :NEW.preferred_currency_code OR 
      (:OLD.preferred_currency_code IS NULL AND :NEW.preferred_currency_code IS NOT NULL) OR 
      (:OLD.preferred_currency_code IS NOT NULL AND :NEW.preferred_currency_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PREFERRED_CURRENCY_CODE from ' ||
        :OLD.preferred_currency_code || ' to ' || :NEW.preferred_currency_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.country_code <> :NEW.country_code OR 
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR 
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.grac_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.grac_id                          := :NEW.grac_id;
    aud.group_code                       := :NEW.group_code;
    aud.group_name                       := :NEW.group_name;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.parentgroup_code                 := :NEW.parentgroup_code;
    aud.group_type                       := :NEW.group_type;
    aud.group_class                      := :NEW.group_class;
    aud.preferred_currency_code          := :NEW.preferred_currency_code;
    aud.country_code                     := :NEW.country_code;
  ELSIF DELETING THEN
    aud.grac_id                          := :OLD.grac_id;
    aud.group_code                       := :OLD.group_code;
    aud.group_name                       := :OLD.group_name;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.parentgroup_code                 := :OLD.parentgroup_code;
    aud.group_type                       := :OLD.group_type;
    aud.group_class                      := :OLD.group_class;
    aud.preferred_currency_code          := :OLD.preferred_currency_code;
    aud.country_code                     := :OLD.country_code;
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
    INSERT INTO OHI_GROUPS_AUDIT VALUES aud;
  END IF;

  -- Setting the Commissions_Recalc row values

   l_grac_id := :OLD.grac_id;
--	 dbms_output.put_line('Just before loop  for GRAC_ID OHI_GROUPS_AUDIT_TRG ' || l_grac_id); 

    FOR x IN c_get_changes_to_recalc (l_grac_id) LOOP
       BEGIN
 
  -- dbms_output.put_line('In loop  for GRAC_ID OHI_GROUPS_AUDIT_TRG ' || l_grac_id || ' x.poen_id ' || x.poen_id || ' x.poep_id ' || x.poep_id  );

	     IF       l_recalc = 'Y' THEN 
 
           BEGIN
              -- dbms_output.put_line('grac_id,Poep_id ' || l_grac_id || ' ' || x.poep_id); 
              INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_GROUPS ', SYSDATE, USER); 
		
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
END OHI_GROUPS_AUDIT_TRG;
/