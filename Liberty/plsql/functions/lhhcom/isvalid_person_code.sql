CREATE or REPLACE FUNCTION isvalid_person_code(p_person_code IN ohi_insured_entities.inse_code%TYPE) RETURN VARCHAR2

IS
  lv_inse_id                     ohi_insured_entities.inse_code%TYPE;
  
BEGIN
  lv_inse_id := NULL;
  SELECT MAX(inse_id) INTO lv_inse_id
    FROM ohi_insured_entities
   WHERE inse_code = p_person_code
   GROUP BY inse_code;
  IF lv_inse_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('PERSON_CODE '|| p_person_code || ' does not exist.');
    RETURN 'FALSE';
END isvalid_person_code;