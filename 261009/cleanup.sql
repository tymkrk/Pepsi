/*
    Remove obsolete sector_business configuration and grid-draft SQL objects.
    Run only after deploying and validating the new Bonus Team tables, seed data,
    and dbo._fn_get_bonus_team. Old table data is permanently removed.
    The current PEPSICO_bonus_team_* tables and business dictionaries are preserved.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.PEPSICO_bonus_team_business_mapping', N'U') IS NULL
       OR OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule', N'U') IS NULL
    BEGIN
        THROW 51000, 'Deploy the new Bonus Team configuration tables before running cleanup.', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.PEPSICO_bonus_team_business_mapping)
       OR NOT EXISTS (SELECT 1 FROM dbo.PEPSICO_bonus_team_allocation_rule)
    BEGIN
        THROW 51001, 'Load and validate the new Bonus Team configuration before running cleanup.', 1;
    END;

    DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_mapping;
    DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_rule;

    DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_sector_lookup;
    DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_org_unit_lookup;
    DROP VIEW IF EXISTS dbo.vPEPSICO_business_split_rule_lookup;
    DROP VIEW IF EXISTS dbo.vPEPSICO_number_of_businesses_lookup;

    DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_mapping_xhisto;
    DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_rule_xhisto;
    DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_mapping;
    DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_rule;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
