CREATE or REPLACE FUNCTION get_poep_id
                           (p_date           IN  DATE     DEFAULT SYSDATE
                           ,p_product        IN  VARCHAR2 DEFAULT NULL
                           ,p_policy         IN  VARCHAR2 DEFAULT NULL
                           ,p_person         IN  VARCHAR2 DEFAULT NULL)
                           RETURN                ohi_enrollment_products.poep_id%type

IS

  v_poep_id     ohi_enrollment_products.poep_id%TYPE;
  v_return_msg  VARCHAR2(500);
  
BEGIN
  commissions_pkg.get_poep_id    (p_date => p_date
                                 ,p_product => p_product
                                 ,p_policy => p_policy
                                 ,p_person => p_person
                                 ,p_poep => v_poep_id
                                 ,p_return_msg => v_return_msg);
  RETURN v_poep_id;
END get_poep_id;
/