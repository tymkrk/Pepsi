
CREATE VIEW [dbo].[vPEPSICO_bonus_team_step1_business]
AS
	select 
		cgbt.BTBusinessCode,
		CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,
		ISNULL(cgbt.idCompGroup,0) as idCompGroup
	from PEPSICO_Bonus_Team_Business_per_CompGroup as cgbt
	join PEPSICO_Bonus_Team_Business AS btb
		on btb.BTBusinessCode = cgbt.BTBusinessCode
	ORDER BY CASE WHEN btb.BTBusinessValue = N'Other' THEN 1 ELSE 0 END,
		btb.BTBusinessValue ASC
	OFFSET 0 ROWS;
GO
CREATE VIEW [dbo].[vPEPSICO_bonus_team_step2_business]
AS
SELECT
    bcg.BTBusinessCode,
    CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,
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
            AND cg.CompGroupName IN (N'North America', N'Corporate GGF')
    )
UNION ALL

SELECT DISTINCT
    CAST(CASE WHEN cg.CompGroupName = N'Corporate GGF' THEN N'Not Applicable for Corporate GGF Bonus Design' ELSE N'Not Applicable for North America Bonus Design' END AS NVARCHAR(50)) AS BTBusinessCode,
    CAST(CASE WHEN cg.CompGroupName = N'Corporate GGF' THEN N'Not Applicable for Corporate GGF Bonus Design' ELSE N'Not Applicable for North America Bonus Design' END AS NVARCHAR(100)) AS BTBusinessValue,
    cg.idCompGroup,
    b.BTBusinessCode AS BTBusiness_filter
FROM dbo.PEPSICO_CompGroup AS cg
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
WHERE cg.CompGroupName IN (N'North America', N'Corporate GGF');
GO
  
  
CREATE VIEW [dbo].[vPEPSICO_bonus_team_step3_business]  
AS  
/******************************************************************************  
Purpose: Data source for the Bonus process field bonus_team_step_3 drop-down.  
         Cascading filters (k_m_fields_relation):  
           idCompGroup          <- Comp Group of the process row  
           BTBusiness_filter_1  <- value selected in bonus_team_step_1  
           BTBusiness_filter_2  <- value selected in bonus_team_step_2  
         Returns Businesses mapped to the Comp Group, excluding the  
         Businesses already chosen in Step 1 and Step 2.  
******************************************************************************/  
SELECT  
    bcg.BTBusinessCode,  
    CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,  
    ISNULL(bcg.idCompGroup, 0) AS idCompGroup,  
    s1.BTBusinessCode AS BTBusiness_filter_1,  
    s2.BTBusinessCode AS BTBusiness_filter_2  
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb  
    ON btb.BTBusinessCode = bcg.BTBusinessCode  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s1  
    ON ISNULL(s1.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s2  
    ON ISNULL(s2.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)  
WHERE s1.BTBusinessCode <> s2.BTBusinessCode  
    AND bcg.BTBusinessCode <> s1.BTBusinessCode  
    AND bcg.BTBusinessCode <> s2.BTBusinessCode  
    AND NOT EXISTS  
    (  
        SELECT 1  
        FROM dbo.PEPSICO_CompGroup AS cg  
        WHERE cg.idCompGroup = bcg.idCompGroup  
            AND cg.CompGroupName IN (N'North America', N'Corporate GGF')  
    )  
UNION ALL  
  
SELECT DISTINCT  
    CAST(CASE WHEN cg.CompGroupName = N'Corporate GGF' THEN N'Not Applicable for Corporate GGF Bonus Design' ELSE N'Not Applicable for North America Bonus Design' END AS NVARCHAR(50)) AS BTBusinessCode,  
    CAST(CASE WHEN cg.CompGroupName = N'Corporate GGF' THEN N'Not Applicable for Corporate GGF Bonus Design' ELSE N'Not Applicable for North America Bonus Design' END AS NVARCHAR(100)) AS BTBusinessValue,  
    cg.idCompGroup,  
    b.BTBusinessCode AS BTBusiness_filter_1,  
 b.BTBusinessCode AS BTBusiness_filter_2  
FROM dbo.PEPSICO_CompGroup AS cg  
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b  
WHERE cg.CompGroupName IN (N'North America', N'Corporate GGF');
GO
