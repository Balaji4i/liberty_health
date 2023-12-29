   insert into WEB_APPL_OBJECT
   (WEB_APPL_OBJECT_NO
,SYSTEM_NAME
,PARENT_WEB_APPL_OBJECT_NO
,OBJECT_TYPE_NO
,MENU_SORT_SEQ_NO
,URL_PATH_NAME
,ACTIVE_FROM_DATE
,REMOVE_FROM_DATE)
values
(45,'LB_HEALTH_COMMS',4,1,9,'/WEB-INF/flows/comms/all-report-dashboard-flow.xml#all-report-dashboard-flow',trunc(sysdate),to_date('31-JAN-3100'));
/
insert into web_appl_object_lang_menu values (45,'fr_FR','FR - Report Dashboard');
/
insert into web_appl_object_lang_menu values (45,'pt_PT','PT - Report Dashboard');
/
insert into web_appl_object_lang_menu values (45,'en_ZA','Report Dashboard');   
/
commit;
/
ALTER TABLE INVOICE_PAYMENTS ADD (INVOICE_PAYMENT_ID NUMBER);
/ 
 insert into WEB_APPL_OBJECT
    (WEB_APPL_OBJECT_NO
 ,SYSTEM_NAME
 ,PARENT_WEB_APPL_OBJECT_NO
 ,OBJECT_TYPE_NO
 ,MENU_SORT_SEQ_NO
 ,URL_PATH_NAME
 ,ACTIVE_FROM_DATE
 ,REMOVE_FROM_DATE)
 values
 (46,'LB_HEALTH_COMMS',3,1,5,'/WEB-INF/flows/brokerage/all-broker-partial-flow.xml#all-broker-partial-flow',trunc(sysdate),to_date('31-JAN-3100'));
 /
 insert into web_appl_object_lang_menu values (46,'fr_FR','FR - Commission on Partial Receipt');
 /
 insert into web_appl_object_lang_menu values (46,'pt_PT','PT - Commission on Partial Receipt');
 /
 insert into web_appl_object_lang_menu values (46,'en_ZA','Commission on Partial Receipt');   
 /
 commit;
/ 
 insert into WEB_APPL_OBJECT
    (WEB_APPL_OBJECT_NO
 ,SYSTEM_NAME
 ,PARENT_WEB_APPL_OBJECT_NO
 ,OBJECT_TYPE_NO
 ,MENU_SORT_SEQ_NO
 ,URL_PATH_NAME
 ,ACTIVE_FROM_DATE
 ,REMOVE_FROM_DATE)
 values
 (47,'LB_HEALTH_COMMS_WATCH_LIST',null,3,10,'/WEB-INF/flows/watchlist/all-comms-watchlist-flow.xml#all-comms-watchlist-flow',trunc(sysdate),to_date('31-JAN-3100'));
 /
 insert into web_appl_object_lang_menu values (47,'fr_FR','FR - Commission on Partial Receipt Approval');
 /
 insert into web_appl_object_lang_menu values (47,'pt_PT','PT - Commission on Partial Receipt Approval');
 /
 insert into web_appl_object_lang_menu values (47,'en_ZA','Commission on Partial Receipt Approval');   
 /
 commit;
/