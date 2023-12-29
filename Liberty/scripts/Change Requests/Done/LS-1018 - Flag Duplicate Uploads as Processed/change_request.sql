/**
* ----------------------------------------------------------------------
* Change Request: Allow Duplicates Applied Receipts to have a Processed Date (LS-1018)
*
* Description  : Change the upload package to flag duplicate uploads as processed
* Author       : Sarel Eybers
* Date         : 2018-02-15
* Call Syntax  : Just Run (F5) this script in it's etirety
* Steps
*   1) Modify EXT_COMMS_PAYMENTS_RECEIVED table to include more decimals
*   2) Compile new UPLD_TRN_PKG procedures
*                */

--  1) Modify EXT_COMMS_PAYMENTS_RECEIVED table to include more decimals

ALTER TABLE 
   ext_comms_payments_received
MODIFY 
   ( 
  	FINANCE_RECEIPT_AMT    NUMBER(38,10)
   )
;

--  2) Compile new UPLD_TRN_PKG procedures

@../../../../plsql/packages/lhhcom/upld_trn_pkg.sql;

