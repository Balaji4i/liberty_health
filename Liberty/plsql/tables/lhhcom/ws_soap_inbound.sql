create table lhhcom.ws_soap_inbound
( process_name VARCHAR2(100), 
  key_value VARCHAR2(200),
  payload CLOB,
  bu VARCHAR2(200),
  creation_date DATE,
  status VARCHAR2(100)
);