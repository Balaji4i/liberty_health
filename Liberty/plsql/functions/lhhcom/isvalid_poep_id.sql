CREATE or REPLACE FUNCTION isvalid_poep_id(p_poep_id IN ohi_enrollment_products.poep_id%TYPE) RETURN VARCHAR2

IS
  lv_poep_id                     ohi_enrollment_products.poep_id%TYPE;
  
BEGIN
  lv_poep_id := NULL;
  SELECT MAX(poep_id) INTO lv_poep_id
    FROM ohi_enrollment_products
   WHERE poep_id = p_poep_id
   GROUP BY poep_id;
  IF lv_poep_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('POEP_ID '|| p_poep_id || ' does not exist.');
    RETURN 'FALSE';
END isvalid_poep_id;