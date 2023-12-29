CREATE OR REPLACE EDITIONABLE TRIGGER "UTIL"."SYSTEM_PARAMETER_AUDIT_TRG" 

/**
----------------------------------------------------------------------
Project:     : Commisions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated. Also prevent Delete
Author       : Sarel Eybers
Requirements : UTIL priviledges to account
Amendments   : 
Date        User     Change Description
========    ======== =================================================
25/07/2017  SE       Create Trigger 
*/

BEFORE INSERT OR UPDATE OR DELETE ON SYSTEM_PARAMETER

FOR EACH ROW

DECLARE

  aud SYSTEM_PARAMETER_AUDIT%ROWTYPE;
  
BEGIN    

/* In Case we don't want to allow deleting
  IF DELETING THEN
    raise_application_error(-20001,'Deletion not supported on this table');
  END IF;
*/

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Added a new record';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Record Changed';
    IF :OLD.system_name <> :NEW.system_name OR 
      (:OLD.system_name IS NULL AND :NEW.system_name IS NOT NULL) OR 
      (:OLD.system_name IS NOT NULL AND :NEW.system_name IS NULL) THEN
      aud.transaction_desc := aud.transaction_desc || ', SYSTEM_NAME from ' ||
        :OLD.system_name || ' to ' || :NEW.system_name;
    END IF;
    IF :OLD.parameter_section <> :NEW.parameter_section  OR 
      (:OLD.parameter_section IS NULL AND :NEW.parameter_section IS NOT NULL) OR 
      (:OLD.parameter_section IS NOT NULL AND :NEW.parameter_section IS NULL) THEN
      aud.transaction_desc := aud.transaction_desc || ', PARAMETER_SECTION from ' ||
        :OLD.parameter_section || ' to ' || :NEW.parameter_section;
    END IF;
    IF :OLD.parameter_key <> :NEW.parameter_key  OR 
      (:OLD.parameter_key IS NULL AND :NEW.parameter_key IS NOT NULL) OR 
      (:OLD.parameter_key IS NOT NULL AND :NEW.parameter_key IS NULL) THEN
      aud.transaction_desc := aud.transaction_desc || ', PARAMETER_KEY from ' ||
        :OLD.parameter_key || ' to ' || :NEW.parameter_key;
    END IF;
    IF :OLD.parameter_value <> :NEW.parameter_value  OR 
      (:OLD.parameter_value IS NULL AND :NEW.parameter_value IS NOT NULL) OR 
      (:OLD.parameter_value IS NOT NULL AND :NEW.parameter_value IS NULL) THEN
      aud.transaction_desc := aud.transaction_desc || ', PARAMETER_VALUE from ' ||
        :OLD.parameter_value || ' to ' || :NEW.parameter_value;
    END IF;
    IF :OLD.user_update_ind <> :NEW.user_update_ind  OR 
      (:OLD.user_update_ind IS NULL AND :NEW.user_update_ind IS NOT NULL) OR 
      (:OLD.user_update_ind IS NOT NULL AND :NEW.user_update_ind IS NULL) THEN
      aud.transaction_desc := aud.transaction_desc || ', USER_UPDATE_IND from ' ||
        :OLD.user_update_ind || ' to ' || :NEW.user_update_ind;
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted an existing record';
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.system_name               := :NEW.system_name;
    aud.parameter_section         := :NEW.parameter_section;
    aud.parameter_key             := :NEW.parameter_key;
    aud.parameter_value           := :NEW.parameter_value;
    aud.user_update_ind           := :NEW.user_update_ind;
  ELSIF DELETING THEN
    aud.system_name               := :OLD.system_name;
    aud.parameter_section         := :OLD.parameter_section;
    aud.parameter_key             := :OLD.parameter_key;
    aud.parameter_value           := :OLD.parameter_value;
    aud.user_update_ind           := :OLD.user_update_ind;
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;

  -- Setting the Audit User and Date
  aud.transaction_username := USER;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  INSERT INTO SYSTEM_PARAMETER_AUDIT VALUES aud;

  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error Code is ' || TO_CHAR(SQLCODE ) );
      DBMS_OUTPUT.PUT_LINE('Error Message is ' || SQLERRM );
      RAISE;
END SYSTEM_PARAMETER_AUDIT_TRG;
/