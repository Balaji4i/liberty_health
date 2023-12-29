select --* --clm.id, clm.created_by, usr.display_name--, hist.clai_id, hist.last_updated_by 
       usr.display_name
      ,clm.code
      ,clm.type
      ,clm.status
      ,clm.entry_date
      ,clm.receipt_date
      ,clm.creation_date
      ,clm.last_updated_date
      ,clm.total_claimed_amount
      ,clm.total_covered_amount
      ,clm.total_allowed_amount
      ,hist.creation_date
      ,usra.display_name
      ,hist.status
from OHI_CLAIMS_OWNER.CLA_CLAIMS clm
left outer join OHI_CLAIMS_OWNER.OHI_USERS usr
on (clm.created_by = usr.id)
join OHI_CLAIMS_OWNER.CLA_CLAIM_STATUS_HISTORY hist
on (clm.id = hist.clai_id)
left outer join OHI_CLAIMS_OWNER.OHI_USERS usra
on (hist.created_by = usra.id)
where 1=1
  and clm.created_by in (5891, 5571, 12741)
  and clm.last_updated_date > to_date('2021-05-13', 'YYYY-MM-DD')
  and clm.last_updated_date < to_date('2021-05-14', 'YYYY-MM-DD')
--  and clm.code IN ('CLM2377866', 'CLM2377868', 'CLM2377873')
--  and clm.id = hist.clai_id
--  and clm.created_by = hist.last_updated_by
--  and hist.last_updated_by <> 10;
--  and hist.last_updated_by <> clm.created_by
order by 1, 2, 12;

select * from OHI_CLAIMS_OWNER.CLA_CLAIM_STATUS_HISTORY
where clai_id = 2345425;