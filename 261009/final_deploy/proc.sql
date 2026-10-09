CREATE PROCEDURE [dbo].[Kernel_SP_Process_DataOnChange]
	@uidObject UNIQUEIDENTIFIER,
	@uidProfile UNIQUEIDENTIFIER,
	@uidUser UNIQUEIDENTIFIER,
	@idStep int,
	@idTree int,
	@idTreeSecurity int,
	@Values AS [dbo].[Kernel_Type_Process_Values] READONLY
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

-- created by James Mackay ?????? to update Process fields using RTC
-- modified by James Mackay 20210527 update ic_score range and merit_range when Performance Rating changes
-- modified by Yoann Schrago 20210607 added Merit_percent as a trigger
-- modified by Yoann Schrago 20210609 SYS2021-01 added promotion range
-- modified by Yoann Schrago 20210610 SYS2021-01 added equity range
-- modified by Yoann Schrago 20210614 SYS2021-01 added merit_amount, prom_percent, Prom_amount, equity_percent and equity_amount as triggers
-- modified by Yoann Schrago 20210615 SYS2021-01 modified to use values from k_m_values if no value found in [Kernel_Type_Process_Values]
-- modified by Yoann Schrago 20210616 SYS2021-01 added functions to refresh values
-- modified by Yoann Schrago 20210617 added dm_multiplier, stp, eligibility and CompaRatio refresh, added Promotion_type as Trigger
-- modified by Yoann Schrago 20210618 added Promotion_level, promotion_salaryPlan as triggers, refresh promotion drop down lists
-- modified by Yoann Schrago 20210621 changed functions to avoid code redundancy 
-- modified by Yoann Schrago 20210622 added compaRatio refresh into the process
-- modified by Yoann Schrago 20210629 Added rounding amounts and changed refresh functions
-- modified by Yoann Schrago 20210701 added egypt exception for @merit_percent
-- modified by Yoann Schrago 20210702 added deletion of promotion_cross_level if promotion_cross_type <> 'CROSS', 
									--added dm_manager_dm_increase as default value for dm_hr_dm_increase and delete dm_hr_dm_increase if NULL
-- modified by Yoann Schrago 20210708 fixed merit_percent when new value is NULL
-- modified by Yoann Schrago 20210709 use only values from [dbo].[Kernel_Type_Process_Values]
-- modified by Yoann Schrago 20210709 reset ic_score, ranges, increases and amounts if Performance Rating is set to NULL
-- modified by Yoann Schrago 20210712 avoid "edge" issue by rounding back the percentages to 2 decimals after the "Amount" rounding
-- modified by Yoann Schrgao 20210713 added @uidProfiles and profiles check before updating DM_Increases
-- modified by Yoann Schrgao 20210715 fix to trigger Widget Budget
-- modified by Yoann Schrago 20210723 Take compa ratios from k_m_values instead of EmpCompaRatio
-- modified by Yoann Schrago 20210723 Remove clearing of ic_score when Performance Rating is set to NULL
-- modified by Yoann Schrago 20210813 remove increases if Rating changes depending of the profile
-- modified by Yoann Schrago 20210817 added logic to clear Promotion_cross_Salary_Plan if promotion_type is null and fix Salary_Plan lookup
-- modified by Yoann Schrago 20210824 added FinalPayComponent refresh if final_lump_sum > 0, and refresh Compa_Ratio in this case and india check for xxx_amount values
-- modified by Yoann Schrago 20210826 fix Minimum_amount logic, added PEPSICO_FocalPoint_Minimum, clear promotion_cross_level if promotion_cross_type is NULL or 'IN'
-- modified by Yoann Schrago 20210826 changed Spend calculation to get merit_amount_prorated and the india exception
-- modified by Yoann Schrago 20210831 commented the refresh of lists fields when Promotion_type changes
-- modified by Yoann Schrago 20210902 #48705 fix to return a value in the #temp table even if they didn't change
-- modified by Yoann Schrago 20210908 #48104 ic_score cleared when Performance Rating changes
-- modified by Yoann Schrago 20210909 return in all cases ic_score, cleared or with the actual value. to avoid returning a NULL value to the PreSave
-- modified by Yoann Schrago 20211014 #50528 fix for Final Amount not showing if SalaryPlan is missing into PEPSICO_FocalPoint_LumpSum
-- modified by Yoann Schrago 20211025 fixed saving issue for Super user and Comp Admin
-- modified by Yoann Schrago 20211122 fix for RTC passing 0 for ic_score instead of NULL 
-- modified by James Mackay 20211201 changed vPEPSICO_SalaryPlan_All to PEPSICO_SalaryPlan_All
-- modified by Yoann Schrago 20211201 replace GPID by codepayee in JOIN
-- modified by Yoann Schrago 20211206 #52980 add default value for merit_percent AND Add IC Score as a TRIGGER to return itself
-- modified by Yoann Schrago 20211209 #52374 return only Performance Ratings if is_budget_exclude = 1
-- modified by Yoann Schrago 20211210 #53289 fix for LumpSum calculation JOIN on LegalEntity
-- modified by James Mackay 20220109 changed ic_score cast from INT to NUMERIC 
-- modified by Yoann Schrago 20221201 added WITH (NOLOCK) from k_m_values 
-- modified by James Mackay 20221205 #73981 changed to use PEPSICO_SalaryPlan_Exception
-- modified by Yoann Schrago 20230807 R/M2023-14 refresh final_proposal and final_proposal_rounded if equity_amount is entered
-- modified by James Mackay 20230827 R/M2023-15 added promotion_multiplier
-- modified by Yoann Schrago 20231019 R/M2023-07 india changes (pay Components)
-- modified by Yoann Schrago 20231208 #98549 set dm_hr_dm_increase with dm_manager_dm_increase
-- modified by James Mackay 20240106 #100112 fixed issues with increase amount calculations
-- modified by Yoann Schrago 20240627 Job Architecture poulate POC5 Job Title
-- modified by Yoann Schrago 20240712 Job Architecture lookup for POC5 JobTitle
-- modified by Yoann Schrago 20240806 Job Architecture lookup for POC5 JobTitle_2 and JobSubFamily_2
-- modified by Yoann Schrago 20240822 R/M2024-02 Remove Promotion and Equity Type when Performance Rating changes.
-- modified by Yoann Schrago 20240826 DM2024-03 remove dm_manager_dm_increase from MyTeams grid
-- modified by Yoann Schrago 20240827 DM2024-03 Add dm_amount
-- modified by Yoann Schrago 20240829 R/M2024-02 rollback changes
-- modified by Yoann Schrago 20240829_2 DM2024-02 cap equity range to the max of the salary range
-- modified by Yoann Schrago 20240829_3 DM2024-02 cap DM range to the max of the salary range
-- modified by Yoann Schrago 20240830 R/M2024-13 ZD113473 fix LumpSum calculation
-- modified by Yoann Schrago 20240918 DM2024-05 Change TARGETED to DIFFERENTIATED
-- modified by Yoann Schrago 20241003 R/M2024-08 add Promotion_Job_Code
-- modified by Kamil Roganowicz 20241017 R/M2024-19 ZD#116368 - rounding final_lump_sum
-- modified by Yoann Schrago 20241227 zd121084 adjust india increase amounts
-- modified by James Mackay 20250415 2025 Job Architecture changes
-- modified by James Mackay 20250612 moved check for Ratings process to the start of the ratings script -- IF @PlanId = @id_plan_focalpoint -- was doing lots of Ratings processing for Job Architecture
-- modified by Yoann Schrago 20250724 B2025-05 adding bonus process logic
-- modified by Yoann Schrago 20250818 B2025-05 adapt Bonus Process logic
-- modified by Yoann Schrago 20250826 new Final Bonus Team logic
-- modified by Kamil Roganowicz 20250916 ZD#138427 add logic for prt message 
-- modified by Yoann Schrago 20251020 R/M2025-05 add russian mandatory merit increase and modifiy LumpSum logic
-- modified by Yoann Schrago 20251113 R/M2025-13 Change in LumpSum calculation for EGY population
-- modified by Przemyslaw Kot 20251217 #ZD145010 Correct value assignment for @preassigned_bonus variable - should be BonusTeamNameProcess instead of BonusTeamName
-- modified by Przemyslaw Kot 20260211 #ZD148392 Take into consideration @finalSalaryPlanCode_nk and @LevelCodeFinal values while assigning value to @final_max_pay variable for Salaray Plan Codes stored in the PEPSICO_FocalPoint_Merit_Increase_forced table (Russia case)

--select * from k_profiles
--select * from k_users where login_user like '%yoann.schrago%'
--select * from hm_NodeTreePublished

----------------- TEST PARAMETERS 
---- select * from PEPSICO_Process_FocalPoint where gpid = '20620701'
----select * from PEPSICO_FocalPoint_EmpCurrentPayee where gpid = '20500320'
----select * from PEPSICO_Sector where SectorCode_nk = 'S03'
---- select * from py_payee where codePayee = '20500320' --idPayee 38552
---- select * from k_m_plans_payees_steps where id_payee = 285986 --id_step 1037110
---- STANDARD TEST: codepayee = '70178577'-- idPayee = 227488 id_step = 1042752
---- INDIAN TEST: codepayee = '20616772'-- idPayee = 179290 id_step = 1042169

------
--DECLARE @uidObject NVARCHAR(255) = '65509CA7-8A0E-49BB-BFB9-AA9A802FBA62', @uidProfile NVARCHAR(255) = '49D6E955-3E76-4105-93F4-7F0551D345F1', @uidUser NVARCHAR(255) = '7E70B506-C48E-4248-9F00-FC9EACC2ED10', @idTree int = 5, @idStep int = 3203396,  @idTreeSecurity int = 1111512 , @Values AS [dbo].[Kernel_Type_Process_Values]

--insert into @Values (idIndicator, idField, isTrigger, inputValue)
--select idIndicator, idField, isTrigger, inputValue from zz_temp_jm_Kernel_Type_Process_Values where insert_datetime = '2025-08-22 11:34:33.933'--equity_amount'2021-06-14 05:40:25.923'--equity_percent'2021-06-14 12:12:11.107'--promotion_amount'2021-06-15 12:54:15.873'--promotion_pct'2021-06-15 06:36:32.437'--merit_amount'2021-06-14 11:47:12.730'-- merit_pct'2021-06-15 12:54:01.967'


--insert into @Values (idIndicator, idField, isTrigger, inputValue)
--VALUES	
--	(21,137,0,'BonusTeamPreAssigned'),
--	(21,138,0,'NO'),
--	(21,139,0,'DATA'),
--	(21,140,0,'ENABLE'),
--	(21,141,1,'OU_MU'),
--	(21,142,0,'BTR001'),
--	(21,143,0,'BTOU001'),
--	(21,144,0,'BTOU004'),
--	(21,145,0,'BTOU003'),
--	(21,146,0,''),
--	(21,147,0,'OU')


----select * from @Values
--drop table if exists #tempTable
---------------END TEST PARAMETERS

	Declare 
		@TriggerAlias nvarchar(max) = '', 
		@TriggerValue nvarchar(max) = '',
		@PlanId int = 0,
		@calculatedValue int = 0;
	
	CREATE TABLE #tempTable  
	(  
		PrimaryKey   INT   NOT NULL ,  
		ObjectFieldAlias   VARCHAR(100),
		ObjectAttribute    VARCHAR(40),
		IsValid   BIT,
		InvalidReason   NVARCHAR(400),
		AllowEdit   BIT,
		NewValue   NVARCHAR(200),
	);  

-- for debugging 
INSERT INTO zz_temp_jm_Kernel_Type_Process_Values ([idIndicator], [idField], [isTrigger], [inputValue]) -- select top 1000 * from zz_temp_jm_Kernel_Type_Process_Values order by insert_datetime desc
SELECT [idIndicator], [idField], [isTrigger], [inputValue] FROM @Values

	-- PayComponent temp table for indian SalaryPLan
	DECLARE 
		@RTCPayComponent AS [PEPSICO_EmpPayComponentIncrease_param]

	--DECLARE @RTCPayComponent TABLE
	--(
	--	[FiscalYear] [int],
	--	[GPID] [nvarchar](50),
	--	[PayComponentCode_nk] [varchar](255),
	--	[MeritIncreaseTypeCode_nk] [varchar](50),
	--	[Amount] [numeric](18, 5),
	--	IncreasePercent [numeric](18, 5),
	--	[ProposedAmount] [numeric](18, 5)
	--)

	-- get some field details

	DECLARE 
		@idPayee INT,
		@codePayee NVARCHAR(50),
		@id_ind INT, 
		@id_field INT,
		@inputValue NVARCHAR(MAX),
		@id_plan_focalpoint INT,
		@FiscalYear INT = (SELECT FiscalYear from vPEPSICO_FocalPoint_Parameters),
		@id_ind_ci INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_comp_index'),	-- select * from k_m_indicators -- select * from k_m_fields
		@id_ind_ic_score INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'ic_score'),	
		@id_ind_merit INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_merit'),
		@id_ind_dm INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_differentiated_merit'),
		@id_ind_promotion INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_cross'),
		@id_ind_equity INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_equity'),
		@id_ind_minimum INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_minimum'),
		@id_ind_final INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_final'),
		@id_field_ci INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci'),		
		@id_field_ic_score INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score'),		
		@id_field_ic_score_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score_min'),		
		@id_field_ic_score_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score_max'),		
		@id_field_merit_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_range_min'),	
		@id_field_merit_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_range_max'),	
		@id_field_merit_percent int = (SELECT id_field from k_m_fields where code_field = 'merit_percent'),
		@id_field_merit_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_amount'),
		@id_field_merit_spend INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_spend'),
		@id_field_merit_spend_2 INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_spend_2'),
		@id_field_merit_proposal_prorated INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_proposal_prorated'),
		--@id_field_dm_manager_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_manager_dm_increase'), -- YS 20240826
		@id_field_dm_hr_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hr_dm_increase'),
		@id_field_dm_hr_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hr_proposal'),
		@id_field_dm_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_amount'), -- YS 20240827
		@id_field_dm_spend INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_spend'),
		@id_field_promotion_cross_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_range_min'),
		@id_field_promotion_cross_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_range_max'),
		@id_field_promotion_percent INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_percent'),
		@id_field_promotion_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_amount'),
		@id_field_promotion_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_proposal'),
		@id_field_promotion_cross_level INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_level'),
		@id_field_promotion_cross_salary_plan INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_salary_plan'),
		@id_field_promotion_cross_type INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_type'),
		@id_field_promotion_job_code INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_job_code'), -- YS 20241003
		@id_field_equity_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_range_min'),
		@id_field_equity_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_range_max'),
		@id_field_equity_percent INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_percent'),
		@id_field_equity_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_amount'),
		@id_field_equity_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_proposal'),
		@id_field_equity_type INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_type'), --YS 20240822
		@id_field_minimum_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'minimum_amount'),
		@id_field_minimum_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'minimum_proposal'),
		@id_field_final_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_proposal'),
		@id_field_final_proposal_rounded INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_proposal_rounded'),
		@id_field_final_lump_sum INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_lump_sum'),
		@uidProfileManager NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 2), --select * from k_profiles
		@uidProfileManagerLG8 NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 3),
		@uidProfileHR NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 4),
		@uidProfileHRLG8 NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 5),
		@uidProfileCompAdmin NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 6),
		@uidProfileSuperUser NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 7),
		@uidProfileAdmin NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = -1)

	SELECT
		@id_plan_focalpoint = idPlanFocalPoint
	FROM vPEPSICO_FocalPoint_Parameters -- select * from vPEPSICO_FocalPoint_Parameters

	DECLARE 
		@id_plan_job_architecture INT = (SELECT idPlanJobArchitecture FROM vPEPSICO_FocalPoint_Parameters), -- YS 20240627
		@id_ind_ja_poc5 int = (SELECT id_ind from k_m_indicators where comment_ind = 'ja_poc5'), --YS 20240627
		@id_field_ja_poc5_new_job_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_family'), --YS 20240627
		@id_field_ja_poc5_new_job_family_description int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_family_description'), --YS 20240627
		@id_field_ja_poc5_new_job_sub_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family'), --YS 20240627
		@id_field_ja_poc5_new_job_sub_family_description int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family_description'), --YS 20240627
		@id_field_ja_new_job_title int = (SELECT id_field from k_m_fields where code_field = 'ja_new_job_title'),
		--@id_field_ja_poc5_new_job_title_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title_2'), --YS 20240627
		@id_field_ja_poc5_new_job_title int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title') --YS 20240627
		--@id_field_ja_poc5_new_title int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_title'), --YS 20240627
		--@id_field_ja_poc5_new_job_sub_family_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family_2'), --YS 20240806
		--@id_field_ja_poc5_new_job_title_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title_2') --YS 20240806

	DECLARE 
		@id_plan_bonus INT = (SELECT idPlanBonusApproval FROM vPEPSICO_FocalPoint_Parameters), --YS 20250724
		@id_ind_bonus_team int = (SELECT id_ind from k_m_indicators where comment_ind = 'bonus_team'), --YS 20250724
		--@id_field_bonus_team_preassigned int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_preassigned'), --YS 20250724
		@id_field_bonus_team_assignment_correct int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_assignment_correct'), --YS 20250724
		--@id_field_bonus_team_correction_reason int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_correction_reason'), --YS 20250724
		--@id_field_bonus_team_enabling int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_enabling'), --YS 20250724
		@id_field_bonus_team_step_1 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_1'), --YS 20250724 
		@id_field_bonus_team_step_2 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_2'), --YS 20250724 
		@id_field_bonus_team_step_3 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_3'), --YS 20250724 
		--@id_field_bonus_team_step_35 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_35'), --YS 20250724
		--@id_field_bonus_team_step_4 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_4'), --YS 20250724
		--@id_field_bonus_team_step_5 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_5'), --YS 20250724
		@id_field_bonus_team_final int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_final'), --YS 20250724
		--@id_field_bonus_team_double_hatter int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_double_hatter'), --YS 20250818
		@id_field_bonus_team_comment int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_comment'), --YS 20250818
		@id_field_bonus_team_prt_message int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_prt_message') --YS 20250818

	-- get the plan

	SELECT @PlanId = id_plan 
	FROM k_m_plans 
	WHERE 
		uid_object = @uidObject;

	-- get the id payee and code payee

	SELECT 
		@idPayee = py.idPayee, --227488
		@codePayee = py.codePayee
	FROM k_m_plans_payees_steps AS pps
	JOIN py_Payee AS py
		ON py.idPayee = pps.id_payee
	WHERE 
		pps.id_step = @idStep
			   		 
	-- get the field that triggered the Stored Procedure

	SELECT TOP 1
		@id_ind = idIndicator,
		@id_field = idField,
		@inputValue = inputValue
	FROM @Values 
	WHERE 
		isTrigger = 1

	------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------- Ratings Process START-------------------------------------------------------
	IF @PlanId = @id_plan_focalpoint
	BEGIN

		----------------- is_budget_excluded Condition START -------------------- YS 20211209
		IF EXISTS (SELECT 1 FROM PEPSICO_Process_FocalPoint where codePayee = @codePayee AND is_budget_exclude = 0)
		BEGIN

			-- get all variables usefull for the calculations from @Values, vPEPSICO_Process_FocalPoint_Values_Pivoted or PEPSICO_FocalPoint_EmpCompaRatio
			DECLARE
				@ci							INT,
				@ic_score					INT,
				@merit_percent				NUMERIC(18,5),
				@merit_amount				NUMERIC(18,5),
				@merit_amount_prorated		NUMERIC(18,5),
				@merit_proposal_prorated	NUMERIC(18,5),
				@dm_hr_dm_increase			NUMERIC(18,5),
				--@dm_manager_dm_increase		NUMERIC(18,5), -- YS 20240826
				@dm_hr_proposal				NUMERIC(18,5),
				@dm_amount					NUMERIC(18,5), -- YS 20240827
				@promotion_cross_percent	NUMERIC(18,5),
				@promotion_cross_percent_multiplier NUMERIC(18,5),
				@promotion_cross_amount		NUMERIC(18,5),
				@promotion_cross_proposal	NUMERIC(18,5),
				@promotion_cross_type		VARCHAR(256),
				@promotion_job_code			VARCHAR(256), -- YS 20241003
				@equity_percent				NUMERIC(18,5),
				@equity_amount				NUMERIC(18,5),
				@equity_proposal			NUMERIC(18,5),
				@equity_type				VARCHAR(256), -- YS 20240822
				@minimum_amount				NUMERIC(18,5),
				@minimum_proposal			NUMERIC(18,5),
				@final_lump_sum				NUMERIC(18,5),
				@final_proposal				NUMERIC(18,5),
				@final_proposal_rounded		NUMERIC(18,5),
				@final_increase_rounded		NUMERIC(18,5),
				@cr_merit					NUMERIC(18,5),
				@cr_targeted				NUMERIC(18,5),
				@cr_promotion				NUMERIC(18,5),
				@cr_equity					NUMERIC(18,5),
				@cr_minimum					NUMERIC(18,5),
				@cr_lump					NUMERIC(18,5),
				@cr_final					NUMERIC(18,5),
				@LevelCodeFinal				VARCHAR(256),
				@SalaryPlanCode_nk			VARCHAR(256),
				@finalSalaryPlanCode_nk		VARCHAR(256),
				@min_pay					NUMERIC(18,0),
				@mid_point_pay				NUMERIC(18,0),
				@max_pay					NUMERIC(18,0),
				@final_min_pay				NUMERIC(18,0),
				@final_mid_point_pay		NUMERIC(18,0),
				@final_max_pay				NUMERIC(18,0)
		
		
			SELECT
				@ci =						TRY_CAST(p_kmv.ci AS INT),-- NUMERIC(18,5)), 
				@ic_score =					TRY_CAST(p_kmv.ic_score AS NUMERIC), -- JM 20220109 changed from INT to NUMERIC 
				@merit_percent =			TRY_CAST(p_kmv.merit_percent AS NUMERIC(18,5)), 
				@merit_amount =				TRY_CAST(p_kmv.merit_amount AS NUMERIC(18,5)),
				@merit_amount_prorated =	TRY_CAST(p_kmv.merit_amount_prorated AS NUMERIC(18,5)),
				--@dm_manager_dm_increase =	ISNULL(TRY_CAST(kmv_dm_hr.input_value_numeric AS NUMERIC(18,5)),TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5))), --COALESCE(TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5)), piv.dm_manager_dm_increase, 0.0), -- YS 20240826
				@dm_hr_dm_increase =		TRY_CAST(p_kmv.dm_hr_dm_increase AS NUMERIC(18,5)), --COALESCE(TRY_CAST(p_kmv.dm_hr_dm_increase AS NUMERIC(18,5)), TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5))),
				@dm_amount =				TRY_CAST(p_kmv.dm_amount AS NUMERIC(18,5)), -- YS 20240827
				@promotion_cross_percent =	TRY_CAST(p_kmv.promotion_cross_percent AS NUMERIC(18,5)),
				@promotion_cross_percent_multiplier = ((1.0 + TRY_CAST(p_kmv.promotion_cross_percent AS NUMERIC(18,5)) / 100.0) * pfp.promotion_multiplier - 1.0) * 100.0,				
				@promotion_cross_amount =	TRY_CAST(p_kmv.promotion_cross_amount AS NUMERIC(18,5)), 
				@promotion_cross_type =		NULLIF(p_kmv.promotion_cross_type,''),
				@promotion_job_code =		NULLIF(p_kmv.promotion_job_code,''), -- YS 20241003
				@equity_percent =			TRY_CAST(p_kmv.equity_percent AS NUMERIC(18,5)),
				@equity_amount =			TRY_CAST(p_kmv.equity_amount AS NUMERIC(18,5)),
				@equity_type =				NULLIF(p_kmv.equity_type,''), -- YS 20240822
				@minimum_amount =			TRY_CAST(p_kmv.minimum_amount AS NUMERIC(18,5)),
				@final_lump_sum =			TRY_CAST(p_kmv.final_lump_sum AS NUMERIC(18,5)), 
				@cr_merit =					cr_merit.CompaRatio,
				@cr_targeted =				TRY_CAST(p_kmv.merit_dm_compa_ratio AS NUMERIC(18,5)) ,				 
				@cr_promotion =				TRY_CAST(p_kmv.dm_promotion_compa_ratio AS NUMERIC(18,5)) ,			 
				@cr_equity =				TRY_CAST(p_kmv.promotion_cross_equity_compa_ratio AS NUMERIC(18,5)),  
				@cr_minimum =				TRY_CAST(p_kmv.equity_minimum_compa_ratio AS NUMERIC(18,5)) ,		 
				@cr_lump =					TRY_CAST(p_kmv.minimum_lump_compa_ratio AS NUMERIC(18,5)) ,			 
				@cr_final =					TRY_CAST(p_kmv.final_compa_ratio AS NUMERIC(18,5)) ,				 
				@LevelCodeFinal =			COALESCE(NULLIF(p_kmv.promotion_cross_level,''), pfp.LevelCodeFinal, pfp.LevelCode),
				@SalaryPlanCode_nk =		pfp.SalaryPlanCode_nk,
				@finalSalaryPlanCode_nk	=	COALESCE(NULLIF(p_kmv.promotion_cross_salary_plan,''), pfp.SalaryPlanCode_nk),
				@min_pay =					pr.MinPay,
				@mid_point_pay =			pr.MidPointPay,
				@max_pay =					pr.MaxPay,
				@final_min_pay =			fpr.MinPay,
				@final_mid_point_pay =		fpr.MidPointPay,
				@final_max_pay =			fpr.MaxPay
			FROM  vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv
			JOIN PEPSICO_Process_FocalPoint AS pfp 
				ON pfp.idPayee = piv.id_payee
			LEFT JOIN k_m_values AS kmv_dm_hr WITH (NOLOCK) -- YS 20221201
				ON kmv_dm_hr.id_step = piv.id_step
				AND id_field = @id_field_dm_hr_dm_increase
			LEFT JOIN 
			(
				SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
				FROM @Values AS kmv
				JOIN k_m_fields as kmf on kmf.id_field = kmv.idField
				WHERE kmf.code_field  IN (
					'ci', 'ic_score',
					'merit_percent', 'merit_amount', 'merit_amount_prorated', 'merit_proposal_prorated', /*dm_manager_dm_increase',*/ 'dm_hr_dm_increase', 'dm_hr_proposal', 'dm_amount',  -- YS 20240826 -- YS 20240827
					'promotion_cross_percent', 'promotion_cross_amount', 'promotion_cross_proposal', 'promotion_cross_level', 'promotion_cross_type', 'promotion_cross_salary_plan', 'promotion_job_code', -- YS 20241003
					'equity_percent', 'equity_amount', 'equity_proposal','equity_type', 'minimum_amount', 'minimum_proposal', 'final_proposal', 'final_lump_sum',
					'merit_dm_compa_ratio', 'dm_promotion_compa_ratio', 'promotion_cross_equity_compa_ratio', 'equity_minimum_compa_ratio', 'minimum_lump_compa_ratio', 'final_compa_ratio')
			) AS s
			PIVOT
			(
				MAX(inputValue)
				FOR s.code_field  IN (
					ci, ic_score,
					merit_percent, merit_amount, merit_amount_prorated, merit_proposal_prorated, /*dm_manager_dm_increase,*/ dm_hr_dm_increase, dm_hr_proposal, dm_amount,  -- YS 20240826 -- YS 20240827
					promotion_cross_percent, promotion_cross_amount, promotion_cross_proposal, promotion_cross_level, promotion_cross_type, promotion_cross_salary_plan, promotion_job_code, -- YS 20241003
					equity_percent, equity_amount, equity_proposal, equity_type, minimum_amount, minimum_proposal, final_proposal, final_lump_sum,
					merit_dm_compa_ratio, dm_promotion_compa_ratio, promotion_cross_equity_compa_ratio, equity_minimum_compa_ratio, minimum_lump_compa_ratio, final_compa_ratio)
			) AS p_kmv ON p_kmv.idStep = piv.id_step
			LEFT JOIN PEPSICO_FocalPoint_EmpCompaRatio AS cr_merit
				ON cr_merit.GPID = @codePayee AND cr_merit.MeritIncreaseTypeCode_nk = 'MERIT'
			LEFT JOIN PEPSICO_SalaryPlan_All AS sp
				ON sp.SalaryPlanCode_nk = ISNULL(NULLIF(p_kmv.promotion_cross_salary_plan, ''), pfp.SalaryPlanCode_nk) 
			LEFT JOIN PEPSICO_FocalPoint_PayRange AS fpr 
				ON fpr.SalaryPlanCode_nk = ISNULL(NULLIF(p_kmv.promotion_cross_salary_plan, ''), pfp.SalaryPlanCode_nk)
				AND fpr.LevelCode = COALESCE(NULLIF(p_kmv.promotion_cross_level,''), pfp.LevelCodeFinal, pfp.LevelCode)
				AND sp.PayRange_Date_Lookup BETWEEN fpr.PayRangeStartDate AND fpr.PayRangeEndDate
			LEFT JOIN PEPSICO_FocalPoint_PayRange AS pr 
				ON pr.SalaryPlanCode_nk = pfp.SalaryPlanCode_nk
				AND pr.LevelCode = pfp.LevelCode
				AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate
			WHERE piv.id_step = @idStep

	/* -- YS 20240826
			IF @id_field = @id_field_dm_manager_dm_increase
				SELECT @dm_hr_dm_increase = @dm_manager_dm_increase

			IF @dm_hr_dm_increase is null and @dm_manager_dm_increase is not null -- YS 20231208 
				SELECT @dm_hr_dm_increase = @dm_manager_dm_increase
	 -- YS 20240826 
	 */

		--select @ci, @merit_percent, @merit_amount, @merit_amount_prorated, @merit_proposal_prorated, @dm_manager_dm_increase, @dm_hr_dm_increase, @dm_hr_proposal, @dm_amount, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type, @equity_percent, @equity_amount, @equity_proposal, @minimum_amount, @final_lump_sum, @final_proposal_rounded AS finalRounded, @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final, @LevelCodeFinal, @finalSalaryPlanCode_nk, @min_pay, @mid_point_pay, @max_pay, @final_min_pay, @final_mid_point_pay, @final_max_pay				
	--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal
			-------------------------- CLEAR Percentages and Amounts if Performance Ratings is set to NULL

			--IF @id_field = @id_field_ci AND @inputValue = '' --YS 20210813
			IF @id_field = @id_field_ci
			BEGIN
				IF @uidProfile IN (@uidProfileManager, @uidProfileManagerLG8)
				BEGIN
					SELECT
						@ic_score = NULL,
						@merit_percent = NULL,
						@merit_amount = NULL,
	--					@dm_manager_dm_increase = NULL -- YS 20240826
						@dm_hr_dm_increase = NULL, -- YS 20240829
						@dm_amount = NULL -- YS 20240829
						--@dm_hr_dm_increase = NULL,
						--@promotion_cross_percent = NULL,
						--@promotion_cross_amount = NULL,
						--@equity_percent = NULL,
						--@equity_amount = NULL

					print'reset percentages for Managers'
				END
				ELSE 
				BEGIN
					SELECT
						@ic_score = NULL,
						@merit_percent = NULL,
						@merit_amount = NULL,
	--					@dm_manager_dm_increase = NULL, -- YS 20240826
						@dm_hr_dm_increase = NULL,
						@dm_amount = NULL, -- YS 20240827
						@promotion_cross_percent = NULL,
						@promotion_cross_amount = NULL,
						--@promotion_cross_type = NULL, --YS 20240822 -- YS 20240829
						@equity_percent = NULL,
						@equity_amount = NULL
						--@equity_type = NULL --YS 20240822 -- YS 20240829

					print'reset percentages for Admin'
				END

				-- Insert Merit_percent default value --YS 20211206
				IF @inputValue <> ''
				BEGIN
					SELECT 
						@merit_percent = ir.MeritPercent
					FROM vPEPSICO_Parameters AS par
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp 
						ON emp.idPayee = @idPayee
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON pfp.idPayee = @idPayee
						AND pfp.is_eligible = 1
						AND pfp.is_merit_eligible = 1
					LEFT JOIN PEPSICO_FocalPoint_MeritIncreaseRange AS ir 
						ON	ir.SalaryPlanCode_nk = emp.SalaryPlanCode_nk
						AND ir.CompensationIndex = @ci
						AND @cr_merit BETWEEN ISNULL(ir.CompaRatioMin, 0) AND ISNULL(ir.CompaRatioMax, 99999999)
						AND emp.LevelCode = ISNULL(ir.LevelCode, emp.LevelCode)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
					WHERE @merit_percent IS NULL
				END
			END
			ELSE

			-------------------------- PROMOTION LEVEL UPDATE
			--delete the promotion_cross_level if the promotion_cross_type <> 'CROSS'
			IF @promotion_cross_type = 'IN'
				SELECT @LevelCodeFinal = pfp.LevelCode
				FROM PEPSICO_Process_FocalPoint AS pfp
				WHERE pfp.idPayee = @idPayee
			-------------------------- PROMOTION SALARY PLAN UPDATE
			--delete the promotion_cross_level if the promotion_cross_type = ''
			IF @promotion_cross_type IS NULL
				SELECT @finalSalaryPlanCode_nk = pfp.SalaryPlanCode_nk,
				@LevelCodeFinal = pfp.LevelCode, --YS 20210826
				@final_min_pay = @min_pay,
				@final_mid_point_pay = @mid_point_pay,
				@final_max_pay = @max_pay
				FROM PEPSICO_Process_FocalPoint AS pfp
				WHERE pfp.idPayee = @idPayee


			-------------------------- R/M2025-05 Russia Mandatory Merit Increase -- YS 20251020
			IF @SalaryPlanCode_nk IN (SELECT SalaryplanCode_nk FROM PEPSICO_FocalPoint_Merit_Increase_forced)
			BEGIN
				SELECT 
					@final_max_pay = CASE WHEN emp.AnnualAmount * (100.0+mif.Merit_percent)/100.0 > pr.MaxPay
						THEN emp.AnnualAmount * (100.0+mif.Merit_percent)/100.0
						ELSE pr.MaxPay
					END ,
					@merit_percent = CASE WHEN ISNULL(@ci,0) <> 0 
						THEN CASE WHEN ISNULL(@merit_percent,0) > mif.Merit_percent
							THEN @merit_percent
							ELSE mif.merit_percent
						END
						ELSE NULL
					END 
				from py_payee as py -- use #py
				join PEPSICO_FocalPoint_EmpCurrentPayee AS emp
					on emp.idPayee = py.idPayee
				join PEPSICO_FocalPoint_Merit_Increase_forced as mif
					--on mif.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					on mif.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
				JOIN vPEPSICO_SalaryPlan_All AS sp
					--ON sp.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					ON sp.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
				LEFT JOIN PEPSICO_FocalPoint_PayRange AS pr
					--ON pr.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					ON pr.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
					--AND pr.LevelCode = emp.LevelCode					--PK 20260211 #ZD148392
					AND pr.LevelCode = @LevelCodeFinal					--PK 20260211 #ZD148392
					AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate 
				where emp.GPID = @codePayee
			END
			

			-------------------------INDIAN PAY COMPONENT CALCULATION
			INSERT INTO @RTCPayComponent(FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, IncreasePercent, ProposedAmount)
			SELECT FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, IncreasePercent, ProposedAmount
			FROM _ufn_rtc_pay_components_refresh (@idPayee, @PlanId, @merit_percent, @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @SalaryPlanCode_nk)

		--select * from @RTCPayComponent 

			-- If the Employee is INDIAN, RECALCULATE @merit_amount,@dm_hr_proposal, @promotion_amount and @equity_amount
			IF EXISTS (SELECT 1 FROM @RTCPayComponent)
			BEGIN

				--@merit_amount
				; WITH cte_merit AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'MERIT'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004') 
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227
				)

				SELECT 
					@merit_amount = ROUND((inc.ProposedAmount - inc.Amount) / NULLIF(pfp.merit_proration, 0), 4)
				FROM PEPSICO_Process_FocalPoint AS pfp
				JOIN cte_merit AS inc
					ON 1=1 
				WHERE 
					pfp.idPayee = @idPayee

				--@@dm_hr_proposal
				--@dm_amount -- YS 20240827
				;WITH cte_dm AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						--MeritIncreaseTypeCode_nk = 'TARGETED'
						MeritIncreaseTypeCode_nk = 'DIFFERENTIATED'-- YS 20240918
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004')
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227 
				)

				SELECT
					--@dm_hr_proposal = ROUND(@merit_proposal_prorated + inc.ProposedAmount - inc.Amount, 4)
					@dm_amount =  ROUND((inc.ProposedAmount - inc.Amount), 4), -- YS 20240827
					@dm_hr_proposal = ROUND(inc.ProposedAmount, 4)
				FROM cte_dm AS inc

				--@promotion_amount
				;WITH cte_promotion AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'PROMOTION'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					-- AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004')
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227 
				)

				SELECT
					@promotion_cross_amount = ROUND((inc.ProposedAmount - inc.Amount), 4)
				FROM cte_promotion AS inc

				--@equity_amount
				;WITH cte_equity AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'EQUITY'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004') 
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227
				)
				SELECT
					@equity_amount = ROUND((inc.ProposedAmount - inc.Amount), 4)
				FROM cte_equity AS inc

			END
			----------------------- EGYPT EXCEPTION FOR @merit_percent
			IF EXISTS 
			(
				SELECT TOP 1 * 
				FROM PEPSICO_Process_FocalPoint AS pfp 
				JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS gov 
					ON gov.FiscalYear = @FiscalYear AND gov.GPID = pfp.codePayee
				WHERE pfp.idPayee = @idPayee
			)
				SELECT @merit_percent = 
						CASE WHEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) > ISNULL(@merit_percent, 0.0000) --YS 20210708
							THEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) 
							ELSE @merit_percent
						END
		
				FROM vPEPSICO_FocalPoint_Parameters AS par 
				JOIN k_m_plans_payees_steps AS pps 
					ON pps.id_plan = par.idPlanFocalPoint
				JOIN PEPSICO_Process_FocalPoint AS pfp
					ON pfp.idPayee = pps.id_payee
					AND pfp.is_eligible = 1 --YS 20210506
				JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS gov -- select * from PEPSICO_FocalPoint_EmpGovernmentIncrease
					ON gov.FiscalYear = par.FiscalYear -- select fiscalyear from vPEPSICO_FocalPoint_Parameters
					AND gov.GPID = pfp.codePayee
				JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val
					ON val.id_step = pps.id_step
				JOIN k_m_values AS kmv WITH (NOLOCK)-- YS 20221201
					ON kmv.id_step = pps.id_step
				JOIN k_m_fields AS kmf
					ON kmf.id_field = kmv.id_field AND kmf.code_field = 'merit_percent' 
				WHERE
					@merit_percent <> 
						CASE WHEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) > ISNULL(@merit_percent, 0.0000) --YS 20210708
							THEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) 
							ELSE @merit_percent
						END
					AND pfp.idPayee = @idPayee

			----------------------- EGYPT EXCEPTION FOR @merit_percent END

			-- Calculation of proposals based on increases. They are used to define increase percentages when an Amount is entered
			SELECT
				@merit_proposal_prorated = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) --LIKE 'SP-IND%' 
						THEN pfp.base_salary + ISNULL(@merit_amount,0.0) * pfp.merit_proration 
						ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee--YS 20210708
	

			SELECT 
				@dm_hr_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @dm_hr_proposal
						ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee--YS 20210708

			SELECT	
				@promotion_cross_proposal =	
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @dm_hr_proposal + @promotion_cross_amount
						-- JM 20230827 promotion multiplier 
						--ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000)
						ELSE pfp.base_salary * 
								(1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
								* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
								* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee


			-- YS 20230807 recalculate Equity_percent and Equity_Amount
			-- IF @equity_percent IS ENTERED
			IF @id_field = @id_field_equity_percent AND  @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 Added india check
			BEGIN

				-- work out @equity_amount Rounded 
				SELECT
					-- JM 20230827 promotion multiplier 
					--@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					@equity_amount = ROUND(pfp.base_salary 
											* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
											* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
											* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
											* @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
				FROM PEPSICO_Process_FocalPoint AS pfp
				LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
					ON rnd.GPID = pfp.gpid
					AND rnd.RoundIncreasesFlag = 1
				WHERE pfp.idPayee = @idPayee

				--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @equity_percent IS NOT NULL --YS 20210708 --YS20210824 COMMENTED
					-- ADJUST @equity_percent ROUNDED
				SELECT
					@equity_percent = @equity_amount / NULLIF(@promotion_cross_proposal,0) * 100.0000

			END
			-- IF @equity_amount IS ENTERED
			IF @id_field = @id_field_equity_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
			BEGIN

				--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
				-- work out Equity Percent and do the same logic as above
				SELECT
					@equity_percent = ROUND( ROUND(@equity_amount, ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@promotion_cross_proposal, 0.0) * 100.0000, 2) --YS 20210712 	
					--/*potentially needed*/,@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
			
				FROM PEPSICO_Process_FocalPoint AS pfp
				LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
					ON rnd.GPID = pfp.gpid
					AND rnd.RoundIncreasesFlag = 1
				WHERE pfp.idPayee = @idPayee
			END

			SELECT	
				@equity_proposal =
				CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN  @promotion_cross_proposal + @equity_amount
						-- JM 20230827 promotion multiplier 
						--ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
						ELSE	pfp.base_salary 
								* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
								* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
								* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
								* (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
				END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee


			----------------------------------- Refresh Minimum_amount
				--minimum_amount
			;WITH cte_min
			AS(
				SELECT
				adj_ovr.id as id_ovr,
				ir.id AS id_min,
				pfp.idpayee,
					CASE WHEN adj_ovr.GPID IS NOT NULL --YS 20201030
						THEN
							--Override part
							CASE WHEN adj_ovr.Yes_No = 'YES'
								THEN
								CASE WHEN @equity_proposal * pfp.merit_annualised_factor < @final_min_pay 
									THEN @final_min_pay / NULLIF(pfp.merit_annualised_factor, 0) - @equity_proposal 
									ELSE 0 
								END 
								ELSE 0 
							END
						--Normal calculation
						ELSE
							CASE WHEN @equity_proposal * pfp.merit_annualised_factor < @final_min_pay 
								THEN @final_min_pay / NULLIF(pfp.merit_annualised_factor, 0) - @equity_proposal
								ELSE 0  
							END
					END
					AS MinimumAmount
				FROM PEPSICO_Process_FocalPoint AS pfp
				JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
					ON emp.idPayee = pfp.idPayee
				LEFT JOIN PEPSICO_FocalPoint_Minimum AS ir -- YS 20210826
					ON	ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					AND ISNULL(@ci, 10) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
					AND @cr_minimum BETWEEN ISNULL(ir.CompaRatioMin, 0) AND ISNULL(ir.CompaRatioMax, 99999999)
					AND @LevelCodeFinal = ISNULL(ir.LevelCode, @LevelCodeFinal)
					AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
					AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
					AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
					AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
					AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
					AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
					AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
				LEFT JOIN PEPSICO_FocalPoint_AdjustmentToMinimum_GPID AS adj_ovr
					ON adj_ovr.GPID = pfp.gpid
				WHERE pfp.idPayee = @idPayee
				--AND (ir.id IS NOT NULL OR adj_ovr.id IS NOT NULL)

			)
			SELECT
				 @minimum_amount = 
					 CASE WHEN (cte.id_min IS NOT NULL OR cte.id_ovr IS NOT NULL) 
						THEN cte.MinimumAmount
						ELSE 0.00
					END
			FROM cte_min AS cte

			-- Calculate @minimum_proposal
			SELECT 
				@minimum_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @minimum_amount
						+ @equity_proposal
						ELSE	@minimum_amount
						-- JM 20230827 promotion multiplier 
						--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
						--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
						+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
						+ pfp.base_salary 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee
	

			------------------------------------ Refresh Lump Sum Amount

			SELECT
				@final_lump_sum =
					CASE WHEN lump_ovr.GPID IS NOT NULL 
						THEN
							--Override part
							CASE WHEN lump_ovr.Yes_No = 'YES'
								THEN
								CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
									THEN 
									CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
											--OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
											OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) ) -- YS 20251113
										--THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase 
										THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- YS 20251113                 
										ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
									ELSE 0 
								END 
								ELSE 0
							END
						--Normal calculation
						ELSE 
							CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
								THEN 
									CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
											--OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
											OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) ) -- YS 20251113
										--THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase  
										THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- YS 20251113                  
										ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
								END
								ELSE 0 
							END 
					END
				--AS LumpSumAmount

			FROM vPEPSICO_FocalPoint_Parameters AS par
			JOIN PEPSICO_Process_FocalPoint AS pfp 
				ON 1 = 1
			JOIN py_Payee AS py 
				ON py.idPayee = pfp.idPayee
			JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
				ON emp.idPayee = pfp.idPayee
			JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
				ON kmv.idpayee = pfp.idPayee
			JOIN PEPSICO_SalaryPlan_All AS sp
				ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
			--JOIN PEPSICO_FocalPoint_EmpCompaRatio AS ecr 
			--	ON ecr.GPID = pfp.codePayee 
			--	AND ecr.MeritIncreaseTypeCode_nk = 'LUMP'
			LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
				ON	
				--ir.SalaryPlanCode_nk = ISNULL(kmv.promotion_cross_salary_plan, pfp.SalaryPlanCode_nk)
				ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
				AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
				AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
				AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
				AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
				AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
				AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
				AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
				AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
				AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
				AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
				AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
				AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
			LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
				ON lump_ovr.GPID = pfp.gpid 
			LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
				ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
			LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
				ON egi.gpid = py.codePayee 
				AND egi.FiscalYear = par.FiscalYear 
			LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
				ON er.FiscalYear = par.FiscalYear 
				AND er.gpid = pfp.codePayee
			WHERE 
				(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
				AND py.idPayee = @idPayee


			IF @final_lump_sum IS NULL	-- YS 20211014
				SELECT @final_lump_sum = 0.000

			------------------------------------ Refresh Lump Sum Amount END
		--select @final_lump_sum
			------------------------------------ Set @final_proposal and @final_proposal_rounded
			SELECT 
				@final_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
						ELSE
							@minimum_amount 
							-- JM 20230827 promotion multiplier 
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
							+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
							- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
						END,
				@final_proposal_rounded=
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
						ELSE ROUND(@minimum_amount 
							-- JM 20230827 promotion multiplier 
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
							+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
							- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
							, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
						END
			FROM PEPSICO_Process_FocalPoint AS pfp 
			JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
			LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
			WHERE pfp.idPayee = @idPayee

			SELECT
				@final_increase_rounded = (@final_proposal_rounded / pfp.base_salary - 1.00000) * 100.00000
			FROM PEPSICO_Process_FocalPoint AS pfp 
			--WHERE pfp.gpid = @codePayee --YS 20211201
			WHERE pfp.codePayee = @codePayee

			--Recalculate Final Pay Component if Lump Sum is not null
			IF @final_lump_sum > 0 
			BEGIN
				UPDATE pc
				SET
					pc.Amount = pcf.Amount,
					pc.IncreasePercent = pcf.IncreasePercent,
					pc.ProposedAmount = pcf.ProposedAmount
				FROM @RTCPayComponent AS pc
				JOIN _ufn_rtc_pay_components_final_refresh (@RTCPayComponent, @final_increase_rounded, @final_max_pay) AS pcf
					ON pcf.MeritIncreaseTypeCode_nk = pc.MeritIncreaseTypeCode_nk
					AND pcf.PayComponentCode_nk = pc.PayComponentCode_nk
				WHERE pc.MeritIncreaseTypeCode_nk = 'FINAL'

			END

			-- Refresh Compa Ratios 
			SELECT 
				@cr_merit = cr_merit,
				@cr_targeted = cr_targeted,
				@cr_promotion = cr_promotion,
				@cr_equity	= cr_equity,
				@cr_minimum	= cr_minimum,
				@cr_lump = cr_lump,
				@cr_final = cr_final
			--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
			FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr


	--select @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final, @final_lump_sum as lumpsum, @final_proposal, @final_proposal_rounded as final_Prop_Round, @min_pay as min_pay, @mid_point_pay, @max_pay, @final_min_pay as finalminpay, @final_mid_point_pay, @final_max_pay
	--select @ci,@merit_percent	,@merit_amount	,@merit_amount_prorated,@merit_proposal_prorated,@dm_hr_dm_increase,@dm_hr_proposal,@promotion_cross_percent,@promotion_cross_amount,@promotion_cross_proposal,@promotion_cross_type,@equity_percent,@equity_amount	,@equity_proposal,@minimum_amount,@final_lump_sum,@final_proposal_rounded, @cr_merit,@cr_targeted,@cr_promotion,@cr_equity,@cr_minimum,@cr_lump,@cr_final,@LevelCodeFinal,@finalSalaryPlanCode_nk,@min_pay,@mid_point_pay,@max_pay,@final_min_pay,@final_mid_point_pay,@final_max_pay				
--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal	
	

			----------------------------------------------- Performance Ratings Field START -------------------------------------------------

			IF @id_field = @id_field_ci
			BEGIN
				-- Refresh ic score range based on Performance Rating and Merit Compa_ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_icscore_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_merit)

				-- Refresh merit range based on Performance Rating and Merit Compa_ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_range_refresh(@PlanId, @idStep, @idPayee, @ci,  @cr_merit)

				-- Refresh promotion range based on Performance Rating, Promotion_Type, Promotion_CompaRatio, LevelCodeFinal, SalaryPlanCodeFinal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_range_refresh(@PlanId, @idStep, @idPayee, @ci, @promotion_cross_type, @cr_promotion, @LevelCodeFinal, @finalSalaryPlanCode_nk)
			
				-- Refresh equity range based on Performance Rating, Equity CompaRatio, LevelCodeFinal, SalaryPlanCodeFinal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2


--insert into zz_jm_temp_rtc_dm (PlanId, idStep, idPayee, ci, cr_targeted, FinalSalaryPlanCode_nk, LevelCodeFinal, merit_percent, mid_point_pay, uidProfile, max_pay)
--select
--	@PlanId,
--	@idStep,
--	@idPayee,
--	@ci,
--	@cr_targeted ,
--	@FinalSalaryPlanCode_nk ,
--	@LevelCodeFinal ,
--	@merit_percent ,
--	@mid_point_pay ,
--	@uidProfile ,
--	@max_pay 

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3


				-- Refresh IC Score, Merit, DM, Promotion, Equity, Minimum, Lump Sum and Final
				--IF @inputValue = '' --YS 20210813 commented
				--BEGIN

				---- Clear ic score"--YS 20210908
				--INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				--SELECT 
				--	@idStep AS PrimaryKey, 
				--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30))) AS ObjectFieldAlias,
				--	'' AS ObjectAttribute,
				--	1 AS IsValid,
				--	'' AS InvalidReason,
				--	1 AS AllowEdit,
				--	NULL AS NewValue

				-- Refresh merit_amount, merit_proposal_prorated
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount, @merit_proposal_prorated)

/* -- YS 20240826
				IF @uidProfile IN (@uidProfileManager, @uidProfileManagerLG8, @uidProfileAdmin) --YS 20210713
					--Refresh dm_manager_dm_increase
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_dm AS NVARCHAR(30)), '_', CAST(@id_field_dm_manager_dm_increase AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,			
						CAST(@dm_manager_dm_increase AS NVARCHAR) AS NewValue
-- YS 20240826
*/
/* YS 20240827 Now done in _ufn_rtc_dm_fields_refresh with @dm_amount and @dm_hr_proposal

				IF @uidProfile IN (@uidProfileHR, @uidProfileHRLG8, @uidProfileCompAdmin, @uidProfileSuperUser, @uidProfileAdmin) --YS 20210713
					-- Refresh dm_hr_dm_increase
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_dm AS NVARCHAR(30)), '_', CAST(@id_field_dm_hr_dm_increase AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,			
						CAST(@dm_hr_dm_increase AS NVARCHAR) AS NewValue
*/
				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_percent, promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee, @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
				
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			
				--END--YS 20210813 commented


			END
			--------------------------------------------- Performance Ratings Field END ----------------------------------------------

			--------------------------------------------- Merit Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_merit_percent, @id_field_merit_amount) 
			BEGIN

				IF @id_field = @id_field_merit_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN
					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Merit_percent if Merit_Amount is entered
					SELECT
						@merit_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(pfp.base_salary,0.0) * 100.0000,2) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629 --select * from PEPSICO_FocalPoint_EmpRounding
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--Refresh proposals with the correct merit_percent
					SELECT
						@merit_proposal_prorated = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration), --YS 20210708
						@dm_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20240827
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END				
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830
					
					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END

				IF @id_field = @id_field_merit_percent AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 added india check
				BEGIN
					--Calculate @merit_amount rounded
					SELECT 
						@merit_amount = ROUND(pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					----------------------- ADJUST @merit_percent based on @merit_amount rounded IF NOT INDIAN
					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @merit_percent IS NOT NULL --YS 20210708 --YS 20210824 COMMENTED
	
					SELECT 
						@merit_percent = ROUND(@merit_amount  / NULLIF(pfp.base_salary,0.0) * 100.0000, 2) --YS 20210712
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

			

					--Refresh proposals with the correct merit_percent
					SELECT
						@merit_proposal_prorated = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration), --YS 20210708
						@dm_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20240827
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						-- JM 20230827 * pfp.promotion_multiplier
						--@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000), --YS 20210708
						--@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee
				END
			
				-- Refresh merit_amount, merit_proposal_prorated
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount, @merit_proposal_prorated)

				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3
			
			END
			--------------------------------------------- Merit Percent and Amount Field END ---------------------------------------------
/*-- START COMMENT YS 20240826
			--------------------------------------------- Differentiated Merit Manager Percent Field ---------------------------------------------
			IF @id_field = @id_field_dm_manager_dm_increase
			BEGIN

				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal) --YS 20210629
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal) --YS 20210629
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_manager_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_manager_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee, @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee,@final_proposal, @final_proposal_rounded, @cr_final)
			
				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
			
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)


			END
			--------------------------------------------- Differentiated Merit Manager Percent Field END ---------------------------------------------
-- END COMMENT YS 20240826
*/
			--------------------------------------------- Differentiated Merit HR Percent Field ---------------------------------------------
			IF @id_field IN (@id_field_dm_hr_dm_increase,@id_field_dm_amount) -- YS 20240827
			BEGIN
				IF @id_field = @id_field_dm_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN
					-- work out DM_percent if DM_Amount is entered
					SELECT
						@dm_hr_dm_increase = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@merit_proposal_prorated, 0.0) * 100.0000, 2)
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee
					
					--Refresh proposals with the correct merit_percent
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END	
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END
				
				IF @id_field = @id_field_dm_hr_dm_increase AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception)
				BEGIN
--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal	
					--Calculate @dm_amount rounded
					SELECT 
						@dm_amount = 
							ROUND(	pfp.base_salary 
										* (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) 
										* (CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) 
									, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK)
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					----------------------- ADJUST @dm_hr_dm_increase based on @dm_amount rounded IF NOT INDIAN
	
					SELECT 
						@dm_hr_dm_increase = ROUND(@dm_amount  / NULLIF(@merit_proposal_prorated,0.0) * 100.0000, 2) --YS 20210712
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee


--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal			

					--Refresh proposals with the correct merit_percent
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee
					
				END

				-- Refresh dm_hr_proposal, dm_amount and dm_hr_dm_increase
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			
				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
			
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025	
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3

			END
			--------------------------------------------- Differentiated Merit HR Percent Field END ---------------------------------------------

			--------------------------------------------- Promotion Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_promotion_percent, @id_field_promotion_amount)
			BEGIN

				IF @id_field = @id_field_promotion_percent AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 added india check
				BEGIN
					-- CALCULATE @promotion_cross_amount ROUNDED
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_amount = ROUND(pfp.base_salary * (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) * (1.0000 + CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) * try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000 , ISNULL(rnd.DecimalRoundingFactor,2)) 
						@promotion_cross_amount = 
							ROUND(	pfp.base_salary 
										* (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) 
										* (1.0000 + CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) 
--										* (try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000 * pfp.promotion_multiplier) 
										* (try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000) -- JM 20230915 removed promotion multiplier
									, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @promotion_cross_percent IS NOT NULL --YS 20210708 --YS 20210824 commented
						-- ADJUST @promotion_cross_percent based on @promotion_cross_amount rounded
					SELECT
--						@promotion_cross_percent = @promotion_cross_amount / NULLIF(@dm_hr_proposal, 0.0) * 100.0000
--						@promotion_cross_percent = @promotion_cross_amount / pfp.promotion_multiplier / NULLIF(@dm_hr_proposal, 0.0) * 100.0000 -- JM 20230827 add promotion mulitplier
						@promotion_cross_percent = @promotion_cross_amount / NULLIF(@dm_hr_proposal, 0.0) * 100.0000 -- JM 20230915 removed promotion multiplier
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					--Refresh proposals with the correct equity_percent -- YS 20240830
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

				END
			
				IF @id_field = @id_field_promotion_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Promotion Percent and do the same logic as above
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2)  --YS 20210712
--						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / pfp.promotion_multiplier / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2)  
						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2) -- JM 20230915 removed promotion multiplier 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee	

					--refresh @promotion_cross_percent_multiplier --YS 20240830
					SELECT @promotion_cross_percent_multiplier = ((1.0 + @promotion_cross_percent / 100.0) * pfp.promotion_multiplier - 1.0) * 100.0
					FROM PEPSICO_Process_FocalPoint as pfp
					WHERE pfp.idPayee = @idPayee	

			
					--Refresh proposals with the correct @promotion_cross_percent
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000),
--						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000)
						@promotion_cross_proposal =	pfp.base_salary 
														* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
														* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
														* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000),
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20240830
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000),
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END	
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 			
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END

				-- Refresh promotion_percent,  promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh  merit_spend,
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)

			END 
			--------------------------------------------- Promotion Percent and Amount Field END ---------------------------------------------

			--------------------------------------------- Promotion Type Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_type
			BEGIN
				-- Refresh Promotion Range,  
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_range_refresh(@PlanId, @idStep, @idPayee, @ci, @promotion_cross_type, @cr_promotion, @LevelCodeFinal, @finalSalaryPlanCode_nk)


				--Refresh k_m_fields_values for SalaryPlan_List, Level_List
				--EXEC SP_RTC_FieldValuesRefresh @idStep, @idPayee, @promotion_cross_type, @finalSalaryPlanCode_nk --YS 20210831 Commented

				--Set promotion_cross_level to NULL if promotion_cross_type = 'IN' or ''
				IF @promotion_cross_type = 'IN' OR @promotion_cross_type IS NULL --YS 20210826
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_level AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,
						NULL AS NewValue

				--Set promotion_cross_salary_plan to NULL if promotion_cross_type = ''
				IF @promotion_cross_type IS NULL
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_salary_plan AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,
						NULL AS NewValue
				
			END
			--------------------------------------------- Promotion Type Field END ---------------------------------------------

			--------------------------------------------- Promotion Level Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_level
			BEGIN
				-- Refresh Equity_range
				-- equity range 
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025	
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3

			END
			--------------------------------------------- Promotion Level Field END ---------------------------------------------

			--------------------------------------------- Promotion Salary Plan Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_salary_plan
			BEGIN
				-- Refresh Equity_range, all CompaRatio, DM_Multiplier, DM_Cap
				-- equity range 
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3
			END
			--------------------------------------------- Promotion Salary Plan Field END ---------------------------------------------

			--------------------------------------------- Equity Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_equity_percent, @id_field_equity_amount) 
			BEGIN
/*				-- IF @equity_percent IS ENTERED
				IF @id_field = @id_field_equity_percent AND  @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 Added india check
				BEGIN

					-- work out @equity_amount Rounded 
					SELECT
						@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @equity_percent IS NOT NULL --YS 20210708 --YS20210824 COMMENTED
						-- ADJUST @equity_percent ROUNDED
					SELECT
						@equity_percent = @equity_amount / NULLIF(@promotion_cross_proposal,0) * 100.0000

				END
				-- IF @equity_amount IS ENTERED
				IF @id_field = @id_field_equity_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Equity Percent and do the same logic as above
					SELECT
						@equity_percent = ROUND( ROUND(@equity_amount, ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@promotion_cross_proposal, 0.0) * 100.0000, 2) --YS 20210712 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee
		
					--Refresh proposals with the correct @equity_percent
					SELECT
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000)
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					-- Refresh minimum, lump sum and Final proposal as the equity_percent has been calculated right now -- YS 20230807

					-- Calculate @minimum_proposal -- YS 20230807
					SELECT 
						@minimum_proposal =
							@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee



					------------------------------------ Refresh Lump Sum Amount -- YS 20230807

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0))
												THEN (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0)                   
												ELSE (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0))
												THEN (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0)                     
												ELSE (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor
										END
										ELSE 0 
									END 
							END

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL
						SELECT @final_lump_sum = 0.000


					-- Refresh Final_proposal and final_proposal_rounded -- YS 20230807
					SELECT
						@final_proposal =
							@minimum_amount 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
								- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								,
						@final_proposal_rounded=
							ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

					-- Refresh Compa Ratios -- YS 20230807
					SELECT 
						@cr_merit = cr_merit,
						@cr_targeted = cr_targeted,
						@cr_promotion = cr_promotion,
						@cr_equity	= cr_equity,
						@cr_minimum	= cr_minimum,
						@cr_lump = cr_lump,
						@cr_final = cr_final
					FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				END
*/

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh  merit_spend,
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)


			END
			--------------------------------------------- Equity Percent and Amount Field END ---------------------------------------------

		----------------------------------------------- Compa Ratio Refresh ---------------------------------------------
			-- Refresh Compa Ratios
			SELECT 
				@cr_merit = cr_merit,
				@cr_targeted = cr_targeted,
				@cr_promotion = cr_promotion,
				@cr_equity	= cr_equity,
				@cr_minimum	= cr_minimum,
				@cr_lump = cr_lump,
				@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT
				PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
			FROM _ufn_rtc_compa_ratio_fields_refresh(@PlanId, @idStep, @idPayee, @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final)

		--------------------------------------------- Compa Ratio Refresh END -------------------------------------------

		-------------------------------------------- Refresh ic_score----------------------------------

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
			SELECT 
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@ic_score AS NewValue
			

		-- REMOVED TEMPORARY FIX YS 20210826
	----TEMPORARY FIX TO UPDATE PROMOTION_LEVEL--Set promotion_cross_level to NULL if promotion_cross_type = IN
	--	IF @promotion_cross_type = 'IN'
	--		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
	--		SELECT 
	--			@idStep AS PrimaryKey, 
	--			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_level AS NVARCHAR(30))) AS ObjectFieldAlias,
	--			'' AS ObjectAttribute,
	--			1 AS IsValid,
	--			'' AS InvalidReason,
	--			1 AS AllowEdit,
	--			NULL AS NewValue

		
		END
		--------------------------------------------- Ratings Process End ---------------------------------------------

	END
	----------------- END is_budget_exclude condition-------------------- YS 20211209
	
------------------------------------------------------- JOB ARCHITECTURE Process START------------------------------------------------------- -- YS 20240627
	IF @PlanId = @id_plan_job_architecture -- YS 20240627
	BEGIN

INSERT into zz_temp_jm (temp_datetime, temp_value) values (getdate(), 'input value ' + @inputValue)
		
		IF @id_field = @id_field_ja_poc5_new_job_family
		BEGIN

			DECLARE @job_family_description NVARCHAR(200) = 'Job Family changed. Description will be updated after saving changes.'

			--SELECT 
			--	@job_family_description = JobFamilyDescription -- too long for the max 200 characters :(
			--FROM _tb_ja_JobFamily
			--WHERE JobFamilyCode = @inputValue
		
			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				ISNULL(@job_family_description, 'Description not available') AS NewValue

			--UNION ALL -- JM 20250913 commented

			--IF NOT EXISTS ( -- JM 20250913 added
			--		SELECT *
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee
			--		JOIN _tb_ja_employee_job_title_lookup_exception AS ex
			--			ON ex.GPID = jap.gpid
			--		WHERE
			--			pps.id_step = @idStep)
			--BEGIN
			--	INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			--	SELECT
			--		@idStep AS PrimaryKey, 
			--		CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--		'' AS ObjectAttribute,
			--		1 AS IsValid,
			--		'' AS InvalidReason,
			--		1 AS AllowEdit,
			--		NULL AS NewValue
			--END

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

		END

		IF @id_field = @id_field_ja_poc5_new_job_sub_family
		BEGIN

			DECLARE 
				@job_sub_family_description NVARCHAR(200)  = 'Job Sub Family changed. Description will be updated after saving changes.',
				@job_title_code VARCHAR(50), 
				@job_title_name NVARCHAR(256),
				@GPID NVARCHAR(50)

			-- get new job title

			SELECT TOP 1
				@job_title_code = 
					CASE	
						WHEN jt.JobTitleCode IS NULL THEN 'Not Found' 
						WHEN ex.id IS NOT NULL THEN 'Exception' 
						ELSE jt.JobTitleCode 
					END,
				@job_title_name = jt.JobTitleName,
				@GPID = jap.gpid
			FROM k_m_plans_payees_steps AS pps
			JOIN _tb_ja_process AS jap
				ON jap.idPayee = pps.id_payee
			LEFT JOIN _tb_ja_JobTitle AS jt
				ON jt.JobSubFamilyCode = @inputValue
				AND jt.LevelCode = jap.LevelCode
			LEFT JOIN _tb_ja_employee_job_title_lookup_exception AS ex
				ON ex.GPID = jap.gpid
			WHERE
				pps.id_step = @idStep

			-- add rows to temp table

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				ISNULL(@job_sub_family_description, 'Description not available') AS NewValue
	
			UNION ALL

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@job_title_name AS NewValue
			WHERE 
				@GPID NOT IN (SELECT GPID FROM _tb_ja_employee_job_title_lookup_exception)

			UNION ALL

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@job_title_code AS NewValue
			--WHERE 
			--	@job_title_code <> 'Exception'

--			IF @job_title_code IS NOT NULL
--			BEGIN

--INSERT into zz_temp_jm (temp_datetime, temp_value) values (getdate(), 'job title code ' + @job_title_code)

--				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

--				SELECT
--					@idStep AS PrimaryKey, 
--					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
--					'' AS ObjectAttribute,
--					1 AS IsValid,
--					'' AS InvalidReason,
--					1 AS AllowEdit,
--					@job_title_code AS NewValue
--			END

			--SELECT 
			--	@job_sub_family_description = JobSubFamilyDescription -- too long for the max 200 characters :(
			--FROM _tb_ja_JobSubFamily
			--WHERE JobSubFamilyCode = @inputValue
		
			--DECLARE @job_title_name NVARCHAR(256)

			--; WITH cte_ja_job_title AS (

			--	SELECT 
			--		NewValue,
			--		ROW_NUMBER() OVER (ORDER BY sort_order) AS rn
			--	FROM (
			--		SELECT 
			--			jt.JobTitleName AS NewValue,
			--			2 AS sort_order
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee
			--		JOIN _tb_ja_title_level AS tl
			--			ON tl.LevelCode = jap.LevelCode
			--		JOIN _tb_ja_JobTitle AS jt
			--			ON jt.JobSubFamilyCode = @inputValue
			--			AND jt.titleCode = tl.titleCode
			--		WHERE
			--			pps.id_step = @idStep
			--			--pay.current_JobSubFamilyCode IS NOT NULL

			--		UNION ALL -- YS 20240806_2
		
			--		SELECT 
			--			jt.JobTitleName AS NewValue,
			--			1 as sort_order
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee		
			--		JOIN @Values AS kmv 
			--			ON kmv.idField = @id_field_ja_poc5_new_job_family
			--		JOIN _tb_ja_title_level_jobfunction AS tlj
			--			ON tlj.LevelCode = jap.levelCode
			--			AND tlj.JobFunctionCode_nk = kmv.inputValue -- even though JobFunctionCode_nk, this is the job family
			--		JOIN _tb_ja_JobTitle AS jt
			--			ON jt.JobSubFamilyCode = @inputValue
			--			AND jt.titleCode = tlj.titleCode
			--		WHERE
			--			pps.id_step = @idStep

			--		UNION ALL -- YS 20240806_2
		
			--		SELECT 
			--			NULL AS NewValue,
			--			3 as sort_order
			--	) AS s
			--)

			--INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	@job_sub_family_description AS NewValue

			--UNION ALL

			--SELECT TOP 1
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NewValue
			--FROM cte_ja_job_title
			--WHERE
			--	rn = 1

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
				--NULL AS NewValue

		END


--		DECLARE
--			@job_sub_family_code NVARCHAR(256),
--			@title_code NVARCHAR(256),
--			@job_sub_family_name NVARCHAR(256),
--			@title_name NVARCHAR(256),
--			@job_title_name NVARCHAR(256),
--			@job_sub_family_name_2 NVARCHAR(256), -- YS 20240806
--			@job_title_code_2 NVARCHAR(256) -- YS 20240806

--		SELECT
--			@job_sub_family_code =			NULLIF(p_kmv.ja_poc5_new_job_sub_family,''), -- YS 20240627
--			@title_code =					NULLIF(p_kmv.ja_poc5_new_title,''), -- YS 20240627
--			@job_sub_family_name =			NULLIF(jsf.jobSubFamilyName,''), -- YS 20240627
--			@title_name =					NULLIF(t.titleName,''), -- YS 20240627
--			@job_title_code_2 =				NULLIF(p_kmv.ja_poc5_new_job_title_2,''), -- YS 20240806
--			@job_sub_family_name_2 =		NULLIF(jsf_2.JobSubFamilyName,'') -- YS 20240806
			
--		FROM   
--		(
--			SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
--			FROM @Values AS kmv
--			JOIN k_m_fields as kmf on kmf.id_field = kmv.idField
--			WHERE kmf.code_field  IN (
--				--'ja_poc5_new_job_title', 'ja_poc5_new_title', 'ja_poc5_new_job_sub_family')
--				'ja_poc5_new_job_title', 'ja_poc5_new_title', 'ja_poc5_new_job_sub_family', 'ja_poc5_new_job_title_2') -- YS 20240806
--		) AS s
--		PIVOT
--		(
--			MAX(inputValue)
--			FOR s.code_field  IN (
--				--ja_poc5_new_job_title, ja_poc5_new_title, ja_poc5_new_job_sub_family)
--				ja_poc5_new_job_title, ja_poc5_new_title, ja_poc5_new_job_sub_family,ja_poc5_new_job_title_2) -- YS 20240806
--		) AS p_kmv
--		LEFT JOIN _tb_ja_JobSubFamily AS jsf
--			ON jsf.JobSubFamilyCode = p_kmv.ja_poc5_new_job_sub_family
--		LEFT JOIN _tb_ja_title AS t
--			ON t.titleCode = p_kmv.ja_poc5_new_title
--		LEFT JOIN _tb_ja_JobTitle AS jt_2 -- YS 20240806
--			ON jt_2.JobTitleCode = p_kmv.ja_poc5_new_job_title_2
--		LEFT JOIN _tb_ja_JobSubFamily AS jsf_2 -- YS 20240806
--			ON jsf_2.JobSubFamilyCode = jt_2.JobSubFamilyCode


--		--SELECT @job_title_name = CONCAT(@job_sub_family_name + ' ', @title_name) -- YS 20240712

--		SELECT @job_title_name = JobTitleName
--		FROM _tb_ja_JobTitle
--		WHERE titleCode = @title_code
--		and JobSubFamilyCode = @job_sub_family_code

----select @job_sub_family_code, @job_sub_family_name, @title_code, @title_name, @job_title_name
--		----------------------------------------------- Title Field START -------------------------------------------------

--		IF @id_field = @id_field_ja_poc5_new_title
--		BEGIN
		
--			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
--			SELECT
--				@idStep AS PrimaryKey, 
--				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
--				'' AS ObjectAttribute,
--				1 AS IsValid,
--				'' AS InvalidReason,
--				1 AS AllowEdit,
--				@job_title_name AS NewValue

--		END
--		----------------------------------------------- Title Field END -------------------------------------------------
--		----------------------------------------------- JobTitle_2 Field START ------------------------------------------------- -- YS 20240806

--		IF @id_field = @id_field_ja_poc5_new_job_title_2
--		BEGIN
		
--			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
--			SELECT
--				@idStep AS PrimaryKey, 
--				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
--				'' AS ObjectAttribute,
--				1 AS IsValid,
--				'' AS InvalidReason,
--				1 AS AllowEdit,
--				@job_sub_family_name_2 AS NewValue

--		END
		----------------------------------------------- JobTitle_2 Field END ------------------------------------------------- -- YS 20240806

		
	END
------------------------------------------------------- JOB ARCHITECTURE Process END------------------------------------------------------- -- YS 20240627
------------------------------------------------------- BONUS Process START------------------------------------------------------- --YS 20250724

	IF @PlanId = @id_plan_bonus  --YS 20250724
	BEGIN
		DECLARE 
			@preassigned_bonus nvarchar(max)
		,	@is_correct nvarchar(50)
		,	@bonus_team_correction_reason nvarchar(255)
		,	@bonus_team_enabling nvarchar(255)
		,	@step_1 nvarchar(255)
		,	@step_2 nvarchar(255)
		,	@step_3 nvarchar(255)
		,	@step_35 nvarchar(255)
		,	@step_4 nvarchar(255)
		,	@step_5 nvarchar(255)
		,	@step_1_name nvarchar(255)
		,	@step_2_name nvarchar(255)
		,	@step_3_name nvarchar(255)
		,	@step_4_name nvarchar(255)
		,	@step_5_name nvarchar(255)
		,	@bonus_team_final nvarchar(255)
		,	@double_hatter nvarchar(255)
		,	@prt_message nvarchar(255)
		,	@comment nvarchar(255)
		,	@idCompGroup INT
		,	@is_double_hat bit	

		SELECT
			@is_correct =					NULLIF(p_kmv.bonus_team_assignment_correct,''),
			@bonus_team_correction_reason =	NULLIF(p_kmv.bonus_team_correction_reason,''),
			@bonus_team_enabling =			NULLIF(p_kmv.bonus_team_enabling,''),
			@step_1 =						NULLIF(p_kmv.bonus_team_step_1,''),
			@step_2 =						NULLIF(p_kmv.bonus_team_step_2,''),
			@step_3 =						NULLIF(p_kmv.bonus_team_step_3,''),
			@step_35 =						NULLIF(p_kmv.bonus_team_step_35,''),
			@step_4 =						NULLIF(p_kmv.bonus_team_step_4,''),
			@step_5 =						NULLIF(p_kmv.bonus_team_step_5,''),
			@double_hatter =				NULLIF(p_kmv.bonus_team_double_hatter,''),
			@prt_message =					NULLIF(p_kmv.bonus_team_prt_message,''),
			@comment =						NULLIF(p_kmv.bonus_team_comment,'')
		from (
				SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
				FROM @Values AS kmv
				JOIN k_m_fields as kmf on kmf.id_field = kmv.idField -- select * from k_m_fields
				WHERE kmf.code_field  IN (
					'bonus_team_assignment_correct','bonus_team_correction_reason','bonus_team_enabling',
					'bonus_team_step_1','bonus_team_step_2','bonus_team_step_3','bonus_team_step_35','bonus_team_step_4','bonus_team_step_5',
					'bonus_team_double_hatter','bonus_team_prt_message','bonus_team_comment'
					)
				) AS s
			PIVOT
			(
				MAX(inputValue)
				FOR s.code_field  IN (
					bonus_team_preassigned,bonus_team_assignment_correct,bonus_team_correction_reason,bonus_team_enabling,
					bonus_team_step_1,bonus_team_step_2,bonus_team_step_3,bonus_team_step_35,bonus_team_step_4,bonus_team_step_5,
					bonus_team_double_hatter,bonus_team_prt_message,bonus_team_comment
				)
					
			) AS p_kmv

		-- Get Preassigned Bonus Team from process grid info field
		SELECT @preassigned_bonus =	BonusTeamNameProcess,	--BonusTeamName,	--PK 20251217
			@idCompGroup = idCompGroup,
			@is_double_hat = cast(isnull(pba.IsDoubleHat, 0) as bit)
		from k_m_plans_payees_steps as pps
		JOIN PEPSICO_Process_BonusApproval as pba
			on pps.id_payee = pba.idPayee
			and pps.start_step = pba.start_date_histo
		where pps.id_step = @idStep





--SELECT @preassigned_bonus as preassigned_bonus,@is_correct as is_correct,@bonus_team_correction_reason as bonus_team_correction_reason ,@bonus_team_enabling as bonus_team_enabling ,@step_1 as step_1 ,@step_2 as step_2 ,@step_3 as step_3 ,@step_35 as step_35 ,@step_4 as step_4 ,@step_5 as step_5,@double_hatter as double_hatter ,@prt_message as prt_message,@comment as comment
		-- If Enable is the trigger, nothing to set
		IF @id_field = @id_field_bonus_team_assignment_correct --YS 20250818
		BEGIN
			IF @inputValue IN ('CORRECT', 'SELECT','INCORRECT_DATA')
			BEGIN

				SET @step_1 = NULL
				SET @step_2 = NULL
				SET @comment = NULL

				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_1 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_1 AS NewValue
				UNION ALL
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_2 AS NewValue
			IF @inputValue IN ('CORRECT', 'SELECT')
			BEGIN
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_comment AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@comment AS NewValue
			END

			END

			--SET prt_message depending on assignment_correct_code --YS 20250818
			SELECT @prt_message = ISNULL(prt_message,'')
			FROM PEPSICO_bonus_team_assignment_correct
			WHERE assignment_correct_code = @is_correct
			AND manually_configured_bonus_team = @is_double_hat

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
			SELECT 
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_prt_message AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@prt_message AS NewValue

		END

		
        -- Resolve stored business codes before checking the displayed Step 1 choice.
        SELECT @step_1_name = BTBusinessValue FROM dbo.PEPSICO_Bonus_Team_Business WHERE BTBusinessCode = @step_1;
        SELECT @step_2_name = BTBusinessValue FROM dbo.PEPSICO_Bonus_Team_Business WHERE BTBusinessCode = @step_2;
        SELECT @step_3_name = BTBusinessValue FROM dbo.PEPSICO_Bonus_Team_Business WHERE BTBusinessCode = @step_3;

        -- 20261009: Other and North America allow only Step 1 among the three business steps.
        -- Preserve dependent values; RTC controls editability, not the stored selections.
        DECLARE @allow_bonus_team_details BIT = 1;

        IF LTRIM(RTRIM(REPLACE(@step_1_name, NCHAR(160), N' '))) = N'Other'
            OR EXISTS
            (
                SELECT 1
                FROM dbo.PEPSICO_CompGroup AS cg
                WHERE cg.idCompGroup = @idCompGroup
                    AND LTRIM(RTRIM(REPLACE(cg.CompGroupName, NCHAR(160), N' '))) = N'North America'
            )
            OR @is_correct IN (N'CORRECT', N'SELECT', N'INCORRECT_DATA')
        BEGIN
            SET @allow_bonus_team_details = 0;
        END;

        -- Replace any earlier Step 2 response so each alias occurs exactly once.
        DELETE FROM #tempTable
        WHERE ObjectFieldAlias IN
        (
            CONCAT(@PlanId, '_', @id_ind_bonus_team, '_', @id_field_bonus_team_step_2),
            CONCAT(@PlanId, '_', @id_ind_bonus_team, '_', @id_field_bonus_team_step_3)
        );

        INSERT INTO #tempTable
            (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
        SELECT @idStep,
               CONCAT(@PlanId, '_', @id_ind_bonus_team, '_', f.id_field),
               '',
               CASE WHEN @allow_bonus_team_details = 1 AND @id_field = @id_field_bonus_team_step_2
                         AND f.id_field = @id_field_bonus_team_step_2 THEN 0 ELSE 1 END,
               CASE WHEN @allow_bonus_team_details = 1 AND @id_field = @id_field_bonus_team_step_2
                         AND f.id_field = @id_field_bonus_team_step_2
                    THEN N'Employees should only be assigned a combined bonus team when their role consistently and significantly supports multiple parts of the business. HRBPs will review bonus team changes.'
                    ELSE N'' END,
               @allow_bonus_team_details,
               f.new_value
        FROM (VALUES (@id_field_bonus_team_step_2, @step_2),
                     (@id_field_bonus_team_step_3, @step_3)) AS f(id_field, new_value)
        WHERE f.id_field IS NOT NULL;

		---- Set Bonus team Name based on parameters
		--SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team_ys(@idCompGroup ,@step_1_name,@step_2_name), @preassigned_bonus) ----YS 20250821
		--SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team(@idCompGroup ,@step_1_name,@step_2_name), @preassigned_bonus) ----YS 20250826
		SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team(@idCompGroup ,@step_1_name,@step_2_name,@step_3_name), @preassigned_bonus) ----TK 20261008

		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
		SELECT 
			@idStep AS PrimaryKey, 
			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_final AS NVARCHAR(30))) AS ObjectFieldAlias,
			'' AS ObjectAttribute,
			1 AS IsValid,
			'' AS InvalidReason,
			1 AS AllowEdit,
			@bonus_team_final AS NewValue

	END

------------------------------------------------------- BONUS Process END------------------------------------------------------- --YS 20250724
	---------------------------- Return the entered value if it is not already in the returned table --YS 20210901

	IF NOT EXISTS (SELECT 1 FROM #tempTable WHERE ObjectFieldAlias = CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))))
	BEGIN
		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
		SELECT 
			@idStep AS PrimaryKey, 
			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))) AS ObjectFieldAlias,
			'' AS ObjectAttribute,
			1 AS IsValid,
			'' AS InvalidReason,
			1 AS AllowEdit,
			@inputValue AS NewValue
	END

	-- YS 20211122 FIX: Return ic_score = NULL for inelligible payees instead of 0
	--IF (SELECT is_sc_eligible FROM PEPSICO_Process_FocalPoint WHERE gpid = @codePayee) = 0 --YS 20211201
	IF (SELECT is_sc_eligible FROM PEPSICO_Process_FocalPoint WHERE codePayee = @codePayee) = 0
	BEGIN
		UPDATE #tempTable
		SET NewValue = NULL
		WHERE ObjectFieldAlias = CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30)))
	END

------------------------------- this is for testing START

	--IF NOT EXISTS (SELECT * FROM #tempTable)
	--BEGIN
	--	INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	

	--	SELECT 
	--		@idStep AS PrimaryKey, 
	--		CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))) AS ObjectFieldAlias,
	--		'' AS ObjectAttribute,
	--		1 AS IsValid,
	--		'' AS InvalidReason,
	--		1 AS AllowEdit,
	--		@inputValue AS NewValue
	--END

------------------------------- this is for testing END

---- for debugging	
--insert into zz_temp_jm_tempTable -- select top 1000* from zz_temp_jm_tempTable order by insertdatetime desc
--select *, getdate() from #tempTable


----- DEBUG PAY COMPONENT

--INSERT INTO zz_temp_PayComponentInrcease(FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, Increasepercent, proposedAmount)
--SELECT FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, Increasepercent, proposedAmount
--FROM @RTCPayComponent


	-- return the results

	SELECT PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
	FROM #tempTable

	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;

END
GO
