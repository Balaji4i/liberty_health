/**
* ----------------------------------------------------------------------
* Change Request: Enable Company Country Correspondence Template (LS-1342)
*
* Description  : Insert a record into the table so the option becomes available to the users
* Author       : Sarel Eybers
* Date         : 2018-06-08
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Update Company_address table with country and address country (null Country not allowed)
*  99) Ad Hoc Comments and Code
*                */

--  1) Update Company Address table - Tanya has this script
    
--COMMIT;
@../../../../plsql/packages/lhhcom/commissions_pkg.sql;
@../../../../plsql/procedures/lhhcom/get_corr_address_prc.sql;
@../../../../plsql/procedures/lhhcom/get_corr_contact_prc.sql;
@../../../../plsql/functions/lhhcom/get_comp_template.sql;

GRANT EXECUTE ON LHHCOM.get_comp_template TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_address TO LHHCORR;
GRANT EXECUTE ON LHHCOM.get_corr_contact TO LHHCORR;
/


-- 99) Ad Hoc Comments and Code
/*
Which template to use?
  Users will capture the country code in ADDRESS_COUNTRY_CODE on COMPANY_ADDRESS (the address tab on Maintain Brokerage)
  Currently there are templates for LS, UG and ZA
  Suzette will use this value to determine which letterhead.

Which Brokerage Address to use on the letter?
  We'll add a new Brokerage Table Type (like on Dev) for "Correspondence Country Address to use" (not final wording)
  Then we'll add valid values per country
  Users will capture/maintain which country address contains the address to be used and the country template to be used under "Current Attributes" on Maintain Brokerage (check Dev)
  Suzette Van Rensburg will use this code to determing which address and which template to use . . .

<snip>
select comp.company_id_no, comptt.COMPANY_TABLE_ID_NO, comptt.COMPANY_TABLE_TYPE_ID_NO, COMPANY_TABLE_TYPE_DESC, compa.ADDRESS_LINE3, compa.ADDRESS_COUNTRY_CODE
  from company comp
  join company_function compf
    on comp.company_id_no = compf.company_id_no
   and compf.COMPANY_TABLE_ID_NO = 7
  join company_table_type comptt
    on compf.COMPANY_TABLE_ID_NO = comptt.COMPANY_TABLE_ID_NO
   and compf.COMPANY_TABLE_TYPE_ID_NO = comptt.COMPANY_TABLE_TYPE_ID_NO
  join company_address compa
    on compa.company_id_no = comp.company_id_no
   and compa.country_code = comptt.COMPANY_TABLE_TYPE_DESC
   and compa.ADDRESS_TYPE_CODE = 'C'
   and SYSDATE BETWEEN compa.effective_start_date and compa.effective_end_date
 where comp.company_id_no = 10000061
   and SYSDATE BETWEEN comptt.effective_start_date and comptt.effective_end_date;
</snip>

Currently there are templates for LS, UG and ZA

Some other ADF things for Sarel to do . . . 
  Add ADDRESS_COUNTRY_CODE to Current Address page on Maintain brokerage
  Check that Country Code filters through to Current Address
  Maybe . . . Add validation to Broker Communication to inform users which address and which template will be used.
*/
