CREATE or REPLACE FUNCTION isvalid_broker_id_no(p_broker_id_no IN broker.broker_id_no%TYPE) RETURN VARCHAR2

IS
  lv_brok_id                     broker.broker_id_no%TYPE;
  
BEGIN
  lv_brok_id := NULL;
  SELECT MAX(broker_id_no) INTO lv_brok_id
    FROM broker
   WHERE broker_id_no = p_broker_id_no
   GROUP BY broker_id_no;
  IF lv_brok_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('BROKER_ID_NO '|| p_broker_id_no || ' does not exist.');
    RETURN 'FALSE';
END isvalid_broker_id_no;