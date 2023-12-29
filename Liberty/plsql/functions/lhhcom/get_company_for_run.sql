create or replace FUNCTION lhhcom.get_company_for_run(
                             p_contribution_date IN DATE
                            ,p_group_code        IN VARCHAR2 
                            ,p_product_code      IN VARCHAR2 
                            ,p_policy_code       IN VARCHAR2 
                            ,p_person_code       IN VARCHAR2
                            ) RETURN NUMBER 
        
RESULT_CACHE RELIES_ON (p_contribution_date,p_product_code,p_policy_code,p_person_code) IS
  l_company_id_no company.company_id_no%TYPE;
BEGIN
          SELECT MAX(company_id_no)
            INTO l_company_id_no
            FROM ohi_policy_brokers      pobr
            JOIN ohi_policies            poli
              ON pobr.poli_id = poli.poli_id
            JOIN ohi_policy_enrollments  poen
              ON pobr.poli_id = poen.poli_id
            JOIN ohi_insured_entities    inse
              ON poen.inse_id = inse.inse_id
            JOIN ohi_enrollment_products poep
              ON poen.poen_id = poep.poen_id
            JOIN ohi_policy_groups       pogr
              ON poli.poli_id = pogr.poli_id
             AND p_contribution_date between pogr.effective_start_date and pogr.effective_end_date
            JOIN ohi_groups              grac
              ON pogr.grac_id = grac.grac_id
            JOIN ohi_products            enpr
              ON poep.enpr_id                 = enpr.enpr_id
           WHERE poli.policy_code             = p_policy_code
             AND inse.inse_code               = p_person_code
             AND poep.poep_id = get_poep_id(p_contribution_date, p_product_code, p_policy_code, p_person_code)
             AND p_contribution_date between pobr.effective_start_date and pobr.effective_end_date
             AND grac.group_code              = p_group_code
             AND enpr.product_code            = p_product_code
           GROUP BY poli.policy_code, inse.inse_code, grac.group_code, enpr.product_code;
  RETURN l_company_id_no;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN 'Failed: Policy - Broker/Company link does not exist for Policy';
  WHEN OTHERS THEN
     RETURN SQLERRM;
END get_company_for_run;