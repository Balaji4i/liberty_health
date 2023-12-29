/**
* ----------------------------------------------------------------------
* Change Request: MP-7636 - Remove Broker Consultant
*
* Description  : MP-7636 - Remove Broker Consultant
* Author       : Sarel Eybers
* Date         : 2019-10-31
* Call Syntax  : Just Run (F5) this script in it's etirety
*
* Steps
*   1) Display Result Before
*   2) Add Audit Records
*   3) Update Rows
*   4) Display Result After
*   5) Decide to Commit or not
*                                                                         */

-- 1) Display Result Before
SELECT AG_CODE, AG_NAME, AG_CONSULTANT, AG_DT_CHANGE, U_USER
FROM AGENT
WHERE AG_CONSULTANT > ' ' AND 'A' <> substr(AG_CODE, 1, 1);

-- 2) Add Audit Records
INSERT INTO AUDITA
    (A_COMMON_KEY
    ,A_AUDIT_TYPE
    ,AD_DT_STAMP
    ,AD_TM_STAMP
    ,U_USER
    ,A_PROGRAM
    ,A_FIELD
    ,A_FIELD_TYPE
    ,A_OLD
    ,A_NEW
    ,A_DT_FROM
    ,A_DT_TO
    ,A_ACTIONED
    ,A_FILE
    ,A_USER_AUTH
    ,A_MGR_NAME
    ,A_DT_ACTIONED
    ,A_TM_ACTIONED)
SELECT
    substr('AGENT ' ||  AG_CODE, 1, 58)
    ,'C '
    ,20200110
    ,15000000
    ,'MGR     '
    ,'MP-7636 '
    ,'AG_CONSULTANT                 '
    ,'CHAR'
    ,AG_CONSULTANT
    ,'                                        '
    ,20191001
    ,0
    ,'  '
    ,'AGENT               '
    ,'        '
    ,'        '
    ,0
    ,0
FROM AGENT
WHERE AG_CONSULTANT > ' ' AND 'A' <> substr(AG_CODE, 1, 1);

--   3) Update AGENT Rows
UPDATE AGENT
  SET AG_CONSULTANT = '            ',
    AG_DT_CHANGE = 20200110,
    U_USER = 'MGR     '
WHERE AG_CONSULTANT > ' ' AND 'A' <> substr(AG_CODE, 1, 1);
  
--   4) Display Result After
SELECT * 
FROM AUDITA 
WHERE A_PROGRAM = 'MP-7636 ';

SELECT AG_CODE, AG_NAME, AG_CONSULTANT, AG_DT_CHANGE, U_USER
FROM AGENT
WHERE AG_DT_CHANGE = 20200110 AND U_USER = 'MGR     ';

-- 4) Decide to Commit or not
--commit;