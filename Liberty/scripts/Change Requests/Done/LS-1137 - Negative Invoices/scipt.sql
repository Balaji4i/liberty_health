create or replace FUNCTION get_invoice_hold_reason 
(p_company_id_no IN NUMBER,p_country_code IN VARCHAR2,p_date IN DATE, p_invoice_no IN NUMBER) RETURN VARCHAR2 IS v_char VARCHAR2 (250);
lv_msg            varchar2(250) := null;
lv_ind            varchar2(1)   := null;
ln_company_id_no  company.company_id_no%type;
lv_group_code     ohi_groups.group_code%type;
lv_product_code   ohi_products.product_code%type;
lv_return_msg     varchar2(500);

cursor c_get_company_status is
  select decode(cf.company_table_type_id_no,25,'Y','N') ind, company_table_type_desc
    from company_function cf, company_table_type ctt
   where cf.company_Table_id_no = 2
     and cf.company_id_no = p_company_id_no
     and sysdate between cf.effective_start_date and cf.effective_end_date
     and cf.company_Table_id_no = ctt.company_Table_id_no
     and cf.company_table_type_id_no = ctt.company_table_type_id_no
   order by cf.last_update_datetime desc;

 --group  country hold  
cursor c_get_company_country is
  select hold_ind
    from company_country
   where company_id_no = p_company_id_no
     and country_code = p_country_code;
  
 --does not meet minimum payout amount
cursor c_get_min_pay_out_valid is
  select case
           when sum(id.fee_type_exch_amt) < cc.min_payout_amt then 'N'
         else 
          'Y'
         end ind,
		 i.country_code
    from invoice i, invoice_detail id, company_country cc
   where i.invoice_no = id.invoice_no
     and i.company_id_no = p_company_id_no
     and i. country_code = nvl(p_country_code,i.country_code)
     and i.release_date is null
     and (i.release_hold_reason IS NULL OR i.release_hold_reason like '%Total outstanding payments does not meet the minimum%')
     and i.company_id_no = cc.company_id_no
     and i.country_code = cc.country_code
   group by i.country_code,cc.min_payout_amt; 
   
 --group hold
cursor c_get_ohi_hold is
  select distinct product_code, group_code, company_id_no group_hold
   from comms_calc_snapshot
  where invoice_no = p_invoice_no;
	 
 --SA only needs to have valid accredidation based on contribution date
cursor c_get_accred is
  select 'Y'
    from Company_Accreditation
   where p_date between company_accred_start_date and company_accred_end_date
     and company_id_no = p_company_id_no
     and country_code = p_country_code
	 and accreditation_type_id_no = 1;
  
BEGIN

   open c_get_company_status;
     fetch c_get_company_status into lv_ind, lv_msg;
   close c_get_company_status;
   
   if lv_ind = 'N' then
     v_char := 'Brokerage is currently in '||lv_msg||' status';
   end if;
  
   lv_ind := null;
   lv_msg := null;
   
   open c_get_company_country;
     fetch c_get_company_country into lv_ind;
   close c_get_company_country; 

   if lv_ind = 'Y' then
     v_char := 'Country is currently on hold';
   end if;
   
   lv_ind := null;
   lv_msg := null;
   
   open c_get_ohi_hold;
     fetch c_get_ohi_hold into lv_product_code, lv_group_code, ln_company_id_no;
   close c_get_ohi_hold;
   
   --check product_code
   if lv_product_code is not null and lv_group_code is not null then
    commissions_pkg.get_hold_ind (p_date => trunc(sysdate)
                                 ,p_company => null
                                 ,p_broker => null
                                 ,p_group => lv_group_code
                                 ,p_product => lv_product_code
                                 ,p_policy => null
                                 ,p_person => null
                                 ,p_poep => null
                                 ,p_hold_ind => lv_ind
                                 ,p_hold_reason => lv_msg
                                 ,p_return_msg => lv_return_msg);  
    end if;

    if lv_ind IS NOT NULL  then   
	   v_char := lv_msg;
	end if;
   --check group_code
   if lv_group_code is not null then
    commissions_pkg.get_hold_ind (p_date => trunc(sysdate)
                                 ,p_company => null
                                 ,p_broker => null
                                 ,p_group => lv_group_code
                                 ,p_product => null
                                 ,p_policy => null
                                 ,p_person => null
                                 ,p_poep => null
                                 ,p_hold_ind => lv_ind
                                 ,p_hold_reason => lv_msg
                                 ,p_return_msg => lv_return_msg) ; 
    end if;
	
    if lv_ind IS NOT NULL  then   
	   v_char := lv_msg;
	end if;   
   --check company
   if ln_company_id_no is not null then
    commissions_pkg.get_hold_ind (p_date => trunc(sysdate)
                                 ,p_company => ln_company_id_no
                                 ,p_broker => null
                                 ,p_group => null
                                 ,p_product => null
                                 ,p_policy => null
                                 ,p_person => null
                                 ,p_poep => null
                                 ,p_hold_ind => lv_ind
                                 ,p_hold_reason => lv_msg
                                 ,p_return_msg => lv_return_msg);
    end if;
	
    if lv_ind IS NOT NULL  then   
	   v_char := lv_msg;
	end if;
	
   lv_ind := null;
   lv_msg := null;
   
   open c_get_min_pay_out_valid;
     fetch c_get_min_pay_out_valid into lv_ind,lv_msg;
   close c_get_min_pay_out_valid;
  
   if lv_ind = 'N' then --The cursor can return Y,N or nothing, therefore check if the lv_ind = 'N'. Otherwise if the cursor returns nothing, the check will still occur
     v_char := 'Total outstanding payments does not meet the minimum payout amount for country '||lv_msg; 
   end if;     
   
   lv_ind := null;
   lv_msg := null;
   if p_country_code = 'ZA' then
     open c_get_accred;
	   fetch c_get_accred into lv_ind;
     close c_get_accred;
	 
	 if lv_ind <> 'Y' then   --The cursor only returns a Y or nothing, therefore check if the lv_ind <> 'Y'.
	   v_char := 'Brokerage does not have a valid accreditation';
	 end if;
   end if;
   
  RETURN v_char;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
   v_char := NULL;
END;