-- DROP MATERIALIZED VIEW LOG ON "LHHCOM"."OHI_COMM_PERC";
-- DROP MATERIALIZED VIEW "LHHCOM"."OHI_COMM_PERC_DETECT_OVERLAP";

CREATE MATERIALIZED VIEW LOG ON "LHHCOM"."OHI_COMM_PERC" 
  WITH ROWID (
       product_code
      ,poep_id
      ,inse_code
      ,policy_code
      ,group_code
      ,broker_id_no
      ,company_id_no
      ,effective_start_date
      ,effective_END_date)
  INCLUDING NEW VALUES;
/
CREATE MATERIALIZED VIEW "LHHCOM"."OHI_COMM_PERC_DETECT_OVERLAP"
  BUILD IMMEDIATE 
  REFRESH FORCE
  ON COMMIT
  AS
    SELECT 
           ocp.product_code
          ,ocp.poep_id
          ,ocp.inse_code
          ,ocp.policy_code
          ,ocp.group_code
          ,ocp.broker_id_no
          ,ocp.company_id_no
          ,ocp.effective_start_date
          ,ocp.effective_end_date
          ,count(*) as num_overlaps 
      FROM ohi_comm_perc ocp
      JOIN ohi_comm_perc ocpa 
        ON
          (
           nvl(ocp.product_code, 0)  = nvl(ocpa.product_code, 0)
       AND nvl(ocp.poep_id, 0)       = nvl(ocpa.poep_id, 0)
       AND nvl(ocp.inse_code, 0)     = nvl(ocpa.inse_code, 0)
       AND nvl(ocp.policy_code, 0)   = nvl(ocpa.policy_code, 0)
       AND nvl(ocp.group_code, 0)    = nvl(ocpa.group_code, 0)
       AND nvl(ocp.broker_id_no, 0)  = nvl(ocpa.broker_id_no, 0)
       AND nvl(ocp.company_id_no, 0) = nvl(ocpa.company_id_no, 0)
       AND ocp.ROWID                 != ocpa.ROWID
          )
     WHERE
            ocp.effective_start_date <= ocp.effective_end_date
       AND (ocp.auth_username IS NOT NULL AND ocpa.auth_username IS NOT NULL)
       AND (ocp.effective_start_date between ocpa.effective_start_date and ocpa.effective_end_date
        OR  ocp.effective_end_date   between ocpa.effective_start_date and ocpa.effective_end_date)
     GROUP BY
           ocp.product_code
          ,ocp.poep_id
          ,ocp.inse_code
          ,ocp.policy_code
          ,ocp.group_code
          ,ocp.broker_id_no
          ,ocp.company_id_no
          ,ocp.effective_start_date
          ,ocp.effective_end_date;
/
ALTER TABLE "LHHCOM"."OHI_COMM_PERC_DETECT_OVERLAP"
  ADD
    CONSTRAINT OHI_COMM_PERC_NO_DATE_OVERLAPS CHECK(num_overlaps = 0);
/