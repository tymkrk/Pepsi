/* Bonus Team latest changes - 2026-11-09
Run the whole file in the intended existing PepsiCo/beqom database in SSMS, one session.
Plain T-SQL with GO; no SQLCMD mode or external files required.
Requires the previous extended-round / Step 3 deployment and existing Override grid metadata.
Includes V3 allocation, Lipton dual mapping, Division ALL fallback, Override field validation
and the read-only mismatch column. Includes one Division exception-cache refresh.
No global transaction: on any error STOP, inspect and correct before continuing.
Completed batches remain committed. For unattended execution use sqlcmd -b.
Recurring cache-refresh scheduling is not included.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF @@TRANCOUNT <> 0
    THROW 51520, 'Run outside an existing transaction.', 1;
IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'comp_round_extended') IS NULL
    OR COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'corporate_override') IS NULL
    OR OBJECT_ID(N'dbo.PEPSICO_bonus_team_business_mapping', N'U') IS NULL
    OR OBJECT_ID(N'dbo.PEPSICO_CompRoundExtendedRule', N'U') IS NULL
    OR OBJECT_ID(N'dbo.PEPSICO_EmployeeCompRoundException', N'U') IS NULL
    OR OBJECT_ID(N'dbo._ufn_get_employee_bonus_team', N'FN') IS NULL
    THROW 51521, 'Previous Bonus Team extended-round prerequisites are missing.', 1;
IF OBJECT_ID(N'dbo.SP_Grid_Add_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate', N'P') IS NULL
    OR OBJECT_ID(N'dbo.SP_Grid_Save_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate', N'P') IS NULL
    THROW 51522, 'Existing Override grid procedures are required.', 1;
IF (SELECT COUNT(*) FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Upload') <> 1
    OR (SELECT COUNT(*) FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Override') <> 1
    THROW 51523, 'Expected existing Upload and Override grids.', 1;
IF NOT EXISTS
(
    SELECT 1 FROM dbo.k_referential_grids AS g
    INNER JOIN dbo.k_referential_grids_fields AS gf ON gf.id_grid = g.id_grid
    INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = gf.id_field
    WHERE g.name_grid = N'Bonus Team Upload' AND f.name_field = N'CompGroupBonusTeamMismatchFlag'
)
    THROW 51524, 'Existing Upload mismatch column is required.', 1;
GO

-- SECTION 01: Objects/Functions/dbo._fn_get_bonus_team.sql
PRINT N'Objects/Functions/dbo._fn_get_bonus_team.sql';
GO
CREATE OR ALTER FUNCTION [dbo].[_fn_get_bonus_team]
(
    @comp_round_extended NVARCHAR(256),
    @Step1 NVARCHAR(255),
    @Step2 NVARCHAR(255),
    @Step3 NVARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    /*
    History:
    20261105 Lipton supports IB and North America; resolve by round, with IB priority for globals.
    20261109 V3: two businesses always split 50/50; regional display names and Procurement priority.
    20251013 Danuta Lemma    Remove "100%" from final team name.
    20251126 Danuta Lemma    Added IB CompGroup logic.
    20251127 Danuta Lemma    Added ICC CompGroup logic.
    20261009 Tymoteusz Kruk  Added @Step3 and rule selection by step count and region flag;
                            resolve common OU/sector for OR rules, merge repeated teams,
                            and format percentages before alphabetically sorted team names
                            with a slash separator, Corporate last, explicit 100%, and Other for unresolved setups;
                            resolve incoming business names to codes and use CompGroup IDs as configuration keys;
                            Corporate inherits the common sector of the other selected businesses;
                            require a common is_region flag across all selected steps;
                            mixed region/non-region selections return Other;
                            return NULL for empty selections to preserve the preassigned-team fallback in OnChange.

    20261021 Tymoteusz Kruk  Select region rules when any selected business has is_region = 1;
                            regional 100% Sector uses only regional mappings, ignoring other steps;
                            multiple regional sectors return Other;
                            businesses spanning different EMEA OUs return Other after regional priority;
                            keep validation and allocation decisions inside individual split-rule branches;
                            configured Corporate selection overrides base rules and other-step validation.

    20261022 Tymoteusz Kruk  Unify Corporate rule names; retain override validation behavior by flag.

    20261023 Allocation lookup uses comp_round_extended; no employee timeline reads.

    20261104 Restore common EMEA sector across OUs for two/three businesses;
             omit 100% from final names, preserving blend percentages;
             Corporate GGF Corporate priority is configured through conditional override rows.

    20261104 Regional OR rule for two/three businesses distinguishes regional selections:
             one region uses 75% selected sector / 25% Corporate; two or more regions use Corporate.

    Workflow: count nonblank steps -> any-region flag -> configured rule.
    OR rules use a common OU first, otherwise sector_name; unresolved setups return Other.
    */
    DECLARE @number_of_businesses INT,
            @is_region BIT = 0,
            @rule_count INT,
            @split_rule NVARCHAR(200),
            @corporate_override BIT = 0,
            @common_sector_name NVARCHAR(100),
            @common_ou_name NVARCHAR(100),
            @resolved_team_name NVARCHAR(100),
            @final_bonus_team NVARCHAR(MAX) = N'Other';

    DECLARE @steps TABLE
    (
        step_number INT NOT NULL,
        bt_business_code NVARCHAR(50) NULL,
        business_name NVARCHAR(100) NULL
    );

    -- RTC supplies business names; resolve codes internally without changing the arguments.
    INSERT INTO @steps (step_number, bt_business_code, business_name)
    SELECT s.step_number, b.bt_business_code, b.business_name
    FROM (VALUES (1, @Step1), (2, @Step2), (3, @Step3)) AS s(step_number, business_name)
    CROSS APPLY
    (
        SELECT LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(s.business_name,
            NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) AS business_name
    ) AS n
    OUTER APPLY
    (
        SELECT CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessCode) END AS bt_business_code,
               CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessValue) END AS business_name
        FROM dbo.PEPSICO_Bonus_Team_Business AS d
        WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(d.BTBusinessValue,
            NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = n.business_name
    ) AS b
    WHERE NULLIF(n.business_name, N'') IS NOT NULL;

    -- Count supplied steps, including repeated names; NULL/blank steps are ignored.
    SELECT @number_of_businesses = COUNT(*) FROM @steps;

    -- No correction selected: let OnChange fall back to the preassigned bonus team.
    IF @number_of_businesses = 0
    BEGIN
        RETURN NULL;
    END;

    IF NOT EXISTS
    (
        SELECT 1 WHERE NULLIF(LTRIM(RTRIM(@comp_round_extended)), N'') IS NOT NULL
    )
    BEGIN
        RETURN @final_bonus_team;
    END;

    -- Lipton belongs to both sectors. Resolve it by Comp Group; globals prefer IB.
    DECLARE @effective_mapping TABLE
    (
        bt_business_code NVARCHAR(50), sector_name NVARCHAR(100),
        org_unit_name NVARCHAR(100), is_region BIT
    );
    INSERT INTO @effective_mapping (bt_business_code, sector_name, org_unit_name, is_region)
    SELECT m.bt_business_code, m.sector_name, m.org_unit_name, m.is_region
    FROM dbo.PEPSICO_bonus_team_business_mapping AS m
    WHERE EXISTS (SELECT 1 FROM @steps AS s WHERE s.bt_business_code = m.bt_business_code)
      AND NOT EXISTS
    (
        SELECT 1 FROM @steps AS s WHERE s.bt_business_code = m.bt_business_code
          AND s.business_name = N'Lipton JV North America'
    );
    INSERT INTO @effective_mapping (bt_business_code, sector_name, org_unit_name, is_region)
    SELECT selected_mapping.bt_business_code, selected_mapping.sector_name,
           selected_mapping.org_unit_name, selected_mapping.is_region
    FROM (SELECT DISTINCT bt_business_code FROM @steps WHERE business_name = N'Lipton JV North America') AS lipton
    CROSS APPLY
    (
        SELECT TOP (1) m.bt_business_code, m.sector_name, m.org_unit_name, m.is_region
        FROM dbo.PEPSICO_bonus_team_business_mapping AS m
        WHERE m.bt_business_code = lipton.bt_business_code
        ORDER BY CASE WHEN m.sector_name = @comp_round_extended THEN 0
                      WHEN m.sector_name = N'International Beverages' THEN 1 ELSE 2 END,
                 m.sector_name, m.org_unit_name, m.is_region
    ) AS selected_mapping;

    -- Any region business selects region rules, including mixed region/non-region steps.
    SELECT @is_region = MAX(CONVERT(INT, m.is_region))
    FROM @steps AS s
    INNER JOIN @effective_mapping AS m
        ON m.bt_business_code = s.bt_business_code;

    IF @is_region IS NULL
        RETURN @final_bonus_team;

    DECLARE @has_unmapped_step BIT = 0;
    IF EXISTS
    (
        SELECT 1 FROM @steps AS s
        WHERE s.bt_business_code IS NULL
           OR NOT EXISTS (SELECT 1 FROM @effective_mapping AS m WHERE m.bt_business_code = s.bt_business_code)
    )
        SET @has_unmapped_step = 1;

    DECLARE @team_shares TABLE
    (
        team_name NVARCHAR(255) NOT NULL,
        team_pct DECIMAL(6, 2) NOT NULL
    );

    DECLARE @mapped_steps TABLE
    (
        step_number INT NOT NULL,
        sector_name NVARCHAR(100) NOT NULL,
        org_unit_name NVARCHAR(100) NULL
    );

    INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
    SELECT DISTINCT s.step_number, m.sector_name, NULLIF(LTRIM(RTRIM(m.org_unit_name)), N'')
    FROM @steps AS s
    INNER JOIN @effective_mapping AS m
        ON m.bt_business_code = s.bt_business_code
    WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) <> N'Corporate';


    -- Corporate-specific rules take priority for the selected step count.
    -- Their region flag is ignored; normal allocation excludes override rows.
    SET @rule_count = 0;
    IF EXISTS
    (
        SELECT 1 FROM @steps
        WHERE LTRIM(RTRIM(REPLACE(business_name, NCHAR(160), N' '))) = N'Corporate'
    )
    BEGIN
        SELECT @rule_count = COUNT(*),
               @corporate_override = MAX(CONVERT(INT, r.corporate_override)),
               @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
        FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
        WHERE r.comp_round_extended = @comp_round_extended
          AND r.number_of_businesses = @number_of_businesses
          AND r.corporate_override = 1;
    END;

    IF @rule_count = 0
    BEGIN
        SET @corporate_override = 0;
        SELECT @rule_count = COUNT(*),
               @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
        FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
        WHERE r.comp_round_extended = @comp_round_extended
          AND r.number_of_businesses = @number_of_businesses
          AND r.is_region = @is_region
          AND r.corporate_override = 0;
    END;

    -- No fallback to a different flag or arbitrary candidate.
    IF @rule_count <> 1
    BEGIN
        RETURN @final_bonus_team;
    END;

    IF @split_rule = N'75% Bonus Team / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 75 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'100% 1st Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 100 FROM @steps WHERE step_number = 1;
    END
    ELSE IF @split_rule = N'50% 1st Bonus Team / 50% 2nd Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1
            RETURN N'Other';
        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 50 FROM @steps;
    END
    ELSE IF @split_rule = N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 37.5 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% OU / 25% Corporate OR 75% sector / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% Selected Region / 25% Corporate OR 100% Corporate'
    BEGIN
        IF @has_unmapped_step = 1 OR @number_of_businesses NOT IN (2, 3)
        BEGIN
            RETURN N'Other';
        END;

        -- Count selected steps, not mappings or distinct sectors; repeated regions count twice.
        DECLARE @regional_step_count INT;
        SELECT @regional_step_count = COUNT(*)
        FROM @steps AS s
        WHERE EXISTS
        (
            SELECT 1 FROM @effective_mapping AS m
            WHERE m.bt_business_code = s.bt_business_code AND m.is_region = 1
        );

        IF @regional_step_count >= 2
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
        END
        ELSE IF @regional_step_count = 1
        BEGIN
            SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT m.sector_name) = 1
                                             THEN MAX(m.sector_name) END
            FROM @steps AS s
            INNER JOIN @effective_mapping AS m
                ON m.bt_business_code = s.bt_business_code
            WHERE m.is_region = 1;

            IF @resolved_team_name IS NULL
                RETURN N'Other';

            INSERT INTO @team_shares (team_name, team_pct)
            VALUES (@resolved_team_name, 75), (N'Corporate', 25);
        END
        ELSE
            RETURN N'Other';
    END
    ELSE IF @split_rule = N'75% Selected Region / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
            RETURN N'Other';
        SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT m.sector_name) = 1 THEN MAX(m.sector_name) END
        FROM @steps AS s
        INNER JOIN @effective_mapping AS m ON m.bt_business_code = s.bt_business_code
        WHERE m.is_region = 1;
        IF @resolved_team_name IS NULL
            RETURN N'Other';
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'100% Corporate'
    BEGIN
        IF @corporate_override = 0
           AND @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
    END
    ELSE IF @split_rule = N'100% OU or 100% Sector'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
    END
    ELSE IF @split_rule = N'100% Sector'
    BEGIN
        -- Regional 100% Sector ignores non-region steps, including unresolved selections.
        -- More than one regional sector is ambiguous, regardless of step order.
        IF @is_region = 1
        BEGIN
            SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT m.sector_name) = 1
                                             THEN MAX(m.sector_name) END
            FROM @steps AS s
            INNER JOIN @effective_mapping AS m
                ON m.bt_business_code = s.bt_business_code
            WHERE m.is_region = 1;

            IF @resolved_team_name IS NULL
                RETURN N'Other';
            INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
        END
        ELSE
        BEGIN
            IF @has_unmapped_step = 1
            BEGIN
                RETURN N'Other';
            END;

            SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT sector_name) = 1
                                             THEN MAX(sector_name) END
            FROM @mapped_steps;
            IF @resolved_team_name IS NULL
            BEGIN
                RETURN N'Other';
            END;
            INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
        END;
    END
    ELSE
    BEGIN
        RETURN N'Other';
    END;

    -- Display region bonus team names while keeping technical sector keys in mappings.
    UPDATE @team_shares
    SET team_name = CASE team_name
        WHEN N'EMEA' THEN N'EMEA Region'
        WHEN N'APAC' THEN N'APAC Foods Region'
        WHEN N'LATAM' THEN N'LATAM Foods Region'
        WHEN N'Intl. Beverages' THEN N'International Beverages'
        ELSE team_name END;

    -- Merge repeated teams, omit 100%, retain blend percentages and keep Corporate last.
    IF EXISTS (SELECT 1 FROM @team_shares)
    BEGIN
        SELECT @final_bonus_team = STRING_AGG
        (
            CAST
            (
                CASE WHEN t.team_pct = 100 THEN N''
                     ELSE CASE WHEN t.team_pct = FLOOR(t.team_pct)
                     THEN CONVERT(NVARCHAR(10), CONVERT(INT, t.team_pct))
                     ELSE CONVERT(NVARCHAR(10), CONVERT(DECIMAL(6, 1), t.team_pct))
                     END + N'% '
                END + t.team_name AS NVARCHAR(MAX)
            ), N' / '
        ) WITHIN GROUP (ORDER BY CASE WHEN t.team_name = N'Corporate' THEN 1 ELSE 0 END, t.team_name)
        FROM
        (
            SELECT team_name, SUM(team_pct) AS team_pct
            FROM @team_shares
            GROUP BY team_name
        ) AS t;
    END;

    RETURN @final_bonus_team;
END;
GO

-- SECTION 02: Objects/Stored Procedures/dbo.SP_RefreshEmployeeCompRoundException.sql
PRINT N'Objects/Stored Procedures/dbo.SP_RefreshEmployeeCompRoundException.sql';
GO
CREATE OR ALTER PROCEDURE dbo.SP_RefreshEmployeeCompRoundException
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Same process Comp Group source as Kernel_SP_Process_DataOnChange.
        -- Materialize candidates before touching the large involvement timeline.
        SELECT DISTINCT pps.id_step, pps.id_payee, pps.start_step,
               py.codePayee AS gpid, approval.idCompGroup AS id_comp_group
        INTO #candidates
        FROM dbo.k_m_plans AS plan_def
        INNER JOIN dbo.k_m_plans_payees_steps AS pps ON pps.id_plan = plan_def.id_plan
        INNER JOIN dbo.py_Payee AS py ON py.idPayee = pps.id_payee
        INNER JOIN dbo.PEPSICO_Process_BonusApproval AS approval
            ON approval.idPayee = pps.id_payee
           AND approval.start_date_histo = pps.start_step
        WHERE plan_def.name_plan = N'Bonus'
          AND EXISTS
          (
              SELECT 1 FROM dbo.PEPSICO_CompRoundExtendedRule AS rule_def
              WHERE rule_def.id_comp_group = approval.idCompGroup
          );

        SELECT DISTINCT candidate.id_step, candidate.id_comp_group, timeline.DivisionCode_nk AS division_code
        INTO #candidate_divisions
        FROM #candidates AS candidate
        INNER JOIN dbo.PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS timeline
            ON timeline.GPID = candidate.gpid
           AND timeline.StartDateInvolvement = candidate.start_step;

        -- NULL plus a known code is ambiguous too; identical duplicate rows are harmless.
        IF EXISTS
        (
            SELECT id_step FROM #candidate_divisions
            GROUP BY id_step
            HAVING COUNT(*) > 1
        )
            THROW 51020, 'Ambiguous Comp Group or Division for a Bonus involvement; exception cache was not refreshed.', 1;

        SELECT candidate.id_step, candidate.id_comp_group, candidate.division_code, rule_def.comp_round_extended
        INTO #exceptions
        FROM #candidate_divisions AS candidate
        CROSS APPLY
        (
            -- ALL is a fallback for known Divisions; exact matches always win.
            SELECT TOP (1) rule_row.comp_round_extended
            FROM dbo.PEPSICO_CompRoundExtendedRule AS rule_row
            WHERE rule_row.id_comp_group = candidate.id_comp_group
              AND NULLIF(LTRIM(RTRIM(candidate.division_code)), '') IS NOT NULL
              AND (rule_row.division_code = candidate.division_code OR rule_row.division_code = 'ALL')
            ORDER BY CASE WHEN rule_row.division_code = candidate.division_code THEN 0 ELSE 1 END
        ) AS rule_def
        INNER JOIN dbo.PEPSICO_CompGroup AS comp_group ON comp_group.idCompGroup = candidate.id_comp_group
        WHERE rule_def.comp_round_extended <> comp_group.CompGroupName;

        BEGIN TRANSACTION;
        -- Serialize publication; DELETE and INSERT are one atomic replacement, including empty results.
        DELETE FROM dbo.PEPSICO_EmployeeCompRoundException WITH (TABLOCKX);
        INSERT INTO dbo.PEPSICO_EmployeeCompRoundException
            (id_step, id_comp_group, division_code, comp_round_extended, refreshed_at)
        SELECT id_step, id_comp_group, division_code, comp_round_extended, SYSUTCDATETIME()
        FROM #exceptions;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SECTION 03: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_00_comp_round_extended_rules.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_00_comp_round_extended_rules.sql';
GO
-- Confirmed Comp Group + Division mappings; resolve IDs by name across fiscal years.
-- Run before deploy_bonus_team_allocation_rule.sql, after deploying the configuration table.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE INTO dbo.PEPSICO_CompRoundExtendedRule WITH (HOLDLOCK) AS target
    USING
    (
        SELECT cg.idCompGroup AS id_comp_group, seed.division_code, seed.comp_round_extended
        FROM (VALUES
            (N'Global S&T', 'D101', N'Global S&T'),
            (N'Global S&T', 'ALL', N'Global'),
            (N'Corporate GGF', 'D034', N'Global R&D'),
            (N'Corporate GGF', 'D033', N'Global Procurement')
        ) AS seed(comp_group_name, division_code, comp_round_extended)
        INNER JOIN dbo.PEPSICO_CompGroup AS cg
            ON cg.CompGroupName = seed.comp_group_name
    ) AS source
        ON target.id_comp_group = source.id_comp_group
       AND target.division_code = source.division_code
    WHEN MATCHED AND target.comp_round_extended <> source.comp_round_extended THEN
        UPDATE SET comp_round_extended = source.comp_round_extended
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id_comp_group, division_code, comp_round_extended)
        VALUES (source.id_comp_group, source.division_code, source.comp_round_extended);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 04: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping.sql';
GO
-- Merge source snapshot by names resolved against the target environment.
-- Preserve target rows without a matching source; skip unresolved dictionary names.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Exported codes without dictionary names are deliberately not seeded:
    -- BTB0, BTB091, BTB094, BTB097, BTB100, BTB126, BTB139, BTB140, Not Applicable for North America Bonus Design.
    DECLARE @mapping_seed TABLE
    (
        sector_name NVARCHAR(100) NOT NULL,
        org_unit_name NVARCHAR(100) NULL,
        business_name NVARCHAR(500) NOT NULL,
        is_region BIT NOT NULL
    );

    INSERT INTO @mapping_seed
        (sector_name, org_unit_name, business_name, is_region)
    VALUES
        (N'APAC', NULL, N'ANZ Foods', 0),
        (N'APAC', NULL, N'APAC Foods Region', 1),
        (N'APAC', NULL, N'Asia Foods', 0),
        (N'APAC', NULL, N'Asia Foods PO1', 0),
        (N'APAC', NULL, N'B&C Po1', 0),
        (N'APAC', NULL, N'Be & Cheery', 0),
        (N'APAC', NULL, N'Corporate', 0),
        (N'APAC', NULL, N'GCR Food PO1', 0),
        (N'APAC', NULL, N'Greater China Foods', 0),
        (N'APAC', NULL, N'IndoChina Foods', 0),
        (N'APAC', NULL, N'Indonesia Foods', 0),
        (N'EMEA', NULL, N'BCCA', 0),
        (N'EMEA', NULL, N'Corporate', 0),
        (N'EMEA', NULL, N'EMEA Region', 1),
        (N'EMEA', NULL, N'RBCCA', 0),
        (N'EMEA', NULL, N'Russia', 0),
        (N'EMEA', NULL, N'Turkey', 0),
        (N'EMEA', NULL, N'UKI', 0),
        (N'EMEA', N'East Europe', N'East Balkans', 0),
        (N'EMEA', N'East Europe', N'East Europe', 0),
        (N'EMEA', N'East Europe', N'SEEB', 0),
        (N'EMEA', N'East Europe', N'Poland', 0),
        (N'EMEA', N'East Europe', N'Ukraine', 0),
        (N'EMEA', N'MENAPAK', N'Egypt Foods & COBO', 0),
        (N'EMEA', N'MENAPAK', N'MENAPAK', 0),
        (N'EMEA', N'MENAPAK', N'Middle East Foods', 0),
        (N'EMEA', N'MENAPAK', N'Pakistan Foods', 0),
        (N'EMEA', N'MENAPAK', N'Southern Africa', 0),
        (N'EMEA', N'Western Europe', N'BeNeLux', 0),
        (N'EMEA', N'Western Europe', N'France', 0),
        (N'EMEA', N'Western Europe', N'GroW', 0),
        (N'EMEA', N'Western Europe', N'Iberia', 0),
        (N'EMEA', N'Western Europe', N'Western Europe', 0),
        (N'International Beverages', NULL, N'ANZ FOBO', 0),
        (N'International Beverages', NULL, N'Asia', 0),
        (N'International Beverages', NULL, N'Corporate', 0),
        (N'International Beverages', NULL, N'Europe FOBO', 0),
        (N'International Beverages', NULL, N'Greater China FOBO', 0),
        (N'International Beverages', NULL, N'India Beverages', 0),
        (N'International Beverages', NULL, N'India Foods', 0),
        (N'International Beverages', NULL, N'India PO1', 0),
        (N'International Beverages', NULL, N'Intl. Beverages', 1),
        (N'International Beverages', NULL, N'LATAM FOBO', 0),
        (N'International Beverages', NULL, N'Lipton JV North America', 0),
        (N'International Beverages', NULL, N'MEA FOBO', 0),
        (N'International Beverages', NULL, N'Pakistan FOBO', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMEA ', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton LATAM Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMEA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMESA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton LATAM', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMESA', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton APAC', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton EU / AMEA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Global', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Europe Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton NA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton APAC Technical', 0),
        (N'International Beverages', NULL, N'PGCS China', 0),
        (N'International Beverages', NULL, N'PGCS India', 0),
        (N'International Beverages', NULL, N'PGCS Mexico', 0),
        (N'International Beverages', NULL, N'PGCS Pakistan', 0),
        (N'International Beverages', NULL, N'PGCS Global S&T', 0),
        (N'International Beverages', NULL, N'PGCS Uruguay', 0),
        (N'International Beverages', NULL, N'PGCS US', 0),
        (N'International Beverages', NULL, N'PGCS Global', 0),
        (N'International Beverages', NULL, N'Soda Stream Israel', 0),
        (N'International Beverages', NULL, N'Soda Stream NA', 0),
        (N'International Beverages', NULL, N'Soda Stream DACH', 0),
        (N'International Beverages', NULL, N'Soda Stream Argentina', 0),
        (N'International Beverages', NULL, N'Soda Stream ROW', 0),
        (N'International Beverages', NULL, N'Soda Stream Japan', 0),
        (N'International Beverages', NULL, N'Soda Stream South Africa', 0),
        (N'International Beverages', NULL, N'Soda Stream North EU', 0),
        (N'International Beverages', NULL, N'Soda Stream Australia', 0),
        (N'International Beverages', NULL, N'Soda Stream Global', 0),
        (N'International Beverages', NULL, N'Soda Stream Central EU', 0),
        (N'International Beverages', NULL, N'Soda Stream South EU', 0),
        (N'International Beverages', NULL, N'Soda Stream South Korea', 0),
        (N'International Beverages', NULL, N'SSA FOBO', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Europe', 0),
        (N'LATAM', NULL, N'Andean', 0),
        (N'LATAM', NULL, N'Caricam', 0),
        (N'LATAM', NULL, N'LATAM Foods Region', 1),
        (N'LATAM', NULL, N'PBF', 0),
        (N'LATAM', NULL, N'PMF', 0),
        (N'LATAM', NULL, N'South Cone', 0),
        (N'LATAM', NULL, N'Venezuela', 0),
        (N'North America', NULL, N'Lipton JV North America', 0),
        (N'North America', NULL, N'Costco Global', 0),
        (N'North America', NULL, N'Costco International', 0),
        (N'North America', NULL, N'North America Coffee Partnership', 0),
        (N'North America', NULL, N'Texoma PO1', 0),
        (N'North America', NULL, N'Walmart International', 0),
        (N'North America', NULL, N'Canada', 0),
        (N'North America', NULL, N'Corporate', 0),
        (N'North America', NULL, N'Digital Commerce', 0),
        (N'North America', NULL, N'FLC', 0),
        (N'North America', NULL, N'FLC SDL / Field Sales Leader', 0),
        (N'North America', NULL, N'North America', 1),
        (N'North America', NULL, N'PBC Canada', 0),
        (N'North America', NULL, N'PBUS', 0),
        (N'North America', NULL, N'7Eleven PBUS', 0),
        (N'North America', NULL, N'PBUS AFH', 0),
        (N'North America', NULL, N'PBUS Atlantic Region', 0),
        (N'North America', NULL, N'Costco PBUS', 0),
        (N'North America', NULL, N'Dollar General PBUS', 0),
        (N'North America', NULL, N'Kroger PBUS', 0),
        (N'North America', NULL, N'PBUS NorthCentral Region', 0),
        (N'North America', NULL, N'PBUS NorthEast Region', 0),
        (N'North America', NULL, N'Sam’s Club PBUS', 0),
        (N'North America', NULL, N'PBUS SouthEast Region', 0),
        (N'North America', NULL, N'Strategic Grocery Channel PBUS', 0),
        (N'North America', NULL, N'Target PBUS', 0),
        (N'North America', NULL, N'PBUS Texoma Region', 0),
        (N'North America', NULL, N'Walmart PBUS', 0),
        (N'North America', NULL, N'Walmart + Sam''s Club Global', 0),
        (N'North America', NULL, N'PBUS West Region', 0),
        (N'North America', NULL, N'PFUS', 0),
        (N'North America', NULL, N'PFUS Atlantic Region', 0),
        (N'North America', NULL, N'PFC Canada', 0),
        (N'North America', NULL, N'7Eleven PFUS', 0),
        (N'North America', NULL, N'Costco PFUS', 0),
        (N'North America', NULL, N'PFUS NorthCentral Region', 0),
        (N'North America', NULL, N'PFUS SouthEast Region', 0),
        (N'North America', NULL, N'PFUS Texoma Region', 0),
        (N'North America', NULL, N'PFUS NorthEast Region', 0),
        (N'North America', NULL, N'Dollar General PFUS', 0),
        (N'North America', NULL, N'Walmart PFUS', 0),
        (N'North America', NULL, N'Sam’s Club PFUS', 0),
        (N'North America', NULL, N'Walmart + Sam’s Club PFUS', 0),
        (N'North America', NULL, N'PFUS West Region', 0),
        (N'North America', NULL, N'Target PFUS', 0),
        (N'North America', NULL, N'PFUS Quaker', 0),
        (N'North America', NULL, N'Strategic Grocery Channel PFUS', 0),
        (N'North America', NULL, N'Kroger PFUS', 0),
        (N'North America', NULL, N'poppi', 0),
        (N'North America', NULL, N'Siete', 0),
        (N'North America', NULL, N'Sabra', 0),
        (N'North America', NULL, N'QFC', 0),
        (N'North America', NULL, N'7Eleven US PO1', 0),
        (N'North America', NULL, N'Dollar General US PO1', 0),
        (N'North America', NULL, N'Kroger US PO1', 0),
        (N'North America', NULL, N'Sam’s Club US PO1', 0),
        (N'North America', NULL, N'Strategic Grocery Channel US PO1', 0),
        (N'North America', NULL, N'Target US PO1', 0),
        (N'North America', NULL, N'Walmart US PO1', 0),
        (N'North America', NULL, N'Walmart + Sam’s Club US PO1', 0);

    -- Normalize NBSP and typographic apostrophes on both sides.
    ;WITH business_dictionary AS
    (
        SELECT
            LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(b.BTBusinessValue, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) AS business_name,
            b.BTBusinessCode AS bt_business_code
        FROM dbo.PEPSICO_Bonus_Team_Business AS b
    ),
    unique_business AS
    (
        -- MIN only projects the one distinct code; ambiguous names are skipped.
        SELECT business_name, MIN(bt_business_code) AS bt_business_code
        FROM business_dictionary
        GROUP BY business_name
        HAVING COUNT(DISTINCT bt_business_code) = 1
    )
    MERGE INTO dbo.PEPSICO_bonus_team_business_mapping WITH (HOLDLOCK) AS target
    USING
    (
        SELECT DISTINCT s.sector_name, s.org_unit_name, b.bt_business_code, s.is_region
        FROM @mapping_seed AS s
        INNER JOIN unique_business AS b
            ON b.business_name = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(s.business_name, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39))))
    ) AS source
        ON target.sector_name = source.sector_name
       AND (target.org_unit_name = source.org_unit_name
            OR (target.org_unit_name IS NULL AND source.org_unit_name IS NULL))
       AND target.bt_business_code = source.bt_business_code
    WHEN MATCHED AND target.is_region <> source.is_region THEN
        UPDATE SET is_region = source.is_region
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (sector_name, org_unit_name, bt_business_code, is_region)
        VALUES (source.sector_name, source.org_unit_name, source.bt_business_code, source.is_region);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 05: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_allocation_rule.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_allocation_rule.sql';
GO
-- Merge known allocation defaults for base and configured extended Comp Round names.
-- Run after deploy_bonus_team_00_comp_round_extended_rules.sql.
-- Custom extended allocation rules outside this seed remain maintained separately.
-- Preserve unmatched target rows except superseded regional rules in the explicit scope below.
-- Skip unresolved dictionary names.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @allocation_seed TABLE
    (
        comp_round_extended NVARCHAR(256) NOT NULL,
        number_of_businesses INT NOT NULL,
        split_rule NVARCHAR(200) NOT NULL,
        is_region BIT NOT NULL,
        corporate_override BIT NOT NULL
    );

    INSERT INTO @allocation_seed
        (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
    VALUES
        (N'Global', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Global', 1, N'100% Sector', 1, 0),
        (N'Global', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'Global', 2, N'100% Sector', 1, 0),
        (N'Global', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global', 3, N'100% Sector', 1, 0),
        (N'APAC Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'APAC Foods', 1, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'100% Sector', 1, 0),
        (N'APAC Foods', 3, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'APAC Foods', 3, N'100% Sector', 0, 0),
        (N'Corporate GGF', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Corporate GGF', 1, N'100% Sector', 1, 0),
        (N'Corporate GGF', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'Corporate GGF', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Corporate GGF', 2, N'100% Sector', 1, 0),
        (N'Corporate GGF', 3, N'100% Sector', 1, 0),
        (N'EMEA Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'EMEA Foods', 1, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'100% Sector', 1, 0),
        (N'EMEA Foods', 3, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'EMEA Foods', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global Procurement', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Global Procurement', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global Procurement', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'Global Procurement', 2, N'75% Selected Region / 25% Corporate', 1, 0),
        (N'Global Procurement', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global Procurement', 3, N'100% Sector', 1, 0),
        (N'Global R&D', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global R&D', 1, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'100% Corporate', 0, 1),
        (N'Global R&D', 3, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 2, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global R&D', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global R&D', 3, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global S&T', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global S&T', 1, N'100% Corporate', 0, 1),
        (N'Global S&T', 2, N'100% Corporate', 0, 1),
        (N'Global S&T', 3, N'100% Corporate', 0, 1),
        (N'Global S&T', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global S&T', 2, N'75% OU / 25% Corporate OR 75% sector / 25% Corporate', 0, 0),
        (N'Global S&T', 2, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global S&T', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global S&T', 3, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'International Beverages', 1, N'100% 1st Bonus Team', 0, 0),
        (N'International Beverages', 1, N'100% Sector', 1, 0),
        (N'International Beverages', 2, N'100% Sector', 1, 0),
        (N'International Beverages', 3, N'100% Sector', 1, 0),
        (N'International Beverages', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'International Beverages', 3, N'100% Sector', 0, 0),
        (N'LATAM ', 1, N'100% 1st Bonus Team', 0, 0),
        (N'LATAM ', 1, N'100% Sector', 1, 0),
        (N'LATAM ', 2, N'100% Sector', 1, 0),
        (N'LATAM ', 3, N'100% Sector', 1, 0),
        (N'LATAM ', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'LATAM ', 3, N'100% Sector', 0, 0),
        (N'North America', 1, N'100% 1st Bonus Team', 0, 0),
        (N'North America', 1, N'100% Sector', 1, 0),
        (N'North America', 2, N'100% Sector', 1, 0),
        (N'North America', 3, N'100% Sector', 1, 0),
        (N'North America', 2, N'100% 1st Bonus Team', 0, 0),
        (N'North America', 3, N'100% 1st Bonus Team', 0, 0);

    -- Corporate is a conditional override, not a multi-sector regional mapping.
    -- R&D/S&T overrides are defined above; Corporate GGF uses a conditional override for 2/3.
    INSERT INTO @allocation_seed
        (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
    SELECT round_def.comp_round_extended, business_count.number_of_businesses, N'100% Corporate', 0, 1
    FROM (VALUES (N'APAC Foods'), (N'EMEA Foods'), (N'LATAM'),
        (N'International Beverages'), (N'North America'), (N'Global Procurement'), (N'Corporate GGF')) AS round_def(comp_round_extended)
    CROSS JOIN (VALUES (2), (3)) AS business_count(number_of_businesses);

    ;WITH configured_comp_round AS
    (
        SELECT DISTINCT CompGroupName AS comp_round_extended
        FROM dbo.PEPSICO_CompGroup
        UNION
        SELECT comp_round_extended
        FROM dbo.PEPSICO_CompRoundExtendedRule
    )
    MERGE INTO dbo.PEPSICO_bonus_team_allocation_rule WITH (HOLDLOCK) AS target
    USING
    (
        SELECT DISTINCT cg.comp_round_extended, s.number_of_businesses, s.split_rule, s.is_region, s.corporate_override
        FROM @allocation_seed AS s
        INNER JOIN configured_comp_round AS cg
            ON cg.comp_round_extended = s.comp_round_extended
    ) AS source
        ON target.comp_round_extended = source.comp_round_extended
       AND target.number_of_businesses = source.number_of_businesses
       AND target.is_region = source.is_region
       AND target.split_rule = source.split_rule
    WHEN MATCHED AND target.corporate_override <> source.corporate_override THEN
        UPDATE SET corporate_override = source.corporate_override
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
        VALUES (source.comp_round_extended, source.number_of_businesses, source.split_rule, source.is_region, source.corporate_override)
    WHEN NOT MATCHED BY SOURCE
         AND (target.is_region = 1
              OR (target.comp_round_extended = N'Corporate GGF'
                  AND target.number_of_businesses IN (2, 3)))
         AND target.number_of_businesses BETWEEN 1 AND 3
         AND target.comp_round_extended IN
         (
             SELECT cg.comp_round_extended
             FROM configured_comp_round AS cg
             WHERE cg.comp_round_extended IN
                 (N'North America', N'EMEA Foods', N'APAC Foods',
                  N'LATAM', N'International Beverages', N'Corporate GGF')
                OR (cg.comp_round_extended = N'Global S&T'
                    AND target.number_of_businesses = 1
                    AND target.corporate_override = 0
                    AND target.split_rule = N'100% 1st Bonus Team')
         ) THEN
        DELETE;

    -- Procurement single non-region business follows 1 Business Supported, not Bonus with Corp Component.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    WHERE legacy.comp_round_extended = N'Global Procurement'
      AND legacy.number_of_businesses = 1
      AND legacy.is_region = 0
      AND legacy.corporate_override = 0
      AND legacy.split_rule = N'75% Bonus Team / 25% Corporate'
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS replacement
          WHERE replacement.comp_round_extended = legacy.comp_round_extended
            AND replacement.number_of_businesses = 1
            AND replacement.is_region = 0
            AND replacement.corporate_override = 0
            AND replacement.split_rule = N'100% 1st Bonus Team'
      );

    -- Retire superseded two/three-business regional rules only when their replacements exist.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    WHERE legacy.comp_round_extended IN (N'Global R&D', N'Global S&T')
      AND legacy.number_of_businesses IN (2, 3)
      AND legacy.is_region = 1
      AND legacy.corporate_override = 0
      AND legacy.split_rule IN (N'Corporate', N'100% Corporate')
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS replacement
          WHERE replacement.comp_round_extended = legacy.comp_round_extended
            AND replacement.number_of_businesses = legacy.number_of_businesses
            AND replacement.is_region = 1
            AND replacement.corporate_override = 0
            AND replacement.split_rule = N'75% Selected Region / 25% Corporate OR 100% Corporate'
      );

    -- Retire the old name only where its canonical replacement was seeded.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    INNER JOIN @allocation_seed AS s
        ON s.comp_round_extended = legacy.comp_round_extended
       AND s.number_of_businesses = legacy.number_of_businesses
       AND s.is_region = legacy.is_region
       AND s.corporate_override = legacy.corporate_override
       AND s.split_rule = N'100% Corporate'
    WHERE legacy.split_rule = N'Corporate'
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS canonical
          WHERE canonical.comp_round_extended = legacy.comp_round_extended
            AND canonical.number_of_businesses = legacy.number_of_businesses
            AND canonical.is_region = legacy.is_region
            AND canonical.corporate_override = legacy.corporate_override
            AND canonical.split_rule = N'100% Corporate'
      );

    -- V3 replaces only known superseded defaults; preserve unrelated custom configuration.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    WHERE legacy.corporate_override = 0
      AND (
          (legacy.comp_round_extended = N'EMEA Foods' AND legacy.number_of_businesses = 2 AND legacy.is_region = 0
           AND legacy.split_rule IN (N'50% 1st Bonus Team / 50% 2nd Bonus Team OR 100% Sector',
               N'50% 1st Bonus Team / 50% 2nd Bonus Team OR 100% Sector for different OUs'))
          OR (legacy.comp_round_extended = N'Global' AND
              ((legacy.number_of_businesses IN (1, 2) AND legacy.is_region = 1
                AND legacy.split_rule IN (N'100% 1st Bonus Team', N'50% 1st Bonus Team / 50% 2nd Bonus Team'))
               OR (legacy.number_of_businesses = 3 AND legacy.split_rule = N'100% OU')))
          OR (legacy.comp_round_extended = N'Global Procurement' AND legacy.number_of_businesses = 2
              AND legacy.is_region = 1 AND legacy.split_rule = N'100% Sector')
      );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 06: Objects/Stored Procedures/dbo.SP_Grid_Add_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate.sql
PRINT N'Objects/Stored Procedures/dbo.SP_Grid_Add_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate.sql';
GO
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Add_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate]
	(
	@UniqueKey nvarchar(max)
	,@idUser int
	,@idProfile int
	,@primaryKey int
	)
AS
BEGIN
/****************************************************************************************************
Purpose: Return failure / message if month overlaps found

History:
	(0) 20180427		Sandip Keni			Created
	(1) 20250919		Danuta Lemma		Change target table to PEPSICO_OvrdBonusTeam_ProcessUpdate
	(2) 2026-10-12 /Bartosz Ryżak/ PEPPRT26-117 Reject a grid row that overlaps a MyTeam Bonus process Bonus Team Override (dbo.SP_OvrdBonusTeam_OverlapCheck)
	(3) 2026-10-16 /Bartosz Ryżak/ PEPPRT26-117 overlap rejection (2) removed; a material HR Override takes priority over overlapping manager Final rows in its period through dbo.SP_MergeOvrdBonusTeamProcess; comment 'Bonus Process' rejected (reserved for MyTeam Bonus rows)
	(4) 2026-10-22 /Michal Czarnecki/ PEPPRTCR25-76 require Override Bonus Team or Create New Team Named

	(5) 2026-11-05 /Tymoteusz Kruk/ Require exactly one of Override Bonus Team and Create New Team Named

****************************************************************************************************/
	DECLARE @TableName varchar(200) = 'PEPSICO_OvrdBonusTeam_ProcessUpdate'
	DECLARE @IdentityColumn varchar(200) = 'idOvrdBonusTeam'
	DECLARE @OverlapCheckColumn varchar(200) = 'GPID'
	DECLARE @StartDateColumn varchar(200) = 'StartDate'
	DECLARE @EndDateColumn varchar(200) = 'EndDate'
	DECLARE @OverlapCheckColumnLabel varchar(200) = 'GPID'
	DECLARE @StartDateColumnLabel varchar(200) = 'Start Month'
	DECLARE @EndDateColumnLabel varchar(200) = 'End Month'

	DECLARE @ResultStatus bit = 1
	DECLARE @ResultMessage nvarchar(max) = ''
	DECLARE @procedure_name NVARCHAR(255) = OBJECT_NAME(@@PROCID) --(3)

	EXEC SP_Grid_AddSave_DateOverlapCheck @UniqueKey ,@primaryKey
		,@TableName ,@IdentityColumn ,@OverlapCheckColumn ,@StartDateColumn ,@EndDateColumn
		,@OverlapCheckColumnLabel ,@StartDateColumnLabel ,@EndDateColumnLabel
		,@ResultMessage OUTPUT

	--(5) Require exactly one populated team field.
	IF @ResultMessage = N''
		AND (
			SELECT
				COUNT(DISTINCT gdtv.Column_Name)
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Process_Type = N'ADD'
				AND gdtv.Column_Name IN (N'idBonusTeam', N'NewTeamName')
				AND NULLIF(LTRIM(RTRIM(gdtv.Column_Value)), N'') IS NOT NULL
				AND gdtv.Column_Value <> N'_null_'
			) <> 1
	BEGIN
		SET @ResultMessage = N'Exactly one of Override Bonus Team or Create New Team Named must be provided.';
	END;

	--(3)
	/**
	the comment 'Bonus Process' marks MyTeam Bonus rows in Final, an HR row must not carry it
	**/
	IF @ResultMessage = N''
		AND EXISTS
			(
			SELECT 1
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Column_Name = N'Comments'
				AND LTRIM(RTRIM(gdtv.Column_Value)) = N'Bonus Process'
			)
	BEGIN
		SET @ResultMessage = N'Comment "Bonus Process" is reserved for MyTeam Bonus changes. Please use a different comment.';
		PRINT CONCAT(CONVERT(VARCHAR(25), GETUTCDATE(), 121), ' ', @procedure_name, ' -- comment Bonus Process rejected');
	---------- 
	END;

	IF @ResultMessage <> '' --overlaps found
	BEGIN
		SET @ResultStatus = 0 --failure
	END

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
END
GO

-- SECTION 07: Objects/Stored Procedures/dbo.SP_Grid_Save_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate.sql
PRINT N'Objects/Stored Procedures/dbo.SP_Grid_Save_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate.sql';
GO
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Save_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate]
	(
	@UniqueKey NVARCHAR(MAX)
	, @idUser INT
	, @idProfile INT
	, @primaryKey INT
	)
AS
BEGIN
/****************************************************************************************************
Purpose: Return failure / message if month overlaps found

Note:
	- Call to this procedure is set from Advanced tab of Grid Editor.

History:
	(0) 2018-04-27 /Sandip Keni/ Created
	(1) 2025-09-19 /Danuta Lemma/ Change target table to PEPSICO_OvrdBonusTeam_ProcessUpdate
	(2) 2026-10-12 /Bartosz Ryżak/ PEPPRT26-117 Reject a grid row that overlaps a MyTeam Bonus process Bonus Team Override (dbo.SP_OvrdBonusTeam_OverlapCheck)
	(3) 2026-10-16 /Bartosz Ryżak/ PEPPRTCR25-79 BT-GAP-07 GPID / StartDate change: Final row of the old GPID / StartDate marked for deletion (dbo.SP_MergeOvrdBonusTeamProcess @mark_old_key = 1)
		; parameter list in brackets, data types uppercase
	(4) 2026-10-16 /Bartosz Ryżak/ PEPPRT26-117 overlap rejection (2) removed; a material HR Override takes priority over overlapping manager Final rows in its period; the merge (3) detects a real change and removes the MyTeam Bonus rows of the period, new parameter @is_grid_add
		; comment 'Bonus Process' rejected (reserved for MyTeam Bonus rows)
		; old values for the Save Post written by the merge to dbo.grid_data_temp_values (Process_Type 'PEP')
	(5) 2026-10-22 /Michal Czarnecki/ PEPPRTCR25-76 require Override Bonus Team or Create New Team Named

	(6) 2026-11-05 /Tymoteusz Kruk/ Require exactly one of Override Bonus Team and Create New Team Named

****************************************************************************************************/
	DECLARE @TableName varchar(200) = 'PEPSICO_OvrdBonusTeam_ProcessUpdate'
	DECLARE @IdentityColumn varchar(200) = 'idOvrdBonusTeam'
	DECLARE @OverlapCheckColumn varchar(200) = 'GPID'
	DECLARE @StartDateColumn varchar(200) = 'StartDate'
	DECLARE @EndDateColumn varchar(200) = 'EndDate'
	DECLARE @OverlapCheckColumnLabel varchar(200) = 'GPID'
	DECLARE @StartDateColumnLabel varchar(200) = 'Start Month'
	DECLARE @EndDateColumnLabel varchar(200) = 'End Month'

	DECLARE @ResultStatus bit = 1
	DECLARE @ResultMessage nvarchar(max) = ''
	DECLARE @procedure_name NVARCHAR(255) = OBJECT_NAME(@@PROCID) --(4)
	DECLARE @null_value NVARCHAR(10) = N'_null_' --(5)

	EXEC SP_Grid_AddSave_DateOverlapCheck @UniqueKey ,@primaryKey
		,@TableName ,@IdentityColumn ,@OverlapCheckColumn ,@StartDateColumn ,@EndDateColumn
		,@OverlapCheckColumnLabel ,@StartDateColumnLabel ,@EndDateColumnLabel
		,@ResultMessage OUTPUT

	--(6) Require exactly one populated team field after applying pending changes.
	IF @ResultMessage = N''
		AND NOT EXISTS
			(
			SELECT
				1
			FROM
				dbo.PEPSICO_OvrdBonusTeam_ProcessUpdate AS pu
			CROSS JOIN
				(
				SELECT
					MAX(CASE WHEN gdtv.Column_Name = N'idBonusTeam' THEN gdtv.Column_Value END) AS idBonusTeam
					, MAX(CASE WHEN gdtv.Column_Name = N'NewTeamName' THEN gdtv.Column_Value END) AS NewTeamName
				FROM
					dbo.grid_data_temp_values AS gdtv
				WHERE 1 = 1
					AND gdtv.Unique_Key = @UniqueKey
					AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
					AND gdtv.Process_Type = N'UPD'
				) AS b
			WHERE 1 = 1
				AND pu.idOvrdBonusTeam = @primaryKey
				AND
					(
					CASE WHEN CASE WHEN b.idBonusTeam = @null_value THEN NULL ELSE COALESCE(TRY_CONVERT(INT, b.idBonusTeam), pu.idBonusTeam) END IS NOT NULL THEN 1 ELSE 0 END
					+ CASE WHEN CASE WHEN b.NewTeamName = @null_value THEN NULL ELSE NULLIF(LTRIM(RTRIM(COALESCE(b.NewTeamName, pu.NewTeamName))), N'') END IS NOT NULL THEN 1 ELSE 0 END = 1
					)
			)
	BEGIN
		SET @ResultMessage = N'Exactly one of Override Bonus Team or Create New Team Named must be provided.';
	END;

	--(4)
	/**
	the comment 'Bonus Process' marks MyTeam Bonus rows in Final, an HR row must not carry it
	**/
	IF @ResultMessage = N''
		AND EXISTS
			(
			SELECT 1
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Column_Name = N'Comments'
				AND LTRIM(RTRIM(gdtv.Column_Value)) = N'Bonus Process'
			)
	BEGIN
		SET @ResultMessage = N'Comment "Bonus Process" is reserved for MyTeam Bonus changes. Please use a different comment.';
		PRINT CONCAT(CONVERT(VARCHAR(25), GETUTCDATE(), 121), ' ', @procedure_name, ' -- comment Bonus Process rejected');
	---------- 
	END;

	--(3)
	/**
	no overlap: the stored row still has the old values; a real change removes the MyTeam Bonus rows of the new period, a GPID change rebuilds the old GPID --(4)
	!!! ATTENTION: NEEDED IN THE SAVE POST !!! the merge also writes the real-change flag and the old GPID / StartDate / EndDate to dbo.grid_data_temp_values (Process_Type 'PEP');
	dbo.SP_Grid_Save_Post_PEPSICO_OvrdBonusTeam_ProcessUpdate reads them (the row is already updated there): Bonus Team Review cleared only on a real change, new and old period --(4)
	**/
	IF @ResultMessage = N''
	BEGIN
		EXEC dbo.SP_MergeOvrdBonusTeamProcess
			@primaryKey = @primaryKey
			, @UniqueKey = @UniqueKey
			, @is_grid_add = 0 --(4)
			, @is_grid_delete = 0
			, @mark_old_key = 1
			, @result_message = @ResultMessage OUTPUT
		;
		PRINT '-- AFTER dbo.SP_MergeOvrdBonusTeamProcess';
	---------- 
	END;

	IF @ResultMessage <> '' --overlaps found
	BEGIN
		SET @ResultStatus = 0 --failure
	END

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
END
GO

-- SECTION 08: Override mismatch column
/* 2026-11-05 /Tymoteusz Kruk/
Copy the existing Upload mismatch flag column to the Override child, read-only.
Run in SSMS in the target database. No SQLCMD mode required.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @source_grid INT, @target_grid INT, @field INT, @next_order INT;

    IF (SELECT COUNT(*) FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Upload') <> 1
        THROW 51510, 'Expected exactly one Bonus Team Upload grid.', 1;
    IF (SELECT COUNT(*) FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Override') <> 1
        THROW 51511, 'Expected exactly one Bonus Team Override grid.', 1;

    SELECT @source_grid = id_grid FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Upload';
    SELECT @target_grid = id_grid FROM dbo.k_referential_grids WHERE name_grid = N'Bonus Team Override';

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.k_referential_grids AS s
        JOIN dbo.k_referential_grids AS t ON t.id_table_view = s.id_table_view
        WHERE s.id_grid = @source_grid AND t.id_grid = @target_grid
    )
        THROW 51512, 'Source and target grids must use the same table/view.', 1;

    IF (SELECT COUNT(*)
        FROM dbo.k_referential_grids_fields AS gf
        JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = gf.id_field
        WHERE gf.id_grid = @source_grid AND f.name_field = N'CompGroupBonusTeamMismatchFlag') <> 1
        THROW 51513, 'Expected exactly one mismatch flag column in Upload.', 1;

    SELECT @field = gf.id_field
    FROM dbo.k_referential_grids_fields AS gf
    JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = gf.id_field
    WHERE gf.id_grid = @source_grid AND f.name_field = N'CompGroupBonusTeamMismatchFlag';

    SELECT @next_order = ISNULL(MAX(order_column), -1) + 1
    FROM dbo.k_referential_grids_fields WITH (UPDLOCK, HOLDLOCK)
    WHERE id_grid = @target_grid;

    IF NOT EXISTS
    (
        SELECT 1 FROM dbo.k_referential_grids_fields
        WHERE id_grid = @target_grid AND id_field = @field
    )
    BEGIN
        INSERT INTO dbo.k_referential_grids_fields
        (
            [id_grid],
            [id_field],
            [name_column],
            [order_column],
            [is_editable],
            [regular_expression],
            [is_sortable],
            [error_message],
            [url],
            [width],
            [combo_datasource_name],
            [combo_datavaluefield_name],
            [combo_datatextfield_name],
            [combo_defaultfield_value],
            [combo_page_size],
            [combo_filtered_column_name],
            [combo_filtered_pattern],
            [combo_allow_custom_text],
            [group_index],
            [is_frozen],
            [thousand_separator],
            [decimal_precision],
            [filter_field],
            [sort_order],
            [column_align],
            [is_flex_used],
            [flex],
            [id_source_tenant],
            [id_source],
            [id_change_set],
            [is_mandatory],
            [defaultfield_value],
            [sort_direction],
            [is_percentage_used],
            [combo_type],
            [combo_dataparentvaluefield_name],
            [is_bulk_apply_used],
            [enable_row_validation],
            [is_uid_reference],
            [hyperlink_enabled],
            [hyperlink_id_display_field],
            [hyperlink_default_display_text],
            [hyperlink_type]
        )
        SELECT
            @target_grid,
            src.[id_field],
            src.[name_column],
            @next_order,
            0,
            src.[regular_expression],
            src.[is_sortable],
            src.[error_message],
            src.[url],
            src.[width],
            src.[combo_datasource_name],
            src.[combo_datavaluefield_name],
            src.[combo_datatextfield_name],
            src.[combo_defaultfield_value],
            src.[combo_page_size],
            src.[combo_filtered_column_name],
            src.[combo_filtered_pattern],
            src.[combo_allow_custom_text],
            src.[group_index],
            src.[is_frozen],
            src.[thousand_separator],
            src.[decimal_precision],
            src.[filter_field],
            src.[sort_order],
            src.[column_align],
            src.[is_flex_used],
            src.[flex],
            NULL,
            NULL,
            NULL,
            src.[is_mandatory],
            src.[defaultfield_value],
            src.[sort_direction],
            src.[is_percentage_used],
            src.[combo_type],
            src.[combo_dataparentvaluefield_name],
            src.[is_bulk_apply_used],
            src.[enable_row_validation],
            src.[is_uid_reference],
            src.[hyperlink_enabled],
            src.[hyperlink_id_display_field],
            src.[hyperlink_default_display_text],
            src.[hyperlink_type]
        FROM dbo.k_referential_grids_fields AS src
        WHERE src.id_grid = @source_grid AND src.id_field = @field;
    END;
    ELSE
    BEGIN
        UPDATE dbo.k_referential_grids_fields
        SET is_editable = 0
        WHERE id_grid = @target_grid AND id_field = @field;
    END;

    COMMIT TRANSACTION;

    SELECT id_column, id_grid, id_field, name_column, order_column, is_editable
    FROM dbo.k_referential_grids_fields
    WHERE id_grid = @target_grid AND id_field = @field;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

GO

-- SECTION 09: Initial Division cache refresh
EXEC dbo.SP_RefreshEmployeeCompRoundException;
GO
PRINT N'Bonus Team latest changes deployment completed.';
GO
