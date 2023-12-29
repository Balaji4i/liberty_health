INSERT INTO SYSTEM_PARAMETER(
SYSTEM_NAME
,PARAMETER_SECTION
,PARAMETER_KEY
,PARAMETER_VALUE
,USER_UPDATE_IND
,LAST_UPDATE_DATETIME
,USERNAME
)
VALUES
(
'LB_HEALTH_COMMS',
'FUSION',	
'LAST_FUSION_PREMIUM_CHECK',	
'02-20-2019',
'N',
TRUNC(SYSDATE),
'LHHCOM'
);
/
INSERT INTO SYSTEM_PARAMETER(
SYSTEM_NAME
,PARAMETER_SECTION
,PARAMETER_KEY
,PARAMETER_VALUE
,USER_UPDATE_IND
,LAST_UPDATE_DATETIME
,USERNAME
)
VALUES
(
'LB_HEALTH_COMMS',
'FUSION',	
'WEB_SERVICE_WSDL',	
'https://efnu-dev1.fa.em3.oraclecloud.com/xmlpserver/services/PublicReportService',
'N',
TRUNC(SYSDATE),
'LHHCOM'
);
/
INSERT INTO SYSTEM_PARAMETER(
SYSTEM_NAME
,PARAMETER_SECTION
,PARAMETER_KEY
,PARAMETER_VALUE
,USER_UPDATE_IND
,LAST_UPDATE_DATETIME
,USERNAME
)
VALUES
(
'LB_HEALTH_COMMS',
'WSO2',	
'SERVER_LINK',	
'https://zactoa01.dot.co.za:8243',
'N',
TRUNC(SYSDATE),
'LHHCOM'
);
COMMIT;