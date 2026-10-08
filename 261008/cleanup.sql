/* =================================================================================================
   Sector Business Mapping / Sector Business Rule - cleanup of the grid-based draft (re-runnable)
   Drops the SQL objects created by the earlier grid one-shot scripts:
   grid hook procedures, lookup views, _xhisto tables and id-based draft tables.
   beqom grid metadata is NOT touched - grids are removed manually in the application.
   Afterwards run deploy_sector_business_mapping.sql and deploy_sector_business_rule.sql.
   ================================================================================================= */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_mapping;
	DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_rule;

	DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_sector_lookup;
	DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_org_unit_lookup;
	DROP VIEW IF EXISTS dbo.vPEPSICO_business_split_rule_lookup;
	DROP VIEW IF EXISTS dbo.vPEPSICO_number_of_businesses_lookup;

	DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_mapping_xhisto;
	DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_rule_xhisto;

	-- Id-based drafts (seed data only); new name-based tables are created by the deploy scripts
	IF COL_LENGTH('dbo.PEPSICO_sector_business_mapping', 'id_sector') IS NOT NULL
		DROP TABLE dbo.PEPSICO_sector_business_mapping;

	IF COL_LENGTH('dbo.PEPSICO_sector_business_rule', 'id_sector') IS NOT NULL
		DROP TABLE dbo.PEPSICO_sector_business_rule;

	COMMIT TRANSACTION;
	PRINT 'Cleanup committed.';
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	THROW;
END CATCH;
GO

/* ------------------------------------------------------------------------------------------------- */
/* QUICK CHECK (no rows expected; name-based tables appear only after the deploy scripts)          */
/* ------------------------------------------------------------------------------------------------- */
SELECT o.name, o.type_desc
FROM sys.objects AS o
WHERE o.type IN ('U', 'V', 'P')
	AND (o.name LIKE N'%sector_business%'
		OR o.name IN (N'vPEPSICO_business_split_rule_lookup', N'vPEPSICO_number_of_businesses_lookup'));
GO
