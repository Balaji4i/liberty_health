CREATE or REPLACE FUNCTION isvalid_product_code(p_product_code IN ohi_products.product_code%TYPE) RETURN VARCHAR2

IS
  lv_enpr_id                     ohi_products.product_code%TYPE;
  
BEGIN
  lv_enpr_id := NULL;
  SELECT MAX(enpr_id) INTO lv_enpr_id
    FROM ohi_products
   WHERE product_code = p_product_code
   GROUP BY product_code;
  IF lv_enpr_id > 0 THEN
    RETURN 'TRUE';
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('PRODUCT_CODE '|| p_product_code || ' does not exist.');
    RETURN 'FALSE';
END isvalid_product_code;