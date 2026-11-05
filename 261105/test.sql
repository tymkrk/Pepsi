/* Post-deployment smoke tests: run this whole file in the deployed database in SSMS.
Plain T-SQL; no SQLCMD mode. No persistent writes, no refresh, no OnChange execution.
Some cases deliberately exercise invalid/repeated UI selections at function level.
A FAIL can indicate missing/different target configuration; inspect actual vs expected.
*/
SET NOCOUNT ON;

DECLARE @cases TABLE
(
    comp_group_name NVARCHAR(200),
    step_1 NVARCHAR(100),
    step_2 NVARCHAR(100),
    step_3 NVARCHAR(100),
    expected NVARCHAR(500)
);

INSERT INTO @cases VALUES
    (N'Global Procurement', N'Poland', NULL, NULL, N'Poland'),
    (N'Global Procurement', N'Corporate', NULL, NULL, N'Corporate'),
    (N'Global Procurement', N'APAC Foods Region', NULL, NULL, N'75% APAC Foods Region / 25% Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'Poland', N'France', N'75% APAC / 25% Corporate'),
    (N'Global S&T', N'Poland', N'France', N'APAC Foods Region', N'75% APAC / 25% Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'EMEA Region', N'Poland', N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'EMEA Region', N'Poland', N'Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'APAC Foods Region', N'Poland', N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'EMEA Region', N'APAC Foods Region', N'Corporate'),
    (N'Global R&D', N'Poland', N'France', N'Ukraine', N'75% EMEA / 25% Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'Corporate', N'Poland', N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'Poland', N'Other', N'Other'),
    (N'Global R&D', N'APAC Foods Region', N'Poland', NULL, N'75% APAC / 25% Corporate'),
    (N'Global R&D', N'Poland', N'APAC Foods Region', NULL, N'75% APAC / 25% Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'Poland', NULL, N'75% APAC / 25% Corporate'),
    (N'Global S&T', N'Poland', N'APAC Foods Region', NULL, N'75% APAC / 25% Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'EMEA Region', NULL, N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'EMEA Region', NULL, N'Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'APAC Foods Region', NULL, N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'APAC Foods Region', NULL, N'Corporate'),
    (N'Global S&T', N'APAC Foods Region', N'Corporate', NULL, N'Corporate'),
    (N'Global R&D', N'APAC Foods Region', N'Other', NULL, N'Other'),
    (N'Global S&T', N'APAC Foods Region', N'Other', NULL, N'Other'),
    (N'EMEA Foods', N'Poland', N'France', NULL, N'EMEA'),
    (N'EMEA Foods', N'Poland', N'Other', NULL, N'Other'),
    (N'EMEA Foods', N'Poland', N'Ukraine', NULL, N'50% Poland / 50% Ukraine'),
    (N'EMEA Foods', N'Poland', N'France', N'APAC Foods Region', N'APAC'),
    (N'EMEA Foods', N'EMEA Region', N'APAC Foods Region', NULL, N'Other'),
    (N'EMEA Foods', N'EMEA Region', N'Other', NULL, N'EMEA'),
    (N'Corporate GGF', N'Poland', N'France', NULL, N'Corporate'),
    (N'Corporate GGF', N'Other', N'Other', NULL, N'Corporate'),
    (N'Corporate GGF', N'APAC Foods Region', N'Other', NULL, N'Corporate'),
    (N'Corporate GGF', N'Poland', NULL, NULL, N'Poland'),
    (N'North America', N'Poland', NULL, NULL, N'Poland'),
    (N'Global Procurement', N'Poland', N'Poland', NULL, N'Poland'),
    (N'Global R&D', N'Poland', N'France', NULL, N'37.5% France / 37.5% Poland / 25% Corporate'),
    (N'Global S&T', N'Corporate', NULL, NULL, N'Corporate'),
    (N'Global S&T', N'Corporate', N'Poland', NULL, N'Corporate'),
    (N'Global S&T', N'Poland', N'Corporate', NULL, N'Corporate'),
    (N'Global S&T', N'Poland', N'France', N'Corporate', N'Corporate'),
    (N'Global S&T', N'Corporate', N'Other', NULL, N'Corporate'),
    (N'Global S&T', N'Poland', NULL, NULL, N'75% Poland / 25% Corporate'),
    (N'Global R&D', N'Corporate', NULL, NULL, N'Corporate'),
    (N'Global R&D', N'Corporate', N'Poland', NULL, N'Corporate'),
    (N'Global R&D', N'Poland', N'Corporate', NULL, N'Corporate'),
    (N'Global R&D', N'Poland', N'France', N'Corporate', N'Corporate'),
    (N'Global R&D', N'Corporate', N'APAC Foods Region', NULL, N'Corporate'),
    (N'Global R&D', N'Corporate', N'Other', NULL, N'Corporate'),
    (N'Global R&D', N'Poland', NULL, NULL, N'75% Poland / 25% Corporate'),
    (N'Global Procurement', N'Corporate', N'Poland', NULL, N'Corporate'),
    (N'EMEA Foods', N'Corporate', N'Poland', NULL, N'Corporate'),
    (N'EMEA Foods', N'Corporate', N'Poland', N'France', N'Corporate'),
    (N'Global Procurement', N'APAC Foods Region', N'Corporate', N'Poland', N'Corporate'),
    (N'Global S&T', NULL, NULL, NULL, NULL),
    (N'EMEA Foods', N'  Poland  ', N'', NULL, N'Poland'),
    (N'Global S&T', N' ', N'', NULL, NULL),
    (N'EMEA Foods', N'Ukraine', N'Poland', NULL, N'50% Poland / 50% Ukraine'),
    (N'EMEA Foods', N'Poland', N'Ukraine', N'Poland', N'East Europe'),
    (N'__UNKNOWN_ROUND__', N'Poland', NULL, NULL, N'Other'),
    (N'EMEA Foods', N'__UNKNOWN_BUSINESS__', NULL, NULL, N'Other');

DECLARE @results TABLE
(
    comp_round_extended NVARCHAR(256), step_1 NVARCHAR(100),
    step_2 NVARCHAR(100), step_3 NVARCHAR(100),
    expected NVARCHAR(500), actual NVARCHAR(MAX), passed BIT
);
INSERT INTO @results
SELECT c.comp_group_name, c.step_1, c.step_2, c.step_3, c.expected, a.actual,
    CASE WHEN a.actual = c.expected
           OR (a.actual IS NULL AND c.expected IS NULL) THEN 1 ELSE 0 END
FROM @cases AS c
CROSS APPLY (VALUES (dbo._fn_get_bonus_team(c.comp_group_name,
    c.step_1, c.step_2, c.step_3))) AS a(actual);

SELECT CASE WHEN passed = 1 THEN N'PASS' ELSE N'FAIL' END AS test_status,
       comp_round_extended, step_1, step_2, step_3, expected, actual
FROM @results
ORDER BY passed, comp_round_extended, step_1, step_2, step_3;
SELECT DB_NAME() AS database_name, COUNT(*) AS total_cases,
       SUM(CONVERT(INT, passed)) AS passed_cases,
       SUM(CASE WHEN passed = 0 THEN 1 ELSE 0 END) AS failed_cases
FROM @results;

-- Check every published Division exception against its rule and lookup function.
-- Empty cache is reported explicitly; it is not proof that Division routing was tested.
SELECT COUNT(*) AS cached_exceptions,
       MIN(refreshed_at) AS oldest_refresh_utc, MAX(refreshed_at) AS newest_refresh_utc
FROM dbo.PEPSICO_EmployeeCompRoundException;

SELECT e.id_step, e.id_comp_group, e.division_code,
       e.comp_round_extended AS cached_round, r.comp_round_extended AS configured_round,
       dbo._ufn_get_comp_round_extended(e.id_step, e.id_comp_group) AS resolved_round
FROM dbo.PEPSICO_EmployeeCompRoundException AS e
LEFT JOIN dbo.PEPSICO_CompRoundExtendedRule AS r
    ON r.id_comp_group = e.id_comp_group AND r.division_code = e.division_code
WHERE r.id IS NULL OR r.comp_round_extended <> e.comp_round_extended
   OR dbo._ufn_get_comp_round_extended(e.id_step, e.id_comp_group) <> e.comp_round_extended;

IF EXISTS (SELECT 1 FROM @results WHERE passed = 0)
    THROW 51500, 'Bonus Team smoke tests failed: inspect FAIL rows and target configuration.', 1;
IF EXISTS
(
    SELECT 1 FROM dbo.PEPSICO_EmployeeCompRoundException AS e
    LEFT JOIN dbo.PEPSICO_CompRoundExtendedRule AS r
        ON r.id_comp_group = e.id_comp_group AND r.division_code = e.division_code
    WHERE r.id IS NULL OR r.comp_round_extended <> e.comp_round_extended
       OR dbo._ufn_get_comp_round_extended(e.id_step, e.id_comp_group) <> e.comp_round_extended
)
    THROW 51501, 'Division exception cache does not match its configuration or lookup.', 1;
PRINT N'PASS: Bonus Team combinations and published Division exception consistency.';
