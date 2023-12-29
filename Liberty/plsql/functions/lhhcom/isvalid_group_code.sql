CREATE or REPLACE FUNCTION isvalid_group_code(p_group_code IN ohi_groups.group_code%TYPE) RETURN VARCHAR2

IS
  lv_grac_id                     ohi_groups.group_code%TYPE;
  
BEGIN
  lv_grac_id := NULL;
  SELECT MAX(grac_id) INTO lv_grac_id
    FROM ohi_groups
   WHERE group_code = p_group_code
   GROUP BY group_code;
  IF lv_grac_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('GROUP_CODE '|| p_group_code || ' does not exist.');
    RETURN 'FALSE';
END isvalid_group_code;