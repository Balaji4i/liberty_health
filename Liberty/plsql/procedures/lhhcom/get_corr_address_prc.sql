/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Get Correspondence Address for a Company
*                File Name    : Liberty\plsql\procedures\lhhcom\get_corr_address_prc.sql
*                Author       : Sarel Eybers
*                Requirements : Access to account SCHEMA
*                Call Syntax  : Anonymous Block Example at the end
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2018/09/12  Sarel    Created the Procedure
*
* </pre>         */

CREATE OR REPLACE
    PROCEDURE get_corr_address (p_company        IN  NUMBER   DEFAULT NULL
                               ,p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_address_line1 OUT VARCHAR2
                               ,p_address_line2 OUT VARCHAR2
                               ,p_address_line3 OUT VARCHAR2
                               ,p_postal_code   OUT VARCHAR2
                               ,p_country_code  OUT VARCHAR2
                               ,p_return_msg    OUT VARCHAR2)

IS

  p_date_in  DATE;
  CURSOR get_address IS
    SELECT
           NVL(cadr.address_line1, ' ')        address_line1
          ,NVL(cadr.address_line2, ' ')        address_line2
          ,NVL(cadr.address_line3, ' ')        address_line3
          ,NVL(cadr.postal_code, ' ')          postal_code
          ,NVL(cadr.address_country_code, ' ') country_code
      FROM lhhcom.company_address cadr
     WHERE cadr.company_id_no = p_company
       AND cadr.address_type_code = 'C'
       AND p_date_in BETWEEN cadr.effective_start_date and cadr.effective_end_date;

BEGIN
  IF p_company is NULL THEN
    p_return_msg  := 'ERROR: Company (' || p_company || ') cannot be NULL';
    RETURN;
  END IF;
  IF p_date is NULL THEN
    p_date_in     := SYSDATE;
  ELSE
    p_date_in     := p_date;
  END IF;
  p_address_line1 := NULL;
  p_address_line2 := NULL;
  p_address_line3 := NULL;
  p_postal_code   := NULL;
  p_country_code  := NULL;
  p_return_msg    := NULL;
  OPEN get_address;
  FETCH get_address
    INTO
         p_address_line1
        ,p_address_line2
        ,p_address_line3
        ,p_postal_code
        ,p_country_code;
  CLOSE get_address;
  p_return_msg    := 'SUCCESS: Company (' || p_company || ') and date (' || p_date_in || ') returned a Corresopndence Address';
  RETURN;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CLOSE get_address;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned no Corresopndence Address');
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned no Corresopndence Address';
  WHEN TOO_MANY_ROWS THEN
    CLOSE get_address;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned more than one Corresopndence Address');
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned more than one Corresopndence Address';
  WHEN OTHERS THEN
    CLOSE get_address;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned an unexpected error: ' || sqlerrm);
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned an unexpected error: ' || sqlerrm;
 
END get_corr_address;

/*
-- Call the procedure to report the address
set serveroutput on;
DECLARE
  lv_return1         VARCHAR2(500);
  lv_return2         VARCHAR2(500);
  lv_return3         VARCHAR2(500);
  lv_return4         VARCHAR2(500);
  lv_return5         VARCHAR2(500);
  lv_return_msg      VARCHAR2(500);
BEGIN
  get_corr_address(740000000, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
END;
*/