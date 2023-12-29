INSERT INTO lhhcom.comm_hub_jobs values (comms_job_id_seq.nextval, 'PROCESS_FUSION_PREMIUMS','Job to pull all premium related information from Fusion','COMMISSIONS_PKG.invoke_rest_service','PROCEDURE','scheduled',NULL,NULL,'Y');
/
INSERT INTO lhhcom.comm_hub_jobs values (comms_job_id_seq.nextval, 'PROCESS_FUSION_PAYABLES','Job to run the payables import process on Fusion for records with STATUS of NULL','COMMISSIONS_PKG.process_fusion_payables','PROCEDURE','scheduled',NULL,NULL,'Y');
/
COMMIT;