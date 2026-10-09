INSERT INTO dbo.PEPSICO_bonus_team_allocation_rule
    (id_comp_group, number_of_businesses, split_rule, is_region)
SELECT DISTINCT cg.idCompGroup, s.number_of_businesses, s.split_rule, s.is_region
FROM
(
    VALUES
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
);
