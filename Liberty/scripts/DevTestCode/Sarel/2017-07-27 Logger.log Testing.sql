declare
  x number;
begin
  execute immediate 'select count(*) into x from foo1234';
exception when others then
logger.log_error();
  raise;
end;
/
select * from logger_logs;
delete from logger_logs;
drop table OHI_PRODUCT_AUDIT;
drop table OHI_PERSON;
drop table OHI_PRODUCT;
drop table OHI_GROUP;
SELECT * FROM USER_CONSTRAINTS WHERE TABLE_NAME = 'OHI_GROUP';
SELECT * FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME like '%OHI%' order by TABLE_NAME;
ALTER TABLE OHI_PERSON DISABLE CONSTRAINT OHI_PERSON_GROUP_FK;
