alter table comms_payments_received add (bu VARCHAR2(500));
alter table comms_payments_received add (partial_yn VARCHAR2(1));
UPDATE comms_payments_received
  SET bu = 'LH Uganda BU'
where country_CODE = 'UG';
/
UPDATE comms_payments_received
  SET bu = 'LH Lesotho BU'
where country_CODE = 'LS';
/
commit;