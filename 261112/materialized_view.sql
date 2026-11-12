-- 1. Zapis wyniku obecnego widoku.
-- Uruchomić PRZED zmianą jego definicji.
SELECT
    BTBusinessCode,
    BTBusinessValue,
    idCompGroup,
    BTBusiness_filter_1,
    BTBusiness_filter_2
INTO dbo.PEPSICO_bonus_team_step3_business_materialized
FROM dbo.vPEPSICO_bonus_team_step3_business;
GO

-- 2. Indeks dla ładowania etykiet procesu po kodzie Business.
CREATE CLUSTERED INDEX CX_bonus_team_step3_business_code
ON dbo.PEPSICO_bonus_team_step3_business_materialized
(
    BTBusinessCode,
    idCompGroup,
    BTBusiness_filter_1,
    BTBusiness_filter_2
);
GO

-- 3. Indeks dla filtrowanego dropdownu.
CREATE NONCLUSTERED INDEX IX_bonus_team_step3_business_cascade
ON dbo.PEPSICO_bonus_team_step3_business_materialized
(
    idCompGroup,
    BTBusiness_filter_1,
    BTBusiness_filter_2
)
INCLUDE (BTBusinessCode, BTBusinessValue);
GO

-- 4. Zachowanie nazwy i kolumn widoku używanych przez aplikację.
ALTER VIEW dbo.vPEPSICO_bonus_team_step3_business
AS
SELECT
    BTBusinessCode,
    BTBusinessValue,
    idCompGroup,
    BTBusiness_filter_1,
    BTBusiness_filter_2
FROM dbo.PEPSICO_bonus_team_step3_business_materialized;
GO
