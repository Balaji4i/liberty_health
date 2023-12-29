declare
cursor c1 is 
select object_name
  from all_objects
 where object_type in ('FUNCTION','PACKAGE')
   and owner = user;
   
cmd varchar2(200);
begin
for c in c1 loop
cmd := 'GRANT  EXECUTE ON '||c.object_name||' to LHHCOM';
execute immediate cmd;
end loop;
end;