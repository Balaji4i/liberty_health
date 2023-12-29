CREATE OR REPLACE package comms_comm_hub_pkg as 
/**
* <pre>
* ----------------------------------------------------------------------
* Project:     : Commission Self Build
*
*                Description  : Procedures and Functions used by the Commission Self Build project
*                Author       : Jaco Bosman
*                Requirements : 
*                Call Syntax  : Anonymous Block Example at the bottom of package header
*
*                Amendments   :
*                Date        User     Change Description
*                ========    ======== =================================================
*                2017/08/24  Jaco    Created Package
*
* </pre>         */
procedure execute_broker_statement (pn_broker_id_no in number, pn_company_id_no in number, pv_template_code in varchar2, pv_language_code in varchar2, pd_statement_start_date in date, pd_statement_end_date in date, pv_username in varchar2, pv_country_code in varchar2, pv_return_msg out varchar2);

end comms_comm_hub_pkg;
/


CREATE OR REPLACE package body comms_comm_hub_pkg as

procedure execute_broker_statement (pn_broker_id_no in number, pn_company_id_no in number, pv_template_code in varchar2, pv_language_code in varchar2, pd_statement_start_date in date, pd_statement_end_date in date, pv_username in varchar2, pv_country_code in varchar2, pv_return_msg out varchar2) as
 lv_return_msg              varchar2(500);
 lv_external_reference      varchar2(500);
 lv_ci_id                   varchar2(500);
 E_NO_DATA                  exception;
 
 cursor c_get_brokers is
   select distinct c.company_id_no
     from broker b, company c, company_country cc
    where b.company_id_no = c.company_id_no
      and c.company_id_no = cc.company_id_no
      and broker_id_no = nvl(pn_broker_id_no,broker_id_no)
      and c.company_id_no = nvl(pn_company_id_no, c.company_id_no)
      and cc.country_code = nvl(pv_country_code, cc.country_code);
      
begin
     
     for x in c_get_brokers loop
     LHHCORR.ws_in_pkg.create_correspondence_prc(p_source => get_system_parameter('LB_HEALTH_COMMS','COMMS_HUB','SOURCE_NAME'),
                                                 p_template => pv_template_code,
                                                 p_source_code => x.company_id_no,
                                                 p_source_code_type => get_system_parameter('LB_HEALTH_COMMS','COMMS_HUB','BROKER_SRC_CODE'),
                                                 --p_source_version => :p_source_version,
                                                 p_recipient => get_system_parameter('LB_HEALTH_COMMS','COMMS_HUB','BROKER_SRC_CODE')||x.company_id_no,
                                                 p_language => nvl(pv_language_code,'en'),
                                               --  p_send_date => nvl(pd_statement_date,trunc(sysdate)),
                                                 --p_batch => 'Batch number if it is a batch',
                                                 --p_hide_document => :p_hide_document,
                                                 --p_external_reference_in => 'If there is a specific serial numner - one will be generated otherwise',
											  /* p_in_char1 => :p_in_char1,
                                                 p_in_char2 => :p_in_char2,
                                                 p_in_char3 => :p_in_char3,
                                                 p_in_char4 => :p_in_char4,
                                                 p_in_char5 => :p_in_char5,
                                                 p_in_char6 => :p_in_char6,
                                                 p_in_char7 => :p_in_char7,
                                                 p_in_char8 => :p_in_char8,
                                                 p_in_char9 => :p_in_char9,
                                                 p_in_char10 => :p_in_char10,
                                                 p_in_num1 => :p_in_num1,
                                                 p_in_num2 => :p_in_num2,
                                                 p_in_num3 => :p_in_num3,
                                                 p_in_num4 => :p_in_num4,
                                                 p_in_num5 => :p_in_num5,*/
                                                 p_in_date1 => nvl(pd_statement_start_date,trunc(sysdate)),
                                                 p_in_date2 => nvl(pd_statement_end_date,trunc(sysdate)),/*,
                                                 p_in_date3 => :p_in_date3,
                                                 p_in_date4 => :p_in_date4,
                                                 p_in_date5 => :p_in_date5,
											  */
                                                 -- Out Variables
                                                 p_external_reference_out => lv_external_reference,
                                                 p_return_message => lv_return_msg,
                                                 p_ci_id => lv_ci_id);
       
       if lv_external_reference is not null then
         insert into company_comments (company_id_no,
                                      comment_datetime,
                                      comment_desc,
                                      last_update_datetime,
                                      username)
                              values (x.company_id_no,
                                      sysdate,
                                      get_comm_hub_template_name(pv_template_code)||' requested by '||pv_username,
                                      sysdate,
                                      pv_username);
       END IF;
    END LOOP;
   
    IF lv_ci_id IS NULL AND lv_external_reference IS NULL then
      raise E_NO_DATA;
    END IF;
	
EXCEPTION
  WHEN E_NO_DATA THEN
     pv_return_msg := 'Please check broker/brokerage input criteria';
  WHEN OTHERS THEN 
     pv_return_msg := 'Process failed with error: '||SQLERRM;
END execute_broker_statement;

end comms_comm_hub_pkg;
/


update system_parameter
  set parameter_value = 'BR'
where parameter_section = 'COMMS_HUB'
  and parameter_key = 'BROKER_SRC_CODE';
  
 /