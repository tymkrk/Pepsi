CREATE VIEW [dbo].[vPEPSICO_bonus_team_step2_business]
AS
SELECT	
    bcg.BTBusinessCode,
    btb.BTBusinessValue,
    ISNULL(bcg.idCompGroup, 0) AS idCompGroup,
    b.BTBusinessCode AS BTBusiness_filter
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb
    ON btb.BTBusinessCode = bcg.BTBusinessCode
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b 
WHERE b.BTBusinessCode <> bcg.BTBusinessCode
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.PEPSICO_CompGroup AS cg
        WHERE cg.idCompGroup = bcg.idCompGroup
            AND LOWER(cg.CompGroupName) = N'north america'
    )

UNION ALL

SELECT DISTINCT
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusinessCode,
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(100)) AS BTBusinessValue,
    cg.idCompGroup,
    b.BTBusinessCode AS BTBusiness_filter
FROM dbo.PEPSICO_CompGroup AS cg
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
WHERE LOWER(cg.CompGroupName) = N'north america'
GO
