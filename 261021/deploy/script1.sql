-- Merge source snapshot by names resolved against the target environment.
-- Preserve unmatched target rows except superseded regional rules in the explicit scope below.
-- Skip unresolved dictionary names.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @allocation_seed TABLE
    (
        comp_group_name NVARCHAR(200) NOT NULL,
        number_of_businesses INT NOT NULL,
        split_rule NVARCHAR(200) NOT NULL,
        is_region BIT NOT NULL,
        corporate_override BIT NOT NULL
    );

    INSERT INTO @allocation_seed
        (comp_group_name, number_of_businesses, split_rule, is_region, corporate_override)
    VALUES
        (N'APAC Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'APAC Foods', 1, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'100% Sector', 1, 0),
        (N'APAC Foods', 3, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'APAC Foods', 3, N'100% Sector', 0, 0),
        (N'Corporate GGF', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Corporate GGF', 1, N'100% Sector', 1, 0),
        (N'Corporate GGF', 2, N'100% Sector', 1, 0),
        (N'Corporate GGF', 3, N'100% Sector', 1, 0),
        (N'EMEA Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'EMEA Foods', 1, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'100% Sector', 1, 0),
        (N'EMEA Foods', 3, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'EMEA Foods', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global Procurement', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global Procurement', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'Global Procurement', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global R&D', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 1, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'100% Corporate', 0, 1),
        (N'Global R&D', 3, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global R&D', 3, N'Corporate', 1, 0),
        (N'Global S&T', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global S&T', 1, N'100% Corporate', 0, 1),
        (N'Global S&T', 2, N'100% Corporate', 0, 1),
        (N'Global S&T', 3, N'100% Corporate', 0, 1),
        (N'Global S&T', 1, N'100% 1st Bonus Team', 1, 0),
        (N'Global S&T', 2, N'75% OU / 25% Corporate OR 75% sector / 25% Corporate', 0, 0),
        (N'Global S&T', 2, N'Corporate', 1, 0),
        (N'Global S&T', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global S&T', 3, N'Corporate', 1, 0),
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

    ;WITH unique_comp_group AS
    (
        SELECT CompGroupName, MIN(idCompGroup) AS id_comp_group
        FROM dbo.PEPSICO_CompGroup
        GROUP BY CompGroupName
        HAVING COUNT(DISTINCT idCompGroup) = 1
    )
    MERGE INTO dbo.PEPSICO_bonus_team_allocation_rule WITH (HOLDLOCK) AS target
    USING
    (
        SELECT DISTINCT cg.id_comp_group, s.number_of_businesses, s.split_rule, s.is_region, s.corporate_override
        FROM @allocation_seed AS s
        INNER JOIN unique_comp_group AS cg
            ON cg.CompGroupName = s.comp_group_name
    ) AS source
        ON target.id_comp_group = source.id_comp_group
       AND target.number_of_businesses = source.number_of_businesses
       AND target.is_region = source.is_region
       AND target.split_rule = source.split_rule
    WHEN MATCHED AND target.corporate_override <> source.corporate_override THEN
        UPDATE SET corporate_override = source.corporate_override
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id_comp_group, number_of_businesses, split_rule, is_region, corporate_override)
        VALUES (source.id_comp_group, source.number_of_businesses, source.split_rule, source.is_region, source.corporate_override)
    WHEN NOT MATCHED BY SOURCE
         AND target.is_region = 1
         AND target.number_of_businesses BETWEEN 1 AND 3
         AND target.id_comp_group IN
         (
             SELECT cg.id_comp_group
             FROM unique_comp_group AS cg
             WHERE cg.CompGroupName IN
                 (N'North America', N'EMEA Foods', N'APAC Foods',
                  N'LATAM', N'International Beverages', N'Corporate GGF')
         ) THEN
        DELETE;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
