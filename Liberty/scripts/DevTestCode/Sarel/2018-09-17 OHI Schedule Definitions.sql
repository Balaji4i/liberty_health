-- OHI Schedule Definitions
SELECT 
--       *
       ID                         AS schedule_id
      ,code                       AS code
      ,descr                      AS schedule_description
      ,type                       AS type
      ,premium_scope              AS premium_scope
      ,dylo_id_codl               AS condition
      ,surcharge_rule_evaluation  AS surcharge_rule
      ,ind_enabled                AS enabled
  FROM pol_schedule_definitions_v@policies.liberty.co.za
 ORDER BY 4, 5, 2;

