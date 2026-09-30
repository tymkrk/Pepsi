/* =====================================================================================================
   BONUS TEAM STEP 3 - BATCH 1: DROPDOWN VIEW + REGISTRATION IN BEQOM REFERENTIAL
   Target:  DEV only
   Prereq:  batch 0 reviewed (section 2 = all zeros)
   Effect:  new view, new rows in k_referential_tables_views / _fields. No user-visible change
            (the view is not referenced by any process field yet).
   Run:     sections 1-2 together, then fill @idCompGroup/@step1/@step2 in section 3 and run it.
   Source:  Objects/Views/dbo.vPEPSICO_bonus_team_step3_business.sql (keep both in sync)
   ===================================================================================================== */

/* -----------------------------------------------------------------------------------------------------
   1. VIEW
   ----------------------------------------------------------------------------------------------------- */
CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step3_business]
AS
-- Dropdown source for process field bonus_team_step_3 (Bonus Verification).
-- Cascades on bonus_team_step_1 (BTBusiness_filter_1), bonus_team_step_2 (BTBusiness_filter_2) and idCompGroup:
-- returns businesses of the Comp Group excluding the ones already selected in Step 1 and Step 2.
SELECT
    bcg.BTBusinessCode,
    btb.BTBusinessValue,
    ISNULL(bcg.idCompGroup, 0) AS idCompGroup,
    b1.BTBusinessCode AS BTBusiness_filter_1,
    b2.BTBusinessCode AS BTBusiness_filter_2
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb
    ON btb.BTBusinessCode = bcg.BTBusinessCode
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS b1
    ON ISNULL(b1.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS b2
    ON ISNULL(b2.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)
WHERE b1.BTBusinessCode <> b2.BTBusinessCode
    AND bcg.BTBusinessCode <> b1.BTBusinessCode
    AND bcg.BTBusinessCode <> b2.BTBusinessCode
GO

/* -----------------------------------------------------------------------------------------------------
   2. REGISTRATION (same call as in the Bonus process wrapper; type_data taken from the step 2 view)
   ----------------------------------------------------------------------------------------------------- */
DECLARE @type_data INT = ISNULL((
    SELECT rtv.type_data
    FROM dbo.k_referential_tables_views AS rtv
    WHERE rtv.name_table_view = 'vPEPSICO_bonus_team_step2_business'), 0);

EXEC dbo.sp_client_std_synchronize 'vPEPSICO_bonus_team_step3_business', 'view', @type_data;

-- expected: 1 row, same type_table_view / type_data as step 2
SELECT rtv.id_table_view, rtv.name_table_view, rtv.type_table_view, rtv.type_data
FROM dbo.k_referential_tables_views AS rtv
WHERE rtv.name_table_view IN ('vPEPSICO_bonus_team_step2_business', 'vPEPSICO_bonus_team_step3_business');

-- expected: 5 columns - BTBusinessCode, BTBusinessValue, idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2
SELECT rtv.name_table_view, rtvf.id_field, rtvf.name_field, rtvf.type_field, rtvf.length_field, rtvf.order_field
FROM dbo.k_referential_tables_views_fields AS rtvf
INNER JOIN dbo.k_referential_tables_views AS rtv
    ON rtv.id_table_view = rtvf.id_table_view
WHERE rtv.name_table_view = 'vPEPSICO_bonus_team_step3_business'
ORDER BY rtvf.order_field;
GO

/* -----------------------------------------------------------------------------------------------------
   3. TESTS
   ----------------------------------------------------------------------------------------------------- */
-- 3a. structural checks - every column must be 0
SELECT
    SUM(CASE WHEN v.BTBusinessCode IN (v.BTBusiness_filter_1, v.BTBusiness_filter_2) THEN 1 ELSE 0 END) AS rows_repeating_step1_or_step2,
    SUM(CASE WHEN v.BTBusiness_filter_1 = v.BTBusiness_filter_2 THEN 1 ELSE 0 END)                       AS rows_with_step1_equal_step2,
    SUM(CASE WHEN NOT EXISTS (
            SELECT 1 FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
            WHERE ISNULL(bcg.idCompGroup, 0) = v.idCompGroup
              AND bcg.BTBusinessCode IN (v.BTBusiness_filter_1)) THEN 1 ELSE 0 END)                        AS rows_filter_outside_comp_group
FROM dbo.vPEPSICO_bonus_team_step3_business AS v;

-- 3b. size per Comp Group (expected per group: N * (N-1) * (N-2) rows for N distinct businesses)
SELECT
    v.idCompGroup,
    COUNT(1) AS view_rows,
    n.business_count,
    n.business_count * (n.business_count - 1) * (n.business_count - 2) AS expected_rows
FROM dbo.vPEPSICO_bonus_team_step3_business AS v
INNER JOIN (
    SELECT ISNULL(bcg.idCompGroup, 0) AS idCompGroup, COUNT(DISTINCT bcg.BTBusinessCode) AS business_count
    FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
    GROUP BY ISNULL(bcg.idCompGroup, 0)
) AS n
    ON n.idCompGroup = v.idCompGroup
GROUP BY v.idCompGroup, n.business_count
ORDER BY v.idCompGroup;
-- view_rows > expected_rows => duplicated (BTBusinessCode, idCompGroup) rows in PEPSICO_Bonus_Team_Business_per_CompGroup

-- 3c. dropdown simulation for a test employee (take values from batch 0, section 7)
DECLARE @idCompGroup INT = 0;             -- <-- fill
DECLARE @step1 NVARCHAR(50) = N'';        -- <-- fill: business code chosen in Step 1 (x)
DECLARE @step2 NVARCHAR(50) = N'';        -- <-- fill: business code chosen in Step 2 (y)

SELECT 'step 2 list (existing view)' AS list_name, s2.BTBusinessCode, s2.BTBusinessValue
FROM dbo.vPEPSICO_bonus_team_step2_business AS s2
WHERE s2.idCompGroup = @idCompGroup
  AND s2.BTBusiness_filter = @step1
ORDER BY s2.BTBusinessValue;

-- expected: step 2 list minus @step2
SELECT 'step 3 list (new view)' AS list_name, s3.BTBusinessCode, s3.BTBusinessValue
FROM dbo.vPEPSICO_bonus_team_step3_business AS s3
WHERE s3.idCompGroup = @idCompGroup
  AND s3.BTBusiness_filter_1 = @step1
  AND s3.BTBusiness_filter_2 = @step2
ORDER BY s3.BTBusinessValue;

-- expected: 0 rows (empty Step 2 => empty Step 3 dropdown)
SELECT 'step 3 list with empty step 2' AS list_name, s3.BTBusinessCode
FROM dbo.vPEPSICO_bonus_team_step3_business AS s3
WHERE s3.idCompGroup = @idCompGroup
  AND s3.BTBusiness_filter_1 = @step1
  AND s3.BTBusiness_filter_2 = N'';
GO

/* -----------------------------------------------------------------------------------------------------
   ROLLBACK BATCH 1 (only if batch 2 was NOT run or was already rolled back)
   -----------------------------------------------------------------------------------------------------
BEGIN TRAN;

DELETE rtvf
FROM dbo.k_referential_tables_views_fields AS rtvf
INNER JOIN dbo.k_referential_tables_views AS rtv
    ON rtv.id_table_view = rtvf.id_table_view
WHERE rtv.name_table_view = 'vPEPSICO_bonus_team_step3_business';

DELETE FROM dbo.k_referential_tables_views
WHERE name_table_view = 'vPEPSICO_bonus_team_step3_business';

DROP VIEW IF EXISTS dbo.vPEPSICO_bonus_team_step3_business;

-- COMMIT;  -- or ROLLBACK;
*/
