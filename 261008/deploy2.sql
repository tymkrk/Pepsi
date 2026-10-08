/* =================================================================================================
   Sector Business Rule - one-shot deployment script (re-runnable)
   1. Cleanup of the earlier grid-based draft (lookup views, grid hook procedure, id-/sector-based table)
   2. Table   dbo.PEPSICO_sector_business_rule            (created if missing; old 2-column PK is widened)
   3. Initial data load (rows already present are skipped)
   Run as one batch in SSMS / Azure Data Studio against the target beqom database.
   ================================================================================================= */

SET NOCOUNT ON;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 1. CLEANUP OF GRID-BASED DRAFT                                                                  */
/* ------------------------------------------------------------------------------------------------- */
DROP PROCEDURE IF EXISTS dbo.SP_Grid_Save_Post_PEPSICO_sector_business_rule;
DROP VIEW IF EXISTS dbo.vPEPSICO_sector_business_mapping_sector_lookup;
DROP VIEW IF EXISTS dbo.vPEPSICO_business_split_rule_lookup;
DROP VIEW IF EXISTS dbo.vPEPSICO_number_of_businesses_lookup;
GO

-- Earlier drafts stored ids (id_sector / id_rule) or sector_name and were never filled, so rebuild them.
IF COL_LENGTH('dbo.PEPSICO_sector_business_rule', 'id_sector') IS NOT NULL
	OR COL_LENGTH('dbo.PEPSICO_sector_business_rule', 'sector_name') IS NOT NULL
BEGIN
	DROP TABLE dbo.PEPSICO_sector_business_rule;
	PRINT 'Dropped earlier draft of dbo.PEPSICO_sector_business_rule.';
END

DROP TABLE IF EXISTS dbo.PEPSICO_sector_business_rule_xhisto;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 2. TABLE                                                                                        */
/* ------------------------------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEPSICO_sector_business_rule', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[PEPSICO_sector_business_rule](
		[comp_group_name] [nvarchar](256) NOT NULL,
		[number_of_businesses] [int] NOT NULL CONSTRAINT [CK_PEPSICO_sector_business_rule_number_of_businesses] CHECK ([number_of_businesses] BETWEEN 1 AND 3),
		[split_rule] [nvarchar](200) NOT NULL,
		[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_sector_business_rule_is_region] DEFAULT ((0)),
	 CONSTRAINT [PK_PEPSICO_sector_business_rule] PRIMARY KEY CLUSTERED
	(
		[comp_group_name] ASC,
		[number_of_businesses] ASC,
		[split_rule] ASC
	)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

-- Upgrade an existing table; old rows receive the default flag 0.
IF COL_LENGTH('dbo.PEPSICO_sector_business_rule', 'is_region') IS NULL
BEGIN
    ALTER TABLE dbo.PEPSICO_sector_business_rule
        ADD is_region BIT NOT NULL
            CONSTRAINT DF_PEPSICO_sector_business_rule_is_region DEFAULT ((0)) WITH VALUES;
END;
GO
-- Earlier version had PK (comp_group_name, number_of_businesses); one Comp Group + Number of Businesses
-- can have several rules, so the PK also includes split_rule.
IF EXISTS
(
	SELECT 1
	FROM sys.key_constraints AS kc
	WHERE kc.parent_object_id = OBJECT_ID('dbo.PEPSICO_sector_business_rule')
		AND kc.name = 'PK_PEPSICO_sector_business_rule'
		AND NOT EXISTS
		(
			SELECT 1
			FROM sys.index_columns AS ic
			INNER JOIN sys.columns AS c
				ON c.object_id = ic.object_id
				AND c.column_id = ic.column_id
			WHERE ic.object_id = kc.parent_object_id
				AND ic.index_id = kc.unique_index_id
				AND c.name = 'split_rule'
		)
)
BEGIN
	ALTER TABLE dbo.PEPSICO_sector_business_rule DROP CONSTRAINT PK_PEPSICO_sector_business_rule;
	ALTER TABLE dbo.PEPSICO_sector_business_rule ADD CONSTRAINT PK_PEPSICO_sector_business_rule
		PRIMARY KEY CLUSTERED (comp_group_name ASC, number_of_businesses ASC, split_rule ASC);
	PRINT 'Widened PK_PEPSICO_sector_business_rule to (comp_group_name, number_of_businesses, split_rule).';
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
	comp_group_name NVARCHAR(256) NOT NULL,
	number_of_businesses INT NOT NULL,
	split_rule NVARCHAR(200) NOT NULL, is_region BIT NOT NULL
);

INSERT INTO #seed (comp_group_name, number_of_businesses, split_rule, is_region)
VALUES
	-- 1 business
	('Global S&T', 1, '75% Bonus Team / 25% Corporate', 0),
	('Global R&D', 1, '75% Bonus Team / 25% Corporate', 0),
	('Global Procurement', 1, '75% Bonus Team / 25% Corporate', 0),
	-- 2 businesses
	('EMEA', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('APAC', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('LATAM', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('International Beverages', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('Global R&D', 2, '37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate', 0),
	('Global S&T', 2, '75% OU / 25% Corporate OR 75% sector / 25% Corporate', 0),
	('Global S&T', 2, 'Corporate', 1),
	('Global Procurement', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
    -- 3 businesses: user-supplied rules; OR remains part of the configured text.
    ('EMEA', 3, '100% OU or 100% Sector', 0),
    ('APAC', 3, '100% Sector', 0),
    ('LATAM', 3, '100% Sector', 0),
    ('International Beverages', 3, '100% Sector', 0),
    ('Global R&D', 3, '75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0),
    ('Global R&D', 3, 'Corporate', 1),
    ('Global S&T', 3, '75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0),
    ('Global S&T', 3, 'Corporate', 1),
    ('Global Procurement', 3, '100% OU or 100% Sector', 0);

BEGIN TRY
	BEGIN TRANSACTION;

	INSERT INTO dbo.PEPSICO_sector_business_rule (comp_group_name, number_of_businesses, split_rule, is_region)
	SELECT
		s.comp_group_name,
		s.number_of_businesses,
		s.split_rule,
		s.is_region
	FROM #seed AS s
	WHERE NOT EXISTS
		(
			SELECT 1
			FROM dbo.PEPSICO_sector_business_rule AS r
			WHERE r.comp_group_name = s.comp_group_name
				AND r.number_of_businesses = s.number_of_businesses
				AND r.split_rule = s.split_rule
		)
	ORDER BY s.seed_order;

	PRINT CONCAT('Inserted rows: ', @@ROWCOUNT);

    -- Synchronize flags for existing seed rows as well as newly inserted rows.
    UPDATE r
    SET r.is_region = s.is_region
    FROM dbo.PEPSICO_sector_business_rule AS r
    INNER JOIN #seed AS s
        ON s.comp_group_name = r.comp_group_name
       AND s.number_of_businesses = r.number_of_businesses
       AND s.split_rule = r.split_rule
    WHERE r.is_region <> s.is_region;
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	THROW;
END CATCH;

-- Comp Group names from the seed list not found in dbo.PEPSICO_CompGroup (any FiscalYear)
SELECT DISTINCT
	'NOT FOUND IN PEPSICO_CompGroup' AS [check],
	s.comp_group_name
FROM #seed AS s
WHERE NOT EXISTS
(
	SELECT 1
	FROM dbo.PEPSICO_CompGroup AS cg
	WHERE cg.CompGroupName = s.comp_group_name
)
ORDER BY s.comp_group_name;

DROP TABLE #seed;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 4. QUICK CHECK                                                                                  */
/* ------------------------------------------------------------------------------------------------- */
SELECT
	r.comp_group_name,
	r.number_of_businesses,
	r.split_rule,
	r.is_region
FROM dbo.PEPSICO_sector_business_rule AS r
ORDER BY r.number_of_businesses, r.comp_group_name, r.split_rule;
GO

