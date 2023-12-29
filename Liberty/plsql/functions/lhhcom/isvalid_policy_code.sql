CREATE or REPLACE FUNCTION isvalid_policy_code(p_policy IN ohi_policies.policy_code%TYPE) RETURN VARCHAR2

IS
  lv_poli_id                     ohi_policies.poli_id%TYPE;
  
BEGIN
  lv_poli_id := NULL;
  SELECT MAX(poli_id) INTO lv_poli_id
    FROM ohi_policies
   WHERE policy_code = p_policy
   GROUP BY policy_code;
  IF lv_poli_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('POLICY_CODE '|| p_policy || ' does not exist.');
    RETURN 'FALSE';
END isvalid_policy_code;