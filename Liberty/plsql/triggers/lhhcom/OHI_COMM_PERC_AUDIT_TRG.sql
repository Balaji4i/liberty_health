CREATE OR REPLACE EDITIONABLE TRIGGER "LHHCOM"."OHI_COMM_PERC_AUDIT_TRG" 

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
09/09/2017  SE       Create Trigger 
27/10/2017  SE       Changed how Audit is displayed and added two user fields
07/11/2017  SE       Added constraint to check for valid fields entered.
15/12/2017  Helen    Added recalc process
06/04/2018  SE       Make Changes for transaction_desc < 550 characters
29/01/2019  SE       Ensure that Audit records only get written if something worth auditing changes
*/

BEFORE INSERT OR UPDATE ON OHI_COMM_PERC

FOR EACH ROW

DECLARE

  gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT) || '.';
  l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix;
  l_params logger.tab_param;
  aud OHI_COMM_PERC_AUDIT%ROWTYPE;
  lv_sys_param_date              VARCHAR2(50)           
           := get_system_parameter('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE');
  l_cnt NUMBER; 
  l_recalc VARCHAR(1);
  l_write_aud VARCHAR(1);
  l_poep_id NUMBER (14,0);
  l_product_code VARCHAR2(30);
  l_inse_code VARCHAR2(30);
  l_policy_code VARCHAR2(30);
  l_group_code VARCHAR2(30);
  l_company_id_no NUMBER(9,0);
  l_broker_id_no NUMBER(9,0);
  
    CURSOR c_get_recalc_from_poep_id (l_poep_id NUMBER) IS	
	  SELECT poep.poep_id
	    FROM ohi_enrollment_products     poep
      WHERE poep.poep_id = l_poep_id;
  
    CURSOR c_get_recalc_from_inse_code (l_inse_code VARCHAR2) IS	
	  SELECT poep.poep_id,
           inse.inse_code
      FROM ohi_insured_entities                    inse
	    JOIN ohi_policy_enrollments                  poen
         ON poen.inse_id = inse.inse_id 
	    JOIN ohi_enrollment_products                 poep
	       ON poen.poen_id = poep.poen_id	 
      WHERE inse.inse_code = l_inse_code;
      
    CURSOR c_get_recalc_from_product_code (l_product_code VARCHAR2,l_group_code VARCHAR2) IS	
	     SELECT poep.poep_id,
              prod.product_code,
              grps.group_code
	       FROM ohi_products                prod  
         JOIN ohi_enrollment_products     poep
           ON prod.enpr_id = poep.enpr_id
         JOIN ohi_policy_enrollments      poen  
           ON poep.poen_id  = poen.poen_id
         JOIN ohi_policies                poli
           ON poen.poli_id = poli.poli_id
         JOIN ohi_policy_groups           pogr
           ON poli.poli_id = pogr.poli_id
         JOIN ohi_groups                  grps  
           ON grps.grac_id = pogr.grac_id
	       WHERE prod.product_code = l_product_code;
         
    CURSOR c_get_recalc_from_policy_code (l_policy_code VARCHAR2) IS	
	  SELECT poep.poep_id,
           poli.policy_code
	    FROM ohi_policies                           poli          
      JOIN ohi_policy_enrollments                 poen
         ON poli.poli_id = poen.poli_id
	    JOIN ohi_enrollment_products                poep
	       ON poep.poen_id = poen.poen_id	 
      WHERE poli.policy_code = l_policy_code; 
      
    CURSOR c_get_recalc_from_group_code (l_group_code VARCHAR2) IS	
	  SELECT poep.poep_id,
           poen.poen_id,
           grps.group_code
      FROM ohi_groups                  grps     
	    JOIN  ohi_policy_groups          pogr
         ON grps.grac_id = pogr.grac_id
      JOIN ohi_policy_enrollments      poen
         ON poen.poli_id = pogr.poli_id
	    JOIN ohi_enrollment_products     poep
	       ON poep.poen_id = poen.poen_id	 
      WHERE grps.group_code = l_group_code;
      
    CURSOR c_get_recalc_from_company (l_company_id_no NUMBER) IS	
	  SELECT poep.poep_id,
           comp.company_id_no
	    FROM company                                comp
      JOIN ohi_policy_brokers                     pobr
        ON comp.company_id_no = pobr.company_id_no 
      JOIN ohi_policy_enrollments                 poen
        ON pobr.poli_id = poen.poli_id   
	    JOIN ohi_enrollment_products                poep
	       ON poep.poen_id = poen.poen_id	 
      WHERE comp.company_id_no = l_company_id_no; 
    
    CURSOR c_get_recalc_from_broker (l_broker_id_no NUMBER) IS	
	  SELECT poep.poep_id,
           brok.broker_id_no
	    FROM broker                                 brok
      JOIN ohi_policy_brokers                     pobr
        ON brok.broker_id_no = pobr.broker_id_no 
      JOIN ohi_policy_enrollments                 poen
        ON pobr.poli_id = poen.poli_id   
	    JOIN ohi_enrollment_products                poep
	       ON poep.poen_id = poen.poen_id	 
      WHERE brok.broker_id_no = l_broker_id_no;   
 
BEGIN    

  l_write_aud := 'N';
  -- Checking that valid values were entered in the Codes . . .
  IF  -- Not NULL Values Check
         :NEW.company_id_no IS NULL 
     AND :NEW.broker_id_no  IS NULL
     AND :NEW.group_code    IS NULL
     AND :NEW.product_code  IS NULL
     AND :NEW.policy_code   IS NULL
     AND :NEW.inse_code   IS NULL
     AND :NEW.poep_id       IS NULL THEN
    raise_application_error(-20007,'Error: NULL values entered for all Key Fields');
  END IF; -- Not NULL Values Check
  -- Checking the Company ID
  IF :NEW.company_id_no IS NOT NULL THEN
    IF isvalid_company_id_no(:NEW.company_id_no) = 'FALSE' THEN
      raise_application_error(-20007,'Error: COMPANY_ID_NO '|| :NEW.company_id_no || ' does not exist.');
    END IF;
    IF   :NEW.broker_id_no IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: BROKER_ID_NO must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.group_code   IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: GROUP_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.product_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: PRODUCT_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when COMPANY_ID_NO is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when COMPANY_ID_NO is populated');
    END IF;
  END IF; -- Checking the Company ID
  -- Checking the Broker ID
  IF :NEW.broker_id_no IS NOT NULL THEN
    IF isvalid_broker_id_no(:NEW.broker_id_no) = 'FALSE' THEN
      raise_application_error(-20007,'Error: BROKER_ID_NO '|| :NEW.broker_id_no || ' does not exist.');
    END IF;
    IF   :NEW.group_code   IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: GROUP_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.product_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: PRODUCT_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when BROKER_ID_NO is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when BROKER_ID_NO is populated');
    END IF;
  END IF; -- Checking the Broker ID
  -- Checking the Group Code
  IF :NEW.group_code IS NOT NULL THEN
    IF isvalid_group_code(:NEW.group_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: GROUP_CODE '|| :NEW.group_code || ' does not exist.');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when GROUP_CODE is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when GROUP_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when GROUP_CODE is populated');
    END IF;
  END IF; -- Checking the Group Code
  -- Checking the Product Code
  IF :NEW.product_code IS NOT NULL THEN
    IF isvalid_product_code(:NEW.product_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: PRODUCT_CODE '|| :NEW.product_code || ' does not exist.');
    END IF;
    IF   :NEW.policy_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POLICY_CODE must be NULL when PRODUCT_CODE is populated');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when PRODUCT_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when PRODUCT_CODE is populated');
    END IF;
  END IF; -- Checking the Product Code
  -- Checking the Policy Code
  IF :NEW.policy_code IS NOT NULL THEN
    IF isvalid_policy_code(:NEW.policy_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: POLICY_CODE '|| :NEW.policy_code || ' does not exist.');
    END IF;
    IF   :NEW.inse_code IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: INSE_CODE must be NULL when POLICY_CODE is populated');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when POLICY_CODE is populated');
    END IF;
  END IF; -- Checking the Policy Code
  -- Checking the Person Code
  IF :NEW.inse_code IS NOT NULL THEN
    IF isvalid_person_code(:NEW.inse_code) = 'FALSE' THEN
      raise_application_error(-20007,'Error: INSE_CODE '|| :NEW.inse_code || ' does not exist.');
    END IF;
    IF   :NEW.poep_id IS NOT NULL THEN
      raise_application_error(-20008,'Data Integrity Error: POEP_ID must be NULL when INSE_CODE is populated');
    END IF;
  END IF; -- Checking the Person Code
  -- Checking the POEP ID
  IF :NEW.poep_id IS NOT NULL THEN
    IF isvalid_poep_id(:NEW.poep_id) = 'FALSE' THEN
      raise_application_error(-20007,'Error: POEP_ID '|| :NEW.poep_id || ' does not exist.');
    END IF;
  END IF; -- Checking the POEP ID

  -- Writing away the Audit record . . .
  -- Setting the Transaction Description
  IF INSERTING THEN
    aud.transaction_desc := 'Added new record' ||
      CASE WHEN :NEW.company_id_no IS NOT NULL THEN ' COMPANY-' || :NEW.company_id_no END ||
      CASE WHEN :NEW.broker_id_no  IS NOT NULL THEN ' BROKER-'  || :NEW.broker_id_no  END ||
      CASE WHEN :NEW.group_code    IS NOT NULL THEN ' GROUP-'   || :NEW.group_code    END ||
      CASE WHEN :NEW.product_code  IS NOT NULL THEN ' PRODUCT-' || :NEW.product_code  END ||
      CASE WHEN :NEW.policy_code   IS NOT NULL THEN ' POLICY-'  || :NEW.policy_code   END ||
      CASE WHEN :NEW.inse_code     IS NOT NULL THEN ' INSE-'    || :NEW.inse_code     END ||
      CASE WHEN :NEW.poep_id       IS NOT NULL THEN ' POEP-'    || :NEW.poep_id       END;
    l_write_aud := 'Y';
  ELSIF UPDATING THEN
    aud.transaction_desc := 'Changed record' ||
      CASE WHEN :OLD.company_id_no IS NOT NULL THEN ' COMPANY-' || :OLD.company_id_no END ||
      CASE WHEN :OLD.broker_id_no  IS NOT NULL THEN ' BROKER-'  || :OLD.broker_id_no  END ||
      CASE WHEN :OLD.group_code    IS NOT NULL THEN ' GROUP-'   || :OLD.group_code    END ||
      CASE WHEN :OLD.product_code  IS NOT NULL THEN ' PRODUCT-' || :OLD.product_code  END ||
      CASE WHEN :OLD.policy_code   IS NOT NULL THEN ' POLICY-'  || :OLD.policy_code   END ||
      CASE WHEN :OLD.inse_code     IS NOT NULL THEN ' INSE-'    || :OLD.inse_code     END ||
      CASE WHEN :OLD.poep_id       IS NOT NULL THEN ' POEP-'    || :OLD.poep_id       END;
    IF :OLD.product_code <> :NEW.product_code OR 
      (:OLD.product_code IS NULL AND :NEW.product_code IS NOT NULL) OR 
      (:OLD.product_code IS NOT NULL AND :NEW.product_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', PRODUCT_CODE from ' ||
        :OLD.product_code || ' to ' || :NEW.product_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.poep_id <> :NEW.poep_id OR 
      (:OLD.poep_id IS NULL AND :NEW.poep_id IS NOT NULL) OR 
      (:OLD.poep_id IS NOT NULL AND :NEW.poep_id IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POEP_ID from ' ||
        :OLD.poep_id || ' to ' || :NEW.poep_id, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.inse_code <> :NEW.inse_code OR 
      (:OLD.inse_code IS NULL AND :NEW.inse_code IS NOT NULL) OR 
      (:OLD.inse_code IS NOT NULL AND :NEW.inse_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', INSE_CODE from ' ||
        :OLD.inse_code || ' to ' || :NEW.inse_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.policy_code <> :NEW.policy_code OR 
      (:OLD.policy_code IS NULL AND :NEW.policy_code IS NOT NULL) OR 
      (:OLD.policy_code IS NOT NULL AND :NEW.policy_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', POLICY_CODE from ' ||
        :OLD.policy_code || ' to ' || :NEW.policy_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.group_code <> :NEW.group_code OR 
      (:OLD.group_code IS NULL AND :NEW.group_code IS NOT NULL) OR 
      (:OLD.group_code IS NOT NULL AND :NEW.group_code IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', GROUP_CODE from ' ||
        :OLD.group_code || ' to ' || :NEW.group_code, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.broker_id_no <> :NEW.broker_id_no OR 
      (:OLD.broker_id_no IS NULL AND :NEW.broker_id_no IS NOT NULL) OR 
      (:OLD.broker_id_no IS NOT NULL AND :NEW.broker_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', BROKER_ID_NO from ' ||
        :OLD.broker_id_no || ' to ' || :NEW.broker_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.company_id_no <> :NEW.company_id_no OR 
      (:OLD.company_id_no IS NULL AND :NEW.company_id_no IS NOT NULL) OR 
      (:OLD.company_id_no IS NOT NULL AND :NEW.company_id_no IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMPANY_ID_NO from ' ||
        :OLD.company_id_no || ' to ' || :NEW.company_id_no, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.comm_perc <> :NEW.comm_perc OR 
      (:OLD.comm_perc IS NULL AND :NEW.comm_perc IS NOT NULL) OR 
      (:OLD.comm_perc IS NOT NULL AND :NEW.comm_perc IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMM_PERC from ' ||
        :OLD.comm_perc || ' to ' || :NEW.comm_perc, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.comm_desc <> :NEW.comm_desc OR 
      (:OLD.comm_desc IS NULL AND :NEW.comm_desc IS NOT NULL) OR 
      (:OLD.comm_desc IS NOT NULL AND :NEW.comm_desc IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', COMM_DESC from ' ||
        :OLD.comm_desc || ' to ' || :NEW.comm_desc, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_start_date <> :NEW.effective_start_date OR 
      (:OLD.effective_start_date IS NULL AND :NEW.effective_start_date IS NOT NULL) OR 
      (:OLD.effective_start_date IS NOT NULL AND :NEW.effective_start_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_START_DATE from ' ||
        :OLD.effective_start_date || ' to ' || :NEW.effective_start_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.effective_end_date <> :NEW.effective_end_date OR 
      (:OLD.effective_end_date IS NULL AND :NEW.effective_end_date IS NOT NULL) OR 
      (:OLD.effective_end_date IS NOT NULL AND :NEW.effective_end_date IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', EFFECTIVE_END_DATE from ' ||
        :OLD.effective_end_date || ' to ' || :NEW.effective_end_date, 1, 550);
      l_write_aud := 'Y';
    END IF;
    IF :OLD.created_username <> :NEW.created_username OR 
      (:OLD.created_username IS NULL AND :NEW.created_username IS NOT NULL) OR 
      (:OLD.created_username IS NOT NULL AND :NEW.created_username IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', CREATED_USERNAME from ' ||
        :OLD.created_username || ' to ' || :NEW.created_username, 1, 550);
      l_write_aud := 'Y';
    END IF; 
    IF :OLD.auth_username <> :NEW.auth_username OR 
      (:OLD.auth_username IS NULL AND :NEW.auth_username IS NOT NULL) OR 
      (:OLD.auth_username IS NOT NULL AND :NEW.auth_username IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', AUTH_USERNAME from ' ||
        :OLD.auth_username || ' to ' || :NEW.auth_username, 1, 550);
      IF :OLD.auth_username IS NULL and :NEW.auth_username IS NOT NULL THEN
	      l_recalc := 'Y';
      END IF;   
      l_write_aud := 'Y';
    END IF;
    IF :OLD.reject_username <> :NEW.reject_username OR 
      (:OLD.reject_username IS NULL AND :NEW.reject_username IS NOT NULL) OR 
      (:OLD.reject_username IS NOT NULL AND :NEW.reject_username IS NULL) THEN
      aud.transaction_desc := SUBSTR(aud.transaction_desc || ', REJECT_USERNAME from ' ||
        :OLD.reject_username || ' to ' || :NEW.reject_username, 1, 550);
      l_write_aud := 'Y';
    END IF;
  END IF;

  -- Setting the logger values in case
  logger.append_param(l_params, 'Action:', aud.transaction_desc);

  -- Setting the Audit row values
  IF INSERTING OR UPDATING THEN
    aud.product_code                     := :NEW.product_code;
    aud.poep_id                          := :NEW.poep_id;
    aud.inse_code                        := :NEW.inse_code;
    aud.policy_code                      := :NEW.policy_code;
    aud.group_code                       := :NEW.group_code;
    aud.broker_id_no                     := :NEW.broker_id_no;
    aud.company_id_no                    := :NEW.company_id_no;
    aud.comm_perc                        := :NEW.comm_perc;
    aud.comm_desc                        := :NEW.comm_desc;
  	aud.auth_username                    := :NEW.auth_username;
	  aud.created_username                 := :NEW.created_username;
    aud.effective_start_date             := :NEW.effective_start_date;
    aud.effective_end_date               := :NEW.effective_end_date;
  	aud.created_username                 := :NEW.created_username;
  	aud.auth_username                    := :NEW.auth_username;
  ELSE
    raise_application_error(-20002,'Not INSERTING, UPDATING or DELETING. Please contact IT Support');
  END IF;
  
  -- Setting the Audit User and Date values
  aud.transaction_username := :NEW.USERNAME;
  aud.transaction_datetime := SYSDATE;

  -- Writing the Audit Record
  IF l_write_aud = 'Y' THEN
    INSERT INTO OHI_COMM_PERC_AUDIT VALUES aud;
  END IF;
  
    -- Setting the Commissions_Recalc row values

   l_poep_id       := :OLD.poep_id;
	 -- dbms_output.put_line('Just before loop  for POEP_ID OHI_COMM_PERC_AUDIT_TRG ' || l_poep_id); 
   l_product_code  := :OLD.product_code;
   l_inse_code     := :OLD.inse_code;
   l_policy_code   := :OLD.policy_code;
   l_group_code    := :OLD.group_code;
   l_broker_id_no  := :OLD.broker_id_no;
   l_company_id_no := :OLD.company_id_no;

   
   IF l_poep_id IS NOT NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_poep_id (l_poep_id) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Poep_id,Poep_id ' || l_poep_id || ' ' || x.poep_id); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;

ELSIF l_inse_code IS NOT NULL 

    THEN BEGIN
    FOR x IN c_get_recalc_from_inse_code (l_inse_code) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Inse_code,inse_code ' || l_inse_code || ' ' || x.inse_code); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;

ELSIF l_product_code IS NOT NULL AND l_group_code IS NOT NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_product_code (l_product_code, l_group_code) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Product_code,product_code ' || l_product_code || ' ' || x.product_code); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;

   ELSIF l_group_code IS NOT NULL AND l_product_code IS NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_group_code (l_group_code) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Group_code,group_code ' || l_group_code || ' ' || x.group_code); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;
  
 ELSIF l_policy_code IS NOT NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_policy_code (l_policy_code) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Policy_code,policy_code ' || l_policy_code || ' ' || x.policy_code); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;

ELSIF l_company_id_no IS NOT NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_company (l_company_id_no) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Company_id_no,company_id_no ' || l_company_id_no || ' ' || x.company_id_no); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;


ELSIF l_broker_id_no IS NOT NULL
    THEN BEGIN
    FOR x IN c_get_recalc_from_broker (l_broker_id_no) LOOP
       BEGIN

	     IF       l_recalc = 'Y'    THEN 
          BEGIN
             --dbms_output.put_line('Broker_id_no, broker_id_no ' || l_broker_id_no || ' ' || x.broker_id_no); 
             INSERT INTO COMMS_RECALC (poep_id, processed_date, description, last_update_datetime, username) 
                    VALUES (x.poep_id,to_date(lv_sys_param_date) ,'Source : OHI_COMM_PERC ', SYSDATE, USER); 
              
              
               EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                          NULL;
                          
		       END;
		
  	   END IF;
	    END; 
	 END LOOP;  
  END;
END IF;

 -- end of all loops

  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Unhandled Exception', l_scope, null, l_params);
      -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
      -- dbms_output.put_line('Error Message is ' || SQLERRM );
      RAISE;
END OHI_COMM_PERC_AUDIT_TRG;
/
ALTER TRIGGER "LHHCOM"."OHI_COMM_PERC_AUDIT_TRG" ENABLE;
/