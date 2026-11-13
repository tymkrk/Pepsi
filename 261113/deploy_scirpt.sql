/* Bonus Team Step 3 deployment -- static T-SQL, run on the intended database.
   Run outside an ambient transaction and outside the overnight ETL window.
   GO separates module definitions; batches commit separately (not an atomic deployment).
   Stop on any error before continuing with later batches.
   The final batch installs the FULL overnight procedure from the repository:
   compare it with the target definition before deployment if that environment has hotfixes.
   No application metadata bindings or external schedules are changed.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
IF @@TRANCOUNT <> 0
    THROW 50001, N'Run deployment outside an existing transaction.', 1;
GO

-- 1. Create the cache if missing.
IF OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PEPSICO_bonus_team_step3_business
    (
        BTBusinessCode NVARCHAR(50) NOT NULL,
        BTBusinessValue NVARCHAR(101) NULL,
        idCompGroup INT NOT NULL,
        BTBusiness_filter_1 NVARCHAR(50) NOT NULL,
        BTBusiness_filter_2 NVARCHAR(50) NOT NULL
    );
END;
GO

-- 2. Replace the legacy clustered cascade index; support both lookup paths.
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business', N'U') IS NULL
        THROW 50001, N'Brak tabeli dbo.PEPSICO_bonus_team_step3_business.', 1;
    IF EXISTS
    (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business')
          AND name = N'IX_PEPSICO_bonus_team_step3_business_cascade' AND type = 1
    )
        DROP INDEX IX_PEPSICO_bonus_team_step3_business_cascade
            ON dbo.PEPSICO_bonus_team_step3_business;
    IF NOT EXISTS
    (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business')
          AND name = N'CX_bonus_team_step3_business_code'
    )
        CREATE CLUSTERED INDEX CX_bonus_team_step3_business_code
            ON dbo.PEPSICO_bonus_team_step3_business
                (BTBusinessCode, idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2);
    IF NOT EXISTS
    (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business')
          AND name = N'IX_bonus_team_step3_business_cascade'
    )
        CREATE NONCLUSTERED INDEX IX_bonus_team_step3_business_cascade
            ON dbo.PEPSICO_bonus_team_step3_business
                (idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2)
            INCLUDE (BTBusinessValue);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- 3. Refresh procedure.
CREATE OR ALTER PROCEDURE dbo.SP_Refresh_bonus_team_step3_business
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Build before publishing: a failed build leaves the previous cache intact.
        SELECT BTBusinessCode, BTBusinessValue, idCompGroup,
            BTBusiness_filter_1, BTBusiness_filter_2
        INTO #step3_business
        FROM
        (
            SELECT
                bcg.BTBusinessCode,
                CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,
                ISNULL(bcg.idCompGroup, 0) AS idCompGroup,
                s1.BTBusinessCode AS BTBusiness_filter_1,
                s2.BTBusinessCode AS BTBusiness_filter_2
            FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb
                ON btb.BTBusinessCode = bcg.BTBusinessCode
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s1
                ON ISNULL(s1.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s2
                ON ISNULL(s2.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)
            WHERE s1.BTBusinessCode <> s2.BTBusinessCode
                AND bcg.BTBusinessCode <> s1.BTBusinessCode
                AND bcg.BTBusinessCode <> s2.BTBusinessCode
                AND NOT EXISTS
                (
                    SELECT 1
                    FROM dbo.PEPSICO_CompGroup AS cg
                    WHERE cg.idCompGroup = bcg.idCompGroup
                        AND cg.CompGroupName IN (N'North America', N'Global S&T')
                )
            UNION ALL

            SELECT DISTINCT
                CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusinessCode,
                CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(100)) AS BTBusinessValue,
                cg.idCompGroup,
                b.BTBusinessCode AS BTBusiness_filter_1,
                CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusiness_filter_2
            FROM dbo.PEPSICO_CompGroup AS cg
            CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
            WHERE cg.CompGroupName = N'North America'
            UNION ALL
            SELECT DISTINCT
                CAST(N'Not Applicable for Global S&T Bonus Design' AS NVARCHAR(50)),
                CAST(N'Not Applicable for Global S&T Bonus Design' AS NVARCHAR(100)),
                cg.idCompGroup,
                s1.BTBusinessCode,
                s2.BTBusinessCode
            FROM dbo.PEPSICO_CompGroup AS cg
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s1
                ON s1.idCompGroup = cg.idCompGroup
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s2
                ON s2.idCompGroup = cg.idCompGroup
            WHERE cg.CompGroupName = N'Global S&T'
                AND s1.BTBusinessCode <> s2.BTBusinessCode
        ) AS source_rows;

        BEGIN TRANSACTION;
        -- TABLOCKX serializes publication; readers never see a partial committed load.
        DELETE FROM dbo.PEPSICO_bonus_team_step3_business WITH (TABLOCKX);
        INSERT INTO dbo.PEPSICO_bonus_team_step3_business
            (BTBusinessCode, BTBusinessValue, idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2)
        SELECT BTBusinessCode, BTBusinessValue, idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2
        FROM #step3_business;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- 4. Load before switching the registered view.
EXEC dbo.SP_Refresh_bonus_team_step3_business;
GO

-- 5. Preserve the registered view contract.
CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step3_business]
AS
-- Keep the registered dropdown contract; expensive combinations are refreshed overnight.
SELECT BTBusinessCode, BTBusinessValue, idCompGroup,
    BTBusiness_filter_1, BTBusiness_filter_2
FROM dbo.PEPSICO_bonus_team_step3_business;
GO

-- 6. Global S&T ignores Step 3.
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
             Corporate GGF with two/three businesses resolves to Corporate.

    20261104 Regional OR rule for two/three businesses distinguishes regional selections:
             one region uses 75% selected sector / 25% Corporate; two or more regions use Corporate.

    Workflow: count nonblank steps -> any-region flag -> configured rule.
    OR rules use a common OU first, otherwise sector_name; unresolved setups return Other.
    */
    -- 20261113 Global S&T uses only Steps 1 and 2, including legacy saved selections.
    IF @comp_round_extended = N'Global S&T'
        SET @Step3 = NULL;

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

    -- Any region business selects region rules, including mixed region/non-region steps.
    SELECT @is_region = MAX(CONVERT(INT, m.is_region))
    FROM @steps AS s
    INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
        ON m.bt_business_code = s.bt_business_code;

    IF @is_region IS NULL
    BEGIN
        IF @comp_round_extended = N'Corporate GGF' AND @number_of_businesses IN (2, 3)
            SET @is_region = 0;
        ELSE
            RETURN @final_bonus_team;
    END;

    DECLARE @has_unmapped_step BIT = 0,
            @has_emea_ou_conflict BIT = 0;

    -- An unmapped step cannot be classified as non-region.
    IF EXISTS
    (
        SELECT 1 FROM @steps AS s
        WHERE s.bt_business_code IS NULL
           OR NULLIF(LTRIM(RTRIM(s.business_name)), N'') IS NULL OR NOT EXISTS
        (
            SELECT 1 FROM dbo.PEPSICO_bonus_team_business_mapping AS m
            WHERE m.bt_business_code = s.bt_business_code
        )
    )
    BEGIN
        SET @has_unmapped_step = 1;
    END;

    -- Different EMEA OUs use their common sector instead of a two-business blend.
    IF
    (
        SELECT COUNT(DISTINCT m.org_unit_name)
        FROM @steps AS s
        INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
            ON m.bt_business_code = s.bt_business_code
        WHERE m.sector_name = N'EMEA'
          AND m.org_unit_name IN (N'East Europe', N'Western Europe', N'MENAPAK')
    ) > 1
    BEGIN
        SET @has_emea_ou_conflict = 1;
    END;

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
    INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
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
        BEGIN
            RETURN N'Other';
        END;

        IF @has_emea_ou_conflict = 1
           AND (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) = 1
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N'EMEA', 100);
        END
        ELSE
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct)
            SELECT business_name, 50 FROM @steps;
        END;
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
            SELECT 1 FROM dbo.PEPSICO_bonus_team_business_mapping AS m
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
            INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
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
    ELSE IF @split_rule = N'100% Corporate'
    BEGIN
        IF @corporate_override = 0
           AND NOT (@comp_round_extended = N'Corporate GGF' AND @number_of_businesses IN (2, 3))
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
            INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
                ON m.bt_business_code = s.bt_business_code
            WHERE m.is_region = 1;

            RETURN CASE WHEN @resolved_team_name IS NOT NULL
                        THEN @resolved_team_name ELSE N'Other' END;
        END;

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
    END
    ELSE
    BEGIN
        RETURN N'Other';
    END;

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

-- 7. Full repository definition of the overnight caller.
CREATE OR ALTER PROCEDURE [dbo].[SP_ETL_PostEligibilityRulesRun_v2]
/******************************************************************************
Purpose: 
	- Refresh all BonusTeam, BonusPlanType, BonusAdjustment, Measure-SubMeasure assignments

Notes:
	- This SP needs to be executed after the Eligibility rules are executed

History:
	20180723	Seyhun Guzel	Created
	20180803	James Mackay	Added Bonus  Approval and Focal Point SPs
	20180813	Seyhun Guzel	Added sp execution logging
	20180821	Sandip Keni		Modified sp execution logging
	20180822	Sandip Keni		Enhanced sp execution logging to capture error
	20180902    James Mackay	Added Focal Point Refresh sps
	20180918	Steve Harrell	Added Load to materialize the vPEPSICO_Transaction_Bonus_Eligibility_Results data
	20181101	James Mackay	Added [SP_Refresh_Populations_All] a second time for security populations
	20181113    James Mackay    Added security user stuff
	20181207	James Mackay	setup comp admin access before hr in case deleted then tree security refresh does not break
	20181215	James Mackay	Added [SP_FocalPointEmpTargetedMeritRefresh]
	20190813    James Mackay    Added sp_refresh_indexes
	20190916	James Mackay	2019-04 Added SP_FocalPointEmpPayComponentIncreaseRefresh
	20190918	James Mackay	moved bonus elig materialisation to beginning of sp JM 20190918
	20191103	James Mackay	added logic to fix comp group teams
	20191109	James Mackay	added email notifications
	20191114	James Mackay	added user id_external_user check	
	20191124    James Mackay    added calls to new bonus optomisation procs
	20191209	James Mackay	called SP_FocalPointICEmpBudgetRefresh
	20191213	James Mackay	added some logic to update user names if they have changed
	20200204	James Mackay	added SP_StatementProcessRefresh
	20200213	James Mackay	added SP_Refresh_Populations_Statements
	20200729    James Mackay    added Stephanie and removed Rico from email
	20200903    James Mackay	added logic  update default user tree
	20201016	James Mackay	added LTI refresh logic
	20210122	James Mackay	added EXEC SP_FocalPointEmpPayComponentIncreaseFinalRefresh NULL, 1
	20210422    James Mackay    disabled summary refresh
	20210709	James Mackay	added SP_FocalPointManagerBudgetRefresh
	20210721	Yoann Schrago	added SP_FocalPointManagerEmpBudgetRefresh
	20210930    James Mackay    added error email
	20210930    James Mackay    added calls to SP_SecurityRefreshUserPayee and SP_SecurityUserRefreshHRPopEC and added error email
	20211108    James Mackay    added call to _sp_aa_refresh_cube_data
	20211208    James Mackay    #53151 added second call for SP_FocalPointManagerBudgetRefresh
	20211229	James Mackay	#52598 added update for FP_LAST_REFRESH_DATETIME
	20220204    James Mackay    enable summary refreshes
	20220506    James Mackay    added uid_tem to k_teams_users
	20220601	Yoann Schrago	changed the order of the LTI refresh logic
	20220902	Yoann Schrago	removed LTI Hierarchy and security refresh SPs as redundant
	20220908    James Mackay    added SP_LTIEligibilityRefresh, SP_LTIEmployeeRefresh, SP_LTI_DLTIGroupRefresh
	20221103	Yoann Schrago	added #71657 SP_LTIManagerEmpBudgetRefresh and SP_LTIManagerBudgetRefresh for lti Budget freeze
	20221118    James Mackay    added mails for duplicate users
	20221128    James Mackay    added status
	20230824    James Mackay    DM2023-01 added dm budget refresh sps
	20230921    Yoann Schrago   #91039 added second call for SP_FocalPointManagerEmpBudgetRefresh,SP_FocalPointManagerEmpDMBudgetRefresh,SP_FocalPointManagerDMBudgetRefresh
	20231110    James Mackay    SYS2023-11 refresh employee attached documents grid
	20240815    James Mackay	zd 112021 B2024-01 added bonus sector forecast refresh logic
	20241031    James Mackay    zd 117419 R/M2024-22 changed order of last values refresh and final pay component refresh - in order to refresh the 
	20241205	Yoann Schrago	zd 120059 remove workaround from 20241204
	20241206	Magda Czaja -	zd 120539 remove HR profile for selected users (security issue)
	20241212	Kamil Roganowicz -	changed refresh indexes procedure from Saturday/Sunday to daily refresh
	20250203	Magda Czaja -	update LTIEligibility Refresh to enhance performance
	20250213	Kamil Roganowicz - enabled SP_Refresh_Populations_Statements
	20250501	Yoann Schrago	disable Summary for new cycle - commented out ___k_transaction_master_earn_check_duplicates
	20250509	Yoann Schrago	commented out k_users refresh during 2025 Cycle opening
	20250513	Yoann Schrago	 ROLLBACK commented out k_users refresh during 2025 Cycle opening
	20250825	Yoann Schrago	B2025-05 add SP_BonusApprovalValuesRefresh
	20251023	Kamil Roganowicz add refreshes SP_LTIManagerEmpBudgetRefresh, SP_LTIManagerBudgetRefresh at the end of the procedure
	20251030	Przemyslaw Kot	turn exec of SP_Refresh_Indexes only on Saturdays and Sundays
	20251117	Yoann Schrago	Add email if population have NULL for LastVersion
	20251128	Kamil Roganowicz add [SP_PEPSICO_OvrdBonusTeam_Refresh]
	20251210	Przemyslaw Kot	add exec of SP_BonusVerificationSetCorrectStatusRefresh
	20251223	Kamil Roganowicz turn on exec of SP_BonusVerificationSetCorrectStatusRefresh
	20251229	Yoann Schrago	Enable Statement refresh SPs
	20260112	Kamil Roganowicz PEPPRTCR25-73 remove ',' from Employee_Name
	20260112	Yoann Schrago	Added refresh of section visibility in Statement. to enable/disable with other SPS Statement related
	20260116	Yoann Schrago	Added SP_refresh_summary_translation_flattened, to enable/disable with other SPs Statement related
	20260212	Yoann Schrago	Added refresh of population used in Summary PDF Generation merge
	20260408    Arkadiusz Sobczak change condition for sending emails for duplicated users
	20260506	Michal Czarnecki	Modified part that updates PEPSICO_EmpAttachedDocument so it follow new archive logic
	20260907	Michal Czarnecki	Added Support members to CC of fail notification
(70) 20261001	Bartosz Ryżak	PEPPRT26-142 add SP_BonusApprovalSnapshotRefresh before SP_BonusApprovalProcessRefresh and SP_BonusApprovalReopenRefresh after SP_BonusVerificationSetCorrectStatusRefresh (snapshot run id passed between them)
(71) 20261001	Bartosz Ryżak	PEPPRT26-142 mail subject / content environment (DEV / TEST / Production) from DB_NAME() in @environment_name
(72) 20261022	Bartosz Ryżak	PEPPRT26-117/142 dispatch pending Override events and conditionally refresh timeline and Comp Group before the existing pipeline
********************************************************************************/
AS
BEGIN

	-- Log SP Execution Start
	DECLARE
		@ProcName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID))+'.'+QUOTENAME(OBJECT_NAME(@@PROCID))
		, @StartTime datetime = GETUTCDATE()
		, @SPLogID INT
		, @environment_name NVARCHAR(128) = --(71)
			CASE DB_NAME()
				WHEN 'peptest' THEN 'TEST'
				WHEN 'pepdev' THEN 'DEV'
				WHEN 'pepprod' THEN 'Production'
				ELSE DB_NAME()
			END
		, @ID_snapshot_run INT -- Bonus Approval snapshot run: SP_BonusApprovalSnapshotRefresh -> SP_BonusApprovalReopenRefresh
		, @event_processed BIT = 0 --(72)
	;

	INSERT INTO dbo.SystemSPLog (ProcName, StartTime, Message) VALUES (@ProcName, @StartTime, 'Started')
	SELECT @SPLogID = SCOPE_IDENTITY()

	BEGIN TRY

--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------

		-- Execute SPs

		--(72)
		EXEC dbo.SP_OvrdBonusTeam_EventDispatch
			@called_by = @ProcName
			, @event_processed = @event_processed OUTPUT
		;
		PRINT '-- AFTER dbo.SP_OvrdBonusTeam_EventDispatch';

		/* refresh ovrd bonus team */
		IF EXISTS (SELECT TOP 1 1 FROM PEPSICO_OvrdBonusTeam WHERE Needs_Insert = 1 OR Needs_Update = 1 OR Needs_Delete = 1)
		BEGIN
			EXEC SP_PEPSICO_OvrdBonusTeam_Refresh
			PRINT '-- AFTER dbo.SP_PEPSICO_OvrdBonusTeam_Refresh';
		END

		/**
		SSIS PepsiCo_Master refreshes the Bonus Timeline before SP_ETL_PostTimelineRefresh.
		If EventDispatch applies an HR Override afterwards, rebuild Timeline and Comp Group again
		so the existing Bonus pipeline uses the new Override dates and team.
		**/
		IF @event_processed = 1
		BEGIN
			EXEC dbo.SP_ETL_LOAD_PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates
				@gpid = NULL
			;
			PRINT '-- AFTER dbo.SP_ETL_LOAD_PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates';

			EXEC dbo.SP_CompGroupPayeesRefreshAll
				@GPID = NULL
			;
			PRINT '-- AFTER dbo.SP_CompGroupPayeesRefreshAll';
		END;

		EXEC SP_BonusEligibilityRefresh NULL -- JM 20191124

		EXEC SP_AssignmentsRefreshAll

		EXEC dbo.SP_TransactionBonusEligibilityResultsRefresh -- JM 20191124

		-- 20261113 Materialize the Step 3 dropdown once per overnight refresh.
		EXEC dbo.SP_Refresh_bonus_team_step3_business;

		-- Bonus Approval 

		EXEC SP_BonusEligiblePayeesRefresh

		--(70)
		EXEC dbo.SP_BonusApprovalSnapshotRefresh
			@idPayeeList = NULL
			, @RefreshAll = 1
			, @snapshot_source = @ProcName
			, @ID_snapshot_run = @ID_snapshot_run OUTPUT
		;
		PRINT '-- AFTER dbo.SP_BonusApprovalSnapshotRefresh';

		EXEC SP_BonusApprovalProcessRefresh NULL, 1

		EXEC SP_BonusApprovalStepsRefresh
		
		EXEC SP_BonusApprovalValuesRefresh -- YS 20250825

		TRUNCATE TABLE PEPSICO_stg_Transaction_Bonus_Eligibility_Results -- JM 20191124 no longer used but can keep just in case
		INSERT PEPSICO_stg_Transaction_Bonus_Eligibility_Results
		SELECT * FROM vPEPSICO_Transaction_Bonus_Eligibility_Results

		TRUNCATE TABLE PEPSICO_Transaction_Bonus_Eligibility_Results
		INSERT PEPSICO_Transaction_Bonus_Eligibility_Results
		SELECT * FROM PEPSICO_stg_Transaction_Bonus_Eligibility_Results

		EXEC SP_BonusVerificationSetCorrectStatusRefresh -- PK 20251210 temporary commented out till tests are still not completed --KR 20251223 turned on

		--(70)
		EXEC dbo.SP_BonusApprovalReopenRefresh
			@ID_snapshot_run = @ID_snapshot_run
			, @debug_flag = 0
		;
		PRINT '-- AFTER dbo.SP_BonusApprovalReopenRefresh';

		EXEC SP_ETL_SetUpdateLevel 400 -- bonus refreshed

		-- Bonus Sector Forecast Refresh


--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------


		DECLARE 
			@SectorForecastGroup_id nvarchar(50),
			@primaryKey_SectorForecastGroup INT = (SELECT TOP 1 id FROM PEPSICO_SectorForecastGroup_CompGroup_ext)

		DECLARE forecast_cur CURSOR FAST_FORWARD FOR
		SELECT SectorForecastGroup_id 
		FROM vPEPSICO_SectorForecastGroup_SectorGroup_lookup 
		WHERE SectorForecastGroup_id <> '0'
		ORDER BY SectorForecastGroup_id

		OPEN forecast_cur

		FETCH NEXT FROM forecast_cur INTO @SectorForecastGroup_id

		WHILE @@FETCH_STATUS = 0
		BEGIN
	
			UPDATE PEPSICO_SectorForecastGroup_CompGroup_ext 
			SET SectorForecastGroup = @SectorForecastGroup_id,
				is_execute = 1

			EXEC [dbo].[SP_Grid_Save_Post_PEPSICO_SectorForecastGroup_CompGroup_ext] NULL, -1, -1, @primaryKey_SectorForecastGroup

			FETCH NEXT FROM forecast_cur INTO @SectorForecastGroup_id

		END
		CLOSE forecast_cur
		DEALLOCATE forecast_cur


--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------


		-- Focal Point

		EXEC SP_FocalPointEligibilityRefresh -- JM 20191124

		EXEC SP_FocalPointEmployeeRefresh 

		EXEC [SP_DM_EligibilityRefresh]

		EXEC SP_FocalPointEmpPayComponentRefresh NULL, 1 

		EXEC [SP_FocalPointBaseRefresh] NULL, NULL, 1 

		EXEC [dbo].[SP_Refresh_Populations_All] -- refresh non security populations

		EXEC SP_FocalPointIncreaseAmountInserts

		EXEC SP_FocalPointEmpTargetedMeritRefresh NULL, 1

		EXEC [dbo].[SP_FocalPointStepsRefresh] 

		EXEC dbo.SP_DM_Emp_Refresh NULL, 1

		EXEC [dbo].[SP_FocalPointProcessRefresh] NULL, 1 
		
		EXEC SP_StatementProcessRefresh --MC enabled 20250218 -- YS disabled 20250512 -- ys 20251229 enable

		EXEC SP_FocalPointWorkflowRefresh 

		EXEC SP_FocalPointEmpPayComponentIncreaseRefresh NULL, 1

		EXEC SP_FocalPointEmpRoundingRefresh 

		EXEC [SP_FocalPointEmpBudgetRefresh]


--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------



		EXEC [SP_FocalPointManagerEmpBudgetRefresh] -- JM 20210816

		EXEC SP_FocalPointManagerBudgetRefresh -- JM 20210709 

		EXEC [SP_FocalPointManagerEmpDMBudgetRefresh] -- JM 20230824

		EXEC [SP_FocalPointManagerDMBudgetRefresh] -- JM 20230824

		EXEC SP_FocalPointValuesRefresh
		--EXEC [SP_FocalPointValuesRefresh_KR_20241204] -- YS 20241205 remove workaround

		EXEC SP_FocalPointEmpCompaRatioRefresh NULL, 1 

		EXEC SP_FocalPointDefaultValuesRefresh NULL, 1 

		EXEC SP_FocalPointEmpPayComponentIncreaseFinalRefresh NULL, 1 -- JM 20210122

		EXEC SP_FocalPointValuesRefresh NULL, 1
		--EXEC [SP_FocalPointValuesRefresh_KR_20241204] NULL, 1 -- YS 20241205 remove workaround

		EXEC SP_FocalPointEmpCompaRatioFinalRefresh NULL, 1 

		-- JM 20241031 changed the order of SP_FocalPointValuesRefresh and SP_FocalPointFinalPayComponentsRefresh - this is so that the Final Salary USD is updated correctly in the new indicator field

		--EXEC SP_FocalPointValuesRefresh NULL, 1

		--EXEC SP_FocalPointFinalPayComponentsRefresh NULL, NULL, 1 

		EXEC SP_FocalPointFinalPayComponentsRefresh NULL, NULL, 1 

		EXEC SP_FocalPointValuesRefresh NULL, 1
		--EXEC [SP_FocalPointValuesRefresh_KR_20241204] NULL, 1 -- YS 20241205 remove workaround

--		EXEC [SP_FocalPointEmpBudgetRefresh]

		EXEC [SP_FocalPointICEmpBudgetRefresh]

		EXEC SP_FocalPointFieldValuesRefresh

		EXEC SP_ETL_SetUpdateLevel 500 -- ratings refreshed

		--------------------------------- LTI Process
		
		EXEC SP_LTIEligibilityRefresh

		EXEC SP_LTIEmployeeRefresh

		DECLARE @idPopLTI INT = (select top 1 idPop from pop_Population where name = 'lti') --YS 20220601

		EXEC SP_Refresh_Populations_All 0, @idPopLTI --YS 20220601 COMMENTED

		EXEC SP_LTIStepsRefresh

		--EXEC SP_LTIWorkflowRefresh -- YS 20220601 COMMENTED

		EXEC SP_LTIProcessRefresh NULL, 1 -- JM 20210218 added as LTI_Emp relies on LTI Process

		EXEC SP_LTIWorkflowRefresh --YS 20220601

		EXEC SP_LTI_Emp_Refresh NULL, 1 

		EXEC SP_LTIProcessRefresh NULL, 1 -- JM could remove but does use LTI A and LTI B from the LTI_Emp

		EXEC SP_LTIManagerEmpBudgetRefresh -- YS 20221103

		EXEC SP_LTIManagerBudgetRefresh -- YS 20221103

		EXEC SP_LTIDefaultValuesRefresh NULL, 1

		EXEC SP_LTI_DLTIGroupRefresh

		EXEC SP_LTIValuesRefresh NULL, 1

		EXEC SP_ETL_SetUpdateLevel 600 -- lti refreshed

		/************************** attahced documents grid ********************/

		--MERGE INTO PEPSICO_EmpAttachedDocument AS t
		--USING (
		--	SELECT DISTINCT
		--		emp.GPID,
		--		CONCAT(py.firstname + ' ', py.lastname) AS Employee_Name
		--	FROM (
		--		SELECT GPID FROM PEPSICO_Process_BonusApproval
		--		UNION ALL
		--		SELECT GPID FROM PEPSICO_Process_FocalPoint
		--		UNION ALL
		--		SELECT GPID FROM PEPSICO_Process_LTI
		--	) AS emp
		--	JOIN py_Payee AS py
		--		ON py.codePayee = emp.gpid
		--) AS s
		--	ON s.GPID = t.GPID

		--WHEN NOT MATCHED THEN INSERT (GPID, Employee_Name) VALUES (s.GPID, s.Employee_Name)

		--WHEN MATCHED AND ISNULL(s.Employee_Name, '-999') <> ISNULL(t.Employee_Name, '-999') THEN UPDATE SET t.Employee_Name = s.Employee_Name;

		MERGE INTO
			dbo.PEPSICO_EmpAttachedDocument t
		USING (
			SELECT DISTINCT
				emp.GPID
				, CONCAT(py.firstname + ' ', py.lastname) AS Employee_Name
			FROM (
				SELECT pba.GPID
				FROM dbo.PEPSICO_Process_BonusApproval pba

				UNION ALL

				SELECT pfp.GPID
				FROM dbo.PEPSICO_Process_FocalPoint pfp

				UNION ALL

				SELECT plti.GPID
				FROM dbo.PEPSICO_Process_LTI plti
			) emp
				INNER JOIN py_Payee py ON
					py.codePayee = emp.gpid
		) s	ON
			s.GPID = t.GPID
			AND t.[year] = (SELECT FiscalYear FROM dbo.vPEPSICO_focalpoint_Parameters)

		WHEN
			NOT MATCHED
		THEN
			INSERT (
				GPID
				, Employee_Name
				, [year]
			)
			VALUES (
				s.GPID
				, s.Employee_Name
				, (SELECT FiscalYear FROM dbo.vPEPSICO_focalpoint_Parameters)
			)

		WHEN
			MATCHED
			AND ISNULL(s.Employee_Name, '-999') <> ISNULL(t.Employee_Name, '-999')
			AND t.is_archived <> 1
		THEN
			UPDATE
			SET
				t.Employee_Name = s.Employee_Name;

		/************************** Hierarchies ********************/

		EXEC [SP_hm_HierarchyRefreshAll]

		--/************************** START Security User ********************/

		EXEC SP_SecurityRefreshUserPayee

		EXEC SP_SecurityUserRefreshHRPopEC

		EXEC [SP_SecurityUserCompAdminRefreshPop] -1 -- parameter is the user

		EXEC [SP_SecurityUserRefreshManager]

		EXEC [SP_SecurityUserRefreshCompAdmin]

		EXEC [SP_SecurityUserRefreshHR]


--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------




		/******************** START check for duplicate users*/

		drop table if exists #user_dup

		select u2.login_user, 0 as is_deleted
		into #user_dup
		from k_users as u
		join k_users as u2 on u2.id_external_user = u.id_external_user and u2.id_user <> u.id_user
		join py_Payee as py on py.idPayee = u.id_external_user
		where u.active_user = 1
		and u2.login_user not in (select login_user from zz_passport_cleanup)-- where is_deleted = 1) --20260408 AS
		and u2.active_user = 0

		IF EXISTS ( SELECT * FROM #user_dup ) 
		BEGIN
			--------------------------------- mail 
			INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount,
					priority, sourceId, typeSource, scheduleDate, isDeleted)
			SELECT
				CONCAT('ATTENTION (', @environment_name, ') Performance Rewards Duplicate Users') AS mailSubject,
				'The Performance Rewards system has some duplicate users that need to be cleaned up' AS mailContent,
				'magda.czaja@ggsitc.com' AS sentTo,
				null AS mailCC,
				null AS mailBCC,
				null AS mailAttach,
				getutcdate() AS createDate,
				null AS sentDate,
				0 AS isSent,
				null AS sendTryCount,
				2 AS priority,
				1 AS sourceId,
				3 AS typeSource,
				getutcdate() AS scheduleDate,
				0 AS isDeleted
			--------------------------------- end mail	
		END	

		IF EXISTS ( select id_user, id_profile from k_users_profiles group by id_user, id_profile having count(1) > 1 )
		BEGIN
			--------------------------------- mail 
			INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount,
					priority, sourceId, typeSource, scheduleDate, isDeleted)
			SELECT
				CONCAT('ATTENTION (', @environment_name, ') Performance Rewards Duplicate User Profiles') AS mailSubject,
				'The Performance Rewards system has some duplicate user profiles that need to be cleaned up' AS mailContent,
				'magda.czaja@ggsitc.com' AS sentTo,
				null AS mailCC,
				null AS mailBCC,
				null AS mailAttach,
				getutcdate() AS createDate,
				null AS sentDate,
				0 AS isSent,
				null AS sendTryCount,
				2 AS priority,
				1 AS sourceId,
				3 AS typeSource,
				getutcdate() AS scheduleDate,
				0 AS isDeleted
			--------------------------------- end mail	
		END	

		---------------------- LTI Hierarchies

		--EXEC SP_hm_HierarchyManagerLTIBuild -- YS 20220902 -- added to [SP_hm_HierarchyRefreshAll]

		--EXEC SP_hm_HierarchyManagerLTIPublish -- YS 20220902 -- added to [SP_hm_HierarchyRefreshAll]

		--EXEC SP_hm_HierarchyHRLTIBuild -- YS 20220902 -- added to [SP_hm_HierarchyRefreshAll]

		--EXEC SP_hm_HierarchyHRLTIPublish -- YS 20220902 -- added to [SP_hm_HierarchyRefreshAll]

		--EXEC SP_hm_HierarchySecurityRefreshManagerLTI -- YS 20220902 -- Called in SP_SecurityUserRefreshManager

		--EXEC SP_hm_HierarchySecurityRefreshHRLTI -- YS 20220902 -- Called in SP_SecurityUserRefreshCompAdmin and SP_SecurityUserRefreshHR

		----------------------- make sure summary tree security can validate -- this can be done better!!

		update tsple
		set tsple.is_validate = 1
		-- select * 
		from k_tree_security_plan_level_exception as tsple
		join k_tree_security_plan_level as tspl
			on tspl.id_tree_security_plan_level = tsple.id_tree_security_plan_level
		join k_tree_security as ts
			on ts.id_tree_security = tspl.id_tree_security
		join hm_NodelinkPublished as n
			on n.id = ts.id_tree_node_published
		where 
			tsple.is_override_workflow_permission = 1
		and n.idTree in (7,8)
		and tsple.is_validate = 1

		------------------------

		-- correct any default user profiles if needed - this should be executed after all user stuff

		; with cte_up as
		(
			select 
				up.id_user,
				MIN(up.id_profile) AS id_profile
			from k_users_profiles AS up
			group by up.id_user
		)

		--select u.id_user, u.login_user, upar.defaultProfileId, up.id_profile
		update upar
		set upar.defaultProfileId = up.id_profile
		from k_users as u
		join k_users_parameters AS upar
			on upar.id = u.id_user_parameter
		join cte_up as up
			on up.id_user = u.id_user
		left join k_users_profiles AS up2
			on up2.id_user = u.id_user
			and up2.id_profile = upar.defaultProfileId
		where 
			up2.idUserProfile IS NULL

		-- set any users without id payee JM 20191114

		update u
		set u.id_external_user = py.idPayee
		from k_users as u
		left join PEPSICO_EmpTimeline_Full AS emp
			on emp.EmailAddr = u.login_user
			and CAST(getdate() AS date) between emp.StartDate and emp.EndDate
		left join py_Payee AS py 
			on py.codePayee = emp.gpid
		where 1 = 1
		and u.id_external_user is null
		and u.active_user = 1
		and u.isadmin_user = 0
		and charindex('@pepsico.com', u.login_user) > 0

		-- refresh teams_users

		insert into k_teams_users (id_team, id_user, uid_team)
		select cgm.id_team, u.id_user, t.uid_team
			--,cg.idCompGroup, cgm.idCompGroup, cgm.id_team, cg.CompGroupName, t.name_team
		from PEPSICO_CompGroupAssignment as cga 
		join py_Payee as py on py.codePayee = cga.gpid
		join k_users as u on u.id_external_user = py.idPayee
		join PEPSICO_CompGroup as cg on cg.idCompGroup = cga.idCompGroup
		join PEPSICO_CompGroupMapBonusEligRules as cgm on cgm.idCompGroup = cg.idCompGroup
		join k_teams as t on t.id_team = cgm.id_team
		left join k_teams_users as tu on tu.id_team = cgm.id_team and tu.id_user = u.id_user
		where tu.idTeamsUsers is null 

		delete from tu
		-- select *  
		from k_teams_users as tu
		join k_users as u on u.id_user = tu.id_user
		join py_Payee as py on py.idPayee = u.id_external_user
		join PEPSICO_CompGroupMapBonusEligRules as cgm on cgm.id_team = tu.id_team
		left join PEPSICO_CompGroupAssignment as cga on cga.idCompGroup = cgm.idCompGroup and cga.GPID = py.codePayee 
		where 
			tu.id_team in (select id_team from PEPSICO_CompGroupMapBonusEligRules)
		and cga.idCompGroupAssignment is null

		-- update user names if they have changed - JM 20191213

		UPDATE u
			SET u.firstname_user = ISNULL(NULLIF(emp.FirstName, ''), u.firstname_user),
				u.lastname_user = ISNULL(NULLIF(emp.LastName, ''), u.lastname_user)
		FROM k_users AS u
		JOIN py_Payee AS py
			ON py.idPayee = u.id_external_user
		JOIN PEPSICO_EmpTimeline_Full AS emp
			ON emp.GPID = py.codePayee
			AND CAST(GETDATE() AS DATE) BETWEEN emp.StartDate AND emp.EndDate
		WHERE
			u.active_user = 1
		AND u.login_user like '%pepsico.com%'
		AND	(	u.firstname_user <> ISNULL(NULLIF(emp.FirstName, ''), u.firstname_user) 
			OR	u.lastname_user <> ISNULL(NULLIF(emp.LastName, ''), u.lastname_user)
			)

		-- update default user tree

		;with cte_user_tree AS
		(
			select  
				u.id_user,
				n.idTree,
				upar.defaultTree,
				ROW_NUMBER() OVER (PARTITION BY u.id_user ORDER BY n.idtree) AS rn
			from k_tree_security as ts
			join k_users_profiles as up
				on up.idUserProfile = ts.id_user_profile
			join k_users as u
				on u.id_user = up.id_user
			join k_users_parameters AS upar
				on upar.id = u.id_user_parameter
			join hm_NodelinkPublished as n 
				on n.id = ts.id_tree_node_published
			where 1 = 1
			and u.active_user = 1
			and up.id_profile = upar.defaultProfileId
		)

		update upar set upar.defaultTree = ut.idTree
		from k_users AS u
		join k_users_parameters AS upar
			on upar.id = u.id_user_parameter
		join cte_user_tree AS ut
			on ut.id_user = u.id_user 
			and ut.rn = 1
		where
			u.active_user = 1
		and u.id_user not in (select id_user from cte_user_tree where defaultTree = idTree)

		/************************** Security User END ********************/

		EXEC [SP_FocalPointManagerEmpBudgetRefresh] -- YS 20230921

		EXEC SP_FocalPointManagerBudgetRefresh -- JM 20211208

		EXEC [SP_FocalPointManagerEmpDMBudgetRefresh] -- YS 20230921

		EXEC [SP_FocalPointManagerDMBudgetRefresh] -- YS 20230921
				
		EXEC SP_LTIManagerEmpBudgetRefresh -- KR 20251023

		EXEC SP_LTIManagerBudgetRefresh -- KR 20251023
--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------


		--exec [_sp_aa_refresh_cube_data] 1

		update PEPSICO_FocalPoint_Parameters set ValueDATETIME = getdate() where ParameterCode = 'FP_LAST_REFRESH_DATETIME'

		--------------------------------- mail 
		INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount,
				priority, sourceId, typeSource, scheduleDate, isDeleted)
		SELECT
			CONCAT('(', @environment_name, ') Performance Rewards Overnight Refresh Completed') AS mailSubject,
			CONCAT('The Performance Rewards overnight refresh has completed (', @environment_name, ' tenant)') AS mailContent,
			'peter.casale@pepsico.com,joanna.glen@pepsico.com,ARMANDO.CERVANTES2@pepsico.com' AS sentTo,
			null AS mailCC,
			'magda.czaja@ggsitc.com,yoann.schrago@beqom.com' AS mailBCC,
			null AS mailAttach,
			getutcdate() AS createDate,
			null AS sentDate,
			0 AS isSent,
			null AS sendTryCount,
			2 AS priority,
			1 AS sourceId,
			3 AS typeSource,
			getutcdate() AS scheduleDate,
			0 AS isDeleted
		--------------------------------- end mail

		EXEC SP_ETL_SetUpdateLevel 700 -- security refreshed

		EXEC [SP_Refresh_Populations_All] 1 -- refresh security populations

		EXEC [SP_BonusApprovalStepsRefresh] 
		
		EXEC [SP_SecurityRemoveHRProfiles]--20241206 Magda Czaja - remove HR profile (security issue ZD#120539)

		exec [_sp_aa_refresh_cube_data] 1

		EXEC SP_EmpSummarySectionRefresh -- YS 20260112 -- 33min to tun

		EXEC SP_refresh_summary_translation_flattened -- YS 20260116
		
		EXEC [SP_Refresh_Populations_Statements]  -- YS disabled 20250512 -- YS 20251229 enable

		DECLARE @idPopStatementAll INT = (select top 1 idPop from pop_Population where name = '2025 - Statement Generation - all - grid') --YS 20260212

		EXEC SP_Refresh_Populations_All 0, @idPopStatementAll --YS 20260212

		IF (SELECT DATEPART(DW, GETDATE())) IN (1,7) -- refresh indexes on Saturday and Sunday
		BEGIN
		--refresh indexes daily
			EXEC SP_Refresh_Indexes
		END


--------------------------------------------------------------------------------------------------------------------------------------
--insert into ___k_transaction_master_earn_check_duplicates (id_cond_earn,id_simulation,counted_values,date_time,id_simulation_current)
--select id_cond_earn,id_simulation, count(*), getdate(), -1
--from k_transaction_master_earn
--group by id_cond_earn , id_simulation
--having count(*) > 1
--------------------------------------------------------------------------------------------------------------------------------------


		--------------------------------- mail 
		INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount,
				priority, sourceId, typeSource, scheduleDate, isDeleted)
		SELECT
			CONCAT('(', @environment_name, ') Performance Rewards Population Refresh Completed') AS mailSubject,
			CONCAT('The Performance Rewards population refresh has completed (', @environment_name, ' tenant)') AS mailContent,
			'magda.czaja@ggsitc.com,yoann.schrago@beqom.com' AS sentTo,
			null AS mailCC,
			null AS mailBCC,
			null AS mailAttach,
			getutcdate() AS createDate,
			null AS sentDate,
			0 AS isSent,
			null AS sendTryCount,
			2 AS priority,
			1 AS sourceId,
			3 AS typeSource,
			getutcdate() AS scheduleDate,
			0 AS isDeleted
		--------------------------------- end mail

		EXEC SP_ETL_SetUpdateLevel 9999 -- finished

		-- Check for Populations without content -- YS 20251117
		IF EXISTS (  select 1 
					 from pop_Population as p 
					 left join pop_VersionContent as vc 
						on vc.idPopVersion = p.lastVersion 
					where name like 'SYSTEM-EC%' 
					and (lastVersion IS NULL 
						OR vc.id IS NULL))
		BEGIN
			--------------------------------- mail 
			INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount,
					priority, sourceId, typeSource, scheduleDate, isDeleted)
			SELECT
				CONCAT('ATTENTION (', @environment_name, ') Performance Rewards Populations issue') AS mailSubject,
				'The Performance Rewards system has some Populations created by the system that need to be cleaned up, LastVersion = NULL or no rows in VersionContent' AS mailContent,
				'magda.czaja@ggsitc.com' AS sentTo,
				null AS mailCC,
				null AS mailBCC,
				null AS mailAttach,
				getutcdate() AS createDate,
				null AS sentDate,
				0 AS isSent,
				null AS sendTryCount,
				2 AS priority,
				1 AS sourceId,
				3 AS typeSource,
				getutcdate() AS scheduleDate,
				0 AS isDeleted
			--------------------------------- end mail	
		END	


		-- Log SP Execution success
		INSERT INTO dbo.SystemSPLog (StartSPLogID, ProcName, StartTime, EndTime, Message) VALUES (@SPLogID, @ProcName, @StartTime, GETUTCDATE(), 'Ended with success');

	END TRY

	BEGIN CATCH		
		-- Log SP Execution failure
		INSERT INTO dbo.SystemSPLog (StartSPLogID, ProcName, StartTime, EndTime, Message) VALUES (@SPLogID, @ProcName, @StartTime, GETUTCDATE(), 'Ended with failure. Error at line ' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE());

		INSERT INTO nc_MailQueue (mailSubject, mailContent, sentTo, mailCC, mailBCC, mailAttach, createDate, sentDate, isSent, sendTryCount, [priority], sourceId, typeSource, scheduleDate, isDeleted)
		SELECT
			CONCAT('ATTENTION (', @environment_name, ') Performance Rewards Overnight Refresh Failed') AS mailSubject,
			CONCAT('The Performance Rewards overnight refresh has failed (', @environment_name, ' tenant)') AS mailContent,
			'magda.czaja@ggsitc.com,yoann.schrago@beqom.com' AS sentTo,
			'michal.czarnecki@beqom.com,arkadiusz.sobczak@beqom.com,krystian.kawa@beqom.com,przemyslaw.kot@beqom.com' AS mailCC,
			null AS mailBCC,
			null AS mailAttach,
			getutcdate() AS createDate,
			null AS sentDate,
			0 AS isSent,
			null AS sendTryCount,
			2 AS priority,
			1 AS sourceId,
			3 AS typeSource,
			getutcdate() AS scheduleDate,
			0 AS isDeleted;

		THROW;
	END CATCH;

END;
GO

-- 8. Deployment inspection.
SELECT DB_NAME() AS deployed_database, COUNT_BIG(*) AS cached_row_count
FROM dbo.PEPSICO_bonus_team_step3_business;
SELECT name AS index_name, type_desc, is_disabled
FROM sys.indexes
WHERE object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business') AND index_id > 0;
GO
