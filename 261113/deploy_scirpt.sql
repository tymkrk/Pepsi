/* Bonus Team Step 3 deployment. Run the WHOLE script in the intended database in SSMS.
   No SQLCMD mode, external files or scheduler creation required.
   Transactional and repeatable. Preserves the deployed overnight procedure except
   for inserting the refresh call before its Bonus Approval section.
   Run outside an existing transaction and outside the overnight ETL window.
   Daily frequency follows the existing ETL schedule, already checked separately.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

IF @@TRANCOUNT <> 0
    THROW 51000, 'Run deployment outside an existing transaction.', 1;
IF OBJECT_ID(N'dbo.SP_ETL_PostEligibilityRulesRun_v2', N'P') IS NULL
    THROW 51000, 'Overnight procedure is missing; wrong database or incomplete baseline.', 1;
IF OBJECT_ID(N'dbo.vPEPSICO_bonus_team_step3_business', N'V') IS NULL
 OR OBJECT_ID(N'dbo._fn_get_bonus_team', N'FN') IS NULL
    THROW 51000, 'Existing Step 3 view/function is missing.', 1;

DECLARE @etl NVARCHAR(MAX) = OBJECT_DEFINITION(OBJECT_ID(N'dbo.SP_ETL_PostEligibilityRulesRun_v2')),
    @anchor NVARCHAR(200) = N'EXEC SP_BonusEligiblePayeesRefresh',
    @refresh NVARCHAR(200) = N'SP_Refresh_bonus_team_step3_business',
    @position INT;
IF @etl IS NULL THROW 51000, 'Cannot read overnight procedure definition.', 1;
IF CHARINDEX(@refresh, @etl) = 0
BEGIN
    SET @position = CHARINDEX(@anchor, @etl);
    IF @position = 0 OR CHARINDEX(@anchor, @etl, @position + LEN(@anchor)) > 0
        THROW 51000, 'Expected a single Bonus Approval anchor; no changes made.', 1;
    SET @etl = STUFF(@etl, @position, 0,
        N'EXEC dbo.SP_Refresh_bonus_team_step3_business;' + NCHAR(13) + NCHAR(10) + NCHAR(9) + NCHAR(9));
    SET @position = CHARINDEX(N'PROCEDURE', UPPER(@etl));
    IF @position = 0 THROW 51000, 'Unsupported overnight procedure header.', 1;
    SET @etl = N'ALTER ' + SUBSTRING(@etl, @position, LEN(@etl));
END
ELSE
    SET @etl = NULL; -- Repeat deployment: refresh call already present.

BEGIN TRY
    BEGIN TRANSACTION;
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
    IF NOT EXISTS
    (
        SELECT 1 FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_step3_business')
          AND name = N'IX_PEPSICO_bonus_team_step3_business_cascade'
    )
        CREATE CLUSTERED INDEX IX_PEPSICO_bonus_team_step3_business_cascade
            ON dbo.PEPSICO_bonus_team_step3_business
                (idCompGroup, BTBusiness_filter_1, BTBusiness_filter_2, BTBusinessCode);

    EXEC sys.sp_executesql N'CREATE OR ALTER PROCEDURE dbo.SP_Refresh_bonus_team_step3_business
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
                CASE WHEN btb.BTBusinessValue = N''Other'' THEN btb.BTBusinessValue ELSE CONCAT(N'' '', btb.BTBusinessValue) END AS BTBusinessValue,
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
                        AND cg.CompGroupName IN (N''North America'', N''Global S&T'')
                )
            UNION ALL

            SELECT DISTINCT
                CAST(N''Not Applicable for North America Bonus Design'' AS NVARCHAR(50)) AS BTBusinessCode,
                CAST(N''Not Applicable for North America Bonus Design'' AS NVARCHAR(100)) AS BTBusinessValue,
                cg.idCompGroup,
                b.BTBusinessCode AS BTBusiness_filter_1,
                CAST(N''Not Applicable for North America Bonus Design'' AS NVARCHAR(50)) AS BTBusiness_filter_2
            FROM dbo.PEPSICO_CompGroup AS cg
            CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
            WHERE cg.CompGroupName = N''North America''
            UNION ALL
            SELECT DISTINCT
                CAST(N''Not Applicable for Global S&T Bonus Design'' AS NVARCHAR(50)),
                CAST(N''Not Applicable for Global S&T Bonus Design'' AS NVARCHAR(100)),
                cg.idCompGroup,
                s1.BTBusinessCode,
                s2.BTBusinessCode
            FROM dbo.PEPSICO_CompGroup AS cg
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s1
                ON s1.idCompGroup = cg.idCompGroup
            INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s2
                ON s2.idCompGroup = cg.idCompGroup
            WHERE cg.CompGroupName = N''Global S&T''
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
END;';

    -- Populate before changing the registered view. A failure rolls back the deployment.
    EXEC sys.sp_executesql N'EXEC dbo.SP_Refresh_bonus_team_step3_business;';

    EXEC sys.sp_executesql N'CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step3_business]
AS
-- Keep the registered dropdown contract; expensive combinations are refreshed overnight.
SELECT BTBusinessCode, BTBusinessValue, idCompGroup,
    BTBusiness_filter_1, BTBusiness_filter_2
FROM dbo.PEPSICO_bonus_team_step3_business;';
    EXEC sys.sp_executesql N'CREATE OR ALTER FUNCTION [dbo].[_fn_get_bonus_team]
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
    IF @comp_round_extended = N''Global S&T''
        SET @Step3 = NULL;

    DECLARE @number_of_businesses INT,
            @is_region BIT = 0,
            @rule_count INT,
            @split_rule NVARCHAR(200),
            @corporate_override BIT = 0,
            @common_sector_name NVARCHAR(100),
            @common_ou_name NVARCHAR(100),
            @resolved_team_name NVARCHAR(100),
            @final_bonus_team NVARCHAR(MAX) = N''Other'';

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
            NCHAR(160), N'' ''), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) AS business_name
    ) AS n
    OUTER APPLY
    (
        SELECT CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessCode) END AS bt_business_code,
               CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessValue) END AS business_name
        FROM dbo.PEPSICO_Bonus_Team_Business AS d
        WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(d.BTBusinessValue,
            NCHAR(160), N'' ''), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = n.business_name
    ) AS b
    WHERE NULLIF(n.business_name, N'''') IS NOT NULL;

    -- Count supplied steps, including repeated names; NULL/blank steps are ignored.
    SELECT @number_of_businesses = COUNT(*) FROM @steps;

    -- No correction selected: let OnChange fall back to the preassigned bonus team.
    IF @number_of_businesses = 0
    BEGIN
        RETURN NULL;
    END;

    IF NOT EXISTS
    (
        SELECT 1 WHERE NULLIF(LTRIM(RTRIM(@comp_round_extended)), N'''') IS NOT NULL
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
        IF @comp_round_extended = N''Corporate GGF'' AND @number_of_businesses IN (2, 3)
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
           OR NULLIF(LTRIM(RTRIM(s.business_name)), N'''') IS NULL OR NOT EXISTS
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
        WHERE m.sector_name = N''EMEA''
          AND m.org_unit_name IN (N''East Europe'', N''Western Europe'', N''MENAPAK'')
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
    SELECT DISTINCT s.step_number, m.sector_name, NULLIF(LTRIM(RTRIM(m.org_unit_name)), N'''')
    FROM @steps AS s
    INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
        ON m.bt_business_code = s.bt_business_code
    WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N'' ''))) <> N''Corporate'';


    -- Corporate-specific rules take priority for the selected step count.
    -- Their region flag is ignored; normal allocation excludes override rows.
    SET @rule_count = 0;
    IF EXISTS
    (
        SELECT 1 FROM @steps
        WHERE LTRIM(RTRIM(REPLACE(business_name, NCHAR(160), N'' ''))) = N''Corporate''
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

    IF @split_rule = N''75% Bonus Team / 25% Corporate''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 75 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N''Corporate'', 25);
    END
    ELSE IF @split_rule = N''100% 1st Bonus Team''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 100 FROM @steps WHERE step_number = 1;
    END
    ELSE IF @split_rule = N''50% 1st Bonus Team / 50% 2nd Bonus Team''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        IF @has_emea_ou_conflict = 1
           AND (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) = 1
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N''EMEA'', 100);
        END
        ELSE
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct)
            SELECT business_name, 50 FROM @steps;
        END;
    END
    ELSE IF @split_rule = N''37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 37.5 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N''Corporate'', 25);
    END
    ELSE IF @split_rule = N''75% OU / 25% Corporate OR 75% sector / 25% Corporate''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N''Other'';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N'' ''))) = N''Corporate'';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N''Corporate'', 25);
    END
    ELSE IF @split_rule = N''75% Sector / 25% Corporate OR 75% OU / 25% Corporate''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N''Other'';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N'' ''))) = N''Corporate'';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N''Corporate'', 25);
    END
    ELSE IF @split_rule = N''75% Selected Region / 25% Corporate OR 100% Corporate''
    BEGIN
        IF @has_unmapped_step = 1 OR @number_of_businesses NOT IN (2, 3)
        BEGIN
            RETURN N''Other'';
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
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N''Corporate'', 100);
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
                RETURN N''Other'';

            INSERT INTO @team_shares (team_name, team_pct)
            VALUES (@resolved_team_name, 75), (N''Corporate'', 25);
        END
        ELSE
            RETURN N''Other'';
    END
    ELSE IF @split_rule = N''100% Corporate''
    BEGIN
        IF @corporate_override = 0
           AND NOT (@comp_round_extended = N''Corporate GGF'' AND @number_of_businesses IN (2, 3))
           AND @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        INSERT INTO @team_shares (team_name, team_pct) VALUES (N''Corporate'', 100);
    END
    ELSE IF @split_rule = N''100% OU or 100% Sector''
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N''Other'';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N'' ''))) = N''Corporate'';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
    END
    ELSE IF @split_rule = N''100% Sector''
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
                        THEN @resolved_team_name ELSE N''Other'' END;
        END;

        IF @has_unmapped_step = 1
        BEGIN
            RETURN N''Other'';
        END;

        SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT sector_name) = 1
                                         THEN MAX(sector_name) END
        FROM @mapped_steps;
        IF @resolved_team_name IS NULL
        BEGIN
            RETURN N''Other'';
        END;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
    END
    ELSE
    BEGIN
        RETURN N''Other'';
    END;

    -- Merge repeated teams, omit 100%, retain blend percentages and keep Corporate last.
    IF EXISTS (SELECT 1 FROM @team_shares)
    BEGIN
        SELECT @final_bonus_team = STRING_AGG
        (
            CAST
            (
                CASE WHEN t.team_pct = 100 THEN N''''
                     ELSE CASE WHEN t.team_pct = FLOOR(t.team_pct)
                     THEN CONVERT(NVARCHAR(10), CONVERT(INT, t.team_pct))
                     ELSE CONVERT(NVARCHAR(10), CONVERT(DECIMAL(6, 1), t.team_pct))
                     END + N''% ''
                END + t.team_name AS NVARCHAR(MAX)
            ), N'' / ''
        ) WITHIN GROUP (ORDER BY CASE WHEN t.team_name = N''Corporate'' THEN 1 ELSE 0 END, t.team_name)
        FROM
        (
            SELECT team_name, SUM(team_pct) AS team_pct
            FROM @team_shares
            GROUP BY team_name
        ) AS t;
    END;

    RETURN @final_bonus_team;
END;';

    IF @etl IS NOT NULL EXEC sys.sp_executesql @etl;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;

SELECT DB_NAME() AS deployed_database, COUNT_BIG(*) AS cached_row_count
FROM dbo.PEPSICO_bonus_team_step3_business;
PRINT 'SUCCESS: Step 3 cache loaded, view/function deployed, overnight refresh connected.';
