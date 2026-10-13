-- Allow the same allocation rule for both region flags on existing databases.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes AS i
    INNER JOIN sys.index_columns AS ic
        ON ic.object_id = i.object_id AND ic.index_id = i.index_id
    INNER JOIN sys.columns AS c
        ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE i.object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule')
      AND i.is_primary_key = 1
      AND ic.key_ordinal > 0
      AND c.name = N'is_region'
)
BEGIN
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule
        DROP CONSTRAINT PK_PEPSICO_bonus_team_allocation_rule;
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule
        ADD CONSTRAINT PK_PEPSICO_bonus_team_allocation_rule PRIMARY KEY CLUSTERED
        (id_comp_group, number_of_businesses, is_region, split_rule);
END;

INSERT INTO dbo.PEPSICO_bonus_team_allocation_rule
    (id_comp_group, number_of_businesses, split_rule, is_region)
SELECT DISTINCT cg.idCompGroup, s.number_of_businesses, s.split_rule, s.is_region
FROM
(
    VALUES
    -- North America: Step 1 owns 100%; standard mapping/region validation applies.
    ('North America', 1, '100% 1st Bonus Team', 0),
    ('North America', 2, '100% 1st Bonus Team', 0),
    ('North America', 3, '100% 1st Bonus Team', 0),
	-- 1 business
	('Global S&T', 1, '75% Bonus Team / 25% Corporate', 0),
	('Global R&D', 1, '75% Bonus Team / 25% Corporate', 0),
	('Global Procurement', 1, '75% Bonus Team / 25% Corporate', 0),
	-- 2 businesses
	('EMEA Foods', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('APAC Foods', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('LATAM', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('International Beverages', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
	('Global R&D', 2, '37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate', 0),
	('Global S&T', 2, '75% OU / 25% Corporate OR 75% sector / 25% Corporate', 0),
	('Global S&T', 2, 'Corporate', 1),
	('Global Procurement', 2, '50% 1st Bonus Team / 50% 2nd Bonus Team', 0),
    -- 3 businesses
    ('EMEA Foods', 3, '100% OU or 100% Sector', 0),
    ('APAC Foods', 3, '100% Sector', 0),
    ('LATAM', 3, '100% Sector', 0),
    ('International Beverages', 3, '100% Sector', 0),
    ('Global R&D', 3, '75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0),
    ('Global R&D', 3, 'Corporate', 1),
    ('Global S&T', 3, '75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0),
    ('Global S&T', 3, 'Corporate', 1),
    ('Global Procurement', 3, '100% OU or 100% Sector', 0)
) AS s(comp_group_name, number_of_businesses, split_rule, is_region)
INNER JOIN dbo.PEPSICO_CompGroup AS cg
    ON cg.CompGroupName = s.comp_group_name
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
    WHERE r.id_comp_group = cg.idCompGroup
      AND r.number_of_businesses = s.number_of_businesses
      AND r.split_rule = s.split_rule
      AND r.is_region = s.is_region
);

-- Default single-step allocation for CompGroups without a rule for the given region flag.
-- Preserve configured exceptions and make repeated deployments idempotent.
INSERT INTO dbo.PEPSICO_bonus_team_allocation_rule
    (id_comp_group, number_of_businesses, split_rule, is_region)
SELECT cg.idCompGroup, 1, N'100% 1st Bonus Team', region_flag.is_region
FROM dbo.PEPSICO_CompGroup AS cg
CROSS JOIN (VALUES (0), (1)) AS region_flag(is_region)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
    WHERE r.id_comp_group = cg.idCompGroup
      AND r.number_of_businesses = 1
      AND r.is_region = region_flag.is_region
);

