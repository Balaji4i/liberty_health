declare
cursor c1 is select table_name from user_tables where table_name not like '%EXT%';
cmd varchar2(200);
begin
for c in c1 loop
cmd := 'GRANT SELECT, UPDATE, INSERT, DELETE, REFERENCEs ON '||c.table_name|| ' to LHHCOM';
execute immediate cmd;
end loop;
end;