/**
* ----------------------------------------------------------------------
* Change Request: Store Local Currency Code (LS-844)
*
* Description  : Find and Store the Currency Code of the local payment on COMMS_CALC_SNAPSHOT
* Author       : Sarel Eybers
* Date         : 2018-01-22
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Extract data from COMMS_CALC_SNAPSHOT
*   2) Drop and recreate COMMS_CALC_SNAPSHOT (Add PAYMENT_CURRENCY_CODE)
*   3) Recreate Triggers and Indexes (Add Index on PAYMENT_CURRENCY_CODE)
*   4) Repopulate COMMS_CALC_SNAPSHOT with PAYMENT_CURRENCY_CODE
*   5) Compile new COMMS_CALC procedure
*   6) Cleanup will happen later
*                */

--  1) Extract data from COMMS_CALC_SNAPSHOT

  CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS844" AS
   SELECT
          COUNTRY_CODE
         ,PRODUCT_CODE
         ,POEP_ID
         ,PERSON_CODE
         ,POLICY_CODE
         ,GROUP_CODE
         ,BROKER_ID_NO
         ,COMPANY_ID_NO
         ,COMMS_PERC
         ,CONTRIBUTION_DATE
         ,PAYMENT_RECEIVE_DATE
         ,FINANCE_RECEIPT_NO
         ,CALCULATION_DATETIME
         ,COMMS_CALC_TYPE_CODE
         ,PAYMENT_RECEIVE_AMT
         ,CASE WHEN ppc.code IS NOT NULL THEN 'P' || ppc.code
               WHEN gpc.code IS NOT NULL THEN 'G' || gpc.code
               ELSE '*LSL' END AS PAYMENT_CURRENCY
         ,COMMS_CALCULATED_AMT
         ,EXCHANGE_RATE
         ,EXCHANGE_RATE_CURRENCY_CODE
         ,COMMS_CALCULATED_EXCH_AMT
         ,INVOICE_NO
         ,LAST_UPDATE_DATETIME
         ,USERNAME
     FROM COMMS_CALC_SNAPSHOT                         ccs
     LEFT OUTER JOIN
          POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA       pol
       ON     ccs.policy_code = pol.code 
          AND tec_ind_last_version = 'Y'
     LEFT OUTER JOIN
          FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA         ppc
           ON pol.prefcur_id = ppc.id
     LEFT OUTER JOIN
          POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA grp
           ON ccs.group_code = grp.code
     LEFT OUTER JOIN
          FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA         gpc
           ON grp.prefcur_id = gpc.id
    WHERE (    grp.object_version_number = (SELECT MAX(object_version_number)
                                              FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                             WHERE code = grp.code) 
            OR grp.object_version_number IS NULL);

  COMMIT;   
   
--  2) Drop and recreate COMMS_CALC_SNAPSHOT (Add PAYMENT_CURRENCY_CODE)

DROP TABLE "LHHCOM"."COMMS_CALC_SNAPSHOT";

@../../../../plsql/tables/lhhcom/comms_calc_snapshot.sql;

--  3) Recreate Triggers and Indexes (Add Index on PAYMENT_CURRENCY_CODE)

@../../../../plsql/Indexes/lhhcom/comms_calc_snap_idx.sql;

--  4) Repopulate COMMS_CALC_SNAPSHOT with PAYMENT_CURRENCY_CODE

  INSERT INTO COMMS_CALC_SNAPSHOT
   SELECT
          COUNTRY_CODE
         ,PRODUCT_CODE
         ,POEP_ID
         ,PERSON_CODE
         ,POLICY_CODE
         ,GROUP_CODE
         ,BROKER_ID_NO
         ,COMPANY_ID_NO
         ,COMMS_PERC
         ,CONTRIBUTION_DATE
         ,PAYMENT_RECEIVE_DATE
         ,FINANCE_RECEIPT_NO
         ,CALCULATION_DATETIME
         ,COMMS_CALC_TYPE_CODE
         ,PAYMENT_RECEIVE_AMT
         ,SUBSTR(PAYMENT_CURRENCY, 2) AS PAYMENT_CURRENCY
         ,COMMS_CALCULATED_AMT
         ,EXCHANGE_RATE
         ,EXCHANGE_RATE_CURRENCY_CODE
         ,COMMS_CALCULATED_EXCH_AMT
         ,INVOICE_NO
         ,LAST_UPDATE_DATETIME
         ,USERNAME
   FROM TEMP_BACKUP_LS844;

  COMMIT;   
   
--  5) Compile new COMMS_CALC procedure

@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;

--  6) Cleanup

--  DROP TABLE "LHHCOM"."TEMP_BACKUP_LS844";

  COMMIT;
  
--  7) Ad Hoc Code

/*

    		  SELECT 
--                 count(*) AllRecords, count(ppc.code) PolicyCurr, count(gpc.code) GroupCurr
                  ccs.person_code, ccs.policy_code, ccs.Group_code, pol.code pol_code, ppc.code pol_curr, grp.code grp_code, gpc.code grp_curr
                 ,CASE WHEN ppc.code IS NOT NULL THEN 'P' || ppc.code
                      WHEN gpc.code IS NOT NULL THEN 'G' || gpc.code
                       ELSE '*LSL' END Derived_Curr
            FROM COMMS_CALC_SNAPSHOT                         ccs
            LEFT OUTER JOIN
                 POL_POLICIES_V@POLICIES.LIBERTY.CO.ZA       pol
              ON ccs.policy_code = pol.code 
             AND tec_ind_last_version = 'Y'
            LEFT OUTER JOIN
                 FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA         ppc
              ON pol.prefcur_id = ppc.id
            LEFT OUTER JOIN
                 POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA grp
              ON ccs.group_code = grp.code
            LEFT OUTER JOIN
                 FCOD_PREFCUR@POLICIES.LIBERTY.CO.ZA         gpc
              ON grp.prefcur_id = gpc.id
           WHERE (    grp.object_version_number = (SELECT MAX(object_version_number)
                                                     FROM POL_GROUP_ACCOUNTS_V@POLICIES.LIBERTY.CO.ZA
                                                    WHERE code = grp.code) 
                   OR grp.object_version_number IS NULL);

*/