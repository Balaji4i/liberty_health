UPDATE company comp
   set comp.effective_Start_Date = (SELECT MIn(effective_start_datE) from company_country where company_id_no = comp.company_id_no)
where comp.effective_start_date is null;
/
commit;