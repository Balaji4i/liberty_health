SELECT poli.code,
       calc_result.poli_id, calc_result.cape_id, 
       calc_result.total_base_premium, calc_result.total_adjustment, 
       calc_result.total_result, calc_result.total_surcharge, 
       calc_result.curr_id_total_result,
       cape.start_date, cape.end_date,
       capetl.display_name FROM 
 (SELECT policy_gid, cape_id, MAX(VERSION) version_max
   FROM ohi_policies_owner.pol_calculation_results cres
     GROUP BY policy_gid, cape_id) calc_result_unq,
     ohi_policies_owner.pol_calculation_results calc_result,
     ohi_policies_owner.pol_calculation_periods_b cape, 
     ohi_policies_owner.pol_calculation_periods_tl capetl,
     ohi_policies_owner.pol_policies poli
       WHERE calc_result.policy_gid = calc_result_unq.policy_gid AND
             calc_result.cape_id = calc_result_unq.cape_id AND
             calc_result.VERSION = calc_result_unq.version_max AND
             calc_result.cape_id = cape.ID AND
             cape.ID = capetl.base_table_id AND
             capetl.language = 'en' AND
             calc_result.poli_id = poli.id
      ORDER by cape.start_date;
