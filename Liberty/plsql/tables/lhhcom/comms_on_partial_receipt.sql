create table lhhcom.comms_on_partial_receipt 
(
comms_partial_pk      number not null,
company_id_no         number not null,
group_code            varchar2(500) not null,
bu                    varchar2(500) not null,
country_code          varchar2(10) not null,
comms_percentage      number not null,
interface_to_comms    varchar2(1) default 'Y',
effective_Start_date  date default sysdate,
effective_end_date    date default to_date('31-DEC-4712'),
created_by            varchar2(200),
creation_date         date default sysdate,
last_updated_by       varchar2(200),
last_update_date      date default sysdate,
active_yn             varchar2(1)default 'N',
approved_by           varchar2(200),
CONSTRAINT commsPartialPk PRIMARY KEY (COMMS_PARTIAL_PK)
);
/
CREATE INDEX comms_on_partial_idx1 ON lhhcom.comms_on_partial_receipt (company_id_no);		