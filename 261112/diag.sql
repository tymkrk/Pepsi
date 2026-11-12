/* Read-only diagnostics. Run on the affected tenant in SSMS.
   For the final query, set all three parameters from one slow process row
   and enable Include Actual Execution Plan (Ctrl+M).
   Full-view COUNT below intentionally measures the unfiltered expansion.
*/
SET NOCOUNT ON;

-- Distinct choices versus permutations; formula assumes unique mapping/code rows.
SELECT
    ISNULL(m.idCompGroup, 0) AS id_comp_group,
    cg.CompGroupName,
    COUNT_BIG(*) AS mapping_rows,
    COUNT(DISTINCT m.BTBusinessCode) AS distinct_businesses,
    CONVERT(BIGINT, COUNT(DISTINCT m.BTBusinessCode))
        * (COUNT(DISTINCT m.BTBusinessCode) - 1)
        * (COUNT(DISTINCT m.BTBusinessCode) - 2) AS expected_regular_rows
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS m
LEFT JOIN dbo.PEPSICO_CompGroup AS cg ON cg.idCompGroup = m.idCompGroup
GROUP BY ISNULL(m.idCompGroup, 0), cg.CompGroupName
ORDER BY expected_regular_rows DESC;

-- Duplicates here multiply the three joins. NULL and 0 share a view key.
SELECT ISNULL(idCompGroup, 0) AS id_comp_group, BTBusinessCode, COUNT_BIG(*) AS copies
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup
GROUP BY ISNULL(idCompGroup, 0), BTBusinessCode
HAVING COUNT_BIG(*) > 1;

SELECT BTBusinessCode, COUNT_BIG(*) AS copies
FROM dbo.PEPSICO_Bonus_Team_Business
GROUP BY BTBusinessCode
HAVING COUNT_BIG(*) > 1;

-- Verify live field source and each of the three parent relations.
SELECT p.name_plan, f.code_field, source_view.name_table_view,
    r.id_parent_field, filter_column.name_field AS filter_column
FROM dbo.k_m_plans AS p
INNER JOIN dbo.k_m_plans_indicators AS pi ON pi.id_plan = p.id_plan
INNER JOIN dbo.k_m_indicators_fields AS indf ON indf.id_ind = pi.id_ind
INNER JOIN dbo.k_m_fields AS f ON f.id_field = indf.id_field
LEFT JOIN dbo.k_referential_tables_views AS source_view
    ON source_view.id_table_view = f.combo_table_view
LEFT JOIN dbo.k_m_fields_relation AS r
    ON r.id_plan = p.id_plan
    AND r.id_field = CONCAT(p.id_plan, '_', pi.id_ind, '_', f.id_field)
LEFT JOIN dbo.k_referential_tables_views_fields AS filter_column
    ON filter_column.id_field = r.id_field_table_view
WHERE p.name_plan = N'Bonus' AND f.code_field = N'bonus_team_step_3';

SELECT COUNT_BIG(*) AS total_rows, COUNT(DISTINCT BTBusinessCode) AS distinct_businesses
FROM dbo.vPEPSICO_bonus_team_step3_business;

DECLARE @id_comp_group INT = NULL,
    @step_1 NVARCHAR(50) = NULL,
    @step_2 NVARCHAR(50) = NULL;

IF @id_comp_group IS NOT NULL AND @step_1 IS NOT NULL AND @step_2 IS NOT NULL
BEGIN
    SET STATISTICS IO ON;
    SET STATISTICS TIME ON;

    SELECT DISTINCT BTBusinessCode, BTBusinessValue
    FROM dbo.vPEPSICO_bonus_team_step3_business
    WHERE idCompGroup = @id_comp_group
        AND BTBusiness_filter_1 = @step_1
        AND BTBusiness_filter_2 = @step_2;

    SET STATISTICS TIME OFF;
    SET STATISTICS IO OFF;
END;
