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
    btb.BTBusinessValue,
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
ORDER BY btb.BTBusinessValue ASC
OFFSET 0 ROWS;
GO
