select 'select * from (select lndsc, count(*) cnt from (select substr(TRANSACTION_DESC, 1, 30) lndsc FROM ' || owner || '.' || table_name || ') group by lndsc order by 1) where cnt > 100;' line from all_tables
 where table_name like '%AUDIT';

select owner, table_name, num_rows from all_tables order by 3 desc; 
 where table_name like '%AUDIT';
 
select q'[select ']' || owner || '.' || table_name || q'[' tble, count(*) cnt from ]' || owner || '.' || table_name || q'[ where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all]' line from all_tables
 where table_name like '%AUDIT';

select * from (
select 'UTIL.SYSTEM_PARAMETER_AUDIT' tble, count(*) cnt from UTIL.SYSTEM_PARAMETER_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.ACCREDITATION_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.ACCREDITATION_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.ADDRESS_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.ADDRESS_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_CONTACT_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_CONTACT_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_COUNTRY_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_COUNTRY_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_ACCREDITATION_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_ACCREDITATION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_ADDRESS_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_ADDRESS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_CONTACT_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_CONTACT_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_FEE_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_FEE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_FEE_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_FEE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_TABLE_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_TABLE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_TABLE_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_TABLE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_FUNCTION_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_FUNCTION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.BROKER_ACCREDITATION_AUDIT' tble, count(*) cnt from LHHCOM.BROKER_ACCREDITATION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.BROKER_AUDIT' tble, count(*) cnt from LHHCOM.BROKER_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.BROKER_TABLE_AUDIT' tble, count(*) cnt from LHHCOM.BROKER_TABLE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.BROKER_TABLE_TYPE_AUDIT' tble, count(*) cnt from LHHCOM.BROKER_TABLE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.BROKER_FUNCTION_AUDIT' tble, count(*) cnt from LHHCOM.BROKER_FUNCTION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.INVOICE_DETAIL_AUDIT' tble, count(*) cnt from LHHCOM.INVOICE_DETAIL_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_GROUPS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_GROUPS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_POLICIES_AUDIT' tble, count(*) cnt from LHHCOM.OHI_POLICIES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_POLICY_GROUPS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_POLICY_GROUPS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_POLICY_BROKERS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_POLICY_BROKERS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_POLICYHOLDERS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_POLICYHOLDERS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_INSURED_ENTITIES_AUDIT' tble, count(*) cnt from LHHCOM.OHI_INSURED_ENTITIES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_POLICY_ENROLLMENTS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_POLICY_ENROLLMENTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_PRODUCTS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_PRODUCTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_ENROLLMENT_PRODUCTS_AUDIT' tble, count(*) cnt from LHHCOM.OHI_ENROLLMENT_PRODUCTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_COMM_PERC_AUDIT' tble, count(*) cnt from LHHCOM.OHI_COMM_PERC_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.OHI_HOLD_IND_AUDIT' tble, count(*) cnt from LHHCOM.OHI_HOLD_IND_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COMPANY_REG_AUDIT' tble, count(*) cnt from LHHCOM.COMPANY_REG_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.TEMP_INVOICE_AUDIT' tble, count(*) cnt from LHHCOM.TEMP_INVOICE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.INVOICE_AUDIT' tble, count(*) cnt from LHHCOM.INVOICE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.COUNTRY_TAXES_AUDIT' tble, count(*) cnt from LHHCOM.COUNTRY_TAXES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' union all
select 'LHHCOM.INVOICE_PAYMENTS_AUDIT' tble, count(*) cnt from LHHCOM.INVOICE_PAYMENTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %'
) where cnt > 0 order by 2 desc;

select q'[select transaction_desc dsc, count(*) cnt from ]' || owner || '.' || table_name || q'[ where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all]' line from all_tables
 where table_name like '%AUDIT';

select * from (
select transaction_desc dsc, count(*) cnt from UTIL.SYSTEM_PARAMETER_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.ACCREDITATION_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.ADDRESS_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_CONTACT_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_COUNTRY_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_ACCREDITATION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_ADDRESS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_CONTACT_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_FEE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_FEE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_TABLE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_TABLE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_FUNCTION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.BROKER_ACCREDITATION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.BROKER_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.BROKER_TABLE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.BROKER_TABLE_TYPE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.BROKER_FUNCTION_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.INVOICE_DETAIL_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_GROUPS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_POLICIES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_POLICY_GROUPS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_POLICY_BROKERS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_POLICYHOLDERS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_INSURED_ENTITIES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_POLICY_ENROLLMENTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_PRODUCTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_ENROLLMENT_PRODUCTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_COMM_PERC_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.OHI_HOLD_IND_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COMPANY_REG_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.TEMP_INVOICE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.INVOICE_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.COUNTRY_TAXES_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc union all
select transaction_desc dsc, count(*) cnt from LHHCOM.INVOICE_PAYMENTS_AUDIT where transaction_desc like 'Change%' and upper(transaction_desc) NOT LIKE '% FROM %' group by transaction_desc
) order by 2 desc;
