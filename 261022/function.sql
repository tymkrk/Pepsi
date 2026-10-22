CREATE FUNCTION [dbo].[_fn_get_bonus_team]
(
    @idCompGroup INT,
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
        SELECT 1 FROM dbo.PEPSICO_CompGroup AS cg WHERE cg.idCompGroup = @idCompGroup
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

    -- Different EMEA OUs must not be combined into EMEA or split between teams.
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
        WHERE r.id_comp_group = @idCompGroup
          AND r.number_of_businesses = @number_of_businesses
          AND r.corporate_override = 1;
    END;

    IF @rule_count = 0
    BEGIN
        SET @corporate_override = 0;
        SELECT @rule_count = COUNT(*),
               @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
        FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
        WHERE r.id_comp_group = @idCompGroup
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
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 75 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'100% 1st Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 100 FROM @steps WHERE step_number = 1;
    END
    ELSE IF @split_rule = N'50% 1st Bonus Team / 50% 2nd Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 50 FROM @steps;
    END
    ELSE IF @split_rule = N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 37.5 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% OU / 25% Corporate OR 75% sector / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
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
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
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
    ELSE IF @split_rule = N'100% Corporate'
    BEGIN
        IF @corporate_override = 0
           AND (@has_unmapped_step = 1 OR @has_emea_ou_conflict = 1)
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
    END
    ELSE IF @split_rule = N'100% OU or 100% Sector'
    BEGIN
        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
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
                        THEN N'100% ' + @resolved_team_name ELSE N'Other' END;
        END;

        IF @has_unmapped_step = 1 OR @has_emea_ou_conflict = 1
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

    -- Merge repeated teams, retain all percentages, sort team names alphabetically, and keep Corporate last.
    IF EXISTS (SELECT 1 FROM @team_shares)
    BEGIN
        SELECT @final_bonus_team = STRING_AGG
        (
            CAST
            (
                CASE WHEN t.team_pct = FLOOR(t.team_pct)
                     THEN CONVERT(NVARCHAR(10), CONVERT(INT, t.team_pct))
                     ELSE CONVERT(NVARCHAR(10), CONVERT(DECIMAL(6, 1), t.team_pct))
                END + N'% ' + t.team_name AS NVARCHAR(MAX)
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
