CREATE OR REPLACE PACKAGE "COMM_SELF_BUILD_PKG" 
AS
/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used by the Commission Self Build project
*                File Name    : $BASE/src/plsql/commselfbuild_pkg.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : 
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/07/03  Sarel    Created Package
*
* </pre>         */

PROCEDURE POPULATE_OHI_PERSON (p_commit BOOLEAN DEFAULT FALSE);

PROCEDURE POPULATE_OHI_PRODUCT (p_commit BOOLEAN DEFAULT FALSE);

PROCEDURE POPULATE_OHI_GROUP (p_commit BOOLEAN DEFAULT FALSE);

/*
*
*  PROCEDURE EXAMPLE_PROCEDURE (p_ab_common_key IN acbauth.ab_common_key%TYPE,
*                               p_acbauth_row OUT acbauth%ROWTYPE );
*
*  FUNCTION EXAMPLE_FUNCTION (p_account_number  varchar2) return boolean ;
*
*/

END COMM_SELF_BUILD_PKG;

/

CREATE OR REPLACE PACKAGE BODY "COMM_SELF_BUILD_PKG" 
  AS
  /**
  * Fetches the ACBAUTH row data for the parameters received.
  * @param p_ab_common_key     description key %TYPE definition
  * @param p_ACBAUTH_row   return ACBAUTH %ROWTYPE to the caller
  * @throws NO_DATA_FOUND exception if the ACBAUTH does not exist
  * @throws STANDARD exception SQLCODE/SQLERRM
  * */
  
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE POPULATE_OHI_PERSON (p_commit BOOLEAN DEFAULT FALSE)
IS
BEGIN
  MERGE INTO ohi_person                          person 
  USING 
   (SELECT poli1.id               AS policy_id
          ,rela.code              AS person_code
          ,rela.name              AS surname  
          ,rela.first_name        AS first_name
          ,rela.initials          AS initials
          ,poli1.code             AS policy_code
          ,prod.code              AS product_code
          ,grps.code              AS group_code 
          ,to_number(grps.broker) AS broker_id_no
          ,poli1.id               AS poli1_id
          ,poen.id                AS poen_id
          ,gapr.id                AS gapr_id
          ,prod.id                AS prod_id
          ,grps.id                AS grps_id
          ,rela.id                AS rela_id
    FROM
     (SELECT id
            ,code
            ,version		 
      FROM pol_policies_v@POLICIES               p 
    	WHERE  version = 
       (SELECT max(version) 
        FROM pol_policies_v@POLICIES             a 
        WHERE  p.code = a.code
       )
     )                                           poli1 
    LEFT OUTER 
      JOIN pol_policyholders_v@policies          polh 
        ON poli1.ID = polh.poli_id               -- policy holders
    LEFT OUTER 
      JOIN pol_policy_enrollments_v@POLICIES     poen 
        ON poli1.id = poen.poli_id               -- policy enrollments
    LEFT OUTER 
      JOIN rel_relations_v@POLICIES              rela 
        ON poen.inse_id = rela.id                -- relations
    LEFT OUTER 
      JOIN pol_policy_enroll_products_v@POLICIES pper
        ON poen.id = pper.poen_id                -- policy enroll products
    LEFT OUTER 
      JOIN pol_group_account_products_v@POLICIES gapr
        ON gapr.id = pper.gapr_id                -- group account products
    LEFT OUTER 
      JOIN pol_enrollment_products_v@POLICIES    prod
        ON gapr.enpr_id = prod.id                -- enrolment product = product
    LEFT OUTER 
      JOIN pol_group_accounts_v@POLICIES         grps
        ON gapr.grac_id = grps.id                -- group
        WHERE 
          grps.broker is NOT null and 
          rela.id is NOT null
   )                                              polperson
  ON 
   (person.person_code  = polperson.person_code and 
    person.product_code = polperson.product_code)
  WHEN MATCHED
    THEN 
      UPDATE 
        SET person.policy_code  = polperson.policy_code 
           ,person.group_code   = polperson.group_code 
           ,person.broker_id_no = polperson.broker_id_no 
           ,person.surname      = polperson.surname 
           ,person.first_name   = polperson.first_name 
           ,person.initials     = polperson.initials
  WHEN NOT MATCHED 
    THEN 
      INSERT 
           (person.person_code
           ,person.policy_code
           ,person.product_code
           ,person.group_code
           ,person.broker_id_no
           ,person.surname
           ,person.first_name
           ,person.initials) 
      VALUES 
           (polperson.person_code
           ,polperson.policy_code
           ,polperson.product_code
           ,polperson.group_code
           ,polperson.broker_id_no
           ,polperson.surname
           ,polperson.first_name
           ,polperson.initials);
  IF p_commit
    THEN
      COMMIT;
  END IF;

-- handle exceptions
EXCEPTION
  WHEN STANDARD.NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PERSON error: No data row found');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PERSON error: Error Code is ' || TO_CHAR(SQLCODE ) );
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PERSON error: Error Message is ' || SQLERRM );

END POPULATE_OHI_PERSON;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE POPULATE_OHI_PRODUCT (p_commit BOOLEAN DEFAULT FALSE)
IS
BEGIN
  MERGE INTO ohi_product                         prod
  USING
   (SELECT poen.code              AS product_code
          ,poen.descr             AS product_name
          ,country.code           AS country_code
	  FROM pol_enrollment_products_v@policies      poen
    LEFT OUTER
      JOIN fcod_country@policies                 country
        ON poen.country_id = country.id          
   )                                             polprod
	ON 
   (prod.product_code = polprod.product_code)
	WHEN MATCHED
    THEN
      UPDATE
        SET prod.product_name = polprod.product_name
           ,prod.country_code = polprod.country_code
  WHEN NOT MATCHED
    THEN
      INSERT 
           (prod.product_code
           ,prod.product_name
           ,prod.country_code
           ,prod.comm_perc
           ,prod.hold_ind)
      VALUES
           (polprod.product_code
           ,polprod.product_name
           ,polprod.country_code
           ,0
           ,'N');
  IF p_commit
    THEN
      COMMIT;
  END IF;

-- handle exceptions
EXCEPTION
  WHEN STANDARD.NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PRODUCT error: No data row found');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PRODUCT error: Error Code is ' || TO_CHAR(SQLCODE ) );
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_PRODUCT error: Error Message is ' || SQLERRM );

END POPULATE_OHI_PRODUCT;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

PROCEDURE POPULATE_OHI_GROUP (p_commit BOOLEAN DEFAULT FALSE)
IS
BEGIN
  MERGE INTO ohi_group                           grp
  USING 
   (SELECT grps.code              AS group_code
          ,grps.descr             AS group_name
          ,grps.parentgroup       AS parentgroup_code
          ,to_number(grps.broker) AS broker_id_no
          ,grpclass.code          AS group_class
          ,prefcur.code           AS pref_cur_code
          ,country.code           AS country_code
    FROM pol_group_accounts_v@policies           grps
    LEFT OUTER 
      JOIN fcod_country@policies                 country
        ON grps.country_id = country.id
    LEFT OUTER 
      JOIN fcod_groupclass@policies              grpclass
        ON grps.groupclass_id = grpclass.id
    LEFT OUTER
      JOIN fcod_prefcur@policies                 prefcur
        ON grps.prefcur_id = prefcur.id
    WHERE  grps.broker IS NOT NULL
   )                                             polgrp
	ON    (grp.group_code = polgrp.group_code)
	WHEN MATCHED
    THEN
      UPDATE
        SET grp.group_name              = polgrp.group_name
           ,grp.parentgroup_code        = polgrp.parentgroup_code
           ,grp.broker_id_no            = polgrp.broker_id_no
           ,grp.group_class             = polgrp.group_class
           ,grp.preferred_currency_code = polgrp.pref_cur_code
           ,grp.country_code            = polgrp.country_code
	WHEN NOT MATCHED
    THEN
      INSERT 
           (grp.group_code
           ,grp.group_name
           ,grp.parentgroup_code
           ,grp.broker_id_no
           ,grp.group_class
           ,grp.preferred_currency_code
           ,grp.country_code)
      VALUES
           (polgrp.group_code
           ,polgrp.group_name
           ,polgrp.parentgroup_code
           ,polgrp.broker_id_no
           ,polgrp.group_class
           ,polgrp.pref_cur_code
           ,polgrp.country_code);
  IF p_commit
    THEN
      COMMIT;
  END IF;

-- handle exceptions
EXCEPTION
  WHEN STANDARD.NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_GROUP error: No data row found');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_GROUP error: Error Code is ' || TO_CHAR(SQLCODE ) );
    DBMS_OUTPUT.PUT_LINE('COMM_SELF_BUILD_PKG.POPULATE_OHI_GROUP error: Error Message is ' || SQLERRM );

END POPULATE_OHI_GROUP;

-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*
*
* PROCEDURE EXAMPLE_PROCEDURE (p_ab_common_key IN ACBAUTH.ab_common_key%TYPE,
*                               p_ACBAUTH_row OUT ACBAUTH%ROWTYPE)
*  IS
*  BEGIN
*    SELECT *
*    INTO p_ACBAUTH_row
*    FROM ACBAUTH
*    WHERE ACBAUTH.ab_common_key = p_ab_common_key;
*
*  -- handle exceptions
*  EXCEPTION
*    WHEN STANDARD.NO_DATA_FOUND THEN
*      DBMS_OUTPUT.PUT_LINE('No data row found for ACBAUTH key: ' || p_ab_common_key);
*    WHEN OTHERS THEN
*      DBMS_OUTPUT.PUT_LINE('Error Code is ' || TO_CHAR(SQLCODE ) );
*      DBMS_OUTPUT.PUT_LINE('Error Message is ' || SQLERRM );
*
*
*  END EXAMPLE_PROCEDURE;
*
*
*  FUNCTION EXAMPLE_FUNCTION (p_account_number  varchar2) return boolean is
*
*  BEGIN
*
*    RETURN FALSE;
*
*  END EXAMPLE_FUNCTION;
*
*/
  
END COMM_SELF_BUILD_PKG;

/
 