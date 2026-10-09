-- Run after deploying the current mapping, rule configuration and function.
-- Read-only regression cases against the supplied configuration seed.
-- Case labels use business names for readability; function arguments are resolved BTBusinessCode values.
DECLARE @cases TABLE
(
    case_name NVARCHAR(100), comp_group_name NVARCHAR(256),
    step_1 NVARCHAR(255), step_2 NVARCHAR(255), step_3 NVARCHAR(255),
    expected NVARCHAR(MAX)
);
INSERT INTO @cases (case_name, comp_group_name, step_1, step_2, step_3, expected)
VALUES
(N'Common OU', N'Global S&T', N'France', N'Iberia', NULL, N'75% Western Europe / 25% Corporate'),
(N'Common sector, different OU', N'Global S&T', N'France', N'Ukraine', NULL, N'75% EMEA / 25% Corporate'),
(N'Different sectors', N'Global S&T', N'France', N'ANZ Foods', NULL, N'Other'),
(N'Three steps common OU', N'Global R&D', N'France', N'Iberia', N'BeNeLux', N'75% Western Europe / 25% Corporate'),
(N'Three steps different OU', N'Global R&D', N'France', N'Iberia', N'Ukraine', N'75% EMEA / 25% Corporate'),
(N'Full OU', N'EMEA Foods', N'France', N'Iberia', N'BeNeLux', N'100% Western Europe'),
(N'Full sector', N'APAC Foods', N'ANZ Foods', N'IndoChina Foods', N'Greater China Foods', N'100% APAC'),
(N'Single step', N'Global R&D', N'France', NULL, NULL, N'75% France / 25% Corporate'),
(N'Equal steps combine', N'EMEA Foods', N'France', N'France', NULL, N'100% France'),
(N'Weighted split', N'Global R&D', N'France', N'Iberia', NULL, N'37.5% France / 37.5% Iberia / 25% Corporate'),
(N'Weighted split reversed', N'Global R&D', N'Iberia', N'France', NULL, N'37.5% France / 37.5% Iberia / 25% Corporate'),
(N'Equal split reversed', N'EMEA Foods', N'Iberia', N'France', NULL, N'50% France / 50% Iberia'),
(N'Region step selects Corporate', N'Global S&T', N'APAC Foods Region', N'France', NULL, N'100% Corporate'),
(N'No steps', N'Global R&D', NULL, NULL, NULL, N'Other'),
(N'Unmapped business', N'Global R&D', N'__unmapped_bonus_team__', NULL, NULL, N'Other'),
(N'No configured rule', N'EMEA Foods', N'France', NULL, NULL, N'Other');

DECLARE @results TABLE (case_name NVARCHAR(100), expected NVARCHAR(MAX), actual NVARCHAR(MAX), id_comp_group INT);
INSERT INTO @results (case_name, expected, actual, id_comp_group)
SELECT c.case_name, c.expected,
       dbo._fn_get_bonus_team(cg.id_comp_group, b1.business_code, b2.business_code, b3.business_code), cg.id_comp_group
FROM @cases AS c
OUTER APPLY
(
    SELECT MAX(g.idCompGroup) AS id_comp_group
    FROM dbo.PEPSICO_CompGroup AS g WHERE g.CompGroupName = c.comp_group_name
) AS cg
OUTER APPLY
(
    SELECT COALESCE(MIN(b.BTBusinessCode), c.step_1) AS business_code
    FROM dbo.PEPSICO_Bonus_Team_Business AS b WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(b.BTBusinessValue, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = c.step_1
) AS b1
OUTER APPLY
(
    SELECT COALESCE(MIN(b.BTBusinessCode), c.step_2) AS business_code
    FROM dbo.PEPSICO_Bonus_Team_Business AS b WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(b.BTBusinessValue, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = c.step_2
) AS b2
OUTER APPLY
(
    SELECT COALESCE(MIN(b.BTBusinessCode), c.step_3) AS business_code
    FROM dbo.PEPSICO_Bonus_Team_Business AS b WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(b.BTBusinessValue, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = c.step_3
) AS b3;

SELECT case_name, expected, actual, id_comp_group
FROM @results
WHERE id_comp_group IS NULL OR actual IS NULL OR actual <> expected;
IF EXISTS (SELECT 1 FROM @results WHERE id_comp_group IS NULL OR actual IS NULL OR actual <> expected)
    THROW 51000, 'Bonus team regression cases failed; inspect results and deployed seed.', 1;
PRINT 'PASS: 16 bonus team regression cases.';
GO
