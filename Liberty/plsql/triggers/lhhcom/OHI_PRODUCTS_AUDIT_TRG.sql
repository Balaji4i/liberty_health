create or replace TRIGGER "LHHCOM"."OHI_PRODUCTS_AUDIT_TRG" 

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
22/11/2017  Helen    added recalc process
07/02/2018  Helen    corrected recalc cursor to include more poep_ids
03/05/2018  Helen    simplified cursor again to eliminate mutation.
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE OR DELETE ON OHI_PRODUCTS

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_PRODUCTS_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
                                 := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_enpr_id NUMBER (14,0);
	
CURSOR c_get_changes_to_recalc (l_enpr_id NUMBER) IS	
	SELECT DISTINCT poep.poep_id
	  FROM ohi_enrollment_products     poep
	    WHERE poep.enpr_id = l_enpr_id;
	
/*
CURSOR c_get_changes_to_recalc (l_enpr_id NUMBER) IS	
	SELECT poep.poep_id
        ,prod.product_code
        ,aliprod.enpr_id
	  FROM ohi_products                prod
    JOIN ohi_products                aliprod
      ON prod.product_code = aliprod.product_code
    JOIN ohi_enrollment_products     poep
      ON poep.enpr_id = prod.enpr_id
	    WHERE prod.enpr_id = l_enpr_id;
*/
  
BEGIN    

 --dbms_output.put_line('In trigger for PROD OHI_PRODUCTS '); 
  l_write_aud := 'N';

  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Created ' || :NEW.enpr_id;
    l_recalc := 'Y';
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record ' || :OLD.enpr_id;
    IF :OLD.enpr_id <> :NEW.enpr_id OR 
      (:OLD.enpr_id IS NULL AND :NEW.enpr_id IS NOT NULL) OR 
      (:OLD.enpr_id IS NOT NULL AND :NEW.enpr_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', ENPR_ID from ' ||
        :OLD.enpr_id || ' to ' || :NEW.enpr_id, 1, 550);
	    l_recalc := 'Y';	
      l_write_aud := 'Y';
    END IF;
    IF :OLD.product_code <> :NEW.product_code OR 
      (:OLD.product_code IS NULL AND :NEW.product_code IS NOT NULL) OR 
      (:OLD.product_code IS NOT NULL AND :NEW.product_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PRODUCT_CODE from ' ||
        :OLD.product_code || ' to ' || :NEW.product_code, 1, 550);
  	  l_recalc := 'Y';
      l_write_aud := 'Y';
    END IF;
    IF :OLD.country_code <> :NEW.country_code OR 
      (:OLD.country_code IS NULL AND :NEW.country_code IS NOT NULL) OR 
      (:OLD.country_code IS NOT NULL AND :NEW.country_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COUNTRY_CODE from ' ||
        :OLD.country_code || ' to ' || :NEW.country_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.product_name <> :NEW.product_name OR 
      (:OLD.product_name IS NULL AND :NEW.product_name IS NOT NULL) OR 
      (:OLD.product_name IS NOT NULL AND :NEW.product_name IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PRODUCT_NAME from ' ||
        :OLD.product_name || ' to ' || :NEW.product_name, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.product_descr <> :NEW.product_descr OR 
      (:OLD.product_descr IS NULL AND :NEW.product_descr IS NOT NULL) OR 
      (:OLD.product_descr IS NOT NULL AND :NEW.product_descr IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PRODUCT_DESCR from ' ||
        :OLD.product_descr || ' to ' || :NEW.product_descr, 1, 550);
      l_write_aud := 'Y';
    END IF;
  ELSIF DELETING THEN
    aud.transaction_desc := 'Deleted record ' || :OLD.enpr_id;
    l_write_aud := 'Y';
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.enpr_id                          := :NEW.enpr_id;
    aud.product_code                     := :NEW.product_code;
    aud.country_code                     := :NEW.country_code;
    aud.product_name                     := :NEW.product_name;
    aud.product_descr                    := :NEW.product_descr;
  ELSIF DELETING THEN
    aud.enpr_id                          := :OLD.enpr_id;
    aud.product_code                     := :OLD.product_code;
    aud.country_code                     := :OLD.country_code;
    aud.product_name                     := :OLD.product_name;
    aud.product_descr                    := :OLD.product_descr;
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
    INSERT INTO OHI_PRODUCTS_AUDIT VALUES aud;
  END IF;
  
  -- Setting the Commissions_Recalc row values

   l_enpr_id := :OLD.enpr_id;
	 --dbms_output.put_line('Just before loop  for POEP_ID OHI_PRODUCTS ' || l_enpr_id); 


    FOR x IN c_get_changes_to_recalc (l_enpr_id) LOOP
       BEGIN
   
   --   dbms_output.put_line('In loop  for POEP_ID OHI_PRODUCTS ' || l_enpr_id || ' ' || l_recalc); 

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
               INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) , 'Source : OHI_PRODUCTS ', SYSDATE, USER); 
              
              
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
END OHI_PRODUCTS_AUDIT_TRG;