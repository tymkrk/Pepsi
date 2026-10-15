CREATE VIEW [dbo].[vPEPSICO_EffectiveBonusPlanTypeAssignment]
AS
-- created by Tymoteusz Kruk 20261014: Distinct effective Plan Types at canonical involvement grain (BT-GAP-22/financial reports).
SELECT DISTINCT
    t.GPID,
    t.StartDateInvolvement,
    t.EndDateInvolvement,
    p.idBonusPlanType,
    p.BonusPlanTypeName
FROM dbo.PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS t
LEFT JOIN dbo.PEPSICO_BonusPlanTypePeopleAssignEmp AS a
    ON a.GPID = t.GPID
    AND a.StartDateInvolvement = t.StartDateInvolvement
    AND a.EndDateInvolvement = t.EndDateInvolvement
LEFT JOIN dbo.PEPSICO_OvrdBonusPlanType AS o
    ON o.GPID = t.GPID
    AND o.StartDate <= t.EndDateInvolvement
    AND o.EndDate >= t.StartDateInvolvement
LEFT JOIN dbo.PEPSICO_BonusPlanType AS op
    ON op.idBonusPlanType = o.idBonusPlanType
INNER JOIN dbo.PEPSICO_BonusPlanType AS p
    ON p.idBonusPlanType = COALESCE(op.idBonusPlanType, a.idBonusPlanType)
GO
