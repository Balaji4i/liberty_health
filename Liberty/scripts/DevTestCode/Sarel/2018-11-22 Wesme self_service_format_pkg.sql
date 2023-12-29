CREATE OR REPLACE PACKAGE  self_service_format_pkg
AS
/**
<pre>
----------------------------------------------------------------------
Project:     : Medware Application
Description  : Web Service output message formats
File Name    : $BASE/src/sql/self_service_format_pkg
Author       : Juliet Ogden
Requirements : Access to account SCHEMA
Call Syntax  : @self_service_format_pkg(*)
Ammedments   :
Date        User     Change Description
========   ======== =================================================
25/08/2017  Juliet   Modernization Strategic
23/10/2017  Juliet   Add contacts entity to JSON
06/11/2017  Juliet   Add authorizations
15/11/2017  Juliet   Add policy country    
22/11/2017  Juliet   Add provider discipline
01/12/2017  Juliet   Remove ':' from error message JSON
07/12/2017  KimK     Add employer fields to JSON
19/12/2017  Juliet   Add person code
</pre>
*/
  
/* Format JSON */
PROCEDURE no_result_prc(
    p_reason IN VARCHAR2,
    p_reason_code IN VARCHAR2 DEFAULT 1,
    p_clob OUT CLOB
    );
    
PROCEDURE policy_json_prc(
 p_policy_record  IN OUT NOCOPY self_service_v1_pkg.policy_record,
 p_policy_json_clob OUT CLOB
 );
 
 PROCEDURE membership_json_prc(
 p_membership_record  IN OUT NOCOPY self_service_v1_pkg.membership_record,
 p_membership_json_clob OUT CLOB
);

PROCEDURE employer_json_prc(
 p_employer_record  IN OUT NOCOPY self_service_v1_pkg.employer_record,
 p_employer_json_clob OUT CLOB
);
 
PROCEDURE brand_json_prc(
 p_brand_record  IN OUT NOCOPY self_service_v1_pkg.brand_record,
 p_brand_json_clob OUT CLOB
);

PROCEDURE product_json_prc(
 p_product_record  IN OUT NOCOPY self_service_v1_pkg.product_record,
  p_product_json_clob OUT CLOB
);

PROCEDURE provider_json_prc(
 p_provider_record  IN OUT NOCOPY self_service_v1_pkg.provider_record,
 p_provider_json_clob OUT CLOB
);

PROCEDURE broker_json_prc(
 p_broker_record  IN OUT NOCOPY self_service_v1_pkg.broker_record,
 p_broker_json_clob OUT CLOB
);

PROCEDURE contacts_json_prc(
 p_contacts_record  IN OUT NOCOPY self_service_v1_pkg.contacts_record,
 p_contacts_json_clob OUT CLOB
);

PROCEDURE dependant_json_prc(
 p_dependant_record  IN OUT NOCOPY self_service_v1_pkg.dependant_table,
 p_dependant_json_clob OUT CLOB
);

PROCEDURE auth_json_prc(
 p_auth_record  IN OUT NOCOPY self_service_v1_pkg.auth_record,
 p_auth_json_clob OUT CLOB
);

PROCEDURE policy_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_policy_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
);

PROCEDURE employer_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_employer_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
);

PROCEDURE provider_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_provider_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
);

PROCEDURE broker_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_broker_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
);

PROCEDURE user_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_user_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
);


 END self_service_format_pkg;
/


CREATE OR REPLACE PACKAGE BODY self_service_format_pkg
AS
/* 
When no json message is returned then send a 'No Result' message
*/
PROCEDURE no_result_prc(
    p_reason IN VARCHAR2,
    p_reason_code IN VARCHAR2 DEFAULT 1,
    p_clob OUT CLOB
    )
   AS 
   v_error_json JSON;
   v_data_json  JSON;
BEGIN
  v_error_json := json();
  v_error_json.put('code', p_reason_code);
  v_error_json.put('message', p_reason);
  
  v_data_json := json();
  v_data_json.put('errors',v_error_json);
  
  dbms_lob.createtemporary(p_clob, true);
  v_data_json.to_clob(p_clob);
 END no_result_prc;
 
 /*
Format JSON message for policy/member 
*/
PROCEDURE policy_json_prc(
 p_policy_record  IN OUT NOCOPY self_service_v1_pkg.policy_record,
 p_policy_json_clob OUT CLOB
)
AS
 v_parameters_json JSON;

 v_member_json     JSON;
 v_data_json       JSON; 
BEGIN

  v_member_json := json();
  v_member_json.put('policyCode', p_policy_record.v_policy_code);
  v_member_json.put('dependantCode', p_policy_record.v_dependant_code);
  v_member_json.put('groupCode', p_policy_record.v_group_code);
  IF p_policy_record.v_broker_code IS NULL THEN
   v_member_json.put('brokerCode', p_policy_record.v_broker_code);
  ELSE
   v_member_json.put('brokerCode', p_policy_record.v_agent_code);
  END IF; 
   v_member_json.put('status', p_policy_record.v_status);
   v_member_json.put('brandCode', p_policy_record.v_brand_code);
   v_member_json.put('productCode', p_policy_record.v_product_code);
   v_member_json.put('lastCardDate', p_policy_record.v_last_card_date);
   v_member_json.put('crossReference', p_policy_record.v_xref);

   v_data_json := json();
   v_data_json.put('data', v_member_json);

   dbms_lob.createtemporary(p_policy_json_clob, true);
   
   v_data_json.to_clob(p_policy_json_clob);
 
 END policy_json_prc;

 /*
Format JSON message for membership/member 
*/
PROCEDURE membership_json_prc(
 p_membership_record  IN OUT NOCOPY self_service_v1_pkg.membership_record,
 p_membership_json_clob OUT CLOB
)
AS
 v_parameters_json JSON;

 v_member_json      JSON;
 v_mainmember_json  JSON;
 v_data_json        JSON;
BEGIN

  v_member_json := json();
  v_member_json.put('policyCode', p_membership_record.v_policy_code);
  v_member_json.put('groupCode', p_membership_record.v_group);
  v_member_json.put('group', p_membership_record.v_groupname);
  v_member_json.put('groupClass', p_membership_record.v_groupclass);
  v_member_json.put('country', p_membership_record.v_country);
 
 IF p_membership_record.v_broker IS NULL THEN
   v_member_json.put('brokerCode', p_membership_record.v_broker_code);
   v_member_json.put('broker', p_membership_record.v_broker);
  ELSE
   v_member_json.put('brokerCode', p_membership_record.v_agent_code);
   v_member_json.put('broker', p_membership_record.v_agent);
  END IF; 

  v_member_json.put('brandCode', p_membership_record.v_brand_code);
  v_member_json.put('brand', p_membership_record.v_brand);
  v_member_json.put('lastCardDate', p_membership_record.v_last_card_date);
  v_member_json.put('crossReference', p_membership_record.v_xref);
   
  v_mainmember_json := json();
  v_mainmember_json.put('dependantCode', p_membership_record.v_dependant);
  v_mainmember_json.put('empNo', p_membership_record.v_empno);
  v_mainmember_json.put('maritalStatus', p_membership_record.v_marital_status);
  v_mainmember_json.put('status', p_membership_record.v_status);
  v_mainmember_json.put('language', p_membership_record.v_language);
  v_mainmember_json.put('preregCode', p_membership_record.v_prereg_code);
  v_mainmember_json.put('preregStatus', p_membership_record.v_prereg_status);
  v_mainmember_json.put('susresStatus', p_membership_record.v_susres_status);
  v_mainmember_json.put('employedDate', p_membership_record.v_employed_date);
  v_mainmember_json.put('id', p_membership_record.v_id);
  v_mainmember_json.put('title', p_membership_record.v_title);
  v_mainmember_json.put('surname', p_membership_record.v_surname);
  v_mainmember_json.put('initials', p_membership_record.v_initials);
  v_mainmember_json.put('firstName', p_membership_record.v_firstname);
  v_mainmember_json.put('gender', p_membership_record.v_gender);
  v_mainmember_json.put('dateOfBirth', p_membership_record.v_date_of_birth);
  v_mainmember_json.put('registeredDate', p_membership_record.v_registered_date);
  v_mainmember_json.put('resignedDate', p_membership_record.v_resigned_date);
  v_mainmember_json.put('benefitDate', p_membership_record.v_benefit_date);
  v_mainmember_json.put('division', p_membership_record.v_division);
  v_mainmember_json.put('payroll', p_membership_record.v_payroll);
  v_mainmember_json.put('paypoint', p_membership_record.v_paypoint);
  
  v_mainmember_json.put('passport', p_membership_record.v_passport);
  v_mainmember_json.put('productCode', p_membership_record.v_product_code);
  v_mainmember_json.put('product', p_membership_record.v_product);
  v_mainmember_json.put('personCode', p_membership_record.v_person_code);

  v_member_json.put('mainMember', v_mainmember_json);
  
  v_data_json := json();
  v_data_json.put('data', v_member_json);

  dbms_lob.createtemporary(p_membership_json_clob, true);
   
   v_data_json.to_clob(p_membership_json_clob);
 
 END membership_json_prc;
 
 /*
Format JSON message for employer
*/
PROCEDURE employer_json_prc(
 p_employer_record  IN OUT NOCOPY self_service_v1_pkg.employer_record,
 p_employer_json_clob OUT CLOB
)
AS
 v_employer_json   JSON;
 v_data_json       JSON;
BEGIN

  v_employer_json := json();
  v_employer_json.put('groupCode', p_employer_record.v_group_code);
  v_employer_json.put('group', p_employer_record.v_group);
  v_employer_json.put('class', p_employer_record.v_group_class);
  v_employer_json.put('brandCode', p_employer_record.v_brand_code);
  v_employer_json.put('brand', p_employer_record.v_brand);
  v_employer_json.put('parentGroupCode', p_employer_record.v_parent_group_code);
  v_employer_json.put('parentGroup', p_employer_record.v_parent_group);
  v_employer_json.put('country', p_employer_record.v_country);
  v_employer_json.put('preferredCurrencyCode', p_employer_record.v_preferred_currency_code);
  v_employer_json.put('preferredCurrency', p_employer_record.v_preferred_currency);
  v_employer_json.put('premiumRule', p_employer_record.v_premium_rule);
  v_employer_json.put('contractStartDate', p_employer_record.v_contract_start_date);
  v_employer_json.put('contractEndDate', p_employer_record.v_contract_end_date);
  v_employer_json.put('raisingFrequency', p_employer_record.v_raising_frequency);
  v_employer_json.put('broker', p_employer_record.v_broker);
  v_employer_json.put('reconUser', p_employer_record.v_recon_user);
  v_employer_json.put('territory', p_employer_record.v_territory);

  v_data_json := json();
  v_data_json.put('data', v_employer_json);
 
  dbms_lob.createtemporary(p_employer_json_clob, true);
  
   v_data_json.to_clob(p_employer_json_clob);
 
 END employer_json_prc;
 
 /*
Format JSON message for brand
*/
PROCEDURE brand_json_prc(
 p_brand_record  IN OUT NOCOPY self_service_v1_pkg.brand_record,
 p_brand_json_clob OUT CLOB
)
AS
 v_brand_json   JSON;
 v_data_json    JSON;
BEGIN

  v_brand_json := json();
  v_brand_json.put('brandCode', p_brand_record.v_brand_code);
  v_brand_json.put('brand', p_brand_record.v_brand);

  v_data_json := json();
  v_data_json.put('data', v_brand_json);

  dbms_lob.createtemporary(p_brand_json_clob, true);
   
   v_data_json.to_clob(p_brand_json_clob);
 
 END brand_json_prc;

/*
Format JSON message for product
*/
PROCEDURE product_json_prc(
 p_product_record  IN OUT NOCOPY self_service_v1_pkg.product_record,
 p_product_json_clob OUT CLOB
)
AS
 v_product_json   JSON;
 v_data_json      JSON;
BEGIN

  v_product_json := json();
  v_product_json.put('productCode', p_product_record.v_product_code);
  v_product_json.put('product', p_product_record.v_product);

  v_data_json := json();
  v_data_json.put('data', v_product_json);

  dbms_lob.createtemporary(p_product_json_clob, true);
   
   v_data_json.to_clob(p_product_json_clob);
 
 END product_json_prc;

/*
Format JSON message for service provider
*/
PROCEDURE provider_json_prc(
 p_provider_record  IN OUT NOCOPY self_service_v1_pkg.provider_record,
 p_provider_json_clob OUT CLOB
)
AS
 v_provider_json   JSON;
 v_data_json       JSON;
BEGIN

  v_provider_json := json();
  v_provider_json.put('providerCode', p_provider_record.v_provider_code);
  v_provider_json.put('firstname', p_provider_record.v_firstname);
  v_provider_json.put('middleName', p_provider_record.v_middle_name);
  v_provider_json.put('name', p_provider_record.v_name);
  v_provider_json.put('country', p_provider_record.v_country);
  v_provider_json.put('discipline', p_provider_record.v_discipline);
  v_provider_json.put('preferredCurrencyCode', p_provider_record.v_preferred_currency_code);
  v_provider_json.put('preferredCurrency', p_provider_record.v_preferred_currency);
  v_provider_json.put('SAMDCNumber', p_provider_record.v_samdc_number);
  v_provider_json.put('startDate', p_provider_record.v_start_date);
  v_provider_json.put('endDate', p_provider_record.v_end_date);
  v_provider_json.put('id', p_provider_record.v_id);
  v_provider_json.put('crossReference', p_provider_record.v_cross_reference);
  v_provider_json.put('dispensingStatus', p_provider_record.v_dispensing_status);
  v_provider_json.put('dispeningLicense', p_provider_record.v_dispensing_license);
  v_provider_json.put('emergencyNumber', p_provider_record.v_emergency_number);

  v_data_json := json();
  v_data_json.put('data', v_provider_json);

  dbms_lob.createtemporary(p_provider_json_clob, true);
   
   v_data_json.to_clob(p_provider_json_clob);
 
 END provider_json_prc;
 
/*
Format JSON message for broker
*/
PROCEDURE broker_json_prc(
 p_broker_record  IN OUT NOCOPY self_service_v1_pkg.broker_record,
 p_broker_json_clob OUT CLOB
)
AS
 v_broker_json   JSON;
 v_data_json     JSON;
BEGIN

  v_broker_json := json();
  v_broker_json.put('brokerCode', p_broker_record.v_broker_id_no);
  v_broker_json.put('parentBrokerCode', p_broker_record.v_parent_broker_id_no);
  v_broker_json.put('broker', p_broker_record.v_broker_name);
  v_broker_json.put('brokerType', p_broker_record.v_broker_table_type_desc);
  v_broker_json.put('companyCode', p_broker_record.v_company_id_no);
  v_broker_json.put('startDate', p_broker_record.v_effective_start_date);
  v_broker_json.put('endDate', p_broker_record.v_effective_end_date);
  v_broker_json.put('brokerTypeStartDate', p_broker_record.v_bt_effective_start_date);
  v_broker_json.put('vatNo', p_broker_record.v_vat_no);
  v_broker_json.put('companyType', p_broker_record.v_company_table_type_desc);
  v_broker_json.put('language', p_broker_record.v_language_code);
  v_broker_json.put('phoneMobile', p_broker_record.v_cellphone_no);
  v_broker_json.put('medicalAccredNo', p_broker_record.v_medical_accred_no);
  v_broker_json.put('medicalStartDate', p_broker_record.v_medical_start_date);
  v_broker_json.put('medicalExpiryDate', p_broker_record.v_medical_expiry_date);
  v_broker_json.put('faisAccredNo', p_broker_record.v_fais_accred_no);
  v_broker_json.put('faisExpiryDate', p_broker_record.v_fais_expiry_date);
  v_broker_json.put('consultant', p_broker_record.v_consultant);
  v_broker_json.put('companyName', p_broker_record.v_company_name);
  v_broker_json.put('brokerAccredNo', p_broker_record.v_broker_accred_no);
  v_broker_json.put('brokerAccredStartDate', p_broker_record.v_broker_accred_start_date);
  v_broker_json.put('brokerAccredExpiryDate', p_broker_record.v_broker_accred_end_date);
  v_broker_json.put('preferredCurrencyCode', p_broker_record.v_preferred_currency_code);

  v_data_json := json();
  v_data_json.put('data', v_broker_json);

  dbms_lob.createtemporary(p_broker_json_clob, true);
   
   v_data_json.to_clob(p_broker_json_clob);
 
 END broker_json_prc;

/*
Format JSON message for address/contacts
*/
PROCEDURE contacts_json_prc(
 p_contacts_record  IN OUT NOCOPY self_service_v1_pkg.contacts_record,
 p_contacts_json_clob OUT CLOB
)
AS
 v_contacts_json   JSON;
 v_address_json    JSON;
 v_addresses_json  JSON_LIST;
 v_data_json       JSON;
BEGIN

  v_contacts_json := json();
  v_contacts_json.put('entityType', p_contacts_record.v_entity_type);
  v_contacts_json.put('entityCode', p_contacts_record.v_entity_code);
  v_contacts_json.put('fax', p_contacts_record.v_fax);
  v_contacts_json.put('phoneBusiness', p_contacts_record.v_phone_business);
  v_contacts_json.put('phonePrivate', p_contacts_record.v_phone_private);
  v_contacts_json.put('phoneMobile', p_contacts_record.v_phone_mobile);
  v_contacts_json.put('email', p_contacts_record.v_email);
  v_contacts_json.put('email2', p_contacts_record.v_email2);
  
  v_addresses_json := json_list();
  
  -- street 
  IF p_contacts_record.v_street_l1 IS NOT NULL 
   OR p_contacts_record.v_street_country IS NOT NULL
  THEN
   v_address_json := json();
   v_address_json.put('type', 'street');
   v_address_json.put('line1', p_contacts_record.v_street_l1);
   v_address_json.put('line2', p_contacts_record.v_street_l2);
   v_address_json.put('line3', p_contacts_record.v_street_l3);
   v_address_json.put('town', p_contacts_record.v_street_town);
   v_address_json.put('postalCode', p_contacts_record.v_street_pcode);
   v_address_json.put('country', p_contacts_record.v_street_country);

   v_addresses_json.append(v_address_json.to_json_value);
 END IF;


  -- postal  
  IF p_contacts_record.v_postal_l1 IS NOT NULL 
   OR p_contacts_record.v_postal_country IS NOT NULL
  THEN
   v_address_json := json();
   v_address_json.put('type', 'postal');
   v_address_json.put('line1', p_contacts_record.v_postal_l1);
   v_address_json.put('line2', p_contacts_record.v_postal_l2);
   v_address_json.put('line3', p_contacts_record.v_postal_l3);
   v_address_json.put('town', p_contacts_record.v_postal_town);
   v_address_json.put('postalCode', p_contacts_record.v_postal_pcode);
   v_address_json.put('country', p_contacts_record.v_postal_country);
  
   v_addresses_json.append(v_address_json.to_json_value);
 END IF;

 IF v_addresses_json IS NOT NULL THEN 
  v_contacts_json.put('addresses', v_addresses_json);
 END IF;
 
 v_data_json := json();
 v_data_json.put('data', v_contacts_json);

  dbms_lob.createtemporary(p_contacts_json_clob, true);
   
   v_data_json.to_clob(p_contacts_json_clob);
 
 END contacts_json_prc;


/*
Format JSON message for dependant/benef one or more
*/
PROCEDURE dependant_json_prc(
 p_dependant_record  IN OUT NOCOPY self_service_v1_pkg.dependant_table,
 p_dependant_json_clob OUT CLOB
)
AS
 v_parameters_json JSON;

 v_dependant_json  JSON;
 v_dependants_json JSON_LIST;
 v_policy_json     JSON;
 v_data_json       JSON;
BEGIN

 v_dependants_json := json_list();

FOR i IN p_dependant_record.FIRST .. p_dependant_record.LAST
LOOP
  v_dependant_json := json();
  v_dependant_json.put('dependantCode', p_dependant_record(i).v_dependant_code);
  v_dependant_json.put('status', p_dependant_record(i).v_status);
  v_dependant_json.put('title', p_dependant_record(i).v_title);
  v_dependant_json.put('surname', p_dependant_record(i).v_surname);
  v_dependant_json.put('firstName', p_dependant_record(i).v_firstname);
  v_dependant_json.put('initials', p_dependant_record(i).v_initials);
  v_dependant_json.put('id', p_dependant_record(i).v_id);
  v_dependant_json.put('gender', p_dependant_record(i).v_gender);
  v_dependant_json.put('dateOfBirth', p_dependant_record(i).v_date_of_birth);
  v_dependant_json.put('registeredDate', p_dependant_record(i).v_registered_date);
  v_dependant_json.put('resignedDate', p_dependant_record(i).v_resigned_date);
  v_dependant_json.put('deceasedDate', p_dependant_record(i).v_deceased_date);
  v_dependant_json.put('benefitDate', p_dependant_record(i).v_benefit_date);
  v_dependant_json.put('status', p_dependant_record(i).v_status);
  v_dependant_json.put('susresStatus', p_dependant_record(i).v_susres_status);
  v_dependant_json.put('preregCode', p_dependant_record(i).v_prereg_code);
  v_dependant_json.put('preregStatus', p_dependant_record(i).v_prereg_status);
  v_dependant_json.put('passport', p_dependant_record(i).v_passport);
  v_dependant_json.put('division', p_dependant_record(i).v_division);
  v_dependant_json.put('payroll', p_dependant_record(i).v_payroll);
  v_dependant_json.put('paypoint', p_dependant_record(i).v_paypoint);
  v_dependant_json.put('empNo', p_dependant_record(i).v_empno);
  v_dependant_json.put('maritalStatus', p_dependant_record(i).v_marital_status);
  v_dependant_json.put('language', p_dependant_record(i).v_language);
  v_dependant_json.put('employedDate', p_dependant_record(i).v_employed_date);
  v_dependant_json.put('productCode', p_dependant_record(i).v_product_code);
  v_dependant_json.put('relationship', p_dependant_record(i).v_relationship);
  v_dependant_json.put('personCode', p_dependant_record(i).v_person_code);

  v_dependants_json.append(v_dependant_json.to_json_value);
 END LOOP;
  v_policy_json := json();
  v_policy_json.put('policyCode', p_dependant_record(1).v_policy_code);
  v_policy_json.put('dependants', v_dependants_json);

  v_data_json := json();
  v_data_json.put('data', v_policy_json);

  dbms_lob.createtemporary(p_dependant_json_clob, true);
   
   v_data_json.to_clob(p_dependant_json_clob);
 
 END dependant_json_prc;
 
 /*
Format JSON message for auth
*/
PROCEDURE auth_json_prc(
 p_auth_record  IN OUT NOCOPY self_service_v1_pkg.auth_record,
 p_auth_json_clob OUT CLOB
)
AS
 v_auth_json   JSON;
 v_data_json     JSON;
BEGIN

  v_auth_json := json();
  v_auth_json.put('authId', p_auth_record.v_auth_id);
  v_auth_json.put('authNumber', p_auth_record.v_auth_number);
  
  v_data_json := json();
  v_data_json.put('data', v_auth_json);

  dbms_lob.createtemporary(p_auth_json_clob, true);
   
   v_data_json.to_clob(p_auth_json_clob);
 
 END auth_json_prc;
 
PROCEDURE policy_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_policy_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
)

AS
 v_parameters_json JSON;

 v_lookup_json  JSON;
 v_lookups_json JSON_LIST;
 v_header_json     JSON;
 v_data_json       JSON;
 
BEGIN
 
 v_lookups_json := json_list();

FOR i IN p_lookup_table.FIRST .. p_lookup_table.LAST
LOOP
 
  v_lookup_json := json();
  v_lookup_json.put('policyCode', p_lookup_table(i).v_policy_code);
  v_lookup_json.put('dependantCode', p_lookup_table(i).v_dependant_code);
  v_lookup_json.put('origin', p_lookup_table(i).v_origin);
  --v_lookup_json.put('personCode', p_lookup_table(i).v_person_code);
  v_lookup_json.put('status', p_lookup_table(i).v_status);
  --v_lookup_json.put('title', p_lookup_table(i).v_title);
  v_lookup_json.put('surname', p_lookup_table(i).v_surname);
  v_lookup_json.put('firstName', p_lookup_table(i).v_firstname);
  v_lookup_json.put('initials', p_lookup_table(i).v_initials);
  v_lookup_json.put('id', p_lookup_table(i).v_id);
  v_lookup_json.put('passport', p_lookup_table(i).v_passport);
  v_lookup_json.put('dateOfBirth', p_lookup_table(i).v_date_of_birth);
  v_lookup_json.put('gender', p_lookup_table(i).v_gender);
  --v_lookup_json.put('language', p_lookup_table(i).v_language);
  --v_lookup_json.put('relationship', p_lookup_table(i).v_relationship);
  --v_lookup_json.put('registeredDate', p_lookup_table(i).v_registered_date);
  --v_lookup_json.put('resignedDate', p_lookup_table(i).v_resigned_date);
  v_lookup_json.put('deceasedDate', p_lookup_table(i).v_deceased_date);
  --v_lookup_json.put('benefitDate', p_lookup_table(i).v_benefit_date);
  v_lookup_json.put('productCode', p_lookup_table(i).v_product_code);
  v_lookup_json.put('brandCode', p_lookup_table(i).v_brand);
  v_lookup_json.put('countryCode', p_lookup_table(i).v_country);
  --v_lookup_json.put('status', p_lookup_table(i).v_status);
--  v_lookup_json.put('susresStatus', p_lookup_table(i).v_susres_status);
--  v_lookup_json.put('preregCode', p_lookup_table(i).v_prereg_code);
--  v_lookup_json.put('preregStatus', p_lookup_table(i).v_prereg_status);
--  v_lookup_json.put('division', p_lookup_table(i).v_division);
--  v_lookup_json.put('payroll', p_lookup_table(i).v_payroll);
--  v_lookup_json.put('paypoint', p_lookup_table(i).v_paypoint);
 -- v_lookup_json.put('employerCode', p_lookup_table(i).v_employer_code);
  v_lookup_json.put('employerName', p_lookup_table(i).v_employer_name);
  v_lookup_json.put('empNo', p_lookup_table(i).v_empno);
  
--  v_lookup_json.put('maritalStatus', p_lookup_table(i).v_marital_status);
--  v_lookup_json.put('employedDate', p_lookup_table(i).v_employed_date);
 
  v_lookups_json.append(v_lookup_json.to_json_value);
 END LOOP;
 
  v_header_json := json();
  
  v_header_json.put('policies', v_lookups_json);
  v_header_json.put('page', p_page);
  v_header_json.put('pageSize', p_page_size);
  v_header_json.put('totalEntries', p_total_entries);


  v_data_json := json();
  v_data_json.put('data', v_header_json);
  dbms_lob.createtemporary(p_lookup_json_clob, true);
  v_data_json.to_clob(p_lookup_json_clob);
 

END policy_lookup_json_prc;
 
PROCEDURE employer_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_employer_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
)

AS
 v_parameters_json JSON;

 v_lookup_json  JSON;
 v_lookups_json JSON_LIST;
 v_header_json     JSON;
 v_data_json       JSON;
 
BEGIN
 
 v_lookups_json := json_list();

FOR i IN p_lookup_table.FIRST .. p_lookup_table.LAST
LOOP
 
  v_lookup_json := json();
  v_lookup_json.put('employerCode', p_lookup_table(i).v_employer_code);
   v_lookup_json.put('employerName', p_lookup_table(i).v_name);
   v_lookup_json.put('parentGroup', p_lookup_table(i).v_parent_group);
   v_lookup_json.put('startDate', p_lookup_table(i).v_start_date);
   v_lookup_json.put('contractStart', p_lookup_table(i).v_contract_from);
   v_lookup_json.put('contractEnd', p_lookup_table(i).v_contract_to);
   v_lookup_json.put('country', p_lookup_table(i).v_country);
  v_lookup_json.put('origin', p_lookup_table(i).v_origin);
  v_lookup_json.put('Name', p_lookup_table(i).v_name);
  

  v_lookups_json.append(v_lookup_json.to_json_value);
 END LOOP;
 
  v_header_json := json();
 v_header_json.put('employers', v_lookups_json);  
v_header_json.put('page', p_page);
  v_header_json.put('pageSize', p_page_size);
  v_header_json.put('totalEntries', p_total_entries);
 

  v_data_json := json();
  v_data_json.put('data', v_header_json);
  dbms_lob.createtemporary(p_lookup_json_clob, true);
  v_data_json.to_clob(p_lookup_json_clob);
 

END employer_lookup_json_prc;

PROCEDURE provider_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_provider_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
)

AS
 v_parameters_json JSON;

 v_lookup_json  JSON;
 v_lookups_json JSON_LIST;
 v_header_json     JSON;
 v_data_json       JSON;
 
BEGIN
 
 v_lookups_json := json_list();

FOR i IN p_lookup_table.FIRST .. p_lookup_table.LAST
LOOP
 
  v_lookup_json := json();
  v_lookup_json.put('providerCode', p_lookup_table(i).v_provider_code);
  v_lookup_json.put('origin', p_lookup_table(i).v_origin);
  v_lookup_json.put('surname', p_lookup_table(i).v_surname);
  v_lookup_json.put('firstName', p_lookup_table(i).v_firstname);
  v_lookup_json.put('initials', p_lookup_table(i).v_initials);
  v_lookup_json.put('specialty', p_lookup_table(i).v_specialty);
    v_lookup_json.put('specialtyDesc', p_lookup_table(i).v_specialty_desc);
  v_lookups_json.append(v_lookup_json.to_json_value);
 END LOOP;
 
  v_header_json := json();
  v_header_json.put('providers', v_lookups_json);
  v_header_json.put('page', p_page);
  v_header_json.put('pageSize', p_page_size);
  v_header_json.put('totalEntries', p_total_entries);
 
  v_data_json := json();
  v_data_json.put('data', v_header_json);
  dbms_lob.createtemporary(p_lookup_json_clob, true);
  v_data_json.to_clob(p_lookup_json_clob);
 

END provider_lookup_json_prc;

PROCEDURE broker_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_broker_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
)

AS
 v_parameters_json JSON;

 v_lookup_json  JSON;
 v_lookups_json JSON_LIST;
 v_header_json     JSON;
 v_data_json       JSON;
 
BEGIN
 
 v_lookups_json := json_list();

FOR i IN p_lookup_table.FIRST .. p_lookup_table.LAST
LOOP
 
  v_lookup_json := json();
  v_lookup_json.put('companyCode', p_lookup_table(i).v_company_code); 
  v_lookup_json.put('companyName', p_lookup_table(i).v_company_name);
  v_lookup_json.put('companyType', p_lookup_table(i).v_company_type);
  v_lookup_json.put('brokerCode', p_lookup_table(i).v_broker_code);
  v_lookup_json.put('origin', p_lookup_table(i).v_origin);
  v_lookup_json.put('brokerTitle', p_lookup_table(i).v_title);
  v_lookup_json.put('brokerSurname', p_lookup_table(i).v_surname);
  v_lookup_json.put('brokerFirstName', p_lookup_table(i).v_firstname);
  v_lookup_json.put('brokerInitials', p_lookup_table(i).v_initials);
 
  v_lookup_json.put('brokerType', p_lookup_table(i).v_broker_type);
  v_lookup_json.put('brokerEffectiveStartDate', p_lookup_table(i).v_start_date);
  v_lookup_json.put('brokerEffectiveEndDateinitials', p_lookup_table(i).v_end_date);
  v_lookups_json.append(v_lookup_json.to_json_value);
 END LOOP;
 
  v_header_json := json();
  v_header_json.put('brokers', v_lookups_json); 
  v_header_json.put('page', p_page);
  v_header_json.put('pageSize', p_page_size);
  v_header_json.put('totalEntries', p_total_entries);
 

  v_data_json := json();
  v_data_json.put('data', v_header_json);
  dbms_lob.createtemporary(p_lookup_json_clob, true);
  v_data_json.to_clob(p_lookup_json_clob);
 

END broker_lookup_json_prc;

PROCEDURE user_lookup_json_prc(
 p_lookup_table  IN OUT NOCOPY self_service_v1_pkg.t_user_lookup_table,
 p_page IN NUMBER,
 p_page_size IN NUMBER,
 p_total_entries IN NUMBER,
 p_lookup_json_clob OUT CLOB
)

AS
 v_parameters_json JSON;

 v_lookup_json  JSON;
 v_lookups_json JSON_LIST;
 v_header_json     JSON;
 v_data_json       JSON;
 
BEGIN
 
 v_lookups_json := json_list();

FOR i IN p_lookup_table.FIRST .. p_lookup_table.LAST
LOOP
 
  v_lookup_json := json();
  v_lookup_json.put('userCode', p_lookup_table(i).v_user_code);
  v_lookup_json.put('name', p_lookup_table(i).v_name);
  v_lookup_json.put('countryCode', p_lookup_table(i).v_country);
 
  v_lookups_json.append(v_lookup_json.to_json_value);
 END LOOP;
 
  v_header_json := json();
  v_header_json.put('users', v_lookups_json);
  v_header_json.put('page', p_page);
  v_header_json.put('pageSize', p_page_size);
  v_header_json.put('totalEntries', p_total_entries);


  v_data_json := json();
  v_data_json.put('data', v_header_json);
  dbms_lob.createtemporary(p_lookup_json_clob, true);
  v_data_json.to_clob(p_lookup_json_clob);
 

END user_lookup_json_prc;
 
  
BEGIN
  -- initialize package body to null
  NULL;
END self_service_format_pkg;
/
