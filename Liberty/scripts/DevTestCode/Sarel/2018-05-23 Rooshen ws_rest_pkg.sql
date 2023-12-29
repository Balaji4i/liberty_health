create or replace package ws_rest_pkg is

    /**
    <pre>
    ------------------------------------------------------------------------------------
    Project:     : CorrHub
    Description  : Co-ordinates Correspondence related activities
    File Name    : $BASE/src/sql/WS_REST_PKG.sql
    
    Change Log
    Date        Version   User      Change Description
    ========    =======   ========  =================================================
    04/07/2017    1.0     Rooshen   Create
    23/11/2017    1.5     Rooshen   Skipped a few version - added commenting
    
    
    
    </pre>
    */
    -------------------------------------------------------------------------------------


    type r_headers is record(
        header varchar2(100),
        value  varchar2(100));
    type t_headers is table of r_headers index by binary_integer;


    c_null_headers t_headers;

    procedure add_header_prc(p_headers in out nocopy t_headers,
                             p_header  varchar2,
                             p_value   varchar2);

    procedure clear_headers_prc(p_headers in out nocopy t_headers);

    procedure http_post_rest_xml_prc(p_url         varchar2,
                                     p_rest_method varchar2 default 'POST',
                                     p_xml_clob    clob default null,
                                     p_xml_xmltype xmltype default null,
                                     p_headers     t_headers default c_null_headers,
                                     p_wallet      varchar2 default null,
                                     p_username    varchar2 default null,
                                     p_password    varchar2 default null,
                                     p_response    out nocopy clob,
                                     p_status      out nocopy varchar2);


end ws_rest_pkg;
/
create or replace package body ws_rest_pkg is

    /**
    <pre>
    ------------------------------------------------------------------------------------
    Project:     : CorrHub
    Description  : Co-ordinates Correspondence related activities
    File Name    : $BASE/src/sql/WS_REST_PKG.sql
    
    Change Log
    Date        Version   User      Change Description
    ========    =======   ========  =================================================
    04/07/2017    1.0     Rooshen   Create
    23/11/2017    1.5     Rooshen   Skipped a few version - added commenting
    
    
    
    </pre>
    */
    -------------------------------------------------------------------------------------



    -- similar to ws_soap_docm_pkg - but made more generic
    procedure add_header_prc(p_headers in out nocopy t_headers,
                             p_header  varchar2,
                             p_value   varchar2) is
        v_header r_headers;
    begin
        v_header.header := p_header;
        v_header.value := p_value;
        p_headers(p_headers.count + 1) := v_header;
    end;
    -----------------------------------------------------------------------------------------------------------------------------------------------

    procedure clear_headers_prc(p_headers in out nocopy t_headers) is
        v_header r_headers;
    begin
        p_headers := ws_rest_pkg.c_null_headers;
    end;
    -----------------------------------------------------------------------------------------------------------------------------------------------



    procedure http_post_rest_xml_prc(p_url         varchar2,
                                     p_rest_method varchar2 default 'POST',
                                     p_xml_clob    clob default null,
                                     p_xml_xmltype xmltype default null,
                                     p_headers     t_headers default c_null_headers,
                                     p_wallet      varchar2 default null,
                                     p_username    varchar2 default null,
                                     p_password    varchar2 default null,
                                     p_response    out nocopy clob,
                                     p_status      out nocopy varchar2) is
    
        v_http_request   utl_http.req;
        v_http_response  utl_http.resp;
        v_text           varchar2(32766);
        v_xml            xmltype;
        v_xml_resp       xmltype;
        v_xml_clob       clob;
        v_xml_clob_chunk clob;
        v_result         varchar2(2) := 'R';
    
        v_chunk_start number := 0;
        c_chunk_length constant number := 32000;
    
        v_start_timestamp timestamp;
    begin
    
        logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - START - p_url : ' || p_url || ', p_rest_method : ' || p_rest_method);
    
        if p_xml_clob is not null
        then
            v_xml_clob := p_xml_clob;
        elsif v_xml is not null
        then
            v_xml_clob := v_xml.extract('/*').getclobval();
        end if;
    
    
        logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - before setting headers');
    
        if p_wallet is not null
        then
            utl_http.set_wallet(p_wallet, null);
        end if;
    
    
    
        utl_http.set_transfer_timeout(120);
    
        v_http_request := utl_http.begin_request(p_url, p_rest_method, 'HTTP/1.1');
    
        if p_username is not null and p_password is not null
        then
            utl_http.set_authentication(v_http_request, p_username, p_password);
        end if;
    
        for i in 1 .. p_headers.count
        loop
            utl_http.set_header(v_http_request, p_headers(i).header, p_headers(i).value);
            --logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - setting header - '||p_headers(i).header);
        end loop;
    
    
    
        --utl_http.set_header(v_http_request, 'Content-Type', 'text/xml');
        utl_http.set_header(v_http_request, 'Content-Length', length(v_xml_clob));
        utl_http.set_header(v_http_request, 'Transfer-Encoding', 'chunked');
    
    
        logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - before calling utl_http.write_text with clob -> ',
                   p_extra => v_xml_clob);
        --utl_http.write_text(v_http_request, v_xml_clob);
    
        
        if v_xml_clob is not null then
        loop
            v_xml_clob_chunk := null;
            v_xml_clob_chunk := substr(v_xml_clob, v_chunk_start, c_chunk_length);
        
            utl_http.write_text(v_http_request, v_xml_clob_chunk);
            logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - chunk starting - ' || v_chunk_start, p_extra => v_xml_clob_chunk);
        
            if (length(v_xml_clob_chunk) < c_chunk_length)
            then
                exit;
            end if;
        
            v_chunk_start := v_chunk_start + c_chunk_length + 1;
        
        end loop;
        end if;
    
    
    
        logger_log_information('WS_REST_PKG.DOCM_POST_PRC - calling webservice with -> ', p_extra => v_xml_clob);
    
        v_start_timestamp := systimestamp;
        v_http_response   := utl_http.get_response(v_http_request);
    
        logger_log_information('WS_REST_PKG.HTTP_POST_REST_XML_FNC - response  - v_http_response.status_code: ' ||
                               v_http_response.status_code || ', in ' || to_char(systimestamp - v_start_timestamp, 'MI:SS'));
    
        begin
            <<loop_resp>>
            loop
            
                utl_http.read_line(v_http_response, v_text, true);
            
                --logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - v_resp_line length - ' || length(p_response) || ' -  v_text - ' || v_text);
            
                p_response := p_response || v_text;
            
            end loop;
        
            --logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - end of parsing response loop');
        
            utl_http.end_response(v_http_response);
        
        
            logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - end of <<loop_resp>>');
        
        end loop_resp;
    
        p_status := global_pkg.gc_cp_success;
    
        logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - DONE - p_status : ' || p_status || ', p_response -> ',
                   p_extra => p_response);
    
        utl_http.end_response(v_http_response);
    
    
    exception
        when utl_http.end_of_body then
            --successful
            p_status := global_pkg.gc_cp_success;
        
            logger_log_information('WS_REST_PKG.HTTP_POST_REST_XML_FNC - response  - v_http_response.status_code: ' ||
                                   v_http_response.status_code || ', in ' || to_char(systimestamp - v_start_timestamp, 'MI:SS'));
        
        
        
            logger_log('WS_REST_PKG.HTTP_POST_REST_XML_FNC - DONE - p_status : ' || p_status || ', p_response -> ',
                       p_extra => p_response);
        
        
        
            utl_http.end_response(v_http_response);
        
        when utl_http.transfer_timeout then
            p_status := global_pkg.gc_cp_error_timeout; -- ET
            logger_log_error('WS_REST_PKG.HTTP_POST_REST_XML_FNC - err :' || utl_http.get_detailed_sqlcode || ' - ' ||
                             utl_http.get_detailed_sqlerrm);
        
            raise;
        
        when others then
            p_status := global_pkg.gc_cp_error_others; -- EO
            --logger_log('WS_POST.HTTP_POST_REST_XML_FNC - ERROR - ' || sqlerrm);
            logger_log_error('WS_REST_PKG.HTTP_POST_REST_XML_FNC - ERROR - ' || utl_http.get_detailed_sqlcode ||
                             utl_http.get_detailed_sqlerrm,
                             p_extra => sqlerrm);
            --raise;
    
    end http_post_rest_xml_prc;


begin
    null;
end ws_rest_pkg;
/
