		DROP TABLE IF EXISTS #ost
		CREATE TABLE #ost (id_step INT, involvement_status NVARCHAR(50),bonus_team_assignment_correct NVARCHAR(250),bonus_team_step_1 NVARCHAR(250), bonus_team_final NVARCHAR(255))

		;WITH cte_id_step AS
		(
			SELECT DISTINCT id_step 
			FROM @kMValuesData AS kmv 
		)

		INSERT INTO #ost (id_step,involvement_status,bonus_team_assignment_correct,bonus_team_step_1,bonus_team_final) 
		SELECT kmv.id_step, CASE WHEN piv.bonus_team_final = N'Other' THEN N'REVIEW REQUIRED' ELSE N'PENDING' END, piv.bonus_team_assignment_correct, piv.bonus_team_step_1, piv.bonus_team_final
		FROM cte_id_step AS kmv 
		JOIN vPEPSICO_Process_BonusApproval_Values_Pivoted as piv
			on piv.id_step = kmv.id_step
--select * from #ost where involvement_status = 'APPROVED'
		-- update Involvement status based on Assignment Correct and Business entered -- YS 20250822
		UPDATE kmvd
		SET involvement_status = 'APPROVED'-- select *
		FROM #ost AS kmvd
		WHERE ISNULL(kmvd.bonus_team_final, N'') <> N'Other'
		AND (kmvd.bonus_team_assignment_correct = 'CORRECT' OR (kmvd.bonus_team_assignment_correct = 'INCORRECT_TEAM' AND kmvd.bonus_team_step_1 IS NOT NULL)) -- YS 20251010 added ()

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
				kmv.input_value AS overall_status,
				ROW_NUMBER() OVER (PARTITION BY py.id_payee ORDER BY CASE WHEN kmv.input_value = N'REVIEW REQUIRED' THEN 0 ELSE 1 END, kmv.input_value DESC) AS rn
			FROM k_m_plans_payees_steps AS pps 
			JOIN #os AS py ON py.id_payee = pps.id_payee
			LEFT JOIN k_m_values AS kmv ON kmv.id_step = pps.id_step AND kmv.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status')
			WHERE pps.id_plan = @idProcess AND pps.end_step > '2000-01-01'
		)
