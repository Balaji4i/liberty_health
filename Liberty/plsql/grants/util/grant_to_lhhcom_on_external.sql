declare
cursor c1 is select table_name from user_tables where table_name like '%EXT%';
cmd varchar2(200);
begin
for c in c1 loop
cmd := 'GRANT SELECT ON '||c.table_name|| ' to LHHCOM';
execute immediate cmd;
end loop;
end;