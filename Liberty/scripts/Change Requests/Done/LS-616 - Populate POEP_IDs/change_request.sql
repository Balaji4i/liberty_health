/**
* ----------------------------------------------------------------------
* Change Request: Populate POEP_IDs in COMMS_CALC_SNAPSHOT (LS-616)
*
* Description  : Find and Update the POEP_IDs in COMMS_CALC_SNAPSHOT
* Author       : Sarel Eybers
* Date         : 2018-01-30
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Make a Backup to delete later
*   2) Compile Package and Function
*   3) Update all possible records
*   4) Cleanup
*                */

--  1) Make a Backup to delete later

  CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS616" AS
   SELECT
          "COUNTRY_CODE"                
         ,"PRODUCT_CODE"                
         ,"POEP_ID"                     
         ,"PERSON_CODE"                 
         ,"POLICY_CODE"                 
         ,"GROUP_CODE"                  
         ,"BROKER_ID_NO"                
         ,"COMPANY_ID_NO"               
         ,"COMMS_PERC"                  
         ,"CONTRIBUTION_DATE"           
         ,"PAYMENT_RECEIVE_DATE"        
         ,"FINANCE_RECEIPT_NO"          
         ,"CALCULATION_DATETIME"        
         ,"COMMS_CALC_TYPE_CODE"        
         ,"PAYMENT_RECEIVE_AMT"         
         ,"COMMS_CALCULATED_AMT"        
         ,"EXCHANGE_RATE"               
         ,"EXCHANGE_RATE_CURRENCY_CODE" 
         ,"COMMS_CALCULATED_EXCH_AMT"   
         ,"INVOICE_NO"                  
         ,"LAST_UPDATE_DATETIME"        
         ,"USERNAME"                    
   FROM COMMS_CALC_SNAPSHOT;

  COMMIT;   
   
--  2) Compile Package and Function

@../../../../plsql/packages/lhhcom/commissions_pkg.sql;
@../../../../plsql/functions/lhhcom/get_poep_id.sql;

--  3) Update all possible records

UPDATE COMMS_CALC_SNAPSHOT
  SET poep_id = NVL(CASE WHEN isvalid_person_code(PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_person => PERSON_CODE)
                         WHEN isvalid_policy_code(PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => PERSON_CODE)
                         WHEN isvalid_policy_code(POLICY_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => POLICY_CODE)
                    END, 0)
 WHERE poep_id = 0;
 
COMMIT;   
   
--  3) Cleanup

--  DROP TABLE "LHHCOM"."TEMP_BACKUP_LS616";

--  4) Ad Hoc Code

/*

   SELECT count(*)
     FROM COMMS_CALC_SNAPSHOT
    WHERE POEP_ID != '0';

   SELECT 
          POEP_ID                     
         ,PERSON_CODE                 
         ,POLICY_CODE                 
         ,CONTRIBUTION_DATE                 
--         ,get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => PERSON_CODE) as VAL1
--         ,get_poep_id(p_date => CONTRIBUTION_DATE, p_person => PERSON_CODE) as VAL2
         ,CASE WHEN isvalid_person_code(PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_person => PERSON_CODE)
               WHEN isvalid_person_code(POLICY_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_person => POLICY_CODE)
               WHEN isvalid_policy_code(PERSON_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => PERSON_CODE)
               WHEN isvalid_policy_code(POLICY_CODE)  = 'TRUE' THEN get_poep_id(p_date => CONTRIBUTION_DATE, p_policy => POLICY_CODE)
               ELSE 0
           END AS UPD_POEP_ID
     FROM COMMS_CALC_SNAPSHOT
    WHERE COMMS_CALC_TYPE_CODE != 'T';
    WHERE PERSON_CODE like '02566194%';

*/