select
       pobr.company_id_no
      ,pobr.broker_id_no
      ,grac.group_code
      ,prod.product_code
      ,poli.policy_code
      ,inse.inse_code
      ,poep.effective_start_date
      ,pobr.pobr_id
      ,grac.grac_id
      ,poen.poli_id
      ,poen.poen_id
      ,inse.inse_id
      ,poep.enpr_id
      ,poep.poep_id
--      ,prod.product_descr
--      ,poep.effective_end_date
  from OHI_INSURED_ENTITIES inse
  left outer 
  join OHI_POLICY_ENROLLMENTS poen
    on poen.inse_id = inse.inse_id
  left outer 
  join OHI_ENROLLMENT_PRODUCTS poep
    on poep.poen_id = poen.poen_id
  left outer 
  join OHI_POLICIES poli
    on poli.poli_id = poen.poli_id
  left outer 
  join OHI_PRODUCTS prod
    on prod.enpr_id = poep.enpr_id
  left outer 
  join OHI_POLICY_GROUPS polgrp
    on polgrp.poli_id = poli.poli_id
  left outer 
  join OHI_GROUPS grac
    on grac.grac_id = polgrp.grac_id
  left outer 
  join OHI_POLICY_BROKERS pobr
    on pobr.poli_id = poli.poli_id
--  where inse.inse_code = '6906745-00';
  where grac.group_code = 'ERICUGANDA';
