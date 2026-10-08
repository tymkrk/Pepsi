/* =================================================================================================
   Sector Business Mapping - one-shot deployment script (re-runnable)
   1. Cleanup of the earlier grid-based draft (lookup view, grid hook procedure, id-based table)
   2. Table   dbo.PEPSICO_sector_business_mapping       (created if missing)
   3. Initial data load (rows already present are skipped)
   Run as one batch in SSMS / Azure Data Studio against the target beqom database.
   ================================================================================================= */

SET NOCOUNT ON;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 1. CLEANUP OF GRID-BASED DRAFT                                                                  */
/* ------------------------------------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_mapping;
DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_org_unit_lookup;
GO

-- Earlier draft stored ids (id_sector / id_org_unit / bt_business_code) and held only seed data, so rebuild it.
IF COL_LENGTH('dbo.PEPSICO_sector_business_mapping', 'id_sector') IS NOT NULL
BEGIN
	DROP TABLE dbo.PEPSICO_sector_business_mapping;
	PRINT 'Dropped id-based draft of dbo.PEPSICO_sector_business_mapping.';
END

DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_mapping_xhisto;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 2. TABLE                                                                                        */
/* ------------------------------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEPSICO_sector_business_mapping', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[PEPSICO_sector_business_mapping](
		[sector_name] [nvarchar](100) NOT NULL,
		[org_unit_name] [nvarchar](100) NULL,
		[business_name] [nvarchar](100) NOT NULL,
		[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_sector_business_mapping_is_region] DEFAULT ((0)),
	 CONSTRAINT [UQ_PEPSICO_sector_business_mapping] UNIQUE CLUSTERED
	(
		[sector_name] ASC,
		[org_unit_name] ASC,
		[business_name] ASC
	)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/* ------------------------------------------------------------------------------------------------- */
/* 3. INITIAL DATA LOAD                                                                            */
/* ------------------------------------------------------------------------------------------------- */
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#seed') IS NOT NULL
	DROP TABLE #seed;

CREATE TABLE #seed
(
	seed_order INT IDENTITY(1,1) NOT NULL,
	sector_name NVARCHAR(100) NOT NULL,
	org_unit_name NVARCHAR(100) NULL,
	business_name NVARCHAR(100) NOT NULL,
	is_region BIT NOT NULL
);

INSERT INTO #seed (sector_name, org_unit_name, business_name, is_region)
VALUES
	-- North America
	('North America', NULL, 'North America', 1),
	('North America', NULL, 'Digital Commerce', 0),
	('North America', NULL, 'Texoma US PO1', 0),
	('North America', NULL, 'US PO1 Kroger', 0),
	('North America', NULL, 'US PO1 Costco', 0),
	('North America', NULL, 'US PO1 Target', 0),
	('North America', NULL, 'US PO1 Dollar General', 0),
	('North America', NULL, 'US PO1 7Eleven', 0),
	('North America', NULL, 'US PO1 Walmart', 0),
	('North America', NULL, 'US PO1 Walmart + Sam''s Club', 0),
	('North America', NULL, 'US PO1 Sam''s Club', 0),
	('North America', NULL, 'US PO1 Strategic Grocery Channel', 0),
	('North America', NULL, 'PBUS', 0),
	('North America', NULL, 'PBUS Northeast', 0),
	('North America', NULL, 'PBUS Atlantic', 0),
	('North America', NULL, 'PBUS Northcentral', 0),
	('North America', NULL, 'PBUS Texoma', 0),
	('North America', NULL, 'PBUS Southeast', 0),
	('North America', NULL, 'PBUS West', 0),
	('North America', NULL, 'PBUS Kroger', 0),
	('North America', NULL, 'PBUS Costco', 0),
	('North America', NULL, 'PBUS Target', 0),
	('North America', NULL, 'PBUS Dollar General', 0),
	('North America', NULL, 'PBUS 7Eleven', 0),
	('North America', NULL, 'PBUS Walmart', 0),
	('North America', NULL, 'PBUS Walmart + Sam''s Club', 0),
	('North America', NULL, 'PBUS Sam''s Club', 0),
	('North America', NULL, 'PBUS Strategic Grocery Channel', 0),
	('North America', NULL, 'PBUS AFH', 0),
	('North America', NULL, 'poppi', 0),
	('North America', NULL, 'PFUS', 0),
	('North America', NULL, 'PFUS Northeast', 0),
	('North America', NULL, 'PFUS Atlantic', 0),
	('North America', NULL, 'PFUS Northcentral', 0),
	('North America', NULL, 'PFUS Texoma', 0),
	('North America', NULL, 'PFUS Southeast', 0),
	('North America', NULL, 'PFUS West', 0),
	('North America', NULL, 'PFUS Kroger', 0),
	('North America', NULL, 'PFUS Costco', 0),
	('North America', NULL, 'PFUS Target', 0),
	('North America', NULL, 'PFUS Dollar General', 0),
	('North America', NULL, 'PFUS 7Eleven', 0),
	('North America', NULL, 'PFUS Walmart', 0),
	('North America', NULL, 'PFUS Walmart + Sam''s Club', 0),
	('North America', NULL, 'PFUS Sam''s Club', 0),
	('North America', NULL, 'PFUS Strategic Grocery Channel', 0),
	('North America', NULL, 'PFUS Quaker', 0),
	('North America', NULL, 'Sabra', 0),
	('North America', NULL, 'Siete', 0),
	('North America', NULL, 'Canada', 0),
	('North America', NULL, 'PBC Canada', 0),
	('North America', NULL, 'PFC Canada', 0),
	('North America', NULL, 'FLC', 0),
	('North America', NULL, 'QFC', 0),
	('North America', NULL, 'FLC SDL / Field Sales Leader', 0),
	('North America', NULL, 'Corporate', 0),
	('North America', NULL, 'Other', 0),
	-- EMEA
	('EMEA', NULL, 'EMEA Region', 1),
	('EMEA', NULL, 'Turkey', 0),
	('EMEA', NULL, 'UKI', 0),
	('EMEA', NULL, 'RBCCA', 0),
	('EMEA', NULL, 'BCCA', 0),
	('EMEA', NULL, 'Russia', 0),
	-- EMEA / East Europe
	('EMEA', 'East Europe', 'East Europe', 0),
	('EMEA', 'East Europe', 'Poland', 0),
	('EMEA', 'East Europe', 'SEEB', 0),
	('EMEA', 'East Europe', 'East Balkans', 0),
	('EMEA', 'East Europe', 'Ukraine', 0),
	-- EMEA / Western Europe
	('EMEA', 'Western Europe', 'Western Europe', 0),
	('EMEA', 'Western Europe', 'France', 0),
	('EMEA', 'Western Europe', 'Iberia', 0),
	('EMEA', 'Western Europe', 'GroW', 0),
	('EMEA', 'Western Europe', 'BeNeLux', 0),
	-- EMEA / MENAPAK
	('EMEA', 'MENAPAK', 'MENAPAK', 0),
	('EMEA', 'MENAPAK', 'Egypt Foods & COBO', 0),
	('EMEA', 'MENAPAK', 'Middle East Foods', 0),
	('EMEA', 'MENAPAK', 'Pakistan Foods', 0),
	('EMEA', 'MENAPAK', 'Ethiopia Foods', 0),
	('EMEA', 'MENAPAK', 'Nigeria Foods', 0),
	('EMEA', 'MENAPAK', 'Southern Africa', 0),
	-- EMEA
	('EMEA', NULL, 'Corporate', 0),
	('EMEA', NULL, 'Other', 0),
	-- APAC
	('APAC', NULL, 'APAC Foods Region', 1),
	('APAC', NULL, 'ANZ Foods', 0),
	('APAC', NULL, 'IndoChina Foods', 0),
	('APAC', NULL, 'Greater China Foods', 0),
	('APAC', NULL, 'Asia Foods', 0),
	('APAC', NULL, 'Indonesia Foods', 0),
	('APAC', NULL, 'Be & Cheery', 0),
	('APAC', NULL, 'GCR Food PO1', 0),
	('APAC', NULL, 'B&C Po1', 0),
	('APAC', NULL, 'Asia Foods PO1', 0),
	('APAC', NULL, 'Corporate', 0),
	('APAC', NULL, 'Other', 0),
	-- LATAM
	('LATAM', NULL, 'LATAM Foods Region', 1),
	('LATAM', NULL, 'PMF', 0),
	('LATAM', NULL, 'PBF', 0),
	('LATAM', NULL, 'South Cone', 0),
	('LATAM', NULL, 'Andean', 0),
	('LATAM', NULL, 'Caricam', 0),
	('LATAM', NULL, 'Venezuela', 0),
	('LATAM', NULL, 'Other', 0),
	-- International Beverages
	('International Beverages', NULL, 'Intl. Beverages', 1),
	('International Beverages', NULL, 'India PO1', 0),
	('International Beverages', NULL, 'India Foods', 0),
	('International Beverages', NULL, 'India Beverages', 0),
	('International Beverages', NULL, 'LATAM FOBO', 0),
	('International Beverages', NULL, 'Europe FOBO', 0),
	('International Beverages', NULL, 'Asia', 0),
	('International Beverages', NULL, 'ANZ FOBO', 0),
	('International Beverages', NULL, 'MEA FOBO', 0),
	('International Beverages', NULL, 'Greater China FOBO', 0),
	('International Beverages', NULL, 'Pakistan FOBO', 0),
	('International Beverages', NULL, 'SSA FOBO', 0),
	('International Beverages', NULL, 'PGCS Global', 0),
	('International Beverages', NULL, 'PGCS Pakistan', 0),
	('International Beverages', NULL, 'PGCS India', 0),
	('International Beverages', NULL, 'PGCS China', 0),
	('International Beverages', NULL, 'PGCS Mexico', 0),
	('International Beverages', NULL, 'PGCS Uruguay', 0),
	('International Beverages', NULL, 'PGCS US', 0),
	('International Beverages', NULL, 'Soda Stream Global', 0),
	('International Beverages', NULL, 'Soda Stream NA', 0),
	('International Beverages', NULL, 'Soda Stream DACH', 0),
	('International Beverages', NULL, 'Soda Stream South EU', 0),
	('International Beverages', NULL, 'Soda Stream North EU', 0),
	('International Beverages', NULL, 'Soda Stream Central EU', 0),
	('International Beverages', NULL, 'Soda Stream ROW', 0),
	('International Beverages', NULL, 'Soda Stream Argentina', 0),
	('International Beverages', NULL, 'Soda Stream Japan', 0),
	('International Beverages', NULL, 'Soda Stream Australia', 0),
	('International Beverages', NULL, 'Soda Stream Israel', 0),
	('International Beverages', NULL, 'Soda Stream South Africa', 0),
	('International Beverages', NULL, 'Soda Stream South Korea', 0),
	('International Beverages', NULL, 'Corporate', 0),
	('International Beverages', NULL, 'Other', 0),
	('International Beverages', NULL, 'Pepsi Lipton Global', 0),
	('International Beverages', NULL, 'Pepsi Lipton Europe', 0),
	('International Beverages', NULL, 'Lipton JV North America', 0),
	('International Beverages', NULL, 'Pepsi Lipton LATAM', 0),
	('International Beverages', NULL, 'Pepsi Lipton AMEA', 0),
	('International Beverages', NULL, 'Pepsi Lipton AMESA', 0),
	('International Beverages', NULL, 'Pepsi Lipton APAC', 0),
	('International Beverages', NULL, 'Pepsi Lipton LATAM Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton NA Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton Europe Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton AMEA Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton APAC Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton AMESA Technical', 0),
	('International Beverages', NULL, 'Pepsi Lipton EU / AMEA Technical', 0);

BEGIN TRY
	BEGIN TRANSACTION;

	INSERT INTO dbo.PEPSICO_sector_business_mapping (sector_name, org_unit_name, business_name, is_region)
	SELECT
		s.sector_name,
		s.org_unit_name,
		s.business_name,
		s.is_region
	FROM #seed AS s
	WHERE NOT EXISTS
		(
			SELECT 1
			FROM dbo.PEPSICO_sector_business_mapping AS m
			WHERE m.sector_name = s.sector_name
				AND ISNULL(m.org_unit_name, '') = ISNULL(s.org_unit_name, '')
				AND m.business_name = s.business_name
		)
	ORDER BY s.seed_order;

	PRINT CONCAT('Inserted rows: ', @@ROWCOUNT);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	THROW;
END CATCH;

DROP TABLE #seed;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 4. QUICK CHECK                                                                                  */
/* ------------------------------------------------------------------------------------------------- */
SELECT
	m.sector_name,
	m.org_unit_name,
	m.business_name,
	m.is_region
FROM dbo.PEPSICO_sector_business_mapping AS m
ORDER BY m.sector_name, m.org_unit_name, m.business_name;
GO
