/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Get Correspondence Contact for a Company
*                File Name    : Liberty\plsql\procedures\lhhcom\get_corr_contact_prc.sql
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
    PROCEDURE get_corr_contact (p_company        IN  NUMBER   DEFAULT NULL
                               ,p_date           IN  DATE     DEFAULT SYSDATE
                               ,p_name          OUT VARCHAR2
                               ,p_cell          OUT VARCHAR2
                               ,p_email         OUT VARCHAR2
                               ,p_fax           OUT VARCHAR2
                               ,p_tel           OUT VARCHAR2
                               ,p_return_msg    OUT VARCHAR2)

IS

  p_date_in  DATE;
  CURSOR get_contact IS
    SELECT
           NVL(ccon.contact_name, ' ')         contact_name
          ,NVL(ccon.contact_cellphone_no, ' ') contact_cellphone
          ,NVL(ccon.contact_email, ' ')        contact_email
          ,NVL(ccon.contact_fax_no, ' ')       contact_fax
          ,NVL(ccon.contact_telephone_no, ' ') contact_tel
      FROM lhhcom.company_contact ccon
     WHERE ccon.company_id_no = p_company
       AND ccon.company_contact_type_id_no = '3'
       AND p_date_in BETWEEN ccon.effective_start_date and ccon.effective_end_date;

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
  p_name          := NULL;
  p_cell          := NULL;
  p_email         := NULL;
  p_fax           := NULL;
  p_tel           := NULL;
  p_return_msg    := NULL;
  OPEN get_contact;
  FETCH get_contact
    INTO
         p_name
        ,p_cell
        ,p_email
        ,p_fax
        ,p_tel;
  CLOSE get_contact;
  p_return_msg    := 'SUCCESS: Company (' || p_company || ') and date (' || p_date_in || ') returned a Corresopndence Contact';
  RETURN;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    CLOSE get_contact;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned no Corresopndence Contact');
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned no Corresopndence Contact';
  WHEN TOO_MANY_ROWS THEN
    CLOSE get_contact;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned more than one Corresopndence Contact');
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned more than one Corresopndence Contact';
  WHEN OTHERS THEN
    CLOSE get_contact;
    dbms_output.put_line('ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned an unexpected error: ' || sqlerrm);
    p_return_msg := 'ERROR: Company (' || p_company || ') and date (' || p_date_in || ') returned an unexpected error: ' || sqlerrm;
 
END get_corr_contact;

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
  get_corr_contact(10000061, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
  get_corr_contact(774000000, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
  get_corr_contact(832000015, NULL, lv_return1, lv_return2, lv_return3, lv_return4, lv_return5, lv_return_msg);
  dbms_output.put_line('  Message: ' || lv_return_msg || '
    Line1: ' || lv_return1 || '
    Line2: ' || lv_return2 || '
    Line3: ' || lv_return3 || '
    Line4: ' || lv_return4 || '
    Line5: ' || lv_return5 );
END;
*/