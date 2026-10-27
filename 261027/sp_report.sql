
CREATE PROCEDURE [dbo].[SP_Report_Process_Values_Employee]
	@idPayee INT, @idProcess INT, @idStep INT
AS
BEGIN

--select * from py_payee where codepayee = '40178214'
-- created by James Mackay 20180929 dataset for process values attached report
-- Modified by Cesar Retana 20180212 target merit designations change the values to yes or no when values are 1 or 0
-- Modified by James Mackay 20200303 added k m values as it seems that not all history is added when changing in the process grid.
-- modified by Yoann Schrago 20201119 added filter to hide row when Value and Previous value are equal
-- modified by Yoann Schrago 20210803 #47484 hide row if ROUND(prev_value,3) = ROUND(value,3)
-- modified by James Mackay 20211211 #53285 show Ratings rather than Comp Index
-- modified by Yoann Schrago 20220124 #55156 fix to show text fields changes
-- modified by Yoann Schrago 20220512 #57702 Remove DM Nomination from the report
-- modified by Yoann Schrago 20240709 ZD105886 id_user_histo issue
-- modified by Kamil Roganowicz 20250227 ZD125608 - perfromance issues
-- modified by Przemyslaw Kot 20251030 PEPPRT26-79 - display history changes exactly for passed parameter @idStep not for random one
-- modified 20261007 show business name for bonus_team_step_3

 ----test parameters 
 --DECLARE @idPayee int = 16836, @idProcess int = 3, @idstep int = 3252143 -- select * from py_payee where codePayee = '03266774'
 ----select *  from k_m_plans_payees_steps where id_plan = @idProcess and id_payee = @idPayee


	DECLARE 
		@id_field_dm_manager_nomination INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_manager_nomination'),
		@id_field_prt_message INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_prt_message'),
		@id_field_bonus_team_step_1 INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_step_1'),
		@id_field_bonus_team_step_2 INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_step_2'),
		@id_field_bonus_team_step_3 INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_step_3')


	/* performance corrections kr */
	--declare @id_step int = (select top 1 id_step from k_m_plans_payees_steps where id_plan = @idProcess and id_payee = @idPayee)

	--temp hold for businesses
	DROP TABLE IF EXISTS #TempBonusTeam;

	CREATE TABLE #TempBonusTeam (
		BTBusinessValue NVARCHAR(4000),
		BTBusinessCode NVARCHAR(50)
	)

	INSERT INTO #TempBonusTeam	
	SELECT 
		DISTINCT BTBusinessValue, 
		BTBusinessCode
	FROM dbo.Pepsico_Bonus_Team_Business

	drop table if exists #kmvalueshisto_perf
	select 
		perf.user_histo, 
		perf.id_step, 
		perf.id_ind, 
		perf.id_field, 
		CASE 
			WHEN perf.id_field = @id_field_bonus_team_step_1 THEN tbt.BTBusinessValue
			WHEN perf.id_field = @id_field_bonus_team_step_2 THEN tbt.BTBusinessValue
			WHEN perf.id_field = @id_field_bonus_team_step_3 THEN tbt.BTBusinessValue
			ELSE perf.input_value 
		END as input_value, 
		perf.input_value_numeric, 
		perf.date_histo, 
		perf.source_value, 
		perf.comment_value
	into #kmvalueshisto_perf 
	from k_m_values_histo perf with (nolock)
		LEFT JOIN #TempBonusTeam tbt
			ON tbt.BTBusinessCode = perf.input_value
	where id_step = @idStep

	drop table if exists #kmvalues_perf
	select 
		kmv.id_user, 
		kmv.id_step, 
		kmv.id_ind, 
		kmv.id_field, 
		CASE 
			WHEN kmv.id_field = @id_field_bonus_team_step_1 THEN tbt.BTBusinessValue
			WHEN kmv.id_field = @id_field_bonus_team_step_2 THEN tbt.BTBusinessValue
			WHEN kmv.id_field = @id_field_bonus_team_step_3 THEN tbt.BTBusinessValue
			ELSE kmv.input_value 
		END as input_value, 
		input_value_numeric, 
		input_date, 
		source_value, 
		comment_value
	into #kmvalues_perf
	from k_m_values kmv with (nolock)
	LEFT JOIN #TempBonusTeam tbt
			ON tbt.BTBusinessCode = kmv.input_value
	where id_step = @idStep



	DROP TABLE IF EXISTS #t
	
	SELECT  
		py.idPayee,
		py.codePayee,
		ISNULL(py.firstname, '') + ' ' + ISNULL(py.lastname, '') AS employee_fullname,
		--CASE WHEN vh.id_user = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.firstname_user, '') + ' ' + ISNULL(u.lastname_user, '') END AS user_fullname, 
		--CASE WHEN vh.id_user = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.login_user,'') END AS user_login, 
		CASE WHEN vh.user_histo = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.firstname_user, '') + ' ' + ISNULL(u.lastname_user, '') END AS user_fullname, -- YS 20240709
		CASE WHEN vh.user_histo = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.login_user,'') END AS user_login,  -- YS 20240709
		vh.id_step,
		vh.id_ind,
		vh.id_field,
		i.name_ind,
		f.name_field, 
		CASE 
			WHEN i.name_ind = 'Targeted Merit' AND vh.input_value = '1' THEN 'Yes'
			WHEN i.name_ind = 'Targeted Merit' AND vh.input_value = '0' THEN 'No'
			ELSE vh.input_value
		END AS input_value,
		vh.input_value_numeric, --YS 20210803
		--vh.input_value,
		vh.date_histo AS input_date,
		vh.source_value,
		vh.comment_value
	INTO #t
	FROM #kmvalueshisto_perf AS vh
	JOIN k_m_plans_payees_steps AS pps  with (nolock)
		ON pps.id_step = vh.id_step 
	JOIN k_m_indicators AS i 
		ON i.id_ind = vh.id_ind
	JOIN k_m_fields AS f ON 
		f.id_field = vh.id_field
	JOIN py_Payee AS py  with (nolock)
		ON py.idPayee = pps.id_payee
	LEFT JOIN k_users AS u  with (nolock)
		--ON u.id_user = vh.id_user
		ON u.id_user = vh.user_histo -- YS 20240709
	WHERE f.id_field --<> @id_field_dm_manager_nomination --YS 20220512
		NOT IN (@id_field_prt_message, @id_field_dm_manager_nomination) -- 20251107

	UNION ALL

	SELECT  
		py.idPayee,
		py.codePayee,
		ISNULL(py.firstname, '') + ' ' + ISNULL(py.lastname, '') AS employee_fullname,
		CASE WHEN vh.id_user = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.firstname_user, '') + ' ' + ISNULL(u.lastname_user, '') END AS user_fullname, 
		CASE WHEN vh.id_user = -1 THEN 'SYSTEM UPDATE' ELSE ISNULL(u.login_user,'') END AS user_login, 
		vh.id_step,
		vh.id_ind,
		vh.id_field,
		i.name_ind,
		f.name_field, 
		CASE 
			WHEN i.name_ind = 'Targeted Merit'AND vh.input_value = '1' THEN 'Yes'
			WHEN i.name_ind = 'Targeted Merit'AND vh.input_value = '0' THEN 'No'
			ELSE vh.input_value
		END AS input_value,
		vh.input_value_numeric, --YS 20210803
		--vh.input_value,
		vh.input_date AS input_date,
		vh.source_value,
		vh.comment_value
	FROM #kmvalues_perf AS vh with (nolock)
	JOIN k_m_plans_payees_steps AS pps  with (nolock)
		ON pps.id_step = vh.id_step 
	JOIN k_m_indicators AS i 
		ON i.id_ind = vh.id_ind
	JOIN k_m_fields AS f ON 
		f.id_field = vh.id_field
	JOIN py_Payee AS py  with (nolock)
		ON py.idPayee = pps.id_payee
	LEFT JOIN k_users AS u  with (nolock)
		ON u.id_user = vh.id_user
	WHERE f.id_field --<> @id_field_dm_manager_nomination --YS 20220512
		NOT IN (@id_field_prt_message, @id_field_dm_manager_nomination) -- 20251107

	;WITH cte_t
	AS
	(
		SELECT 
			idPayee,
			codePayee,
			employee_fullname,
			user_fullname,
			user_login,
			name_ind,
			name_field,
			input_date,
			input_value,
			LAG(input_value, 1) OVER (PARTITION BY id_ind, id_field ORDER BY input_date) AS prev_input_value,
			input_value_numeric, --YS 20210803
			LAG(input_value_numeric, 1) OVER (PARTITION BY id_ind, id_field ORDER BY input_date) AS prev_input_value_numeric, --YS 20210803
			source_value,
			comment_value
		FROM #t
	)
	SELECT
		idPayee,
		codePayee,
		employee_fullname,
		user_fullname,
		user_login,
		name_ind,
		CASE WHEN name_field = 'Comp Index' THEN 'Performance Rating' ELSE name_field END AS name_field, -- JM 20211211
		input_date,
		input_value,
		prev_input_value,
		source_value,
		comment_value
	FROM cte_t
--WHERE ISNULL(input_value,'') <> ISNULL(prev_input_value,'') --YS 20210803
	WHERE ISNULL(ROUND(input_value_numeric,3),999999.9) <> ISNULL(ROUND(prev_input_value_numeric,3),999999.9)
	OR (input_value_numeric IS NULL AND input_value IS NOT NULL and ISNULL(input_value,'') <> ISNULL(prev_input_value,'')) --YS 20220124
	
	order by input_date desc



	DROP TABLE IF EXISTS #t;
	DROP TABLE IF EXISTS #kmvalueshisto_perf;
	DROP TABLE IF EXISTS #kmvalues_perf;
	DROP TABLE IF EXISTS #TempBonusTeam;

END
GO
