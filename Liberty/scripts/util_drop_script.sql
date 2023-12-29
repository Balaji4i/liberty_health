-- Sarel ran this drop script rather . . .
-- select 'drop '||object_type||' '|| object_name||';' from user_objects order by created desc;

drop table util.SYSTEM_PARAMETER;
drop table SYSTEM_PARAMETER_AUDIT;
drop table WEB_APPL_OBJECT_TYPE;
drop table WEB_APPL_OBJECT_LANG_MENU;
drop table WEB_APPL_OBJECT;
drop table INTERF_SYS_TRN_TP_SUB_TYPE;
drop table INTERF_SYSTEM_TRN_SUB_TYPE;
drop table INTERF_SYSTEM_TRN_COLUMN_TYPE;
drop table INTERF_SYSTEM_TRN_TYPE;
drop table INTERF_SYS_TRN_TP_SUB_TP_COL;
drop table INTERF_SYSTEM;
drop table upld_trn;
drop table dnld_batch;
drop table ext_fusion_file_name;
drop table SYSTEM_NAME;

drop  SEQUENCE  "UTIL"."INTERF_SYSTEM_ID_NO_SEQ";
drop  SEQUENCE "UTIL"."UPLD_TRN_SEQ_NO";
   