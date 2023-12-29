--------------------------------------------------------
--  File created - Tuesday-November-20-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package OHI_POLICIES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "LHHCOM"."OHI_POLICIES_LOAD_PKG" 
AS
/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used by the Commission Self Build project
*                File Name    : Liberty\plsql\packages\lhhcom\ohi_policies_load_pkg.sql
*                Author       : Helen Lane
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example at the bottom of package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/07/03  Sarel    Created Package
*                2018/03/05  Helen    fixed policy versions causing duplicates.
*                2018/05/17  Sarel    Made changes to POBR procedure to pick up Group Broker details also. Needs more testing
*                2018/09/20  Sarel    LS-1860 Load Group Broker if no Policy Broker is found.
*                2019/05/20  Sarel    OP-316 Load Parent Group from new Group Client table. Also, fix the NULL vs NOT NULL selects
*                2020/09/14  Sarel    Cater for Orbit pgrade changes in 19.1, 19.2, 19.3, 20.1 and 20.2 (pol_assigned_broker_agents_v)
*
* </pre>         */

-- gv_username VARCHAR2 (20) := 'POLICIES_LOAD_PKG' ;
 
PROCEDURE POPULATE_OHI_INSE (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_PROD (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_GRPS (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POLI (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POGR (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POHO (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POBR (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POEN (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_OHI_POEP (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE POPULATE_ALL      (p_commit BOOLEAN DEFAULT FALSE);
PROCEDURE CLEAR_TABLES_AFTER_REFRESH (p_commit BOOLEAN DEFAULT FALSE);
-- PROCEDURE BACK_DATED_DATES_FIX (p_poli_id IN NUMBER, p_username in VARCHAR2, pv_message OUT VARCHAR2);


/* 
*  -- Templates for creating new procedures or fauntions
*  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*
*  PROCEDURE EXAMPLE_PROCEDURE (p_ab_common_key IN acbauth.ab_common_key%TYPE,
*                               p_acbauth_row OUT acbauth%ROWTYPE );
*
*  FUNCTION EXAMPLE_FUNCTION (p_account_number  varchar2) return boolean ;
*
*/

/* 
*  -- Example of Procedures executed in an anonymous block (auto-commit data)
*  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

declare
begin
   OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POBR (p_commit);   
--   OHI_POLICIES_LOAD_PKG.POPULATE_ALL(true);
end;
*/

END OHI_POLICIES_LOAD_PKG;

/
--------------------------------------------------------
--  DDL for Package Body OHI_POLICIES_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "LHHCOM"."OHI_POLICIES_LOAD_PKG" 
  AS
    /**
    * Fetches data from the POLICIES database link and populates tables in
    * the Commissions Self Build tables.
    * @param p_commit        auto commits data to the database at the end of 
    *                        each procedure
  * ----------------------------------------------------------------------
  * Project:     : Commission Self Build
  *
  *                Description  : Procedures and Functions used by the Commission Self Build project
  *                File Name    : Liberty\plsql\packages\lhhcom\comm_ohi_policies_load_pkg.sql
  *                Author       : Helen Lane
  *                Requirements : Access to account SCHEMA
  *                Call Syntax  : Anonymous Block Example at the bottom of package header
  *
  *                Amendments   :
  *                Date        User     Change Version    Change Description
  *                ========    ======== ==============    =================================================
  *                2017/07/03  Sarel                      Created Package
  *                2018/03/05  Helen                      fixed policy versions causing duplicates.
  *                2018/05/17  Sarel                      Made changes to POBR procedure to pick up Group Broker details also. Needs more testing
  *                2018/09/20  Sarel                      LS-1860 Load Group Broker if no Policy Broker is found.
  *                2018/11/15  T.Percy   1.0              LS-2264 - Make all jobs asynchronous with logging and output files
  *                2018/12/11  T.Percy   1.1              LS-2482 - Remove orphaned records in the ohi_policy_broker table as causing
  *                                                       data integrity issues (more than one row) in comms_calc_run for UG
  *                2019/05/20  Sarel     1.2              OP-316 Load Parent Group from new Group Client table. Also, fix the NULL vs NOT NULL selects
  * */
    
  -- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    g_directory               VARCHAR2(100) DEFAULT 'LOGDATA';
    g_log_file_name           VARCHAR2(400);
    g_output_file_name        VARCHAR2(400);
    g_logger_identifier       NUMBER;
    g_raise_application_error BOOLEAN DEFAULT FALSE;
  -- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  PROCEDURE write_csv(p_file_name IN VARCHAR2, p_query IN VARCHAR2) IS --1.0
  
  
        l_theCursor         INTEGER DEFAULT dbms_sql.open_cursor;
        l_columnValue       VARCHAR2(4000);
        l_status            INTEGER;
        l_descTbl           dbms_sql.desc_tab;
        l_colCnt            NUMBER;
        n                   NUMBER := 0;
        f                   utl_file.file_type;
        l_line              VARCHAR2(32767);
  
  
  BEGIN
  
    
    --generate a csv file from the select statement
    f := utl_file.fopen(g_directory,p_file_name,'a');
  
    --commissions_pkg.write_to_file(  p_file_name,p_query);
    dbms_sql.parse(l_theCursor,  p_query, dbms_sql.native );
    
    
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
  
    for i in 1 .. l_colCnt loop
       dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
       l_line := l_line ||  l_descTbl(i).col_name||',';
    end loop;
        
    utl_file.put_line(f,l_line);
        
    l_status := dbms_sql.execute(l_theCursor);
  
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
      l_line := null;
      for i in 1 .. l_colCnt loop
         dbms_sql.column_value( l_theCursor, i, l_columnValue );
         l_line := l_line || l_columnValue ||',';
      end loop;
      utl_file.put_line(f,l_line);
    end loop;
        
    utl_file.fclose(f);
    
  EXCEPTION 
    WHEN OTHERS THEN
       utl_file.fclose(f);
  END write_csv;
  
  PROCEDURE POPULATE_OHI_INSE (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix     constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope             logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_inse';
     l_params            logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Insured Entities');
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    
    /*logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_INSE: ', 'RunDate ' 
                        || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));*/
  
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_INSE started');
  
  MERGE INTO ohi_insured_entities                                     cominse
    USING 
    
   (SELECT   rela.code as inse_code
           ,(SELECT titl.code as title 
              FROM rel_titles_v@policies                              titl 
             WHERE titl.id = 
               (SELECT reti.titl_id 
                  FROM rel_persons_titles_v@policies                  reti
                WHERE reti.rela_id = rela.id AND ROWNUM = 1
           )
         )                             AS title
             ,rela.id                  AS rela_id_pers
             ,rela.initials         
             ,rela.first_name
             ,rela.name                AS surname
             ,rela.gender 
             ,rela.last_updated_date   AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
                                       AS username
             ,insp.id                  AS inse_id
            FROM rel_relations_v@policies                             rela
     JOIN  ohi_insurable_persons_v@policies                           insp 
        ON insp.rela_id_pers = rela.id
                   JOIN ohi_users_v@policies                                usrs
              ON usrs.id = rela.last_updated_by
          )               ohiinse
       ON (cominse.inse_id = ohiinse.inse_id ) 
     
  WHEN MATCHED
      THEN
        UPDATE
      SET cominse.inse_code               = ohiinse.inse_code
         ,cominse.rela_id_pers            = ohiinse.rela_id_pers
         ,cominse.title                   = ohiinse.title
         ,cominse.initials                = ohiinse.initials
         ,cominse.first_name              = ohiinse.first_name
         ,cominse.surname                 = ohiinse.surname
         ,cominse.gender                  = ohiinse.gender
         ,cominse.last_update_datetime    = ohiinse.last_update_datetime
         ,cominse.username                = ohiinse.username
      WHERE    
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    cominse.inse_code               !=               ohiinse.inse_code
            OR (cominse.inse_code               IS     NULL  AND ohiinse.inse_code               IS NOT NULL)
            OR (cominse.inse_code               IS NOT NULL  AND ohiinse.inse_code               IS     NULL)
            OR  cominse.rela_id_pers            !=               ohiinse.rela_id_pers
            OR (cominse.rela_id_pers            IS     NULL  AND ohiinse.rela_id_pers            IS NOT NULL)
            OR (cominse.rela_id_pers            IS NOT NULL  AND ohiinse.rela_id_pers            IS     NULL)
            OR  cominse.title                   !=               ohiinse.title
            OR (cominse.title                   IS     NULL  AND ohiinse.title                   IS NOT NULL)
            OR (cominse.title                   IS NOT NULL  AND ohiinse.title                   IS     NULL)
            OR  cominse.initials                !=               ohiinse.initials
            OR (cominse.initials                IS     NULL  AND ohiinse.initials                IS NOT NULL)
            OR (cominse.initials                IS NOT NULL  AND ohiinse.initials                IS     NULL)
            OR  cominse.first_name              !=               ohiinse.first_name
            OR (cominse.first_name              IS     NULL  AND ohiinse.first_name              IS NOT NULL)
            OR (cominse.first_name              IS NOT NULL  AND ohiinse.first_name              IS     NULL)
            OR  cominse.surname                 !=               ohiinse.surname
            OR (cominse.surname                 IS     NULL  AND ohiinse.surname                 IS NOT NULL)
            OR (cominse.surname                 IS NOT NULL  AND ohiinse.surname                 IS     NULL)
            OR  cominse.gender                  !=               ohiinse.gender
            OR (cominse.gender                  IS     NULL  AND ohiinse.gender                  IS NOT NULL)
            OR (cominse.gender                  IS NOT NULL  AND ohiinse.gender                  IS     NULL))
  
  
  WHEN NOT MATCHED
    THEN INSERT (cominse.inse_id
                ,cominse.inse_code
                ,cominse.rela_id_pers
                ,cominse.title
                ,cominse.initials         
                ,cominse.first_name
                ,cominse.surname
                ,cominse.gender
                ,cominse.last_update_datetime
                ,cominse.username)
          VALUES
                (ohiinse.inse_id
                ,ohiinse.inse_code
                ,ohiinse.rela_id_pers
                ,ohiinse.title
                ,ohiinse.initials         
                ,ohiinse.first_name
                ,ohiinse.surname
                ,ohiinse.gender
                ,ohiinse.last_update_datetime
                ,ohiinse.username);
    
       
                            
    IF p_commit
      THEN
        COMMIT;
    END IF;
    
    /* catch all the records which were updated */
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_insured_entities WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        commissions_pkg.write_to_file(g_log_file_name,'Error in synchronising Insured Entities');
        g_raise_application_error := TRUE;
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_INSE', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
  END POPULATE_OHI_INSE;
                
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_PROD (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_prod';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    --logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_PROD: ', 'RunDate '|| to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
      commissions_pkg.write_to_file(g_log_file_name,'==========================================');
      commissions_pkg.write_to_file(g_log_file_name,'Synchronizing the OHI Product Information ');
      commissions_pkg.write_to_file(g_log_file_name,'==========================================');
   -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_PROD started');
  
  MERGE INTO ohi_products                                             comprod
    USING 
    
   (SELECT   enpr.id                    AS enpr_id
             ,enpr.code                 AS product_code
             ,enpr.display_name         AS product_name          
             ,enpr.descr                AS product_descr
             ,country.code              AS country_code
             ,enpr.last_updated_date    AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
                                        AS username
  
      FROM pol_enrollment_products_v@policies                   enpr
      LEFT OUTER
        JOIN fcod_country@policies                                    country
          ON enpr.country_id = country.id
        JOIN ohi_users_v@policies                                usrs
         ON usrs.id = enpr.last_updated_by
          )                            ohiprod
        ON (comprod.enpr_id = ohiprod.enpr_id )
      
  WHEN MATCHED
      THEN
        UPDATE
      SET     comprod.product_code         = ohiprod.product_code
             ,comprod.product_name         = ohiprod.product_name          
             ,comprod.product_descr        = ohiprod.product_descr
             ,comprod.country_code         = ohiprod.country_code
             ,comprod.last_update_datetime = ohiprod.last_update_datetime
             ,comprod.username             = ohiprod.username
      WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    comprod.product_code            !=               ohiprod.product_code
            OR (comprod.product_code            IS     NULL  AND ohiprod.product_code            IS NOT NULL)
            OR (comprod.product_code            IS NOT NULL  AND ohiprod.product_code            IS     NULL)
            OR  comprod.product_name            !=               ohiprod.product_name          
            OR (comprod.product_name            IS     NULL  AND ohiprod.product_name            IS NOT NULL)
            OR (comprod.product_name            IS NOT NULL  AND ohiprod.product_name            IS     NULL)
            OR  comprod.product_descr           !=               ohiprod.product_descr
            OR (comprod.product_descr           IS     NULL  AND ohiprod.product_descr           IS NOT NULL)
            OR (comprod.product_descr           IS NOT NULL  AND ohiprod.product_descr           IS     NULL)
            OR  comprod.country_code            !=               ohiprod.country_code
            OR (comprod.country_code            IS     NULL  AND ohiprod.country_code            IS NOT NULL)
            OR (comprod.country_code            IS NOT NULL  AND ohiprod.country_code            IS     NULL))
        
               
  WHEN NOT MATCHED
    THEN INSERT (comprod.enpr_id
                ,comprod.product_code
                ,comprod.product_name
                ,comprod.product_descr
                ,comprod.country_code
                ,comprod.last_update_datetime
                ,comprod.username
                )
          VALUES 
               (ohiprod.enpr_id
               ,ohiprod.product_code
               ,ohiprod.product_name
               ,ohiprod.product_descr
               ,ohiprod.country_code
               ,ohiprod.last_update_datetime
               ,ohiprod.username
              ) 
    ;
             
    IF p_commit
      THEN
        COMMIT;
    END IF;
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_products WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_PROD', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
  END POPULATE_OHI_PROD;
  
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_GRPS (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_grps';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
   -- logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_GRPS: ', 'RunDate ' 
   --                     || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
     commissions_pkg.write_to_file(g_log_file_name,'==========================================');
     commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Employer Groups');
     commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_GRPS started');
  
  MERGE INTO ohi_groups                                              comgrps
    USING 
    
   (SELECT    grac.id                   		  AS grac_id
             ,grac.code                 		  AS group_code
             ,grac.descr                		  AS group_name
             ,grac.start_date           		  AS effective_start_date
             ,nvl(grac.enddate,'31-JAN-3100') AS effective_end_date  
-- 1.2 Change Parent Group and Group Type to read from Group Client, not Group Account
             ,CASE WHEN     pgroc.code        IS NOT NULL THEN    pgroc.code
                                                          ELSE    NULL
              END 	                          AS parentgroup_code
             ,CASE WHEN     pgroc.code        IS NOT NULL THEN    'GROUP'
                                                          ELSE    'PARENT'
              END 	                          AS group_type
             ,grpclass.code            		    AS group_class
             ,prefcur.code             		    AS preferred_currency_code
             ,country.code              		  AS country_code
             ,grac.last_updated_date    		  AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
                                              AS username    
         
      FROM pol_group_accounts_v@policies                            grac
      LEFT OUTER 
-- 1.2 Change Parent Group and Group Type to read from Group Client, not Group Account
      JOIN pol_group_clients_v@policies                             groc
        ON grac.groc_id = groc.id
      LEFT OUTER 
      JOIN pol_group_clients_v@policies       pgroc
        ON groc.groc_id = pgroc.id
--      LEFT OUTER 
--      JOIN fcod_grouptype@policies            grptype
--        ON grac.grouptype_id = grptype.id
        JOIN fcod_groupclass@policies                               grpclass
          ON grac.groupclass_id = grpclass.id
      LEFT OUTER
        JOIN fcod_prefcur@policies                                  prefcur
          ON grac.prefcur_id = prefcur.id
      LEFT OUTER
        JOIN fcod_country@policies                                  country
          ON grac.country_id = country.id
             JOIN ohi_users_v@policies                              usrs
          ON usrs.id = grac.last_updated_by
          )                            ohigrps
        ON (comgrps.grac_id = ohigrps.grac_id )  
     
  WHEN MATCHED
      THEN
        UPDATE
      SET     comgrps.group_code                = ohigrps.group_code
             ,comgrps.group_name                = ohigrps.group_name          
             ,comgrps.effective_start_date      = ohigrps.effective_start_date
             ,comgrps.effective_end_date        = ohigrps.effective_end_date
             ,comgrps.country_code              = ohigrps.country_code
             ,comgrps.parentgroup_code          = ohigrps.parentgroup_code
             ,comgrps.group_type                = ohigrps.group_type
             ,comgrps.group_class               = ohigrps.group_class
             ,comgrps.preferred_currency_code   = ohigrps.preferred_currency_code
             ,comgrps.last_update_datetime      = ohigrps.last_update_datetime
             ,comgrps.username                  = ohigrps.username
      WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (   comgrps.group_code               !=  ohigrps.group_code
            OR (comgrps.group_code              IS     NULL  AND ohigrps.group_code              IS NOT NULL)
            OR (comgrps.group_code              IS NOT NULL  AND ohigrps.group_code              IS     NULL)
            OR comgrps.group_name               != ohigrps.group_name          
            OR (comgrps.group_name              IS     NULL  AND ohigrps.group_name              IS NOT NULL)
            OR (comgrps.group_name              IS NOT NULL  AND ohigrps.group_name              IS     NULL)
            OR comgrps.effective_start_date     != ohigrps.effective_start_date
            OR (comgrps.effective_start_date    IS     NULL  AND ohigrps.effective_start_date    IS NOT NULL)
            OR (comgrps.effective_start_date    IS NOT NULL  AND ohigrps.effective_start_date    IS     NULL)
            OR comgrps.effective_end_date       != ohigrps.effective_end_date
            OR (comgrps.effective_end_date      IS     NULL  AND ohigrps.effective_end_date      IS NOT NULL)
            OR (comgrps.effective_end_date      IS NOT NULL  AND ohigrps.effective_end_date      IS     NULL)
            OR comgrps.country_code             != ohigrps.country_code
            OR (comgrps.country_code            IS     NULL  AND ohigrps.country_code            IS NOT NULL)
            OR (comgrps.country_code            IS NOT NULL  AND ohigrps.country_code            IS     NULL)
            OR comgrps.parentgroup_code         != ohigrps.parentgroup_code
            OR (comgrps.parentgroup_code        IS     NULL  AND ohigrps.parentgroup_code        IS NOT NULL)
            OR (comgrps.parentgroup_code        IS NOT NULL  AND ohigrps.parentgroup_code        IS     NULL)
            OR comgrps.group_type               != ohigrps.group_type
            OR (comgrps.group_type              IS     NULL  AND ohigrps.group_type              IS NOT NULL)
            OR (comgrps.group_type              IS NOT NULL  AND ohigrps.group_type              IS     NULL)
            OR comgrps.group_class              != ohigrps.group_class
            OR (comgrps.group_class             IS     NULL  AND ohigrps.group_class             IS NOT NULL)
            OR (comgrps.group_class             IS NOT NULL  AND ohigrps.group_class             IS     NULL)
            OR comgrps.preferred_currency_code  != ohigrps.preferred_currency_code
            OR (comgrps.preferred_currency_code IS     NULL  AND ohigrps.preferred_currency_code IS NOT NULL)
            OR (comgrps.preferred_currency_code IS NOT NULL  AND ohigrps.preferred_currency_code IS     NULL))
            
-- Change all to check for NULL and NOT NULL
-- https://asktom.oracle.com/pls/asktom/f%3Fp%3D100:11:0::::P11_QUESTION_ID:7806711400346248708
             
  WHEN NOT MATCHED
    THEN INSERT (comgrps.grac_id
                ,comgrps.group_code
                ,comgrps.group_name
                ,comgrps.effective_start_date
                ,comgrps.effective_end_date
                ,comgrps.parentgroup_code
                ,comgrps.group_type
                ,comgrps.group_class
                ,comgrps.preferred_currency_code
                ,comgrps.country_code
                ,comgrps.last_update_datetime
                ,comgrps.username
                )
          VALUES 
                (ohigrps.grac_id
                ,ohigrps.group_code
                ,ohigrps.group_name
                ,ohigrps.effective_start_date
                ,ohigrps.effective_end_date
                ,ohigrps.parentgroup_code
                ,ohigrps.group_type
                ,ohigrps.group_class
                ,ohigrps.preferred_currency_code
                ,ohigrps.country_code
               ,ohigrps.last_update_datetime
               ,ohigrps.username
              ) ;
             
    IF p_commit
      THEN
        COMMIT;
    END IF;
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_groups WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_GRPS', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
  END POPULATE_OHI_GRPS;
    
   -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_POLI (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_poli';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
   -- logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POLI: ', 'RunDate ' 
   --                     || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
     commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policies');
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POLI started');
  
    MERGE INTO ohi_policies                                            compoli
    USING (
           SELECT poli.id                    AS poli_id
                 ,poli.code                  AS policy_code   
                 ,poli.last_updated_date     AS last_update_datetime
                 ,nvl(upper(usrs.login_name),usrs.display_name)    
                                             AS username
                 ,poli.version
                 ,poli.status
             FROM pol_policies_v@policies                              poli
             JOIN ohi_users_v@policies                                 usrs
               ON usrs.id = poli.last_updated_by        
  	        WHERE poli.version = (SELECT MAX(version)
                                    FROM pol_policies_v@policies 
                                   WHERE code = poli.code 
                                     AND status = 'APPROVED') 
          )                            ohipoli
       ON (compoli.poli_id = ohipoli.poli_id)  
      WHEN MATCHED THEN
        UPDATE
          SET compoli.policy_code               =  ohipoli.policy_code
             ,compoli.last_update_datetime      =  ohipoli.last_update_datetime
             ,compoli.username                  =  ohipoli.username
        WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
              (    compoli.policy_code             !=               ohipoli.policy_code
               OR (compoli.policy_code             IS     NULL  AND ohipoli.policy_code              IS NOT NULL)
               OR (compoli.policy_code             IS NOT NULL  AND ohipoli.policy_code              IS     NULL))
      WHEN NOT MATCHED THEN
        INSERT (compoli.poli_id
               ,compoli.policy_code
               ,compoli.last_update_datetime
               ,compoli.username)
        VALUES (ohipoli.poli_id
               ,ohipoli.policy_code
               ,ohipoli.last_update_datetime
               ,ohipoli.username);
    IF p_commit
      THEN
        COMMIT;
    END IF;
    
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_policies WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POLI', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
      
  END POPULATE_OHI_POLI;
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_POGR (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_pogr';
     l_params logger.tab_param;
  
  BEGIN 
  
    -- Setting the logger values in case of errors
   -- logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POGR: ', 'RunDate ' 
    --                    || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policy Groups');
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POGR started');
  
  MERGE INTO ohi_policy_groups                                     compogr
    USING
    
    (SELECT   pogr.id         		           AS pogr_id
             ,pogr.poli_id
             ,pogr.grac_id
             ,pogr.start_date         		   AS effective_start_date 
             ,nvl(pogr.end_date,'31-JAN-3100')   AS effective_end_date
             ,pogr.last_updated_date             AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
  											   AS username
             ,poli.version
             ,poli.status
  	FROM pol_policy_group_accounts_v@policies                    pogr
  	  JOIN pol_policies_v@policies                               poli
          ON pogr.poli_id = poli.id	  
        JOIN ohi_users_v@policies                                usrs
          ON usrs.id = pogr.last_updated_by
    	    WHERE poli.version = (SELECT MAX(version)
                              FROM pol_policies_v@policies 
                            WHERE code = poli.code 
                              AND status = 'APPROVED'))  ohipogr
          ON (compogr.pogr_id = ohipogr.pogr_id)
  		
  	WHEN MATCHED
      THEN
        UPDATE
  		SET	 compogr.poli_id              = ohipogr.poli_id
  	      ,compogr.grac_id              = ohipogr.grac_id
  		    ,compogr.effective_start_date = ohipogr.effective_start_date
  	    	,compogr.effective_end_date   = ohipogr.effective_end_date
  	    	,compogr.last_update_datetime = ohipogr.last_update_datetime
          ,compogr.username             = ohipogr.username
  	 WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    compogr.poli_id         	 	    !=               ohipogr.poli_id	
            OR (compogr.poli_id                 IS     NULL  AND ohipogr.poli_id                 IS NOT NULL)
            OR (compogr.poli_id                 IS NOT NULL  AND ohipogr.poli_id                 IS     NULL)
        		OR  compogr.grac_id          	      !=               ohipogr.grac_id
            OR (compogr.grac_id                 IS     NULL  AND ohipogr.grac_id                 IS NOT NULL)
            OR (compogr.grac_id                 IS NOT NULL  AND ohipogr.grac_id                 IS     NULL)
  		      OR  compogr.effective_start_date    !=               ohipogr.effective_start_date
            OR (compogr.effective_start_date    IS     NULL  AND ohipogr.effective_start_date    IS NOT NULL)
            OR (compogr.effective_start_date    IS NOT NULL  AND ohipogr.effective_start_date    IS     NULL)
        		OR  compogr.effective_end_date      !=               ohipogr.effective_end_date
            OR (compogr.effective_end_date      IS     NULL  AND ohipogr.effective_end_date      IS NOT NULL)
            OR (compogr.effective_end_date      IS NOT NULL  AND ohipogr.effective_end_date      IS     NULL))
  		
  	WHEN NOT MATCHED
  		THEN INSERT (compogr.pogr_id
  				    ,compogr.poli_id
  				    ,compogr.grac_id
  				  	,compogr.effective_start_date
  				  	,compogr.effective_end_date
  				  	,compogr.last_update_datetime
  				  	,compogr.username)
  			VALUES  (ohipogr.pogr_id
  				    ,ohipogr.poli_id
  				    ,ohipogr.grac_id
  				    ,ohipogr.effective_start_date
  				  	,ohipogr.effective_end_date
  				  	,ohipogr.last_update_datetime
  				  	,ohipogr.username 
              ) ;
             
    IF p_commit
      THEN
        COMMIT;
    END IF;
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_policy_groups WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POGR', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
      
  END POPULATE_OHI_POGR;									   
  									   
    -- *****************************************************************
  
  PROCEDURE POPULATE_OHI_POHO (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_poho';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
   -- logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POHO: ', 'RunDate ' 
    --                    || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policy Holders');
    commissions_pkg.write_to_file(g_log_file_name,'==========================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POHO started');
  
  MERGE INTO ohi_policyholders                                     compoho
    USING 
    
   (SELECT   (SELECT titl.code as title 
              FROM rel_titles_v@policies                              titl 
             WHERE titl.id = 
               (SELECT reti.titl_id 
                  FROM rel_persons_titles_v@policies                  reti
                WHERE reti.rela_id = rela.id AND ROWNUM = 1
           )
         )                             AS title
             ,rela.id                  AS rela_id_pers
             ,rela.initials         
             ,rela.first_name
             ,rela.name                AS surname
             ,poho.start_date           		  AS effective_start_date
             ,nvl(poho.end_date,'31-JAN-3100')  AS effective_end_date  
             ,rela.last_updated_date   AS last_update_datetime
             ,nvl(upper(usrs.login_name),usrs.display_name)    
                                       AS username
             ,poho.id                  AS poho_id
             ,poli.id                  AS poli_id
             ,poli.version
             ,poli.status
     FROM rel_relations_v@policies                                    rela
     JOIN  pol_policyholders_v@policies                               poho 
        ON poho.rela_id_pers = rela.id
     JOIN pol_policies_v@policies                                     poli
        ON poli.id = poho.poli_id
     JOIN ohi_users_v@policies                                        usrs
        ON usrs.id = rela.last_updated_by
        
    	    WHERE poli.version = (SELECT MAX(version)
                              FROM pol_policies_v@policies 
                            WHERE code = poli.code 
                              AND status = 'APPROVED')      
          )               ohipoho
       ON (compoho.poho_id = ohipoho.poho_id ) 
     
  WHEN MATCHED
      THEN
        UPDATE
      SET compoho.rela_id_pers            = ohipoho.rela_id_pers
         ,compoho.poli_id                 = ohipoho.poli_id
         ,compoho.title                   = ohipoho.title
         ,compoho.initials                = ohipoho.initials
         ,compoho.first_name              = ohipoho.first_name
         ,compoho.surname                 = ohipoho.surname
         ,compoho.effective_start_date    = ohipoho.effective_start_date
  	     ,compoho.effective_end_date      = ohipoho.effective_end_date
         ,compoho.last_update_datetime    = ohipoho.last_update_datetime
         ,compoho.username                = ohipoho.username
     WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    compoho.rela_id_pers            !=               ohipoho.rela_id_pers
            OR (compoho.rela_id_pers            IS     NULL  AND ohipoho.rela_id_pers            IS NOT NULL)
            OR (compoho.rela_id_pers            IS NOT NULL  AND ohipoho.rela_id_pers            IS     NULL)
            OR  compoho.poli_id                 !=               ohipoho.poli_id
            OR (compoho.poli_id                 IS     NULL  AND ohipoho.poli_id                 IS NOT NULL)
            OR (compoho.poli_id                 IS NOT NULL  AND ohipoho.poli_id                 IS     NULL)
            OR  compoho.title                   !=               ohipoho.title
            OR (compoho.title                   IS     NULL  AND ohipoho.title                   IS NOT NULL)
            OR (compoho.title                   IS NOT NULL  AND ohipoho.title                   IS     NULL)
            OR  compoho.initials                !=               ohipoho.initials
            OR (compoho.initials                IS     NULL  AND ohipoho.initials                IS NOT NULL)
            OR (compoho.initials                IS NOT NULL  AND ohipoho.initials                IS     NULL)
            OR  compoho.first_name              !=               ohipoho.first_name
            OR (compoho.first_name              IS     NULL  AND ohipoho.first_name              IS NOT NULL)
            OR (compoho.first_name              IS NOT NULL  AND ohipoho.first_name              IS     NULL)
            OR  compoho.surname                 !=               ohipoho.surname
            OR (compoho.surname                 IS     NULL  AND ohipoho.surname                 IS NOT NULL)
            OR (compoho.surname                 IS NOT NULL  AND ohipoho.surname                 IS     NULL)
            OR  compoho.effective_start_date    !=               ohipoho.effective_start_date
            OR (compoho.effective_start_date    IS     NULL  AND ohipoho.effective_start_date    IS NOT NULL)
            OR (compoho.effective_start_date    IS NOT NULL  AND ohipoho.effective_start_date    IS     NULL)
  	        OR  compoho.effective_end_date      !=               ohipoho.effective_end_date
            OR (compoho.effective_end_date      IS     NULL  AND ohipoho.effective_end_date      IS NOT NULL)
            OR (compoho.effective_end_date      IS NOT NULL  AND ohipoho.effective_end_date      IS     NULL))
         
  WHEN NOT MATCHED
    THEN INSERT (compoho.poho_id
                ,compoho.poli_id
                ,compoho.rela_id_pers
                ,compoho.title
                ,compoho.initials         
                ,compoho.first_name
                ,compoho.surname
                ,compoho.effective_start_date
  			        ,compoho.effective_end_date
                ,compoho.last_update_datetime
                ,compoho.username)
          VALUES
               (ohipoho.poho_id
                ,ohipoho.poli_id
                ,ohipoho.rela_id_pers
                ,ohipoho.title
                ,ohipoho.initials         
                ,ohipoho.first_name
                ,ohipoho.surname
                ,ohipoho.effective_start_date
  			        ,ohipoho.effective_end_date
                ,ohipoho.last_update_datetime
                ,ohipoho.username) ;
                
                            
    IF p_commit
      THEN
        COMMIT;
    END IF;
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_policyholders WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POHO', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
  END POPULATE_OHI_POHO;
  
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_POBR (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_pobr';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    --logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POBR: ', 'RunDate ' 
    --                    || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
    commissions_pkg.write_to_file(g_log_file_name,'================================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policy Brokers/Groups');
    commissions_pkg.write_to_file(g_log_file_name,'================================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POBR started');
  
  MERGE INTO ohi_policy_brokers                                     compobr
    USING 
      (
        SELECT
               poli.id                                           AS poli_id
              ,CASE WHEN     agnt.code        IS NOT NULL 
                         AND brok.code        IS NOT NULL   THEN    poba.id
                    WHEN     agnt.code        IS NOT NULL  
                         AND brok.code        IS NULL       THEN    poba.id
                    WHEN     agnt.code        IS NULL      
                         AND brok.code        IS NOT NULL   THEN    poba.id
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL 
                         AND grag.agent       IS NOT NULL   THEN    grag.id 
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NOT NULL   THEN    grbr.id 
                    WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NULL       THEN    pogr.id 
               END	    	                                       AS pobr_id
              ,CASE WHEN     trim(agnt.code)  IS NOT NULL   THEN    trim(agnt.code) 
                                                            ELSE    trim(grag.agent)
               END 	                                             AS broker_id_no
  			      ,CASE WHEN     trim(brok.code)  IS NOT NULL   THEN    trim(brok.code) 
                                                            ELSE    trim(grbr.broker)     
               END	                                             AS company_id_no				
       			  ,CASE WHEN     trim(agnt.code)   IS NOT NULL  THEN    poba.start_date
                    WHEN     trim(grag.agent)  IS NOT NULL
                         AND pogr.start_date < grag.start_date THEN grag.start_date
                    WHEN     trim(grag.agent)  IS NOT NULL  THEN    nvl(pogr.start_date,grag.start_date)
                    WHEN     trim(brok.code)   IS NOT NULL  THEN    poba.start_date
                    WHEN     trim(grbr.broker) IS NOT NULL
                         AND pogr.start_date < grbr.start_date THEN grbr.start_date
                                                            ELSE    nvl(pogr.start_date, grbr.start_date)
               END				                                       AS effective_start_date	
       			  ,CASE WHEN     trim(agnt.code)   IS NOT NULL  THEN    nvl(poba.end_date,'31-JAN-3100')
                    WHEN     trim(grag.agent)  IS NOT NULL
                         AND pogr.end_date < grag.end_date  THEN    nvl(grag.end_date,'31-JAN-3100')
                    WHEN     trim(grag.agent)  IS NOT NULL  THEN    nvl(nvl(pogr.end_date, grag.end_date),'31-JAN-3100')
                    WHEN     trim(brok.code)   IS NOT NULL  THEN    nvl(poba.end_date,'31-JAN-3100')
                    WHEN     trim(grbr.broker) IS NOT NULL
                         AND pogr.end_date > grbr.end_date  THEN    nvl(grbr.end_date,'31-JAN-3100')
                                                            ELSE    nvl(nvl(pogr.end_date, grbr.end_date),'31-JAN-3100')
               END                                               AS effective_end_date
              ,poli.last_updated_date                 		       AS last_update_datetime
              ,nvl(upper(usrs.login_name),usrs.display_name)     AS username
  			  FROM pol_policies_v@policies                              poli
          LEFT OUTER 
          JOIN pol_assigned_broker_agents_v@policies                  poba   -- (both)
            ON     poli.id = poba.poli_id
          LEFT OUTER 
          JOIN pol_brokers_v@policies                               brok
            ON     poba.brkr_id = brok.id 
  		    LEFT OUTER 
          JOIN pol_agents_v@policies                                agnt
            ON     poba.agnt_id = agnt.id 
          LEFT OUTER 
          JOIN pol_policy_group_accounts_v@policies                 pogr
            ON     poli.id = pogr.poli_id 
               AND poba.id IS NULL
  		    LEFT OUTER 
          JOIN grac_agent@policies                                  grag
            ON     grag.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                       AND grag.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          LEFT OUTER 
          JOIN grac_broker@policies                                 grbr
            ON     grbr.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                       AND grbr.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          JOIN ohi_users_v@policies                                 usrs
            ON     usrs.id = poli.last_updated_by
         WHERE     poli.version = (SELECT MAX(version)
                                     FROM pol_policies_v@policies 
                                    WHERE     code = poli.code 
                                          AND status = 'APPROVED')
      )                                                             ohipobr
       ON (    compobr.poli_id = ohipobr.poli_id 
           AND compobr.pobr_id = ohipobr.pobr_id)                           
    WHEN MATCHED 
      THEN
        UPDATE 
          SET compobr.broker_id_no            = ohipobr.broker_id_no
  	         ,compobr.company_id_no          = ohipobr.company_id_no
             ,compobr.effective_start_date   = ohipobr.effective_start_date	
             ,compobr.effective_end_date     = ohipobr.effective_end_date	
          WHERE
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
                (    compobr.broker_id_no            !=               ohipobr.broker_id_no
                 OR (compobr.broker_id_no            IS     NULL  AND ohipobr.broker_id_no            IS NOT NULL)
                 OR (compobr.broker_id_no            IS NOT NULL  AND ohipobr.broker_id_no            IS     NULL)
                 OR  compobr.company_id_no           !=               ohipobr.company_id_no
                 OR (compobr.company_id_no           IS     NULL  AND ohipobr.company_id_no           IS NOT NULL)
                 OR (compobr.company_id_no           IS NOT NULL  AND ohipobr.company_id_no           IS     NULL)
                 OR  compobr.effective_start_date    != ohipobr.effective_start_date 												
                 OR (compobr.effective_start_date    IS     NULL  AND ohipobr.effective_start_date    IS NOT NULL)
                 OR (compobr.effective_start_date    IS NOT NULL  AND ohipobr.effective_start_date    IS     NULL)
                 OR  compobr.effective_end_date      != ohipobr.effective_end_date
                 OR (compobr.effective_end_date      IS     NULL  AND ohipobr.effective_end_date      IS NOT NULL)
                 OR (compobr.effective_end_date      IS NOT NULL  AND ohipobr.effective_end_date      IS     NULL))
        DELETE WHERE ohipobr.broker_id_no = NULL AND ohipobr.company_id_no = NULL 
      
  WHEN NOT MATCHED
    THEN INSERT (compobr.poli_id
                ,compobr.pobr_id
                ,compobr.broker_id_no
                ,compobr.company_id_no
                ,compobr.effective_start_date 
                ,compobr.effective_end_date         
                ,compobr.last_update_datetime
                ,compobr.username)
          VALUES
               (ohipobr.poli_id
               ,ohipobr.pobr_id
               ,ohipobr.broker_id_no
               ,ohipobr.company_id_no                                             
               ,ohipobr.effective_start_date
               ,ohipobr.effective_end_date
               ,ohipobr.last_update_datetime
               ,ohipobr.username)
          WHERE ohipobr.company_id_no IS NOT NULL or ohipobr.broker_id_no IS NOT NULL
                 ;
                        
                            
    IF p_commit
      THEN
        COMMIT;
    END IF;
     write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_policy_brokers WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- issue with orphaned pobr records where they have been deleted on OHI but exist in self-build
    -- this is causing issues with fetch returns more than one row - data integrity issue
    -- this section checks target to source to identify orphaned records
    -- start 1.1
    FOR c_rec in (
    SELECT pobr_id
      FROM LHHCOM.ohi_policy_brokers 
     MINUS
     SELECT CASE WHEN     agnt.code        IS NOT NULL 
                         AND brok.code        IS NOT NULL   THEN    poba.id
                 WHEN     agnt.code        IS NOT NULL  
                         AND brok.code        IS NULL       THEN    poba.id
                 WHEN     agnt.code        IS NULL      
                         AND brok.code        IS NOT NULL   THEN    poba.id
                 WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL 
                         AND grag.agent       IS NOT NULL   THEN    grag.id 
                 WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NOT NULL   THEN    grbr.id 
                 WHEN     agnt.code        IS NULL 
                         AND brok.code        IS NULL
                         AND grag.agent       IS NULL 
                         AND grbr.broker      IS NULL       THEN    pogr.id 
             END pobr_id
        FROM pol_policies_v@policies                              poli
          LEFT OUTER 
          JOIN pol_assigned_broker_agents_v@policies                poba   -- (both)
            ON     poli.id = poba.poli_id
          LEFT OUTER 
          JOIN pol_brokers_v@policies                               brok
            ON     poba.brkr_id = brok.id 
  		    LEFT OUTER 
          JOIN pol_agents_v@policies                                agnt
            ON     poba.agnt_id = agnt.id 
          LEFT OUTER 
          JOIN pol_policy_group_accounts_v@policies                 pogr
            ON     poli.id = pogr.poli_id 
               AND poba.id IS NULL
  		    LEFT OUTER 
          JOIN grac_agent@policies                                  grag
            ON     grag.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grag.start_date AND nvl(grag.end_date,'31-JAN-3100')
                       AND grag.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          LEFT OUTER 
          JOIN grac_broker@policies                                 grbr
            ON     grbr.grac_id = pogr.grac_id 
               AND poba.id IS NULL
               AND (   pogr.start_date 
                       BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                    OR (   pogr.start_date 
                           NOT BETWEEN grbr.start_date AND nvl(grbr.end_date,'31-JAN-3100')
                       AND grbr.start_date 
                           BETWEEN pogr.start_date AND nvl(pogr.end_date,'31-JAN-3100')))
          JOIN ohi_users_v@policies                                 usrs
            ON     usrs.id = poli.last_updated_by
         WHERE     poli.version = (SELECT MAX(version)
                                     FROM pol_policies_v@policies 
                                    WHERE     code = poli.code 
                                          AND status = 'APPROVED')) LOOP
          
          commissions_pkg.write_to_file(g_log_file_name,'Orphaned Policy Broker records in Self-build deleted '||c_rec.pobr_id);
          DELETE FROM LHHCOM.ohi_policy_brokers where pobr_id = c_rec.pobr_id;
          
          
      END LOOP;
      
      COMMIT;
      -- end 1.1
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POBR', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
    END POPULATE_OHI_POBR;
  
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_POEN (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_poen';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    --logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEN: ', 'RunDate ' 
    --                    || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
     commissions_pkg.write_to_file(g_log_file_name,'=============================================');
     commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policy Enrollments');
     commissions_pkg.write_to_file(g_log_file_name,'=============================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEN started');
  
  MERGE INTO ohi_policy_enrollments                    compoen
    USING 
     (SELECT poen.id                  AS poen_id
         ,poen.poli_id 
         ,poen.inse_id
         ,poen.dependant_id
         ,poen.last_updated_date     AS last_update_datetime
         ,nvl(upper(usrs.login_name),usrs.display_name)    
                                     AS username        
         ,poli.version
         ,poli.status
  FROM 
    pol_policy_enrollments_v@policies                  poen
       JOIN pol_policies_v@policies                    poli
  	        ON poli.id = poen.poli_id
       JOIN ohi_users_v@policies                       usrs
              ON usrs.id = poen.last_updated_by
              
                	    WHERE poli.version = (SELECT MAX(version)
                              FROM pol_policies_v@policies 
                            WHERE code = poli.code 
                              AND status = 'APPROVED')
  			)                                              ohipoen    
    ON (ohipoen.poen_id = compoen.poen_id )
    
  	WHEN MATCHED
      THEN
        UPDATE
      SET compoen.poli_id               = ohipoen.poli_id
         ,compoen.inse_id               = ohipoen.inse_id
         ,compoen.dependant_id          = ohipoen.dependant_id
         ,compoen.last_update_datetime  = ohipoen.last_update_datetime
         ,compoen.username              = ohipoen.username
     WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    compoen.poli_id                 !=               ohipoen.poli_id
            OR (compoen.poli_id                 IS     NULL  AND ohipoen.poli_id                 IS NOT NULL)
            OR (compoen.poli_id                 IS NOT NULL  AND ohipoen.poli_id                 IS     NULL)
            OR  compoen.inse_id                 !=               ohipoen.inse_id
            OR (compoen.inse_id                 IS     NULL  AND ohipoen.inse_id                 IS NOT NULL)
            OR (compoen.inse_id                 IS NOT NULL  AND ohipoen.inse_id                 IS     NULL)
            OR  compoen.dependant_id            !=               ohipoen.dependant_id
            OR (compoen.dependant_id            IS     NULL  AND ohipoen.dependant_id            IS NOT NULL)
            OR (compoen.dependant_id            IS NOT NULL  AND ohipoen.dependant_id            IS     NULL))
      
    WHEN NOT MATCHED
      THEN
        INSERT (compoen.poen_id
               ,compoen.poli_id
               ,compoen.inse_id
               ,compoen.dependant_id
               ,compoen.last_update_datetime
               ,compoen.username)
        VALUES 
              (ohipoen.poen_id
              ,ohipoen.poli_id
              ,ohipoen.inse_id
              ,ohipoen.dependant_id
              ,ohipoen.last_update_datetime
              ,ohipoen.username);
              
    IF p_commit
      THEN
        COMMIT;
    END IF;
     write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_policy_enrollments WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEN', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
    END POPULATE_OHI_POEN;
  
  
  -- *******************************************************************
  
  PROCEDURE POPULATE_OHI_POEP (p_commit BOOLEAN DEFAULT FALSE)
  IS
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_ohi_poep';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEP: ', 'RunDate ' 
                        || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
    commissions_pkg.write_to_file(g_log_file_name,'=====================================================');
    commissions_pkg.write_to_file(g_log_file_name,'Start of synchronizing the Policy Product Enrollments');
    commissions_pkg.write_to_file(g_log_file_name,'=====================================================');
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEP started');
  
  MERGE INTO ohi_enrollment_products                         compoep
    USING 
     (SELECT 
             poep.id                                          AS poep_id
            ,poep.poen_id                                     AS poen_id
            ,poen.poli_id                                     AS poen_poli_id
            ,poli.id                                          		  
            ,gapr.id                                          AS gapr_id 
            ,nvl(poep.enpr_id,gapr.enpr_id)                   AS enpr_id 
            ,poep.start_date                                  AS effective_start_date
            ,nvl(poep.end_date,'31-JAN-3100')                 AS effective_end_date
            ,poep.last_updated_date                           AS last_update_datetime
            ,nvl(upper(usrs.login_name),usrs.display_name)    
                                                              AS username      
               
            ,poep.enpr_id                                     AS poep_enpr_id
            ,poli.version
            ,poli.status
  FROM 
    pol_policy_enroll_products_v@policies                    poep
    JOIN pol_group_account_products_v@policies               gapr
      ON gapr.id = poep.gapr_id
    JOIN pol_policy_enrollments_v@policies                   poen
      ON poen.id = poep.poen_id
     JOIN pol_policies_v@policies                            poli
      ON poen.poli_id = poli.id
    JOIN ohi_users_v@policies                               usrs
      ON usrs.id = poep.last_updated_by 
            	    WHERE poli.version = (SELECT MAX(version)
                              FROM pol_policies_v@policies 
                            WHERE code = poli.code 
                              AND status = 'APPROVED')
    )                                                        ohipoep    
    ON (ohipoep.poep_id = compoep.poep_id )
    
  	WHEN MATCHED
      THEN
        UPDATE
      SET compoep.poen_id               = ohipoep.poen_id
         ,compoep.enpr_id               = ohipoep.enpr_id 
         ,compoep.effective_start_date  = ohipoep.effective_start_date
         ,compoep.effective_end_date    = ohipoep.effective_end_date
         ,compoep.last_update_datetime  = ohipoep.last_update_datetime
         ,compoep.username              = ohipoep.username
     WHERE 
-- 1.2 Change "a != b"  -->  "a != b OR (a IS NULL AND b IS NOT NULL) OR (a IS NOT NULL AND b IS NULL)"
           (    compoep.poen_id                 !=               ohipoep.poen_id
            OR (compoep.poen_id                 IS     NULL  AND ohipoep.poen_id                 IS NOT NULL)
            OR (compoep.poen_id                 IS NOT NULL  AND ohipoep.poen_id                 IS     NULL)
            OR  compoep.enpr_id                 !=               ohipoep.enpr_id 
            OR (compoep.enpr_id                 IS     NULL  AND ohipoep.enpr_id                 IS NOT NULL)
            OR (compoep.enpr_id                 IS NOT NULL  AND ohipoep.enpr_id                 IS     NULL)
            OR  compoep.effective_start_date    !=               ohipoep.effective_start_date
            OR (compoep.effective_start_date    IS     NULL  AND ohipoep.effective_start_date    IS NOT NULL)
            OR (compoep.effective_start_date    IS NOT NULL  AND ohipoep.effective_start_date    IS     NULL)
            OR  compoep.effective_end_date      !=               ohipoep.effective_end_date
            OR (compoep.effective_end_date      IS     NULL  AND ohipoep.effective_end_date      IS NOT NULL)
            OR (compoep.effective_end_date      IS NOT NULL  AND ohipoep.effective_end_date      IS     NULL))
         
    WHEN NOT MATCHED 
      THEN 
        INSERT (compoep.poep_id
               ,compoep.poen_id
               ,compoep.enpr_id
               ,compoep.effective_start_date
               ,compoep.effective_end_date
               ,compoep.last_update_datetime
               ,compoep.username)
        VALUES 
              (ohipoep.poep_id
              ,ohipoep.poen_id
              ,ohipoep.enpr_id
              ,ohipoep.effective_start_date
              ,ohipoep.effective_end_date
              ,ohipoep.last_update_datetime
              ,ohipoep.username)
              ;
              
    IF p_commit
      THEN
        COMMIT;
    END IF;
    write_csv(g_output_file_name,'SELECT * FROM lhhcom.ohi_enrollment_products WHERE last_update_datetime BETWEEN SYSDATE - 30 / 24 / 60 AND SYSDATE');
    
    -- handle exceptions
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEP', l_scope, null, l_params);
        -- dbms_output.put_line('Error Code is ' || TO_CHAR(SQLCODE ) );
        -- dbms_output.put_line('Error Message is ' || SQLERRM );
        -- RAISE;
                 
  END POPULATE_OHI_POEP ;
  
  -- *******************************************************************
  
  PROCEDURE POPULATE_ALL (p_commit BOOLEAN DEFAULT FALSE)
  IS
  --  l_return_msg VARCHAR2(100);
  
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.populate_all';
     l_params logger.tab_param;
     
     l_session_id     VARCHAR2(200);
     l_slave_id       NUMBER;
     l_job_start_date DATE;
  
  BEGIN
  
     -- changes made to handle this job in the scheduler - require get the scheduler id for logging purposes --1.0
    select sys_context('userenv','sid') INTO l_session_id from dual;
    select userenv('PID')               INTO l_slave_id FROM DUAL;
  
  
   
    g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);
       
    g_log_file_name    := g_logger_identifier||'.html';
    g_output_file_name := g_logger_identifier||'.csv';
    
    
    --open up a log and output file to store the run and output information for reference
    commissions_pkg.create_file(  
                        p_file_name     => g_log_file_name,
                        p_process       => 'OHI Information Synchronization'
                      );
   
    commissions_pkg.create_file(  
                        p_file_name     => g_output_file_name,
                        p_process       => 'OHI Information Synchronization'
                      ); 
    -- end 1.0
    
    -- Setting the logger values in case of errors
    /*logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.POPULATE_ALL: ', 'RunDate ' 
                        || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));*/
    commissions_pkg.write_to_file(g_log_file_name,'OHI_POLICIES_LOAD_PKG.POPULATE_ALL: RunDate ' || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));                     
  
    -- logger.log_information('OHI_POLICIES_LOAD_PKG.POPULATE_ALL started');
  
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_INSE (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_PROD (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_GRPS (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POLI (p_commit);   
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POGR (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POHO (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POBR (p_commit);   
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEN (p_commit);
     OHI_POLICIES_LOAD_PKG.POPULATE_OHI_POEP (p_commit);
   --  OHI_COMMS_CALC_PKG.RECALC_CHANGES_RUN (p_return_msg => l_return_msg);
   
   
  EXCEPTION
      WHEN OTHERS THEN
        commissions_pkg.write_to_file(g_log_file_name,'Unhandled Exception : '||SQLERRM);
        --logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.POPULATE_ALL', l_scope, null, l_params);
   
  END POPULATE_ALL;
  
  -- *****************************************************************
  
  PROCEDURE CLEAR_TABLES_AFTER_REFRESH (p_commit BOOLEAN DEFAULT FALSE)
  IS
  
     gc_scope_prefix constant VARCHAR2(31) := lower($$PLSQL_UNIT);
     l_scope logger_logs.scope%type := 'CommissionsSelfBuild: ' || gc_scope_prefix || '.clear_tables_after_refresh';
     l_params logger.tab_param;
  
  BEGIN
  
    -- Setting the logger values in case of errors
    logger.append_param(l_params, 'OHI_POLICIES_LOAD_PKG.CLEAR_TABLES_AFTER_REFRESH: ', 'RunDate ' 
                        || to_char(SYSDATE , 'yyyy-Mon-dd hh24:mi:ss'));
  
  delete from ohi_enrollment_products;
  delete from ohi_policy_enrollments;
  delete from ohi_policy_brokers;
  delete from ohi_insured_entities;
  delete from ohi_policyholders;
  delete from ohi_policy_groups;
  delete from ohi_groups;
  delete from ohi_policies;
  delete from ohi_products;
  delete from ohi_enrollment_products_audit;
  delete from ohi_policy_enrollments_audit;
  delete from ohi_policy_brokers_audit;
  delete from ohi_insured_entities_audit;
  delete from ohi_policyholders_audit;
  delete from ohi_policy_groups_audit;
  delete from ohi_groups_audit;
  delete from ohi_policies_audit;
  delete from ohi_products_audit;
   
  EXCEPTION
      WHEN OTHERS THEN
        logger.log_error('Unhandled Exception in OHI_POLICIES_LOAD_PKG.CLEAR_TABLES_AFTER_REFRESH', l_scope, null, l_params);
   
  END CLEAR_TABLES_AFTER_REFRESH;
  
  -- *****************************************************************
  
END OHI_POLICIES_LOAD_PKG;
/