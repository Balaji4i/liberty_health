define p_date = '01/DEC/2017';
define p_param = '(76620)';
SELECT 
       CASE WHEN pobr.pobr_id        IS  NULL THEN NULL
            WHEN comp.company_id_no  IS  NULL THEN NULL
            WHEN poepcp.comm_perc IS NOT NULL THEN poepcp.comm_perc
            WHEN insecp.comm_perc IS NOT NULL THEN insecp.comm_perc
            WHEN policp.comm_perc IS NOT NULL THEN policp.comm_perc
            WHEN grprcp.comm_perc IS NOT NULL THEN grprcp.comm_perc
            WHEN graccp.comm_perc IS NOT NULL THEN graccp.comm_perc
            WHEN brokcp.comm_perc IS NOT NULL THEN brokcp.comm_perc
            WHEN compcp.comm_perc IS NOT NULL THEN compcp.comm_perc
            ELSE NULL
       END FINAL_COMM_PERC
      ,CASE WHEN pobr.pobr_id        IS  NULL THEN 'No Policy - Broker Link found'
            WHEN comp.company_id_no  IS  NULL THEN 'No Valid Company found'
            WHEN poepcp.comm_perc IS NOT NULL THEN 'POEP Id ' || poepcp.poep_id
            WHEN insecp.comm_perc IS NOT NULL THEN 'Person Code ' || insecp.inse_code
            WHEN policp.comm_perc IS NOT NULL THEN 'Policy Code ' || policp.policy_code
            WHEN grprcp.comm_perc IS NOT NULL THEN 'Group Code ' || grprcp.group_code || ', Product Code ' || grprcp.product_code
            WHEN graccp.comm_perc IS NOT NULL THEN 'Group Code ' || graccp.group_code
            WHEN brokcp.comm_perc IS NOT NULL THEN 'Broker ID ' || brokcp.broker_id_no
            WHEN compcp.comm_perc IS NOT NULL THEN 'Company ID ' || compcp.company_id_no
            ELSE NULL
       END DERIVED_FROM
      ,to_date('&&p_date', 'DD/MON/YYYY') P_DATE
      ,poep.poep_id       POEP_ID
      ,poepcp.comm_perc   POEP_PERC
      ,inse.inse_id       INSE_ID
      ,insecp.comm_perc   INSE_PERC
      ,poli.poli_id       POLI_ID
      ,policp.comm_perc   POLI_PERC
      ,grac.grac_id       GRAC_ID
      ,enpr.enpr_id       ENPR_ID
      ,grprcp.comm_perc   GRPR_PERC
      ,graccp.comm_perc   GRAC_PERC
      ,pobr.pobr_id       POBR_ID
      ,brok.broker_id_no  BROK_ID
      ,brokcp.comm_perc   BROK_PERC
      ,comp.company_id_no COMP_ID
      ,compcp.comm_perc   COMP_PERC
  FROM 
       lhhcom.ohi_enrollment_products     poep
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               poepcp
    ON     poepcp.product_code  IS NULL
       AND poepcp.poep_id       = poep.poep_id
       AND poepcp.inse_code     IS NULL
       AND poepcp.policy_code   IS NULL
       AND poepcp.group_code    IS NULL
       AND poepcp.broker_id_no  IS NULL
       AND poepcp.company_id_no IS NULL
       AND poepcp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     poepcp.effective_start_date 
                                                      AND poepcp.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_policy_enrollments      poen
    ON     poep.poen_id = poen.poen_id
  LEFT OUTER
  JOIN lhhcom.ohi_insured_entities        inse
    ON     poen.inse_id = inse.inse_id
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               insecp
    ON     insecp.product_code  IS NULL
       AND insecp.poep_id       IS NULL
       AND insecp.inse_code     = inse.inse_code
       AND insecp.policy_code   IS NULL
       AND insecp.group_code    IS NULL
       AND insecp.broker_id_no  IS NULL
       AND insecp.company_id_no IS NULL
       AND insecp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     insecp.effective_start_date 
                                                      AND insecp.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_policies                poli
    ON     poen.poli_id = poli.poli_id
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               policp
    ON     policp.product_code  IS NULL
       AND policp.poep_id       IS NULL
       AND policp.inse_code     IS NULL
       AND policp.policy_code   = poli.policy_code
       AND policp.group_code    IS NULL
       AND policp.broker_id_no  IS NULL
       AND policp.company_id_no IS NULL
       AND policp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     policp.effective_start_date 
                                                      AND policp.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_policy_groups           pogr
    ON     poli.poli_id = pogr.poli_id
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     pogr.effective_start_date 
                                                      AND pogr.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_groups                  grac
    ON     pogr.grac_id = grac.grac_id
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     grac.effective_start_date 
                                                      AND grac.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_products                enpr
    ON     poep.enpr_id = enpr.enpr_id
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               grprcp
    ON     grprcp.product_code  = enpr.product_code
       AND grprcp.poep_id       IS NULL
       AND grprcp.inse_code     IS NULL
       AND grprcp.policy_code   IS NULL
       AND grprcp.group_code    = grac.group_code
       AND grprcp.broker_id_no  IS NULL
       AND grprcp.company_id_no IS NULL
       AND grprcp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     grprcp.effective_start_date 
                                                      AND grprcp.effective_end_date
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               graccp
    ON     graccp.product_code  IS NULL
       AND graccp.poep_id       IS NULL
       AND graccp.inse_code     IS NULL
       AND graccp.policy_code   IS NULL
       AND graccp.group_code    = grac.group_code
       AND graccp.broker_id_no  IS NULL
       AND graccp.company_id_no IS NULL
       AND graccp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     graccp.effective_start_date 
                                                      AND graccp.effective_end_date
  LEFT OUTER
  JOIN lhhcom.ohi_policy_brokers          pobr
    ON     poli.poli_id = pobr.poli_id
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     pobr.effective_start_date 
                                                      AND pobr.effective_end_date
  LEFT OUTER 
  JOIN lhhcom.broker                      brok
    ON     pobr.broker_id_no = brok.broker_id_no
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               brokcp
    ON     brokcp.product_code  IS NULL
       AND brokcp.poep_id       IS NULL
       AND brokcp.inse_code     IS NULL
       AND brokcp.policy_code   IS NULL
       AND brokcp.group_code    IS NULL
       AND brokcp.broker_id_no  = brok.broker_id_no
       AND brokcp.company_id_no IS NULL
       AND brokcp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     brokcp.effective_start_date 
                                                      AND brokcp.effective_end_date
  LEFT OUTER 
  JOIN lhhcom.company                     comp
    ON     nvl(brok.company_id_no, pobr.company_id_no) = comp.company_id_no
  LEFT OUTER 
  JOIN lhhcom.ohi_comm_perc               compcp
    ON     compcp.product_code  IS NULL
       AND compcp.poep_id       IS NULL
       AND compcp.inse_code     IS NULL
       AND compcp.policy_code   IS NULL
       AND compcp.group_code    IS NULL
       AND compcp.broker_id_no  IS NULL
       AND compcp.company_id_no = comp.company_id_no
       AND compcp.auth_username IS NOT NULL
       AND to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     compcp.effective_start_date 
                                                      AND compcp.effective_end_date
 WHERE     to_date('&&p_date', 'DD/MON/YYYY') BETWEEN     poep.effective_start_date 
                                                      AND poep.effective_end_date
       AND poep.poep_id IN &&p_param;
--       AND nvl(NULL, poep.poep_id)     = poep.poep_id
--       AND nvl(NULL, inse.inse_id)     = inse.inse_id
--       AND nvl(NULL, inse.inse_code)   = inse.inse_code
--       AND nvl(NULL, inse.inse_id)      IN &&p_param;
--       AND nvl(NULL, poli.poli_id)      IN &&p_param;
--       AND nvl('6756948', poli.policy_code) = poli.policy_code;