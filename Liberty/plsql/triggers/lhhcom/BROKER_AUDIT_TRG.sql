CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."BROKER_AUDIT_TRG" 

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
27/07/2017  SE       Create Trigger 
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON BROKER

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud BROKER_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.broker_id_no;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.broker_id_no;
    IF :OLD.broker_id_no <> :NEW.broker_id_no OR 
      (:OLD.broker_id_no IS NULL AND :NEW.broker_id_no IS NOT NULL) OR 
      (:OLD.broker_id_no IS NOT NULL AND :NEW.broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ID_NO from ' ||
        :OLD.broker_id_no || ' to ' || :NEW.broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.parent_broker_id_no <> :NEW.parent_broker_id_no OR 
      (:OLD.parent_broker_id_no IS NULL AND :NEW.parent_broker_id_no IS NOT NULL) OR 
      (:OLD.parent_broker_id_no IS NOT NULL AND :NEW.parent_broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PARENT_BROKER_ID_NO from ' ||
        :OLD.parent_broker_id_no || ' to ' || :NEW.parent_broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.kam_broker_id_no <> :NEW.kam_broker_id_no OR 
      (:OLD.kam_broker_id_no IS NULL AND :NEW.kam_broker_id_no IS NOT NULL) OR 
      (:OLD.kam_broker_id_no IS NOT NULL AND :NEW.kam_broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', KAM_BROKER_ID_NO from ' ||
        :OLD.kam_broker_id_no || ' to ' || :NEW.kam_broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.person_title_code <> :NEW.person_title_code OR 
      (:OLD.person_title_code IS NULL AND :NEW.person_title_code IS NOT NULL) OR 
      (:OLD.person_title_code IS NOT NULL AND :NEW.person_title_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PERSON_TITLE_CODE from ' ||
        :OLD.person_title_code || ' to ' || :NEW.person_title_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.initials <> :NEW.initials OR 
      (:OLD.initials IS NULL AND :NEW.initials IS NOT NULL) OR 
      (:OLD.initials IS NOT NULL AND :NEW.initials IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INITIALS from ' ||
        :OLD.initials || ' to ' || :NEW.initials, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_name <> :NEW.broker_name OR 
      (:OLD.broker_name IS NULL AND :NEW.broker_name IS NOT NULL) OR 
      (:OLD.broker_name IS NOT NULL AND :NEW.broker_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_NAME from ' ||
        :OLD.broker_name || ' to ' || :NEW.broker_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_last_name <> :NEW.broker_last_name OR 
      (:OLD.broker_last_name IS NULL AND :NEW.broker_last_name IS NOT NULL) OR 
      (:OLD.broker_last_name IS NOT NULL AND :NEW.broker_last_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_LAST_NAME from ' ||
        :OLD.broker_last_name || ' to ' || :NEW.broker_last_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.passport_code <> :NEW.passport_code OR 
      (:OLD.passport_code IS NULL AND :NEW.passport_code IS NOT NULL) OR 
      (:OLD.passport_code IS NOT NULL AND :NEW.passport_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PASSPORT_CODE from ' ||
        :OLD.passport_code || ' to ' || :NEW.passport_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.language_code <> :NEW.language_code OR 
      (:OLD.language_code IS NULL AND :NEW.language_code IS NOT NULL) OR 
      (:OLD.language_code IS NOT NULL AND :NEW.language_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', LANGUAGE_CODE from ' ||
        :OLD.language_code || ' to ' || :NEW.language_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.id_no <> :NEW.id_no OR 
      (:OLD.id_no IS NULL AND :NEW.id_no IS NOT NULL) OR 
      (:OLD.id_no IS NOT NULL AND :NEW.id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ID_NO from ' ||
        :OLD.id_no || ' to ' || :NEW.id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.sms_notification_ind <> :NEW.sms_notification_ind OR 
      (:OLD.sms_notification_ind IS NULL AND :NEW.sms_notification_ind IS NOT NULL) OR 
      (:OLD.sms_notification_ind IS NOT NULL AND :NEW.sms_notification_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', SMS_NOTIFICATION_IND from ' ||
        :OLD.sms_notification_ind || ' to ' || :NEW.sms_notification_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.email_notification_ind <> :NEW.email_notification_ind OR 
      (:OLD.email_notification_ind IS NULL AND :NEW.email_notification_ind IS NOT NULL) OR 
      (:OLD.email_notification_ind IS NOT NULL AND :NEW.email_notification_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EMAIL_NOTIFICATION_IND from ' ||
        :OLD.email_notification_ind || ' to ' || :NEW.email_notification_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.business_dev_mgr_name <> :NEW.business_dev_mgr_name OR 
      (:OLD.business_dev_mgr_name IS NULL AND :NEW.business_dev_mgr_name IS NOT NULL) OR 
      (:OLD.business_dev_mgr_name IS NOT NULL AND :NEW.business_dev_mgr_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BUSINESS_DEV_MGR_NAME from ' ||
        :OLD.business_dev_mgr_name || ' to ' || :NEW.business_dev_mgr_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.web_password <> :NEW.web_password OR 
      (:OLD.web_password IS NULL AND :NEW.web_password IS NOT NULL) OR 
      (:OLD.web_password IS NOT NULL AND :NEW.web_password IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', WEB_PASSWORD from ' ||
        :OLD.web_password || ' to ' || :NEW.web_password, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.broker_id_no;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.broker_id_no                     := :NEW.broker_id_no;
    aud.parent_broker_id_no              := :NEW.parent_broker_id_no;
    aud.kam_broker_id_no                 := :NEW.kam_broker_id_no;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.person_title_code                := :NEW.person_title_code;
    aud.initials                         := :NEW.initials;
    aud.broker_name                      := :NEW.broker_name;
    aud.broker_last_name                 := :NEW.broker_last_name;
    aud.passport_code                    := :NEW.passport_code;
    aud.language_code                    := :NEW.language_code;
    aud.id_no                            := :NEW.id_no;
    aud.sms_notification_ind             := :NEW.sms_notification_ind;
    aud.email_notification_ind           := :NEW.email_notification_ind;
    aud.business_dev_mgr_name            := :NEW.business_dev_mgr_name;
    aud.web_password                     := :NEW.web_password;
  ELSIF DELETING THEN
    aud.broker_id_no                     := :OLD.broker_id_no;
    aud.parent_broker_id_no              := :OLD.parent_broker_id_no;
    aud.kam_broker_id_no                 := :OLD.kam_broker_id_no;
    aud.company_id_no                    := :OLD.company_id_no;
    aud.person_title_code                := :OLD.person_title_code;
    aud.initials                         := :OLD.initials;
    aud.broker_name                      := :OLD.broker_name;
    aud.broker_last_name                 := :OLD.broker_last_name;
    aud.passport_code                    := :OLD.passport_code;
    aud.language_code                    := :OLD.language_code;
    aud.id_no                            := :OLD.id_no;
    aud.sms_notification_ind             := :OLD.sms_notification_ind;
    aud.email_notification_ind           := :OLD.email_notification_ind;
    aud.business_dev_mgr_name            := :OLD.business_dev_mgr_name;
    aud.web_password                     := :OLD.web_password;
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
    INSERT INTO BROKER_AUDIT VALUES aud;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END BROKER_AUDIT_TRG;
/