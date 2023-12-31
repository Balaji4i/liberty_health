@/tables/lhhcom/temp_AGENT_broker_table.sql;
@/tables/lhhcom/temp_agent_company_table.sql;
@/tables/lhhcom/accreditation_type.sql;
@/tables/lhhcom/accreditation_type_audit.sql;
@/tables/lhhcom/address_type.sql;
@/tables/lhhcom/address_type_audit.sql;
@/tables/lhhcom/company_contact_type.sql;
@/tables/lhhcom/company_contact_type_audit.sql;
@/tables/lhhcom/comms_calc_type.sql;
@/tables/lhhcom/comm_hub_template_type.sql;
@/tables/lhhcom/company.sql;
@/tables/lhhcom/company_country.sql;
@/tables/lhhcom/company_country_audit.sql;
@/tables/lhhcom/company_accreditation.sql;
@/tables/lhhcom/company_accreditation_audit.sql;
@/tables/lhhcom/company_address.sql;
@/tables/lhhcom/company_address_audit.sql;
@/tables/lhhcom/company_audit.sql;
@/tables/lhhcom/company_comments.sql;
@/tables/lhhcom/company_contact.sql;
@/tables/lhhcom/company_contact_audit.sql;
@/tables/lhhcom/company_fee_type.sql;
@/tables/lhhcom/company_fee_type_audit.sql;
@/tables/lhhcom/company_fee.sql;
@/tables/lhhcom/company_fee_audit.sql;
@/tables/lhhcom/company_reg.sql;
@/tables/lhhcom/company_reg_audit.sql;
@/tables/lhhcom/company_table.sql;
@/tables/lhhcom/company_table_audit.sql;
@/tables/lhhcom/company_table_type.sql;
@/tables/lhhcom/company_table_type_audit.sql;
@/tables/lhhcom/company_function.sql;
@/tables/lhhcom/company_function_audit.sql;
@/tables/lhhcom/broker.sql;
@/tables/lhhcom/broker_accreditation.sql;
@/tables/lhhcom/broker_accreditation_audit.sql;
@/tables/lhhcom/broker_audit.sql;
@/tables/lhhcom/broker_comments.sql;
@/tables/lhhcom/broker_table.sql;
@/tables/lhhcom/broker_table_audit.sql;
@/tables/lhhcom/broker_table_type.sql;
@/tables/lhhcom/broker_table_type_audit.sql;
@/tables/lhhcom/broker_function.sql;
@/tables/lhhcom/broker_function_audit.sql;
@/tables/lhhcom/comms_calc_snapshot.sql;
@/tables/lhhcom/comms_payments_received.sql;
@/tables/lhhcom/dnld_broker.sql;
@/tables/lhhcom/DNLD_BROKER_ACCRED.sql;
@/tables/lhhcom/dnld_company.sql;
@/tables/lhhcom/DNLD_COMPANY_ACCRED.sql;
@/tables/lhhcom/dnld_company_address.sql;
@/tables/lhhcom/dnld_company_contact.sql;
@/tables/lhhcom/dnld_invoice.sql;
@/tables/lhhcom/dnld_trn.sql;
@/tables/lhhcom/ext_comms_payments_received.sql;
@/tables/lhhcom/invoice_type.sql;
@/tables/lhhcom/invoice.sql;
@/tables/lhhcom/invoice_audit.sql;
@/tables/lhhcom/invoice_detail.sql;
@/tables/lhhcom/invoice_detail_audit.sql;
@/tables/lhhcom/ohi_new_tables.sql;
@/tables/lhhcom/new_ohi_comm_and_hold_tables.sql;
@/tables/lhhcom/upld_comms_payments_received.sql;

@/sequences/lhhcom/ACCREDITATION_TYPE_SEQ_NO.sql;
@/sequences/lhhcom/BROKER_ID_NO_SEQ.sql;
@/sequences/lhhcom/BROKER_TABLE_ID_NO_SEQ.sql;
@/sequences/lhhcom/BROKER_TABLE_TYPE_ID_NO_SEQ.sql;
@/sequences/lhhcom/COMPANY_CONTACT_TYPE_ID_NO_SEQ.sql;
@/sequences/lhhcom/company_fee_type_id_no_seq.sql;
@/sequences/lhhcom/COMPANY_ID_NO_SEQ.sql;
@/sequences/lhhcom/COMPANY_TABLE_ID_NO_SEQ.sql;
@/sequences/lhhcom/COMPANY_TABLE_TYPE_ID_NO_SEQ.sql;
@/sequences/lhhcom/DNLD_BATCH_NO_SEQ.sql;
@/sequences/lhhcom/DETAIL_SEQ_NO.sql;
@/sequences/lhhcom/DNLD_TRN_SEQ_NO.sql;
@/sequences/lhhcom/INVOICE_NO_SEQ.sql;

@/functions/lhhcom/check_if_number.sql;
@/functions/lhhcom/get_broker_from_comp.sql;
@/functions/lhhcom/get_broker_id_no.sql;
@/functions/lhhcom/get_broker_table_desc.sql;
@/functions/lhhcom/get_broker_table_type_desc.sql;
@/functions/lhhcom/get_comm_hub_template_name.sql;
@/functions/lhhcom/get_company_id_no.sql;
@/functions/lhhcom/get_company_table_desc.sql;
@/functions/lhhcom/get_company_table_type_desc.sql;
@/functions/lhhcom/get_invoice_hold_reason.sql;
@/functions/lhhcom/isvalid_broker_id_no.sql;
@/functions/lhhcom/isvalid_company_id_no.sql;
@/functions/lhhcom/isvalid_group_code.sql;
@/functions/lhhcom/isvalid_person_code.sql;
@/functions/lhhcom/isvalid_poep_id.sql;
@/functions/lhhcom/isvalid_policy_code.sql;
@/functions/lhhcom/isvalid_product_code.sql;
@/functions/lhhcom/check_resigned_status;


@/packages/lhhcom/commissions_pkg.sql;
@/packages/lhhcom/comms_calc_pkg.sql;
@/packages/lhhcom/COMMS_COMM_HUB_PKG.sql;
@/packages/lhhcom/ohi_policies_load_pkg.sql;
@/packages/lhhcom/DNLD_TRN_FUSION_PKG.sql;
@/packages/lhhcom/STAMP_TRN.sql;
@/packages/lhhcom/UPLD_TRN_PKG.sql;

@/functions/lhhcom/get_comm_percent.sql;
@/functions/lhhcom/get_comm_percentage.sql;
@/functions/lhhcom/get_comm_perc_reason.sql;
@/functions/lhhcom/get_hold_ind.sql;
@/functions/lhhcom/get_hold_reason.sql;
@/functions/lhhcom/get_comm_perc_reason.sql;
@/functions/lhhcom/get_hold_reason.sql;

@/indexes/lhhcom/accred_type_aud_idx.sql;
@/indexes/lhhcom/accred_type_idx.sql;
@/indexes/lhhcom/address_type_aud_idx.sql;
@/indexes/lhhcom/address_type_idx.sql;
@/indexes/lhhcom/broker_accred_audit_idx.sql;
@/indexes/lhhcom/broker_accred_idx.sql;
@/indexes/lhhcom/broker_audit_idx.sql;
@/indexes/lhhcom/broker_comments_idx.sql;
@/indexes/lhhcom/broker_function_aud_idx.sql;
@/indexes/lhhcom/broker_function_idx.sql;
@/indexes/lhhcom/broker_idx.sql;
@/indexes/lhhcom/broker_table_aud_idx.sql;
@/indexes/lhhcom/broker_table_idx.sql;
@/indexes/lhhcom/broker_table_type_idx.sql;
@/indexes/lhhcom/broker_tab_ty_aud_idx.sql;
@/indexes/lhhcom/comms_calc_snap_idx.sql;
@/indexes/lhhcom/comms_calc_type_idx.sql;
@/indexes/lhhcom/comms_payment_rec_idx.sql;
@/indexes/lhhcom/company_accred_audit_idx.sql;
@/indexes/lhhcom/company_accred_idx.sql;
@/indexes/lhhcom/company_address_aud_idx.sql;
@/indexes/lhhcom/company_address_idx.sql;
@/indexes/lhhcom/company_audit_idx.sql;
@/indexes/lhhcom/company_comments_idx.sql;
@/indexes/lhhcom/company_contact_aud_idx.sql;
@/indexes/lhhcom/company_contact_idx.sql;
@/indexes/lhhcom/company_contact_type_idx.sql;
@/indexes/lhhcom/company_cont_ty_aud_idx.sql;
@/indexes/lhhcom/company_country_aud_idx.sql;
@/indexes/lhhcom/company_country_idx.sql;
@/indexes/lhhcom/company_fee_aud_idx.sql;
@/indexes/lhhcom/company_fee_idx.sql;
@/indexes/lhhcom/company_fee_type_aud_idx.sql;
@/indexes/lhhcom/company_fee_type_idx.sql;
@/indexes/lhhcom/company_function_aud_idx.sql;
@/indexes/lhhcom/company_function_idx.sql;
@/indexes/lhhcom/company_idx.sql;
@/indexes/lhhcom/company_reg_aud_idx.sql;
@/indexes/lhhcom/company_reg_idx.sql;
@/indexes/lhhcom/company_table_aud_idx.sql;
@/indexes/lhhcom/company_table_idx.sql;
@/indexes/lhhcom/company_table_type_aud_idx.sql;
@/indexes/lhhcom/company_table_type_idx.sql;
@/indexes/lhhcom/dnld_broker_accred_idx.sql;
@/indexes/lhhcom/dnld_broker_idx.sql;
@/indexes/lhhcom/dnld_company_accred_idx.sql;
@/indexes/lhhcom/dnld_company_address_idx.sql;
@/indexes/lhhcom/dnld_company_contact_idx.sql;
@/indexes/lhhcom/dnld_company_idx.sql;
@/indexes/lhhcom/dnld_invoice_idx.sql;
@/indexes/lhhcom/dnld_trn_idx.sql;
@/indexes/lhhcom/invoice_detail_idx.sql;
@/indexes/lhhcom/invoice_idx.sql;
@/indexes/lhhcom/ohi_enrollemnt_products_aud_idx.sql;
@/indexes/lhhcom/ohi_enrollment_products_idx.sql;
@/indexes/lhhcom/ohi_groups_aud_idx.sql;
@/indexes/lhhcom/ohi_groups_idx.sql;
@/indexes/lhhcom/ohi_insured_entities_aud_idx.sql;
@/indexes/lhhcom/ohi_insured_entities_idx.sql;
@/indexes/lhhcom/ohi_policies_aud_idx.sql;
@/indexes/lhhcom/ohi_policyholders_aud_idx.sql;
@/indexes/lhhcom/ohi_policyholders_idx.sql;
@/indexes/lhhcom/ohi_policy_brokers_audit_idx.sql;
@/indexes/lhhcom/ohi_policy_brokers_idx.sql;
@/indexes/lhhcom/ohi_policy_enrollments_aud_idx.sql;
@/indexes/lhhcom/ohi_policy_enrollments_idx.sql;
@/indexes/lhhcom/ohi_products_aud_idx.sql;
@/indexes/lhhcom/ohi_products_idx.sql;
@/indexes/lhhcom/upld_comms_payments_rec_idx.sql;

@/synonyms/synonyms.sql;
@/procedures/lhhcom/alter_all_triggers.sql;
@/triggers/lhhcom/ACCREDITATION_TYPE_AUD_BEF_TRG.sql;
@/triggers/lhhcom/ADDRESS_TYPE_AUDIT_BEFORE_TRG.sql;
@/triggers/lhhcom/BROKER_ACCREDITAT_AUD_BEF_TRG.sql;
@/triggers/lhhcom/BROKER_AUDIT_TRG.sql;
@/triggers/lhhcom/BROKER_BEFORE_TRG.sql;
@/triggers/lhhcom/BROKER_FUNCTION_AUDIT_BEF_TRG.sql;
--@/triggers/lhhcom/BROKER_FUNCTION_TRG.SQL
@/triggers/lhhcom/BROKER_TABLE_AUDIT_TRG.sql;
@/triggers/lhhcom/BROKER_TABLE_TYPE_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_ACCREDITAT_AUD_BEF_TRG.sql;
@/triggers/lhhcom/COMPANY_ADDRESS_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_ADDRESS_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_AUDIT_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_CONTACT_AUDIT_TRG.SQL
@/triggers/lhhcom/COMPANY_CONTACT_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_CONTACT_TYPE_BEF_TRG.sql;
@/triggers/lhhcom/COMPANY_COUNTRY_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_COUNTRY_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_FEE_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_FEE_TYPE_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_FUNCTION_AUDIT_BEF_TRG.sql;
@/triggers/lhhcom/COMPANY_FUNCTION_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_REG_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_REG_BEFORE_TRG.sql;
@/triggers/lhhcom/COMPANY_TABLE_AUDIT_TRG.sql;
@/triggers/lhhcom/COMPANY_TABLE_TYPE_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_ENROLLMENT_PRODUCTS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_GROUPS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_INSURED_ENTITIES_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_POLICIES_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_POLICYHOLDERS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_POLICY_BROKERS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_POLICY_GROUPS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_POLICY_ENROLLMENTS_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_PRODUCTS_AUDIT_TRG.sql;
@/triggers/lhhcom/INVOICE_BEFORE_TRG.sql;
@/triggers/lhhcom/INVOICE_AUDIT_BEF_TRG.sql;
@/triggers/lhhcom/INVOICE_DETAIL_AUDIT_BEF_TRG.sql;
@/triggers/lhhcom/OHI_COMM_PERC_AUDIT_TRG.sql;
@/triggers/lhhcom/OHI_HOLD_IND_AUDIT_TRG.sql;
 