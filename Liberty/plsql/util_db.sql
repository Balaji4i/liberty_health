
@/tables/util/SYSTEM_NAME.sql;
@/tables/util/SYSTEM_PARAMETER.sql;
@/tables/util/SYSTEM_PARAMETER_AUDIT.sql;
@/tables/util/WEB_APPL_OBJECT_TYPE.sql;
@/tables/util/WEB_APPL_OBJECT.sql;
@/tables/util/WEB_APPL_OBJECT_LANG_MENU.sql;
@/tables/util/INTERF_SYSTEM.sql;
@/tables/util/INTERF_SYSTEM_TRN_TYPE.sql;
@/tables/util/INTERF_SYSTEM_TRN_COLUMN_TYPE.sql;
@/tables/util/INTERF_SYSTEM_TRN_SUB_TYPE.sql;
@/tables/util/INTERF_SYS_TRN_TP_SUB_TYPE.sql;
@/tables/util/INTERF_SYS_TRN_TP_SUB_TP_COL.sql;
@/tables/util/upld_trn.sql;
@/tables/util/dnld_batch.sql;
@/tables/util/ext_fusion_file_name.sql;


@/triggers/util/SYSTEM_PARAMETER_AUDIT_TRG.sql;


@/sequences/util/INTERF_SYSTEM_ID_NO_SEQ.sql;
@/sequences/util/UPLD_TRN_SEQ_NO.sql;


@/functions/util/GET_SYSTEM_PARAMETER.sql;


@/grants/util/grant_to_lhhcom.sql;
@/grants/util/grant_functions.sql;
@/grants/util/grant_sequences.sql;
@/grants/util/grant_to_lhhcom_on_external.sql;

GRANT SELECT ON ext_fusion_file_name to LHHCOM;