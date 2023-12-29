/********************************************************************************LOOOKUP DATA*****************************************************************************************************************************************************/
insert into address_type (address_type_code, address_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('S','Street','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into address_type (address_type_code, address_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('P','Postal','01-JAN-2000','31-JAN-3100',sysdate,user);

insert into ACCREDITATION_TYPE (ACCREDITATION_TYPE_ID_NO,ACCREDITATION_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (ACCREDITATION_TYPE_SEQ_NO.nextval, 'Medical','01-JAN-2000', '31-JAN-3100',sysdate,user);
insert into ACCREDITATION_TYPE (ACCREDITATION_TYPE_ID_NO,ACCREDITATION_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (ACCREDITATION_TYPE_SEQ_NO.nextval, 'FAIS','01-JAN-2000', '31-JAN-3100',sysdate,user);

insert into company_contact_type (company_contact_type_id_no,company_contact_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values (1, 'Primary','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into company_contact_type (company_contact_type_id_no,company_contact_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values (2, 'Secondary','01-JAN-2000','31-JAN-3100',sysdate,user);

insert into invoice_type (invoice_type_id_no,invoice_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values (1,'Commissions Run',trunc(sysdate),'31-JAN-3100',sysdate,user);
insert into invoice_type (invoice_type_id_no,invoice_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values (2,'Journal Entry',trunc(sysdate),'31-JAN-3100',sysdate,user);

insert into comm_hub_template_type (comm_hub_template_type_code,comm_hub_template_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('COM000001','Broker welcome letter', trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into comm_hub_template_type (comm_hub_template_type_code,comm_hub_template_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('COM000002','Bank Detail Required', trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into comm_hub_template_type (comm_hub_template_type_code,comm_hub_template_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('COM000003','Bank Detail Updated', trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into comm_hub_template_type (comm_hub_template_type_code,comm_hub_template_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('COM000004','Broker statement', trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into comm_hub_template_type (comm_hub_template_type_code,comm_hub_template_type_desc,effective_start_date,effective_end_date,last_update_datetime,username) values ('COM000005','Acknowledgement of Broker', trunc(sysdate), '31-JAN-3100',sysdate,user);


/*******************************************************************************BROKER DATA**********************************************************************************************************************************************************/
insert into broker_table (broker_table_id_no, broker_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values  (1,'Type',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into broker_table (broker_table_id_no, broker_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values  (2,'Status',trunc(sysdate), '31-JAN-3100',sysdate,user);

insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (1,'Agent',trunc(sysdate),'31-JAN-3100',1,sysdate,user);
insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (2,'Consultant',trunc(sysdate),'31-JAN-3100',1,sysdate,user);
insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (3,'Director',trunc(sysdate),'31-JAN-3100',1,sysdate,user);
insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (4,'Special',trunc(sysdate),'31-JAN-3100',1,sysdate,user);

insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (5,'Active',trunc(sysdate),'31-JAN-3100',2,sysdate,user);
insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (6,'Resigned',trunc(sysdate),'31-JAN-3100',2,sysdate,user);
insert into broker_table_type (broker_table_type_id_no, broker_table_type_desc, effective_start_date, effective_end_date, broker_table_id_no, last_update_datetime, username) values (7,'Hold',trunc(sysdate),'31-JAN-3100',2,sysdate,user);

/********************************************************************************BROKERAGE DATA*******************************************************************************************************************************************************/
insert into company_fee_type values (COMPANY_FEE_TYPE_ID_NO_SEQ.nextval,'Commission','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into company_fee_type values (COMPANY_FEE_TYPE_ID_NO_SEQ.nextval,'Referral','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into company_fee_type values (COMPANY_FEE_TYPE_ID_NO_SEQ.nextval,'Handling','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into company_fee_type values (COMPANY_FEE_TYPE_ID_NO_SEQ.nextval,'Consulting','01-JAN-2000','31-JAN-3100',sysdate,user);
insert into company_fee_type values (COMPANY_FEE_TYPE_ID_NO_SEQ.nextval,'Stakeholder','01-JAN-2000','31-JAN-3100',sysdate,user);

insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values  (company_table_id_no_seq.nextval,'Statement',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values   (company_table_id_no_seq.nextval,'Status',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values   (company_table_id_no_seq.nextval,'Function',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values   (company_table_id_no_seq.nextval,'Type',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values   (company_table_id_no_seq.nextval,'Payment Type',trunc(sysdate), '31-JAN-3100',sysdate,user);
insert into company_table (company_table_id_no, company_table_desc, effective_start_date, effective_end_date, last_update_datetime, username) values   (company_table_id_no_seq.nextval,'Multinational',trunc(sysdate), '31-JAN-3100',sysdate,user);


insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/21,'Mail',trunc(sysdate),'31-JAN-3100',1,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/22,'Fax',trunc(sysdate),'31-JAN-3100',1,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/23,'Email',trunc(sysdate),'31-JAN-3100',1,sysdate,user);

insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/24,'Pre-Registration',trunc(sysdate),'31-JAN-3100',2,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/25,'Active',trunc(sysdate),'31-JAN-3100',2,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/26,'Suspend',trunc(sysdate),'31-JAN-3100',2,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/27,'Resigned',trunc(sysdate),'31-JAN-3100',2,sysdate,user);

insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/28,'Global Broker',trunc(sysdate),'31-JAN-3100',3,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/29,'In-Country Broker',trunc(sysdate),'31-JAN-3100',3,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/30,'South African Broker',trunc(sysdate),'31-JAN-3100',3,sysdate,user);

insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/31,'Broker',trunc(sysdate),'31-JAN-3100',4,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/32,'Agency',trunc(sysdate),'31-JAN-3100',4,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/33,'Agent',trunc(sysdate),'31-JAN-3100',4,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/34,'Direct',trunc(sysdate),'31-JAN-3100',4,sysdate,user);

insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/61,'EFT',trunc(sysdate),'31-JAN-3100',5,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/62,'CHEQUE',trunc(sysdate),'31-JAN-3100',5,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/63,'ACB',trunc(sysdate),'31-JAN-3100',5,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/64,'3rd Party',trunc(sysdate),'31-JAN-3100',5,sysdate,user);

insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/1,'Y',trunc(sysdate),'31-JAN-3100',6,sysdate,user);
insert into company_table_type (company_table_type_id_no, company_table_type_desc, effective_start_date, effective_end_date, company_table_id_no, last_update_datetime, username) values (/*company_table_type_id_no_seq.nextval*/2,'N',trunc(sysdate),'31-JAN-3100',6,sysdate,user);


/********************************************************************************BROKERAGE DATA*******************************************************************************************************************************************************/
Insert into comms_calc_type (COMMS_CALC_TYPE_CODE,COMMS_CALC_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values ('A','Adjustment',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('13/DEC/17','DD/MON/RR'),'LHHCOM');
Insert into comms_calc_type (COMMS_CALC_TYPE_CODE,COMMS_CALC_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values ('T','Test Run',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('08/NOV/17','DD/MON/RR'),'LHHCOM');
Insert into comms_calc_type (COMMS_CALC_TYPE_CODE,COMMS_CALC_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values ('P','Posted',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('08/NOV/17','DD/MON/RR'),'LHHCOM');
Insert into comms_calc_type (COMMS_CALC_TYPE_CODE,COMMS_CALC_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values ('R','Reversal',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('12/DEC/17','DD/MON/RR'),'LHHCOM');
Insert into comms_calc_type (COMMS_CALC_TYPE_CODE,COMMS_CALC_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values ('X','Posted',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('12/DEC/17','DD/MON/RR'),'LHHCOM');
/********************************************************************************UTIL DATA*******************************************************************************************************************************************************/
INSERT INTO INTERF_SYSTEM (INTERF_SYSTEM_ID_NO,INTERF_SYSTEM_NAME ,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (INTERF_SYSTEM_ID_NO_SEQ.NEXTVAL,'Oracle Fusion','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYSTEM (INTERF_SYSTEM_ID_NO,INTERF_SYSTEM_NAME ,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (INTERF_SYSTEM_ID_NO_SEQ.NEXTVAL,'OHI','01-JAN-2000','31-JAN-3100',sysdate,user);

INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,1,'Download Broker','01-JAN-2000','31-JAN-3100',sysdate,user);  
INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,2,'Upload Payments Received','01-JAN-2000','31-JAN-3100',sysdate,user);  
INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,3,'Download Transactions','01-JAN-2000','31-JAN-3100',sysdate,user);   
INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,4,'Download Broker Contact','01-JAN-2000','31-JAN-3100',sysdate,user);  
INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,5,'Download Broker Address','01-JAN-2000','31-JAN-3100',sysdate,user);  
INSERT INTO INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC, EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (2,1,'Download Broker','01-JAN-2000','31-JAN-3100',sysdate,user);          


INSERT INTO INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,'H','Header','01-JAN-2000','31-JAN-3100',sysdate,user);  
INSERT INTO INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,'D','Detail','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,'N','Normal','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (2,'H','Header','01-JAN-2000','31-JAN-3100',sysdate,user);    
INSERT INTO INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (2,'D','Detail','01-JAN-2000','31-JAN-3100',sysdate,user);

INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,1,'D','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,2,'H','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,2,'D','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,2,'N','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,3,'H','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,3,'D','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,4,'D','01-JAN-2000','31-JAN-3100',sysdate,user);
INSERT INTO INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) VALUES (1,5,'D','01-JAN-2000','31-JAN-3100',sysdate,user);

INSERT INTO INTERF_SYSTEM_TRN_COLUMN_TYPE  (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) VALUES ('V','VARCHAR',SYSDATE,USER);
INSERT INTO INTERF_SYSTEM_TRN_COLUMN_TYPE  (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) VALUES ('D','Date',SYSDATE,USER);
INSERT INTO INTERF_SYSTEM_TRN_COLUMN_TYPE  (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) VALUES ('N','Number',SYSDATE,USER);

insert into WEB_APPL_OBJECT_TYPE values (1,'Menu');
insert into WEB_APPL_OBJECT_TYPE values (2,'Menu Item');
insert into WEB_APPL_OBJECT_TYPE values (3,'Watch List');

insert into SYSTEM_NAME (SYSTEM_NAME,SYSTEM_NAME_DESC,SYSTEM_PATH_NAME,DISPLAY_IND) values ('LB_HEALTH_COMMS','Liberty Health Commissions',null,'N');
insert into SYSTEM_NAME (SYSTEM_NAME,SYSTEM_NAME_DESC,SYSTEM_PATH_NAME,DISPLAY_IND) values ('LB_HEALTH_COMMS_WATCH_LIST','Liberty Comms Watch List',null,'Y');


--Watchlist
--Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (14,'LB_HEALTH_COMMS_WATCH_LIST',null,3,1,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),trunc(sysdate)-10);
Insert into web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (15,'LB_HEALTH_COMMS_WATCH_LIST',null,3,1,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (15,'fr_FR','FR - Brokers approval oustanding');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (15,'pt_PT','PT -Brokers approval oustanding');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (15,'en_ZA','Brokers approval oustanding');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (13,'LB_HEALTH_COMMS_WATCH_LIST',null,3,3,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (13,'fr_FR','FR - Pre-Reg Brokers');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (13,'pt_PT','PT -Pre-Reg Brokers');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (13,'en_ZA','Pre-Reg Brokers');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (26,'LB_HEALTH_COMMS_WATCH_LIST',null,3,4,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (26,'fr_FR','FR - Payments On Hold');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (26,'pt_PT','PT -Payments On Hold');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (26,'en_ZA','Payments On Hold');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (28,'LB_HEALTH_COMMS_WATCH_LIST',null,3,5,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (28,'fr_FR','FR - Missing Comms %');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (28,'pt_PT','PT -Missing Comms %');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (28,'en_ZA','Missing Comms %');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (29,'LB_HEALTH_COMMS_WATCH_LIST',null,3,3,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (29,'fr_FR','FR - Comms Calc Approvals');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (29,'pt_PT','PT -Comms Calc Approvals');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (29,'en_ZA','Comms Calc Approvals');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (30,'LB_HEALTH_COMMS_WATCH_LIST',null,3,5,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (30,'fr_FR','FR - Brokerage % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (30,'pt_PT','PT -Brokerage % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (30,'en_ZA','Brokerage % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (31,'LB_HEALTH_COMMS_WATCH_LIST',null,3,6,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (31,'fr_FR','FR - Broker % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (31,'pt_PT','PT -Broker % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (31,'en_ZA','Broker % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (32,'LB_HEALTH_COMMS_WATCH_LIST',null,3,7,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (32,'fr_FR','FR - Employer Group % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (32,'pt_PT','PT -Employer Group % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (32,'en_ZA','Employer Group % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (33,'LB_HEALTH_COMMS_WATCH_LIST',null,3,8,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (33,'fr_FR','FR - Benefit Plan % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (33,'pt_PT','PT -Benefit Plan % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (33,'en_ZA','Benefit Plan % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (34,'LB_HEALTH_COMMS_WATCH_LIST',null,3,9,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (34,'fr_FR','FR - Policy % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (34, 'pt_PT','PT -Policy % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (34, 'en_ZA','Policy % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (35,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (35,'fr_FR','FR - Member % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (35, 'pt_PT','PT -Member % Approval');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (35, 'en_ZA','Member % Approval');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (36,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (36,'fr_FR','FR - Employer Group % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (36, 'pt_PT','PT -Employer Group % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (36, 'en_ZA','Employer Group % Rejected');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (38,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (38,'fr_FR','FR - Benefit Plan % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (38, 'pt_PT','PT -Benefit Plan % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (38, 'en_ZA','Benefit Plan % Rejected');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (39,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (39,'fr_FR','FR - Policy % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (39, 'pt_PT','PT -Policy % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (39, 'en_ZA','Policy % Rejected');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (40,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (40,'fr_FR','FR - Member % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (40, 'pt_PT','PT -Member % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (40, 'en_ZA','Member % Rejected');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (41,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');

Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (41,'fr_FR','FR - Brokerage % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (41, 'pt_PT','PT -Brokerage % Rejected');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (41, 'en_ZA','Brokerage % Rejected');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (42,'LB_HEALTH_COMMS',5,1,14,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (42,'fr_FR','FR - Back Dated Changes Errors');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (42, 'pt_PT','PT -Back Dated Changes Errors');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (42, 'en_ZA','Back Dated Changes Errors');


--Brokers
Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (3,'LB_HEALTH_COMMS',null,1,1,null,'01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (3,'fr_FR','FR - Brokers');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (3,'pt_PT','PT -Brokers');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (3,'en_ZA','Brokers');


Insert into web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (16,'LB_HEALTH_COMMS',3,1,1,'/WEB-INF/btf/company/create-new-company-btf.xml#create-new-company-btf',sysdate-10,null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (16,'fr_FR','FR - Create Brokerage');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (16,'pt_PT','PT -Create Brokerage');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (16,'en_ZA','Create Brokerage');

Insert into web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (17,'LB_HEALTH_COMMS',3,1,2,'/WEB-INF/flows/brokerage/all-brokerage-flow.xml#all-brokerage-flow',sysdate-10,null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (17,'fr_FR','FR - Search Brokerage');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (17,'pt_PT','PT -Search Brokerage');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (17,'en_ZA','Search Brokerage');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (2,'LB_HEALTH_COMMS',3,1,3,'/WEB-INF/flows/brokers/all-brokers-flow.xml#all-brokers-flow',sysdate-10,null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (2,'fr_FR','FR - Search Broker');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (2,'pt_PT','PT -Search Broker');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (2,'en_ZA','Search Broker');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (27,'LB_HEALTH_COMMS',3,1,4,'/WEB-INF/flows/brokers/all-broker-comms-submit-flow.xml#all-broker-comms-submit-flow',sysdate-10,null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (27,'fr_FR','FR - Broker Communication');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (27,'pt_PT','PT -Broker Communication');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (27,'en_ZA','Broker Communication');



--Commissions
Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (4,'LB_HEALTH_COMMS',null,1,2,null,'01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (4,'fr_FR','FR - Commissions');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (4,'pt_PT','PT -Commissions');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (4,'en_ZA','Commissions');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (18,'LB_HEALTH_COMMS',4,1,1,'/WEB-INF/flows/ohi/all-ohi-policy-broker-flow.xml#all-ohi-policy-broker-flow','01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (18,'fr_FR','FR - Employer Group');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (18,'pt_PT','PT -Employer Group');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (18,'en_ZA','Employer Group');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (8,'LB_HEALTH_COMMS',4,1,5,'/WEB-INF/flows/comms/all-payments-received-flow.xml#all-payments-received-flow','01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (8,'fr_FR','FR - Payments Received');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (8,'pt_PT','PT -Payments Received');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (8,'en_ZA','Payments Received');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (9,'LB_HEALTH_COMMS',4,1,6,'/WEB-INF/btf/comms/maintain-current-comms-run-btf.xml#maintain-current-comms-run-btf','01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (9,'fr_FR','FR - Commission Run');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (9,'pt_PT','PT -Commission Run');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (9,'en_ZA','Commission Run');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (11,'LB_HEALTH_COMMS',4,1,7,'/WEB-INF/flows/comms/all-comms-run-flow.xml#all-comms-run-flow','01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (11,'fr_FR','FR - Search Commission History');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (11,'pt_PT','PT -Search Commission History');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (11,'en_ZA','Search Commission History');

Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (12,'LB_HEALTH_COMMS',4,1,7,'/WEB-INF/flows/payment/all-invoices-flow.xml#all-invoices-flow','01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (12,'fr_FR','FR - Commissions Payments');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (12,'pt_PT','PT -Commissions Payments');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (12,'en_ZA','Commissions Payments');


--Administration
Insert into web_appl_object  (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (5,'LB_HEALTH_COMMS',null,1,3,null,'01-JAN-2000',null);
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (5,'fr_FR','FR - Administration');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (5,'pt_PT','PT -Administration');
Insert into web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (5,'en_ZA','Administration');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (25,'LB_HEALTH_COMMS',5,1,1,'/WEB-INF/flows/lookup/all-accreditation-type-flow.xml#all-accreditation-type-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (25,'fr_FR','FR - Accreditation');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (25,'pt_PT','PT -Accreditation');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (25,'en_ZA','Accreditation');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (1,'LB_HEALTH_COMMS',5,1,2,'/WEB-INF/flows/lookup/all-address-type-flow.xml#all-address-type-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (1,'fr_FR','FR - Address Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (1,'pt_PT','PT -Address Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (1,'en_ZA','Address Type');

/*
Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (6,'LB_HEALTH_COMMS',5,1,3,'/WEB-INF/flows/lookup/all-bank-account-type-flow.xml#all-bank-account-type-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (6,'IT','IT - Bank Account Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (6,'en_ZA','Bank Account Type');*/

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (23,'LB_HEALTH_COMMS',5,1,4,'/WEB-INF/flows/lookup/all-broker-table-flow.xml#all-broker-table-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (23,'IT','IT - Broker Table');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (23,'en_ZA','Broker Table');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (24,'LB_HEALTH_COMMS',5,1,5,'/WEB-INF/flows/lookup/all-company-table-flow.xml#all-company-table-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (24,'fr_FR','FR - Brokerage Table');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (24,'pt_PT','PT -Brokerage Table');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (24,'en_ZA','Brokerage Table');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (7,'LB_HEALTH_COMMS',5,1,6,'/WEB-INF/flows/lookup/all-company-contact-type-flow.xml#all-company-contact-type-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (7,'fr_FR','FR - Brokerage Contact Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (7,'pt_PT','PT -Brokerage Contact Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (7,'en_ZA','Brokerage Contact Type');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (10,'LB_HEALTH_COMMS',5,1,7,'/WEB-INF/flows/lookup/all-company-fee-type-flow.xml#all-company-fee-type-flow',to_date('01/APR/17','DD/MON/RR'),'31-JAN-3100');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (10,'fr_FR','FR - Brokerage Fee Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (10,'pt_PT','PT -Brokerage Fee Type');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (10,'en_ZA','Brokerage Fee Type');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (22,'LB_HEALTH_COMMS',5,1,10,'/WEB-INF/flows/util/all-system-parameter-flow.xml#all-system-parameter-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (22,'fr_FR','FR - System Parameter');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (22,'pt_PT','PT -System Parameter');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (22,'en_ZA','System Parameter');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (6,'LB_HEALTH_COMMS',5,1,11,'/WEB-INF/flows/lookup/all-medware-compare-flow.xml#all-medware-compare-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (6,'fr_FR','FR - Medware Codes');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (6,'pt_PT','PT -Medware Codes');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (6,'en_ZA','Medware Codes');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (14,'LB_HEALTH_COMMS',5,1,12,'/WEB-INF/flows/lookup/all-error-transactions-flow.xml#all-error-transactions-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (14,'fr_FR','FR - Upload Errors');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (14,'pt_PT','PT -Upload Errors');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (14,'en_ZA','Upload Errors');

Insert into util.web_appl_object (WEB_APPL_OBJECT_NO,SYSTEM_NAME,PARENT_WEB_APPL_OBJECT_NO,OBJECT_TYPE_NO,MENU_SORT_SEQ_NO,URL_PATH_NAME,ACTIVE_FROM_DATE,REMOVE_FROM_DATE) values (37,'LB_HEALTH_COMMS',5,1,13,'/WEB-INF/flows/lookup/all-exchange-rate-flow.xml#all-exchange-rate-flow',to_date('01/APR/17','DD/MON/RR'),null);
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (37,'fr_FR','Taux de change');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (37,'pt_PT','Taxa de câmbio');
Insert into util.web_appl_object_lang_menu (WEB_APPL_OBJECT_NO,LOCAL_CODE,MENU_ITEM_NAME) values (37,'en_ZA','Exchange Rate');

--system parameters
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','BROKER','MAX_MULTI_NET_AMT',1000,'Y',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','WATCHLIST','MAX_PREG_REG_DAYS',10,'Y',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','COMMS_HUB','SOURCE_NAME','COMMISSIONS','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','COMMS_HUB','SERVER_LINK','http://wlsdcmdevlz1.liberty.fin-za.net:7103/ViewDocs/index.html?','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','COMMS_HUB','BROKER_SRC_CODE','AG','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','COMMS_HUB','COMPANY_SRC_CODE','BR','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','SYSTEM','SYSTEM_START_DATE','10-SEP-1957','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','DASHBOARD','DASHBOARD_NO_OF_DAYS',10,'Y',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','COMMS_CALC','MAX_CALC_SHOW_DAYS',10,'Y',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','SYSTEM','MEDWARE_LINK','MEDWARE_PROD.LIBERTY.CO.ZA','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','OHI','SERVER_LINK','http://wlsohidevlz1:7311/api/generic/agents','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','LAST_REMITTANCE_CHECK_DATE',trunc(sysdate),'N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','SERVER_LINK','http://zactlb01.dot.co.za:8280/services/Fusion_Import_And_Load_PayablesPROXY.Fusion_Import_And_Load_PayablesPROXYHttpSoap11Endpoint','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','SERVER_DNLD_FOLDER','DNLD_FUSION','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','SERVER_USERNAME','fusionintegration','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','SERVER_PASSWORD','Fus10nInt','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','DNLD_FILE_TYPE','zip','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','PASSWORD_DIGEST_B64','efffrfsrsstetv','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','HEADER_FILENAME','ApInvoicesInterface.csv','N',sysdate,user);
insert into util.system_parameter (system_name,parameter_section,parameter_key,parameter_value, user_update_ind,last_update_datetime,username) values ('LB_HEALTH_COMMS','FUSION','DETAIL_FILENAME','ApInvoiceLinesInterface.csv','N',sysdate,user);


Insert into UTIL.INTERF_SYSTEM (INTERF_SYSTEM_ID_NO,INTERF_SYSTEM_NAME,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,'Oracle Fusion',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM (INTERF_SYSTEM_ID_NO,INTERF_SYSTEM_NAME,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (2,'OHI',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');

Insert into UTIL.INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,'H','Header',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,'D','Detail',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (2,'H','Header',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (2,'D','Detail',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_SUB_TYPE_CODE,TRN_SUB_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,'N','Normal',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('18/SEP/17','DD/MON/RR'),'UTIL');

Insert into UTIL.INTERF_SYSTEM_TRN_COLUMN_TYPE (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) values ('V','VARCHAR',to_date('13/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_COLUMN_TYPE (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) values ('D','Date',to_date('13/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_COLUMN_TYPE (TRN_COLUMN_TYPE_CODE,TRN_COLUMN_TYPE_DESC,LAST_UPDATEDATE_TIME,USERNAME) values ('N','Number',to_date('13/JUN/17','DD/MON/RR'),'UTIL');

Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,1,'Download Broker',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,2,'Upload Payments Received',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,3,'Download Transactions',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,4,'Download Broker Contact',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,5,'Download Broker Address',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYSTEM_TRN_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_TYPE_DESC,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (2,1,'Download Broker',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');

Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,1,'D',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,2,'H',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,2,'D',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,3,'H',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,3,'D',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,4,'H',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,5,'H',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,4,'D',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,5,'D',to_date('01/JAN/00','DD/MON/RR'),to_date('31/DEC/99','DD/MON/RR'),to_date('26/JUN/17','DD/MON/RR'),'UTIL');
Insert into UTIL.INTERF_SYS_TRN_TP_SUB_TYPE (INTERF_SYSTEM_ID_NO,TRN_TYPE_NO,TRN_SUB_TYPE_CODE,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,LAST_UPDATE_DATETIME,USERNAME) values (1,2,'N',to_date('01/JAN/00','DD/MON/RR'),to_date('31/JAN/00','DD/MON/RR'),to_date('18/SEP/17','DD/MON/RR'),'UTIL');


