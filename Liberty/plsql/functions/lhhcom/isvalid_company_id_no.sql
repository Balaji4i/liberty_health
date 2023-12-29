CREATE or REPLACE FUNCTION isvalid_company_id_no(p_company_id_no IN company.company_id_no%TYPE) RETURN VARCHAR2

IS
  lv_comp_id                     company.company_id_no%TYPE;
  
BEGIN
  lv_comp_id := NULL;
  SELECT MAX(company_id_no) INTO lv_comp_id
    FROM company
   WHERE company_id_no = p_company_id_no
   GROUP BY company_id_no;
  IF lv_comp_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('COMPANY_ID_NO '|| p_company_id_no || ' does not exist.');
    RETURN 'FALSE';
END isvalid_company_id_no;