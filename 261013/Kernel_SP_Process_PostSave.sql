CREATE PROCEDURE [dbo].[Kernel_SP_Process_PostSave]
		@idProfile int,
		@idUser int,
		@idTree int,
		@kMValuesData AS [dbo].[Kernel_Type_k_m_values] READONLY,
		@selectedIdPayee int,
		@idProcess int
AS
BEGIN

	Declare @Result bit = 1;
	Declare @Message nvarchar(max) = NULL;
	Declare @argumentsForError nvarchar(max)=NULL
	DECLARE @SuperUser int = (SELECT idUserSuper FROM vPEPSICO_FocalPoint_Parameters) --YS 20200820

	-- Validation check Logic 
	-- Set @Result and @Message. If desired, set @argumentsForError

	/*** START PEPSICO SPECIFIC LOGIC ***/

-- modified by James Mackay 20180227 refresh comp ratios for modified employees
-- modified by James Mackay 20180630 removed default value for LTI Proposal
-- modified by James Mackay 20180704 added rounding
-- modified by James Mackay 20180706 set field values to have null dates
-- modified by Sandip Keni  20180727 updated to sort drop-down field values (changed merge to delete/insert)
-- modified by James Mackay 20180730 UAT004 added call to SP_FocalPointEmpCompaRatioFinalRefresh
-- modified by James Mackay 20180730 added enforced budget check -- removed comp ratio. default value logic to the pre save sp
-- modified by James Mackay 20180813 added logic to update values and do rounding
-- modified by James Mackay 20181129 added logic to use overrides for LTI
-- modified by James Mackay 20181210 added logic to use culture in fields values
-- modified by James Mackay 20181219 corrected culture fix for promotion
-- modified by James Mackay 20190103 added payrange status = 'A' condition
-- modified by Yoann Schrago 20200724 remove ci_str and ci_ltr
-- modified by Yoann Schrago 20200805 delete ic_score and merit_percent and merit_amount if Perf Rating changed
-- modified by James Mackay 20200813 bonus process - added deletion of reason if status is not REJECTED
-- modified by Yoann Schrago 20200814 added outputs to k_m_values_histo for each k_m_values statement
-- modified by Yoann Schragoo 20200820 changed user in k_m_value_histo output when delete values
-- modified by Yoann Schrago 20201013 added LTI SPs
-- modified by James Mackay 20201104 added PEPSICO_FocalPoint_PayRange
-- modified by James Mackay 20201116 changed check for valid steps from 1900 to 2000
-- modified by Yoann Schrago 20210503 SYS2021-09 added SP logging + updated all logging of changed values
-- modified by Yoann Schrago 20210625 SYS2021-01 Performance optimizing due to RTC
-- modified by Yoann Schrago 20210702 populate default value for dm_hr_increase and delete dm_hr_increase from k_m_values if NULL
-- modified by Yoann Schrago 20210713 clear dm_increases if dm_range is NULL
-- modified by Yoann Schrago 20210813 replaced PEPSICO_Process_FocalPoint_Default_Values with PEPSICO_Process_FocalPoint_Default_DM
-- modified by Yoann Schrago 20210830 LTI2021-02 delete DLTI_Final_Amount if NULL for the default value to show
-- modified by Yoann Schrago 20211125 added output to k_m_values_histo when deleting dm_increase if dm_range is NULL
-- modified by James Mackay 20211129 changed vPEPSICO_SalaryPlan_all to PEPSICO_SalaryPlan_all for Performance and fixed a delete from k m values
-- modified by James Mackay 20230826 RM2023-15 added promotion_multiplier
-- modified by James Mackay 20231025 RM2023-15 added exception for CHN14 and 15 to promotion_multiplier
-- modified by Yoann Schrago 20240725 added Job Architecture POC5 jobSubFamily list refresh
-- modified by Yoann Schrago 20240806 added JA JobTitle Dropdown with JobSubFamily-Title
-- modified by Yoann Schrago 20240806_2 added logic for JobTitle based on level and JobFunction
-- modified by Yoann Schrago 20240826 DM2024-03 remove dm_manager_dm_increase from MyTeams grid
-- modified by Yoann Schrago 20240905 LTI2024-04 Add Performance Rating, IC Score and Merit Percent to LTI Process --40178587
-- modified by James Mackay 20241028 zd 115994 added conditions to only return active Salary Plans for lists
-- modified by Kamil Roganowicz 20241025 ZD117419 added MERGE k_m_values for Final Annual Salary USD 
-- modified by Yoann Schrago 20241107 LTI2024-04 Add DM Percent to LTI Process
-- modified by Mateusz Ziecina 20241209 ZD120653 bonus process - do not delete reason if status is UNAPPROVED
-- modified by Yoann Schrago 20240128 ZD122708 issue with FinalLevelCode after save
-- modified by James Mackay 20250410 2025 Job Architecture changes -- removed refiltering of lists.
-- modified by Yoann Schrago 20250822 B2025-05 added involvement status refresh to 
-- modified by James Mackay 20250822 ???? Job Architecture (comment added by Yoann Schrago for records because of deployment from DEV)
-- modified by Yoann Schrago 20250826 B2025-05 comment out Bonus Approval Reason update (not used)
-- modified by Danuta Lemma 20250905 - update PEPSICO_Process_BonusApproval table for login_user_status and changed_date
-- modified by Danuta Lemma 20250925 - logic change for Bonus Team Override updates
-- modified by Kamil Roganowicz 20251008 - add SP_ProcessBonusTeamRefresh
-- modified by Kamil Roganowicz 20251127 perf-tests update PEPSICO_Process_BonusApproval for login_user_status and changed_date
-- modified by Przemyslaw Kot 20261006 PEPPRT26-143 replace APPROVED and PENDING static values with relevant values queried from vPEPSICO_Bonus_Approval_Statuses view

-- test parameters
--DECLARE @idProfile int = -1, @idUser int = 17, @idTree int = 1, @selectedIdPayee int = NULL, @idProcess int = 1, @kMValuesData AS [dbo].[Kernel_Type_k_m_values]
--insert into @kMValuesData (id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value)
--select id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value from _zz_temp_Kernel_Type_k_m_values where input_date >= '2021-07-01 05:53:15.763'

--select id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value from k_m_values where id_value = 810501
--select * from k_m_values where id_step = 2545378 -- in (select id_step from k_m_plans_payees_steps where id_plan = 1)
-- select * from k_m_plans_payees_steps where id_step = 2545378
-- select * from k_m_fields_values where id_payee = 280438 order by id_field, id
--select * from @kMValuesData
--delete from k_m_fields_values where id_payee = 280438
--delete from k_m_fields_values where id_field in (28,29,57)
--delete from k_m_values where  id_field in (28,29,57)

DECLARE @ProcName NVARCHAR(255) = 'Kernel_SP_Process_PostSave', @StartTime datetime = GETUTCDATE(), @SPLogID INT

	/*** focal point process ***/
--truncate table zz_temp_jm
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave START')

--debug
insert into _zz_ys_kMValuesData( id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, insertDateTime)
select *, getutcdate() as insertDateTime
--into _zz_ys_kMValuesData
from @kMValuesData


	DECLARE 
		@idPayeeList NVARCHAR(MAX) = '',
		@idPayeeList_pm NVARCHAR(MAX) = '',
		@idFieldPromType INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_type'), --select * from k_m_fields
		@idFieldPromSalaryPlan INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_salary_plan'), 
		@idFieldPromLevel INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_level'),
		@idFieldLTIProposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'lti_proposal'), 
		@idFieldCI INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci'),
		@idFieldMeritPercent INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_percent'),
		@idFieldMeritAmount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_amount'),
		@idFieldICScore INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score'),
		@idField_dm_is_dm_eligible INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_is_dm_eligible'),
		@idField_dm_tt INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_tt'),
		@idField_dm_stp INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_stp'),
		@idField_dm_cr INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_cr'),
		@idField_dm_hs INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hs'),
		@idField_dm_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_range_max'),
		--@idField_dm_manager_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_manager_dm_increase'), -- YS 20240826
		@idField_dm_hr_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hr_dm_increase'),
		@id_field_lti_final_amount int = (SELECT id_field from k_m_fields where code_field = 'lti_final_amount'),
		--@idFieldSTR INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci_str'),
		--@idFieldLTR INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci_ltr')
		@id_field_final_annual_salary_usd int = (SELECT id_field from k_m_fields where code_field = 'final_annual_salary_usd'),
		@id_ind_pr_ind_final int = (select id_ind from k_m_indicators where name_ind = 'pr_ind_final')

/********************* updating process table for Bonus Approval variable set up (PEPSICO_Process_BonusApproval)  **************************/

		DECLARE 
			@id_field_bonus_team_assignment_correct INT
			,@id_field_bonus_team_final INT
			,@id_field_bonus_team_comment INT;

		SET @id_field_bonus_team_assignment_correct = (SELECT id_field FROM k_m_fields (NOLOCK) WHERE code_field = 'bonus_team_assignment_correct');
		SET @id_field_bonus_team_final = (SELECT id_field FROM k_m_fields (NOLOCK) WHERE code_field = 'bonus_team_final');
		SET @id_field_bonus_team_comment = (SELECT id_field FROM k_m_fields (NOLOCK) WHERE code_field = 'bonus_team_comment');

		DECLARE @bonus_approval_overall_status_APPROVED NVARCHAR(20) = (SELECT status_APPROVED FROM vPEPSICO_Bonus_Approval_Statuses);
		DECLARE @bonus_approval_overall_status_VALIDATED NVARCHAR(20) = (SELECT status_VALIDATED FROM vPEPSICO_Bonus_Approval_Statuses);
		DECLARE @bonus_approval_overall_status_PENDING NVARCHAR(20) = (SELECT status_PENDING FROM vPEPSICO_Bonus_Approval_Statuses);
		DECLARE @bonus_approval_overall_status_PREASSIGNED NVARCHAR(20) = (SELECT status_PREASSIGNED FROM vPEPSICO_Bonus_Approval_Statuses);
		DECLARE @bonus_approval_overall_status_REVIEW_REQUIRED NVARCHAR(20) = (SELECT status_REVIEW_REQUIRED FROM vPEPSICO_Bonus_Approval_Statuses);
		DECLARE @bonus_approval_overall_status_REOPENED NVARCHAR(20) = (SELECT status_REOPENED FROM vPEPSICO_Bonus_Approval_Statuses);

/**********************************************************************************************************/

/********************* update modified employees' compa ratios and default ranges *************************/

	-- get a list of id payees that have been saved and have had ratings changed 
	DROP TABLE IF EXISTS #id
	CREATE TABLE #id (id_payee INT)

	INSERT INTO #id (id_payee) 
	SELECT DISTINCT pps.id_payee
	FROM @kMValuesData AS kmv 
	JOIN k_m_plans_payees_steps AS pps ON pps.id_step = kmv.id_step

	-- build up a comma delimeted string of the ids
	SELECT @idPayeeList = @idPayeeList + CAST(id_payee AS NVARCHAR) + ',' FROM #id 
	SELECT @idPayeeList = SUBSTRING(@idPayeeList, 0, LEN(@idPayeeList)) -- removes the last comma
	
	IF @idProcess = (SELECT idPlanFocalPoint FROM vPEPSICO_Parameters) 
	BEGIN

-------------------- UPDATE PEPSICO_Process_FocalPoint, PEPSICO_DM_Emp and PEPSICO_DM_Emp_multiplier

		-- we want to get the list of promotion multipliers before we do any updates

		DECLARE @promotion_multipler_pre TABLE (idPayee INT, promotion_multipler numeric(18,5))

		INSERT INTO @promotion_multipler_pre (idPayee, promotion_multipler)
		SELECT 
			id.id_payee, 
			pfp.promotion_multiplier
		FROM #id AS id
		JOIN PEPSICO_Process_FocalPoint AS pfp
			ON pfp.idPayee = id.id_payee

		-- Update some important fields in PEPSICO_Process_FocalPoint

		UPDATE pfp
		SET 
			pfp.LevelCodePromotion = piv.promotion_cross_level,
			--pfp.LevelCodeFinal = ISNULL(piv.promotion_cross_level, pfp.LevelCodeCalibrated),
			pfp.LevelCodeFinal = COALESCE(piv.promotion_cross_level, pfp.LevelCode, pfp.LevelCodeCalibrated), -- YS 20240128
			pfp.SalaryPlanCodePromotion = piv.promotion_cross_salary_plan, -- JM 20230827
			pfp.promotion_multiplier = 
				CASE WHEN ISNULL(piv.promotion_cross_level, pfp.LevelCode) = 'L10' AND pfp.SalaryPlanCode_nk NOT IN ('SP-CHN14', 'SP-CHN15')
					THEN 1.00000
					ELSE ISNULL((1.00000 + curr.promotion_multiplier) / (1.00000 + prom.promotion_multiplier), 1.00000)
				END, -- JM 20230827
			pfp.is_merit_eligible = 
				CASE ISNULL(piv.promotion_cross_level, pfp.LevelCodeCalibrated) WHEN 'LG8'
					THEN 0
					ELSE 1
				END,
			pfp.is_dm = 
				CASE WHEN ISNULL(piv.dm_is_dm_eligible,'') = 'YES' 
						AND (ISNULL(piv.dm_cr,'') = nchar(10003) OR ISNULL(piv.dm_tt,'') = nchar(10003) OR ISNULL(piv.dm_hs,'') = nchar(10003) OR ISNULL(piv.dm_stp,'') = nchar(10003))
					THEN 1
					ELSE 0
				END
		FROM #id AS id
		JOIN k_m_plans_payees_steps AS pps
			ON pps.id_payee = id.id_payee
			AND pps.id_plan = @idProcess
		JOIN PEPSICO_Process_FocalPoint AS pfp
			ON pfp.idPayee = pps.id_payee
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv
			ON piv.id_step = pps.id_step
		LEFT JOIN PEPSICO_FocalPoint_Promotion_Mulitplier AS curr -- JM 20230827
			ON curr.SalaryPlanCode_nk = pfp.SalaryPlanCode_nk
			AND curr.LevelCode = pfp.LevelCode
--			AND curr.promotion_multiplier_type_code = 'Non-Sales'
		LEFT JOIN PEPSICO_FocalPoint_Promotion_Mulitplier AS prom -- JM 20230827
			ON prom.SalaryPlanCode_nk = ISNULL(piv.promotion_cross_salary_plan, pfp.SalaryPlanCode_nk)
			AND prom.LevelCode = ISNULL(piv.promotion_cross_level, pfp.LevelCode)
--			AND prom.promotion_multiplier_type_code = 'Non-Sales'

		-- we want to check if any payees changed promotion multipliers before we do any updates

		DECLARE @promotion_multipler_post TABLE (idPayee INT, promotion_multipler numeric(18,5))

		INSERT INTO @promotion_multipler_post (idPayee)
		SELECT 
			pm.idPayee
		FROM @promotion_multipler_pre AS pm
		JOIN PEPSICO_Process_FocalPoint AS pfp 
			ON pfp.idPayee = pm.idPayee
		WHERE
			pm.promotion_multipler <> pfp.promotion_multiplier

		-- refresh k m values if the multiplier changed

		IF EXISTS (SELECT * FROM @promotion_multipler_post)
		BEGIN

			-- build up a comma delimeted string of the ids that changed
			SELECT @idPayeeList_pm = @idPayeeList_pm + CAST(idPayee AS NVARCHAR) + ',' FROM @promotion_multipler_post 
			SELECT @idPayeeList_pm = SUBSTRING(@idPayeeList_pm, 0, LEN(@idPayeeList_pm)) -- removes the last comma

			EXEC SP_FocalPointValuesRefresh @idPayeeList_pm, 0 
		END

-------------------- Update some important fields from PEPSICO_DM_Emp Table
		-- is_eligible
		UPDATE dm
		SET 
			dm.IsEligible =
				CASE piv.dm_is_dm_eligible WHEN 'YES'
					THEN 1
					ELSE 0
				END,
			dm.IsSustainedTopPerformer =
				CASE piv.dm_stp WHEN nchar(10003)
					THEN 1
					ELSE 0
				END
--select  dm.IsEligible, CASE kmv_isEli.input_value WHEN 'YES' THEN 1 ELSE 0 END
		FROM #id AS id
		JOIN k_m_plans_payees_steps AS pps
			ON pps.id_payee = id.id_payee
			AND pps.id_plan = @idProcess
		JOIN PEPSICO_Process_FocalPoint AS pfp
			ON pfp.idPayee = pps.id_payee
		JOIN PEPSICO_DM_Emp AS dm --select * from PEPSICO_DM_Emp
			ON dm.GPID = pfp.gpid
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv
			ON piv.id_step = pps.id_step

-------------------- Update PEPSICO_DM_Emp_Multiplier
		UPDATE dmm
		SET dmm.QualificationCode = tmp.TargetedMeritQualificationCode
		--select dmm.QualificationCode, tmp.TargetedMeritQualificationCode
		FROM #id AS id 
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv 
			ON piv.id_payee = id.id_payee
		JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp 
			ON emp.idPayee = piv.id_payee
		JOIN PEPSICO_DM_Emp_Multiplier AS dmm
			ON dmm.GPID = emp.gpid
		JOIN PEPSICO_FocalPoint_TargetedMeritPosition AS tmp 
			ON tmp.LevelCode = emp.LevelCode 
			AND tmp.SectorCode_nk = emp.SectorCode_nk
			AND tmp.CompaRatioMin <= piv.dm_promotion_compa_ratio
			AND piv.dm_promotion_compa_ratio < tmp.CompaRatioMax 

		UPDATE dmm
		SET 
			dmm.is_capped =
				CASE WHEN piv.dm_range_max > (pr.MidPointPay * ccr.CompaRatioCap / NULLIF(pfp.merit_annualised_factor, 0) - piv.merit_proposal_prorated) / NULLIF(piv.merit_proposal_prorated, 0) * 100 
				AND piv.dm_range_max <> 0	
					THEN 1	
					ELSE 0
				END
		--select	dmm.is_capped,CASE WHEN piv.dm_range_max > (pr.MidPointPay * ccr.CompaRatioCap / NULLIF(pfp.merit_annualised_factor, 0) - piv.merit_proposal_prorated) / NULLIF(piv.merit_proposal_prorated, 0) * 100 AND piv.dm_range_max <> 0	THEN 1	ELSE 0	END
		FROM #id AS id 
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv 
			ON piv.id_payee = id.id_payee
		JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp 
			ON emp.idPayee = piv.id_payee
		JOIN PEPSICO_Process_FocalPoint AS pfp
			ON pfp.idPayee = piv.id_payee
		JOIN PEPSICO_DM_Emp_Multiplier AS dmm
			ON dmm.GPID = emp.gpid
		JOIN PEPSICO_FocalPoint_TargetedMeritMultiplierLookup AS tmml
			ON tmml.SalaryPlanCode_nk = emp.SalaryPlanCode_nk
			AND tmml.IsCapped = 1
		JOIN PEPSICO_FocalPoint_TargetedMeritCapCompRatio AS ccr
			ON ccr.LevelCode = pfp.LevelCodeFinal
			AND ccr.SectorCode_nk = emp.SectorCode_nk 
--		JOIN vPEPSICO_SalaryPlan_All AS sp
		JOIN PEPSICO_SalaryPlan_All AS sp
			ON sp.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	
		JOIN PEPSICO_FocalPoint_PayRange AS pr
			ON pr.IsActive = 1
			AND pr.IsCurrent = 1
			AND pr.LevelCode = pfp.LevelCode
			AND pr.SalaryPlanCode_nk = pfp.SalaryPlanCode_nk

		UPDATE dmm
		SET dmm.Multiplier = piv.dm_range_max
		--SELECT dmm.Multiplier, piv.dm_range_max
		FROM #id AS id
		JOIN k_m_plans_payees_steps AS pps
			ON pps.id_payee = id.id_payee
			AND pps.id_plan = @idProcess
		JOIN PEPSICO_Process_FocalPoint AS pfp
			ON pfp.idPayee = pps.id_payee
		JOIN PEPSICO_DM_Emp_Multiplier AS dmm --select * from PEPSICO_DM_Emp_Multiplier
			ON dmm.GPID = pfp.gpid
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv
			ON piv.id_step = pps.id_step

		-- Clear dm_manager_dm_increase and dm_hr_dm_increase if dm_range is NULL --YS 20210713
		UPDATE kmv
		SET kmv.input_value = NULL,
			kmv.input_value_numeric = NULL

		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, -- YS 20211125 
			inserted.input_date, inserted.id_user, 'Updated by System (100) clear dm increases as range is NULL', @ProcName, GETUTCDATE(), @SuperUser 
		INTO k_m_values_histo(id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)

		FROM #id AS id
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv 
			ON piv.id_payee = id.id_payee
		JOIN k_m_values AS kmv
			ON kmv.id_step = piv.id_step
			--AND id_field IN (@idField_dm_manager_dm_increase, @idField_dm_hr_dm_increase)
			AND id_field IN (@idField_dm_hr_dm_increase) -- YS 20240826
		WHERE piv.dm_range_min IS NULL 
			AND piv.dm_range_max IS NULL
/* YS 20240826
		-- UPDATE default value for dm_hr_dm_increase --YS 20210702
		UPDATE def
		SET
			def.DMHRIncrease = kmv.input_value_numeric
		FROM #id AS id
		JOIN k_m_plans_payees_steps AS pps
			ON pps.id_payee = id.id_payee
			AND pps.id_plan = @idProcess
		JOIN k_m_values AS kmv
			ON kmv.id_step = pps.id_step
			AND kmv.id_field = @idField_dm_manager_dm_increase
		--JOIN PEPSICO_Process_FocalPoint_Default_Values AS def --YS 20210813
		JOIN PEPSICO_Process_FocalPoint_Default_DM AS def
			ON def.idPayee = pps.id_payee
 YS 20240826*/

		-- DELETE dm_hr_dm_increase and dm_manager_dm_increase from k_m_values if NULL --YS 20210702 
		--DELETE kmv
		--FROM k_m_values AS kmv
		--WHERE kmv.id_field IN (@idField_dm_manager_dm_increase, @idField_dm_hr_dm_increase)--= @idField_dm_hr_dm_increase --YS 20210713
		--AND input_value IS NULL
		--AND input_value_int IS NULL
		--AND input_value_numeric IS NULL

		DELETE kmv -- JM 20211129 added joins for performance.
		FROM #id AS id
		JOIN k_m_plans_payees_steps AS pps
			ON pps.id_payee = id.id_payee
			AND pps.id_plan = @idProcess
		JOIN k_m_values AS kmv
			ON kmv.id_step = pps.id_step
			--AND kmv.id_field IN (@idField_dm_manager_dm_increase, @idField_dm_hr_dm_increase)--= @idField_dm_hr_dm_increase --YS 20210713
			AND kmv.id_field IN ( @idField_dm_hr_dm_increase)-- YS 20240826
		WHERE 
			kmv.input_value IS NULL
		AND kmv.input_value_int IS NULL
		AND kmv.input_value_numeric IS NULL


-------------------- UPDATE PEPSICO_Process_FocalPoint and PEPSICO_DM_Emp END

/* YS 20210625
--delete ic_score, merit_percent and merit_amount from update table if new Performance Rating entered
		DELETE FROM k_m_values
		
		OUTPUT
			deleted.id_value, deleted.id_ind, deleted.id_field, deleted.id_step, deleted.input_value, deleted.input_value_int, deleted.input_value_numeric, deleted.input_value_date, 
			deleted.input_date, deleted.id_user, 'Deleted by System (100) Performance Rating modified', @ProcName, GETUTCDATE(), @SuperUser --YS 20200820
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		
		WHERE id_step IN 
		(
			SELECT kmv.id_step
			FROM @kMValuesData AS kmv
			LEFT JOIN k_m_values AS kmv_target
				ON kmv_target.id_step = kmv.id_step
				AND kmv.id_field = kmv_target.id_field
			WHERE 
				kmv.id_field = @idFieldCI
			AND (kmv.input_value IS NULL OR kmv.input_value <> kmv_target.input_value) -- the value has changed --ys 20200810
		) AND id_field IN (@idFieldMeritPercent, @idFieldMeritAmount, @idFieldICScore); -- select * from k_m_fields where id_field in (8,9,46)
			
*/	

		/************************ now refresh some values ***/

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Update Values')

		--EXEC SP_FocalPointValuesRefresh @idPayeeList, 0 --YS 20210625 

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Refresh Rounding')

		--EXEC SP_FocalPointRoundingRefresh @idPayeeList, 0 --YS 20210625 

		IF EXISTS 
			(
				SELECT TOP 1 *
				FROM vPEPSICO_FocalPoint_Parameters AS par
				JOIN @kMValuesData AS kmv 
					ON 1 = 1
				JOIN k_m_plans_payees_steps AS pps 
					ON pps.id_step = kmv.id_step
				JOIN py_Payee AS py 
					ON py.idPayee = pps.id_payee
				JOIN PEPSICO_FocalPoint_EmpPayComponentIncrease AS pci
					ON pci.GPID = py.codePayee
					AND pci.FiscalYear = par.FiscalYear
			)
		BEGIN
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave pay Component Increases')

			EXEC SP_FocalPointEmpPayComponentIncreaseRefresh @idPayeeList, 0 

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Final pay Component Increases')

			EXEC [SP_FocalPointEmpPayComponentIncreaseFinalRefresh] @idPayeeList, 0

		END

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Final pay Component')

		EXEC SP_FocalPointFinalPayComponentsRefresh @idPayeeList = @idPayeeList, @idPEPSICO_FocalPoint_FinalGroup = NULL, @RefreshAll = 0 -- the second parameters says not to refresh all

		/************************ update salary plan list if type has changed ***/

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Promotion')

		-- get a list of payees that have changed their promotion type or salary plan 
		DROP TABLE IF EXISTS #prom
		CREATE TABLE #prom (id_step INT, id_payee INT, promotion_cross_type varchar(50), promotion_cross_salary_plan varchar(50), CurrencyCode varchar(45))

		INSERT INTO #prom (id_step, id_payee, promotion_cross_type, promotion_cross_salary_plan, CurrencyCode) 
		SELECT DISTINCT pps.id_step, pps.id_payee, val.promotion_cross_type, val.promotion_cross_salary_plan, pfp.CurrencyCode
		FROM @kMValuesData AS kmv 
		JOIN k_m_plans_payees_steps AS pps ON pps.id_step = kmv.id_step
		JOIN PEPSICO_Process_FocalPoint AS pfp ON pfp.idPayee = pps.id_payee
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val ON val.id_payee = pps.id_payee
		WHERE kmv.id_field IN (@idFieldPromType, @idFieldPromSalaryPlan)
		
		IF 0 < (SELECT COUNT(1) FROM #prom)
		BEGIN

			print 'we have a promotion or demotion'

			DROP TABLE IF EXISTS #fv
			CREATE TABLE #fv (id_step INT, id_payee INT NOT NULL, id_field INT NOT NULL, culture INT NOT NULL, [value] NVARCHAR(255) NOT NULL, label NVARCHAR(255))
			ALTER TABLE #fv ADD PRIMARY KEY (id_payee, id_field, [value], culture) 

			INSERT INTO #fv (id_step, id_payee, id_field, culture, [value], label)

			SELECT DISTINCT -- salary plans if type selected
				prom.id_step,
				prom.id_payee,
				@idFieldPromSalaryPlan AS id_field, 
				c.id AS culture,
				pr.SalaryPlanCode_nk AS [value],
				sp.SalaryPlanName AS label 
			FROM #prom AS prom 
			JOIN k_cultures AS c ON 1 = 1
			JOIN PEPSICO_FocalPoint_PayRange AS pr 
				ON pr.PayRange_CurrencyCode = prom.CurrencyCode  
				AND pr.PayRangeStatus = 'A'
			--JOIN vPEPSICO_SalaryPlan_all AS sp 
			JOIN PEPSICO_SalaryPlan_all AS sp 
				ON sp.SalaryPlanCode_nk = pr.SalaryPlanCode_nk
				AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate
				AND sp.SalaryPlanStatus = 'A' -- JM 20241028
			WHERE 
				NULLIF(prom.promotion_cross_type, 'NULL') IS NOT NULL
			
			UNION ALL

			SELECT DISTINCT -- levels if demotion or cross selected
				prom.id_step,
				prom.id_payee,
				@idFieldPromLevel AS id_field, 
				c.id AS culture,
				pr.LevelCode AS [value],
				pr.LevelCode AS label 
			FROM #prom AS prom 
			JOIN k_cultures AS c ON 1 = 1
			JOIN PEPSICO_FocalPoint_PayRange AS pr 
				ON pr.PayRange_CurrencyCode = prom.CurrencyCode 
				AND ISNULL(prom.promotion_cross_salary_plan, pr.SalaryPlanCode_nk) = pr.SalaryPlanCode_nk 
				AND pr.PayRangeStatus = 'A'
			--JOIN vPEPSICO_SalaryPlan_all AS sp 
			JOIN PEPSICO_SalaryPlan_all AS sp 
				ON sp.SalaryPlanCode_nk = pr.SalaryPlanCode_nk
				AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate
				AND sp.SalaryPlanStatus = 'A' -- JM 20241028
			WHERE prom.promotion_cross_type IN ('CROSS', 'DEMOTION')

			ORDER BY id_field, label

			-- now refresh the field values list 
			DELETE t
			FROM k_m_fields_values AS t
			INNER JOIN #fv AS s ON s.id_payee = t.id_payee AND s.id_field = t.id_field AND s.culture = t.culture AND s.[value] = t.[value]

			INSERT INTO k_m_fields_values (id_payee, id_field, label, [value], culture, [start_date], end_date)
			SELECT s.id_payee, s.id_field, s.label, s.[value], s.culture, NULL, NULL
			FROM #fv s

			--MERGE INTO k_m_fields_values AS t
			--USING #fv AS s ON s.id_payee = t.id_payee AND s.id_field = t.id_field AND s.culture = t.culture AND s.[value] = t.[value]

			--WHEN NOT MATCHED THEN 
			--	INSERT (id_payee, id_field, label, [value], culture, [start_date], end_date)
			--	VALUES (s.id_payee, s.id_field, s.label, s.[value], s.culture, NULL, NULL)

			--WHEN MATCHED AND t.label <> s.label THEN UPDATE SET t.label = s.label ;

			DELETE kmfv 
			FROM k_m_fields_values AS kmfv
			JOIN #prom AS prom ON prom.id_payee = kmfv.id_payee
			LEFT JOIN #fv AS fv ON fv.id_payee = kmfv.id_payee AND fv.id_field = kmfv.id_field AND fv.culture = kmfv.culture AND fv.[value] = kmfv.[value]
			WHERE kmfv.id_field IN (@idFieldPromLevel, @idFieldPromSalaryPlan) 
			AND fv.id_step IS NULL

			-- delete any new level k m values if not cross or demotion

		END

		/************************ now we want to update transfer k m values ***/

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Transfers')

		MERGE INTO k_m_values AS t
		USING
		(
			SELECT 
				s_tr.id_step, 
				kmv.id_ind,
				kmv.id_field,
				kmv.input_value,
				kmv.input_value_int,
				kmv.input_value_numeric,
				kmv.input_value_date,
				id_user
			FROM #id AS id 
			JOIN py_Payee AS py ON py.idPayee = id.id_payee
			JOIN py_payee AS tr ON tr.codePayee = 'T' + py.codePayee
			JOIN k_m_plans_payees_steps AS s_py ON s_py.id_payee = py.idPayee AND s_py.id_plan = @idProcess
			JOIN k_m_plans_payees_steps AS s_tr ON s_tr.id_payee = tr.idPayee AND s_tr.id_plan = @idProcess
			JOIN k_m_values AS kmv ON kmv.id_step = s_py.id_step
			WHERE py.ss_nb = 'payee' AND tr.ss_nb = 'transfer' 
		) AS s ON s.id_step = t.id_step AND t.id_ind = s.id_ind AND t.id_field = s.id_field

		WHEN NOT MATCHED THEN
			INSERT (id_step, id_ind, id_field, input_value, input_value_int, input_value_numeric, input_value_date, id_user, value_type, idsim)
			VALUES (s.id_step, s.id_ind, s.id_field, s.input_value, s.input_value_int, s.input_value_numeric, s.input_value_date, s.id_user, 1, 0)

		WHEN MATCHED AND NOT
				(	ISNULL(t.input_value, '|') = ISNULL(s.input_value, '|')
				AND ISNULL(t.input_value_int, -99999) = ISNULL(s.input_value_int, -99999)
				AND ISNULL(t.input_value_numeric, -99999) = ISNULL(s.input_value_numeric, -99999)
				AND ISNULL(t.input_value_date, '2999-01-01') = ISNULL(s.input_value_date, '2999-01-01')
				AND t.id_user = s.id_user 
				)
			THEN UPDATE
			SET t.input_value = s.input_value,
				t.input_value_int = s.input_value_int,
				t.input_value_numeric = s.input_value_numeric,
				t.input_value_date = s.input_value_date,
				t.id_user = s.id_user
				
		OUTPUT
			ISNULL(inserted.id_value, deleted.id_value), ISNULL(inserted.id_ind, deleted.id_ind), ISNULL(inserted.id_field, deleted.id_field), ISNULL(inserted.id_step, deleted.id_step), 
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value ELSE inserted.input_value END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_int ELSE inserted.input_value_int END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_numeric ELSE inserted.input_value_numeric END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_date ELSE inserted.input_value_date END,
			ISNULL(inserted.input_date, deleted.input_date), 
			ISNULL(inserted.id_user, deleted.id_user), 
			CASE $ACTION WHEN 'DELETE' THEN 'Deleted by System (200) transfers' ELSE '(200) transfers' END, 
			@ProcName, 
			GETUTCDATE(), 
			@SuperUser
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, date_histo, user_histo)
		;

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave Delete Null Default Values')

--		-- now delete any null k m values with a default value
--		DELETE kmv 

--		OUTPUT 
--			deleted.id_value, deleted.id_ind, deleted.id_field, deleted.id_step, deleted.input_value, deleted.input_value_int, deleted.input_value_numeric, deleted.input_value_date, 
--			deleted.input_date, deleted.id_user, 'Deleted by System (300) delete lump sum and minimum amount if NULL', @ProcName, GETUTCDATE(), @SuperUser--YS 20200820
--		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
--			input_date, id_user, comment_value, source_value, date_histo, user_histo)

--		FROM #id AS id
--		JOIN k_m_plans_payees_steps AS pps ON pps.id_payee = id.id_payee AND pps.id_plan = @idProcess
--		JOIN k_m_values AS kmv ON kmv.id_step = pps.id_step
--		JOIN k_m_fields AS kmf ON kmf.id_field = kmv.id_field AND kmf.code_field IN ('final_lump_sum', 'minimum_amount')
--		WHERE kmv.input_value IS NULL 

--		;WITH cte_steps AS
--		(
--			SELECT DISTINCT id_step 
--			FROM k_m_values AS kmv
--			JOIN k_m_fields AS kmf ON kmf.id_field = kmv.id_field AND kmf.code_field IN ('target_amount_override', 'target_percent_override')
--			WHERE kmv.input_value IS NULL AND kmf.code_field IN ('target_amount_override', 'target_percent_override')
--		)

--		DELETE kmv

--		OUTPUT 
--			deleted.id_value, deleted.id_ind, deleted.id_field, deleted.id_step, deleted.input_value, deleted.input_value_int, deleted.input_value_numeric, deleted.input_value_date, 
--			deleted.input_date, deleted.id_user, 'Deleted by System (400) delete target_amount_override, target_percent_override and target_proposal if NULL', @ProcName, GETUTCDATE(), @SuperUser --YS 20200820
--		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
--			input_date, id_user, comment_value, source_value, date_histo, user_histo)

--		FROM k_m_values AS kmv
--		JOIN cte_steps AS s ON s.id_step = kmv.id_step
--		JOIN k_m_fields AS kmf ON kmf.id_field = kmv.id_field AND kmf.code_field IN ('target_amount_override', 'target_percent_override', 'target_proposal')

		
	/* MERGE k_m_values for Final Annual Salary USD */
		DROP TABLE IF EXISTS #final_salary_usd_calc
		SELECT 
				s_tr.id_step
			,	@id_ind_pr_ind_final							AS id_ind
			,	@id_field_final_annual_salary_usd				AS id_field
			,	emp.FinalValue * ISNULL(fp.ExchangeRate, 1.0)	AS input_value
			,	GETDATE()										AS input_value_date
			,	@idUser											AS id_user
		INTO #final_salary_usd_calc
		FROM #id AS id 
		JOIN k_m_plans_payees_steps AS s_tr 
			ON s_tr.id_payee = id.id_payee 
			AND s_tr.id_plan = @idProcess
		JOIN PEPSICO_Process_FocalPoint fp
			ON id.id_payee = fp.idPayee
		JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
		JOIN PEPSICO_FocalPoint_EmpPayComponentFinal emp
			ON fp.gpid = emp.GPID
			AND emp.PayComponentCode_nk = 'PC-GBL0084'
			AND par.FiscalYear = emp.FiscalYear

		IF EXISTS (SELECT 1 FROM #final_salary_usd_calc)
		BEGIN

				MERGE INTO k_m_values AS t
				USING
				(
					SELECT 
							id_step
						,	id_ind
						,	id_field
						,	cast(input_value as nvarchar(255))	AS input_value
						,	cast(input_value as int)			AS input_value_int
						,	cast(input_value as decimal(18,4))	AS input_value_numeric
						,   input_value_date
						,	id_user
					FROM #final_salary_usd_calc
				) AS s ON s.id_step = t.id_step AND t.id_ind = s.id_ind AND t.id_field = s.id_field
				WHEN NOT MATCHED THEN
					INSERT (id_step, id_ind, id_field, input_value, input_value_int, input_value_numeric, input_value_date, id_user, value_type, idsim)
					VALUES (s.id_step, s.id_ind, s.id_field, s.input_value, s.input_value_int, s.input_value_numeric, s.input_value_date, s.id_user, 1, 0)
				WHEN MATCHED AND NOT
						(	ISNULL(t.input_value, '|') = ISNULL(s.input_value, '|')
						AND ISNULL(t.input_value_int, -99999) = ISNULL(s.input_value_int, -99999)
						AND ISNULL(t.input_value_numeric, -99999) = ISNULL(s.input_value_numeric, -99999)
						AND ISNULL(t.input_value_date, '2999-01-01') = ISNULL(s.input_value_date, '2999-01-01')
						AND t.id_user = s.id_user 
						)
					THEN UPDATE
					SET t.input_value = s.input_value,
						t.input_value_int = s.input_value_int,
						t.input_value_numeric = s.input_value_numeric,
						t.input_value_date = s.input_value_date,
						t.id_user = s.id_user			
				OUTPUT
					ISNULL(inserted.id_value, deleted.id_value), ISNULL(inserted.id_ind, deleted.id_ind), ISNULL(inserted.id_field, deleted.id_field), ISNULL(inserted.id_step, deleted.id_step), 
					CASE $ACTION WHEN 'DELETE' THEN deleted.input_value ELSE inserted.input_value END,
					CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_int ELSE inserted.input_value_int END,
					CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_numeric ELSE inserted.input_value_numeric END,
					CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_date ELSE inserted.input_value_date END,
					ISNULL(inserted.input_date, deleted.input_date), 
					ISNULL(inserted.id_user, deleted.id_user), 
					CASE $ACTION WHEN 'DELETE' THEN 'Deleted by System' ELSE 'Inserted by system' END, 
					@ProcName, 
					GETUTCDATE(), 
					@SuperUser
				INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, date_histo, user_histo)
				;

		END


------- START LTI2024-04 20240905
	DROP TABLE IF EXISTS #py_lti
	DROP TABLE IF EXISTS #py_lti_changes
	
	SELECT DISTINCT
		pps.id_payee,
		kmv.id_step
	INTO #py_lti
	FROM @kMValuesData as kmv
	JOIN k_m_plans_payees_steps as pps WITH(NOLOCK)
		ON pps.id_step = kmv.id_step
		AND pps.id_plan = (SELECT idPlanFocalPoint from vPEPSICO_Parameters)
	WHERE id_field in 
		--(@idFieldCI, @idFieldICScore, @idFieldMeritPercent)
		(@idFieldCI, @idFieldICScore, @idFieldMeritPercent, @idField_dm_hr_dm_increase) -- YS 20241107

	SELECT	
		py.id_payee,
		py.id_step
	INTO #py_lti_changes
	FROM #py_lti AS py
	JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val WITH(NOLOCK)
		ON val.id_payee = py.id_payee
	JOIN PEPSICO_Process_LTI AS pl WITH(NOLOCK)
		ON pl.idPayee = py.id_payee
	WHERE 
		ISNULL(pl.performance_rating,0) <> ISNULL(val.ci,0)
	OR  ISNULL(pl.ic_score,-9999) <> ISNULL(val.ic_score,-9999)
	OR  ISNULL(pl.merit_percent,-9999) <> ISNULL(val.merit_percent,-9999)
	OR  ISNULL(pl.dm_percent,-9999) <> ISNULL(val.dm_hr_dm_increase,-9999) -- YS 20241107
			

	IF EXISTS (SELECT 1 FROM #py_lti_changes)
	BEGIN

------troubleshoot
----insert into zz_ys_tb_postSave_for_lti(id_payee, id_step, ci_old, ci, ic_score_old, ic_score,merit_percent_old, merit_percent, insert_datetime)
----select 
----	py.id_payee, py.id_step,
----	pl.performance_rating as ci_old,val.ci,
----	pl.ic_score as ic_score_old,val.ic_score,
----	pl.merit_percent as merit_percent_old ,val.merit_percent,
----	getutcdate() as insert_datetime
------into zz_ys_tb_postSave_for_lti
----FROM #py_lti_changes AS py
----JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val WITH(NOLOCK)
----	ON val.id_payee = py.id_payee
----JOIN PEPSICO_Process_LTI AS pl WITH(NOLOCK)
----	ON pl.idPayee = py.id_payee

----insert into zz_ys_py_lti_changes (id_payee,id_step, insert_datetime)
----select id_payee,id_step, getutcdate() as insert_datetime
------into zz_ys_py_lti_changes
----from #py_lti_changes

		UPDATE pl
		SET	
			pl.performance_rating = val.ci,
			pl.ic_score = val.ic_score,
			pl.merit_percent = val.merit_percent,
			pl.dm_percent = val.dm_hr_dm_increase -- YS 20241107
		FROM #py_lti_changes AS py
		JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val WITH(NOLOCK)
			ON val.id_payee = py.id_payee
		JOIN PEPSICO_Process_LTI AS pl WITH(NOLOCK)
			ON pl.idPayee = py.id_payee
	END

------- END LTI2024-04 Add Performance Rating, IC Score and Merit Percent to LTI Process
	

	END -- focal point process

	/*** bonus approval process ***/

	IF @idProcess = (SELECT idPlanBonusApproval from vPEPSICO_Parameters)
	BEGIN

		-- get a list of affected payees
		
		-- get a list of id_step that have been saved -- YS 20250822
		DROP TABLE IF EXISTS #ost
		CREATE TABLE #ost (id_step INT, involvement_status NVARCHAR(50),bonus_team_assignment_correct NVARCHAR(250),bonus_team_step_1 NVARCHAR(250),bonus_team_final NVARCHAR(255))

		;WITH cte_id_step AS
		(
			SELECT DISTINCT id_step 
			FROM @kMValuesData AS kmv 
		)

		INSERT INTO #ost (id_step,involvement_status,bonus_team_assignment_correct,bonus_team_step_1,bonus_team_final)
		--SELECT kmv.id_step,'PENDING', piv.bonus_team_assignment_correct, piv.bonus_team_step_1
		SELECT kmv.id_step,@bonus_approval_overall_status_PREASSIGNED, piv.bonus_team_assignment_correct, piv.bonus_team_step_1, piv.bonus_team_final
		FROM cte_id_step AS kmv 
		JOIN vPEPSICO_Process_BonusApproval_Values_Pivoted as piv
			on piv.id_step = kmv.id_step
--select * from #ost where involvement_status = 'APPROVED'
		-- update Involvement status based on Assignment Correct and Business entered -- YS 20250822
		UPDATE kmvd
		--SET involvement_status = 'APPROVED'-- select *
		SET involvement_status = @bonus_approval_overall_status_VALIDATED-- select *
		FROM #ost AS kmvd
		WHERE kmvd.bonus_team_assignment_correct = 'CORRECT' OR (kmvd.bonus_team_assignment_correct = 'INCORRECT_TEAM' AND kmvd.bonus_team_step_1 is not null) -- YS 20251010 added ()

		-- update Involvement Status to Review Required in relevant cases
		UPDATE kmvd
		SET involvement_status = @bonus_approval_overall_status_REVIEW_REQUIRED-- select *
		FROM #ost AS kmvd
		WHERE kmvd.bonus_team_final = N'Other'
		   OR kmvd.bonus_team_assignment_correct = 'INCORRECT_DATA'
		   OR (kmvd.bonus_team_assignment_correct = 'INCORRECT_TEAM_DATA' AND kmvd.bonus_team_step_1 IS NOT NULL)

--select * from #ost where involvement_status = 'APPROVED'
		MERGE k_m_values AS t
		USING 
		(
			SELECT 
				(SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'bonus_approval') AS id_ind,
				(SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status') AS id_field,
				pps.id_step,
				py.involvement_status AS input_value
			FROM #ost AS py
			JOIN k_m_plans_payees_steps AS pps ON pps.id_step = py.id_step
		) AS s ON t.id_step = s.id_step AND t.id_ind = s.id_ind AND t.id_field = s.id_field

		WHEN NOT MATCHED THEN
			INSERT (id_ind, id_field, id_step, input_value, input_date, id_user, value_type, idSim)
			VALUES (s.id_ind, s.id_field, s.id_step, s.input_value, GETUTCDATE(), @idUser, 1, 0)

		WHEN MATCHED AND NOT (ISNULL(t.input_value, '') = ISNULL(s.input_value, '')) THEN
			UPDATE SET t.input_value = s.input_value
			
		OUTPUT
			ISNULL(inserted.id_value, deleted.id_value), ISNULL(inserted.id_ind, deleted.id_ind), ISNULL(inserted.id_field, deleted.id_field), ISNULL(inserted.id_step, deleted.id_step), 
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value ELSE inserted.input_value END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_int ELSE inserted.input_value_int END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_numeric ELSE inserted.input_value_numeric END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_date ELSE inserted.input_value_date END,
			ISNULL(inserted.input_date, deleted.input_date), 
			ISNULL(inserted.id_user, deleted.id_user), 
			CASE $ACTION WHEN 'DELETE' THEN 'Deleted by System (450) Involvement Bonus Status' ELSE '(450) Involvement Bonus Status' END, 
			@ProcName, 
			GETUTCDATE(), 
			@SuperUser
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, date_histo, user_histo)
		;

		-- get a list of id payees that have been saved
		DROP TABLE IF EXISTS #os
		CREATE TABLE #os (id_payee INT, overall_status NVARCHAR(50))

		INSERT INTO #os (id_payee) 
		SELECT DISTINCT pps.id_payee
		FROM @kMValuesData AS kmv 
		JOIN k_m_plans_payees_steps AS pps ON pps.id_step = kmv.id_step

		-- update the overall status

		; WITH cte_status AS 
		(
			SELECT 
				py.id_payee,
				IIF(COUNT(*) = SUM(IIF(kmv.input_value IN (@bonus_approval_overall_status_APPROVED, @bonus_approval_overall_status_VALIDATED), 1, 0)), @bonus_approval_overall_status_VALIDATED, @bonus_approval_overall_status_PENDING) AS overall_status
				--kmv.input_value AS overall_status,
				--ROW_NUMBER() OVER (PARTITION BY py.id_payee ORDER BY kmv.input_value DESC) AS rn
			FROM k_m_plans_payees_steps AS pps 
			JOIN #os AS py ON py.id_payee = pps.id_payee
			LEFT JOIN k_m_values AS kmv ON kmv.id_step = pps.id_step AND kmv.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status')
			WHERE pps.id_plan = @idProcess AND pps.end_step > '2000-01-01'
			GROUP BY py.id_payee
		)

		UPDATE py
		SET py.overall_status = cte.overall_status
		FROM #os AS py
		JOIN cte_status AS cte ON cte.id_payee = py.id_payee --AND cte.rn = 1

		-- now merge this into the k m values table -- TODO: output to k m values histo table
		MERGE k_m_values AS t
		USING 
		(
			SELECT 
				(SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'bonus_approval') AS id_ind,
				(SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_overall_status') AS id_field,
				pps.id_step,
				py.overall_status AS input_value
			FROM #os AS py
			JOIN k_m_plans_payees_steps AS pps ON pps.id_plan = @idProcess AND pps.id_payee = py.id_payee
		) AS s ON t.id_step = s.id_step AND t.id_ind = s.id_ind AND t.id_field = s.id_field

		WHEN NOT MATCHED THEN
			INSERT (id_ind, id_field, id_step, input_value, input_date, id_user, value_type, idSim)
			VALUES (s.id_ind, s.id_field, s.id_step, s.input_value, GETUTCDATE(), @idUser, 1, 0)

		WHEN MATCHED AND NOT (ISNULL(t.input_value, '') = ISNULL(s.input_value, '')) THEN
			UPDATE SET t.input_value = s.input_value
			
		OUTPUT
			ISNULL(inserted.id_value, deleted.id_value), ISNULL(inserted.id_ind, deleted.id_ind), ISNULL(inserted.id_field, deleted.id_field), ISNULL(inserted.id_step, deleted.id_step), 
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value ELSE inserted.input_value END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_int ELSE inserted.input_value_int END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_numeric ELSE inserted.input_value_numeric END,
			CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_date ELSE inserted.input_value_date END,
			ISNULL(inserted.input_date, deleted.input_date), 
			ISNULL(inserted.id_user, deleted.id_user), 
			CASE $ACTION WHEN 'DELETE' THEN 'Deleted by System (500) Bonus Status' ELSE '(500) Bonus Status' END, 
			@ProcName, 
			GETUTCDATE(), 
			@SuperUser
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, date_histo, user_histo)
		;
			
		-- JM 20200813 new logic to clear the reason if the status is not REJECTED
		-- MZ 20241209 updated logic - clear the reason if the status is not REJECTED and not UNAPPROVED
/*		-- YS 20250826 COMMENT OUT SECTION
		UPDATE val_reason
		SET input_value = '',
			id_user = @idUser,
			input_date = GETDATE()		
		OUTPUT
			inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, 'Updated by System (600) Bonus Status Approved', @ProcName, GETUTCDATE(), @SuperUser
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		from k_m_plans_payees_steps AS pps 
		join #os AS os
			on os.id_payee = pps.id_payee
		join k_m_values AS val_reason
			on val_reason.id_step = pps.id_step
		join k_m_fields AS f_reason
			on f_reason.id_field = val_reason.id_field 
			and f_reason.code_field = 'bonus_approval_reason'
		join k_m_fields AS f_status
			on f_status.code_field = 'bonus_approval_involvement_status'
		left join k_m_values AS val_status
			on f_status.id_field = val_status.id_field 
			and val_status.id_step = pps.id_step
		where 
			pps.id_plan = @idProcess
		and ISNULL(val_status.input_value, '') <> 'REJECTED'	
		and ISNULL(val_status.input_value, '') <> 'UNAPPROVED' 
		and ISNULL(val_reason.input_value, '') <> ''
*/
		-- update the process -- this is to set the last login status field

		EXEC dbo.[SP_BonusApprovalProcessRefresh] @idPayeeList, 0


		/* ************ update PEPSICO_Process_BonusApproval for login_user_status and changed_date -- 20250905 DL */
		
		drop table if exists #cte
		;WITH cte as (
				SELECT 
					id_step, 
					MAX(input_date) AS changed_date, 
					@iduser as id_user
				FROM @kMValuesData
				WHERE id_field IN (@id_field_bonus_team_assignment_correct, @id_field_bonus_team_final, @id_field_bonus_team_comment)
				GROUP BY id_step, id_user
			)
			SELECT 
				c.changed_date,
				u.login_user,
				kmpps.id_payee, 
				kmpps.start_step
			into #cte
			FROM cte c 
			JOIN k_m_plans_payees_steps kmpps
				ON c.id_step = kmpps.id_step
			JOIN k_users u 
				ON c.id_user = u.id_user




		UPDATE ba 
		SET 
			login_user_status = t.login_user, 
			ba.changed_date = t.changed_date
		FROM PEPSICO_Process_BonusApproval ba  
		JOIN #cte t
				ON t.start_step = ba.start_date_histo
				AND t.id_payee = ba.idPayee

		

		/*

		;WITH cte as (
			SELECT DISTINCT 
				id_step, 
				MAX(input_date) AS changed_date, 
				@iduser as id_user
			FROM @kMValuesData
			WHERE id_field IN (@id_field_bonus_team_assignment_correct, @id_field_bonus_team_final, @id_field_bonus_team_comment)
			GROUP BY id_step, id_user
		), cte2 AS (
			SELECT 
				c.id_step, 
				c.changed_date,
				c.id_user,
				pps.id_payee, 
				pps.start_step
			FROM cte c inner join k_m_plans_payees_steps pps
				ON pps.id_step = c.id_step
		)

		UPDATE ba 
		SET 
			login_user_status = u.login_user, 
			ba.changed_date = t.changed_date
		FROM PEPSICO_Process_BonusApproval ba  
			INNER JOIN cte2 t
				ON t.start_step = ba.start_date_histo
				AND t.id_payee = ba.idPayee
			INNER JOIN k_users u 
				ON u.id_user = t.id_user
		*/


		/* ********** end of this update *************************************************************************************** */ 


		/* ******************************  logic change for Bonus Team Override 20250925 DL ***************************************/

		exec SP_ProcessBonusTeamRefresh @kMValuesData; 



		--UPDATE ba
		--SET ba.overall_status = os.overall_status
		--FROM PEPSICO_Process_BonusApproval AS ba
		--JOIN #os AS os ON os.id_payee = ba.idPayee

		-- todo: consider deletions			

	END -- bonus approval process

	IF @idProcess = (SELECT idPlanLTI from vPEPSICO_Parameters)
	BEGIN
		
--print('lti default refresh')
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PreSave LTI Default Values')
		EXEC SP_LTIDefaultValuesRefresh @idPayeeList, 0 

--print('Process lti refresh')
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PreSave Refresh LTI Process')
		EXEC SP_LTIProcessRefresh @idPayeeList, 0 

--print('lti Emp refresh')		
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PreSave LTI Update LTI_Emp')
		EXEC SP_LTI_Emp_Refresh @idPayeeList, 0

--print('lti values refresh')
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PreSave LTI Update Values')
		EXEC SP_LTIValuesRefresh @idPayeeList, 0 

		-- YS 20210830
		DELETE kmv

		OUTPUT 
			deleted.id_value, deleted.id_ind, deleted.id_field, deleted.id_step, deleted.input_value, deleted.input_value_int, deleted.input_value_numeric, deleted.input_value_date, 
			deleted.input_date, deleted.id_user, 'Deleted by system (700) delete NULL', @ProcName, GETUTCDATE(), @SuperUser
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)

		FROM k_m_values AS kmv
		JOIN k_m_plans_payees_steps AS pps ON pps.id_step = kmv.id_step
		JOIN #id AS id 
			ON id.id_payee = pps.id_payee
		WHERE kmv.id_field = @id_field_lti_final_amount 
		AND kmv.input_value IS NULL
		AND kmv.input_value_int IS NULL
		AND kmv.input_value_numeric IS NULL
		
		select @Message = 'LTI Save Message Test'

	END																							
	
	------------------------------- JOB ARCHITECTURE

	IF @idProcess = (select idPlanJobArchitecture from vPEPSICO_FocalPoint_Parameters)
	BEGIN
		DECLARE 
			@id_field_ja_poc5_new_job_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_family'),
			@id_field_ja_poc5_new_job_sub_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family')
--			@id_field_ja_poc5_new_job_title_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title_2') -- YS 20240806

--		----------------------- POC 1 START

--		DROP TABLE IF EXISTS #fv_ja
--		CREATE TABLE #fv_ja (id_step INT, id_payee INT NOT NULL, id_field INT NOT NULL, culture INT NOT NULL, [value] NVARCHAR(255) NOT NULL, label NVARCHAR(255))
--		ALTER TABLE #fv_ja ADD PRIMARY KEY (id_payee, id_field, [value], culture) -- (63, 28, SP-ECU01)

--		----------------------- POC 5 START -- YS 20240725

		IF EXISTS (SELECT * FROM @kMValuesData WHERE id_field in (@id_field_ja_poc5_new_job_family, @id_field_ja_poc5_new_job_sub_family))
		BEGIN

			-- get a list of steps where the job family or job sub family changed

			DROP TABLE IF EXISTS #ja_payee_poc5

			SELECT 
				pps.id_step,
				pps.id_payee,
				jap.current_JobFamilyCode,
				jap.current_JobSubFamilyCode,
				--jap.current_JobTitleCode,
				poc5_jf.input_value AS poc5_jobFamily,
				poc5_jsf.input_value AS poc5_jobSubFamily,
				--jap.LevelCode, -- YS 20240806
				kmv_jf.input_value AS Final_JobFamilyCode -- YS 20240806_2
			INTO #ja_payee_poc5
			FROM _tb_ja_process as jap
			JOIN #id as py
				ON py.id_payee = jap.idPayee
			JOIN k_m_plans_payees_steps AS pps
				ON pps.id_payee = jap.idPayee
				AND pps.id_plan = 7
			--LEFT JOIN k_m_values AS poc5_jf
			LEFT JOIN @kMValuesData AS poc5_jf
				ON poc5_jf.id_step = pps.id_step
				AND poc5_jf.id_field = @id_field_ja_poc5_new_job_family
			--LEFT JOIN k_m_values AS poc5_jsf
			LEFT JOIN @kMValuesData AS poc5_jsf
				ON poc5_jsf.id_step = pps.id_step
				AND poc5_jsf.id_field = @id_field_ja_poc5_new_job_sub_family
			LEFT JOIN k_m_values AS kmv_jf
				ON kmv_jf.id_step = pps.id_step
				AND kmv_jf.id_field = @id_field_ja_poc5_new_job_family

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('payee_poc5 job family', ISNULL(poc5_jobFamily, 'NULL')) FROM #ja_payee_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('payee_poc5 job sub family', ISNULL(poc5_jobSubFamily, 'NULL')) FROM #ja_payee_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('payee_poc5 Final_JobFamilyCode', ISNULL(Final_JobFamilyCode, 'NULL')) FROM #ja_payee_poc5))

			 -- build up temp table of steps and their Job Family, Level Code, Job Function Code 

			DROP TABLE IF EXISTS #ja_py_poc5

			SELECT	
				p.id_step,
				p.id_payee,
				--CAST(ISNULL(p.poc5_jobFamily, p.current_JobFamilyCode) AS varchar(50)) AS current_JobFamilyCode,
				--CAST(ISNULL(p.poc5_jobSubFamily, p.current_JobSubFamilyCode) AS varchar(50)) AS current_JobSubFamilyCode,
				CAST(p.poc5_jobFamily AS varchar(50)) AS current_JobFamilyCode,
				CAST(p.poc5_jobSubFamily AS varchar(50)) AS current_JobSubFamilyCode,
				c.id AS culture,
				--p.levelCode, -- YS 20240806
				CAST(ISNULL(p.poc5_jobFamily, p.Final_JobFamilyCode) AS varchar(50)) AS Final_JobFamilyCode
--				p.JobFunctionCode_nk -- YS 20240806_2
			INTO #ja_py_poc5
			FROM #ja_payee_poc5 as p
			JOIN k_cultures as c 
				on c.id = -3 -- English only -- -- select * from k_cultures

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 id step ', ISNULL(CAST(id_step AS varchar), 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 id_payee ', ISNULL(CAST(id_payee AS varchar), 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 culture ', ISNULL(CAST(culture AS varchar), 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 id_field ', ISNULL(CAST(@id_field_ja_poc5_new_job_sub_family AS varchar), 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 job family ', ISNULL(current_JobFamilyCode, 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 job sub family ', ISNULL(current_JobSubFamilyCode, 'NULL')) FROM #ja_py_poc5))
--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 concat('py_poc5 Final_JobFamilyCode ', ISNULL(Final_JobFamilyCode, 'NULL')) FROM #ja_py_poc5))

--			-- get list values for Job Sub Family

--			INSERT INTO #fv_ja (id_step, id_payee, id_field, culture, [value], [label])
--			SELECT DISTINCT 
--				pay.id_step,
--				pay.id_payee,
--				@id_field_ja_poc5_new_job_sub_family AS id_field, 
--				pay.culture,
--				jsf.JobSubFamilyCode AS [value],
--				jsf.JobSubFamilyName AS [label] 
--			FROM #ja_py_poc5 AS pay 
--			JOIN _tb_ja_JobSubFamily AS jsf
--				ON jsf.JobFamilyCode = pay.current_JobFamilyCode
--			WHERE
--				pay.current_JobFamilyCode IS NOT NULL
--			ORDER BY 
--				id_payee, id_field, [label]

--			-- get list values for Job Title -- get for both based on Level, and Level and job Function

--			INSERT INTO #fv_ja (id_step, id_payee, id_field, culture, [value], [label])
--			SELECT DISTINCT 
--				pay.id_step,
--				pay.id_payee,
--				@id_field_ja_poc5_new_job_title_2 AS id_field, 
--				pay.culture,
--				jt.JobTitleCode AS [value],
--				jt.JobTitleName AS [label] 
--			FROM #ja_py_poc5 AS pay 
--			JOIN _tb_ja_title_level AS tl
--				ON tl.LevelCode = pay.levelCode
--			JOIN _tb_ja_JobTitle AS jt
--				ON jt.JobSubFamilyCode = pay.current_JobSubFamilyCode
--				AND jt.titleCode = tl.titleCode
--			WHERE
--				pay.current_JobSubFamilyCode IS NOT NULL

--			UNION ALL -- YS 20240806_2
		
--			SELECT DISTINCT 
--				pay.id_step,
--				pay.id_payee,
--				@id_field_ja_poc5_new_job_title_2 AS id_field, 
--				pay.culture,
--				jt.JobTitleCode AS [value],
--				jt.JobTitleName AS [label] 
--			FROM #ja_py_poc5 AS pay 
--			JOIN _tb_ja_title_level_jobfunction AS tlj
--				ON tlj.LevelCode = pay.levelCode
--				AND tlj.JobFunctionCode_nk = pay.Final_JobFamilyCode
--			JOIN _tb_ja_JobTitle AS jt
--				ON jt.JobSubFamilyCode = pay.current_JobSubFamilyCode
--				AND jt.titleCode = tlj.titleCode
--			WHERE
--				pay.current_JobSubFamilyCode IS NOT NULL
					
--			ORDER BY id_payee, id_field, [label]

--			-- now refresh the field values list for Job Title

--insert into zz_temp_fv_ja (id_step, id_payee, id_field, culture, value, label)
--select id_step, id_payee, id_field, culture, value, label FROM #fv_ja

--			DELETE t
--			FROM k_m_fields_values AS t
--			JOIN #ja_py_poc5 AS pay 
--				ON pay.id_payee = t.id_payee
--				AND pay.current_JobFamilyCode IS NOT NULL
--			WHERE
--				t.id_field in (@id_field_ja_poc5_new_job_sub_family)

--			DELETE t
--			FROM k_m_fields_values AS t
--			JOIN #ja_py_poc5 AS pay 
--				ON pay.id_payee = t.id_payee
----				AND pay.current_JobSubFamilyCode IS NOT NULL
--			WHERE
--				t.id_field in (@id_field_ja_poc5_new_job_title_2)

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'poc5 between list delete and insert')

--			INSERT INTO k_m_fields_values (id_payee, id_field, [label], [value], culture, [start_date], end_date)
--			SELECT s.id_payee, s.id_field, s.[label], s.[value], s.culture, NULL, NULL
--			FROM #fv_ja s
--			ORDER BY s.[label]

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'poc5 END')

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), (SELECT TOP 1 [value] FROM #fv_ja where left(value,2) = 'JT'))

			-- now we update the job family description

			MERGE k_m_values AS t
			USING 
			(
				SELECT DISTINCT 
					(SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'ja_poc5') AS id_ind, -- select * from k_m_indicators
					(SELECT id_field FROM k_m_fields WHERE code_field = 'ja_poc5_new_job_family_description') AS id_field, -- select * from k_m_fields
					pay.id_step,
					jf.JobFamilyDescription AS input_value
				FROM #ja_py_poc5 AS pay 
				JOIN _tb_ja_JobFamily AS jf
					ON jf.JobFamilyCode = pay.current_JobFamilyCode
				WHERE
					pay.current_JobFamilyCode IS NOT NULL

				UNION ALL

				SELECT DISTINCT 
					(SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'ja_poc5') AS id_ind, -- select * from k_m_indicators
					(SELECT id_field FROM k_m_fields WHERE code_field = 'ja_poc5_new_job_sub_family_description') AS id_field, -- select * from k_m_fields
					pay.id_step,
					jsf.JobSubFamilyDescription AS input_value
				FROM #ja_py_poc5 AS pay 
				JOIN _tb_ja_JobSubFamily AS jsf
					ON jsf.JobSubFamilyCode = pay.current_JobSubFamilyCode
				WHERE
					pay.current_JobSubFamilyCode IS NOT NULL

			) AS s ON 
				t.id_step = s.id_step AND t.id_ind = s.id_ind AND t.id_field = s.id_field

			WHEN NOT MATCHED THEN
				INSERT (id_ind, id_field, id_step, input_value, input_date, id_user, value_type, idSim)
				VALUES (s.id_ind, s.id_field, s.id_step, s.input_value, GETUTCDATE(), @idUser, 1, 0)

			WHEN MATCHED AND NOT (ISNULL(t.input_value, '') = ISNULL(s.input_value, '')) THEN
				UPDATE SET t.input_value = s.input_value
			
			OUTPUT
				ISNULL(inserted.id_value, deleted.id_value), ISNULL(inserted.id_ind, deleted.id_ind), ISNULL(inserted.id_field, deleted.id_field), ISNULL(inserted.id_step, deleted.id_step), 
				CASE $ACTION WHEN 'DELETE' THEN deleted.input_value ELSE inserted.input_value END,
				CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_int ELSE inserted.input_value_int END,
				CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_numeric ELSE inserted.input_value_numeric END,
				CASE $ACTION WHEN 'DELETE' THEN deleted.input_value_date ELSE inserted.input_value_date END,
				ISNULL(inserted.input_date, deleted.input_date), 
				ISNULL(inserted.id_user, deleted.id_user), 
				CASE $ACTION WHEN 'DELETE' THEN 'Deleted by System Job Family Description' ELSE 'Job Family Description' END, 
				@ProcName, 
				GETUTCDATE(), 
				@SuperUser
			INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, input_date, id_user, comment_value, source_value, date_histo, user_histo)
			;

		END -- IF EXISTS (SELECT * FROM @kMValuesData WHERE id_field in (@id_field_ja_poc5_new_job_family, @id_field_ja_poc5_new_job_sub_family))

		-- now we want to update the offline grid

		UPDATE t
		SET t.new_JobFamilyCode = pv.ja_poc5_new_job_family,
			t.new_JobSubFamilyCode = pv.ja_poc5_new_job_sub_family,
			t.new_JobTitleCode = pv.ja_poc5_new_job_title, 
			t.new_JobTitle = pv.ja_new_job_title,
			t.new_approval = pv.ja_poc5_approval,
			t.ResultMessage = NULL,
			t.input_source = 'My Team',
			t.update_datetime = GETDATE(),
			t.update_login_user = u.login_user
		-- select *
		FROM _tb_ja_process_offline AS t -- select * from _tb_ja_process_offline
		JOIN #id AS py
			ON py.id_payee = t.idPayee
		JOIN _vw_ja_process_values_pivoted AS pv
			ON pv.id_payee = t.idPayee
		JOIN k_users AS u
			ON u.id_user = @idUser
		WHERE
			(		ISNULL(t.new_JobFamilyCode, '') <> ISNULL(pv.ja_poc5_new_job_family, '')
				OR	ISNULL(t.new_JobSubFamilyCode, '') <> ISNULL(pv.ja_poc5_new_job_sub_family, '')
				OR	ISNULL(t.new_JobTitleCode, '') <> ISNULL(pv.ja_poc5_new_job_title, '')
				OR	ISNULL(t.new_approval, '') <> pv.ja_poc5_approval
			)

		-- update source in process info field

		UPDATE t
		SET t.input_source = 'My Team',
			t.update_datetime = GETDATE(),
			t.update_login_user = u.login_user
		FROM _tb_ja_process AS t
		JOIN #id AS py
			ON py.id_payee = t.idPayee
		JOIN k_users AS u
			ON u.id_user = @idUser
		
	END

	-- END OF  -- Job Architecture Process

--insert into zz_temp_jm (temp_datetime, temp_value) values (GETUTCDATE(), 'Kernel_SP_Process_PostSave END')

	/*** END PEPSICO SPECIFIC LOGIC ***/

	select @Result as Continue_Flag , @Message as Message, @argumentsForError as ArgumentsForError
END
GO
