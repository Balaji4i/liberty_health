CREATE OR REPLACE PACKAGE "LHHCOM"."DNLD_TRN_FUSION_PKG" AS 
/*****************************************************************************************************************
Description  : Package contains procedures to generate datalines for interfaces 
Author       : Jaco Bosman
Requirements : 
Amendments   : 
Date        User     Change Description
========   ======== =================================================

*******************************************************************************************************************/
procedure dnld_broker (pn_min_batch_no in number,pn_max_batch_no in number);
procedure dnld_company_address (pn_min_batch_no in number,pn_max_batch_no in number);
procedure dnld_company_contact (pn_min_batch_no in number,pn_max_batch_no in number);
procedure dnld_all;
END DNLD_TRN_FUSION_PKG;

/

--------------------------------------------------------
--  DDL for Package Body DNLD_TRN_FUSION_PKG
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY "LHHCOM"."DNLD_TRN_FUSION_PKG" AS
ln_interf_system_id_no   util.interf_system.interf_system_id_no%type := 1;
lv_username              varchar2(50)                           := 'dnld_all';

/**********************************************************************************************************************************/
procedure dnld_broker (pn_min_batch_no in number,pn_max_batch_no in number) is
lu_dnld_file         utl_file.file_type;
lv_file_name         varchar2(100) := 'supplier_import_template'||to_char(sysdate,'yyyymmddhhmiss')||'.csv';

cursor c_dnld_brokers is
  select dataline
    from dnld_trn
  where interf_system_id_no = ln_interf_system_id_no
    and trn_type_no = 1
    and batch_no between pn_min_batch_no and pn_max_batch_no
  order by dnld_trn_no, detail_seq_no;
  

begin

    lu_dnld_file := utl_file.fopen('UTL_DIR',lv_file_name,'w');
	
	for x in c_dnld_brokers loop
      utl_file.put_line(lu_dnld_file,x.dataline);
	end loop;
	
	utl_file.fclose(lu_dnld_file);

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
end;
/**********************************************************************************************************************************/
procedure dnld_company_address (pn_min_batch_no in number,pn_max_batch_no in number) is
lu_dnld_file         utl_file.file_type;
lv_file_name         varchar2(200) := 'supplier_address_import_template'||to_char(sysdate,'yyyymmddhhmiss')||'.csv';

cursor c_dnld_brokers is
  select dataline
    from dnld_trn
  where interf_system_id_no = ln_interf_system_id_no
    and trn_type_no = 5
    and batch_no between pn_min_batch_no and pn_max_batch_no
  order by dnld_trn_no, detail_seq_no;
  

begin

    lu_dnld_file := utl_file.fopen('UTL_DIR',lv_file_name,'w');
	
	for x in c_dnld_brokers loop
      utl_file.put_line(lu_dnld_file,x.dataline);
	end loop;
	
	utl_file.fclose(lu_dnld_file);

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
end;
/**********************************************************************************************************************************/
procedure dnld_company_contact (pn_min_batch_no in number,pn_max_batch_no in number) is
lu_dnld_file         utl_file.file_type;
lv_file_name         varchar2(200) := 'supplier_contact_import_template'||to_char(sysdate,'yyyymmddhhmiss')||'.csv';

cursor c_dnld_brokers is
  select dataline
    from dnld_trn
  where interf_system_id_no = ln_interf_system_id_no
    and trn_type_no = 4
    and batch_no between pn_min_batch_no and pn_max_batch_no
  order by dnld_trn_no, detail_seq_no;
  

begin

    lu_dnld_file := utl_file.fopen('UTL_DIR',lv_file_name,'w');
	
	for x in c_dnld_brokers loop
      utl_file.put_line(lu_dnld_file,x.dataline);
	end loop;
	
	utl_file.fclose(lu_dnld_file);

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
end;
/**********************************************************************************************************************************/
procedure dnld_all is
   ln_min_batch_no        util.dnld_batch.batch_no%type;
   ln_max_batch_no        util.dnld_batch.batch_no%type;
   
  cursor c_batch_no is
    select min(batch_no), max(batch_no)
      from util.dnld_batch
     where process_datetime is null;
     
begin
  
  open c_batch_no;
    fetch c_batch_no into ln_min_batch_no, ln_max_batch_no;
  close c_batch_no;
  
  dnld_broker(ln_min_batch_no, ln_max_batch_no);
  dnld_company_address(ln_min_batch_no, ln_max_batch_no);
  dnld_company_contact(ln_min_batch_no, ln_max_batch_no);
  
  update util.dnld_batch
     set process_datetime = sysdate,
	     last_update_datetime = sysdate,
		 username = lv_username
     where process_datetime is null;
	   
  commit;

exception
  when others then
    rollback;
    dbms_output.put_line(sqlerrm);
	raise;
end;
END DNLD_TRN_FUSION_PKG;

/
