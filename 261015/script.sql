/*
    Find an existing regression candidate for Bonus Actuals / Forecast.
    Read-only against project tables; requires neither the new view nor deployment.
    Set fiscal year and (optionally) the report user/profile below.

    Conservative candidate: eligible timeline involvement, nonzero bonus target,
    at least two DISTINCT effective plan names, and no Bonus Earn source row for
    that involvement (any simulation). This targets the reports' fallback branch.
    Report security and other dimension joins can still affect the full output;
    run the generated EXEC commands before and after deployment to confirm it.
*/
SET NOCOUNT ON;

DECLARE @fiscal_year INT = 2026,
        @id_user INT = -1,       -- Replace with the user used to run the report.
        @id_profile INT = -1,    -- Replace with that user's report profile.
        @max_candidates INT = 20;

DROP TABLE IF EXISTS #effective_plans;
DROP TABLE IF EXISTS #candidates;

-- Reproduce the OLD fallback joins, including override precedence.
SELECT DISTINCT
    t.GPID,
    t.StartDateInvolvement,
    t.EndDateInvolvement,
    COALESCE(po.idBonusPlanType, p.idBonusPlanType) AS id_bonus_plan_type,
    COALESCE(po.BonusPlanTypeName, p.BonusPlanTypeName) AS plan_type_name
INTO #effective_plans
FROM dbo.PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS t
JOIN dbo.PEPSICO_BonusPlanTypePeopleAssignEmp AS a
    ON a.GPID = t.GPID
    AND a.StartDateInvolvement = t.StartDateInvolvement
    AND a.EndDateInvolvement = t.EndDateInvolvement
LEFT JOIN dbo.PEPSICO_BonusPlanType AS p
    ON p.idBonusPlanType = a.idBonusPlanType
LEFT JOIN dbo.PEPSICO_OvrdBonusPlanType AS o
    ON o.GPID = a.GPID
    AND o.StartDate <= a.EndDateInvolvement
    AND o.EndDate >= a.StartDateInvolvement
LEFT JOIN dbo.PEPSICO_BonusPlanType AS po
    ON po.idBonusPlanType = o.idBonusPlanType
WHERE t.FiscalYear = @fiscal_year
  AND COALESCE(po.BonusPlanTypeName, p.BonusPlanTypeName) IS NOT NULL
  AND EXISTS
  (
      SELECT 1
      FROM dbo.PEPSICO_Transaction_Bonus_Eligibility_Results_v2 AS e
      WHERE e.GPID = t.GPID
        AND e.StartDateInvolvement = t.StartDateInvolvement
        AND e.EndDateInvolvement = t.EndDateInvolvement
        AND e.EligibilityPoints > 0
  )
  AND EXISTS
  (
      SELECT 1
      FROM dbo.PEPSICO_CompGroupPayees AS c
      WHERE c.GPID = t.GPID
  )
  AND EXISTS
  (
      SELECT 1
      FROM (VALUES (1)) AS seed(n)
      LEFT JOIN dbo.PEPSICO_OvrdHRAttributeForBonus AS h
          ON h.GPID = t.GPID
          AND h.StartDate <= t.EndDateInvolvement
          AND h.EndDate >= t.StartDateInvolvement
      WHERE NOT
      (
          ISNULL(h.AnnualBonusPct, t.AnnualBonusPct * 100) = 0
          AND ISNULL(h.BDIShortTermTarget, t.BDIShortTermTarget) = 0
          AND ISNULL(h.PremBonusPct, t.PremBonusPct * 100) = 0
      )
  )
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.PEPSICO_Transaction_Bonus_Earn AS be
      WHERE be.GPID = t.GPID
        AND be.FiscalYear = @fiscal_year
        AND be.StartDateInvolvement = t.StartDateInvolvement
        AND be.EndDateInvolvement = t.EndDateInvolvement
  );

SELECT TOP (@max_candidates)
    e.GPID,
    py.idPayee,
    e.StartDateInvolvement,
    e.EndDateInvolvement,
    COUNT(DISTINCT e.plan_type_name) AS old_plan_type_row_count,
    COUNT(DISTINCT e.id_bonus_plan_type) AS distinct_effective_plan_count
INTO #candidates
FROM #effective_plans AS e
JOIN dbo.py_Payee AS py ON py.codePayee = e.GPID
GROUP BY e.GPID, py.idPayee, e.StartDateInvolvement, e.EndDateInvolvement
HAVING COUNT(DISTINCT e.plan_type_name) > 1
ORDER BY e.GPID, e.StartDateInvolvement, e.EndDateInvolvement;

-- Result 1: cases and commands to run on the current database, then after deploy.
SELECT c.GPID, c.idPayee, c.StartDateInvolvement, c.EndDateInvolvement,
    c.old_plan_type_row_count,
    c.distinct_effective_plan_count,
    1 AS expected_new_row_count,
    1 AS expected_new_plan_type_error_flag,
    'Multiple Bonus Plan Types Assigned' AS expected_new_error_message,
    CONCAT('EXEC dbo.SP_Report_BonusActuals_2023 @idCompGroup = ''-1'', @FiscalYear = ',
        @fiscal_year, ', @idUser = ', @id_user, ', @idProfile = ', @id_profile,
        ', @idPayee = ', c.idPayee, ';') AS run_actuals,
    CONCAT('EXEC dbo.SP_Report_BonusForecast_2023 @idCompGroup = ''-1'', @FiscalYear = ',
        @fiscal_year, ', @idUser = ', @id_user, ', @idProfile = ', @id_profile,
        ', @idPayee = ', c.idPayee, ';') AS run_forecast
FROM #candidates AS c
ORDER BY c.GPID, c.StartDateInvolvement;

-- Result 2: the separate Plan Type rows responsible for the old join fan-out.
SELECT e.GPID, e.StartDateInvolvement, e.EndDateInvolvement,
    e.id_bonus_plan_type, e.plan_type_name
FROM #effective_plans AS e
JOIN #candidates AS c
    ON c.GPID = e.GPID
    AND c.StartDateInvolvement = e.StartDateInvolvement
    AND c.EndDateInvolvement = e.EndDateInvolvement
ORDER BY e.GPID, e.StartDateInvolvement, e.id_bonus_plan_type;

IF NOT EXISTS (SELECT 1 FROM #candidates)
    PRINT 'No conservative candidate found for this fiscal year. This does not prove the bug is absent. Try another fiscal year.';

DROP TABLE IF EXISTS #candidates;
DROP TABLE IF EXISTS #effective_plans;
