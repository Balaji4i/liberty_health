CREATE GLOBAL TEMPORARY TABLE lhhcom.comms_fusion_app_receipts_gt (
  key                  VARCHAR2(500),
  customer_class_code  VARCHAR2(100),
  receipt_id           NUMBER,
  customer_trx_id      NUMBER,
  customer_line_id     NUMBER,
  application_id       NUMBER,
  receipt_no           VARCHAR2(500),
  receipt_date         DATE,
  amount_paid          NUMBER,
  customer_acct_id     NUMBER,
  currency_code        VARCHAR2(50),
  exchange_rate        VARCHAR2(50),
  inv_no               VARCHAR2(50),
  invoice_date         DATE,
  enrollment_product   VARCHAR2(200),
  policy_code          VARCHAR2(200),
  member_no            VARCHAR2(200),
  dependant_no         VARCHAR2(200),
  subs_date            DATE,
  member_name          VARCHAR2(500),
  sob                  NUMBER,
  status               VARCHAR2(20),
  bu                   VARCHAR2(300),
  group_account        VARCHAR2(500),
  country_code         VARCHAR2(10),
  type                 VARCHAR2(100) ,
  gl_date              DATE,
  invoice_type         VARCHAR2(100),
  invoice_source       VARCHAR2(100),
  payment_type         VARCHAR2(100),
  bulking_criteria     VARCHAR2(200),
  tax_recoverable      NUMBER);
/
CREATE INDEX comms_fusion_receipt_idx1 ON lhhcom.comms_fusion_app_receipts_gt(policy_code, subs_date, group_account);
/
CREATE INDEX comms_fusion_receipt_idx2 ON lhhcom.comms_fusion_app_receipts_gt (key);