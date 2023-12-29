create or replace TRIGGER "LHHCOM"."COMPANY_AUDIT_BEFORE_TRG" 

/**
----------------------------------------------------------------------
Project:     : Commissions Self Build Application               
Description  : Create Audit Trigger to insert rows whenever a new record
             : is added or an old one is updated or deleted
Author       : Sarel Eybers
Requirements : LHHCOM priviledges to account
Amendments   : 
Date        User   Change Change Description
========    =====  ====== =================================================
28/08/2017  AMS      		  Re-Create Trigger 
06/04/2018  SE       		  Make Changes for DNLD_COMPANY
06/04/2018  SE       		  Make Changes for transaction_desc < 550 characters
05/06/2018  SE       		  Allow for multiple Company Changes per day to trigger DNLD_COMPANY
05/09/2018  TP     1.1    The l_dnld variable is only 1 char but if multiple changes happen then size error occurs.
29/01/2019  SE            Ensure that Audit records only get written if something worth auditing changes
*/
BEFORE INSERT OR UPDATE OR DELETE ON COMPANY

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  l_dnld VARCHAR(1);
  aud COMPANY_AUDIT%ROWTYPE;
  l_write_aud VARCHAR(1);
  
BEGIN    

  l_write_aud := 'N';
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.company_id_no;
    l_dnld := 'I';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.company_id_no;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_dnld := 'B';
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_name <> :NEW.company_name OR 
      (:OLD.company_name IS NULL AND :NEW.company_name IS NOT NULL) OR 
      (:OLD.company_name IS NOT NULL AND :NEW.company_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_NAME from ' ||
        :OLD.company_name || ' to ' || :NEW.company_name, 1, 550);
       l_dnld := SUBSTR(l_dnld || 'U',1, 1);  --1.1
      l_write_aud := 'Y';
    END IF;
    IF :OLD.internal_broker_ind <> :NEW.internal_broker_ind OR 
      (:OLD.internal_broker_ind IS NULL AND :NEW.internal_broker_ind IS NOT NULL) OR 
      (:OLD.internal_broker_ind IS NOT NULL AND :NEW.internal_broker_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INTERNAL_BROKER_IND from ' ||
        :OLD.internal_broker_ind || ' to ' || :NEW.internal_broker_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.consultant_id_no <> :NEW.consultant_id_no OR 
      (:OLD.consultant_id_no IS NULL AND :NEW.consultant_id_no IS NOT NULL) OR 
      (:OLD.consultant_id_no IS NOT NULL AND :NEW.consultant_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CONSULTANT_ID_NO from ' ||
        :OLD.consultant_id_no || ' to ' || :NEW.consultant_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
   IF :OLD.vat_reg_ind <> :NEW.vat_reg_ind OR 
      (:OLD.vat_reg_ind IS NULL AND :NEW.vat_reg_ind IS NOT NULL) OR 
      (:OLD.vat_reg_ind IS NOT NULL AND :NEW.vat_reg_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', VAT_REG_IND from ' ||
        :OLD.vat_reg_ind || ' to ' || :NEW.vat_reg_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.wht_cert_ind <> :NEW.wht_cert_ind OR 
      (:OLD.wht_cert_ind IS NULL AND :NEW.wht_cert_ind IS NOT NULL) OR 
      (:OLD.wht_cert_ind IS NOT NULL AND :NEW.wht_cert_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', WHT_CERT_IND from ' ||
        :OLD.wht_cert_ind || ' to ' || :NEW.wht_cert_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_agreement_ind <> :NEW.company_agreement_ind OR 
      (:OLD.company_agreement_ind IS NULL AND :NEW.company_agreement_ind IS NOT NULL) OR 
      (:OLD.company_agreement_ind IS NOT NULL AND :NEW.company_agreement_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_AGREEMENT_IND from ' ||
        :OLD.company_agreement_ind || ' to ' || :NEW.company_agreement_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.referral_agreement_ind <> :NEW.referral_agreement_ind OR 
      (:OLD.referral_agreement_ind IS NULL AND :NEW.referral_agreement_ind IS NOT NULL) OR 
      (:OLD.referral_agreement_ind IS NOT NULL AND :NEW.referral_agreement_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', REFERRAL_AGREEMENT_IND from ' ||
        :OLD.referral_agreement_ind || ' to ' || :NEW.referral_agreement_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_reg_doc_ind <> :NEW.company_reg_doc_ind OR 
      (:OLD.company_reg_doc_ind IS NULL AND :NEW.company_reg_doc_ind IS NOT NULL) OR 
      (:OLD.company_reg_doc_ind IS NOT NULL AND :NEW.company_reg_doc_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_REG_DOC_IND from ' ||
        :OLD.company_reg_doc_ind || ' to ' || :NEW.company_reg_doc_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.bank_details_ind <> :NEW.bank_details_ind OR 
      (:OLD.bank_details_ind IS NULL AND :NEW.bank_details_ind IS NOT NULL) OR 
      (:OLD.bank_details_ind IS NOT NULL AND :NEW.bank_details_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BANK_DETAILS_IND from ' ||
        :OLD.bank_details_ind || ' to ' || :NEW.bank_details_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.id_doc_ind <> :NEW.id_doc_ind OR 
      (:OLD.id_doc_ind IS NULL AND :NEW.id_doc_ind IS NOT NULL) OR 
      (:OLD.id_doc_ind IS NOT NULL AND :NEW.id_doc_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ID_DOC_IND from ' ||
        :OLD.id_doc_ind || ' to ' || :NEW.id_doc_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.letter_of_intent_ind <> :NEW.letter_of_intent_ind OR 
      (:OLD.letter_of_intent_ind IS NULL AND :NEW.letter_of_intent_ind IS NOT NULL) OR 
      (:OLD.letter_of_intent_ind IS NOT NULL AND :NEW.letter_of_intent_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', LETTER_OF_INTENT_IND from ' ||
        :OLD.letter_of_intent_ind || ' to ' || :NEW.letter_of_intent_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.dis_agreement_application_ind <> :NEW.dis_agreement_application_ind OR 
      (:OLD.dis_agreement_application_ind IS NULL AND :NEW.dis_agreement_application_ind IS NOT NULL) OR 
      (:OLD.dis_agreement_application_ind IS NOT NULL AND :NEW.dis_agreement_application_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', DIS_AGREEMENT_APPLICATION_IND from ' ||
        :OLD.dis_agreement_application_ind || ' to ' || :NEW.dis_agreement_application_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.address_ind <> :NEW.address_ind OR 
      (:OLD.address_ind IS NULL AND :NEW.address_ind IS NOT NULL) OR 
      (:OLD.address_ind IS NOT NULL AND :NEW.address_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ADDRESS_IND from ' ||
        :OLD.address_ind || ' to ' || :NEW.address_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.tax_id_no_ind <> :NEW.tax_id_no_ind OR 
      (:OLD.tax_id_no_ind IS NULL AND :NEW.tax_id_no_ind IS NOT NULL) OR 
      (:OLD.tax_id_no_ind IS NOT NULL AND :NEW.tax_id_no_ind IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', TAX_ID_NO_IND from ' ||
        :OLD.tax_id_no_ind || ' to ' || :NEW.tax_id_no_ind, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date OR 
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR 
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_dnld := SUBSTR(l_dnld || 'U',1, 1); -- 1.1
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date OR 
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR 
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_dnld := SUBSTR(l_dnld || 'U',1, 1); --  1.1
      l_write_aud := 'Y';
    END IF;
    IF :OLD.preferred_currency_code <> :NEW.preferred_currency_code OR 
      (:OLD.preferred_currency_code IS NULL AND :NEW.preferred_currency_code IS NOT NULL) OR 
      (:OLD.preferred_currency_code IS NOT NULL AND :NEW.preferred_currency_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PREFERRED_CURRENCY_CODE from ' ||
        :OLD.preferred_currency_code || ' to ' || :NEW.preferred_currency_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.company_id_no;
    l_dnld := 'D';
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN     
    aud.company_id_no                    := :NEW.company_id_no;
    aud.company_name                     := :NEW.company_name;
    aud.internal_broker_ind              := :NEW.internal_broker_ind;
    aud.consultant_id_no                 := :NEW.consultant_id_no;
    aud.vat_reg_ind                      := :NEW.vat_reg_ind;
    aud.wht_cert_ind                     := :NEW.wht_cert_ind;
    aud.company_agreement_ind            := :NEW.company_agreement_ind;
    aud.referral_agreement_ind           := :NEW.referral_agreement_ind;
    aud.company_reg_doc_ind              := :NEW.company_reg_doc_ind;
    aud.bank_details_ind                 := :NEW.bank_details_ind;
    aud.id_doc_ind                       := :NEW.id_doc_ind;
    aud.letter_of_intent_ind             := :NEW.letter_of_intent_ind;
    aud.dis_agreement_application_ind    := :NEW.dis_agreement_application_ind;
    aud.address_ind                      := :NEW.address_ind;
    aud.tax_id_no_ind                    := :NEW.tax_id_no_ind;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
    aud.preferred_currency_code          := :NEW.preferred_currency_code;
  ELSIF DELETING THEN     
    aud.company_id_no                    := :OLD.company_id_no;
    aud.company_name                     := :OLD.company_name;
    aud.internal_broker_ind              := :OLD.internal_broker_ind;
    aud.consultant_id_no                 := :OLD.consultant_id_no;
    aud.vat_reg_ind                      := :OLD.vat_reg_ind;
    aud.wht_cert_ind                     := :OLD.wht_cert_ind;
    aud.company_agreement_ind            := :OLD.company_agreement_ind;
    aud.referral_agreement_ind           := :OLD.referral_agreement_ind;
    aud.company_reg_doc_ind              := :OLD.company_reg_doc_ind;
    aud.bank_details_ind                 := :OLD.bank_details_ind;
    aud.id_doc_ind                       := :OLD.id_doc_ind;
    aud.letter_of_intent_ind             := :OLD.letter_of_intent_ind;
    aud.dis_agreement_application_ind    := :OLD.dis_agreement_application_ind;
    aud.address_ind                      := :OLD.address_ind;
    aud.tax_id_no_ind                    := :OLD.tax_id_no_ind;
    aud.effective_start_date             := :OLD.effective_start_date;
    aud.effective_end_date               := :OLD.effective_end_date;
    aud.preferred_currency_code          := :OLD.preferred_currency_code;
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := :NEW.username;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  IF l_write_aud = 'Y' THEN
    INSERT INTO COMPANY_AUDIT VALUES aud;
  END IF;

  -- Writing the DNLD_COMPANY Record
  BEGIN
    CASE l_dnld
      WHEN 'I' THEN 
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:NEW.company_id_no
                   ,SYSDATE
                   ,'I'
                   ,0
                   ,TRUNC(SYSDATE)
                   ,:NEW.username);
      WHEN 'U' THEN
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:NEW.company_id_no
                   ,SYSDATE
                   ,'U'
                   ,0
                   ,TRUNC(SYSDATE)
                   ,:NEW.username);
      WHEN 'D' THEN
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:OLD.company_id_no
                   ,SYSDATE
                   ,'D'
                   ,0
                   ,TRUNC(SYSDATE)
                   ,:OLD.username);
      WHEN 'B' THEN
        BEGIN
          INSERT INTO dnld_company
                     (interf_system_id_no
                     ,company_id_no
                     ,stamp_datetime
                     ,stamp_ind
                     ,batch_no
                     ,last_update_datetime
                     ,username)
              VALUES (2
                     ,:NEW.company_id_no
                     ,SYSDATE
                     ,'U'
                     ,0
                     ,TRUNC(SYSDATE)
                     ,:NEW.username);
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            NULL;
        END;
        INSERT INTO dnld_company
                   (interf_system_id_no
                   ,company_id_no
                   ,stamp_datetime
                   ,stamp_ind
                   ,batch_no
                   ,last_update_datetime
                   ,username)
            VALUES (2
                   ,:OLD.company_id_no
                   ,TRUNC(SYSDATE)
                   ,'U'
                   ,0
                   ,TRUNC(SYSDATE)
                   ,:NEW.username);
      ELSE NULL;
    END CASE;
  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
      NULL;
  END;

EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Unhandled Exception', l_scope, null, l_params);
    -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
    -- dbms_output.put_line('Error Message is ' || SQLERRM );
    RAISE;
END COMPANY_AUDIT_BEFORE_TRG;