select --distinct
       poli.code       
,      figc.stamp_id              invoice_id
,      ftdl.product_code
,      ftdl.component_code
,      ftdl.amount
from   ohi_policies_owner.pol_policies               poli
,      ohi_policies_owner.fin_base_financial_objects bfob
,      ohi_policies_owner.fin_trans_details          ftdl
,      ohi_policies_owner.fin_financial_transactions ftrn
,      ohi_policies_owner.fin_trans_process_data     ftpd
,      ohi_policies_owner.fin_grouping_combinations  figc
where  poli.version               = bfob.object_version_number
and    poli.gid                   = bfob.policy_gid
and    ftdl.ftrn_id               = ftrn.id
and    bfob.id                    = ftrn.bfob_id
and    ftrn.id                    = ftpd.ftrn_id
and    ftpd.fin_message_id        = figc.fin_message_id
and    figc.stamp_level           = 'Invoice'
order by
       1,2,3,4
;
