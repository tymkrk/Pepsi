
--SELECT @preassigned_bonus as preassigned_bonus,@is_correct as is_correct,@bonus_team_correction_reason as bonus_team_correction_reason ,@bonus_team_enabling as bonus_team_enabling ,@step_1 as step_1 ,@step_2 as step_2 ,@step_3 as step_3 ,@step_35 as step_35 ,@step_4 as step_4 ,@step_5 as step_5,@double_hatter as double_hatter ,@prt_message as prt_message,@comment as comment
		-- If Enable is the trigger, nothing to set
		IF @id_field = @id_field_bonus_team_assignment_correct --YS 20250818
		BEGIN
			IF @inputValue IN ('CORRECT', 'SELECT','INCORRECT_DATA')
			BEGIN

				SET @step_1 = NULL
				SET @step_2 = NULL
				SET @step_3 = NULL -- 20261103: Reset all Business selections on validation reset.
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
				UNION ALL
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_3 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_3 AS NewValue
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
