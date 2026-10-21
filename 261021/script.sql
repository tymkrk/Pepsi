SET NOCOUNT ON;

-- 1. Business mapping: wszystkie rekordy, bez filtrowania.
SELECT
    (
        SELECT
            m.sector_name,
            m.org_unit_name,
            m.bt_business_code,
            m.is_region
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    ) AS business_mapping_json
FROM dbo.PEPSICO_bonus_team_business_mapping AS m
ORDER BY
    m.sector_name,
    m.org_unit_name,
    m.bt_business_code,
    m.is_region;

-- 2. Allocation rules: wszystkie rekordy wraz z nazwą Comp Group.
SELECT
    (
        SELECT
            r.id_comp_group,
            cg.CompGroupName AS comp_group_name,
            r.number_of_businesses,
            r.split_rule,
            r.is_region
        FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
    ) AS allocation_rule_json
FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
LEFT JOIN dbo.PEPSICO_CompGroup AS cg
    ON cg.idCompGroup = r.id_comp_group
ORDER BY
    cg.CompGroupName,
    r.id_comp_group,
    r.number_of_businesses,
    r.is_region,
    r.split_rule;
