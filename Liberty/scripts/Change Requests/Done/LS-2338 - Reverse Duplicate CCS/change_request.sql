/**
* ----------------------------------------------------------------------
* Change Request: Reverse Duplicate CCS records (BAU-1887/LS-2338)
*
* Description  : Reverse Duplicate CCS records
*                Request number got changed to LS-2338
* Author       : Sarel Eybers
* Date         : 2018-10-18
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Reverse duplicates
*                                                                         */

CREATE TABLE "LHHCOM"."DATAFIX_BACKUP_LS2338" AS
  SELECT * FROM comms_calc_snapshot WHERE comms_calc_snapshot_no IN (13594, 13595, 13596, 13597, 13598, 13599, 13600,
                    13601, 13602, 13603, 13604, 13605, 13606, 13607, 13608, 13609, 13610, 13611, 13612, 13613, 13614,
                    13615, 13616, 13617, 13618, 13619, 13620, 13621, 13622, 13623, 13624, 13625, 13626, 13627, 13628,
                    13629, 13630, 13631, 13632, 13633, 13634, 13635, 13636, 14271, 14272, 14273, 14274, 14275, 14276,
                    14277, 14278, 14279, 14280, 35887, 35888, 35889, 35890, 35891, 35892, 35893, 35894, 35895, 35896,
                    35897, 35898, 35899, 35900, 35901, 35902, 35903, 35904, 35905, 35906, 35907, 35908, 35909, 35910,
                    35911, 35912, 35913, 35914, 35915, 35916, 35917, 35918, 35919, 35920, 35921, 35922, 35923, 35924,
                    35925, 35926, 35927, 35928, 35929, 35930, 35931, 35932, 35933, 35934, 35935, 35936, 35937, 35938,
                    35939, 35940, 35941, 35942, 35943, 35944, 35945, 35946, 35947, 35948, 35949, 35950, 35951, 35952,
                    35953, 35954, 35955, 35956, 35957, 35958, 35959, 35960, 35961, 35962, 35963, 35964, 35965, 35966,
                    35967, 35968, 35969, 35970, 35971, 35972, 35973, 35974, 35975, 35976, 35977, 35978, 35979, 35980,
                    35981, 35982, 35983, 35984, 35985, 35986, 35987, 35988, 35989, 35990, 35991, 35992, 35993, 35994,
                    35995, 35996, 35997, 35998, 35999, 36000, 36001, 36002, 36003, 36004, 36005, 36006, 36007, 36008,
                    36009, 36010, 36011, 36012, 36013, 36014, 36015, 36016, 36017, 36018, 36019, 36020, 36021, 36022,
                    36023, 36024, 36025, 36026, 36027, 36028, 36029, 36030, 36031, 36032, 36033, 36034, 36035, 36036,
                    36037, 36038, 36039, 36040, 36041, 36042, 36043, 36044, 36045, 36046, 36047, 37464, 37465, 37466);

COMMIT;

/

SET SERVEROUTPUT ON;

DECLARE

CURSOR c_ccs_to_reverse IS
  SELECT 
         ccs.comms_calc_snapshot_no
        ,ccs.country_code
        ,ccs.product_code
        ,ccs.poep_id
        ,ccs.person_code
        ,ccs.policy_code
        ,ccs.group_code
        ,ccs.broker_id_no
        ,ccs.company_id_no
        ,ccs.comms_perc
        ,ccs.contribution_date
        ,ccs.payment_receive_date
        ,ccs.finance_receipt_no
        ,ccs.calculation_datetime
        ,ccs.payment_receive_amt
        ,ccs.payment_currency
        ,ccs.comms_calculated_amt
        ,ccs.exchange_rate
        ,ccs.exchange_rate_currency_code
        ,ccs.comms_calculated_exch_amt
        ,cct.trace_original_snapshot_no
    FROM (
          SELECT 14280 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14277 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14273 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14279 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14271 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14276 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14275 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14278 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14274 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 14272 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36003 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35996 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35993 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36019 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35899 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35987 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35940 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36022 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35896 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35981 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35907 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35960 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35936 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36007 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36040 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36035 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36030 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35969 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35926 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36010 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35947 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35966 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35900 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35984 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36021 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35908 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35964 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35925 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36000 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35894 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35963 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35887 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35989 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35919 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36008 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35937 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35980 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35903 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36012 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35943 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35999 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35942 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36044 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36034 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35934 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36013 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35953 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35970 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35948 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35968 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35890 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36016 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35938 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36042 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35931 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35982 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35895 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36023 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35939 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35967 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35909 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36043 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35902 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35971 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35933 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36045 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35951 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36039 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36005 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35941 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35990 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35965 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35922 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35986 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35932 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35977 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35923 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35956 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35995 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35975 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35950 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36033 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35916 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35985 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35888 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36017 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35958 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36031 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35935 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36006 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35920 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35992 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35898 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35959 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35891 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36028 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35893 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36020 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35945 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35991 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35944 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36026 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35889 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36014 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35988 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35901 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35957 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35910 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36036 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35954 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36047 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35955 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36009 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35911 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36041 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35904 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35978 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35946 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35974 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36025 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35921 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35972 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35914 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36032 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35997 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35949 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36011 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36046 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35998 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35912 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36027 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35905 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35961 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35924 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36038 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35906 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35962 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35915 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35976 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35928 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35983 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35927 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35973 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35930 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36024 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35952 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36004 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35929 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36018 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36001 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35917 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36029 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35918 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36002 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36037 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35897 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 36015 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35913 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35994 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35892 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 35979 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13627 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13606 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13628 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13611 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13630 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13612 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13607 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13613 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13596 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13614 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13615 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13597 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13616 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13598 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13617 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13618 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13619 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13600 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13620 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13601 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13621 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13602 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13599 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13622 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13623 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13603 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13624 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13604 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13625 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13605 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13626 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13594 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13629 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13608 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13631 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13609 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13632 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13633 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13610 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13634 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13635 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13595 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 13636 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 37465 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 37464 comms_calc_snapshot_no FROM DUAL UNION ALL
          SELECT 37466 comms_calc_snapshot_no FROM DUAL
         )                                                       ccsu
    LEFT OUTER
    JOIN comms_calc_snapshot                                     ccs
      ON ccs.comms_calc_snapshot_no = ccsu.comms_calc_snapshot_no
    LEFT OUTER 
    JOIN comms_calc_trace                                        cct
      ON ccs.comms_calc_snapshot_no = cct.comms_calc_snapshot_no
   ORDER BY ccsu.comms_calc_snapshot_no;

  ccs                            comms_calc_snapshot%ROWTYPE;
  cct                            comms_calc_trace%ROWTYPE;
  l_insert_cct                   BOOLEAN;

BEGIN
   
  FOR x IN c_ccs_to_reverse LOOP
    BEGIN 
      BEGIN -- Write the negative CCS record
        ccs.comms_calc_snapshot_no      := comms_calc_snapshot_seq.NEXTVAL();
        ccs.country_code                := x.country_code;
        ccs.product_code                := x.product_code;
        ccs.poep_id                     := x.poep_id;
        ccs.person_code                 := x.person_code;
        ccs.policy_code                 := x.policy_code;
        ccs.group_code                  := x.group_code;
        ccs.broker_id_no                := x.broker_id_no;
        ccs.company_id_no               := x.company_id_no;
        ccs.comms_perc                  := x.comms_perc;
        ccs.contribution_date           := x.contribution_date;
        ccs.payment_receive_date        := x.payment_receive_date;
        ccs.finance_receipt_no          := x.finance_receipt_no;
        ccs.calculation_datetime        := x.calculation_datetime;
        ccs.comms_calc_type_code        := 'R';
        ccs.payment_receive_amt         := x.payment_receive_amt * -1;
        ccs.payment_currency            := x.payment_currency;
        ccs.comms_calculated_amt        := x.comms_calculated_amt * -1;
        ccs.exchange_rate               := x.exchange_rate;
        ccs.exchange_rate_currency_code := x.exchange_rate_currency_code;
        ccs.comms_calculated_exch_amt   := x.comms_calculated_exch_amt * -1;
        ccs.invoice_no                  := NULL;
        ccs.last_update_datetime        := SYSDATE;
        ccs.username                    := 'BAU-1887';
        l_insert_cct                    := TRUE;
        INSERT INTO comms_calc_snapshot VALUES ccs;              
        dbms_output.put_line('Insert Reversal:   Snapshot No ('|| x.comms_calc_snapshot_no || 
                                             '), Group (' || x.group_code || 
                                             '), Product (' || x.product_code ||
                                             '), Policy (' || x.policy_code || 
                                             '), Person (' || x.person_code || 
                                          ') and Contribution Date (' || x.contribution_date || 
                                          ') for Brokerage (' || x.company_id_no ||
                                          ') and Percentage (' || x.comms_perc || ')');
      EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
          l_insert_cct                  := FALSE;
          dbms_output.put_line('Sum Dupl Reversal: Snapshot No ('|| x.comms_calc_snapshot_no || 
                                               '), Group (' || x.group_code || 
                                               '), Product (' || x.product_code ||
                                               '), Policy (' || x.policy_code || 
                                               '), Person (' || x.person_code || 
                                            ') and Contribution Date (' || x.contribution_date || 
                                            ') for Brokerage (' || x.company_id_no ||
                                            ') and Percentage (' || x.comms_perc || ')');
          UPDATE comms_calc_snapshot
             SET comms_calculated_amt        = comms_calculated_amt + x.comms_calculated_amt * -1,
                 comms_calculated_exch_amt   = comms_calculated_exch_amt + x.comms_calculated_exch_amt * -1,
                 payment_receive_amt         = payment_receive_amt + x.payment_receive_amt * -1,
                 last_update_datetime        = SYSDATE,
                 username                    = 'BAU-1887'
           WHERE country_code                = x.country_code
             AND product_code                = x.product_code
             AND poep_id                     = x.poep_id
             AND person_code                 = x.person_code
             AND policy_code                 = x.policy_code
             AND group_code                  = x.group_code
             AND broker_id_no                = x.broker_id_no
             AND company_id_no               = x.company_id_no
             AND contribution_date           = x.contribution_date
             AND payment_receive_date        = x.payment_receive_date
             AND finance_receipt_no          = x.finance_receipt_no
             AND calculation_datetime        = x.calculation_datetime
             AND comms_calc_type_code        = 'R'
             AND payment_currency            = x.payment_currency
             AND exchange_rate_currency_code = x.exchange_rate_currency_code;
        WHEN OTHERS THEN
          dbms_output.put_line('Failed Reversal:   Snapshot No ('|| x.comms_calc_snapshot_no || 
                                               '), Group (' || x.group_code || 
                                               '), Product (' || x.product_code ||
                                               '), Policy (' || x.policy_code || 
                                               '), Person (' || x.person_code || 
                                            ') and Contribution Date (' || x.contribution_date || 
                                            ') for Brokerage (' || x.company_id_no ||
                                            ') and Percentage (' || x.comms_perc || ')' ||
                                                   sqlerrm);
          RAISE;
      END;
      BEGIN
        IF l_insert_cct THEN
          BEGIN
            cct.comms_calc_snapshot_no      := ccs.comms_calc_snapshot_no;  
            cct.trace_base_snapshot_no      := x.comms_calc_snapshot_no;
            IF x.trace_original_snapshot_no IS NOT NULL
              THEN cct.trace_original_snapshot_no := x.trace_original_snapshot_no;
              ELSE cct.trace_original_snapshot_no := x.comms_calc_snapshot_no;
            END IF;  
            INSERT INTO comms_calc_trace VALUES cct;
          EXCEPTION  
            WHEN OTHERS THEN
              dbms_output.put_line('Failed CCT Revers: Snapshot No ('|| x.comms_calc_snapshot_no || 
                                                   '), Group (' || x.group_code || 
                                                   '), Product (' || x.product_code ||
                                                   '), Policy (' || x.policy_code || 
                                                   '), Person (' || x.person_code || 
                                                ') and Contribution Date (' || x.contribution_date || 
                                                ') for Brokerage (' || x.company_id_no ||
                                                ') and Percentage (' || x.comms_perc || ')' ||
                                                       sqlerrm);
              RAISE;
          END; 
        END IF;
      EXCEPTION  
         WHEN OTHERS THEN
           RAISE;              
      END;          
      UPDATE comms_calc_snapshot
         SET comms_calc_type_code = 'X',
             last_update_datetime = SYSDATE,
             username = 'BAU-1887'
       WHERE comms_calc_snapshot_no = x.comms_calc_snapshot_no;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_output.put_line('Exception: ' || sqlerrm);
    END;
  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Exception: ' || sqlerrm);
END;

/

/* Ad Hoc Code

DROP TABLE DATAFIX_BACKUP_LS2338;
SELECT * FROM DATAFIX_BACKUP_LS2338;
SELECT * FROM TEMP_BACKUP_LS2338;

DELETE FROM comms_calc_snapshot WHERE comms_calc_snapshot_no IN (
SELECT comms_calc_snapshot_no
  FROM COMMS_CALC_TRACE WHERE TRACE_ORIGINAL_SNAPSHOT_NO IN (13594, 13595, 13596, 13597, 13598, 13599, 13600,
            13601, 13602, 13603, 13604, 13605, 13606, 13607, 13608, 13609, 13610, 13611, 13612, 13613, 13614,
            13615, 13616, 13617, 13618, 13619, 13620, 13621, 13622, 13623, 13624, 13625, 13626, 13627, 13628,
            13629, 13630, 13631, 13632, 13633, 13634, 13635, 13636, 14271, 14272, 14273, 14274, 14275, 14276,
            14277, 14278, 14279, 14280, 35887, 35888, 35889, 35890, 35891, 35892, 35893, 35894, 35895, 35896,
            35897, 35898, 35899, 35900, 35901, 35902, 35903, 35904, 35905, 35906, 35907, 35908, 35909, 35910,
            35911, 35912, 35913, 35914, 35915, 35916, 35917, 35918, 35919, 35920, 35921, 35922, 35923, 35924,
            35925, 35926, 35927, 35928, 35929, 35930, 35931, 35932, 35933, 35934, 35935, 35936, 35937, 35938,
            35939, 35940, 35941, 35942, 35943, 35944, 35945, 35946, 35947, 35948, 35949, 35950, 35951, 35952,
            35953, 35954, 35955, 35956, 35957, 35958, 35959, 35960, 35961, 35962, 35963, 35964, 35965, 35966,
            35967, 35968, 35969, 35970, 35971, 35972, 35973, 35974, 35975, 35976, 35977, 35978, 35979, 35980,
            35981, 35982, 35983, 35984, 35985, 35986, 35987, 35988, 35989, 35990, 35991, 35992, 35993, 35994,
            35995, 35996, 35997, 35998, 35999, 36000, 36001, 36002, 36003, 36004, 36005, 36006, 36007, 36008,
            36009, 36010, 36011, 36012, 36013, 36014, 36015, 36016, 36017, 36018, 36019, 36020, 36021, 36022,
            36023, 36024, 36025, 36026, 36027, 36028, 36029, 36030, 36031, 36032, 36033, 36034, 36035, 36036,
            36037, 36038, 36039, 36040, 36041, 36042, 36043, 36044, 36045, 36046, 36047, 37464, 37465, 37466));
DELETE 
  FROM COMMS_CALC_TRACE WHERE TRACE_ORIGINAL_SNAPSHOT_NO IN (13594, 13595, 13596, 13597, 13598, 13599, 13600,
            13601, 13602, 13603, 13604, 13605, 13606, 13607, 13608, 13609, 13610, 13611, 13612, 13613, 13614,
            13615, 13616, 13617, 13618, 13619, 13620, 13621, 13622, 13623, 13624, 13625, 13626, 13627, 13628,
            13629, 13630, 13631, 13632, 13633, 13634, 13635, 13636, 14271, 14272, 14273, 14274, 14275, 14276,
            14277, 14278, 14279, 14280, 35887, 35888, 35889, 35890, 35891, 35892, 35893, 35894, 35895, 35896,
            35897, 35898, 35899, 35900, 35901, 35902, 35903, 35904, 35905, 35906, 35907, 35908, 35909, 35910,
            35911, 35912, 35913, 35914, 35915, 35916, 35917, 35918, 35919, 35920, 35921, 35922, 35923, 35924,
            35925, 35926, 35927, 35928, 35929, 35930, 35931, 35932, 35933, 35934, 35935, 35936, 35937, 35938,
            35939, 35940, 35941, 35942, 35943, 35944, 35945, 35946, 35947, 35948, 35949, 35950, 35951, 35952,
            35953, 35954, 35955, 35956, 35957, 35958, 35959, 35960, 35961, 35962, 35963, 35964, 35965, 35966,
            35967, 35968, 35969, 35970, 35971, 35972, 35973, 35974, 35975, 35976, 35977, 35978, 35979, 35980,
            35981, 35982, 35983, 35984, 35985, 35986, 35987, 35988, 35989, 35990, 35991, 35992, 35993, 35994,
            35995, 35996, 35997, 35998, 35999, 36000, 36001, 36002, 36003, 36004, 36005, 36006, 36007, 36008,
            36009, 36010, 36011, 36012, 36013, 36014, 36015, 36016, 36017, 36018, 36019, 36020, 36021, 36022,
            36023, 36024, 36025, 36026, 36027, 36028, 36029, 36030, 36031, 36032, 36033, 36034, 36035, 36036,
            36037, 36038, 36039, 36040, 36041, 36042, 36043, 36044, 36045, 36046, 36047, 37464, 37465, 37466);

          UPDATE comms_calc_snapshot
             SET comms_calculated_amt        = comms_calculated_amt + x.comms_calculated_amt * -1,
                 comms_calculated_exch_amt   = comms_calculated_exch_amt + x.comms_calculated_exch_amt * -1,
                 payment_receive_amt         = payment_receive_amt + x.payment_receive_amt * -1,
                 last_update_datetime        = SYSDATE,
                 username                    = 'BAU-1887'
           WHERE country_code                = x.country_code
             AND product_code                = x.product_code
             AND poep_id                     = x.poep_id
             AND person_code                 = x.person_code
             AND policy_code                 = x.policy_code
             AND group_code                  = x.group_code
             AND broker_id_no                = x.broker_id_no
             AND company_id_no               = x.company_id_no
             AND contribution_date           = x.contribution_date
             AND payment_receive_date        = x.payment_receive_date
             AND finance_receipt_no          = x.finance_receipt_no
             AND calculation_datetime        = x.calculation_datetime
             AND comms_calc_type_code        = 'R'
             AND payment_currency            = x.payment_currency
             AND exchange_rate_currency_code = x.exchange_rate_currency_code;

*/