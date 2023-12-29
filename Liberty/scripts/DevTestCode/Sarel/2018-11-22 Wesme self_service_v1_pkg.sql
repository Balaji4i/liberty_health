CREATE OR REPLACE PACKAGE  self_service_v1_pkg
AS
/**
<pre>
----------------------------------------------------------------------
Project:     : Medware Application
Description  : Web Service entry points 
File Name    : $BASE/src/sql/self_service_v1_pkg
Author       : Juliet Ogden
Requirements : Access to account SCHEMA
Call Syntax  : @self_service_v1_pkg(*)
Ammedments   :
Date        User     Change Description
========   ======== =================================================
25/08/2017  Juliet   Modernization Strategic
13/10/2017  Juliet   Add contacts email2, additional employer columns
13/10/2017  Juliet   Add error logging 'SSERV Error'
17/10/2017  Juliet   Add broker contacts
23/10/2017  Juliet   Add contacts entity_type and entity_code
31/10/2017  Juliet   Add Company/brokerage records
06/11/2017  Juliet   Add authorizations
15/11/2017  Juliet   Add policy country                     
22/11/2017  Juliet   Add provider columns
04/12/2017  Juliet   Add columns
07/12/2017  KimK     Add employer columns
13/12/2017  Juliet   Add Medware provider
19/12/2017  Juliet   Add person code
</pre>
*/

TYPE policy_record IS RECORD(
  v_policy_code VARCHAR2(50),
  v_dependant_code VARCHAR2(50),
  v_group_code VARCHAR2(50),
  v_broker_code VARCHAR2(50),
  v_agent_code VARCHAR2(50),
  v_status VARCHAR2(50),
  v_brand_code VARCHAR2(50),
  v_product_code VARCHAR2(50),
  v_last_card_date VARCHAR2(30),
  v_xref VARCHAR2(50)
  );

TYPE dependant_record IS RECORD(
  v_policy_code VARCHAR2(50),
  v_dependant_code VARCHAR2(50),
  v_title VARCHAR2(100),
  v_surname VARCHAR2(100),
  v_firstname VARCHAR2(100),
  v_initials VARCHAR2(50),
  v_id VARCHAR2(50),
  v_gender VARCHAR2(50),
  v_date_of_birth VARCHAR2(30),
  v_deceased_date VARCHAR2(30),
  v_registered_date VARCHAR2(30),
  v_resigned_date VARCHAR2(30),
  v_benefit_date VARCHAR2(30),
  v_status VARCHAR2(50),
  v_prereg_code VARCHAR2(50),
  v_prereg_status VARCHAR2(100), 
  v_susres_status VARCHAR2(50),
  v_passport VARCHAR2(50),
  v_division VARCHAR2(100),
  v_payroll VARCHAR2(100),
  v_paypoint VARCHAR2(100),
  v_empno VARCHAR2(50),
  v_marital_status VARCHAR2(50),
  v_language VARCHAR2(50),
  v_employed_date VARCHAR2(50),
  v_product_code VARCHAR2(50),
  v_relationship VARCHAR2(100),
  v_person_code VARCHAR2(50)
  );
  
 TYPE dependant_table IS TABLE OF dependant_record;
 
 TYPE membership_record IS RECORD(
  v_policy_code VARCHAR2(50),
  v_dependant VARCHAR2(50),
  v_group VARCHAR2(50),
  v_groupname VARCHAR2(100),
  v_groupclass VARCHAR2(100),
  v_country VARCHAR2(100),
  v_empno VARCHAR2(50),
  v_broker_code VARCHAR2(50),
  v_broker VARCHAR2(100),
  v_agent_code VARCHAR2(50),
  v_agent VARCHAR2(100),
  v_marital_status VARCHAR2(50),
  v_status VARCHAR2(50),
  v_language VARCHAR2(50),
  v_prereg_status VARCHAR2(100),
  v_susres_status VARCHAR2(100),
  v_employed_date VARCHAR2(50),
  v_product_code VARCHAR2(50),
  v_product VARCHAR2(50),
  v_brand_code VARCHAR2(50),
  v_brand VARCHAR2(50),
  v_id VARCHAR2(50),
  v_title VARCHAR2(50),
  v_surname VARCHAR2(100),
  v_initials VARCHAR2(50),
  v_firstname VARCHAR2(100),
  v_gender VARCHAR2(50),
  v_date_of_birth VARCHAR2(30),
  v_registered_date VARCHAR2(30),
  v_resigned_date VARCHAR2(30),
  v_benefit_date VARCHAR2(30),
  v_division VARCHAR2(50),
  v_payroll VARCHAR2(50),
  v_paypoint VARCHAR2(50),
  v_passport VARCHAR2(50),
  v_last_card_date VARCHAR2(30),
  v_xref VARCHAR2(50),
  v_prereg_code VARCHAR2(50),
  v_preferred_currency_code VARCHAR2(50),
  v_preferred_currency VARCHAR2(50),
  v_person_code VARCHAR2(50)
  );
  
 TYPE contacts_record IS RECORD(
   v_entity_code VARCHAR2(50),
   v_entity_type VARCHAR2(50),
   v_fax VARCHAR2(50),
   v_phone_business VARCHAR2(50),
   v_phone_private VARCHAR2(50),
   v_phone_mobile VARCHAR2(50),
   v_email VARCHAR2(150),
   v_email2 VARCHAR2(150),
   v_street_l1 VARCHAR2(250),
   v_street_l2 VARCHAR2(250),
   v_street_l3 VARCHAR2(250),
   v_street_town VARCHAR2(250),
   v_street_pcode VARCHAR2(250),
   v_street_country VARCHAR2(250),
   v_postal_l1 VARCHAR2(250),
   v_postal_l2 VARCHAR2(250),
   v_postal_l3 VARCHAR2(250),
   v_postal_town VARCHAR2(250),
   v_postal_pcode VARCHAR2(250),
   v_postal_country VARCHAR2(250)
   );
   
 TYPE employer_record IS RECORD(
  v_group_code VARCHAR2(50),
  v_group VARCHAR2(100),
  v_group_class VARCHAR2(100),
  v_brand_code VARCHAR2(50),
  v_brand VARCHAR2(100),
  v_parent_group_code VARCHAR2(50),
  v_parent_group VARCHAR2(100),
  v_country VARCHAR2(150),
  v_preferred_currency_code VARCHAR2(50),
  v_preferred_currency VARCHAR2(100),
  v_premium_rule VARCHAR2(50),
  v_contract_start_date VARCHAR2(30),
  v_contract_end_date VARCHAR2(30),
  v_raising_frequency VARCHAR2(100),
  v_broker VARCHAR2(100),
  v_recon_user VARCHAR2(200),
  v_territory VARCHAR2(50)
  );
  
 TYPE broker_record IS RECORD(
  v_broker_id_no VARCHAR2(50),
  v_parent_broker_id_no VARCHAR2(100),
  v_broker_name VARCHAR2(100),
  v_broker_table_type_desc VARCHAR2(100),
  v_company_id_no VARCHAR2(50),
  v_effective_start_date VARCHAR2(30),
  v_effective_end_date VARCHAR2(30),
  v_bt_effective_start_date VARCHAR2(30),
  v_vat_no VARCHAR2(50),
  v_company_table_type_desc VARCHAR2(100),
  v_language_code VARCHAR2(50),
  v_cellphone_no VARCHAR2(50),
  v_medical_accred_no VARCHAR2(50),
  v_medical_start_date VARCHAR2(30),
  v_medical_expiry_date VARCHAR2(30),
  v_fais_accred_no VARCHAR2(50),
  v_fais_expiry_date VARCHAR2(30),
  v_consultant VARCHAR2(50),
  v_company_name VARCHAR2(100),
  v_broker_accred_no VARCHAR2(50),
  v_broker_accred_start_date VARCHAR2(30),
  v_broker_accred_end_date VARCHAR2(30),
  v_preferred_currency_code VARCHAR2(50)
  );

TYPE broker_notes_record IS RECORD(
   v_entity_code VARCHAR2(50),
   v_entity_type VARCHAR2(50),
   v_username   VARCHAR2(50),
   v_notes_date VARCHAR2(30),
   v_notes_desc VARCHAR2(250)
   );

TYPE company_record IS RECORD (
  v_company_id_no                  NUMBER(9),
  v_company_name                  VARCHAR2(100),
  v_internal_broker_ind           VARCHAR2(1),  
  v_multinational_ind             VARCHAR2(1),      
  v_vat_reg_ind                   VARCHAR2(1),  
  v_wht_cert_ind                  VARCHAR2(1),  
  v_company_agreement_ind         VARCHAR2(1),  
  v_referral_agreement_ind        VARCHAR2(1),  
  v_company_reg_doc_ind           VARCHAR2(1),  
  v_bank_details_ind              VARCHAR2(1),  
  v_id_doc_ind                    VARCHAR2(1),  
  v_letter_of_intent_ind          VARCHAR2(1),  
  v_agreement_application_ind     VARCHAR2(1),  
  v_address_ind                   VARCHAR2(1),  
  v_tax_id_no_ind                 VARCHAR2(1),  
  v_preferred_currency_code       VARCHAR2(5),  
  v_consultant_id_no              VARCHAR2(9), 
  v_consultant_name               VARCHAR2(250),    
  v_effective_start_date          VARCHAR2(30),         
  v_effective_end_date            VARCHAR2(30),
  v_status                        VARCHAR2(50),
  v_statement_type                VARCHAR2(50),
  v_function                      VARCHAR2(50),
  v_payment_type                  VARCHAR2(50),
  v_type                          VARCHAR2(50),
  v_comm_perc                     VARCHAR2(3),
  v_comm_desc                     VARCHAR2(250),
  v_comm_oustanding_amt           VARCHAR2(50)
  );

 TYPE company_country_record IS RECORD (
  v_company_id_no        VARCHAR2(50),    
  v_country_code         VARCHAR2(50),  
  v_effective_start_date VARCHAR2(30),         
  v_effective_end_date   VARCHAR2(30),         
  v_hold_ind             VARCHAR2(1),  
  v_min_payout_amt       VARCHAR2(15)
  );
 
 TYPE company_country_table IS TABLE OF company_country_record;
 
 TYPE company_accreditation_record  IS RECORD (
  v_company_id_no             VARCHAR2(50),         
  v_country_code              VARCHAR2(50),  
  v_effective_start_date      VARCHAR2(30),               
  v_effective_end_date        VARCHAR2(30),               
  v_accreditation_type        VARCHAR2(100),         
  v_company_accred_no         VARCHAR2(50),         
  v_company_accred_start_date VARCHAR2(30),               
  v_company_accred_end_date   VARCHAR2(30) 
  );

 TYPE company_accreditation_table IS TABLE OF company_accreditation_record;

 TYPE company_fee_record IS RECORD (
  v_company_id_no           VARCHAR2(50),          
  v_company_fee_type_       VARCHAR2(50),          
  v_effective_start_date    VARCHAR2(30),               
  v_effective_end_date      VARCHAR2(30),               
  v_fee_amt                 VARCHAR2(50),          
  v_fee_perc                VARCHAR2(50),          
  v_fee_freq_no             VARCHAR2(50),        
  v_fee_comment_desc        VARCHAR2(200), 
  v_last_pay_date           VARCHAR2(30)
  );

 TYPE company_fee_table IS TABLE OF company_fee_record;

 TYPE company_registration_record IS RECORD (
  v_company_id_no             VARCHAR2(50),         
  v_country_code              VARCHAR2(50),  
  v_effective_start_date      VARCHAR2(30),              
  v_effective_end_date        VARCHAR2(30),              
  v_vat_no                    VARCHAR2(50),         
  v_reg_no                    VARCHAR2(50),         
  v_fais_no                   VARCHAR2(50),         
  v_expiry_date               VARCHAR2(30),              
  v_application_date          VARCHAR2(30),              
  v_authorise_date            VARCHAR2(30)     
  );
  
 TYPE company_comm_perc_record IS RECORD (
  v_company_id_no        VARCHAR2(50),
  v_comm_perc            VARCHAR2(50),
  v_comm_desc            VARCHAR2(100),
  v_effective_start_date VARCHAR2(30),         
  v_effective_end_date   VARCHAR2(30),    
  v_created_username     VARCHAR2(100)
  );
  
 TYPE brand_record IS RECORD(
  v_brand_code VARCHAR2(50),
  v_brand VARCHAR2(100)
  );
  
 TYPE product_record IS RECORD(
  v_product_code VARCHAR2(50),
  v_product VARCHAR2(100)
  ); 
  
 TYPE provider_record IS RECORD(
  v_provider_code   VARCHAR2(50),
  v_firstname       VARCHAR2(100),
  v_middle_name     VARCHAR2(100),
  v_name            VARCHAR2(100),
  v_country         VARCHAR2(150),
  v_discipline      VARCHAR2(100),
  v_preferred_currency_code VARCHAR2(50),
  v_preferred_currency VARCHAR2(100),
  v_samdc_number    VARCHAR2(50),
  v_start_date      VARCHAR2(30),
  v_end_date        VARCHAR2(30),
  v_id              VARCHAR2(30),
  v_cross_reference VARCHAR2(50),
  v_dispensing_status VARCHAR2(50),
  v_dispensing_license VARCHAR2(50),
  v_emergency_number    VARCHAR2(50)
  );
  
 TYPE auth_record IS RECORD(
   v_auth_id       VARCHAR2(50),
   v_auth_number   VARCHAR2(50)
   );

TYPE policy_lookup_record IS RECORD(
  v_policy_code VARCHAR2(50),
  v_dependant_code VARCHAR2(10),
  v_title VARCHAR2(20),
  v_surname VARCHAR2(100),
  v_firstname VARCHAR2(100),
  v_initials VARCHAR2(50),
  v_id VARCHAR2(50),
  v_gender VARCHAR2(50),
  v_date_of_birth VARCHAR2(30),
  v_deceased_date VARCHAR2(30),
  v_registered_date VARCHAR2(30),
  v_resigned_date VARCHAR2(30),
  v_benefit_date VARCHAR2(30),
  v_status VARCHAR2(50),
  v_prereg_code VARCHAR2(50),
  v_prereg_status VARCHAR2(100), 
  v_susres_status VARCHAR2(50),
  v_passport VARCHAR2(50),
  v_division VARCHAR2(100),
  v_payroll VARCHAR2(100),
  v_paypoint VARCHAR2(100),
  v_empno VARCHAR2(50),
  v_marital_status VARCHAR2(50),
  v_language VARCHAR2(50),
  v_employed_date VARCHAR2(50),
  v_product_code VARCHAR2(50),
  v_relationship VARCHAR2(100),
  v_person_code VARCHAR2(50),
  v_employer_code   VARCHAR2(50),
  v_employer_name   VARCHAR2(100),
  v_country    VARCHAR2 (10),
  v_brand     VARCHAR2 (10),
  v_origin     VARCHAR2(10),
  v_rownum     NUMBER
  );
 
TYPE t_policy_lookup_table IS TABLE OF policy_lookup_record index by binary_integer;    

TYPE employer_lookup_record IS RECORD(
  v_employer_code    	VARCHAR2(50),
  v_name          	VARCHAR2(100),
  v_parent_group  	VARCHAR2(50),
  v_start_date      	VARCHAR2(50),
  v_contract_from 	VARCHAR2(50),
  v_contract_to   	VARCHAR2(50),
  v_country    		VARCHAR2 (10),
  v_brand     		VARCHAR2 (10),
  v_origin     		VARCHAR2(10),
  v_rownum     		NUMBER
  );
 
TYPE t_employer_lookup_table IS TABLE OF employer_lookup_record index by binary_integer;    

TYPE provider_lookup_record IS RECORD(
  v_provider_code 	VARCHAR2(50),
  v_title 		VARCHAR2(100),
  v_surname 		VARCHAR2(100),
  v_firstname 		VARCHAR2(100),
  v_initials 		VARCHAR2(50),
  v_specialty   	VARCHAR2(10),
  v_specialty_desc 	VARCHAR2(100),
  v_country    		VARCHAR2 (10),
  v_brand     		VARCHAR2 (10),
  v_origin     		VARCHAR2(10),
  v_rownum    		NUMBER
  );
 
TYPE t_provider_lookup_table IS TABLE OF provider_lookup_record index by binary_integer;  

TYPE broker_lookup_record IS RECORD(
  v_broker_code 	VARCHAR2(50),
  v_title 		VARCHAR2(100),
  v_surname 		VARCHAR2(100),
  v_firstname 		VARCHAR2(100),
  v_initials 		VARCHAR2(50),
  v_company_code 	VARCHAR2(50),
  v_company_name 	VARCHAR2(50),
  v_broker_type 	VARCHAR2(30),
  v_start_date 		VARCHAR2(30),
  v_end_date 		VARCHAR2(30),
  v_company_type 	VARCHAR2(30),
  v_country    		VARCHAR2 (10),
  v_brand     		VARCHAR2 (10),
  v_origin     		VARCHAR2(10),
  v_rownum     		NUMBER
  );
 
TYPE t_broker_lookup_table IS TABLE OF broker_lookup_record index by binary_integer;  

TYPE user_lookup_record IS RECORD(
  v_user_code 	VARCHAR2(50),
  v_name 	VARCHAR2(100),
  v_country    	VARCHAR2 (10),
  v_origin     	VARCHAR2(10),
  v_rownum     	NUMBER
  );
 
TYPE t_user_lookup_table IS TABLE OF user_lookup_record index by binary_integer;  

/*
web services - JSON format
*/
PROCEDURE get_entity_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_clob OUT CLOB
  );
 
 PROCEDURE get_contacts_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_clob OUT CLOB
  );
 
PROCEDURE get_sub_entity_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_sub_entity_type IN VARCHAR2,
  p_sub_entity_code IN VARCHAR2 DEFAULT NULL,
  p_clob OUT CLOB
  );
    
 /* get data into predefined record structure */
 PROCEDURE get_membership_data_prc(
    p_policy_code IN VARCHAR2,
    p_membership_record IN OUT NOCOPY self_service_v1_pkg.membership_record
    );

PROCEDURE get_policy_data_prc(
  p_policy_code IN VARCHAR2,
  p_policy_record IN OUT NOCOPY self_service_v1_pkg.policy_record
  );
  
PROCEDURE get_employer_data_prc(
  p_employer_code IN VARCHAR2,
  p_employer_record IN OUT NOCOPY self_service_v1_pkg.employer_record
  );  

PROCEDURE get_brand_data_prc(
  p_brand_code IN VARCHAR2, 
  p_brand_record IN OUT NOCOPY self_service_v1_pkg.brand_record
  );

PROCEDURE get_product_data_prc(
  p_product_code IN VARCHAR2, 
  p_product_record IN OUT NOCOPY self_service_v1_pkg.product_record
  );

PROCEDURE get_provider_data_prc(
  p_provider_code IN VARCHAR2, 
  p_provider_record IN OUT NOCOPY self_service_v1_pkg.provider_record
  );

PROCEDURE get_broker_data_prc(
  p_broker_code IN VARCHAR2,
  p_broker_record IN OUT NOCOPY self_service_v1_pkg.broker_record
 );
 
PROCEDURE get_contacts_data_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_contacts_record IN OUT NOCOPY self_service_v1_pkg.contacts_record
  );

PROCEDURE get_dependant_data_prc(
  p_policy_code IN VARCHAR2,
  p_dependant_code IN VARCHAR2,
  p_dependant_table IN OUT NOCOPY self_service_v1_pkg.dependant_table
  );
 
 PROCEDURE get_auth_data_prc(
  p_auth_code IN VARCHAR2, 
  p_auth_record IN OUT NOCOPY self_service_v1_pkg.auth_record
  );
 
PROCEDURE entity_lookup_prc(
  p_auth_entity     IN VARCHAR2 DEFAULT NULL,
  p_auth_code       IN VARCHAR2 DEFAULT NULL,
  p_search_entity   IN VARCHAR2,
  p_page            IN NUMBER DEFAULT NULL,
  p_page_size       IN NUMBER DEFAULT NULL,
  p_search_parm1    IN VARCHAR2,
  p_search_value1   IN VARCHAR2,
  p_search_parm2    IN VARCHAR2 DEFAULT NULL,
  p_search_value2   IN VARCHAR2 DEFAULT NULL,
  p_search_parm3    IN VARCHAR2 DEFAULT NULL,
  p_search_value3   IN VARCHAR2 DEFAULT NULL,
  p_clob      OUT CLOB
  );

PROCEDURE find_by_identity_prc(
  p_auth_entity     IN VARCHAR2 DEFAULT NULL,
  p_auth_code       IN VARCHAR2 DEFAULT NULL,
  p_search_entity   IN VARCHAR2, 
  p_name      	    IN VARCHAR2 DEFAULT NULL,
  p_surname         IN VARCHAR2 DEFAULT NULL,
  p_firstname       IN VARCHAR2 DEFAULT NULL,
  p_init            IN VARCHAR2 DEFAULT NULL,
  p_empno           IN VARCHAR2 DEFAULT NULL,
  p_personal_id     IN VARCHAR2 DEFAULT NULL,
  p_dt_born         IN VARCHAR2 DEFAULT NULL,
  p_gender          IN VARCHAR2 DEFAULT NULL,
  p_country         IN VARCHAR2 DEFAULT NULL,
  p_brand           IN VARCHAR2 DEFAULT NULL,
  p_employer        IN VARCHAR2 DEFAULT NULL,
  p_specialty 	    IN VARCHAR2 DEFAULT NULL,
  p_page            IN NUMBER DEFAULT 1,
  p_page_size       IN NUMBER DEFAULT 10,
  p_clob      OUT CLOB
  );
 
 END self_service_v1_pkg;
/


CREATE OR REPLACE PACKAGE BODY self_service_v1_pkg
AS
/*
Get contacts and address details for entity requested
*/
PROCEDURE get_contacts_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_clob OUT CLOB
  )
  AS 
  v_clob CLOB := NULL;
  v_error_json_clob CLOB := NULL;
  v_reason VARCHAR2(200) := NULL;
  v_common_key VARCHAR2(16);
  
  v_contacts_record  self_service_v1_pkg.contacts_record;
  
   --LOGGER variables
  p_scope_prefix CONSTANT VARCHAR2(46) := 'SID=' || SYS_CONTEXT('USERENV','SID') || '.' || lower($$PLSQL_UNIT) || '.';
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := p_scope_prefix || 'get_contacts_prc';
 BEGIN
 -- clear out any logging per potential parameter received to      
   l_params := LOGGER.GC_EMPTY_TAB_PARAM;
   LOGGER.APPEND_PARAM(l_params, 'entity_type, entity_code', p_entity_type || ',' || p_entity_code);      

  v_contacts_record := NULL;
  self_service_v1_pkg.get_contacts_data_prc(p_entity_type => p_entity_type,
      p_entity_code => p_entity_code,
      p_contacts_record => v_contacts_record);
 
   self_service_format_pkg.contacts_json_prc(p_contacts_record => v_contacts_record,
     p_contacts_json_clob => v_clob);
     
  p_clob := v_clob;
  
  ROLLBACK;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  v_reason := 'Entity Contacts do not exist: ' || p_entity_type || ', ' || p_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  ROLLBACK;
  
  WHEN OTHERS THEN
  v_reason := 'Error in contacts: ' || p_entity_type || ', ' || p_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  logger.log_error('SSERV Error', l_scope, null, l_params);
  ROLLBACK;
 END get_contacts_prc; 

/*
Get data for entity requested
*/
PROCEDURE get_entity_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_clob OUT CLOB
  )
  AS
  v_error_json_clob CLOB := NULL;
  v_reason VARCHAR2(200) := NULL;
  v_clob CLOB := NULL;
  
  v_policy_record self_service_v1_pkg.policy_record;
  v_membership_record self_service_v1_pkg.membership_record;
  v_employer_record self_service_v1_pkg.employer_record;
  v_brand_record self_service_v1_pkg.brand_record;
  v_product_record self_service_v1_pkg.product_record;
  v_provider_record self_service_v1_pkg.provider_record;
  v_broker_record self_service_v1_pkg.broker_record;
  v_dependant_table self_service_v1_pkg.dependant_table;
  v_auth_record self_service_v1_pkg.auth_record;
  
  --LOGGER variables
  p_scope_prefix CONSTANT VARCHAR2(46) := 'SID=' || SYS_CONTEXT('USERENV','SID') || '.' || lower($$PLSQL_UNIT) || '.';
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := p_scope_prefix || 'get_entity_prc';
  BEGIN
  
  -- clear out any logging per potential parameter received to      
   l_params := LOGGER.GC_EMPTY_TAB_PARAM;
   LOGGER.APPEND_PARAM(l_params, 'entity_type, entity_code', p_entity_type || ',' || p_entity_code);      
 
 -- get data from ohi or medware or commissions etc.
 -- if not exist or error then go to exception to create error in JSON format
 -- format entity data in JSON 
 -- return entity data
 /*
  IF p_entity_type = 'POLICY' THEN
    v_policy_record := NULL;
    self_service_v1_pkg.get_policy_data_prc(p_policy_code => p_entity_code,
        p_policy_record => v_policy_record);  
    self_service_format_pkg.policy_json_prc(p_policy_record => v_policy_record,
        p_policy_json_clob => v_clob);
*/
  IF p_entity_type = 'POLICY' 
  OR p_entity_type = 'MEMBER' THEN
   v_membership_record := NULL;
   self_service_v1_pkg.get_membership_data_prc(p_policy_code => p_entity_code,
        p_membership_record => v_membership_record); 
   self_service_format_pkg.membership_json_prc(p_membership_record => v_membership_record,
        p_membership_json_clob => v_clob);
   ELSIF p_entity_type = 'EMPLOYER' THEN 
   v_employer_record := NULL;
   self_service_v1_pkg.get_employer_data_prc(p_employer_code => p_entity_code,
        p_employer_record => v_employer_record); 
   self_service_format_pkg.employer_json_prc(p_employer_record => v_employer_record,
        p_employer_json_clob => v_clob);
  ELSIF p_entity_type = 'BROKER' THEN 
   v_broker_record := NULL;
   self_service_v1_pkg.get_broker_data_prc(p_broker_code => p_entity_code,
        p_broker_record => v_broker_record); 
   self_service_format_pkg.broker_json_prc(p_broker_record => v_broker_record,
        p_broker_json_clob => v_clob);
  ELSIF p_entity_type = 'BRAND' THEN 
   v_brand_record := NULL;
   self_service_v1_pkg.get_brand_data_prc(p_brand_code => p_entity_code,
        p_brand_record => v_brand_record); 
   self_service_format_pkg.brand_json_prc(p_brand_record => v_brand_record,
        p_brand_json_clob => v_clob);
  ELSIF p_entity_type = 'PRODUCT' THEN 
   v_product_record := NULL;
   self_service_v1_pkg.get_product_data_prc(p_product_code => p_entity_code,
        p_product_record => v_product_record); 
   self_service_format_pkg.product_json_prc(p_product_record => v_product_record,
        p_product_json_clob => v_clob);
 ELSIF p_entity_type = 'SERVICE_PROVIDER' THEN 
   v_provider_record := NULL;
   self_service_v1_pkg.get_provider_data_prc(p_provider_code => p_entity_code,
        p_provider_record => v_provider_record); 
   self_service_format_pkg.provider_json_prc(p_provider_record => v_provider_record,
        p_provider_json_clob => v_clob);
  ELSIF p_entity_type = 'AUTHORIZATION' THEN
   v_auth_record := NULL;
   self_service_v1_pkg.get_auth_data_prc(p_auth_code => p_entity_code,
        p_auth_record => v_auth_record);
   self_service_format_pkg.auth_json_prc(p_auth_record => v_auth_record,
        p_auth_json_clob => v_clob);
  ELSE RAISE NO_DATA_FOUND;
  END IF; 
  
  p_clob := v_clob;
  
  ROLLBACK;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_reason := 'Entity does not exist: ' || p_entity_type || ', ' || p_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  ROLLBACK;
  WHEN OTHERS THEN
   v_reason := 'Error in: ' || p_entity_type || ', ' || p_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  logger.log_error('SSERV Error', l_scope, null, l_params);
  ROLLBACK;
 END get_entity_prc;
 
 
 
 
 PROCEDURE get_sub_entity_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_sub_entity_type IN VARCHAR2,
  p_sub_entity_code IN VARCHAR2,
  p_clob OUT CLOB
  )
  AS
  v_error_json_clob CLOB := NULL;
  v_reason VARCHAR2(200) := NULL;
  v_clob CLOB := NULL;
  
  v_dependant_table self_service_v1_pkg.dependant_table;
   --LOGGER variables
  p_scope_prefix CONSTANT VARCHAR2(46) := 'SID=' || SYS_CONTEXT('USERENV','SID') || '.' || lower($$PLSQL_UNIT) || '.';
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := p_scope_prefix || 'get_sub_entity_prc';
  BEGIN
  -- clear out any logging per potential parameter received to      
   l_params := LOGGER.GC_EMPTY_TAB_PARAM;
   LOGGER.APPEND_PARAM(l_params, 'entity_type, entity_code, sub_entity_type, sub_entity_code', 
                       p_entity_type || ',' || p_entity_code || ',' || p_sub_entity_type || ',' || p_sub_entity_code);      

-- get data from ohi or medware or commissions etc.
 -- if not exist or error then go to exception to create error in JSON format
 -- format entity data in JSON 
 -- return list of sub entity data
  IF p_sub_entity_type = 'DEPENDANT' THEN 
   v_dependant_table := NULL;
   self_service_v1_pkg.get_dependant_data_prc(p_policy_code => p_entity_code, 
       p_dependant_code => p_sub_entity_code, 
       p_dependant_table => v_dependant_table);
   self_service_format_pkg.dependant_json_prc(p_dependant_record => v_dependant_table,
       p_dependant_json_clob => v_clob);
  ELSE RAISE NO_DATA_FOUND;
  END IF; 
  
  p_clob := v_clob;
  
  ROLLBACK;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_reason := 'Entity does not exist: POLICY ' || p_entity_code || ', ' || p_entity_type || ' ' || p_sub_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  ROLLBACK;
  WHEN OTHERS THEN
   v_reason := 'Error in: POLICY ' || p_entity_code || ', ' || p_entity_type || ' ' || p_sub_entity_code;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  logger.log_error('SSERV Error', l_scope, null, l_params);
  ROLLBACK;
 END get_sub_entity_prc;
 
 
/* get data into predefined record structure */
/*
Policy or Member with related info about main member as at today
Selected on policy/member code parameter entered
If OHI policy exists then OHI data is reported
If no OHI policy exists then Medware data is reported
The status of the policy/member is not checked
*/
 PROCEDURE get_membership_data_prc(
    p_policy_code IN VARCHAR2,
    p_membership_record IN OUT NOCOPY self_service_v1_pkg.membership_record
    )
    AS
BEGIN

  IF service_policy_pkg.is_policy_code_fnc(p_policy_code => p_policy_code) THEN
  service_policy_pkg.get_membership_prc(p_policy_code => p_policy_code,
    p_membership_record => p_membership_record);
	ELSIF service_medware_pkg.is_member_m_member_fnc(p_m_member => p_policy_code) THEN
   service_medware_pkg.get_membership_prc(p_m_member => p_policy_code,
    p_membership_record => p_membership_record);
	ELSE
   RAISE NO_DATA_FOUND;
  END IF; 
  ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;  
 
 END get_membership_data_prc;
 
/*
Policy or Member with related info as at today
Selected on policy/member code parameter entered
If OHI policy exists then OHI data is reported
If no OHI policy exists then Medware data is reported
The status of the policy/member is not checked
*/
PROCEDURE get_policy_data_prc(
  p_policy_code IN VARCHAR2,
  p_policy_record IN OUT NOCOPY self_service_v1_pkg.policy_record
  )
  AS 
 
 BEGIN
  IF service_policy_pkg.is_policy_code_fnc(p_policy_code => p_policy_code) THEN
  service_policy_pkg.get_policy_prc(p_policy_code => p_policy_code,
    p_policy_record => p_policy_record);
  ELSIF service_medware_pkg.is_member_m_member_fnc(p_m_member => p_policy_code) THEN
  service_medware_pkg.get_member_prc(p_m_member => p_policy_code,
    p_policy_record => p_policy_record);
 ELSE
  RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
 END get_policy_data_prc; 

 /*
Employer or groups with related info as at today
Selected on employer/group code parameter entered
If OHI employer exists then OHI data is reported
If no OHI employer exists then Medware data is reported
The status of the employer/group is not checked
*/   
PROCEDURE get_employer_data_prc(
  p_employer_code IN VARCHAR2,
  p_employer_record IN OUT NOCOPY self_service_v1_pkg.employer_record
  )
  AS
 BEGIN
  IF service_policy_pkg.is_employer_code_fnc(p_employer_code => p_employer_code) THEN
  service_policy_pkg.get_employer_prc(p_employer_code => p_employer_code,
    p_employer_record => p_employer_record);
  ELSIF service_medware_pkg.is_groups_g_group_fnc(p_g_group => p_employer_code) THEN
  service_medware_pkg.get_groups_prc(p_g_group => p_employer_code,
    p_employer_record => p_employer_record);
 ELSE
  RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
 END get_employer_data_prc; 

/*
Scheme or Brand with related info as at today
Selected on scheme/brand code parameter entered
If the brand exists on OHI Policies then the OHI data is read
If the scheme does not exist on OHI Policies then the Medware data is read
*/   
PROCEDURE get_brand_data_prc(
  p_brand_code IN VARCHAR2, 
  p_brand_record IN OUT NOCOPY self_service_v1_pkg.brand_record
  )
  AS
 BEGIN
   IF service_policy_pkg.is_brand_code_fnc(p_brand_code => p_brand_code) THEN
  service_policy_pkg.get_brand_prc(p_brand_code => p_brand_code,
    p_brand_record => p_brand_record);
   ELSIF service_medware_pkg.is_scheme_s_scheme_fnc(p_s_scheme => p_brand_code) THEN
  service_medware_pkg.get_scheme_prc(p_s_scheme => p_brand_code,
    p_brand_record => p_brand_record);
 ELSE
  RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
   
 END get_brand_data_prc; 

/* 
Option or Product with related info as at today
Selected on option/product code parameter entered
If the product exists on OHI Policies then the OHI data is read
If the option does not exist on OHI Policies then the Medware data is read
*/  
PROCEDURE get_product_data_prc(
  p_product_code IN VARCHAR2, 
  p_product_record IN OUT NOCOPY self_service_v1_pkg.product_record
  )
  AS
 BEGIN
  IF service_policy_pkg.is_product_code_fnc(p_product_code => p_product_code) THEN
  service_policy_pkg.get_product_prc(p_product_code => p_product_code,
    p_product_record => p_product_record);
  ELSIF service_medware_pkg.is_scheme_s_scheme_fnc(p_s_scheme => p_product_code) THEN
  service_medware_pkg.get_option_prc(p_o_option => p_product_code,
    p_product_record => p_product_record);
 ELSE
  RAISE NO_DATA_FOUND;
  END IF;
  
  ROLLBACK;
  
EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
 END get_product_data_prc;  
  
/* 
Service Provider with related info as at today
Selected on service-provider code parameter entered
OHI data is read
*/  
PROCEDURE get_provider_data_prc(
  p_provider_code IN VARCHAR2, 
  p_provider_record IN OUT NOCOPY self_service_v1_pkg.provider_record
  )
  AS
 BEGIN 
  IF service_claims_pkg.is_provider_code_fnc(p_provider_code => p_provider_code) THEN
  service_claims_pkg.get_service_provider_prc(p_provider_code => p_provider_code,
    p_provider_record => p_provider_record);
  ELSIF service_medware_pkg.is_provider_p_provider_fnc(p_p_provider => p_provider_code) THEN
  service_medware_pkg.get_provider_prc(p_p_provider => p_provider_code,
    p_provider_record => p_provider_record);
   ELSE
   RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
  
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
END get_provider_data_prc;  

/*
Broker or Agent with related info as at today
Selected on broker/agent/company code parameter entered
The Commissions data is read
The status of the broker/agent/company is not checked
*/   
PROCEDURE get_broker_data_prc(
  p_broker_code IN VARCHAR2,
  p_broker_record IN OUT NOCOPY self_service_v1_pkg.broker_record
 )
  AS
  v_company_id_no company.company_id_no@lhhcomm.liberty.co.za%TYPE;   
  v_broker_id_no  broker.broker_id_no@lhhcomm.liberty.co.za%TYPE;
  v_entity_id_no  company.company_id_no@lhhcomm.liberty.co.za%TYPE;
 BEGIN

  v_company_id_no := NULL;
  v_broker_id_no := NULL;
  v_entity_id_no := NULL;
 
 /* changed to only be broker id that can be used */ 
--  IF service_comm_pkg.is_company_code_fnc(p_company_code => p_broker_code) 
  IF service_comm_pkg.is_broker_code_fnc(p_broker_code => p_broker_code)
  THEN
   v_entity_id_no := p_broker_code;
  ELSE 
 --  v_company_id_no := service_comm_pkg.get_company_id_fnc(p_company_code => p_broker_code);
   v_broker_id_no := service_comm_pkg.get_broker_id_fnc(p_broker_code => p_broker_code);
 --  IF v_company_id_no IS NOT NULL THEN
 --   v_entity_id_no := v_company_id_no;
   IF v_broker_id_no IS NOT NULL THEN
    v_entity_id_no := v_broker_id_no;
   ELSE
    RAISE NO_DATA_FOUND;
   END IF;
 END IF;
 
  IF v_entity_id_no IS NOT NULL THEN
  service_comm_pkg.get_broker_prc(p_entity_id_no => v_entity_id_no,
       p_broker_record => p_broker_record);
   IF p_broker_record.v_broker_id_no IS NULL THEN
   RAISE NO_DATA_FOUND;
   END IF;
  ELSE
   RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
  
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
 END get_broker_data_prc; 
   
 /*
Address of entity with related detail as at today
Selected on entity type and entity code parameters entered
If the entity exists on OHI then OHI data is reported for POLICY, EMPLOYER
If no OHI entity exists then Medware data is reported for POLICY, EMPLOYER
The broker detail is taken from the commissions system
The service provider details is taken from OHI
*/
PROCEDURE get_contacts_data_prc(
  p_entity_type IN VARCHAR2,
  p_entity_code IN VARCHAR2,
  p_contacts_record IN OUT NOCOPY self_service_v1_pkg.contacts_record
  )
  AS 
  v_common_key VARCHAR2(16);
  v_company_id_no company.company_id_no@lhhcomm.liberty.co.za%TYPE;   
  v_broker_id_no broker.broker_id_no@lhhcomm.liberty.co.za%TYPE;   
 BEGIN

  IF p_entity_type = 'POLICY' THEN
   IF service_policy_pkg.is_policy_code_fnc(p_policy_code => p_entity_code) THEN
   service_policy_pkg.get_policy_contacts_prc(p_policy_code => p_entity_code,
     p_contacts_record => p_contacts_record);
   ELSIF service_medware_pkg.is_member_m_member_fnc(p_m_member => p_entity_code) THEN
   v_common_key := 'ME' || p_entity_code;
   service_medware_pkg.get_medware_contacts_prc(p_entity => v_common_key,
    p_contacts_record => p_contacts_record);
  ELSE
   RAISE NO_DATA_FOUND;
   END IF;
  ELSIF p_entity_type = 'EMPLOYER' THEN
  IF service_policy_pkg.is_employer_code_fnc(p_employer_code => p_entity_code) THEN
   service_policy_pkg.get_employer_contacts_prc(p_employer_code => p_entity_code,
     p_contacts_record => p_contacts_record);
   ELSIF service_medware_pkg.is_groups_g_group_fnc(p_g_group => p_entity_code) THEN
   v_common_key := 'GR' || p_entity_code;
   service_medware_pkg.get_medware_contacts_prc(p_entity => v_common_key,
    p_contacts_record => p_contacts_record);
  ELSE
   RAISE NO_DATA_FOUND;
  END IF;
  ELSIF p_entity_type = 'BROKER' THEN
   v_company_id_no := NULL;
   v_broker_id_no := NULL;
   p_contacts_record.v_entity_code := NULL;
   IF service_comm_pkg.is_company_code_fnc(p_company_code => p_entity_code) THEN
    v_company_id_no := p_entity_code;
   ELSE  
    v_company_id_no := service_comm_pkg.get_company_id_fnc(p_company_code => p_entity_code);
   END IF;
   IF v_company_id_no IS NOT NULL THEN
    service_comm_pkg.get_company_contacts_prc(p_company => v_company_id_no,
     p_contacts_record => p_contacts_record);
   ELSE
    IF service_comm_pkg.is_broker_code_fnc(p_broker_code => p_entity_code) THEN
     v_broker_id_no := p_entity_code;
    ELSE
     v_broker_id_no := service_comm_pkg.get_broker_id_fnc(p_broker_code => p_entity_code);
    END IF;
    IF v_broker_id_no IS NOT NULL THEN
    service_comm_pkg.get_broker_contacts_prc(p_broker => v_broker_id_no,
     p_contacts_record => p_contacts_record);
    END IF;
   END IF;
   IF p_contacts_record.v_entity_code IS NULL THEN  
    RAISE NO_DATA_FOUND;
   END IF;
   ELSIF p_entity_type = 'SERVICE_PROVIDER' THEN
   IF service_claims_pkg.is_provider_code_fnc(p_provider_code => p_entity_code) THEN
    service_claims_pkg.get_provider_contacts_prc(p_provider_code => p_entity_code,
     p_contacts_record => p_contacts_record);
   END IF;
  ELSE
  RAISE NO_DATA_FOUND;
 END IF;
 
 p_contacts_record.v_entity_type := p_entity_type;
 p_contacts_record.v_entity_code := p_entity_code;
 
 ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
 END get_contacts_data_prc;  
 
  /*
Dependant or beneficiary data as at today
Selected on policy/member code and optional dependant parameter entered
If OHI policy exists then OHI data is reported
If no OHI policy exists then Medware data is reported
The status of the dependant/beneficiary is not checked
*/
PROCEDURE get_dependant_data_prc(
  p_policy_code IN VARCHAR2,
  p_dependant_code IN VARCHAR2,
  p_dependant_table IN OUT NOCOPY self_service_v1_pkg.dependant_table
  )
  AS 
  
 BEGIN
  IF service_policy_pkg.is_policy_code_fnc(p_policy_code => p_policy_code) THEN
   service_policy_pkg.get_dependant_prc(p_policy_code => p_policy_code, 
    p_dependant_code => p_dependant_code,
    p_dependant_record => p_dependant_table);
  ELSIF service_medware_pkg.is_member_m_member_fnc(p_m_member => p_policy_code) THEN
   service_medware_pkg.get_benef_prc(p_m_member => p_policy_code,
    p_b_depend => p_dependant_code,   
    p_dependant_record => p_dependant_table);
 ELSE
  RAISE NO_DATA_FOUND;
  END IF;
  IF p_dependant_table.FIRST IS NULL THEN  
   RAISE NO_DATA_FOUND;
  END IF;

 ROLLBACK;
 
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
 END get_dependant_data_prc; 

/* 
Authorizations with related info as at today
Selected on authorization id parameter entered
OHI data is read
*/  
PROCEDURE get_auth_data_prc(
  p_auth_code IN VARCHAR2, 
  p_auth_record IN OUT NOCOPY self_service_v1_pkg.auth_record
  )
  AS
 BEGIN 
  IF service_auth_pkg.is_auth_code_fnc(p_auth_code => p_auth_code) THEN
  service_auth_pkg.get_auth_prc(p_auth_code => p_auth_code,
    p_auth_record => p_auth_record);
  ELSE
   RAISE NO_DATA_FOUND;
  END IF;
  
 ROLLBACK;
  
 EXCEPTION
 WHEN OTHERS THEN
  ROLLBACK;
  RAISE;
  
END get_auth_data_prc;  

/* 
Entity lookup from both Medware and OHI
*/   
PROCEDURE entity_lookup_prc(
  p_auth_entity     IN VARCHAR2,
	p_auth_code       IN VARCHAR2,
	p_search_entity   IN VARCHAR2,
	p_page            IN NUMBER,
  p_page_size       IN NUMBER,
  p_search_parm1    IN VARCHAR2,
  p_search_value1   IN VARCHAR2,
  p_search_parm2    IN VARCHAR2,
  p_search_value2   IN VARCHAR2,
  p_search_parm3    IN VARCHAR2,
  p_search_value3   IN VARCHAR2,
  p_clob      OUT CLOB
  )
  AS
  v_error_json_clob CLOB          := NULL;
  v_reason          VARCHAR2(200) := NULL;
  v_clob            CLOB           ;
  v_name            VARCHAR2(60) := NULL;
  v_surname         VARCHAR2(60) := NULL;
  v_firstname       VARCHAR2(60) := NULL;
  v_init            VARCHAR2(20) := NULL;
  v_empno           VARCHAR2(20) := NULL;
  v_personal_id     VARCHAR2(20) := NULL;
  v_dt_born        VARCHAR2(20)  := NULL;
  v_gender          VARCHAR2(10)  := NULL;
  v_country         VARCHAR2(10) := NULL;
  v_brand           VARCHAR2(20) := NULL;
  v_employer        VARCHAR2(60) := NULL;
  v_level           VARCHAR2(20) := NULL;  
  v_specialty       VARCHAR2(10) := NULL;  
  v_date_format  VARCHAR2(30) := 'YYYY-MM-DD';
  v_total_entries   NUMBER := 0;
  v_policy_lookup_table  t_policy_lookup_table;   
  v_employer_lookup_table  t_employer_lookup_table;   
  v_provider_lookup_table  t_provider_lookup_table;   
  v_broker_lookup_table  t_broker_lookup_table;   
  v_user_lookup_table  t_user_lookup_table;   
  
   --LOGGER variables
  p_scope_prefix CONSTANT VARCHAR2(46) := 'SID=' || SYS_CONTEXT('USERENV','SID') || '.' || lower($$PLSQL_UNIT) || '.';
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := p_scope_prefix || 'entity_lookup_prc';
  
  BEGIN
      -- clear out any logging per potential parameter received to      
   l_params := LOGGER.GC_EMPTY_TAB_PARAM;
   LOGGER.APPEND_PARAM(l_params, 'authenticatedEntity, authenticatedCode, entityType, page, pageSize, searchParm1, searchValue, searchParm2, searchValue2, searchParm3, searchValue3', 
                       p_auth_entity || ',' || p_auth_code || ',' || p_search_entity || ',' || p_page || ',' || p_page_size || ',' || p_search_parm1 || ',' || 
                       p_search_value1 || ',' || p_search_parm2 || ',' || p_search_value2 || ',' || p_search_parm3 || ',' || p_search_value3);      

 
  IF p_search_entity = 'POLICY' OR p_search_entity = 'PERSON'
       THEN 
           IF p_search_parm1 = 'name'
              THEN v_name      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'surname'
              THEN v_surname   := upper(p_search_value1);
           END IF;
           IF p_search_parm1 = 'firstname' 
              THEN v_firstname := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'init'      
              THEN v_init      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'empno'     
              THEN v_empno     := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'birthDate' 
              THEN v_dt_born   := (p_search_value1);
           END IF;                
           IF p_search_parm1 = 'country'   
              THEN v_country   := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'brand'     
              THEN v_brand     := upper(p_search_value1);
           END IF;     
           IF p_search_parm1 = 'employer'  
              THEN v_employer  := upper(p_search_value1);
           END IF;     
            
           IF p_search_parm2 = 'name'
              THEN v_name      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'surname'
              THEN v_surname   := upper(p_search_value2);
           END IF;                 
           IF p_search_parm2 = 'firstname' 
              THEN v_firstname := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'init'      
              THEN v_init      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'empno'     
              THEN v_empno     := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'birthDate' 
              THEN v_dt_born   := (p_search_value2);
           END IF;                
           IF p_search_parm2 = 'country'   
              THEN v_country   := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'brand'     
              THEN v_brand     := upper(p_search_value2);
           END IF;     
           IF p_search_parm2 = 'employer'  
              THEN v_employer  := upper(p_search_value2);
           END IF;     
           IF p_search_parm3 = 'name'
              THEN v_name      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'surname'
              THEN v_surname   := upper(p_search_value3);
           END IF;
           IF p_search_parm3 = 'firstname' 
              THEN v_firstname := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'init'      
              THEN v_init      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'empno'     
              THEN v_empno     := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'birthDate' 
              THEN v_dt_born    := (p_search_value3);
           END IF;                
           IF p_search_parm3 = 'country'   
              THEN v_country   := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'brand'     
              THEN v_brand     := upper(p_search_value3);
           END IF;     
           IF p_search_parm3 = 'employer'  
              THEN v_employer  := upper(p_search_value3);
           END IF;     
           v_level := p_search_entity;
            service_policy_pkg.get_policy_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => v_name,
            p_surname => v_surname,
            p_firstname => v_firstname,
            p_init => v_init,
            p_empno => v_empno,
            p_personal_id => v_personal_id,
            p_dt_born => v_dt_born,
            p_gender => v_gender,
            p_country => v_country,
            p_brand => v_brand,
            p_employer => v_employer,
            p_level => v_level,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_policy_lookup_table => v_policy_lookup_table);
          self_service_format_pkg.policy_lookup_json_prc(
            p_lookup_table => v_policy_lookup_table,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_lookup_json_clob => v_clob);   
         END IF;
 
 --Employer lookup
  IF p_search_entity = 'EMPLOYER'
       THEN 
           IF p_search_parm1 = 'name'
              THEN v_name      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'country'   
              THEN v_country   := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'brand'     
              THEN v_brand     := upper(p_search_value1);
           END IF;     
            
           IF p_search_parm2 = 'name'
              THEN v_name      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'country'   
              THEN v_country   := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'brand'     
              THEN v_brand     := upper(p_search_value2);
           END IF;     
           IF p_search_parm3 = 'name'
              THEN v_name      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'country'   
              THEN v_country   := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'brand'     
              THEN v_brand     := upper(p_search_value3);
           END IF;     
 
            service_policy_pkg.get_employer_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => v_name,
            p_country => v_country,
            p_brand => v_brand,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_employer_lookup_table => v_employer_lookup_table);
          self_service_format_pkg.employer_lookup_json_prc(
            p_lookup_table => v_employer_lookup_table,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_lookup_json_clob => v_clob);   
         END IF;
  
    IF p_search_entity = 'SERVICEPROVIDER'
       THEN 
           IF p_search_parm1 = 'name'
              THEN v_name      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'surname'
              THEN v_surname   := UPPER(p_search_value1);
           END IF;
           IF p_search_parm1 = 'firstname' 
              THEN v_firstname := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'init'      
              THEN v_init      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'country'   
              THEN v_country   := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'brand'     
              THEN v_brand     := upper(p_search_value1);
           END IF;     
           IF p_search_parm1 = 'specialty'  
              THEN v_specialty  := upper(p_search_value1);
           END IF;     
            
           IF p_search_parm2 = 'name'
              THEN v_name      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'surname'
              THEN v_surname   := upper(p_search_value2);
           END IF;                 
           IF p_search_parm2 = 'firstname' 
              THEN v_firstname := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'init'      
              THEN v_init      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'country'   
              THEN v_country   := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'brand'     
              THEN v_brand     := upper(p_search_value2);
           END IF;     
           IF p_search_parm2 = 'specialty'  
              THEN v_specialty  := upper(p_search_value2);
           END IF;     
           IF p_search_parm3 = 'name'
              THEN v_name      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'surname'
              THEN v_surname   := upper(p_search_value3);
           END IF;
           IF p_search_parm3 = 'firstname' 
              THEN v_firstname := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'init'      
              THEN v_init      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'country'   
              THEN v_country   := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'brand'     
              THEN v_brand     := upper(p_search_value3);
           END IF;     
           IF p_search_parm3 = 'specialty'  
              THEN v_specialty  := upper(p_search_value3);
           END IF;    
           dbms_output.put_line('CALLING ' || v_surname);
         
            service_claims_pkg.get_provider_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => v_name,
            p_surname => v_surname,
            p_firstname => v_firstname,
            p_init => v_init,
            p_country => v_country,
            p_brand => v_brand,
            p_specialty => v_specialty,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_provider_lookup_table => v_provider_lookup_table);
          self_service_format_pkg.provider_lookup_json_prc(
            p_lookup_table => v_provider_lookup_table,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_lookup_json_clob => v_clob);   
         END IF;
  
    IF p_search_entity = 'BROKER'
       THEN 
           IF p_search_parm1 = 'name'
              THEN v_name      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'surname'
              THEN v_surname   := upper(p_search_value1);
           END IF;
           IF p_search_parm1 = 'firstname' 
              THEN v_firstname := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'init'      
              THEN v_init      := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'country'   
              THEN v_country   := upper(p_search_value1);
           END IF;   
           IF p_search_parm1 = 'brand'     
              THEN v_brand     := upper(p_search_value1);
           END IF;     
            
           IF p_search_parm2 = 'name'
              THEN v_name      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'surname'
              THEN v_surname   := upper(p_search_value2);
           END IF;                 
           IF p_search_parm2 = 'firstname' 
              THEN v_firstname := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'init'      
              THEN v_init      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'country'   
              THEN v_country   := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'brand'     
              THEN v_brand     := upper(p_search_value2);
           END IF;     
            
            IF p_search_parm3 = 'name'
              THEN v_name      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'surname'
              THEN v_surname   := upper(p_search_value3);
           END IF;
           IF p_search_parm3 = 'firstname' 
              THEN v_firstname := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'init'      
              THEN v_init      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'country'   
              THEN v_country   := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'brand'     
              THEN v_brand     := upper(p_search_value3);
           END IF;     
            
            service_comm_pkg.get_broker_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => v_name,
            p_surname => v_surname,
            p_firstname => v_firstname,
            p_init => v_init,
            p_country => v_country,
            p_brand => v_brand,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_broker_lookup_table => v_broker_lookup_table);
          self_service_format_pkg.broker_lookup_json_prc(
            p_lookup_table => v_broker_lookup_table,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_lookup_json_clob => v_clob);   
         END IF;
  
    IF p_search_entity = 'USER'  
       THEN 
           IF p_search_parm1 = 'name'
              THEN v_name      := upper(p_search_value1);
           END IF;   
        IF p_search_parm1 = 'country'   
              THEN v_country   := upper(p_search_value1);
           END IF;   
           IF p_search_parm2 = 'name'
              THEN v_name      := upper(p_search_value2);
           END IF;   
           IF p_search_parm2 = 'country'   
              THEN v_country   := upper(p_search_value2);
           END IF;   
           IF p_search_parm3 = 'name'
              THEN v_name      := upper(p_search_value3);
           END IF;   
           IF p_search_parm3 = 'country'   
              THEN v_country   := upper(p_search_value3);
           END IF;   
           v_level := p_search_entity;
            service_general_pkg.get_user_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => v_name,
            p_country => v_country,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_user_lookup_table => v_user_lookup_table);
          self_service_format_pkg.user_lookup_json_prc(
            p_lookup_table => v_user_lookup_table,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_lookup_json_clob => v_clob);   
         END IF;
  
     
  p_clob := v_clob;     
 
 
  ROLLBACK;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_reason := 'No entries found: Entity: ' || p_search_entity || 'Search Value: ' || p_search_parm1 || ': ' || p_search_value1;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  ROLLBACK;
  WHEN OTHERS THEN
   v_reason := 'Error in:  Entity: ' || p_search_entity || ' Search Value: ' || p_search_parm1 || ': ' || p_search_value1;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  logger.log_error('SSERV Error', l_scope, null, l_params);
  ROLLBACK;     
       
       
  END entity_lookup_prc;
 
/* 
Entity lookup from both Medware and OHI
*/   
PROCEDURE find_by_identity_prc(
 p_auth_entity     IN VARCHAR2,
  p_auth_code       IN VARCHAR2,
  p_search_entity   IN VARCHAR2, 
  p_name      	    IN VARCHAR2,
  p_surname         IN VARCHAR2,
  p_firstname       IN VARCHAR2,
  p_init            IN VARCHAR2,
  p_empno           IN VARCHAR2,
  p_personal_id     IN VARCHAR2,
  p_dt_born         IN VARCHAR2,
  p_gender          IN VARCHAR2,
  p_country         IN VARCHAR2,
  p_brand           IN VARCHAR2,
  p_employer        IN VARCHAR2,
  p_specialty 	    IN VARCHAR2,
  p_page            IN NUMBER,
  p_page_size       IN NUMBER,
  p_clob      OUT CLOB
  )
  AS
  v_error_json_clob CLOB          := NULL;
  v_reason          VARCHAR2(200) := NULL;
  v_clob            CLOB           ;
  v_level           VARCHAR2(20) := NULL;  
  v_date_format  VARCHAR2(30) := 'YYYY-MM-DD';
  v_total_entries   NUMBER := 0;
  v_policy_lookup_table  t_policy_lookup_table;   
  v_employer_lookup_table  t_employer_lookup_table;   
  v_provider_lookup_table  t_provider_lookup_table;   
  v_broker_lookup_table  t_broker_lookup_table;   
  v_user_lookup_table  t_user_lookup_table;   
  
   --LOGGER variables
  p_scope_prefix CONSTANT VARCHAR2(46) := 'SID=' || SYS_CONTEXT('USERENV','SID') || '.' || lower($$PLSQL_UNIT) || '.';
  l_params logger.tab_param;
  l_scope logger_logs.scope%type := p_scope_prefix || 'entity_lookup_prc';
  
  BEGIN
  dbms_output.put_line('v_page' || p_page);

      -- clear out any logging per potential parameter received to      
   l_params := LOGGER.GC_EMPTY_TAB_PARAM;
   LOGGER.APPEND_PARAM(l_params, 'authenticatedEntity, authenticatedCode, entityType, name, surname, firstname, init, employeeNumber, personalId, dateBorn, gender, country, brand, employer, specialty, page, pageSize', p_auth_entity || ',' || p_auth_code || ',' || p_search_entity || ',' || p_name || ',' || p_surname || ',' || p_firstname || ',' || p_init || ',' || p_empno || ',' || p_personal_id || ',' || p_dt_born || ',' || p_gender || ',' || p_country || ',' || p_employer || ',' || p_specialty || ',' || p_page || ',' || p_page_size);      

 
  IF p_search_entity = 'POLICY' OR p_search_entity = 'PERSON'
       THEN 
            v_level := p_search_entity;
            service_policy_pkg.get_policy_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => p_name,
            p_surname => p_surname,
            p_firstname => p_firstname,
            p_init => p_init,
            p_empno => p_empno,
            p_personal_id => p_personal_id,
            p_dt_born => p_dt_born,
            p_gender => p_gender,
            p_country => p_country,
            p_brand => p_brand,
            p_employer => p_employer,
            p_level => v_level,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_policy_lookup_table => v_policy_lookup_table);
  	  if v_total_entries > 0
	    then self_service_format_pkg.policy_lookup_json_prc(
	            p_lookup_table => v_policy_lookup_table,
        	    p_page => p_page, 
	            p_page_size => p_page_size,
       		    p_total_entries => v_total_entries,
       	     	    p_lookup_json_clob => v_clob);  
            ELSE RAISE NO_DATA_FOUND;
	  END IF;	
         END IF;
 
 --Employer lookup
  IF p_search_entity = 'EMPLOYER'
       THEN 
            service_policy_pkg.get_employer_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => p_name,
            p_country => p_country,
            p_brand => p_brand,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_employer_lookup_table => v_employer_lookup_table);
            IF v_total_entries > 0		
          	THEN self_service_format_pkg.employer_lookup_json_prc(
            		p_lookup_table => v_employer_lookup_table,
            		p_page => p_page, 
            		p_page_size => p_page_size,
            		p_total_entries => v_total_entries,
            		p_lookup_json_clob => v_clob); 
	    ELSE RAISE NO_DATA_FOUND;
	  END IF; 
         END IF;
  
    IF p_search_entity = 'SERVICEPROVIDER'
       THEN 
          
            service_claims_pkg.get_provider_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => p_name,
            p_surname => p_surname,
            p_firstname => p_firstname,
            p_init => p_init,
            p_country => p_country,
            p_brand => p_brand,
            p_specialty => p_specialty,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_provider_lookup_table => v_provider_lookup_table);
	    IF v_total_entries > 0		
          	THEN 
	          self_service_format_pkg.provider_lookup_json_prc(
        	    p_lookup_table => v_provider_lookup_table,
	            p_page => p_page, 
       		    p_page_size => p_page_size,
	            p_total_entries => v_total_entries,
        	    p_lookup_json_clob => v_clob);  
	    ELSE RAISE NO_DATA_FOUND;
	  END IF; 
         END IF;
  
    IF p_search_entity = 'BROKER'
       THEN 

            
            service_comm_pkg.get_broker_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => p_name,
            p_surname => p_surname,
            p_firstname => p_firstname,
            p_init => p_init,
            p_country => p_country,
            p_brand => p_brand,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_broker_lookup_table => v_broker_lookup_table);
	    IF v_total_entries > 0		
              THEN 
          	self_service_format_pkg.broker_lookup_json_prc(
	            p_lookup_table => v_broker_lookup_table,
        	    p_page => p_page, 
	            p_page_size => p_page_size,
	            p_total_entries => v_total_entries,
	            p_lookup_json_clob => v_clob);   
            ELSE RAISE NO_DATA_FOUND;
	  END IF;
         END IF;
  
    IF p_search_entity = 'USER'  
       THEN 
     
            service_general_pkg.get_user_lookup_prc(
            p_auth_entity => p_auth_entity, 
            p_auth_code => p_auth_code, 
            p_name => p_name,
            p_country => p_country,
            p_page => p_page, 
            p_page_size => p_page_size,
            p_total_entries => v_total_entries,
            p_user_lookup_table => v_user_lookup_table);
	    IF v_total_entries > 0		
              THEN 
   	       self_service_format_pkg.user_lookup_json_prc(
  	          p_lookup_table => v_user_lookup_table,
  	          p_page => p_page, 
  	          p_page_size => p_page_size,
  	          p_total_entries => v_total_entries,
   	          p_lookup_json_clob => v_clob);   
	     ELSE RAISE NO_DATA_FOUND;
	  END IF;
         END IF;
  
     
  p_clob := v_clob;     
 
 
  ROLLBACK;
  
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_reason := 'No entries found: Entity: ' || p_search_entity || ' Search Value: ' || p_name || '; ' || 
						p_surname || '; ' || p_firstname;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
    p_clob => v_error_json_clob);
  p_clob := v_error_json_clob;
  ROLLBACK;
  WHEN OTHERS THEN
   v_reason := 'Error in:  Entity: ' || p_search_entity || ' Search Value: ' || p_name || '; ' || 
						p_surname || '; ' || p_firstname;
  self_service_format_pkg.no_result_prc(p_reason => v_reason, 
   					p_clob => v_error_json_clob);
  					p_clob := v_error_json_clob;
  logger.log_error('SSERV Error', l_scope, null, l_params);
  ROLLBACK;     
       
       
  END find_by_identity_prc;
 
 
BEGIN
  -- initialize package body to null
  NULL;
END self_service_v1_pkg;
/
