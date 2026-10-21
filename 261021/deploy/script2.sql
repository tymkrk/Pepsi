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
        (N'EMEA', N'MENAPAK', N'Ethiopia Foods', 0),
        (N'EMEA', N'MENAPAK', N'MENAPAK', 0),
        (N'EMEA', N'MENAPAK', N'Middle East Foods', 0),
        (N'EMEA', N'MENAPAK', N'Nigeria Foods', 0),
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
