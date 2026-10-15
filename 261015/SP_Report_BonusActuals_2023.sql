CREATE PROCEDURE [dbo].[SP_Report_BonusActuals_2023]  -- [SP_Report_BonusActuals_2023] '-1', 2024, -1, -1, -1
	@idCompGroup varchar(max),  
	@FiscalYear INT,  
	@idUser INT,  
	@idProfile INT,
	@idPayee INT
AS
BEGIN  

-- created by James Mackay 20220209 Returns the dataset for the Bonus Actuals Report - new version 
-- modified by Yoann Schrago 20220601 ZD55926 added , FiscalYearMinus1, FiscalYearMinus2
-- modified by Yoann Schrago 20220824 O2022-05 Added HR Manager GPID and Name
-- modified by JM 20221111 changed HRMGPID joins to left joins
-- modified by JM 20230220 #57005 changed trailing proration to use annualised factor
-- modified by JM 20230223 #57005 changed where annualised factor calculated in order to pick up all involvements
-- modified by JM 20230223 #79122 fixed BDI to pick up override
-- modified by Thiago Oliveira 20230721 B2023-09 added JobFunctionCode and JobFunctioName
-- modified by Thiago Oliveira 20230724 add filter idPayee(GPID), due to B2023-18 ticket.
-- modified by Thiago Oliveira 20230725 add COLUMN  ExtractDate, FinalMeasure, FinalWeight due to B2023-19 ticket.
-- modified by Yoann Schrago 20230907 B2023-19 Update ExtractDate logic 
-- modified by Yoann Schrago 20231122 ZD 95056 added "ALL" (-1) to return all CompGroup
-- modified by James Mackay 20240916 zd 113657 B2024-07 changed premium payout to be Current Year Premium Payout + Previous Year Premium Payout + Current Year Minus 2 Premium Payout
-- modified by Mateusz Ziecina 20250108 zd 121980, 121974 use FiscalYearEnd instead of current date if FiscalYearEnd has passed when checking comp groups
--modified by Magda Czaja 20250110 performance - replace timeline_full with PEPSICO_FocalPoint_EmpCurrentPayee
-- modified by Magda Czaja 20250212 ZD 125026 - take Annual Bonus % from override grid
-- modified by Yoann Schrago 20251128 add logic from ZD 141472 for Bonus Actuals
-- modified by Przemyslaw Kot 20260206 - ZD 146171 and ZD 148185 Take into account entries in the Plan Type Override grid for Plan Type field

-- modified by Tymoteusz Kruk 20261014: Aggregate distinct effective Plan Types per canonical involvement; retain multi-plan errors.

print 'START. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    -- select * from pepsico_compgroup where compgroupname = 'benelux'

 --TestParameters   
--DECLARE  @idCompGroup varchar(max) ='-1',-- '6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,42,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64',  
--  @FiscalYear INT = 2024, @idUser INT = 43189, @idProfile INT = 7, @idPayee INT = -1

	-- parameters

	DECLARE 
		@idUserProfile INT = (SELECT TOP 1 idUserProfile FROM dbo.k_users_profiles WHERE id_user = @idUser AND id_profile = @idProfile),
		@FiscalYearStart DATE = (SELECT StartDate FROM PEPSICO_FiscalYear WHERE FiscalYear = @FiscalYear),
		@FiscalYearEnd DATE = (SELECT EndDate FROM PEPSICO_FiscalYear WHERE FiscalYear = @FiscalYear),
		@codePayee_external_user NVARCHAR(50) 

	SELECT 
		@codePayee_external_user = py.codePayee
	FROM k_users AS u
	LEFT JOIN py_Payee AS py
		ON py.idPayee = u.id_external_user
	WHERE
		u.id_user = @idUser

	DECLARE @firstdDayofYear date = (select CONCAT(FiscalYear, '-12-31') from vPEPSICO_FocalPoint_Parameters) -- YS 20230907
  
	-- get team assignments  
 
	DROP TABLE IF EXISTS #TeamsAssigned  
  
	SELECT  
		e.GPID,
		e.StartDateInvolvement,
		e.EndDateInvolvement,
		COUNT(*) As NoOfTeamsAssigned,
		REPLACE(STUFF((  
			SELECT ', ID ' + CAST(e2.idBonusTeam AS VARCHAR(10)) + ': ' + e2.TeamName   
			FROM dbo.vPEPSICO_MultipleBonusTeamAssignment AS e2 WITH (NOLOCK)
			WHERE e2.GPID = e.GPID  
			AND e2.StartDateInvolvement = e.StartDateInvolvement  
			AND e2.EndDateInvolvement = e.EndDateInvolvement  
			FOR XML PATH('')   
			), 1, 2, ''), '&amp;','&') AS TeamsAssigned  
	INTO #TeamsAssigned  
	FROM dbo.vPEPSICO_MultipleBonusTeamAssignment AS e WITH (NOLOCK)
	GROUP BY 
		e.GPID, 
		e.StartDateInvolvement, 
		e.EndDateInvolvement  
  
	-- get plan type assignments  
 
	DROP TABLE IF EXISTS #PlanTypesAssigned  
  
	SELECT  
		e.GPID,
		e.StartDateInvolvement,
		e.EndDateInvolvement,
		COUNT(*) As NoOfPlansAssigned,
		REPLACE(STUFF((  
			SELECT ', ' + e2.BonusPlanTypeName   
			FROM dbo.vPEPSICO_EffectiveBonusPlanTypeAssignment AS e2 WITH (NOLOCK)
			WHERE e2.GPID = e.GPID  
			AND e2.StartDateInvolvement = e.StartDateInvolvement  
			AND e2.EndDateInvolvement = e.EndDateInvolvement  
			FOR XML PATH('')   
			), 1, 2, ''), '&amp;','&') AS PlanTypesAssigned  
		INTO #PlanTypesAssigned  
		FROM dbo.vPEPSICO_EffectiveBonusPlanTypeAssignment AS e WITH (NOLOCK)  
		GROUP BY 
			e.GPID, 
			e.StartDateInvolvement, 
			e.EndDateInvolvement  
  
	-- create exchange rate table to include 'USD'  
 
	DROP TABLE IF EXISTS #ExchangeRates  
  
	SELECT 
		CurrencyCode, 
		ExchangeRate, 
		[Year]  
	INTO #ExchangeRates  
	FROM dbo.PEPSICO_ExchangeRateAnnual  
	UNION ALL
	SELECT 'USD', CAST(1 AS decimal(24,8)), @FiscalYear - 2
	UNION ALL
	SELECT 'USD', CAST(1 AS decimal(24,8)), @FiscalYear - 1
	UNION ALL 
	SELECT 'USD', CAST(1 AS decimal(24,8)), @FiscalYear
	UNION ALL
	SELECT 'USD', CAST(1 AS decimal(24,8)), @FiscalYear + 1

	-- get bonus earnings overrides

	DROP TABLE IF EXISTS #OvrdBonusEarnings  
  
	SELECT  
		GPID,  
		StartDate,  
		EndDate,  
		SUM(AnnualBonusAmt) AS AnnualBonusAmt,  
		SUM(PremBonusAmt) AS PremBonusAmt,  
		SUM(BDIBonusAmt) AS BDIBonusAmt
	INTO #OvrdBonusEarnings
	FROM dbo.PEPSICO_OvrdBonusEarnings WITH (NOLOCK)  
	GROUP BY  
		GPID,  
		StartDate,  
		EndDate  
  
	-- forecast report builds up list of involvements - to use simulation id - not needed in actual report























	
	
	
	-- get employee details (different to forecast -- optomised by arif )
  
	DROP TABLE IF EXISTS #GPIDS  

	CREATE TABLE #GPIDS (GPID NVARCHAR(50) INDEX ix_1) 
  
	INSERT INTO #GPIDS (GpID)
	SELECT DISTINCT p.codepayee
	FROM dbo.py_Payee AS p
	CROSS APPLY
	(	SELECT TOP 1 cgp.idCompGroup --select max(idCompGroup)
		FROM dbo.PEPSICO_CompGroupPayees AS cgp 
		WHERE p.codePayee = cgp.GPID 
		ORDER BY 
			cgp.EndDate DESC 
	) AS cgp
	WHERE (@idPayee = -1 OR p.idPayee = @idPayee) -- TO 20230724
	AND EXISTS (
		SELECT * 
		FROM dbo._ufn_bonus_rep_standard_payees(@idUserProfile) AS brsp 
		WHERE brsp.idPayee = p.idPayee)
	AND EXISTS (
		SELECT * FROM string_split(@idCompGroup, ',') AS ss 
		WHERE ss.value = cgp.idCompGroup
			OR @idCompGroup = '-1') -- YS 20231122
--and p.codePayee in ('20500726')

	-- get bonus records for GPIDs in the comp groups  (slight difference to forecast report) 

	DROP TABLE IF EXISTS #PEPSICO_Transaction_Bonus_Earn  
  
	SELECT  
		be.BonusPlanTypeName,  
		be.TeamName,  
		be.GPID,  
		be.JobTitle,  
		be.LevelCode,  
		be.EmpClassCode,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.PriorYearBonusSalary,   
		be.AnnualBonusPct,  
		be.PremBonusPct,  
		be.BDIShortTermTarget,  
		be.LOAProration,  
		be.AnnualCurrencyCode,  
		be.CostCenter,  
		be.SectorCode_nk,  
		be.DivisionCode_nk,  
		be.RegionCode_nk,  
		be.BusinessUnitCode_nk,  
		be.MarketUnitCode_nk,  
		be.WorkLocationCode_nk,
		be.JobFunctionCode_nk,
		be.LegalEntityCode_nk,
		be.CountryCode_nk,  
		be.SalaryPlanCode_nk,
		be.BonusSalary,  
		be.TimeInInvolvementFactor,  
		be.AnnualAmount,  
		be.id_trans_master,  
		be.idPayee,  
		be.MeasureName,  
		be.IsAdjustment,  
		be.[Weight],  
		be.ActualScore,  
		be.ForecastScore,
		be.amount_trans_earn,  
		be.amount_trans_earn * be.ic_score / 100 AS amount_trans_earn_ic_score,
		be.AdjustmentName,  
		be.ic_score, -- JM 20200818
		pc.name_cond,  
		p.name_prog,
		me.id_simulation
	INTO #PEPSICO_Transaction_Bonus_Earn  
	FROM dbo.PEPSICO_Transaction_Bonus_Earn AS be WITH (NOLOCK)  
	JOIN dbo.k_transaction_master_earn AS me WITH (NOLOCK)  
		ON me.id_trans_master = be.id_trans_master  
	JOIN dbo.k_program_cond AS pc  
		ON pc.id_prog = me.id_prog_earn   
		AND pc.id_cond = me.id_cond_earn  
		AND pc.active_cond = 1  
	JOIN dbo.k_program AS p  
		ON p.id_prog = me.id_prog_earn  
	JOIN #GPIDs AS g  
		ON g.GPID = be.GPID  
	WHERE 
		be.FiscalYear = @FiscalYear  
	AND me.id_simulation = 0  
  
	-- get measures  
 
	DROP TABLE IF EXISTS #GPIDMeasureList  
  
	SELECT DISTINCT  
		btpae.GPID,  
		btpae.StartDateInvolvement,  
		btpae.EndDateInvolvement,  
		btma.idBonusMeasure,  
		DENSE_RANK() OVER(PARTITION BY btpae.GPID, btpae.StartDateInvolvement ORDER BY btma.idBonusMeasure) AS MeasureRank  
	INTO #GPIDMeasureList  
	FROM dbo.PEPSICO_BonusTeamPeopleAssignEmp AS btpae WITH (NOLOCK)  
	JOIN dbo.PEPSICO_BonusTeamMeasureAssign AS btma WITH (NOLOCK)  
		ON btma.idBonusTeam = btpae.idBonusTeam  
	JOIN dbo.PEPSICO_BonusTeam AS bt WITH (NOLOCK)  
		ON bt.idBonusTeam = btpae.idBonusTeam  
	JOIN #GPIDs As g  
		ON g.GPID = btpae.GPID  
	WHERE 
		bt.FiscalYear = @FiscalYear  
  
	-- get Measures Annual Amount (slight difference to forecast report) 
 
	DROP TABLE IF EXISTS #MeasuresAnnual  
  
	SELECT DISTINCT  
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.MeasureName,  
		be.[Weight],  
		be.ActualScore AS Score,  
		be.amount_trans_earn AS Amount, 
		be.amount_trans_earn_ic_score AS AmountIC,
		ml.MeasureRank  
	INTO #MeasuresAnnual  
	FROM #PEPSICO_Transaction_Bonus_Earn AS be  
	JOIN dbo.PEPSICO_Measure AS m WITH (NOLOCK)  
		ON be.MeasureName = m.MeasureName  
	JOIN #GPIDMeasureList AS ml  
		ON be.GPID = ml.GPID  
		AND be.StartDateInvolvement <= ml.EndDateInvolvement  
		AND be.EndDateInvolvement >= ml.StartDateInvolvement  
		AND m.idBonusMeasure = ml.idBonusMeasure  
	WHERE 
		be.IsAdjustment = 0  
	AND (be.name_cond like '%Annual%' OR be.name_cond like '%BDI%')  
  


	-- get Measures Premium Amount  (slight difference to forecast report) 
 
	DROP TABLE IF EXISTS #MeasuresPremium  
  
	SELECT DISTINCT  
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.MeasureName,  
		be.[Weight],  
		be.ActualScore AS Score,  
		CAST(ROUND(SUM(be.amount_trans_earn),2) AS DECIMAL(18,2)) AS Amount,  
		CAST(ROUND(SUM(be.amount_trans_earn_ic_score), 2) AS DECIMAL(18,2)) AS AmountIC,
		ml.MeasureRank  
	INTO #MeasuresPremium  
	FROM #PEPSICO_Transaction_Bonus_Earn AS be  
		JOIN dbo.PEPSICO_Measure AS m  
	ON be.MeasureName = m.MeasureName  
	JOIN #GPIDMeasureList ml  
		ON be.GPID = ml.GPID  
		AND be.StartDateInvolvement <= ml.EndDateInvolvement  
		AND be.EndDateInvolvement >= ml.StartDateInvolvement  
		AND m.idBonusMeasure = ml.idBonusMeasure  
	WHERE 
		be.IsAdjustment = 0  
	AND be.name_cond like '%Premium%'  
	GROUP BY   
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.MeasureName,  
		be.[Weight],  
		be.ActualScore,  
		ml.MeasureRank  
  


	drop table if exists #GPIDMeasureList -- no longer used

	-- get Trailing Premiums  
 
	DROP TABLE IF EXISTS #TrailingPremiums  
  
	; WITH cte_CurrentCurrencyCodes AS 
	(  
		SELECT 
			GPID, 
			MIN(AnnualCurrencyCode) AS CurrencyCode  
		FROM
		(
			SELECT 
				GPID,
				AnnualCurrencyCode
			FROM #PEPSICO_Transaction_Bonus_Earn

			UNION ALL 

			SELECT 
				GPID, 
				AnnualCurrencyCode
			FROM PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates WITH (NOLOCK)
			WHERE 
				FiscalYear = @FiscalYear
			AND GPID NOT IN (SELECT GPID FROM #PEPSICO_Transaction_Bonus_Earn)
		)
		AS s
		GROUP BY GPID  
	)  

	, cte_Premiums AS 
	(  
		SELECT  
			tpv.GPID,
			tpv.FiscalYear,
			COALESCE(pcc2.CurrencyCode, pcc.CurrencyCode, tpv.CurrencyCode) AS CurrencyCode,
			(tpv.TotalAmount * COALESCE(pcc2.ExchangeRate, pcc.ExchangeRate, 1)) - (tpv.PaidAmount * COALESCE(pcc2.ExchangeRate, pcc.ExchangeRate, 1)) AS CarryOver,
			ROUND((tpv.TotalAmount * COALESCE(pcc2.ExchangeRate, pcc.ExchangeRate, 1)) - (tpv.PaidAmount * COALESCE(pcc2.ExchangeRate, pcc.ExchangeRate, 1)), 0) AS Third
		FROM dbo.PEPSICO_TrailingPremiumValues AS tpv
		JOIN cte_CurrentCurrencyCodes AS ccc
			ON tpv.GPID = ccc.GPID
		LEFT JOIN dbo.PEPSICO_PayoutCurrencyConversion AS pcc
			ON pcc.GPID = tpv.GPID
			AND YEAR(pcc.EffectiveDate) = @FiscalYear
		LEFT JOIN dbo.PEPSICO_PayoutCurrencyConversion pcc2 -- 20191029 added by JM
			ON pcc2.GPID = tpv.GPID
			AND YEAR(pcc2.EffectiveDate) = @FiscalYear - 1
		WHERE 
			tpv.FiscalYear = @FiscalYear - 2

		UNION ALL

		SELECT
			tpv.GPID,
			tpv.FiscalYear,
			ISNULL(pcc.CurrencyCode, tpv.CurrencyCode) AS CurrencyCode,
			(tpv.TotalAmount * ISNULL(pcc.ExchangeRate, 1)) - (tpv.PaidAmount * ISNULL(pcc.ExchangeRate, 1)) AS CarryOver,
			ROUND((tpv.TotalAmount * ISNULL(pcc.ExchangeRate, 1))/3.0, 0) AS Third
		FROM dbo.PEPSICO_TrailingPremiumValues AS tpv
		JOIN cte_CurrentCurrencyCodes AS ccc
			ON tpv.GPID = ccc.GPID
		LEFT JOIN dbo.PEPSICO_PayoutCurrencyConversion AS pcc
			ON pcc.GPID = tpv.GPID
			AND YEAR(pcc.EffectiveDate) = @FiscalYear
		WHERE 
			tpv.FiscalYear = @FiscalYear - 1
		AND tpv.PaidAmount <> tpv.TotalAmount
	)
	
	SELECT  
		c.GPID,  
		c.FiscalYear,  
		c.CurrencyCode,  
		c.CarryOver,  
		c.Third,  
		ROUND(c.Third * e.ExchangeRate, 0) AS ThirdUSD,  
		e.ExchangeRate  
	INTO #TrailingPremiums  
	FROM cte_Premiums AS c  
	LEFT JOIN #ExchangeRates AS e  
		ON c.CurrencyCode = e.CurrencyCode  
		AND e.Year = @FiscalYear  
  
	-- get Adjustment List  
 
	DROP TABLE IF EXISTS #GPIDAdjustmentList  
  
	SELECT   
		btapae.GPID,  
		btapae.StartDateInvolvement,  
		btapae.EndDateInvolvement,  
		btapae.idBonusTeamAdjustment,  
		DENSE_RANK() OVER(PARTITION BY GPID, StartDateInvolvement ORDER BY idBonusTeamAdjustment) AS AdjustmentRank  
	INTO #GPIDAdjustmentList  
	FROM dbo.PEPSICO_BonusTeamAdjustmentPeopleAssignEmp AS btapae WITH (NOLOCK)  
  
	-- get Adjustment Annual Amount (slight difference to forecast report)
 
	DROP TABLE IF EXISTS #AdjustmentsAnnual  
  
	SELECT   
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.AdjustmentName,  
		be.[Weight],  
		be.ActualScore AS Score,  
		be.amount_trans_earn AS 'Amount',
		be.amount_trans_earn * be.ic_score / 100 AS AmountIC,
		ml.AdjustmentRank  
	INTO #AdjustmentsAnnual  
	FROM #PEPSICO_Transaction_Bonus_Earn AS be  
	JOIN dbo.PEPSICO_BonusTeamAdjustment AS bta WITH (NOLOCK)  
		ON be.AdjustmentName = bta.TeamAdjustmentName  
	JOIN #GPIDAdjustmentList AS ml  
		ON be.GPID = ml.GPID  
		AND be.StartDateInvolvement <= ml.EndDateInvolvement  
		AND be.EndDateInvolvement >= ml.StartDateInvolvement  
		AND bta.idBonusTeamAdjustment = ml.idBonusTeamAdjustment  
	WHERE 
		be.IsAdjustment = 1  
	AND (be.name_cond like '%Annual%' OR be.name_cond like '%BDI%')  
  


	-- get Adjustment Premium Amount (slight difference to forecast report) 
 
	DROP TABLE IF EXISTS #AdjustmentsPremium  
  
	SELECT   
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement AS EndDateInvolvement,  
		be.AdjustmentName AS AdjustmentName,  
		be.[Weight],  
		be.ActualScore AS Score,  
		CAST(ROUND(SUM(be.amount_trans_earn),2) as decimal(18,2)) AS Amount,  
		CAST(ROUND(SUM(be.amount_trans_earn_ic_score),2) as decimal(18,2)) AS AmountIC,
		ml.AdjustmentRank AS AdjustmentRank  
	INTO #AdjustmentsPremium  
	FROM #PEPSICO_Transaction_Bonus_Earn AS be  
	JOIN dbo.PEPSICO_BonusTeamAdjustment AS bta WITH (NOLOCK)  
		ON be.AdjustmentName = bta.TeamAdjustmentName  
	JOIN #GPIDAdjustmentList As ml  
		ON be.GPID = ml.GPID  
		AND be.StartDateInvolvement <= ml.EndDateInvolvement  
		AND be.EndDateInvolvement >= ml.StartDateInvolvement  
		AND bta.idBonusTeamAdjustment = ml.idBonusTeamAdjustment  
	WHERE 
		be.IsAdjustment = 1  
	AND be.name_cond LIKE '%Premium%'  
	GROUP BY   
		ml.GPID,  
		be.StartDateInvolvement,  
		be.EndDateInvolvement,  
		be.AdjustmentName,  
		be.[Weight],  
		be.ActualScore,  
		ml.AdjustmentRank  
  
	DROP TABLE IF EXISTS #GPIDAdjustmentList -- no longer used
 
	
	
	--Combine annual measures and adjustments to return as annual measures  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnual  
  
	SELECT  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		ma.MeasureName,  
		ma.[Weight],  
		ma.Score,  
		ma.Amount,  
		ma.AmountIC,
		ma.MeasureRank  
	INTO #MeasuresAndAdjustmentsAnnual  
	FROM #MeasuresAnnual AS ma  
  
	UNION ALL  
  
	SELECT  
		aa.GPID,  
		aa.StartDateInvolvement,  
		aa.EndDateInvolvement,  
		aa.AdjustmentName AS MeasureName,  
		aa.[Weight],  
		aa.Score,  
		aa.Amount,  
		aa.AmountIC,
		aa.AdjustmentRank + (SELECT MAX(MeasureRank) FROM #MeasuresAnnual WHERE GPID = aa.GPID AND StartDateInvolvement = aa.StartDateInvolvement) AS MeasureRank --align adjustments to come after measures  
	FROM #AdjustmentsAnnual AS aa  

	DROP TABLE IF EXISTS #AdjustmentsAnnual -- no longer used 
	DROP TABLE IF EXISTS #MeasuresAnnual -- no longer used
 
	-- calculate proration  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualProration 
  
	SELECT  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.StartDate,  
		obe.EndDate,  
		CASE WHEN (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) > ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)  
			THEN ((DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) - ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)) / CAST((DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) AS decimal(24,8))  
			ELSE CAST(0 AS decimal(24,8))  
		END AS AnnualFactor,  
		CASE WHEN (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) > ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)  
			THEN CAST(1 AS decimal(24,8))  
			ELSE (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) / CAST((DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1) AS decimal(24,8))  
		END AS OvrdFactor  
	INTO #MeasuresAndAdjustmentsAnnualProration  
	FROM #MeasuresAndAdjustmentsAnnual AS ma  
	LEFT JOIN (SELECT * FROM #OvrdBonusEarnings WHERE AnnualBonusAmt IS NOT NULL) AS obe  
		ON ma.GPID = obe.GPID  
		AND ma.StartDateInvolvement <= obe.EndDate  
		AND ma.EndDateInvolvement >= obe.StartDate  
	GROUP BY  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.StartDate,  
		obe.EndDate  
  
	--Calculate sub totals for involvements and corresponding override amounts  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualSubTotals  
  
	SELECT  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		SUM(ma.Amount * ISNULL(map.AnnualFactor, 1.0)) AS AmountPreIC,
		SUM(ma.AmountIC * ISNULL(map.AnnualFactor, 1.0)) AS Amount,
		ISNULL((obe.AnnualBonusAmt * map.OvrdFactor), 0.0) AS OvrdAmount,  
		SUM(ma.Amount) AS CalculatedAmountPreIC,
		SUM(ma.Amount * ISNULL(map.AnnualFactor, 1.0)) + ISNULL((obe.AnnualBonusAmt * map.OvrdFactor), 0.0) AS PayAmountPreIC,
		SUM(ma.AmountIC) AS CalculatedAmount,
		SUM(ma.AmountIC * ISNULL(map.AnnualFactor, 1.0)) + ISNULL((obe.AnnualBonusAmt * map.OvrdFactor), 0.0) AS PayAmount
	INTO #MeasuresAndAdjustmentsAnnualSubTotals  
	FROM #MeasuresAndAdjustmentsAnnual AS ma  
	LEFT JOIN #MeasuresAndAdjustmentsAnnualProration AS map  
		ON ma.GPID = map.GPID  
		AND ma.StartDateInvolvement = map.StartDateInvolvement  
		AND ma.EndDateInvolvement = map.EndDateInvolvement  
		AND ma.StartDateInvolvement <= map.EndDate  
		AND ma.EndDateInvolvement >= map.StartDate  
	LEFT JOIN #OvrdBonusEarnings AS obe  
		ON ma.GPID = obe.GPID  
		AND ma.StartDateInvolvement <= obe.EndDate  
		AND ma.EndDateInvolvement >= obe.StartDate  
	GROUP BY  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.AnnualBonusAmt,  
		obe.StartDate,  
		obe.EndDate,  
		map.OvrdFactor  

	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualProration -- no longer used
  
	--Calculate annual measures and adjustments totals across all involvements  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualTotals  
  
	SELECT  
		ma.GPID,  
		SUM(ma.Amount) AS Amount,
		SUM(ma.AmountPreIC) AS AmountPreIC,
		SUM(ma.OvrdAmount) AS OvrdAmount,
		SUM(ma.CalculatedAmountPreIC) AS CalculatedAmountPreIC,
		SUM(ma.PayAmountPreIC) AS PayAmountPreIC,
		SUM(ma.CalculatedAmount) AS CalculatedAmount,  
		SUM(ma.PayAmount) AS PayAmount  
	 INTO #MeasuresAndAdjustmentsAnnualTotals  
	 FROM #MeasuresAndAdjustmentsAnnualSubTotals AS ma  
	 GROUP BY 
		ma.GPID  
  
	--Combine premium measures and adjustments to return as premium measures  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremium  
  
	SELECT  
		mp.GPID,  
		mp.StartDateInvolvement,  
		mp.EndDateInvolvement,  
		mp.MeasureName,  
		mp.[Weight],  
		mp.Score,  
		mp.Amount,  
		mp.AmountIC,
		mp.MeasureRank  
	INTO #MeasuresAndAdjustmentsPremium  
	FROM #MeasuresPremium AS mp  
  
	UNION ALL  
  
	SELECT  
		ap.GPID,  
		ap.StartDateInvolvement,  
		ap.EndDateInvolvement,  
		ap.AdjustmentName AS MeasureName,  
		ap.[Weight],  
		ap.Score,  
		ap.Amount,  
		ap.AmountIC,
		ap.AdjustmentRank + (SELECT MAX(MeasureRank) FROM #MeasuresPremium WHERE GPID = ap.GPID AND StartDateInvolvement = ap.StartDateInvolvement) AS MeasureRank --align adjustments to come after measures  
	FROM #AdjustmentsPremium AS ap  
  
	drop table if exists #AdjustmentsPremium -- no longer used
	drop table if exists #MeasuresPremium -- no longer used

	--calculate proration  

	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumProration  
  
	SELECT  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.StartDate,  
		obe.EndDate,  
		CASE WHEN (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) > ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)  
			THEN ((DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) - ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)) / CAST((DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) AS decimal(24,8))  
			ELSE CAST(0 AS decimal(24,8))  
		END AS PremiumFactor,  
		CASE WHEN (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) > ISNULL(DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1, 0)  
			THEN CAST(1 AS decimal(24,8))  
			ELSE (DATEDIFF(mm, ma.StartDateInvolvement, ma.EndDateInvolvement) + 1) / CAST((DATEDIFF(mm, obe.StartDate, obe.EndDate) + 1) AS decimal(24,8))  
		END AS OvrdFactor  
	INTO #MeasuresAndAdjustmentsPremiumProration  
	FROM #MeasuresAndAdjustmentsPremium AS ma  
	LEFT JOIN (SELECT * FROM #OvrdBonusEarnings WHERE PremBonusAmt IS NOT NULL) AS obe  
		ON ma.GPID = obe.GPID  
		AND ma.StartDateInvolvement <= obe.EndDate  
		AND ma.EndDateInvolvement >= obe.StartDate  
	GROUP BY  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.StartDate,  
		obe.EndDate  

	--Calculate sub totals for involvements and corresponding override amounts  
 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumSubTotals  
  
	SELECT  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		SUM(ma.Amount * ISNULL(map.PremiumFactor, 1.0)) AS AmountPreIC,
		SUM(ma.AmountIC * ISNULL(map.PremiumFactor, 1.0)) AS Amount,
		ISNULL((obe.PremBonusAmt * map.OvrdFactor), 0.0) AS OvrdAmount,  
		SUM(ma.Amount) AS CalculatedAmountPreIC,
		SUM(ma.Amount * ISNULL(map.PremiumFactor, 1.0)) + ISNULL((obe.PremBonusAmt * map.OvrdFactor), 0.0) AS PayAmountPreIC,
		SUM(ma.AmountIC) AS CalculatedAmount,
		SUM(ma.AmountIC * ISNULL(map.PremiumFactor, 1.0)) + ISNULL((obe.PremBonusAmt * map.OvrdFactor), 0.0) AS PayAmount
	INTO #MeasuresAndAdjustmentsPremiumSubTotals  
	FROM #MeasuresAndAdjustmentsPremium AS ma  
	LEFT JOIN #MeasuresAndAdjustmentsPremiumProration AS map  
		ON ma.GPID = map.GPID  
		AND ma.StartDateInvolvement = map.StartDateInvolvement  
		AND ma.EndDateInvolvement = map.EndDateInvolvement  
		AND ma.StartDateInvolvement <= map.EndDate  
		AND ma.EndDateInvolvement >= map.StartDate  
	LEFT JOIN #OvrdBonusEarnings obe  
		ON ma.GPID = obe.GPID  
		AND ma.StartDateInvolvement <= obe.EndDate  
		AND ma.EndDateInvolvement >= obe.StartDate  
	GROUP BY  
		ma.GPID,  
		ma.StartDateInvolvement,  
		ma.EndDateInvolvement,  
		obe.PremBonusAmt,  
		obe.StartDate,  
		obe.EndDate,  
		map.OvrdFactor  
  
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumProration -- no longer used

	--Calculate premium measures and adjustments totals across all involvements  

	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumTotals  
  
	SELECT  
		mp.GPID,  
		SUM(mp.Amount) AS Amount,  
		SUM(mp.AmountPreIC) AS AmountPreIC,
		SUM(mp.OvrdAmount) AS OvrdAmount,  
		SUM(mp.CalculatedAmountPreIC) AS CalculatedAmountPreIC,
		SUM(mp.PayAmountPreIC) AS PayAmountPreIC,
		SUM(mp.CalculatedAmount) AS CalculatedAmount,  
		SUM(mp.PayAmount) AS PayAmount  
	INTO #MeasuresAndAdjustmentsPremiumTotals  
	FROM #MeasuresAndAdjustmentsPremiumSubTotals mp  
	GROUP BY 
		mp.GPID  
  
print '#ResultSet1. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	DROP TABLE IF EXISTS #ResultSet1 -- (slight difference to forecast) 
  
	SELECT  
		--MIN(be.BonusPlanTypeName) AS PlanType, 
		COALESCE(MIN(pt.BonusPlanTypeName), MIN(be.BonusPlanTypeName)) AS PlanType, -- PK 20260206
		MIN(be.TeamName) AS BonusTeam,  
		CASE ROW_NUMBER() OVER(PARTITION BY be.GPID ORDER BY StartDateInvolvement) WHEN 1 THEN 1 ELSE 0 END AS EmployeeCount,   
		1 AS RecordCount,  
		MIN(PP.FirstName) AS FirstName,  
		MIN(PP.LastName) AS LastName,  
		be.GPID,  
		MIN(be.JobTitle) AS JobTitle,  
		MIN(be.LevelCode) AS [LG Group/Level],  
		MIN(CASE WHEN be.EmpClassCode IN ('E','Z0003') THEN 1 ELSE 0 END) ExpatIndicator_YesNoBool,  
		be.StartDateInvolvement,  
		MIN(be.EndDateInvolvement) AS EndDateInvolvement,  
		MIN(be.PriorYearBonusSalary) AS PriorYearBonusSalary,   
		MIN(be.AnnualBonusPct) AS AnnualBonusPct,  
		MIN(be.PremBonusPct) AS PremBonusPct,  
		MIN(be.BDIShortTermTarget) AS BDITargetAmount,  
		MIN(CASE WHEN bpt.idOvrdBonusPlanType IS NOT NULL THEN 1 ELSE 0 END) AS AdHocPlanIndicator,  
		MIN(ISNULL(be.LOAProration, 1)) AS LOAProration,  
		MIN(be.AnnualCurrencyCode) AS CurrencyCode,  
		MIN(be.CostCenter) AS CostCenterCode,  
		MIN(be.SectorCode_nk) AS SectorCode_nk,  
		S.SectorName as 'Sector Name',  
		MIN(be.DivisionCode_nk) AS DivisionCode_nk,  
		D.DivisionName as 'DivisionName',  
		MIN(be.RegionCode_nk) AS RegionCode_nk,  
		R.RegionName as 'RegionName',  
		MIN(be.BusinessUnitCode_nk) AS BusinessUnitCode_nk,  
		MIN(be.MarketUnitCode_nk) AS MarketUnitCode_nk,  
		M.MarketUnitName as 'MarketName',  
		MIN(be.WorkLocationCode_nk) AS WorkLocationCode_nk,
		MIN(be.JobFunctionCode_nk) AS JobFunctionCode_nk, 
		MIN(be.LegalEntityCode_nk) AS LegalEntityCode_nk,
		MIN(be.CountryCode_nk) AS CountryCode_nk,  
		MIN(be.SalaryPlanCode_nk) AS SalaryPlanCode_nk,  
		MIN(be.BonusSalary) AS BonusSalary,  
		MIN(be.TimeInInvolvementFactor) AS TimeInInvolvementFactor,  
		MIN(be.AnnualAmount) AS AnnualAmount,
		MIN(be.ic_score) AS ic_score -- JM 20200818
	INTO #ResultSet1  
	FROM #PEPSICO_Transaction_Bonus_Earn AS be  
	--JOIN dbo.k_transaction_master_earn AS me  
	--	ON me.id_trans_master = be.id_trans_master  
	LEFT JOIN dbo.PEPSICO_OvrdBonusPlanType AS bpt WITH (NOLOCK)  
		ON be.GPID = bpt.GPID  
		AND bpt.StartDate <= be.EndDateInvolvement  
		AND bpt.EndDate >= be.StartDateInvolvement  
	--new left join here
	LEFT JOIN dbo.PEPSICO_BonusPlanType pt -- PK 20260206
		ON bpt.idBonusPlanType = pt.idBonusPlanType
	--new left join here
	LEFT JOIN dbo.PEPSICO_Region AS R  
		ON be.RegionCode_nk = R.RegionCode_nk  
	LEFT JOIN dbo.PEPSICO_Division AS D  
		ON be.DivisionCode_nk = D.DivisionCode_nk  
	LEFT JOIN dbo.PEPSICO_Sector AS S  
		ON be.SectorCode_nk = S.SectorCode_nk  
	LEFT JOIN dbo.PEPSICO_stg_MarketUnit AS M  
		ON be.MarketUnitCode_nk = M.MarketUnitCode_nk  
	LEFT JOIN Py_payee AS PP  
		ON be.gpid = PP.codepayee  
	GROUP BY   
		be.GPID,  
		be.StartDateInvolvement,  
		S.SectorName,  
		D.DivisionName,  
		R.RegionName,  
		M.MarketUnitName  
  

	drop table if exists #PEPSICO_Transaction_Bonus_Earn -- no longer used

print '#ResultSet2. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff') 

	-- add Measures and Adjustment annual amount to result set  
  
	DROP TABLE IF EXISTS #ResultSet2  
  
	SELECT  
		rs.PlanType,  
		rs.BonusTeam,  
		rs.EmployeeCount,  
		rs.RecordCount,  
		rs.FirstName,  
		rs.LastName,  
		rs.GPID,  
		rs.JobTitle,  
		rs.[LG Group/Level],  
		rs.ExpatIndicator_YesNoBool,  
		rs.StartDateInvolvement,  
		rs.EndDateInvolvement,  
		rs.PriorYearBonusSalary,  
		rs.AnnualBonusPct,  
		rs.PremBonusPct,  
		rs.BDITargetAmount,  
		rs.AdHocPlanIndicator,  
		rs.LOAProration,  
		rs.CurrencyCode,  
		rs.CostCenterCode,  
		rs.SectorCode_nk,  
		rs.DivisionCode_nk,  
		rs.RegionCode_nk,  
		rs.BusinessUnitCode_nk,  
		rs.MarketUnitCode_nk,  
		rs.WorkLocationCode_nk,
		rs.JobFunctionCode_nk,
		rs.LegalEntityCode_nk,
		rs.CountryCode_nk,  
		rs.SalaryPlanCode_nk,
		rs.BonusSalary,  
		rs.TimeInInvolvementFactor,  
		rs.AnnualAmount,  
		maA.MeasureName AS MeasureA,  
		maA.[Weight] AS MeasureAWeight,  
		maA.Score AS MeasureAScore,  
		maB.MeasureName AS MeasureB,  
		maB.[Weight] AS MeasureBWeight,  
		maB.Score AS MeasureBScore,  
		maC.MeasureName AS MeasureC,  
		maC.[Weight] AS MeasureCWeight,  
		maC.Score AS MeasureCScore,  
		maD.MeasureName AS MeasureD,  
		maD.[Weight] AS MeasureDWeight,  
		maD.Score AS MeasureDScore,  
		maE.MeasureName AS MeasureE,  
		maE.[Weight] AS MeasureEWeight,  
		maE.Score AS MeasureEScore,  
		maF.MeasureName AS MeasureF,  
		maF.[Weight] AS MeasureFWeight,  
		maF.Score AS MeasureFScore,  
		maG.MeasureName AS MeasureG,  
		maG.[Weight] AS MeasureGWeight,  
		maG.Score AS MeasureGScore,  
		maH.MeasureName AS MeasureH,  
		maH.[Weight] AS MeasureHWeight,  
		maH.Score AS MeasureHScore,  
		maI.MeasureName AS MeasureI,  
		maI.[Weight] AS MeasureIWeight,  
		maI.Score AS MeasureIScore,  
		maJ.MeasureName AS MeasureJ,  
		maJ.[Weight] AS MeasureJWeight,  
		maJ.Score AS MeasureJScore,  
		maK.MeasureName AS MeasureK,  
		maK.[Weight] AS MeasureKWeight,  
		maK.Score AS MeasureKScore,  
		maL.MeasureName AS MeasureL,  
		maL.[Weight] AS MeasureLWeight,  
		maL.Score AS MeasureLScore,  
		maM.MeasureName AS MeasureM,  
		maM.[Weight] AS MeasureMWeight,  
		maM.Score AS MeasureMScore,  
		maN.MeasureName AS MeasureN,  
		maN.[Weight] AS MeasureNWeight,  
		maN.Score AS MeasureNScore,  
		maO.MeasureName AS MeasureO,  
		maO.[Weight] AS MeasureOWeight,  
		maO.Score AS MeasureOScore,  
		maA.Amount AS AnnualMeasureAAmount,  
		maB.Amount AS AnnualMeasureBAmount,  
		maC.Amount AS AnnualMeasureCAmount,  
		maD.Amount AS AnnualMeasureDAmount,  
		maE.Amount AS AnnualMeasureEAmount,  
		maF.Amount AS AnnualMeasureFAmount,  
		maG.Amount AS AnnualMeasureGAmount,  
		maH.Amount AS AnnualMeasureHAmount,  
		maI.Amount AS AnnualMeasureIAmount,  
		maJ.Amount AS AnnualMeasureJAmount,  
		maK.Amount AS AnnualMeasureKAmount,  
		maL.Amount AS AnnualMeasureLAmount,  
		maM.Amount AS AnnualMeasureMAmount,  
		maN.Amount AS AnnualMeasureNAmount,  
		maO.Amount AS AnnualMeasureOAmount,  
		mast.CalculatedAmount AS AnnualMeasureAmountSubTotal,  
		mat.CalculatedAmount AS AnnualMeasureAmountTotal,  
		mast.CalculatedAmountPreIC AS AnnualMeasureAmountSubTotalPreIC,
		mat.CalculatedAmountPreIC AS AnnualMeasureAmountTotalPreIC,
		mast.OvrdAmount AS AnnualMeasureOvrdAmountSubTotal,  
		mat.OvrdAmount AS AnnualMeasureOvrdAmountTotal,  
		mast.PayAmount AS AnnualMeasurePayAmountSubTotal,  
		mat.PayAmount AS AnnualMeasurePayAmountTotal,
		mast.PayAmountPreIC AS AnnualMeasurePayAmountSubTotalPreIC,
		mat.PayAmountPreIC AS AnnualMeasurePayAmountTotalPreIC,
		rs.ic_score
	INTO #ResultSet2  
	FROM #ResultSet1 AS rs  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maA  
		ON rs.GPID = maA.GPID   
		AND rs.StartDateInvolvement <= maA.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maA.StartDateInvolvement  
		AND maA.MeasureRank = 1  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maB  
		ON rs.GPID = maB.GPID   
		AND rs.StartDateInvolvement <= maB.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maB.StartDateInvolvement  
		AND maB.MeasureRank = 2  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maC  
		ON rs.GPID = maC.GPID   
		AND rs.StartDateInvolvement <= maC.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maC.StartDateInvolvement  
		AND maC.MeasureRank = 3  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maD  
		ON rs.GPID = maD.GPID   
		AND rs.StartDateInvolvement <= maD.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maD.StartDateInvolvement  
		AND maD.MeasureRank = 4  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maE  
		ON rs.GPID = maE.GPID   
		AND rs.StartDateInvolvement <= maE.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maE.StartDateInvolvement  
		AND maE.MeasureRank = 5  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maF  
		ON rs.GPID = maF.GPID   
		AND rs.StartDateInvolvement <= maF.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maF.StartDateInvolvement  
		AND maF.MeasureRank = 6  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maG  
		ON rs.GPID = maG.GPID   
		AND rs.StartDateInvolvement <= maG.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maG.StartDateInvolvement  
		AND maG.MeasureRank = 7  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maH  
		ON rs.GPID = maH.GPID   
		AND rs.StartDateInvolvement <= maH.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maH.StartDateInvolvement  
		AND maH.MeasureRank = 8  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maI  
		ON rs.GPID = maI.GPID   
		AND rs.StartDateInvolvement <= maI.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maI.StartDateInvolvement  
		AND maI.MeasureRank = 9  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maJ  
		ON rs.GPID = maJ.GPID   
		AND rs.StartDateInvolvement <= maJ.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maJ.StartDateInvolvement  
		AND maJ.MeasureRank = 10  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maK  
		ON rs.GPID = maK.GPID   
		AND rs.StartDateInvolvement <= maK.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maK.StartDateInvolvement  
		AND maK.MeasureRank = 11  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maL  
		ON rs.GPID = maL.GPID   
		AND rs.StartDateInvolvement <= maL.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maL.StartDateInvolvement  
		AND maL.MeasureRank = 12  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maM  
		ON rs.GPID = maM.GPID   
		AND rs.StartDateInvolvement <= maM.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maM.StartDateInvolvement  
		AND maM.MeasureRank = 13  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maN  
		ON rs.GPID = maN.GPID   
		AND rs.StartDateInvolvement <= maN.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maN.StartDateInvolvement  
		AND maN.MeasureRank = 14  
	LEFT JOIN #MeasuresAndAdjustmentsAnnual AS maO  
		ON rs.GPID = maO.GPID   
		AND rs.StartDateInvolvement <= maO.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maO.StartDateInvolvement  
		AND maO.MeasureRank = 15  
	LEFT JOIN #MeasuresAndAdjustmentsAnnualSubTotals AS mast  
		ON rs.GPID = mast.GPID   
		AND rs.StartDateInvolvement <= mast.EndDateInvolvement  
		AND rs.EndDateInvolvement >= mast.StartDateInvolvement  
	LEFT JOIN #MeasuresAndAdjustmentsAnnualTotals AS mat  
		ON rs.GPID = mat.GPID   
  
	DROP TABLE IF EXISTS #ResultSet1 -- no longer used
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualTotals -- no longer used 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnualSubTotals -- no longer used 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsAnnual -- no longer used 

print '#ResultSet3. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	-- Add Measures amd Adjustments Premium amounts to result set  
 
	DROP TABLE IF EXISTS #ResultSet3  
  
	SELECT  
		rs.PlanType,  
		rs.BonusTeam,  
		rs.EmployeeCount,  
		rs.RecordCount,  
		rs.FirstName,  
		rs.LastName,  
		rs.GPID,  
		rs.JobTitle,  
		rs.[LG Group/Level],  
		rs.ExpatIndicator_YesNoBool,  
		rs.StartDateInvolvement,  
		rs.EndDateInvolvement,  
		rs.PriorYearBonusSalary,   
		rs.AnnualBonusPct,  
		rs.PremBonusPct,  
		rs.BDITargetAmount,  
		rs.AdHocPlanIndicator,  
		rs.LOAProration,  
		rs.CurrencyCode,  
		rs.CostCenterCode,  
		rs.SectorCode_nk,  
		rs.DivisionCode_nk,  
		rs.RegionCode_nk,  
		rs.BusinessUnitCode_nk,  
		rs.MarketUnitCode_nk,  
		rs.WorkLocationCode_nk,
		rs.JobFunctionCode_nk,
		rs.LegalEntityCode_nk,
		rs.CountryCode_nk,  
		rs.SalaryPlanCode_nk,
		rs.MeasureA,  
		rs.MeasureAWeight,  
		rs.MeasureAScore,  
		rs.MeasureB,  
		rs.MeasureBWeight,  
		rs.MeasureBScore,  
		rs.MeasureC,  
		rs.MeasureCWeight,  
		rs.MeasureCScore,  
		rs.MeasureD,  
		rs.MeasureDWeight,  
		rs.MeasureDScore,  
		rs.MeasureE,  
		rs.MeasureEWeight,  
		rs.MeasureEScore,  
		rs.MeasureF,  
		rs.MeasureFWeight,  
		rs.MeasureFScore,  
		rs.MeasureG,  
		rs.MeasureGWeight,  
		rs.MeasureGScore,  
		rs.MeasureH,  
		rs.MeasureHWeight,  
		rs.MeasureHScore,  
		rs.MeasureI,  
		rs.MeasureIWeight,  
		rs.MeasureIScore,  
		rs.MeasureJ,  
		rs.MeasureJWeight,  
		rs.MeasureJScore,  
		rs.MeasureK,  
		rs.MeasureKWeight,  
		rs.MeasureKScore,  
		rs.MeasureL,  
		rs.MeasureLWeight,  
		rs.MeasureLScore,  
		rs.MeasureM,  
		rs.MeasureMWeight,  
		rs.MeasureMScore,  
		rs.MeasureN,  
		rs.MeasureNWeight,  
		rs.MeasureNScore,  
		rs.MeasureO,  
		rs.MeasureOWeight,  
		rs.MeasureOScore,  
		rs.AnnualMeasureAAmount,  
		rs.AnnualMeasureBAmount,  
		rs.AnnualMeasureCAmount,  
		rs.AnnualMeasureDAmount,  
		rs.AnnualMeasureEAmount,  
		rs.AnnualMeasureFAmount,  
		rs.AnnualMeasureGAmount,  
		rs.AnnualMeasureHAmount,  
		rs.AnnualMeasureIAmount,  
		rs.AnnualMeasureJAmount,  
		rs.AnnualMeasureKAmount,  
		rs.AnnualMeasureLAmount,  
		rs.AnnualMeasureMAmount,  
		rs.AnnualMeasureNAmount,  
		rs.AnnualMeasureOAmount,  
		rs.AnnualMeasureAmountSubTotal,  
		rs.AnnualMeasureAmountTotal,  
		rs.AnnualMeasureAmountSubTotalPreIC,
		rs.AnnualMeasureAmountTotalPreIC,
		rs.AnnualMeasureOvrdAmountSubTotal,  
		rs.AnnualMeasureOvrdAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotal,  
		rs.AnnualMeasurePayAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotalPreIC,
		rs.AnnualMeasurePayAmountTotalPreIC,
		rs.BonusSalary,  
		rs.TimeInInvolvementFactor,  
		rs.AnnualAmount,  
		maA.Amount AS PremiumMeasureAAmount,  
		maB.Amount AS PremiumMeasureBAmount,  
		maC.Amount AS PremiumMeasureCAmount,  
		maD.Amount AS PremiumMeasureDAmount,  
		maE.Amount AS PremiumMeasureEAmount,  
		maF.Amount AS PremiumMeasureFAmount,  
		maG.Amount AS PremiumMeasureGAmount,  
		maH.Amount AS PremiumMeasureHAmount,  
		maI.Amount AS PremiumMeasureIAmount,  
		maJ.Amount AS PremiumMeasureJAmount,  
		maK.Amount AS PremiumMeasureKAmount,  
		maL.Amount AS PremiumMeasureLAmount,  
		maM.Amount AS PremiumMeasureMAmount,  
		maN.Amount AS PremiumMeasureNAmount,  
		maO.Amount AS PremiumMeasureOAmount,  
		mast.CalculatedAmount AS PremiumMeasureAmountSubTotal,  
		mat.CalculatedAmount AS PremiumMeasureAmountTotal,  
		mast.OvrdAmount AS PremiumMeasureOvrdAmountSubTotal,  
		mat.OvrdAmount AS PremiumMeasureOvrdAmountTotal,  
		mast.PayAmount AS PremiumMeasurePayAmountSubTotal,  
		mat.PayAmount AS PremiumMeasurePayAmountTotal,
		rs.ic_score
	INTO #ResultSet3  
	FROM #ResultSet2 AS rs  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maA  
		ON rs.GPID = maA.GPID   
		AND rs.StartDateInvolvement <= maA.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maA.StartDateInvolvement  
		AND maA.MeasureRank = 1  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maB  
		ON rs.GPID = maB.GPID   
		AND rs.StartDateInvolvement <= maB.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maB.StartDateInvolvement  
		AND maB.MeasureRank = 2  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maC  
		ON rs.GPID = maC.GPID   
		AND rs.StartDateInvolvement <= maC.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maC.StartDateInvolvement  
		AND maC.MeasureRank = 3  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maD  
		ON rs.GPID = maD.GPID   
		AND rs.StartDateInvolvement <= maD.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maD.StartDateInvolvement  
		AND maD.MeasureRank = 4  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maE  
		ON rs.GPID = maE.GPID   
		AND rs.StartDateInvolvement <= maE.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maE.StartDateInvolvement  
		AND maE.MeasureRank = 5  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maF  
		ON rs.GPID = maF.GPID   
		AND rs.StartDateInvolvement <= maF.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maF.StartDateInvolvement  
		AND maF.MeasureRank = 6  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maG  
		ON rs.GPID = maG.GPID   
		AND rs.StartDateInvolvement <= maG.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maG.StartDateInvolvement  
		AND maG.MeasureRank = 7  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maH  
		ON rs.GPID = maH.GPID   
		AND rs.StartDateInvolvement <= maH.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maH.StartDateInvolvement  
		AND maH.MeasureRank = 8  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maI  
		ON rs.GPID = maI.GPID   
		AND rs.StartDateInvolvement <= maI.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maI.StartDateInvolvement  
		AND maI.MeasureRank = 9  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maJ  
		ON rs.GPID = maJ.GPID   
		AND rs.StartDateInvolvement <= maJ.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maJ.StartDateInvolvement  
		AND maJ.MeasureRank = 10  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maK  
		ON rs.GPID = maK.GPID   
		AND rs.StartDateInvolvement <= maK.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maK.StartDateInvolvement  
		AND maK.MeasureRank = 11  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maL  
		ON rs.GPID = maL.GPID   
		AND rs.StartDateInvolvement <= maL.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maL.StartDateInvolvement  
		AND maL.MeasureRank = 12  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maM  
		ON rs.GPID = maM.GPID   
		AND rs.StartDateInvolvement <= maM.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maM.StartDateInvolvement  
		AND maM.MeasureRank = 13  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maN  
		ON rs.GPID = maN.GPID   
		AND rs.StartDateInvolvement <= maN.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maN.StartDateInvolvement  
		AND maN.MeasureRank = 14  
	LEFT JOIN #MeasuresAndAdjustmentsPremium AS maO  
		ON rs.GPID = maO.GPID   
		AND rs.StartDateInvolvement <= maO.EndDateInvolvement  
		AND rs.EndDateInvolvement >= maO.StartDateInvolvement  
		AND maO.MeasureRank = 15  
	LEFT JOIN #MeasuresAndAdjustmentsPremiumSubTotals AS mast  
		ON rs.GPID = mast.GPID   
		AND rs.StartDateInvolvement <= mast.EndDateInvolvement  
		AND rs.EndDateInvolvement >= mast.StartDateInvolvement  
	LEFT JOIN #MeasuresAndAdjustmentsPremiumTotals mat  
		ON rs.GPID = mat.GPID   
  
	DROP TABLE IF EXISTS #ResultSet2 -- no longer used 
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremium -- no longer used  
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumTotals -- no longer used  
	DROP TABLE IF EXISTS #MeasuresAndAdjustmentsPremiumSubTotals -- no longer used  
 
print '#ResultSet4. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	-- Add Trailing Premium Amounts to Result Set  
 
	DROP TABLE IF EXISTS #ResultSet4  
  
	SELECT  
		rs.PlanType,  
		rs.BonusTeam,  
		rs.EmployeeCount,  
		rs.RecordCount,  
		rs.FirstName,  
		rs.LastName,  
		rs.GPID,  
		rs.JobTitle,  
		rs.[LG Group/Level],  
		rs.ExpatIndicator_YesNoBool,  
		rs.StartDateInvolvement,  
		rs.EndDateInvolvement,  
		rs.PriorYearBonusSalary,   
		rs.AnnualBonusPct,  
		rs.PremBonusPct,  
		rs.BDITargetAmount,  
		rs.AdHocPlanIndicator,  
		rs.LOAProration,  
		rs.CurrencyCode,  
		rs.CostCenterCode,  
		rs.SectorCode_nk,  
		rs.DivisionCode_nk,  
		rs.RegionCode_nk,  
		rs.BusinessUnitCode_nk,  
		rs.MarketUnitCode_nk,  
		rs.WorkLocationCode_nk,
		rs.JobFunctionCode_nk,
		rs.LegalEntityCode_nk,
		rs.CountryCode_nk,  
		rs.SalaryPlanCode_nk,
		rs.MeasureA,  
		rs.MeasureAWeight,  
		rs.MeasureAScore,  
		rs.MeasureB,  
		rs.MeasureBWeight,  
		rs.MeasureBScore,  
		rs.MeasureC,  
		rs.MeasureCWeight,  
		rs.MeasureCScore,  
		rs.MeasureD,  
		rs.MeasureDWeight,  
		rs.MeasureDScore,  
		rs.MeasureE,  
		rs.MeasureEWeight,  
		rs.MeasureEScore,  
		rs.MeasureF,  
		rs.MeasureFWeight,  
		rs.MeasureFScore,  
		rs.MeasureG,  
		rs.MeasureGWeight,  
		rs.MeasureGScore,  
		rs.MeasureH,  
		rs.MeasureHWeight,  
		rs.MeasureHScore,  
		rs.MeasureI,  
		rs.MeasureIWeight,  
		rs.MeasureIScore,  
		rs.MeasureJ,  
		rs.MeasureJWeight,  
		rs.MeasureJScore,  
		rs.MeasureK,  
		rs.MeasureKWeight,  
		rs.MeasureKScore,  
		rs.MeasureL,  
		rs.MeasureLWeight,  
		rs.MeasureLScore,  
		rs.MeasureM,  
		rs.MeasureMWeight,  
		rs.MeasureMScore,  
		rs.MeasureN,  
		rs.MeasureNWeight,  
		rs.MeasureNScore,  
		rs.MeasureO,  
		rs.MeasureOWeight,  
		rs.MeasureOScore,  
		rs.AnnualMeasureAAmount,  
		rs.AnnualMeasureBAmount,  
		rs.AnnualMeasureCAmount,  
		rs.AnnualMeasureDAmount,  
		rs.AnnualMeasureEAmount,  
		rs.AnnualMeasureFAmount,  
		rs.AnnualMeasureGAmount,  
		rs.AnnualMeasureHAmount,  
		rs.AnnualMeasureIAmount,  
		rs.AnnualMeasureJAmount,  
		rs.AnnualMeasureKAmount,  
		rs.AnnualMeasureLAmount,  
		rs.AnnualMeasureMAmount,  
		rs.AnnualMeasureNAmount,  
		rs.AnnualMeasureOAmount,  
		rs.AnnualMeasureAmountSubTotal,  
		rs.AnnualMeasureAmountTotal,  
		rs.AnnualMeasureAmountSubTotalPreIC,
		rs.AnnualMeasureAmountTotalPreIC,
		rs.AnnualMeasureOvrdAmountSubTotal,  
		rs.AnnualMeasureOvrdAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotal,  
		rs.AnnualMeasurePayAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotalPreIC,
		rs.AnnualMeasurePayAmountTotalPreIC,
		rs.PremiumMeasureAAmount,  
		rs.PremiumMeasureBAmount,  
		rs.PremiumMeasureCAmount,  
		rs.PremiumMeasureDAmount,  
		rs.PremiumMeasureEAmount,  
		rs.PremiumMeasureFAmount,  
		rs.PremiumMeasureGAmount,  
		rs.PremiumMeasureHAmount,  
		rs.PremiumMeasureIAmount,  
		rs.PremiumMeasureJAmount,  
		rs.PremiumMeasureKAmount,  
		rs.PremiumMeasureLAmount,  
		rs.PremiumMeasureMAmount,  
		rs.PremiumMeasureNAmount,  
		rs.PremiumMeasureOAmount,  
		rs.PremiumMeasureAmountSubTotal,  
		rs.PremiumMeasureAmountTotal,  
		rs.PremiumMeasureOvrdAmountSubTotal,  
		rs.PremiumMeasureOvrdAmountTotal,  
		rs.PremiumMeasurePayAmountSubTotal,  
		rs.PremiumMeasurePayAmountTotal,  
		rs.BonusSalary,  
		rs.TimeInInvolvementFactor,  
		rs.AnnualAmount,  
		tp1.CarryOver AS PreviousYearCarryover,   
		tp1.Third AS PreviousYearPremiumPayout,   
		tp1.ThirdUSD AS PreviousYearPremiumPayoutUSD,  
		tp1.CurrencyCode AS PreviousYearPremiumCurrency,  
		tp1.ExchangeRate AS PreviousYearPremiumExchangeRate,  
		tp2.CarryOver AS CurrentYearMinus2Carryover,   
		tp2.Third AS CurrentYearMinus2PremiumPayout,   
		tp2.ThirdUSD AS CurrentYearMinus2PremiumPayoutUSD,  
		tp2.CurrencyCode AS CurrentYearMinus2PremiumCurrency,  
		tp2.ExchangeRate AS CurrentYearMinus2PremiumExchangeRate,
		rs.ic_score
	INTO #ResultSet4  
	FROM #ResultSet3 AS rs  
	LEFT JOIN #TrailingPremiums AS tp1  
		ON rs.GPID = tp1.GPID  
		AND @FiscalYear = tp1.FiscalYear + 1  
	LEFT JOIN #TrailingPremiums AS tp2  
		ON rs.GPID = tp2.GPID  
		AND @FiscalYear = tp2.FiscalYear + 2  

	DROP TABLE IF EXISTS #ResultSet3 -- no longer used

print 'DuplicateInvolvements. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	DROP TABLE IF EXISTS #DuplicateInvolvements  
  
	;WITH cte_Involvements AS  
	(  
		SELECT  
			GPID,
			ROW_NUMBER() OVER (PARTITION BY GPID ORDER BY StartDateInvolvement DESC) AS RowNumber,
			StartDateInvolvement,
			EndDateInvolvement  
		FROM (SELECT DISTINCT * FROM #ResultSet4) AS r  
	)  

	SELECT DISTINCT  
		I1.GPID,
		I1.StartDateInvolvement  
	INTO #DuplicateInvolvements  
	FROM cte_Involvements AS I1  
	JOIN cte_Involvements AS I2  
		ON I1.GPID = I2.GPID  
		AND I1.StartDateInvolvement <= I2.EndDateInvolvement  
		AND I1.EndDateInvolvement >= I2.StartDateInvolvement  
		AND I1.RowNumber <> I2.RowNumber  

	 OPTION(USE HINT('enable_parallel_plan_preference'),HASH JOIN)  
  
/* -- JM 20230223 moved below to calculate these for all involvements

	--identify Annual involvements and proration factor  
 
	DROP TABLE IF EXISTS #AnnualMonths  
 
	SELECT  
		GPID,  
		StartDateInvolvement,  
		EndDateInvolvement,  
		MONTH(EndDateInvolvement) - MONTH(StartDateInvolvement) + 1 AS AnnualMonths  
	INTO #AnnualMonths  
	FROM #ResultSet4  
  
	DROP TABLE IF EXISTS #AnnualTotalMonths  
 
	SELECT  
		GPID,  
		SUM(AnnualMonths) AS AnnualTotalMonths  
	INTO #AnnualTotalMonths  
	FROM #AnnualMonths  
	GROUP BY GPID  
  
	DROP TABLE IF EXISTS #AnnualInvolvements  
 
	SELECT DISTINCT  
		m.GPID,  
		m.StartDateInvolvement,  
		m.EndDateInvolvement,  
		m.AnnualMonths,  
		tm.AnnualTotalMonths,  
		CAST(m.AnnualMonths / (tm.AnnualTotalMonths * 1.0) AS decimal(7,6)) AS AnnualTimeInInvolvementFactor  
	INTO #AnnualInvolvements  
	FROM #AnnualMonths AS m  
	JOIN #AnnualTotalMonths As tm  
		ON m.GPID = tm.GPID  

	DROP TABLE IF EXISTS #AnnualMonths -- no longer used
	DROP TABLE IF EXISTS #AnnualTotalMonths -- no longer used  
  
*/

	--identify Premium involvements and proration factor  

	DROP TABLE IF EXISTS #PremiumMonths  
 
	SELECT  
		GPID,  
		StartDateInvolvement,  
		EndDateInvolvement,  
		MONTH(EndDateInvolvement) - MONTH(StartDateInvolvement) + 1 AS PremiumMonths  
	INTO #PremiumMonths  
	FROM #ResultSet4  
	WHERE 
		[LG Group/Level] IN ('LG1', 'LG2', 'LG3', 'LG4', 'LG5', 'LG6', 'LG7', 'LG8') 
  
	DROP TABLE IF EXISTS #PremiumTotalMonths  
	
	SELECT  
		GPID,  
		SUM(PremiumMonths) AS PremiumTotalMonths  
	INTO #PremiumTotalMonths  
	FROM #PremiumMonths  
	GROUP BY 
		GPID  
  
	DROP TABLE IF EXISTS #PremiumInvolvements  
 
	SELECT DISTINCT  
		m.GPID,  
		m.StartDateInvolvement,  
		m.EndDateInvolvement,  
		m.PremiumMonths,  
		tm.PremiumTotalMonths,  
		CAST(m.PremiumMonths / (tm.PremiumTotalMonths * 1.0) AS decimal(7,6)) AS PremiumTimeInInvolvementFactor  
	INTO #PremiumInvolvements  
	FROM #PremiumMonths AS m  
	JOIN #PremiumTotalMonths AS tm  
		ON m.GPID = tm.GPID  

	DROP TABLE IF EXISTS #PremiumMonths -- no longer used
	DROP TABLE IF EXISTS #PremiumTotalMonths -- no longer used 
  
print 'ResultSet. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

 -- Final ResultSet  

	DROP TABLE IF EXISTS #ResultSet  
  
	SELECT  
		CASE WHEN ISNULL(rs.PlanType, '') = '' OR ISNULL(pt.NoOfPlansAssigned, 1) > 1 THEN 1 ELSE 0 END AS PlanTypeErrorFlag,  
		CASE   
			WHEN ISNULL(rs.PlanType, '') = '' THEN 'No Bonus Plan Type Assigned'  
			WHEN ISNULL(pt.NoOfPlansAssigned, 1) > 1 THEN 'Multiple Bonus Plan Types Assigned'  
			ELSE NULL  
		END AS PlanTypeErrorMessage,  
		CASE WHEN ISNULL(pt.NoOfPlansAssigned, 1) > 1 THEN pt.PlanTypesAssigned ELSE rs.PlanType END AS PlanType,  
		CASE WHEN ISNULL(t.NoOfTeamsAssigned, 1) > 1 THEN 1 ELSE 0 END AS BonusTeamErrorFlag,  
		CASE WHEN ISNULL(t.NoOfTeamsAssigned, 1) > 1 THEN 'Multiple Bonus Teams Assigned' ELSE NULL END AS BonusTeamErrorMessage,  
		CASE WHEN ISNULL(t.NoOfTeamsAssigned, 1) > 1 THEN t.TeamsAssigned ELSE rs.BonusTeam END AS BonusTeam,  
		rs.EmployeeCount,  
		rs.RecordCount,  
		rs.FirstName,  
		rs.LastName,  
		rs.GPID,  
		mgr_hr.codePayee AS HR_GPID, -- YS 20220824
		mgr_hr.firstname + ' ' + mgr_hr.lastname AS HR_Name, -- YS 20220824
		rs.JobTitle,  
		rs.[LG Group/Level],  
		rs.ExpatIndicator_YesNoBool,  
		CASE WHEN di.GPID IS NOT NULL THEN 1 ELSE 0 END AS InvolvementsErrorFlag,  
		CASE WHEN di.GPID IS NOT NULL THEN 'Overlapping Involvements' ELSE NULL END AS InvolvementsErrorMessage,  
		rs.StartDateInvolvement,  
		rs.EndDateInvolvement,  
		MONTH(rs.EndDateInvolvement) - MONTH(rs.StartDateInvolvement) + 1 AS InvolvementMonths,  
		rs.PriorYearBonusSalary,   
		rs.AnnualBonusPct,  
		rs.PremBonusPct,  
		rs.BDITargetAmount,  
		rs.AdHocPlanIndicator,  
		rs.MeasureA,  
		rs.MeasureAWeight,  
		rs.MeasureAScore,  
		rs.MeasureB,  
		rs.MeasureBWeight,  
		rs.MeasureBScore,  
		rs.MeasureC,  
		rs.MeasureCWeight,  
		rs.MeasureCScore,  
		rs.MeasureD,  
		rs.MeasureDWeight,  
		rs.MeasureDScore,  
		rs.MeasureE,  
		rs.MeasureEWeight,  
		rs.MeasureEScore,  
		rs.MeasureF,  
		rs.MeasureFWeight,  
		rs.MeasureFScore,  
		rs.MeasureG,  
		rs.MeasureGWeight,  
		rs.MeasureGScore,  
		rs.MeasureH,  
		rs.MeasureHWeight,  
		rs.MeasureHScore,  
		rs.MeasureI,  
		rs.MeasureIWeight,  
		rs.MeasureIScore,  
		rs.MeasureJ,  
		rs.MeasureJWeight,  
		rs.MeasureJScore,  
		rs.MeasureK,  
		rs.MeasureKWeight,  
		rs.MeasureKScore,  
		rs.MeasureL,  
		rs.MeasureLWeight,  
		rs.MeasureLScore,  
		rs.MeasureM,  
		rs.MeasureMWeight,  
		rs.MeasureMScore,  
		rs.MeasureN,  
		rs.MeasureNWeight,  
		rs.MeasureNScore,  
		rs.MeasureO,  
		rs.MeasureOWeight,  
		rs.MeasureOScore,  
		rs.AnnualMeasureAAmount,  
		rs.AnnualMeasureBAmount,  
		rs.AnnualMeasureCAmount,  
		rs.AnnualMeasureDAmount,  
		rs.AnnualMeasureEAmount,  
		rs.AnnualMeasureFAmount,  
		rs.AnnualMeasureGAmount,  
		rs.AnnualMeasureHAmount,  
		rs.AnnualMeasureIAmount,  
		rs.AnnualMeasureJAmount,  
		rs.AnnualMeasureKAmount,  
		rs.AnnualMeasureLAmount,  
		rs.AnnualMeasureMAmount,  
		rs.AnnualMeasureNAmount,  
		rs.AnnualMeasureOAmount,  
		rs.AnnualMeasureAmountSubTotal,  
		rs.AnnualMeasureAmountTotal,  
		rs.AnnualMeasureAmountSubTotalPreIC,
		rs.AnnualMeasureAmountTotalPreIC,
		rs.AnnualMeasureOvrdAmountSubTotal,  
		rs.AnnualMeasureOvrdAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotal,  
		rs.AnnualMeasurePayAmountTotal,  
		rs.AnnualMeasurePayAmountSubTotalPreIC,
		rs.AnnualMeasurePayAmountTotalPreIC,
		rs.PremiumMeasureAAmount,  
		rs.PremiumMeasureBAmount,  
		rs.PremiumMeasureCAmount,  
		rs.PremiumMeasureDAmount,  
		rs.PremiumMeasureEAmount,  
		rs.PremiumMeasureFAmount,  
		rs.PremiumMeasureGAmount,  
		rs.PremiumMeasureHAmount,  
		rs.PremiumMeasureIAmount,  
		rs.PremiumMeasureJAmount,  
		rs.PremiumMeasureKAmount,  
		rs.PremiumMeasureLAmount,  
		rs.PremiumMeasureMAmount,  
		rs.PremiumMeasureNAmount,  
		rs.PremiumMeasureOAmount,  
		rs.PremiumMeasureAmountSubTotal,  
		rs.PremiumMeasureAmountTotal,  
		rs.PremiumMeasureOvrdAmountSubTotal,  
		rs.PremiumMeasureOvrdAmountTotal,  
		rs.PremiumMeasurePayAmountSubTotal,  
		rs.PremiumMeasurePayAmountTotal,  
		obe.AnnualBonusAmt AS AnnualGuaranteeAmount,  
		obe.PremBonusAmt AS PremiumGuaranteeAmount,  
		obe.BDIBonusAmt AS BDIGuaranteeAmount,  
		(rs.ic_score / 100) *
		(
			ISNULL(rs.AnnualMeasureAAmount, 0) + ISNULL(rs.AnnualMeasureBAmount, 0) + ISNULL(rs.AnnualMeasureCAmount, 0) + ISNULL(rs.AnnualMeasureDAmount, 0) + ISNULL(rs.AnnualMeasureEAmount, 0) + 
			ISNULL(rs.AnnualMeasureFAmount, 0) + ISNULL(rs.AnnualMeasureGAmount, 0) + ISNULL(rs.AnnualMeasureHAmount, 0) + ISNULL(rs.AnnualMeasureIAmount, 0) + ISNULL(rs.AnnualMeasureJAmount, 0) +
			ISNULL(rs.AnnualMeasureKAmount, 0) + ISNULL(rs.AnnualMeasureLAmount, 0) + ISNULL(rs.AnnualMeasureMAmount, 0) + ISNULL(rs.AnnualMeasureNAmount, 0) + ISNULL(rs.AnnualMeasureOAmount, 0)
		) AS AnnualSubTotal,
		(
			ISNULL(rs.AnnualMeasureAAmount, 0) + ISNULL(rs.AnnualMeasureBAmount, 0) + ISNULL(rs.AnnualMeasureCAmount, 0) + ISNULL(rs.AnnualMeasureDAmount, 0) + ISNULL(rs.AnnualMeasureEAmount, 0) + 
			ISNULL(rs.AnnualMeasureFAmount, 0) + ISNULL(rs.AnnualMeasureGAmount, 0) + ISNULL(rs.AnnualMeasureHAmount, 0) + ISNULL(rs.AnnualMeasureIAmount, 0) + ISNULL(rs.AnnualMeasureJAmount, 0) +
			ISNULL(rs.AnnualMeasureKAmount, 0) + ISNULL(rs.AnnualMeasureLAmount, 0) + ISNULL(rs.AnnualMeasureMAmount, 0) + ISNULL(rs.AnnualMeasureNAmount, 0) + ISNULL(rs.AnnualMeasureOAmount, 0)
		) AS AnnualSubTotalPreIC, 
		rs.LOAProration,  
		ROUND(rs.AnnualMeasurePayAmountTotal, -1) AS CurrentYearTotalAnnualPayout,  
		ROUND(ROUND(rs.AnnualMeasurePayAmountTotal, -1) * er.ExchangeRate, 2) AS CurrentYearTotalAnnualPayoutUSD,  
		(rs.ic_score / 100) *
		(
			ISNULL(rs.PremiumMeasureAAmount, 0) + ISNULL(rs.PremiumMeasureBAmount, 0) + ISNULL(rs.PremiumMeasureCAmount, 0) + ISNULL(rs.PremiumMeasureDAmount, 0) + ISNULL(rs.PremiumMeasureEAmount, 0) + 
			ISNULL(rs.PremiumMeasureFAmount, 0) + ISNULL(rs.PremiumMeasureGAmount, 0) + ISNULL(rs.PremiumMeasureHAmount, 0) + ISNULL(rs.PremiumMeasureIAmount, 0) + ISNULL(rs.PremiumMeasureJAmount, 0) +
			ISNULL(rs.PremiumMeasureKAmount, 0) + ISNULL(rs.PremiumMeasureLAmount, 0) + ISNULL(rs.PremiumMeasureMAmount, 0) + ISNULL(rs.PremiumMeasureNAmount, 0) + ISNULL(rs.PremiumMeasureOAmount, 0)
		) AS CurrentYearPremiumCalculatedSubtotal,
		(
			ISNULL(rs.PremiumMeasureAAmount, 0) + ISNULL(rs.PremiumMeasureBAmount, 0) + ISNULL(rs.PremiumMeasureCAmount, 0) + ISNULL(rs.PremiumMeasureDAmount, 0) + ISNULL(rs.PremiumMeasureEAmount, 0) + 
			ISNULL(rs.PremiumMeasureFAmount, 0) + ISNULL(rs.PremiumMeasureGAmount, 0) + ISNULL(rs.PremiumMeasureHAmount, 0) + ISNULL(rs.PremiumMeasureIAmount, 0) + ISNULL(rs.PremiumMeasureJAmount, 0) +
			ISNULL(rs.PremiumMeasureKAmount, 0) + ISNULL(rs.PremiumMeasureLAmount, 0) + ISNULL(rs.PremiumMeasureMAmount, 0) + ISNULL(rs.PremiumMeasureNAmount, 0) + ISNULL(rs.PremiumMeasureOAmount, 0)
		) AS CurrentYearPremiumCalculatedSubtotalPreIC, 
		ROUND(rs.PremiumMeasureAmountTotal, 0) AS CurrentYearTotalPremiumCalculated,  
		ROUND((rs.PremiumMeasurePayAmountTotal / 3), 0) AS CurrentYearPremiumPayout,  
		ROUND((rs.PremiumMeasurePayAmountTotal / 3) * er.ExchangeRate, 0) AS CurrentYearPremiumPayoutUSD,  
		rs.PreviousYearCarryover,   
		rs.PreviousYearPremiumPayout,   
		rs.PreviousYearPremiumPayoutUSD,   
		CASE WHEN ISNULL(rs.PreviousYearPremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode THEN 1 ELSE 0 END AS PreviousYearPremiumCurrencyErrorFlag,  
		CASE WHEN ISNULL(rs.CurrentYearMinus2PremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode THEN 1 ELSE 0 END AS CurrentYearMinus2PremiumCurrencyErrorFlag,  
		CASE  
			WHEN rs.PreviousYearPremiumCurrency = rs.CurrentYearMinus2PremiumCurrency AND ISNULL(rs.PreviousYearPremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode  
				THEN 'Premium Currency Conversion Required From ' + rs.PreviousYearPremiumCurrency + ' To ' + rs.CurrencyCode  
			WHEN ISNULL(rs.PreviousYearPremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode AND ISNULL(rs.CurrentYearMinus2PremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode  
				THEN 'Premium Currency Conversion Required From ' + rs.PreviousYearPremiumCurrency + ' To ' + rs.CurrencyCode + ' and ' + rs.CurrentYearMinus2PremiumCurrency + ' To ' + rs.CurrencyCode  
			WHEN ISNULL(rs.PreviousYearPremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode  
				THEN 'Premium Currency Conversion Required From ' + rs.PreviousYearPremiumCurrency + ' To ' + rs.CurrencyCode  
			WHEN ISNULL(rs.CurrentYearMinus2PremiumCurrency, rs.CurrencyCode) <> rs.CurrencyCode  
				THEN 'Premium Currency Conversion Required From ' + rs.CurrentYearMinus2PremiumCurrency + ' To ' + rs.CurrencyCode  
			ELSE NULL  
		END AS PremiumCurrencyErrorMessage,  
		rs.PreviousYearPremiumCurrency,  
		rs.PreviousYearPremiumExchangeRate,  
		rs.CurrentYearMinus2Carryover,   
		rs.CurrentYearMinus2PremiumPayout,   
		rs.CurrentYearMinus2PremiumPayoutUSD,  
		rs.CurrentYearMinus2PremiumCurrency,  
		rs.CurrentYearMinus2PremiumExchangeRate,  
		ROUND(((ISNULL(rs.PremiumMeasurePayAmountTotal,0) / 3) + ISNULL(rs.PreviousYearPremiumPayout, 0) + ISNULL(rs.CurrentYearMinus2PremiumPayout, 0)), 0) AS TotalPremiumPayout,  
		ROUND((((ISNULL(rs.PremiumMeasurePayAmountTotal,0) / 3) * er.ExchangeRate) + ISNULL(PreviousYearPremiumPayoutUSD, 0) + ISNULL(CurrentYearMinus2PremiumPayoutUSD, 0)), 0) AS TotalPremiumPayoutUSD,  

		ROUND(
			ROUND(ISNULL(obe.BDIBonusAmt,0), -1) 
			+ ROUND(ISNULL(rs.AnnualMeasurePayAmountTotal,0), -1) 
			+ ROUND((ISNULL(rs.PremiumMeasurePayAmountTotal,0) / 3), 0) 
			+ ISNULL(rs.PreviousYearPremiumPayout * rs.TimeInInvolvementFactor, 0) -- JM 20190922 added TimeInInvolvementFactor to PreviousYearPremiumPayout and CurrentYearMinus2Carryover
			+ ISNULL(rs.CurrentYearMinus2Carryover * rs.TimeInInvolvementFactor, 0) -- + ISNULL(obe.SGIBonusAmt, ROUND(ROUND(ISNULL(sgiprev.SGIComponentAAmount,0), 2) + ROUND(ISNULL(sgiprev.SGIComponentBAmount,0), 2), -1))
		, 0) AS TotalPayoutAmount,

		ROUND(
			(
			ROUND(ISNULL(obe.BDIBonusAmt,0), -1) 
			+ ROUND(ISNULL(rs.AnnualMeasurePayAmountTotal,0), -1) 
			+ ROUND((ISNULL(rs.PremiumMeasurePayAmountTotal,0) / 3), 0) 
			+ ISNULL(rs.PreviousYearPremiumPayout * rs.TimeInInvolvementFactor, 0) -- JM 20190922 added TimeInInvolvementFactor to PreviousYearPremiumPayout and CurrentYearMinus2Carryover
			+ ISNULL(rs.CurrentYearMinus2Carryover * rs.TimeInInvolvementFactor, 0) -- + ISNULL(obe.SGIBonusAmt, ROUND(ROUND(ISNULL(sgiprev.SGIComponentAAmount,0), 2) + ROUND(ISNULL(sgiprev.SGIComponentBAmount,0), 2), -1))
			) * er.ExchangeRate
		, 0) AS TotalPayoutAmountUSD,

		er.ExchangeRate,  
		rs.CurrencyCode,  
		rs.CostCenterCode,  
		rs.SectorCode_nk,  
		s.SectorName,  
		rs.DivisionCode_nk,  
		d.DivisionName,  
		rs.RegionCode_nk,  
		r.RegionName,  
		rs.BusinessUnitCode_nk,  
		bu.BusinessUnitName,  
		rs.MarketUnitCode_nk,  
		mu.MarketUnitName,  
		rs.WorkLocationCode_nk,  
		wl.WorkLocationName,
		rs.JobFunctionCode_nk,
		jf.JobFunctionName,
		rs.LegalEntityCode_nk,
		rs.CountryCode_nk,  
		le.LegalEntityName,
		cn.CountryName,  
		rs.SalaryPlanCode_nk,
		sp.SalaryPlanName,
		rs.BonusSalary,  
		rs.TimeInInvolvementFactor,  
		rs.AnnualAmount,
		rs.ic_score
		--B2024-02 -- YS 20240808_1
		,emp.LegalEntityCode_nk AS Current_LegalEntityCode -- YS 20240808_1
		,le_c.LegalEntityLabel AS Current_LegalEntityName -- YS 20240808_1
		--O2024-27 -- YS 20240808_2
		,emp.CountryCode_nk AS Current_CountryCode_nk -- YS 20240808_2
		,c_c.CountryLabel AS Current_CountryName -- YS 20240808_2
		,emp.SalaryPlanCode_nk AS Current_SalaryPlanCode_nk -- YS 20240808_2
		,sp_c.SalaryPlanName AS Current_SalaryPlanName -- YS 20240808_2
		,cg_c.idCompGroup AS Current_idCompGroup -- YS 20240808_2
		,cg_c.CompGroupName AS Current_CompGroupName -- YS 20240808_2
	INTO #ResultSet  
	FROM #ResultSet4 AS rs  
	LEFT JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp -- YS 20220824
		ON emp.codePayee = rs.GPID
	LEFT JOIN py_Payee AS mgr_hr -- YS 20220824
		ON mgr_hr.codePayee = emp.HRMGPID
	LEFT JOIN #OvrdBonusEarnings AS obe  
		ON rs.GPID = obe.GPID  
		AND rs.StartDateInvolvement <= obe.EndDate  
		AND rs.EndDateInvolvement >= obe.StartDate  
	LEFT JOIN dbo.PEPSICO_Sector AS s  
		ON rs.SectorCode_nk = s.SectorCode_nk  
		AND rs.StartDateInvolvement <= s.SectorEndDate  
		AND rs.EndDateInvolvement >= s.SectorStartDate  
	LEFT JOIN dbo.PEPSICO_Division AS d  
		ON rs.DivisionCode_nk = d.DivisionCode_nk  
		AND rs.StartDateInvolvement <= d.DivisionEndDate  
		AND rs.EndDateInvolvement >= d.DivisionStartDate  
	LEFT JOIN dbo.PEPSICO_Region AS r  
		ON rs.RegionCode_nk = r.RegionCode_nk  
		AND rs.StartDateInvolvement <= r.RegionEndDate  
		AND rs.EndDateInvolvement >= r.RegionStartDate  
	LEFT JOIN dbo.PEPSICO_BusinessUnit AS bu  
		ON rs.BusinessUnitCode_nk = bu.BusinessUnitCode_nk  
		AND rs.StartDateInvolvement <= bu.BusinessUnitEndDate  
		AND rs.EndDateInvolvement >= bu.BusinessUnitStartDate  
	LEFT JOIN dbo.PEPSICO_MarketUnit AS mu  
		ON rs.MarketUnitCode_nk = mu.MarketUnitCode_nk  
		AND rs.StartDateInvolvement <= mu.MarketUnitEndDate  
		AND rs.EndDateInvolvement >= mu.MarketUnitStartDate  
	LEFT JOIN dbo.PEPSICO_WorkLocation AS wl  
		ON rs.WorkLocationCode_nk = wl.WorkLocationCode_nk  
		AND rs.StartDateInvolvement <= wl.WorkLocationEndDate  
		AND rs.EndDateInvolvement >= wl.WorkLocationStartDate
	LEFT JOIN dbo.PEPSICO_JobFunction AS jf -- TO 20230721
		ON rs.JobFunctionCode_nk = jf.JobFunctionCode_nk
		AND rs.StartDateInvolvement <= jf.JobFunctionEndDate
		AND rs.EndDateInvolvement >= jf.JobFunctionStartDate
	LEFT JOIN dbo.PEPSICO_LegalEntity AS le
		ON rs.LegalEntityCode_nk = le.LegalEntityCode_nk  
		AND rs.StartDateInvolvement <= le.LegalEntityEndDate
		AND rs.EndDateInvolvement >= le.LegalEntityStartDate
	LEFT JOIN dbo.PEPSICO_Country AS cn  
		ON rs.CountryCode_nk = cn.CountryCode_nk  
		AND rs.StartDateInvolvement <= cn.CountryEndDate  
		AND rs.EndDateInvolvement >= cn.CountryStartDate  
	LEFT JOIN dbo.PEPSICO_SalaryPlan AS sp
		ON rs.SalaryPlanCode_nk = sp.SalaryPlanCode_nk
		AND rs.StartDateInvolvement <= sp.SalaryPlanEndDate
		AND rs.EndDateInvolvement >= sp.SalaryPlanStartDate
	LEFT JOIN #ExchangeRates AS er  
		ON rs.CurrencyCode = er.CurrencyCode  
		AND er.[Year] = @FiscalYear  
	LEFT JOIN #TeamsAssigned AS t  
		ON rs.GPID = t.GPID  
		AND rs.StartDateInvolvement <= t.EndDateInvolvement  
		AND rs.EndDateInvolvement >= t.StartDateInvolvement  
	LEFT JOIN #PlanTypesAssigned AS pt  
		ON rs.GPID = pt.GPID  
		AND rs.StartDateInvolvement = pt.StartDateInvolvement  
		AND rs.EndDateInvolvement = pt.EndDateInvolvement  
	LEFT JOIN #DuplicateInvolvements AS di  
		ON rs.GPID = di.GPID  
		AND rs.StartDateInvolvement = di.StartDateInvolvement  
	LEFT JOIN vPEPSICO_LegalEntity AS le_c -- YS 20240808_1
		ON le_c.LegalEntityCode_nk = emp.LegalEntityCode_nk
	LEFT JOIN PEPSICO_CompGroupPayees AS cgp_c -- YS 20240808_2
		ON cgp_c.GPID = emp.GPID
		AND IIF(GETUTCDATE() > @FiscalYearEnd, @FiscalYearEnd, GETUTCDATE()) BETWEEN cgp_c.StartDate AND cgp_c.EndDate	-- MZ 20250108
	LEFT JOIN PEPSICO_CompGroup AS cg_c -- YS 20240808_2
		ON cg_c.idCompGroup = cgp_c.idCompGroup
	LEFT JOIN vPEPSICO_SalaryPlan_All AS sp_c -- YS 20240808_2
		ON sp_c.SalaryPlanCode_nk = emp.SalaryPlanCode_nk
	LEFT JOIN vPEPSICO_Country AS c_c -- YS 20240808_2
		ON c_c.CountryCode_nk = emp.CountryCode_nk
 
	--drop table if exists #SGICurrent -- no longer used
	drop table if exists #DuplicateInvolvements -- no longer used  
	drop table if exists #ResultSet4 -- no longer used 
	drop table if exists #TeamsAssigned -- no longer used
	drop table if exists #ExchangeRates -- no longer used
	drop table if exists #OvrdBonusEarnings -- no longer used

	-- get involvement eligibility  
	
	DROP TABLE IF EXISTS #InvolvementEligibility  
  
	SELECT DISTINCT  
		e.GPID,
		e.StartDateInvolvement,
		e.EndDateInvolvement,  
		e.LevelCode -- JM 20190922
	INTO #InvolvementEligibility  
	FROM dbo.PEPSICO_Transaction_Bonus_Eligibility_Results_v2 AS e WITH(NOLOCK)
	--JOIN dbo._ufn_bonus_rep_standard_payees(@idUserProfile) AS brsp -- bonus security
	--	ON brsp.idPayee = e.idPayee
	JOIN #GPIDS AS g
		ON g.GPID = e.GPID
	WHERE 
		e.EligibilityPoints > 0  
  
print 'ResultSet (2). ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	-- get involvements missing in bonus table (no bonus team assigned or no bonus data)  
 
	INSERT INTO #ResultSet  
	(  
		GPID,
		FirstName,
		LastName,
		HR_GPID,-- YS 20220824
		HR_Name,-- YS 20220824
		StartDateInvolvement,
		EndDateInvolvement,
		InvolvementMonths,
		EmployeeCount,
		RecordCount,
		BonusTeam,
		PlanType,
		PreviousYearCarryover,
		PreviousYearPremiumPayout,
		PreviousYearPremiumPayoutUSD, 
		CurrentYearMinus2Carryover,
		CurrentYearMinus2PremiumPayout,
		CurrentYearMinus2PremiumPayoutUSD,
		[LG Group/Level],
		BonusTeamErrorFlag,
		PlanTypeErrorFlag,
		PlanTypeErrorMessage,
		InvolvementsErrorFlag,
		PreviousYearPremiumCurrencyErrorFlag,
		CurrentYearMinus2PremiumCurrencyErrorFlag
		--B2024-02 -- YS 20240808_1
		,Current_LegalEntityCode -- YS 20240808_1
		,Current_LegalEntityName -- YS 20240808_1
		--O2024-27 -- YS 20240808_2
		,Current_CountryCode_nk -- YS 20240808_2
		,Current_CountryName -- YS 20240808_2
		,Current_SalaryPlanCode_nk -- YS 20240808_2
		,Current_SalaryPlanName -- YS 20240808_2
		,Current_idCompGroup -- YS 20240808_2
		,Current_CompGroupName -- YS 20240808_2
	)  

	SELECT DISTINCT  
		t.GPID,  
		t.FirstName,  
		t.LastName,  
		ISNULL(mgr_hr.codePayee, '') AS HR_GPID, -- YS 20220824
		ISNULL(CONCAT(mgr_hr.firstname + ' ', mgr_hr.lastname), '') AS HR_Name, -- YS 20220824
		t.StartDateInvolvement,  
		t.EndDateInvolvement,  
		MONTH(t.EndDateInvolvement) - MONTH(t.StartDateInvolvement) + 1 AS InvolvementMonths,  
		0 AS EmployeeCount,  
		1 AS RecordCount,  
		bt.TeamName AS BonusTeam,  
		pt.PlanTypesAssigned AS PlanType,
		tp1.CarryOver AS PreviousYearCarryover, 
		tp1.Third AS PreviousYearPremiumPayout, 
		tp1.ThirdUSD AS PreviousYearPremiumPayoutUSD,
		tp2.CarryOver AS CurrentYearMinus2Carryover, 
		tp2.Third AS CurrentYearMinus2PremiumPayout, 
		tp2.ThirdUSD AS CurrentYearMinus2PremiumPayoutUSD,
		ie.LevelCode,
		0 AS BonusTeamErrorFlag,
		CASE WHEN ISNULL(pt.NoOfPlansAssigned, 0) <> 1 THEN 1 ELSE 0 END AS PlanTypeErrorFlag,
		CASE WHEN ISNULL(pt.NoOfPlansAssigned, 0) = 0 THEN 'No Bonus Plan Type Assigned'
			WHEN pt.NoOfPlansAssigned > 1 THEN 'Multiple Bonus Plan Types Assigned'
			ELSE NULL END AS PlanTypeErrorMessage,
		0 AS InvolvementsErrorFlag,
		0 AS PreviousYearPremiumCurrencyErrorFlag,
		0 AS CurrentYearMinus2PremiumCurrencyErrorFlag
		--B2024-02 -- YS 20240808_1
		,emp.LegalEntityCode_nk AS Current_LegalEntityCode -- YS 20240808_1
		,le_c.LegalEntityLabel AS Current_LegalEntityName -- YS 20240808_1
		--O2024-27 -- YS 20240808_2
		,emp.CountryCode_nk AS Current_CountryCode_nk -- YS 20240808_2
		,c_c.CountryLabel AS Current_CountryName -- YS 20240808_2
		,emp.SalaryPlanCode_nk AS Current_SalaryPlanCode_nk -- YS 20240808_2
		,sp_c.SalaryPlanName AS Current_SalaryPlanName -- YS 20240808_2
		,cg_c.idCompGroup AS Current_idCompGroup -- YS 20240808_2
		,cg_c.CompGroupName AS Current_CompGroupName -- YS 20240808_2
	FROM dbo.PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS t WITH (NOLOCK)  
	JOIN #InvolvementEligibility AS ie  
		ON t.GPID = ie.GPID  
		AND t.StartDateInvolvement = ie.StartDateInvolvement  
		AND t.EndDateInvolvement = ie.EndDateInvolvement  
	LEFT JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp -- YS 20220824
		ON emp.codePayee = t.GPID
	LEFT JOIN py_Payee AS mgr_hr -- YS 20220824
		ON mgr_hr.codePayee = emp.HRMGPID
	LEFT JOIN #ResultSet r  
		ON t.GPID = r.GPID  
		AND t.StartDateInvolvement = r.StartDateInvolvement  
		AND t.EndDateInvolvement = r.EndDateInvolvement  
	LEFT JOIN dbo.PEPSICO_OvrdHRAttributeForBonus AS ovrd_hr WITH (NOLOCK)  
		ON ovrd_hr.GPID = t.GPID  
		AND t.StartDateInvolvement <= ovrd_hr.EndDate  
		AND t.EndDateInvolvement >= ovrd_hr.StartDate  
	LEFT JOIN dbo.PEPSICO_BonusTeamPeopleAssignEmp btpa WITH (NOLOCK)  
		ON t.GPID = btpa.GPID  
		--ZD 141472 change -- ys 20251128
		--AND t.StartDateInvolvement = btpa.StartDateInvolvement
		--AND t.EndDateInvolvement = btpa.EndDateInvolvement
		AND (t.StartDateInvolvement >= btpa.StartDateInvolvement AND t.StartDateInvolvement <= btpa.EndDateInvolvement)
		AND (t.EndDateInvolvement >= btpa.StartDateInvolvement AND t.EndDateInvolvement <= btpa.EndDateInvolvement)
		--ZD 141472 change
	LEFT JOIN #PlanTypesAssigned AS pt
		ON pt.GPID = t.GPID
		AND pt.StartDateInvolvement = t.StartDateInvolvement
		AND pt.EndDateInvolvement = t.EndDateInvolvement
	LEFT JOIN dbo.PEPSICO_BonusTeam bt WITH (NOLOCK)  
		ON bt.idBonusTeam = btpa.idBonusTeam  
	LEFT JOIN #TrailingPremiums tp1 
		ON t.GPID = tp1.GPID
		AND @FiscalYear = tp1.FiscalYear + 1
	LEFT JOIN #TrailingPremiums tp2 
		ON t.GPID = tp2.GPID
		AND @FiscalYear = tp2.FiscalYear + 2
	LEFT JOIN vPEPSICO_LegalEntity AS le_c -- YS 20240808_1
		ON le_c.LegalEntityCode_nk = emp.LegalEntityCode_nk
	LEFT JOIN PEPSICO_CompGroupPayees AS cgp_c -- YS 20240808_2
		ON cgp_c.GPID = emp.GPID
		AND IIF(GETUTCDATE() > @FiscalYearEnd, @FiscalYearEnd, GETUTCDATE()) BETWEEN cgp_c.StartDate AND cgp_c.EndDate	-- MZ 20250108
	LEFT JOIN PEPSICO_CompGroup AS cg_c -- YS 20240808_2
		ON cg_c.idCompGroup = cgp_c.idCompGroup
	LEFT JOIN vPEPSICO_SalaryPlan_All AS sp_c -- YS 20240808_2
		ON sp_c.SalaryPlanCode_nk = emp.SalaryPlanCode_nk
	LEFT JOIN vPEPSICO_Country AS c_c -- YS 20240808_2
		ON c_c.CountryCode_nk = emp.CountryCode_nk
	WHERE 
		r.GPID IS NULL  
	AND t.FiscalYear = @FiscalYear  
	AND NOT  
		(  
			ISNULL(ovrd_hr.AnnualBonusPct, t.AnnualBonusPct * 100) = 0   
			AND ISNULL(ovrd_hr.BDIShortTermTarget, t.BDIShortTermTarget) = 0  
			AND ISNULL(ovrd_hr.PremBonusPct, t.PremBonusPct * 100) = 0  
		)  
  
	-- get selected comp groups  
 
--	DROP TABLE IF EXISTS #CompGroups  
  
--	SELECT 
--		CAST(value AS int) AS idCompGroup  
--	INTO #CompGroups  
--	FROM STRING_SPLIT(@idCompGroup, ',')  
  


--print 'ResultSet (3). ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

--	-- get GPIDs in the comp groups, with no bonus team assigned  
 
--	INSERT INTO #ResultSet  
--	(  
--		GPID,  
--		FirstName,  
--		LastName,  
--		EmployeeCount,  
--		RecordCount,  
--		BonusTeamErrorFlag,  
--		BonusTeamErrorMessage,  
--		PlanTypeErrorFlag,  
--		InvolvementsErrorFlag,  
--		PreviousYearPremiumCurrencyErrorFlag,
--		CurrentYearMinus2PremiumCurrencyErrorFlag,
--		StartDateInvolvement,  
--		EndDateInvolvement,  
--		PreviousYearCarryover, 
--		PreviousYearPremiumPayout,
--		PreviousYearPremiumPayoutUSD,
--		CurrentYearMinus2Carryover,
--		CurrentYearMinus2PremiumPayout,
--		CurrentYearMinus2PremiumPayoutUSD,
--		PreviousYearActualSGIComponentA,
--		PreviousYearActualSGIComponentAWeight,
--		PreviousYearActualSGIComponentB,
--		PreviousYearActualSGIComponentBWeight,
--		PreviousYearActualSGIComponentAScore,
--		PreviousYearActualSGIComponentBScore,
--		PreviousYearActualSGIComponentAAmount,
--		PreviousYearActualSGIComponentBAmount,
--		[LG Group/Level]
--	)  

--	SELECT DISTINCT  
--		cgp.GPID,  
--		p.firstname AS FirstName,  
--		p.lastname AS LastName,  
--		1 AS EmployeeCount,  
--		1 AS RecordCount,  
--		1 AS BonusTeamErrorFlag,  
--		'No Bonus Team Assigned' AS BonusTeamErrorMessage,  
--		0 AS PlanTypeErrorFlag,  
--		0 AS InvolvementsErrorFlag,  
--		0 AS PreviousYearPremiumCurrencyErrorFlag,  
--		0 AS CurrentYearMinus2PremiumCurrencyErrorFlag,  
--		cgp.StartDate,
--		cgp.EndDate,
--		tp1.CarryOver AS PreviousYearCarryover, 
--		tp1.Third AS PreviousYearPremiumPayout, 
--		tp1.ThirdUSD AS PreviousYearPremiumPayoutUSD, 
--		tp2.CarryOver AS CurrentYearMinus2Carryover, 
--		tp2.Third AS CurrentYearMinus2PremiumPayout, 
--		tp2.ThirdUSD AS CurrentYearMinus2PremiumPayoutUSD, 
--		sgiprev.SGIComponentA AS PreviousYearActualSGIComponentA,
--		sgiprev.SGIComponentAWeight AS PreviousYearActualSGIComponentAWeight,
--		sgiprev.SGIComponentB AS PreviousYearActualSGIComponentB,
--		sgiprev.SGIComponentBWeight AS PreviousYearActualSGIComponentBWeight,
--		sgiprev.SGIComponentAScore AS PreviousYearActualSGIComponentAScore,
--		sgiprev.SGIComponentBScore AS PreviousYearActualSGIComponentBScore,
--		sgiprev.SGIComponentAAmount AS PreviousYearActualSGIComponentAAmount,
--		sgiprev.SGIComponentBAmount AS PreviousYearActualSGIComponentBAmount,	
--		ie.LevelCode
--	FROM dbo.PEPSICO_CompGroupPayees AS cgp  
--	JOIN #InvolvementEligibility AS ie 
--		ON cgp.GPID = ie.GPID
--		AND cgp.StartDate = ie.StartDateInvolvement
--		AND cgp.EndDate = ie.EndDateInvolvement
--	JOIN (SELECT DISTINCT GPID FROM PEPSICO_Bonus_Eligibility WITH(NOLOCK)) AS f  
--		ON cgp.GPID = f.GPID  
--	JOIN #CompGroups AS scg  
--		ON cgp.idCompGroup = scg.idCompGroup  
--	JOIN dbo.py_Payee AS p  
--		ON cgp.GPID = p.codePayee  
--	JOIN #GPIDs AS g  
--		ON g.GPID = cgp.GPID  
--	LEFT JOIN dbo.PEPSICO_BonusTeamPeopleAssignEmp AS btpae  
--		ON cgp.GPID = btpae.GPID  
--	LEFT JOIN #TrailingPremiums AS tp1 
--		ON cgp.GPID = tp1.GPID
--		AND @FiscalYear = tp1.FiscalYear + 1
--	LEFT JOIN #TrailingPremiums AS tp2 
--		ON cgp.GPID = tp2.GPID
--		AND @FiscalYear = tp2.FiscalYear + 2
--	LEFT JOIN #SGIPrevious AS sgiprev 
--		ON cgp.GPID = sgiprev.GPID 
--	WHERE 
--		btpae.GPID IS NULL  
  
	drop table if exists #InvolvementEligibility -- no longer used
	drop table if exists #GPIDs -- no longer used
--	drop table if exists #CompGroups -- no longer used
	drop table if exists #TrailingPremiums -- no longer used













































































































































































		-- B2023-19 Get the last Extract Date for each GPID -- YS 20230907
	DROP TABLE IF EXISTS #extract_date
	;WITH cte_extact_gpid AS --187211 rows
	(
		SELECT 
			GPID, 
			be.FileNumber, 
			MAX(be.FileProcessID) AS FileProcessID 
		FROM PEPSICO_BonusExtract AS be
		JOIN PEPSICO_DataExtractScheduleHistory AS desh
			ON desh.FileNumber = be.FileNumber
			AND desh.FileProcessID = be.FileProcessID
			AND desh.DataReleaseStatus = 'Release'
			AND desh.ReleaseStatusUpdateTime > @firstdDayofYear
		WHERE be.FileProcessID <> 999999 
		GROUP BY be.GPID, be.FileNumber

	)
	SELECT 
		py.gpid,
		py.filenumber, 
		py.fileprocessid,
		adep.ReleaseDiscardUpdateTime
	INTO #extract_date
	FROM cte_extact_gpid AS py
	JOIN AUDIT_DataExtractProcessing AS adep
		ON adep.FileProcessID = py.FileProcessID
		AND adep.FileNumber = py.FileNumber

	--select * from #extract_date

	--identify Annual involvements and proration factor  
 
	DROP TABLE IF EXISTS #AnnualMonths  
 
	SELECT DISTINCT
		GPID,  
		StartDateInvolvement,  
		EndDateInvolvement,  
		MONTH(EndDateInvolvement) - MONTH(StartDateInvolvement) + 1 AS AnnualMonths  
	INTO #AnnualMonths  
	FROM #ResultSet  
  
	DROP TABLE IF EXISTS #AnnualTotalMonths  
 
	SELECT  
		GPID,  
		SUM(AnnualMonths) AS AnnualTotalMonths  
	INTO #AnnualTotalMonths  
	FROM #AnnualMonths  
	GROUP BY GPID  
  
	DROP TABLE IF EXISTS #AnnualInvolvements  
 
	SELECT DISTINCT  
		m.GPID,  
		m.StartDateInvolvement,  
		m.EndDateInvolvement,  
		m.AnnualMonths,  
		tm.AnnualTotalMonths,  
		CAST(m.AnnualMonths / (tm.AnnualTotalMonths * 1.0) AS decimal(7,6)) AS AnnualTimeInInvolvementFactor  
	INTO #AnnualInvolvements  
	FROM #AnnualMonths AS m  
	JOIN #AnnualTotalMonths As tm  
		ON m.GPID = tm.GPID  

	DROP TABLE IF EXISTS #AnnualMonths -- no longer used
	DROP TABLE IF EXISTS #AnnualTotalMonths -- no longer used  







print 'ResultSet_Final. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	DROP TABLE IF EXISTS #ResultSet_Final  
  
	SELECT DISTINCT  
		r.PlanTypeErrorFlag  
		,r.PlanType  
		,r.BonusTeamErrorFlag  
		,SUBSTRING(ISNULL(', ' + r.PlanTypeErrorMessage, '') + ISNULL(', ' + r.BonusTeamErrorMessage, '') + ISNULL(', ' + r.PremiumCurrencyErrorMessage, '') + ISNULL(', ' + r.InvolvementsErrorMessage, ''), 2, 1000) AS ErrorMessage  
		,r.BonusTeam  
		,r.EmployeeCount  
		,r.RecordCount  
		,r.FirstName  
		,r.LastName  
		,r.GPID  
		,r.HR_GPID -- YS 20220824
		,r.HR_Name -- YS 20220824
		,r.JobTitle AS r_JobTitle
		,r.[LG Group/Level] AS [r_LG Group/Level]  
		,r.ExpatIndicator_YesNoBool  
		,r.InvolvementsErrorFlag  
		,r.StartDateInvolvement  
		,r.EndDateInvolvement  
		,r.InvolvementMonths AS r_InvolvementMonths 
		,NULLIF(r.PriorYearBonusSalary, 0) AS PriorYearBonusSalary  
		,ISNULL(hr_OverW.AnnualBonusPct, NULLIF(r.AnnualBonusPct * 100.00, 0)) AS r_AnnualBonusPct  --20250212
		,ISNULL(hr_OverW.PremBonusPct,NULLIF(r.PremBonusPct * 100.00, 0)) AS r_PremBonusPct 
		--,NULLIF(ROUND(r.BDITargetAmount * r.TimeInInvolvementFactor, 2), 0) AS r_BDITargetAmount -- JM 20230223
		,ISNULL(hr_OverW.BDIShortTermTarget, NULLIF(ROUND(r.BDITargetAmount * r.TimeInInvolvementFactor, 2), 0)) AS r_BDITargetAmount -- JM 20230223
		,NULLIF(ROUND(r.BonusSalary * r.AnnualBonusPct * r.TimeInInvolvementFactor, 2), 0) AS r_AnnualBonusTargetAmount 
		,NULLIF(ROUND(r.BonusSalary * r.PremBonusPct * r.TimeInInvolvementFactor, 2), 0) AS r_PremiumBonusTargetAmount 
		,r.AdHocPlanIndicator  
		,r.MeasureA  
		,NULLIF(r.MeasureAWeight, 0) AS MeasureAWeight  
		,NULLIF(r.MeasureAScore, 0) AS MeasureAScore  
		,r.MeasureB  
		,NULLIF(r.MeasureBWeight, 0) AS MeasureBWeight  
		,NULLIF(r.MeasureBScore, 0) AS MeasureBScore  
		,r.MeasureC  
		,NULLIF(r.MeasureCWeight, 0) AS MeasureCWeight  
		,NULLIF(r.MeasureCScore, 0) AS MeasureCScore  
		,r.MeasureD  
		,NULLIF(r.MeasureDWeight, 0) AS MeasureDWeight  
		,NULLIF(r.MeasureDScore, 0) AS MeasureDScore  
		,r.MeasureE  
		,NULLIF(r.MeasureEWeight, 0) AS MeasureEWeight  
		,NULLIF(r.MeasureEScore, 0) AS MeasureEScore  
		,r.MeasureF  
		,NULLIF(r.MeasureFWeight, 0) AS MeasureFWeight  
		,NULLIF(r.MeasureFScore, 0) AS MeasureFScore  
		,r.MeasureG  
		,NULLIF(r.MeasureGWeight, 0) AS MeasureGWeight  
		,NULLIF(r.MeasureGScore, 0) AS MeasureGScore  
		,r.MeasureH  
		,NULLIF(r.MeasureHWeight, 0) AS MeasureHWeight  
		,NULLIF(r.MeasureHScore, 0) AS MeasureHScore  
		,r.MeasureI  
		,NULLIF(r.MeasureIWeight, 0) AS MeasureIWeight  
		,NULLIF(r.MeasureIScore, 0) AS MeasureIScore  
		,r.MeasureJ  
		,NULLIF(r.MeasureJWeight, 0) AS MeasureJWeight  
		,NULLIF(r.MeasureJScore, 0) AS MeasureJScore  
		,r.MeasureK  
		,NULLIF(r.MeasureKWeight, 0) AS MeasureKWeight  
		,NULLIF(r.MeasureKScore, 0) AS MeasureKScore  
		,r.MeasureL  
		,NULLIF(r.MeasureLWeight, 0) AS MeasureLWeight  
		,NULLIF(r.MeasureLScore, 0) AS MeasureLScore  
		,r.MeasureM  
		,NULLIF(r.MeasureMWeight, 0) AS MeasureMWeight  
		,NULLIF(r.MeasureMScore, 0) AS MeasureMScore  
		,r.MeasureN  
		,NULLIF(r.MeasureNWeight, 0) AS MeasureNWeight  
		,NULLIF(r.MeasureNScore, 0) AS MeasureNScore  
		,r.MeasureO  
		,NULLIF(r.MeasureOWeight, 0) AS MeasureOWeight  
		,NULLIF(r.MeasureOScore, 0) AS MeasureOScore  
		,NULLIF(r.AnnualMeasureAAmount, 0) AS AnnualMeasureAAmount  
		,NULLIF(r.AnnualMeasureBAmount, 0) AS AnnualMeasureBAmount  
		,NULLIF(r.AnnualMeasureCAmount, 0) AS AnnualMeasureCAmount  
		,NULLIF(r.AnnualMeasureDAmount, 0) AS AnnualMeasureDAmount  
		,NULLIF(r.AnnualMeasureEAmount, 0) AS AnnualMeasureEAmount  
		,NULLIF(r.AnnualMeasureFAmount, 0) AS AnnualMeasureFAmount  
		,NULLIF(r.AnnualMeasureGAmount, 0) AS AnnualMeasureGAmount  
		,NULLIF(r.AnnualMeasureHAmount, 0) AS AnnualMeasureHAmount  
		,NULLIF(r.AnnualMeasureIAmount, 0) AS AnnualMeasureIAmount  
		,NULLIF(r.AnnualMeasureJAmount, 0) AS AnnualMeasureJAmount  
		,NULLIF(r.AnnualMeasureKAmount, 0) AS AnnualMeasureKAmount  
		,NULLIF(r.AnnualMeasureLAmount, 0) AS AnnualMeasureLAmount  
		,NULLIF(r.AnnualMeasureMAmount, 0) AS AnnualMeasureMAmount  
		,NULLIF(r.AnnualMeasureNAmount, 0) AS AnnualMeasureNAmount  
		,NULLIF(r.AnnualMeasureOAmount, 0) AS AnnualMeasureOAmount  
		,NULLIF(r.PremiumMeasureAAmount, 0) AS PremiumMeasureAAmount  
		,NULLIF(r.PremiumMeasureBAmount, 0) AS PremiumMeasureBAmount  
		,NULLIF(r.PremiumMeasureCAmount, 0) AS PremiumMeasureCAmount  
		,NULLIF(r.PremiumMeasureDAmount, 0) AS PremiumMeasureDAmount  
		,NULLIF(r.PremiumMeasureEAmount, 0) AS PremiumMeasureEAmount  
		,NULLIF(r.PremiumMeasureFAmount, 0) AS PremiumMeasureFAmount  
		,NULLIF(r.PremiumMeasureGAmount, 0) AS PremiumMeasureGAmount  
		,NULLIF(r.PremiumMeasureHAmount, 0) AS PremiumMeasureHAmount  
		,NULLIF(r.PremiumMeasureIAmount, 0) AS PremiumMeasureIAmount  
		,NULLIF(r.PremiumMeasureJAmount, 0) AS PremiumMeasureJAmount  
		,NULLIF(r.PremiumMeasureKAmount, 0) AS PremiumMeasureKAmount  
		,NULLIF(r.PremiumMeasureLAmount, 0) AS PremiumMeasureLAmount  
		,NULLIF(r.PremiumMeasureMAmount, 0) AS PremiumMeasureMAmount  
		,NULLIF(r.PremiumMeasureNAmount, 0) AS PremiumMeasureNAmount  
		,NULLIF(r.PremiumMeasureOAmount, 0) AS PremiumMeasureOAmount  
		,NULLIF(r.AnnualGuaranteeAmount, 0) AS AnnualGuaranteeAmount  
		,NULLIF(r.PremiumGuaranteeAmount, 0) AS PremiumGuaranteeAmount  
		,NULLIF(r.BDIGuaranteeAmount, 0) AS BDIGuaranteeAmount  
		,NULLIF(r.AnnualSubTotal, 0) AS AnnualSubTotal  
		,NULLIF(r.AnnualSubTotalPreIC, 0) AS AnnualSubTotalPreIC
		,r.LOAProration  
		,CASE
			WHEN NULLIF(r.AnnualGuaranteeAmount, 0) IS NOT NULL THEN r.AnnualGuaranteeAmount * ai.AnnualTimeInInvolvementFactor -- JM 20210212 changed to AnnualTimeInInvolvementFactor
			WHEN r.CurrentYearTotalAnnualPayout = 0 THEN NULL
			ELSE NULLIF(ROUND(r.CurrentYearTotalAnnualPayout * (CAST(r.AnnualSubTotal AS decimal(36,24)) / r.AnnualMeasurePayAmountTotal), 2), 0)
		END AS CurrentYearTotalAnnualPayout
		,CASE
			WHEN NULLIF(r.AnnualGuaranteeAmount, 0) IS NOT NULL THEN (r.AnnualGuaranteeAmount * r.ExchangeRate) * ai.AnnualTimeInInvolvementFactor -- JM 20210212 changed to AnnualTimeInInvolvementFactor
			WHEN r.CurrentYearTotalAnnualPayout = 0 THEN NULL
			ELSE NULLIF(ROUND(r.CurrentYearTotalAnnualPayoutUSD * (CAST(r.AnnualSubTotal AS decimal(36,24)) / r.AnnualMeasurePayAmountTotal), 2), 0)
		END AS CurrentYearTotalAnnualPayoutUSD
		,NULLIF(r.CurrentYearPremiumCalculatedSubtotal, 0) AS CurrentYearPremiumCalculatedSubtotal  
		,NULLIF(r.CurrentYearPremiumCalculatedSubtotalPreIC, 0) AS CurrentYearPremiumCalculatedSubtotalPreIC
		,CASE WHEN r.[LG Group/Level] IN ('LG1', 'LG2', 'LG3', 'LG4', 'LG5', 'LG6','LG7', 'LG8')
			THEN NULLIF(r.CurrentYearTotalPremiumCalculated, 0)  
			ELSE NULL  
		END AS CurrentYearTotalPremiumCalculated  
		,CASE WHEN r.[LG Group/Level] IN ('LG1', 'LG2', 'LG3', 'LG4', 'LG5', 'LG6','LG7', 'LG8')
			THEN NULLIF(ROUND(r.CurrentYearPremiumPayout * pri.PremiumTimeInInvolvementFactor, 2), 0)  
			ELSE NULL  
		END AS CurrentYearPremiumPayout  
		,CASE WHEN r.[LG Group/Level] IN ('LG1', 'LG2', 'LG3', 'LG4', 'LG5', 'LG6','LG7', 'LG8')
			THEN NULLIF(ROUND(r.CurrentYearPremiumPayoutUSD * pri.PremiumTimeInInvolvementFactor, 2), 0)  
			ELSE NULL  
		END AS CurrentYearPremiumPayoutUSD  
		,NULLIF(r.PreviousYearCarryover, 0) AS PreviousYearCarryover  
		,r.PreviousYearPremiumPayout AS r_PreviousYearPremiumPayout -- JM 20190911
		,r.PreviousYearPremiumPayoutUSD AS r_PreviousYearPremiumPayoutUSD -- JM 20190911
		,r.PreviousYearPremiumCurrencyErrorFlag  
		,r.PreviousYearPremiumCurrency  
		,r.PreviousYearPremiumExchangeRate  
		,NULLIF(r.CurrentYearMinus2Carryover, 0) AS CurrentYearMinus2Carryover  
		,r.CurrentYearMinus2PremiumPayout AS r_CurrentYearMinus2PremiumPayout  -- JM 20190911
		,r.CurrentYearMinus2PremiumPayoutUSD AS r_CurrentYearMinus2PremiumPayoutUSD  -- JM 20190911
		,r.CurrentYearMinus2PremiumCurrency  
		,r.CurrentYearMinus2PremiumCurrencyErrorFlag  
		,r.CurrentYearMinus2PremiumExchangeRate  
		,NULLIF(ROUND(r.TotalPremiumPayout * ai.AnnualTimeInInvolvementFactor, 2), 0) AS r_TotalPremiumPayout -- JM 20240916 changed to r_
		,NULLIF(ROUND(r.TotalPremiumPayoutUSD * ai.AnnualTimeInInvolvementFactor, 2), 0) AS r_TotalPremiumPayoutUSD -- JM 20240916 changed to r_
		,NULLIF(ROUND(r.TotalPayoutAmount * ai.AnnualTimeInInvolvementFactor, 2), 0) AS TotalPayoutAmount_old			--modified 20190808 sharrell, new logic in final select
		,NULLIF(ROUND(r.TotalPayoutAmountUSD * ai.AnnualTimeInInvolvementFactor, 2), 0) AS TotalPayoutAmountUSD_old	--modified 20190808 sharrell, new logic in final select
		,r.ExchangeRate  
		,r.CurrencyCode AS r_CurrencyCode -- JM 20190829
		,r.CostCenterCode AS r_CostCenterCode  -- JM 20190814
		,r.SectorCode_nk AS r_SectorCode_nk    -- JM 20190814
		,r.SectorName AS r_SectorName -- JM 20190814
		,r.DivisionCode_nk AS r_DivisionCode_nk -- JM 20190814
		,r.DivisionName AS r_DivisionName -- JM 20190814
		,r.RegionCode_nk AS r_RegionCode_nk -- JM 20190814
		,r.RegionName AS r_RegionName -- JM 20190814
		,r.BusinessUnitCode_nk AS r_BusinessUnitCode_nk   -- JM 20190814
		,r.BusinessUnitName AS r_BusinessUnitName -- JM 20190814
		,r.MarketUnitCode_nk AS r_MarketUnitCode_nk -- JM 20190814
		,r.MarketUnitName AS r_MarketUnitName -- JM 20190814
		,r.WorkLocationCode_nk AS r_WorkLocationCode_nk -- JM 20190814
		,r.WorkLocationName AS r_WorkLocationName   -- JM 20190814
		,r.JobFunctionCode_nk AS r_JobFunctionCode_nk -- TO 20230721
		,r.JobFunctionName AS r_JobFunctionName -- TO 20230721
		,r.LegalEntityCode_nk AS r_LegalEntityCode_nk
		,r.CountryCode_nk AS r_CountryCode_nk  -- JM 20190814
		,r.LegalEntityName AS r_LegalEntityName
		,r.CountryName AS r_CountryName  -- JM 20190814
		,r.SalaryPlanCode_nk AS r_SalaryPlanCode_nk
		,r.SalaryPlanName AS r_SalaryPlanName 
		,NULLIF(r.BonusSalary, 0) AS r_BonusSalary -- JM 20190828  
		,NULLIF(r.AnnualAmount, 0) AS r_AnnualAmount -- JM 20190828  
		,ISNULL(r.TimeInInvolvementFactor, CAST((DATEDIFF(MONTH, r.StartDateInvolvement, r.EndDateInvolvement) + 1.000000) / 12 AS DECIMAL(7,6))) AS TimeInInvolvementFactor -- JM 20190828
		,ai.AnnualTimeInInvolvementFactor -- JM 20190911
		,r.ic_score
		,CAST(NULL AS datetime) AS ScheduledExtractDate --TO 20230725
		--,CAST(NULL AS datetime) AS ExtractDate --TO 20230725
		,CAST(ed.ReleaseDiscardUpdateTime AS datetime) AS ExtractDate --YS 20230907
--		,CAST(NULL as decimal(18,4)) AS FinalMeasure --TO 20230725
		,CAST(NULL as decimal(18,4)) AS FinalWeight --TO 20230725
		,FinalMeasure = 
			ISNULL(r.MeasureAWeight, 0) / 100 * ISNULL(r.MeasureAScore, 0) +
			ISNULL(r.MeasureBWeight, 0) / 100 * ISNULL(r.MeasureBScore, 0) +
			ISNULL(r.MeasureCWeight, 0) / 100 * ISNULL(r.MeasureCScore, 0) +
			ISNULL(r.MeasureDWeight, 0) / 100 * ISNULL(r.MeasureDScore, 0) +
			ISNULL(r.MeasureEWeight, 0) / 100 * ISNULL(r.MeasureEScore, 0) +
			ISNULL(r.MeasureFWeight, 0) / 100 * ISNULL(r.MeasureFScore, 0) +
			ISNULL(r.MeasureGWeight, 0) / 100 * ISNULL(r.MeasureGScore, 0) +
			ISNULL(r.MeasureHWeight, 0) / 100 * ISNULL(r.MeasureHScore, 0) +
			ISNULL(r.MeasureIWeight, 0) / 100 * ISNULL(r.MeasureIScore, 0) +
			ISNULL(r.MeasureJWeight, 0) / 100 * ISNULL(r.MeasureJScore, 0) +
			ISNULL(r.MeasureKWeight, 0) / 100 * ISNULL(r.MeasureKScore, 0) +
			ISNULL(r.MeasureLWeight, 0) / 100 * ISNULL(r.MeasureLScore, 0) +
			ISNULL(r.MeasureMWeight, 0) / 100 * ISNULL(r.MeasureMScore, 0) +
			ISNULL(r.MeasureNWeight, 0) / 100 * ISNULL(r.MeasureNScore, 0) +
			ISNULL(r.MeasureOWeight, 0) / 100 * ISNULL(r.MeasureOScore, 0) 
		,r.Current_LegalEntityCode -- YS 20240808_1
		,r.Current_LegalEntityName -- YS 20240808_1
		,r.Current_CountryCode_nk -- YS 20240808_2
		,r.Current_CountryName -- YS 20240808_2
		,r.Current_SalaryPlanCode_nk -- YS 20240808_2
		,r.Current_SalaryPlanName -- YS 20240808_2
		,r.Current_idCompGroup -- YS 20240808_2
		,r.Current_CompGroupName -- YS 20240808_2
	INTO #ResultSet_Final  
	FROM #ResultSet AS r  
	LEFT JOIN #AnnualInvolvements AS ai  
		ON r.GPID = ai.GPID  
		AND r.StartDateInvolvement = ai.StartDateInvolvement  
		AND r.EndDateInvolvement = ai.EndDateInvolvement  
	LEFT JOIN #PremiumInvolvements pri  
		ON r.GPID = pri.GPID  
		AND r.StartDateInvolvement = pri.StartDateInvolvement  
		AND r.EndDateInvolvement = pri.EndDateInvolvement  
	LEFT JOIN PEPSICO_OvrdHRAttributeForBonus hr_OverW WITH (NOLOCK)
		ON r.GPID = hr_OverW.GPID
		AND r.StartDateInvolvement Between hr_OverW.StartDate AND hr_OverW.EndDate
		AND r.EndDateInvolvement Between hr_OverW.StartDate AND hr_OverW.EndDate
	LEFT JOIN #extract_date AS ed -- YS 20230907
		ON ed.gpid = r.GPID

	OPTION(USE HINT('enable_parallel_plan_preference'),HASH JOIN)  

	drop table if exists #AnnualInvolvements -- no longer used
	drop table if exists #PremiumInvolvements -- no longer used
	drop table if exists #ResultSet -- no longer used

print 'Before End. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

 	-- get india deferred into a temp table
	DROP TABLE IF EXISTS #ind_def

	SELECT * INTO #ind_def FROM vPEPSICO_India_Deferred_Bonus
  
	DROP TABLE IF EXISTS #rs

	SELECT 
		r.*

		,ISNULL(r.r_CostCenterCode, et.CostCenter) AS CostCenterCode   -- JM 20190814
		,ISNULL(r.r_JobTitle, et.JobTitle) AS JobTitle   -- JM 20190814
		,ISNULL(r.[r_LG Group/Level] , et.LevelCode) AS [LG Group/Level]   -- JM 20190814

        ,ISNULL(r.r_SectorCode_nk, s.SectorCode_nk) AS SectorCode_nk -- JM 20190814
        ,ISNULL(r.r_DivisionCode_nk, d.DivisionCode_nk) AS DivisionCode_nk -- JM 20190814
        ,ISNULL(r.r_RegionCode_nk, reg.RegionCode_nk) AS RegionCode_nk -- JM 20190814
        ,ISNULL(r.r_BusinessUnitCode_nk, bu.BusinessUnitCode_nk) AS BusinessUnitCode_nk   -- JM 20190814
        ,ISNULL(r.r_MarketUnitCode_nk, mu.MarketUnitCode_nk) AS MarketUnitCode_nk -- JM 20190814
        ,ISNULL(r.r_WorkLocationCode_nk, wl.WorkLocationCode_nk) AS WorkLocationCode_nk  -- JM 20190814 
		,ISNULL(r.r_JobFunctionCode_nk, jf.JobFunctionCode_nk) AS JobFunctionCode_nk  -- TO 20230721
        ,ISNULL(r.r_LegalEntityCode_nk, le.LegalEntityCode_nk) AS LegalEntityCode_nk  -- JM 20190814 
        ,ISNULL(r.r_CountryCode_nk, cn.CountryCode_nk) AS CountryCode_nk  -- JM 20190814 
        ,ISNULL(r.r_SalaryPlanCode_nk, sp.SalaryPlanCode_nk) AS SalaryPlanCode_nk  -- JM 20190814 

		,ISNULL(r.r_CurrencyCode, et.AnnualCurrencyCode) AS CurrencyCode  -- JM 201908129

        ,ISNULL(r.r_SectorName, s.SectorName) AS SectorName -- JM 20190814
        ,ISNULL(r.r_DivisionName, d.DivisionName) AS DivisionName -- JM 20190814
        ,ISNULL(r.r_RegionName, reg.RegionName) AS RegionName -- JM 20190814
        ,ISNULL(r.r_BusinessUnitName, bu.BusinessUnitName) AS BusinessUnitName   -- JM 20190814
        ,ISNULL(r.r_MarketUnitName, mu.MarketUnitName) AS MarketUnitName -- JM 20190814
        ,ISNULL(r.r_WorkLocationName, wl.WorkLocationName) AS WorkLocationName  -- JM 20190814 
        ,ISNULL(r.r_JobFunctionName, jf.JobFunctionName) AS JobFunctionName  -- TO 20230721
        ,ISNULL(r.r_LegalEntityName, le.LegalEntityName) AS LegalEntityName  -- JM 20190814 
        ,ISNULL(r.r_CountryName, cn.CountryName) AS CountryName  -- JM 20190814 
        ,ISNULL(r.r_SalaryPlanName, sp.SalaryPlanName) AS SalaryPlanName  -- JM 20190814 

		,ISNULL(r.r_InvolvementMonths, MONTH(r.EndDateInvolvement) - MONTH(r.StartDateInvolvement) + 1) AS InvolvementMonths	-- SH 20190824 -- JM 20190828
		,ISNULL(r.r_BonusSalary, et.BonusSalary) AS BonusSalary	-- SH 20190824 -- JM 20190828
		,ISNULL(r.r_AnnualAmount, et.AnnualAmount) AS AnnualAmount	-- SH 20190824 -- JM 20190828
		,ISNULL(r.r_AnnualBonusPct, et.AnnualBonusPct * 100) AS AnnualBonusPct	-- SH 20190824 -- JM 20190828
		,ISNULL(r.r_PremBonusPct, et.PremBonusPct * 100) AS PremBonusPct	-- SH 20190824 -- JM 20190828

		,ISNULL(r.r_BDITargetAmount, NULLIF(ROUND(et.BDIShortTermTarget * r.TimeInInvolvementFactor, 2), 0)) AS BDITargetAmount -- JM 20190828 
		,ISNULL(r.r_AnnualBonusTargetAmount, NULLIF(ROUND(et.BonusSalary * et.AnnualBonusPct * r.TimeInInvolvementFactor, 2), 0)) AS AnnualBonusTargetAmount -- JM 20190828

		,ISNULL(r.r_PremiumBonusTargetAmount, NULLIF(ROUND(et.BonusSalary * et.PremBonusPct * r.TimeInInvolvementFactor, 2), 0)) AS PremiumBonusTargetAmount -- JM 2019028

		,NULLIF(ROUND(r.r_PreviousYearPremiumPayout * r.AnnualTimeInInvolvementFactor, 2), 0) AS PreviousYearPremiumPayout -- JM 20190911 -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor
		,NULLIF(ROUND(r.r_PreviousYearPremiumPayoutUSD * r.AnnualTimeInInvolvementFactor, 2), 0) AS PreviousYearPremiumPayoutUSD -- JM 20190911 -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor

		,NULLIF(ROUND(r.r_CurrentYearMinus2PremiumPayout  * r.AnnualTimeInInvolvementFactor, 2), 0) AS CurrentYearMinus2PremiumPayout -- JM 20190911 -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor
		,NULLIF(ROUND(r.r_CurrentYearMinus2PremiumPayoutUSD * r.AnnualTimeInInvolvementFactor, 2), 0) AS CurrentYearMinus2PremiumPayoutUSD -- JM 20190911 -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor

		,TotalPremiumPayout = -- JM 20240916
			ISNULL(CurrentYearPremiumPayout, 0.00)
			+ ISNULL(ROUND(r.r_PreviousYearPremiumPayout * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- PreviousYearPremiumPayout
			+ ISNULL(ROUND(r.r_CurrentYearMinus2PremiumPayout  * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- CurrentYearMinus2PremiumPayout

		,TotalPremiumPayoutUSD = -- JM 20240916
			ISNULL(CurrentYearPremiumPayoutUSD, 0.00)
			+ ISNULL(ROUND(r.r_PreviousYearPremiumPayoutUSD * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- PreviousYearPremiumPayoutUSD
			+ ISNULL(ROUND(r.r_CurrentYearMinus2PremiumPayoutUSD * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- CurrentYearMinus2PremiumPayoutUSD

		--,NULLIF(ROUND(r.r_TotalPremiumPayout * r.AnnualTimeInInvolvementFactor, 2), 0) AS TotalPremiumPayout
		--,NULLIF(ROUND(r.r_TotalPremiumPayoutUSD * r.TimeInInvolvementFactor, 2), 0) AS TotalPremiumPayoutUSD

		,ISNULL(r.CurrentYearTotalAnnualPayout, 0.00) 
			+ ISNULL(CurrentYearPremiumPayout, 0.00) 
			+ ISNULL(ROUND(r.r_PreviousYearPremiumPayout * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor
			+ ISNULL(ROUND(r.r_CurrentYearMinus2PremiumPayout  * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor
		AS TotalPayoutAmount				

		,(ISNULL(r.CurrentYearTotalAnnualPayout, 0.00) 
			+ ISNULL(CurrentYearPremiumPayout, 0.00) 
			+ ISNULL(ROUND(r.r_PreviousYearPremiumPayout * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor 
			+ ISNULL(ROUND(r.r_CurrentYearMinus2PremiumPayout  * r.AnnualTimeInInvolvementFactor, 2), 0.00) -- JM 20230220 changed from TimeInInvolvementFactor to AnnualTimeInInvolvementFactor
		) * r.ExchangeRate AS TotalPayoutAmountUSD	    

		,cg.CompGroupName
		,emp.CostCenter AS CurrentCostCenterCode

		,idb.NonAnnualBonusPct * 100 AS DeferredBonusPct
		,idb.DeferredBonusTargetAmount
		,idb.DeferredBonusAmount * r.ic_score / 100.0  AS DeferredSubTotal -- JM 20210219 applied ic score
		,idb.DeferredBonusAmount AS DeferredSubTotalPreIC
		,kmv_status.input_value AS bonus_approval_involvement_status
		,kmv_reason.input_value AS bonus_approval_rejected_reason
		
		,@FiscalYear AS FiscalYear --YS 20220601
		,@FiscalYear - 1 AS FiscalYearMinus1 --YS 20220601
		,@FiscalYear - 2 AS FiscalYearMinus2 --YS 20220601

	INTO #rs
	FROM #ResultSet_Final AS r

	LEFT JOIN PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS et WITH (NOLOCK) -- JM 20190814
		ON et.GPID = r.GPID
		AND et.StartDateInvolvement = r.StartDateInvolvement  
	LEFT JOIN dbo.PEPSICO_Sector s   -- JM 20190814
		ON et.SectorCode_nk = s.SectorCode_nk  
	LEFT JOIN dbo.PEPSICO_Division d   -- JM 20190814 
		ON et.DivisionCode_nk = d.DivisionCode_nk  
	LEFT JOIN dbo.PEPSICO_Region reg   -- JM 20190814
		ON et.RegionCode_nk = reg.RegionCode_nk  
	LEFT JOIN dbo.PEPSICO_BusinessUnit bu   -- JM 20190814
		ON et.BusinessUnitCode_nk = bu.BusinessUnitCode_nk  
	LEFT JOIN dbo.PEPSICO_MarketUnit mu   -- JM 20190814
		ON et.MarketUnitCode_nk = mu.MarketUnitCode_nk  
	LEFT JOIN dbo.PEPSICO_WorkLocation wl   -- JM 20190814
		ON et.WorkLocationCode_nk = wl.WorkLocationCode_nk
	LEFT JOIN dbo.PEPSICO_JobFunction AS jf   -- TO 20230721
		ON et.JobFunctionCode_nk = jf.JobFunctionCode_nk 
	LEFT JOIN dbo.PEPSICO_LegalEntity AS le   -- JM 20190814 
		ON et.LegalEntityCode_nk = le.LegalEntityCode_nk
	LEFT JOIN dbo.PEPSICO_Country AS cn   -- JM 20190814 
		ON et.CountryCode_nk = cn.CountryCode_nk
	LEFT JOIN dbo.PEPSICO_SalaryPlan AS sp   -- JM 20190814
		ON et.SalaryPlanCode_nk = sp.SalaryPlanCode_nk
		  AND r.StartDateInvolvement <= sp.SalaryPlanEndDate
		  AND r.EndDateInvolvement >= sp.SalaryPlanStartDate  
	LEFT JOIN PEPSICO_CompGroupPayees AS cgp WITH (NOLOCK)  -- select * from PEPSICO_CompGroupPayees 
		ON cgp.GPID = r.GPID
		AND r.StartDateInvolvement BETWEEN cgp.StartDate AND cgp.EndDate
	LEFT JOIN PEPSICO_CompGroup AS cg
		ON cg.idCompGroup = cgp.idCompGroup
	LEFT JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp WITH (NOLOCK)  -- 20250110
		ON emp.GPID = r.GPID
		--AND GETDATE() BETWEEN emp.StartDate AND emp.EndDate
	LEFT JOIN #ind_def AS idb
		ON idb.GPID = r.GPID
		AND idb.StartDateInvolvement = r.StartDateInvolvement
	LEFT JOIN py_Payee AS py
		ON py.codePayee = r.GPID
	LEFT JOIN k_m_plans_payees_steps AS pps WITH (NOLOCK)
		ON pps.id_payee = py.idPayee
		AND pps.id_plan = (SELECT idPlanBonusApproval FROM vPEPSICO_Parameters) 
		AND pps.start_step = r.StartDateInvolvement
	LEFT JOIN k_m_values AS kmv_status WITH (NOLOCK)
		ON kmv_status.id_step = pps.id_step
		AND kmv_status.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status')
	LEFT JOIN k_m_values AS kmv_reason WITH (NOLOCK)
		ON kmv_reason.id_step = pps.id_step
		AND kmv_reason.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_reason')

 --where r.GPID in ('40180337')

	
	--ORDER BY  
	--	r.GPID,  
	--	r.StartDateInvolvement  

	drop table if exists #ResultSet_Final -- no longer used
	drop table if exists #ind_def -- no longer used

print 'Before indexes on rs. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')    

	CREATE CLUSTERED INDEX TempIdx_rs ON #rs(GPID, StartDateInvolvement)
	CREATE INDEX TempIdx_rs2 ON #rs(Current_idCompGroup)
	
print 'After indexes on rs. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')  

	IF @idProfile IN (select idProfileSuperUser from vPEPSICO_FocalPoint_Parameters UNION ALL select idProfileCompAdmin from vPEPSICO_FocalPoint_Parameters) -- comp admin or super user 

		SELECT rs.*
		FROM PEPSICO_CompGroupAssignment AS cga WITH (NOLOCK)  
		JOIN #rs AS rs
			ON rs.Current_idCompGroup = cga.idCompGroup	
		WHERE 
			cga.GPID = @codePayee_external_user
		AND cga.id_profile = @idProfile	
--and rs.gpid in ('80299892', '80313710')
		ORDER BY
			rs.GPID,
			rs.StartDateInvolvement

	ELSE

		SELECT *
		FROM #rs
--where gpid in ('80299892', '80313710')
		ORDER BY
			GPID,
			StartDateInvolvement

	drop table if exists #rs

print 'End. ' + FORMAT(GETDATE(), 'hh.mm.ss.fff')  

END
GO
