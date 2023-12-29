select poep.id, poep.poen_id, poep.enpr_id, gapr.enpr_id, poep.gapr_id, gapr.id from OHI_POLICIES_VIEWS_OWNER.POL_POLICY_ENROLL_PRODUCTS_V poep right outer join OHI_POLICIES_VIEWS_OWNER.POL_GROUP_ACCOUNT_PRODUCTS_V gapr on poep.gapr_id = gapr.id;

select poep.id, poep.poen_id, poep.enpr_id, poep.gapr_id from OHI_POLICIES_VIEWS_OWNER.POL_POLICY_ENROLL_PRODUCTS_V poep where poep.GAPR_ID = NULL;