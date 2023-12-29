Select *
From lhhcom.ohi_enrollment_products poep
left outer
join lhhcom.ohi_policy_enrollments  poen
  on poep.poen_id = poen.poen_id
left outer
join lhhcom.ohi_products            enpr
  on poep.enpr_id = enpr.enpr_id
left outer
join lhhcom.ohi_policies            poli
  on poen.poli_id = poli.poli_id
left outer
join lhhcom.ohi_policy_brokers      pobr
  on pobr.poli_id = poli.poli_id
where poep.poep_id = 40288;
