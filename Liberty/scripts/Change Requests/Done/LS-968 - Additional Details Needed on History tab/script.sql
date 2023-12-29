CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."COMPANY_AUDIT_BEFORE_TRG" 

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
28/08/2017  AMS       Re-Create Trigger 
*/

BEFORE INSERT OR UPDATE OR DELETE ON COMPANY

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud COMPANY_AUDIT%ROWTYPE;
  
BEGIN    

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.COMPANY_ID_NO;
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.COMPANY_ID_NO;
	
    IF :old.COMPANY_ID_NO          <> :new.COMPANY_ID_NO                THEN 
         aud.transaction_desc := aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.COMPANY_ID_NO || ' to ' || :NEW.COMPANY_ID_NO;
    END IF;
	
    IF :old.COMPANY_NAME           <> :new.COMPANY_NAME                 THEN 
         aud.transaction_desc := aud.transaction_desc || ', BROKERAGE_NAME from ' ||
        :OLD.COMPANY_NAME || ' to ' || :NEW.COMPANY_NAME;
    END IF;
	       
    IF :old.INTERNAL_BROKER_IND    <> :new.INTERNAL_BROKER_IND          THEN 
         aud.transaction_desc := aud.transaction_desc || ', INTERNAL_BROKER_IND from ' ||
        :OLD.INTERNAL_BROKER_IND || ' to ' || :NEW.INTERNAL_BROKER_IND;
    END IF;
	       
    IF :old.VAT_REG_IND            <> :new.VAT_REG_IND                  THEN 
         aud.transaction_desc := aud.transaction_desc || ', VAT_REG_IND from ' ||
        :OLD.VAT_REG_IND || ' to ' || :NEW.VAT_REG_IND;
    END IF;
	       
    IF :old.WHT_CERT_IND           <> :new.WHT_CERT_IND                 THEN 
         aud.transaction_desc := aud.transaction_desc || ', WHT_CERT_IND from ' ||
        :OLD.WHT_CERT_IND || ' to ' || :NEW.WHT_CERT_IND;
    END IF;
	       
    IF :old.COMPANY_AGREEMENT_IND  <> :new.COMPANY_AGREEMENT_IND        THEN 
         aud.transaction_desc := aud.transaction_desc || ', BROKERAGE_AGREEMENT_IND from ' ||
        :OLD.COMPANY_AGREEMENT_IND || ' to ' || :NEW.COMPANY_AGREEMENT_IND;
    END IF;
	     
    IF :old.REFERRAL_AGREEMENT_IND <> :new.REFERRAL_AGREEMENT_IND       THEN 
         aud.transaction_desc := aud.transaction_desc || ', REFERRAL_AGREEMENT_IND from ' ||
        :OLD.REFERRAL_AGREEMENT_IND || ' to ' || :NEW.REFERRAL_AGREEMENT_IND;
    END IF;
	       
    IF :old.COMPANY_REG_DOC_IND    <> :new.COMPANY_REG_DOC_IND          THEN 
         aud.transaction_desc := aud.transaction_desc || ', BROKERAGE_REG_DOC_IND from ' ||
        :OLD.COMPANY_REG_DOC_IND || ' to ' || :NEW.COMPANY_REG_DOC_IND;
    END IF;
	       
    IF :old.BANK_DETAILS_IND       <> :new.BANK_DETAILS_IND             THEN 
         aud.transaction_desc := aud.transaction_desc || ', BANK_DETAILS_IND from ' ||
        :OLD.BANK_DETAILS_IND || ' to ' || :NEW.BANK_DETAILS_IND;
    END IF;
	      
    IF :old.ID_DOC_IND             <> :new.ID_DOC_IND                   THEN 
         aud.transaction_desc := aud.transaction_desc || ', ID_DOC_IND from ' ||
        :OLD.ID_DOC_IND || ' to ' || :NEW.ID_DOC_IND;
    END IF;
	       
    IF :old.LETTER_OF_INTENT_IND   <> :new.LETTER_OF_INTENT_IND         THEN 
         aud.transaction_desc := aud.transaction_desc || ', LETTER_OF_INTENT_IND from ' ||
        :OLD.LETTER_OF_INTENT_IND || ' to ' || :NEW.LETTER_OF_INTENT_IND;
    END IF;
	      
    IF :old.DIS_AGREEMENT_APPLICATION_IND    <> :new.DIS_AGREEMENT_APPLICATION_IND THEN 
         aud.transaction_desc := aud.transaction_desc || ', DIS_AGREEMENT_APPLICATION_IND from ' ||
        :OLD.DIS_AGREEMENT_APPLICATION_IND || ' to ' || :NEW.DIS_AGREEMENT_APPLICATION_IND;
    END IF;
	       
    IF :old.ADDRESS_IND            <> :new.ADDRESS_IND                  THEN 
         aud.transaction_desc := aud.transaction_desc || ', ADDRESS_IND from ' ||
        :OLD.ADDRESS_IND || ' to ' || :NEW.ADDRESS_IND;
    END IF;
	       
    IF :old.TAX_ID_NO_IND          <> :new.TAX_ID_NO_IND                THEN 
         aud.transaction_desc := aud.transaction_desc || ', TAX_ID_NO_IND from ' ||
        :OLD.TAX_ID_NO_IND || ' to ' || :NEW.TAX_ID_NO_IND;
    END IF;
	      
    IF :old.PREFERRED_CURRENCY_CODE<> :new.PREFERRED_CURRENCY_CODE      THEN 
         aud.transaction_desc := aud.transaction_desc || ', PREFERRED_CURRENCY_CODE from ' ||
        :OLD.PREFERRED_CURRENCY_CODE || ' to ' || :NEW.PREFERRED_CURRENCY_CODE;
    END IF;
	       
    IF :old.CONSULTANT_ID_NO       <> :new.CONSULTANT_ID_NO             THEN 
         aud.transaction_desc := aud.transaction_desc || ', CONSULTANT from ' ||
        NVL(get_broker_name(:OLD.CONSULTANT_ID_NO),:OLD.CONSULTANT_ID_NO) || ' to ' || nvl(get_broker_name(:NEW.CONSULTANT_ID_NO),:NEW.CONSULTANT_ID_NO);
    END IF;
	
    
--    END IF;
    
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.COMPANY_ID_NO;
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN     
    aud.COMPANY_ID_NO                      := :new.COMPANY_ID_NO                ;        
    aud.COMPANY_NAME                       := :new.COMPANY_NAME                 ;        
    aud.INTERNAL_BROKER_IND                := :new.INTERNAL_BROKER_IND          ;        
    aud.VAT_REG_IND                        := :new.VAT_REG_IND                  ;        
    aud.WHT_CERT_IND                       := :new.WHT_CERT_IND                 ;        
    aud.COMPANY_AGREEMENT_IND              := :new.COMPANY_AGREEMENT_IND        ;        
    aud.REFERRAL_AGREEMENT_IND             := :new.REFERRAL_AGREEMENT_IND       ;        
    aud.COMPANY_REG_DOC_IND                := :new.COMPANY_REG_DOC_IND          ;        
    aud.BANK_DETAILS_IND                   := :new.BANK_DETAILS_IND             ;        
    aud.ID_DOC_IND                         := :new.ID_DOC_IND                   ;        
    aud.LETTER_OF_INTENT_IND               := :new.LETTER_OF_INTENT_IND         ;        
    aud.DIS_AGREEMENT_APPLICATION_IND      := :new.DIS_AGREEMENT_APPLICATION_IND;        
    aud.ADDRESS_IND                        := :new.ADDRESS_IND                  ;        
    aud.TAX_ID_NO_IND                      := :new.TAX_ID_NO_IND                ;        
    aud.PREFERRED_CURRENCY_CODE            := :new.PREFERRED_CURRENCY_CODE      ;        
    aud.CONSULTANT_ID_NO                   := :new.CONSULTANT_ID_NO             ;      
  ELSIF DELETING THEN     
    aud.COMPANY_ID_NO                      := :old.COMPANY_ID_NO                ;        
    aud.COMPANY_NAME                       := :old.COMPANY_NAME                 ;        
    aud.INTERNAL_BROKER_IND                := :old.INTERNAL_BROKER_IND          ;        
    aud.VAT_REG_IND                        := :old.VAT_REG_IND                  ;        
    aud.WHT_CERT_IND                       := :old.WHT_CERT_IND                 ;        
    aud.COMPANY_AGREEMENT_IND              := :old.COMPANY_AGREEMENT_IND        ;        
    aud.REFERRAL_AGREEMENT_IND             := :old.REFERRAL_AGREEMENT_IND       ;        
    aud.COMPANY_REG_DOC_IND                := :old.COMPANY_REG_DOC_IND          ;        
    aud.BANK_DETAILS_IND                   := :old.BANK_DETAILS_IND             ;        
    aud.ID_DOC_IND                         := :old.ID_DOC_IND                   ;        
    aud.LETTER_OF_INTENT_IND               := :old.LETTER_OF_INTENT_IND         ;        
    aud.DIS_AGREEMENT_APPLICATION_IND      := :old.DIS_AGREEMENT_APPLICATION_IND;        
    aud.ADDRESS_IND                        := :old.ADDRESS_IND                  ;        
    aud.TAX_ID_NO_IND                      := :old.TAX_ID_NO_IND                ;        
    aud.PREFERRED_CURRENCY_CODE            := :old.PREFERRED_CURRENCY_CODE      ;        
    aud.CONSULTANT_ID_NO                   := :old.CONSULTANT_ID_NO             ;      
    
    -- In Case we don't want to allow deleting
    -- raise_application_error(-20001,'Deletion not supported on this table');
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := :new.USERNAME;
  aud.transaction_datetime := :new.LAST_UPDATE_DATETIME;

  -- Writing the Audit Record
  INSERT INTO COMPANY_AUDIT VALUES aud;

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END COMPANY_AUDIT_BEFORE_TRG;