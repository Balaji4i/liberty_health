create or replace PACKAGE          "SB_FUSION_TRN" AS

procedure create_ap_soapenv_trn ( p_batch      IN NUMBER,
                              p_unique_ref     OUT VARCHAR2,
                              p_batch_number   OUT NUMBER,
                              p_soap_operation OUT VARCHAR2,
                              p_soap_header    OUT CLOB,
                              p_soap_body      OUT clob 
                            );
							
procedure dnld_invoice_batch_prc (p_batch OUT number);

PROCEDURE write_fusion(p_url varchar2, p_request_body clob);

PROCEDURE create_fusion_sb_prc(
                                 p_log_file_name    IN VARCHAR2,
                                 p_output_file_name IN VARCHAR2,
                                 pv_result_msg OUT VARCHAR2);

                         
END;


/*
create table LHH_FUSION_AUDIT
(
business_entity VARCHAR2(100), 
soap_request    CLOB,
soap_response   CLOB,
unique_ref      VARCHAR2(50),
batch_number    NUMBER,
soap_operation  VARCHAR2(40)
);


CREATE SEQUENCE LHH_FINFUSION_REF_SEQ INCREMENT BY 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1;

CREATE SEQUENCE LHH_FINFUS_BTCH_SEQ INCREMENT BY 1 MAXVALUE 9999999999999999999999999999 MINVALUE 1 ;
*/
/
create or replace PACKAGE BODY          "SB_FUSION_TRN" IS
  /**
  * <pre>
  * ----------------------------------------------------------------------
  * Project:     : Commission Self Build
  *
  *                Description  : Package to create commission payables invoices to Fusion
  *                File Name    : Liberty\plsql\packages\lhhcom\sb_fusion_trn.sql
  *
  *                Amendments   :
  *                Date        User     Change No. Change Description
  *                ========    ======== ========== =================================================
  *                2018-11-14  T.Percy   1.0       Changed to add log file and output file generation so that the progress can be tracked by the business.
  *                2019-07-02  T.Percy   1.1       Changes to package to remove hardcoding and improve data quality
  *
  * </pre>         */
  
    g_directory         VARCHAR2(100) DEFAULT 'LOGDATA';
    g_log_file_name     VARCHAR2(400);
    g_output_file_name  VARCHAR2(400);
    g_logger_identifier NUMBER;
    
    g_url_payables_import  VARCHAR2(256)          := get_system_parameter('LB_HEALTH_COMMS','FUSION','SERVER_LINK'); -- 1.1
    
  PROCEDURE write_csv(p_file_name IN VARCHAR2, p_query IN VARCHAR2) IS
  
  
        l_theCursor         INTEGER DEFAULT dbms_sql.open_cursor;
        l_columnValue       VARCHAR2(4000);
        l_status            INTEGER;
        l_descTbl           dbms_sql.desc_tab;
        l_colCnt            NUMBER;
        n                   NUMBER := 0;
        f                   utl_file.file_type;
        l_line              VARCHAR2(32767);
  
  
  BEGIN
  
    
    --generate a csv file from the select statement
    f := utl_file.fopen(g_directory,p_file_name,'a');
  
    dbms_sql.parse(l_theCursor,  p_query, dbms_sql.native );
    
    
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );
  
    for i in 1 .. l_colCnt loop
       dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
       l_line := l_line ||  l_descTbl(i).col_name||',';
    end loop;
        
    utl_file.put_line(f,l_line);
        
    l_status := dbms_sql.execute(l_theCursor);
  
    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
      l_line := null;
      for i in 1 .. l_colCnt loop
         dbms_sql.column_value( l_theCursor, i, l_columnValue );
         l_line := l_line || l_columnValue ||',';
      end loop;
      utl_file.put_line(f,l_line);
    end loop;
        
    utl_file.fclose(f);
    
  EXCEPTION 
    WHEN OTHERS THEN
       utl_file.fclose(f);
  END write_csv;  
  
  procedure create_ap_soapenv_trn (
                                   p_batch          IN  NUMBER, 
                                   p_unique_ref     OUT VARCHAR2,
                                   p_batch_number   OUT NUMBER,
                                   p_soap_operation OUT VARCHAR2,
                                   p_soap_header    OUT CLOB,
                                   p_soap_body      OUT CLOB
                                  )           	    AS
  						  
  
   lv_file_name         		VARCHAR2(265);
   v_zip_file           		VARCHAR2(265);
   v_csv_fileh				    VARCHAR2(265)    := get_system_parameter('LB_HEALTH_COMMS','FUSION','HEADER_FILENAME');
   v_csv_filed				    VARCHAR2(265)    := get_system_parameter('LB_HEALTH_COMMS','FUSION','DETAIL_FILENAME');
   
   g_zipped_blob        		BLOB;
   v_my_blob            		BLOB;
   v_cur_blob           		BLOB;
   v_cur_blob1          		BLOB;
   v_my_clob            		CLOB;
   v_cur_clob           		CLOB;
   v_my_blob1            		BLOB;
   v_my_clob1            		CLOB;
   v_cur_clob1           		CLOB;
   v_zipfile_out        		BLOB;
   v_zipfile_blob               BLOB;
   v_zipfile_clob       		CLOB;
   g_zipped_blob1       		BLOB;
   g_zipped_blob2       		BLOB;
   g_zipped_blob3       	   	BLOB;
   
   l_exp_timestamp           	TIMESTAMP;
   
   l_request_body            	VARCHAR2(10000);
   l_timestamp_char          	VARCHAR2(100)   := TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');
   l_created_timestamp_char  	VARCHAR2(100);
   l_exp_timestamp_char      	VARCHAR2(100);
   l_dnld_folder                VARCHAR2(200)   := get_system_parameter('LB_HEALTH_COMMS','FUSION','SERVER_DNLD_FOLDER');
   l_UserName                	VARCHAR2(100)   := get_system_parameter('LB_HEALTH_COMMS','FUSION','SERVER_USERNAME');
   l_password                	VARCHAR2(100)   := get_system_parameter('LB_HEALTH_COMMS','FUSION','SERVER_PASSWORD');
   l_nonce_raw               	VARCHAR2(1000)  := utl_i18n.string_to_raw(dbms_random.string('a',16),'utf8');
   l_nonce_b64               	VARCHAR2(1000)  := utl_i18n.raw_to_char(utl_encode.base64_encode(l_nonce_raw),'utf8');
   l_password_digest_b64     	VARCHAR2(1000)  := get_system_parameter('LB_HEALTH_COMMS','FUSION','PASSWORD_DIGEST_B64');
   l_file_type               	VARCHAR2(50)    := get_system_parameter('LB_HEALTH_COMMS','FUSION','DNLD_FILE_TYPE');
   v_file_concat                VARCHAR2(50)    := to_char(sysdate,'yyyymmddhhmiss');
   v_BusinessUnitId             VARCHAR2(30);
  
   v_count              		INTEGER;
   
   l_continue                   BOOLEAN DEFAULT FALSE;
  
  CURSOR c1(p_bu in VARCHAR2) IS -- start 1.1
  SELECT i.invoice_no invoice_no
        , SUM(FEE_TYPE_EXCH_AMT) invoice_amt
        , CASE 
           WHEN FEE_TYPE_EXCH_AMT > 0 THEN 
              'STANDARD'
           WHEN FEE_TYPE_EXCH_AMT < 0 THEN 
              'CREDIT'
          END AS type_lookup
        , to_char(sysdate,'yyyy/mm/dd')                     invoice_Date
        , c.company_name||'('||C.Company_Id_No||')'         company_name
        , C.Company_Id_No                                   company_no
        , c.preferred_currency_code                         currency
        , to_char(sysdate,'yyyy/mm/dd')                     trans_date
        , 'EFT'                                             payment_type
        , i.payment_exch_rate rate
        , bu.organization_name as bu
        , bu.organization_id business_unit_id 
        , bu.ledger_id
  from invoice i, 
       invoice_detail id, 
       company c, 
        ( SELECT ORGANIZATION_NAME,
                 LEDGER_ID,
                 LEDGER_NAME,
                 COUNTRY,
                 ORGANIZATION_ID
            FROM ws_soap_inbound t,    
                  XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                  COLUMNS     
                  ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
                  LEDGER_ID         VARCHAR2(150) PATH 'LEDGER_ID/text()',    
                  LEDGER_NAME       VARCHAR2(150) PATH 'LEDGER_NAME/text()',    
                  COUNTRY           VARCHAR2(150) PATH 'COUNTRY/text()',    
                  ORGANIZATION_ID   VARCHAR2(150) PATH 'ORGANIZATION_ID/text()')
             WHERE PROCESS_NAME = 'FUSION_ORGANIZATIONS') bu,
           (select DISTINCT di.invoice_no, ccs.bu 
                  from dnld_invoice di,
                       comms_calc_snapshot ccs
                  where batch_no           = p_batch 
                    AND ccs.invoice_no     = di.invoice_no
             ) inv
  where i.company_id_no                                            = c.company_id_no
 --   and decode(i.country_code,'LS','LH Lesotho BU','LH Uganda BU') = bus.business_unit_ref_uid
    and i.invoice_no                                               = id.invoice_no
    and inv.invoice_no                                             = i.invoice_no
    AND bu.organization_name                                       = inv.bu
    AND inv.bu                                                     = p_bu
    and i.release_date                                             is not null 
   group by i.invoice_no,
   case when FEE_TYPE_EXCH_AMT > 0 then 'STANDARD'
         when FEE_TYPE_EXCH_AMT < 0 then 'CREDIT'
      end,
         i.invoice_date,
         c.company_name,
         C.Company_Id_No,
         c.preferred_currency_code,
         'EFT',
         i.payment_exch_rate,
        -- decode(i.country_code,'LS','LH Lesotho BU','LH Uganda BU'),
         bu.organization_id,
         bu.organization_name,
         bu.ledger_id; -- end 1.1
 /* SELECT i.invoice_no invoice_no
        , SUM(FEE_TYPE_EXCH_AMT) invoice_amt
        , CASE 
           WHEN FEE_TYPE_EXCH_AMT > 0 THEN 
              'STANDARD'
           WHEN FEE_TYPE_EXCH_AMT < 0 THEN 
              'CREDIT'
          END AS type_lookup
        , to_char(sysdate,'yyyy/mm/dd') invoice_Date
        , c.company_name||'('||C.Company_Id_No||')' company_name
        , C.Company_Id_No company_no
        , c.preferred_currency_code currency
        , to_char(sysdate,'yyyy/mm/dd') trans_date
        , nvl(c_payment_type.company_table_type_desc,'EFT') payment_type
        , i.payment_exch_rate rate
        , decode(i.country_code,'LS','LH Lesotho BU','LH Uganda BU') as bu
        , business_unit_id 
  from invoice i, invoice_detail id, company c, business_unit bus,
             (select distinct bf.company_id_no, btt.company_table_type_desc, bf.effective_start_date,    
         rank() over (partition by bf.company_id_no order by bf.effective_start_date desc) rank_no          
           from company_function bf, company_table bt, company_table_type btt         
           where bf.company_table_id_no = bt.company_table_id_no           
            and upper(company_table_desc) = 'FUNCTION'           
            and bf.company_table_type_id_no = btt.company_table_type_id_no           
            and sysdate between bf.effective_start_date and bf.effective_end_date ) c_payment_type where i.company_id_no = c.company_id_no
            and decode(i.country_code,'LS','LH Lesotho BU','LH Uganda BU') = bus.business_unit_ref_uid
    and i.invoice_no = id.invoice_no
    and i.release_date is not null
    and c.company_id_no = c_payment_type.company_id_no(+)    
    and nvl(c_payment_type.rank_no,1) = 1
    and exists (select null
                  from dnld_invoice
                  where batch_no  = p_batch and
                    invoice_no = i.invoice_no) 
                    group by i.invoice_no,
                     case when FEE_TYPE_EXCH_AMT > 0 then 'STANDARD'
         when FEE_TYPE_EXCH_AMT < 0 then 'CREDIT'
      end,
         i.invoice_date,
         c.company_name,
         C.Company_Id_No,
         c.preferred_currency_code,
         nvl(c_payment_type.company_table_type_desc,'EFT'),
         i.payment_exch_rate,
         decode(i.country_code,'LS','LH Lesotho BU','LH Uganda BU'),
         business_unit_id;   */
  
  CURSOR c2(p_bu IN VARCHAR2) IS
  SELECT i.invoice_no invoice_no
        ,rownum line_no
        ,fee_type_exch_amt amount
        ,i.company_id_no company_no
        ,to_char(SYSDATE,'yyyy/mm/dd') invoice_Date
        ,fee_type_desc fee_type
        ,invoice_tax_codes  
    FROM invoice i
       , invoice_detail id 
       , (SELECT DISTINCT 
                 di.invoice_no, 
                 ccs.bu 
            FROM dnld_invoice di,
                 comms_calc_snapshot ccs
           WHERE batch_no           = p_batch 
             AND ccs.invoice_no     = di.invoice_no
     ) inv
  where i.invoice_no    = id.invoice_no
    and inv.invoice_no  = i.invoice_no
    AND inv.bu          = p_bu;
  
  BEGIN  

    
  -- the payload and job submission must be per active bu which exists on commissions self-build
  
  FOR c_org IN  ( SELECT ORGANIZATION_NAME bu,
                         LEDGER_ID,
                         LEDGER_NAME,
                         COUNTRY,
                         ORGANIZATION_ID
                    FROM ws_soap_inbound t,    
                          XMLTABLE('//DATA_DS/G_1' PASSING XMLTYPE(t.payload)    
                          COLUMNS     
                          ORGANIZATION_NAME VARCHAR2(150) PATH 'ORGANIZATION_NAME/text()',    
                          LEDGER_ID         VARCHAR2(150) PATH 'LEDGER_ID/text()',    
                          LEDGER_NAME       VARCHAR2(150) PATH 'LEDGER_NAME/text()',    
                          COUNTRY           VARCHAR2(150) PATH 'COUNTRY/text()',    
                          ORGANIZATION_ID   VARCHAR2(150) PATH 'ORGANIZATION_ID/text()')
                    WHERE PROCESS_NAME = 'FUSION_ORGANIZATIONS'
                 ) LOOP
  
       SELECT lhh_finfusion_ref_seq.nextval||'SUPH'
          INTO p_unique_ref
          FROM dual;
       
        SELECT lhh_finfus_btch_seq.nextval
          INTO p_batch_number
          FROM dual;
      
        v_cur_blob 				        := EMPTY_BLOB(); 
        dbms_lob.createtemporary(v_cur_clob, true);
        dbms_lob.createtemporary(v_my_clob, true);
        v_count 					        := 1;
        lv_file_name 				      := 'broker_ap'||v_file_concat;
        l_created_timestamp_char  := to_char(systimestamp + INTERVAL '-2' hour,'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');
        l_exp_timestamp_char 		  := to_char(systimestamp + INTERVAL '1' hour,'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');

         commissions_pkg.write_to_file(  g_log_file_name , 'before the loop to create the rows');
          for c_rec1 in c1(c_org.bu) loop
               commissions_pkg.write_to_file(  g_log_file_name , 'writing the rows count is '||v_count || 'org is '||c_org.bu);
              if v_count = 1 then 
              
                  select utl_raw.cast_to_raw(c_rec1.invoice_no||','||c_rec1.bu||',LH_CSB,'||c_rec1.invoice_no||','||c_rec1.invoice_amt||','||c_rec1.invoice_Date
                ||','||c_rec1.company_name||','||c_rec1.company_no||','||c_rec1.company_no||','||c_rec1.currency||','||c_rec1.currency||','||
                'Broker Fee,'||c_rec1.invoice_no||','||c_rec1.type_lookup||',,,,,,Immediate,'||c_rec1.trans_date||',,,'||c_rec1.trans_date||','||c_rec1.payment_type||',LH Broker'||
                ',,,,,,,,,,,,,,,,,,,,,,21,,,,,,,,,,,,,,,,,,,,,,,,N,N,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
                    into  v_my_blob
                    from dual FOR UPDATE;
              elsif v_count > 1 then
                 select utl_raw.cast_to_raw(c_rec1.invoice_no||','||c_rec1.bu||',LH_CSB,'||c_rec1.invoice_no||','||c_rec1.invoice_amt||','||c_rec1.invoice_Date
                ||','||c_rec1.company_name||','||c_rec1.company_no||','||c_rec1.company_no||','||c_rec1.currency||','||c_rec1.currency||','||
                'Broker Fee,'||c_rec1.invoice_no||','||c_rec1.type_lookup||',,,,,,Immediate,'||c_rec1.trans_date||',,,'||c_rec1.trans_date||','||c_rec1.payment_type||',LH Broker'||
                ',,,,,,,,,,,,,,,,,,,,,,21,,,,,,,,,,,,,,,,,,,,,,,,N,N,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
                    into  v_cur_blob
                    from dual FOR UPDATE;
              end if;
              
              
          
              COMMIT;
              if v_count > 1 then 
              DBMS_LOB.APPEND(v_my_blob, v_cur_blob);
              
             end if; 
             v_count := v_count +1 ;
             
          end loop;
          
          
          
            v_cur_blob1 				      := EMPTY_BLOB(); 
            dbms_lob.createtemporary(v_cur_clob1, true);
            dbms_lob.createtemporary(v_my_clob1, true);
            v_count 					        := 1;
            v_zip_file   				      := lv_file_name||'.zip';
            l_created_timestamp_char  := to_char(systimestamp + INTERVAL '-2' hour,'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');
            l_exp_timestamp_char 		  := to_char(systimestamp + INTERVAL '1' hour,'YYYY-MM-DD"T"HH24:MI:SS.FF3"Z"');
            
          for c_rec2 in c2(c_org.bu) loop
              
               commissions_pkg.write_to_file(  g_log_file_name , 'writing the rows count is '||v_count || 'org is '||c_org.bu);
              if v_count = 1 then 
                  select utl_raw.cast_to_raw(c_rec2.invoice_no||','||c_rec2.line_no||','||'ITEM'||','||c_rec2.amount||',,,,'||
                c_rec2.company_no||',,,,,,,,,,,,,N,,LH_COMMISSION,'||c_rec2.invoice_date||',,,,,,,,,,,'||c_rec2.INVOICE_TAX_CODES||',,,,,,,,,,,,,,N,1,,,N,,,,,,,N,,,,,,LH_LINE_INFO,'||
                --c_rec2.fee_type||',LH Broker,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
              ',LH Broker,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
                  into  v_my_blob1
                    from dual FOR UPDATE;
              elsif v_count > 1 then
                 select utl_raw.cast_to_raw(c_rec2.invoice_no||','||c_rec2.line_no||','||'ITEM'||','||c_rec2.amount||',,,,'||
                c_rec2.company_no||',,,,,,,,,,,,,N,,LH_COMMISSION,'||c_rec2.invoice_date||',,,,,,,,,,,'||c_rec2.INVOICE_TAX_CODES||',,,,,,,,,,,,,,N,1,,,N,,,,,,,N,,,,,,LH_LINE_INFO,'||
                --c_rec2.fee_type||',LH Broker,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
              ',LH Broker,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,END'||CHR(10))
                    into  v_cur_blob1
                    from dual FOR UPDATE;
              end if;
              
                if v_count > 1 then 
              DBMS_LOB.APPEND(v_my_blob1, v_cur_blob1);
             end if; 
             v_count := v_count +1 ;
           
          end loop;
          
      
            
          --DBMS_OUTPUT.PUT_LINE('v_my_clob1 = '||TO_CHAR(dbms_lob.substr(v_my_clob1, length(v_my_clob1), 1 )));
          --DBMS_OUTPUT.PUT_LINE('v_my_blob1 = '||UTL_RAW.CAST_TO_VARCHAR2(v_my_blob1));

           IF length(v_my_blob) <> 0  THEN
            as_zip.add1file( g_zipped_blob,l_dnld_folder||'/'||v_csv_fileh , v_my_blob);-- *******Use this for adding more files to the zip file*****
            l_continue := TRUE;
           END IF;
           
           IF length(v_my_blob1) <> 0 THEN
            as_zip.add1file( g_zipped_blob,l_dnld_folder||'/'||v_csv_filed , v_my_blob1);
            l_continue := TRUE;
           END IF;
           
           
           IF l_continue THEN
           
           
            as_zip.finish_zip( g_zipped_blob );
            as_zip.save_zip( g_zipped_blob, l_dnld_folder, v_zip_file );
            dbms_lob.freetemporary( g_zipped_blob );
            READ_IN_ZIPFLE_PRC(p_filename=> v_zip_file, p_directory => l_dnld_folder, p_outblob=>  v_zipfile_out);  
            
            v_zipfile_blob := base64_encode_blob(v_zipfile_out);
            v_zipfile_clob := CLOB_FROM_BLOB_FNC(v_zipfile_blob);
            
            commissions_pkg.write_to_file(  g_log_file_name,'Batch Number is           :'||p_batch);
            commissions_pkg.write_to_file(  g_log_file_name,'Document Name is          :'||l_file_type);
            commissions_pkg.write_to_file(  g_log_file_name,'Document Titls is         :'||lv_file_name);
            commissions_pkg.write_to_file(  g_log_file_name,'Fusion Document Account is: fin/payables/import');
            commissions_pkg.write_to_file(  g_log_file_name,'Zip File Name is          :'||v_zip_file);
            
            p_soap_header :=
            '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
             <soapenv:Header></soapenv:Header>
             <soapenv:Body>
                <typ:loadAndImportData xmlns:erp="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/" xmlns:typ="http://xmlns.oracle.com/apps/financials/commonModules/shared/model/erpIntegrationService/types/">
                   <typ:document>
                      <erp:Content>'||v_zipfile_clob||'</erp:Content>
                      <erp:FileName>'||v_zip_file||'</erp:FileName>
                      <erp:ContentType>'|| l_file_type||'</erp:ContentType>
                      <erp:DocumentTitle>'||lv_file_name||'</erp:DocumentTitle>
                      <erp:DocumentSecurityGroup>FAFusionImportExport</erp:DocumentSecurityGroup>
                      <erp:DocumentAccount>fin/payables/import</erp:DocumentAccount>
                      <erp:DocumentName>'||lv_file_name||'</erp:DocumentName>
                      <erp:DocumentId/>
                   </typ:document>
                   <typ:jobList>
                      <erp:JobName>/oracle/apps/ess/financials/payables/invoices/transactions,*APXIIMPT</erp:JobName>
                      <erp:ParameterList>#NULL,'||c_org.organization_id||',N,#NULL,#NULL,#NULL,1000,LH_CSB,#NULL,N,N,'||c_org.ledger_id||',#NULL,1</erp:ParameterList>
                      <erp:JobRequestId/>
                   </typ:jobList>
                   <typ:interfaceDetails>1</typ:interfaceDetails>
                   <typ:notificationCode/>
                   <typ:callbackURL/>
                </typ:loadAndImportData>
             </soapenv:Body>
          </soapenv:Envelope>';
          
         
           
          
           p_soap_body := 
          '<typ:loadAndImportData>
          <typ:document>
          <erp:Content>'||v_zipfile_clob||'</erp:Content>
          <erp:FileName>'||v_zip_file||'</erp:FileName>     
          <erp:ContentType>'|| l_file_type||'</erp:ContentType>
          <erp:DocumentTitle>'||lv_file_name||'</erp:DocumentTitle>                 
          <erp:DocumentSecurityGroup>FAFusionImportExport</erp:DocumentSecurityGroup>
          <erp:DocumentAccount>prc/supplier/import</erp:DocumentAccount>
          <erp:DocumentName>'||lv_file_name||'</erp:DocumentName>                   
          <erp:DocumentId/>
          </typ:document>
          <typ:jobList>
          <erp:JobName>/oracle/apps/ess/prc/poz/supplierImport,*ImportSupplier</erp:JobName>
          <erp:ParameterList>NEW,N</erp:ParameterList>
          <erp:JobRequestId/>
          </typ:jobList>
          <typ:interfaceDetails>24</typ:interfaceDetails>
          <typ:notificationCode/>
          <typ:callbackURL/>
          </typ:loadAndImportData>';    
          
        -- call the rest API per bu 
        write_fusion(g_url_payables_import,P_SOAP_HEADER); -- 1.1 as needs to be submitted per BU 
       END IF;   
     
    END LOOP;   
 
  EXCEPTION
    when others then 

     commit;
  
  end create_ap_soapenv_trn; 
  /******************************************************************************************************/
  PROCEDURE dnld_invoice_batch_prc (
                                    p_batch OUT NUMBER
                                   ) AS
   gc_scope_prefix                CONSTANT VARCHAR2(31)           
                                         := lower($$PLSQL_UNIT) || '.';
   l_scope                        logger_logs.scope%TYPE 
                                         := 'FUSION: ' || gc_scope_prefix;
   l_params                       logger.tab_param;
   
  BEGIN
  
  SELECT dnld_batch_no_seq.nextval
    INTO p_batch
    FROM dual;
  
  UPDATE dnld_invoice
     SET batch_no             = p_batch,
         last_update_datetime = SYSDATE
   WHERE batch_no = 0;
   
   logger.log_information('dnld_invoice_batch_prc using batch no '||p_batch);
   
   COMMIT;
   
   EXCEPTION 
     WHEN OTHERS THEN
      logger.log_error('Unhandled Exception in dnld_invoice_batch_prc with '||sqlerrm, l_scope, null, l_params);
  END dnld_invoice_batch_prc;
  /******************************************************************************************************/
procedure write_fusion(
                        p_url varchar2, 
                        p_request_body clob
                       ) as
                       
                       
   utl_req         UTL_HTTP.req;
   utl_resp        UTL_HTTP.resp;
   req_length      binary_integer;
   response_body   CLOB;
   resp_length     binary_integer;
   buffer          varchar2 (2000);
   amount          pls_integer := 2000;
   offset          pls_integer := 1;

BEGIN

   utl_req := UTL_HTTP.begin_request (p_url, 'POST', 'HTTP/1.1');
   UTL_HTTP.set_header (utl_req, 'Content-Type', 'text/xml');
   
   req_length := DBMS_LOB.getlength (p_request_body);
  utl_http.set_header(utl_req, 'SOAPAction', 'mediate');
   --If Message data under 32kb limit
   if req_length<=32767
   then
  
       UTL_HTTP.set_header (utl_req, 'Content-Length', req_length); 
       UTL_HTTP.write_text (utl_req, p_request_body);
  
  
   -- If Message data more than 32kb   
   elsif req_length > 32767
   then

    UTL_HTTP.set_header (utl_req, 'Transfer-Encoding', 'chunked');
   
       WHILE (offset < req_length)
       LOOP
          DBMS_LOB.read (p_request_body,
                         amount,
                         offset,
                         buffer);
          UTL_HTTP.write_text (utl_req, buffer);
          offset := offset + amount;
  
       END LOOP;
  
   end if;
   
   utl_resp := UTL_HTTP.get_response (utl_req);
   UTL_HTTP.read_text (utl_resp, response_body, 32767);
   
   commissions_pkg.write_to_file(  g_log_file_name,'Output of the response '||response_body);
   
   UTL_HTTP.end_response (utl_resp);
  
  -- RETURN response_body;
  
  EXCEPTION
       when utl_http.end_of_body then
            utl_http.end_response(utl_resp);
END write_fusion;
  
  /******************************************************************************************************/
  PROCEDURE create_fusion_sb_prc(
                                 p_log_file_name    IN VARCHAR2,
                                 p_output_file_name IN VARCHAR2,
                                 pv_result_msg OUT VARCHAR2
                                 ) AS
    p_batch          NUMBER(9);
    p_entity_type    VARCHAR2(30);
    p_unique_ref     VARCHAR2(200);
    p_batch_number   NUMBER;
    p_soap_operation VARCHAR2(200);
    p_soap_header    CLOB;
    p_soap_body      CLOB;
    
   
    
    gc_scope_prefix  CONSTANT VARCHAR2(31)  := lower($$PLSQL_UNIT) || '.';
    
    l_scope          logger_logs.scope%TYPE := 'FUSION: ' || gc_scope_prefix;
    l_params         logger.tab_param;
    l_session_id     VARCHAR2(200);
    l_slave_id       NUMBER;
  
    
  begin
    logger.log_information('create_fusion_sb_prc started');
    
    
    IF p_log_file_name IS NULL THEN
        -- start 1.0
        select sys_context('userenv','sid') INTO l_session_id from dual;
        select userenv('PID') INTO l_slave_id FROM DUAL;
      
        g_logger_identifier := get_scheduler_job_id(l_session_id,l_slave_id);
           
        g_log_file_name    := g_logger_identifier||'.html';
        g_output_file_name := g_logger_identifier||'.csv';
        
        
        --open up a log and output file to store the run and output information for reference
        commissions_pkg.create_file(  
                            p_file_name     => g_log_file_name,
                            p_process       => 'Send Commission Payment Invoices to Fusion'
                          );
       
        commissions_pkg.create_file(  
                            p_file_name     => g_output_file_name,
                            p_process       => 'Send Commission Payment Invoices to Fusion'
                          );
        -- end 1.0
   ELSE
   
       g_log_file_name    := p_log_file_name;
       g_output_file_name := p_output_file_name;
       
   END IF;
   
   dnld_invoice_batch_prc(p_batch);
  
    
  
   create_ap_soapenv_trn
   (
       p_batch          => p_batch,
       P_UNIQUE_REF     => P_UNIQUE_REF,
       P_BATCH_NUMBER   => P_BATCH_NUMBER,
       P_SOAP_OPERATION => P_SOAP_OPERATION,
       P_SOAP_HEADER    => P_SOAP_HEADER,
       P_SOAP_BODY      => P_SOAP_BODY
     );
     
    commissions_pkg.write_to_file(  g_log_file_name,'Creating the SOAP Message: ');
    commissions_pkg.write_to_file(  g_log_file_name,'Creating the SOAP Message - Batch: '||p_batch);
    commissions_pkg.write_to_file(  g_log_file_name,'Creating the SOAP Message - Unique Reference: '||P_UNIQUE_REF);
    commissions_pkg.write_to_file(  g_log_file_name,'Creating the SOAP Message - Batch Number: '||P_BATCH_NUMBER);
    commissions_pkg.write_to_file(  g_log_file_name,'The soap message generated to Fusion');
   
   
  -- write_fusion(v_url,P_SOAP_HEADER);
   
   logger.log_information('create_fusion_sb_prc finished');
   
   commissions_pkg.write_to_file(  g_log_file_name,'CREATE Fusion file has completed successfully');
   
   pv_result_msg :=  null;
   
  EXCEPTION 
    when others then 
    --  rollback;
    commit;
  	pv_result_msg := 'Unhandled Exception in create_fusion_sb_prc with '||sqlerrm;
      logger.log_error('Unhandled Exception in create_fusion_sb_prc with '||sqlerrm, l_scope, null, l_params);
      commissions_pkg.write_to_file(  g_log_file_name, 'Unhandled Exception in create_fusion_sb_prc with '||sqlerrm);
  END create_fusion_sb_prc;
  /******************************************************************************************************/
  
end sb_fusion_trn;
/