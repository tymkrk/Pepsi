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
                            with a slash separator, Corporate last, explicit 100%, and Other for unresolved setups.

    Workflow: count nonblank steps -> any step is_region -> configured rule.
    OR rules use a common OU first, otherwise sector_name; unresolved setups return Other.
    */
    DECLARE @comp_group_name NVARCHAR(256),
            @number_of_businesses INT,
            @is_region BIT = 0,
            @rule_count INT,
            @split_rule NVARCHAR(200),
            @common_sector_name NVARCHAR(100),
            @common_ou_name NVARCHAR(100),
            @resolved_team_name NVARCHAR(100),
            @final_bonus_team NVARCHAR(MAX) = N'Other';

    DECLARE @steps TABLE
    (
        step_number INT NOT NULL,
        business_name NVARCHAR(255) NOT NULL
    );

    INSERT INTO @steps (step_number, business_name)
    SELECT s.step_number, LTRIM(RTRIM(s.business_name))
    FROM (VALUES (1, @Step1), (2, @Step2), (3, @Step3)) AS s(step_number, business_name)
    WHERE NULLIF(LTRIM(RTRIM(s.business_name)), N'') IS NOT NULL;

    -- Count supplied steps, including repeated names; NULL/blank steps are ignored.
    SELECT @number_of_businesses = COUNT(*) FROM @steps;

    SELECT @comp_group_name = cg.CompGroupName
    FROM dbo.PEPSICO_CompGroup AS cg
    WHERE cg.idCompGroup = @idCompGroup;

    IF @comp_group_name IS NULL OR @number_of_businesses = 0
    BEGIN
        RETURN @final_bonus_team;
    END;

    -- An unmapped step cannot be classified as non-region.
    IF EXISTS
    (
        SELECT 1 FROM @steps AS s
        WHERE NOT EXISTS
        (
            SELECT 1 FROM dbo.PEPSICO_sector_business_mapping AS m
            WHERE m.business_name = s.business_name
        )
    )
    BEGIN
        RETURN @final_bonus_team;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM @steps AS s
        INNER JOIN dbo.PEPSICO_sector_business_mapping AS m
            ON m.business_name = s.business_name
        WHERE m.is_region = 1
    )
    BEGIN
        SET @is_region = 1;
    END;

    SELECT @rule_count = COUNT(*),
           @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
    FROM dbo.PEPSICO_sector_business_rule AS r
    WHERE r.comp_group_name = @comp_group_name
      AND r.number_of_businesses = @number_of_businesses
      AND r.is_region = @is_region;

    -- No fallback to a different flag or arbitrary candidate.
    IF @rule_count <> 1
    BEGIN
        RETURN @final_bonus_team;
    END;

    DECLARE @team_shares TABLE
    (
        team_name NVARCHAR(255) NOT NULL,
        team_pct DECIMAL(6, 2) NOT NULL
    );

    -- Resolve the common sector/OU only for rules that aggregate mapped businesses.
    IF @split_rule IN
    (
        N'75% OU / 25% Corporate OR 75% sector / 25% Corporate',
        N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate',
        N'100% OU or 100% Sector',
        N'100% Sector'
    )
    BEGIN
        DECLARE @mapped_steps TABLE
        (
            step_number INT NOT NULL,
            sector_name NVARCHAR(100) NOT NULL,
            org_unit_name NVARCHAR(100) NULL
        );

        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT DISTINCT s.step_number, m.sector_name, NULLIF(LTRIM(RTRIM(m.org_unit_name)), N'')
        FROM @steps AS s
        INNER JOIN dbo.PEPSICO_sector_business_mapping AS m
            ON m.business_name = s.business_name;

        -- A business with several sector mappings cannot identify a common sector.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        -- OU takes precedence only in OR rules; 100% Sector always uses sector_name.
        IF @split_rule = N'100% Sector'
        BEGIN
            SET @resolved_team_name = @common_sector_name;
        END
        ELSE
        BEGIN
            SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        END;
    END;

    IF @split_rule = N'75% Bonus Team / 25% Corporate'
    BEGIN
        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 75 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'50% 1st Bonus Team / 50% 2nd Bonus Team'
    BEGIN
        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 50 FROM @steps;
    END
    ELSE IF @split_rule = N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate'
    BEGIN
        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 37.5 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule IN
    (
        N'75% OU / 25% Corporate OR 75% sector / 25% Corporate',
        N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate'
    )
    BEGIN
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'Corporate'
    BEGIN
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
    END
    ELSE IF @split_rule IN (N'100% OU or 100% Sector', N'100% Sector')
    BEGIN
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
