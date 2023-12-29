CREATE GLOBAL TEMPORARY TABLE lhhcom.comms_levy_information_gt (
 KEY           VARCHAR2(500),
 subs_date     DATE, 
 referencedate DATE, 
 time_period   VARCHAR2(100) ,
 policy_code   VARCHAR2(500), 
 group_code    VARCHAR2(500),
 product       VARCHAR2(500),
 adjustment    VARCHAR2(500), 
 type          VARCHAR2(500),
 sequence      NUMBER,
 percentage    NUMBER
);
/
CREATE INDEX comms_levy_idx1 ON lhhcom.comms_levy_information_gt(policy_code, subs_date, group_code);
/
CREATE INDEX comms_levy_idx2 ON lhhcom.comms_levy_information_gt (key);