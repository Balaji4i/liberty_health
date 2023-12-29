create or replace PACKAGE "COMMISSIONS_COGNOS_PKG" 

AS

/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Cognos Functions to Commissions procedures
*                File Name    : Liberty\plsql\packages\lhhcom\commissions_cognos_pkg.sql
*                Author       : Adriaan Boot
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example below the package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                
*
* </pre>         */

FUNCTION get_comm_percentage
    (p_date           IN  DATE     DEFAULT SYSDATE
    ,p_poep           IN  VARCHAR2 DEFAULT NULL)
    RETURN                ohi_comm_perc.comm_perc%type;


FUNCTION get_poep_id
    (p_date           IN  DATE     DEFAULT SYSDATE
    ,p_person         IN  VARCHAR2 DEFAULT NULL)
    RETURN                ohi_enrollment_products.poep_id%type;

END COMMISSIONS_COGNOS_PKG;
/

CREATE OR REPLACE PACKAGE BODY COMMISSIONS_COGNOS_PKG
/**
  * Contains various functions used by Cognos to call Commissions System procedures
  * */  
-- * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

  AS

FUNCTION get_comm_percentage
                           (p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_poep           IN  VARCHAR2 DEFAULT NULL)
                           RETURN                ohi_comm_perc.comm_perc%type

IS

  v_percentage     ohi_comm_perc.comm_perc%type;
  v_description    ohi_comm_perc.comm_desc%type;
  v_return_msg     VARCHAR2(200);
  
BEGIN
  commissions_pkg.get_percentage (p_date => p_date
                                 ,p_poep => p_poep
                                 ,p_percentage => v_percentage
                                 ,p_description => v_description
                                 ,p_return_msg => v_return_msg);
  RETURN v_percentage;
END get_comm_percentage;

/**********************************************************************************************************************/
FUNCTION get_poep_id
                           (p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_person         IN  VARCHAR2 DEFAULT NULL)
                           RETURN                ohi_enrollment_products.poep_id%type

IS

  v_poep_id     ohi_enrollment_products.poep_id%TYPE;
  v_return_msg  VARCHAR2(500);
  
BEGIN
  commissions_pkg.get_poep_id    (p_date => p_date
                                 ,p_person => p_person
                                 ,p_poep => v_poep_id
                                 ,p_return_msg => v_return_msg);
  RETURN v_poep_id;
END get_poep_id;
/**********************************************************************************************************************/

END COMMISSIONS_COGNOS_PKG;
/