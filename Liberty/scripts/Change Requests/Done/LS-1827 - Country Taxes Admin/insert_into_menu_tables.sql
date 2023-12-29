/**
* ----------------------------------------------------------------------
* Change Request: Country Taxes Admin Function (LS-1342)
*
* Description  : Insert a record into the menus table so that the menu is exposed in the Administration Section
* Author       : Tanya Percy
* Date         : 2019-09-26
* Call Syntax  : Run below insert statements 
* Steps
*   1) 

*/
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
(43,'LB_HEALTH_COMMS',5,1,15,'/WEB-INF/flows/lookup/all-country-taxes-flow.xml#all-country-taxes-flow',trunc(sysdate),to_date('31-JAN-3100'));
/
insert into web_appl_object_lang_menu values (43,'fr_FR','FR - Country Taxes');
/
insert into web_appl_object_lang_menu values (43,'pt_PT','PT - Country Taxes');
/
insert into web_appl_object_lang_menu values (43,'en_ZA','Country Taxes');   
/
commit;