/**
* ----------------------------------------------------------------------
* Change Request: Implement Payment Currency (Comms Calc Snapshot) 
*                 into Recalc Procedure in COMMS_CALC_PKG package
*                 Enhance COMMS_RECALC procedure to take the latest POEP ID into account 
*                 (LS-994)
*
* Description  : Find and use the latest/newest POEP_ID when doing a Recalc
*                Add the code for updating the Payment Currency to RECALC
* Author       : Sarel Eybers
* Date         : 2018-03-14
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Compile Package
*   2) Fix COMMS_CALC_SNAPSHOT data
*   3) Ad Hoc Code
*                */

--  1) Compile Package

@../../../../plsql/packages/lhhcom/comms_calc_pkg.sql;

--  2) Fix COMMS_CALC_SNAPSHOT data

MERGE INTO comms_calc_snapshot ccs
  USING
    (SELECT DISTINCT ccs.poep_id      poep_id
                    ,inse.inse_code   inse_code
                    ,poli.policy_code policy_code
       FROM comms_calc_snapshot          ccs
       JOIN ohi_enrollment_products      poep
         ON poep.poep_id = ccs.poep_id
       JOIN ohi_policy_enrollments       poen
         ON poep.poen_id = poen.poen_id
       JOIN ohi_insured_entities         inse
         ON inse.inse_id = poen.inse_id
       JOIN ohi_policies                 poli
         ON poli.poli_id = poen.poli_id
      WHERE ccs.person_code != inse.inse_code
        OR ccs.policy_code != poli.policy_code
    ) rec
  ON (ccs.poep_id = rec.poep_id)
  WHEN MATCHED THEN UPDATE
    SET person_code = rec.inse_code,
        policy_code = rec.policy_code
  WHERE ccs.person_code != rec.inse_code
     OR ccs.policy_code != rec.policy_code;
     
COMMIT;

--  3) Ad Hoc Code

/*
  Nothing here . . . Now

-- Affected records
SELECT ccs.poep_id, ccs.person_code, inse.inse_code, ccs.policy_code, poli.policy_code
  FROM comms_calc_snapshot          ccs
  JOIN ohi_enrollment_products      poep
    ON poep.poep_id = ccs.poep_id
  JOIN ohi_policy_enrollments       poen
    ON poep.poen_id = poen.poen_id
  JOIN ohi_insured_entities         inse
    ON inse.inse_id = poen.inse_id
  JOIN ohi_policies                 poli
    ON poli.poli_id = poen.poli_id
 WHERE  ccs.person_code != inse.inse_code
    OR ccs.policy_code != poli.policy_code;
--   AND ccs.poep_id = 8024;
    inse.inse_code = '5133394-00';

-- Old less efficient update statement
UPDATE comms_calc_snapshot                               ccs
  SET  person_code = (SELECT inse_code
                        FROM ohi_enrollment_products      poep
                        JOIN ohi_policy_enrollments       poen
                          ON poep.poen_id = poen.poen_id
                        JOIN ohi_insured_entities         inse
                          ON inse.inse_id = poen.inse_id
                       WHERE poep.poep_id = ccs.poep_id),
       policy_code = (SELECT policy_code
                        FROM ohi_enrollment_products      poep
                        JOIN ohi_policy_enrollments       poen
                          ON poep.poen_id = poen.poen_id
                        JOIN ohi_policies                 poli
                          ON poli.poli_id = poen.poli_id
                       WHERE poep.poep_id = ccs.poep_id)
 WHERE ccs.policy_code = '0';
--   AND ccs.poep_id = 8024;

select COMMS_RECALC.poep_id as CR_Poep, OHI_ENROLLMENT_PRODUCTS.poep_id as OHI_POEP, 
       get_poep_id(p_date => EFFECTIVE_START_DATE, p_person => inse_code) as NEW_POEP,
       EFFECTIVE_START_DATE, description, 
       get_comm_percentage(p_poep => COMMS_RECALC.poep_id, p_date => EFFECTIVE_START_DATE) as Percent,
       get_comm_percentage(p_poep => get_poep_id(p_date => EFFECTIVE_START_DATE, p_person => inse_code), p_date => EFFECTIVE_START_DATE) as New_Percent
    from COMMS_RECALC
    LEFT OUTER
    JOIN OHI_ENROLLMENT_PRODUCTS
      ON COMMS_RECALC.poep_id = OHI_ENROLLMENT_PRODUCTS.poep_id
    LEFT OUTER
    JOIN OHI_POLICY_ENROLLMENTS
      ON OHI_POLICY_ENROLLMENTS.poen_id = OHI_ENROLLMENT_PRODUCTS.poen_id
    LEFT OUTER
    JOIN OHI_INSURED_ENTITIES
      ON OHI_POLICY_ENROLLMENTS.inse_id = OHI_INSURED_ENTITIES.inse_id
    where processed_date = '10/SEP/57';

*/