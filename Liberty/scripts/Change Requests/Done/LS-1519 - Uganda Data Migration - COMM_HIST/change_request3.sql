select country_code, min(comms_calc_snapshot_no) minno, max(comms_calc_snapshot_no) maxno from comms_calc_snapshot group by country_code;
select min(comms_calc_snapshot_no) minno, max(comms_calc_snapshot_no) maxno from comms_calc_trace;

CREATE TABLE "LHHCOM"."TEMP_BACKUP_LS1519" AS
  select * from comms_calc_snapshot where comms_calc_snapshot_no > 54400;
commit;
select count(*) from TEMP_BACKUP_LS1519;
delete from comms_calc_snapshot where comms_calc_snapshot_no > 54400;
drop sequence COMMS_CALC_SNAPSHOT_SEQ;
CREATE SEQUENCE COMMS_CALC_SNAPSHOT_SEQ
  START WITH 54399
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 999999999999
  NOCYCLE;