-- Bonus Validation Status Mass Upload: Approve / Reject
-- Run the complete file in SSMS or Azure Data Studio (GO batch separators).
-- Includes only production objects and grid configuration; no AI test scripts.
SET NOCOUNT ON;
GO

-- Source: Objects/Tables/dbo.PEPSICO_BonusVerification_Status_MassUpload.sql
IF OBJECT_ID(N'dbo.PEPSICO_BonusVerification_Status_MassUpload', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[PEPSICO_BonusVerification_Status_MassUpload](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[GPID] [nvarchar](50) NOT NULL,
	[start_month] [nvarchar](20) NOT NULL,
	[end_month] [nvarchar](20) NOT NULL,
	[action] [nvarchar](10) NOT NULL CONSTRAINT [DF_BonusVerification_MassUpload_action] DEFAULT (N'Approve'),
	[comment] [nvarchar](max) NULL,
	[is_error] [bit] NULL,
	[error_message] [nvarchar](max) NULL,
	[is_executed] [bit] NULL,
	[execute_date] [datetime] NULL,
	[id_user_insert] [int] NULL,
	[insert_date] [datetime] NULL,
	[id_user_update] [int] NULL,
	[update_date] [datetime] NULL,
 CONSTRAINT [PK_PEPSICO_BonusVerification_Status_MassUpload] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END;
GO

-- Source: Objects/Tables/dbo.PEPSICO_BonusVerification_Status_MassUpload_xhisto.sql
IF OBJECT_ID(N'dbo.PEPSICO_BonusVerification_Status_MassUpload_xhisto', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[PEPSICO_BonusVerification_Status_MassUpload_xhisto](
	[id_xhisto] [int] IDENTITY(1,1) NOT NULL,
	[id_user_xhisto] [int] NOT NULL,
	[dt_xhisto] [datetime] NOT NULL,
	[type_xhisto] [char](3) NOT NULL,
	[action] [nvarchar](10) NULL,
	[comment] [nvarchar](max) NULL,
	[end_month] [nvarchar](20) NULL,
	[error_message] [nvarchar](max) NULL,
	[execute_date] [datetime] NULL,
	[GPID] [nvarchar](50) NULL,
	[id] [int] NULL,
	[id_user_insert] [int] NULL,
	[id_user_update] [int] NULL,
	[insert_date] [datetime] NULL,
	[is_error] [bit] NULL,
	[is_executed] [bit] NULL,
	[start_month] [nvarchar](20) NULL,
	[update_date] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id_xhisto] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END;
GO

-- Source: Scripts/PreDeploy/00_PreDeployBegin/bonus_verification_mass_upload_action.sql
-- Preserve the existing approval queue and old uploads that omit the new column.
IF OBJECT_ID(N'dbo.PEPSICO_BonusVerification_Status_MassUpload', N'U') IS NOT NULL
	AND COL_LENGTH(N'dbo.PEPSICO_BonusVerification_Status_MassUpload', N'action') IS NULL
BEGIN
	ALTER TABLE dbo.PEPSICO_BonusVerification_Status_MassUpload
		ADD action NVARCHAR(10) NOT NULL
			CONSTRAINT DF_BonusVerification_MassUpload_action DEFAULT (N'Approve') WITH VALUES;
END;
GO

IF OBJECT_ID(N'dbo.PEPSICO_BonusVerification_Status_MassUpload_xhisto', N'U') IS NOT NULL
	AND COL_LENGTH(N'dbo.PEPSICO_BonusVerification_Status_MassUpload_xhisto', N'action') IS NULL
BEGIN
	ALTER TABLE dbo.PEPSICO_BonusVerification_Status_MassUpload_xhisto
		ADD action NVARCHAR(10) NULL;
END;
GO

-- Source: Objects/Views/dbo.vPEPSICO_BonusVerification_MassUpload_Actions.sql
CREATE OR ALTER VIEW [dbo].[vPEPSICO_BonusVerification_MassUpload_Actions]
AS
	SELECT CAST(N'Approve' AS NVARCHAR(10)) AS action
	UNION ALL
	SELECT CAST(N'Reject' AS NVARCHAR(10)) AS action;
GO

-- Source: Objects/Stored Procedures/dbo.SP_Grid_Add_Post_PEPSICO_BonusVerification_Status_MassUpload.sql
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Add_Post_PEPSICO_BonusVerification_Status_MassUpload]
	@UniqueKey nvarchar(max)
	,@idUser int
	,@idProfile int
	,@primaryKey int
AS
BEGIN

/******************************************************************************
Purpose: 
1. Update audit fields (e.g. InsertUser) when the record is inserted through the grid
2. Set status to 'CORRECT' in Bonus Verification field in the Bonus Process for
	matching GPID, start_date and end_date

Note:
- Call to this procedure is set from Advanced tab of Grid Editor.

Date		Author			History	
20251209	Przemyslaw Kot	Created
20251216	Przemyslaw Kot	Replace start_date and end_date columns with start_month and end_month and change their data type

********************************************************************************/

---- test parameters -- DECLARE @UniqueKey NVARCHAR(MAX), @idUser INT = -1, @idProfile INT = -1, @primaryKey INT = 1; -- SELECT * FROM PEPSICO_BonusVerification_Status_MassUpload

	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @ResultStatus BIT = 1
	DECLARE @ResultMessage NVARCHAR(MAX) = ''
	
	-- variables definition
	DECLARE 
		@GPID NVARCHAR(50)
		,@StartMonth VARCHAR(20)
		,@EndMonth VARCHAR(20)
		,@Timestamp DATETIME = (SELECT GETUTCDATE())
		
	SELECT
		@GPID = mu.GPID
		,@StartMonth = mu.start_month
		,@EndMonth = mu.end_month
	FROM PEPSICO_BonusVerification_Status_MassUpload AS mu
	WHERE id = @primaryKey


	-- duplicates check
	IF EXISTS	(SELECT 1 FROM PEPSICO_BonusVerification_Status_MassUpload
				WHERE GPID = @GPID
				AND start_month = @StartMonth
				AND end_month = @EndMonth
				AND ISNULL(is_executed, 0) = 0
				AND id <> @primaryKey)
	BEGIN
		SELECT
		0 AS ResultStatus
		,CONCAT('Cannot insert duplicates. Setup for ', @GPID, ' GPID with ', @StartMonth, ' Start Month and ', @EndMonth, ' End Month already exists.') AS ResultMessage
	RETURN
	END
	

	-- update audit fields in the table	
	UPDATE PEPSICO_BonusVerification_Status_MassUpload
		SET is_error = 0
			,is_executed = 0
			,id_user_insert = @idUser
			,insert_date = @Timestamp
	WHERE id = @primaryKey


	-- check if newly defined row has equivalent in the Bonus Process
	IF NOT EXISTS	(SELECT 1 FROM PEPSICO_Process_BonusApproval
					WHERE gpid = @GPID
					AND start_month = @StartMonth
					AND end_month = @EndMonth)
	BEGIN
		UPDATE PEPSICO_BonusVerification_Status_MassUpload
		SET is_error = 1
			,error_message = CONCAT('Error! Setup for ', @GPID, ' GPID with ', @StartMonth, ' Start Month and ', @EndMonth, ' End Month does not exist in the Bonus process.')
		WHERE id = @primaryKey
	END
	

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;

END
GO

-- Source: Objects/Stored Procedures/dbo.SP_Grid_Save_Post_PEPSICO_BonusVerification_Status_MassUpload.sql
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Save_Post_PEPSICO_BonusVerification_Status_MassUpload]
	@UniqueKey nvarchar(max)
	,@idUser int
	,@idProfile int
	,@primaryKey int
AS
BEGIN

/******************************************************************************
Purpose: 
1. Update audit fields (e.g. UpdateUser) when the record is inserted through the grid
2. Set status to 'CORRECT' in Bonus Verification field in the Bonus Process for
	matching GPID, start_date and end_date

Note:
- Call to this procedure is set from Advanced tab of Grid Editor.

Date		Author			History	
20251209	Przemyslaw Kot	Created
20251216	Przemyslaw Kot	Replace start_date and end_date columns with start_month and end_month and change their data type

********************************************************************************/

---- test parameters -- DECLARE @UniqueKey NVARCHAR(MAX), @idUser INT = -1, @idProfile INT = -1, @primaryKey INT = 1; -- SELECT * FROM PEPSICO_BonusVerification_Status_MassUpload

	SET NOCOUNT ON;
	BEGIN TRY

	DECLARE @ResultStatus BIT = 1
	DECLARE @ResultMessage NVARCHAR(MAX) = ''
	
	-- variables definition
	DECLARE 
		@GPID NVARCHAR(50)
		,@StartMonth VARCHAR(10)
		,@EndMonth VARCHAR(10)
		,@Timestamp DATETIME = (SELECT GETUTCDATE())
		,@is_executed BIT
		
	SELECT
		@GPID = mu.GPID
		,@StartMonth = mu.start_month
		,@EndMonth = mu.end_month
		,@is_executed = mu.is_executed
	FROM PEPSICO_BonusVerification_Status_MassUpload AS mu
	WHERE id = @primaryKey


	-- cannot change any data if is_executed = 1
	IF @is_executed = 1
	BEGIN
		SELECT
		0 AS ResultStatus
		,CONCAT('Cannot change any data for already executed configuration. Following setup: ', @GPID, ' GPID, ', @StartMonth, ' Start Month, ', @EndMonth, ' End Month has been already processed in the Bonus process.') AS ResultMessage
	RETURN
	END


	-- duplicates check
	IF EXISTS	(SELECT 1 FROM PEPSICO_BonusVerification_Status_MassUpload
				WHERE GPID = @GPID
				AND start_month = @StartMonth
				AND end_month = @EndMonth
				AND ISNULL(is_executed, 0) = 0
				AND id <> @primaryKey)
	BEGIN
		SELECT
		0 AS ResultStatus
		,CONCAT('Cannot insert duplicates. Setup for ', @GPID, ' GPID with ', @StartMonth, ' Start Month and ', @EndMonth, ' End Month already exists.') AS ResultMessage
	RETURN
	END
	

	-- update audit fields in the table	
	UPDATE PEPSICO_BonusVerification_Status_MassUpload
		SET id_user_update = @idUser
			,update_date = @Timestamp
	WHERE id = @primaryKey


	-- check if altered row has equivalent in the Bonus Process
	IF @is_executed = 0 AND NOT EXISTS	(SELECT 1 FROM PEPSICO_Process_BonusApproval
										WHERE gpid = @GPID
										AND start_month = @StartMonth
										AND end_month = @EndMonth)
	BEGIN
		UPDATE PEPSICO_BonusVerification_Status_MassUpload
		SET is_error = 1
			,error_message = CONCAT('Error! Setup for ', @GPID, ' GPID with ', @StartMonth, ' Start Month and ', @EndMonth, ' End Month does not exist in the Bonus process.')
		WHERE id = @primaryKey
	END

	ELSE
	BEGIN
		UPDATE PEPSICO_BonusVerification_Status_MassUpload
		SET is_error = 0
			,error_message = NULL
		WHERE id = @primaryKey
	END
	

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
	END TRY
	BEGIN CATCH
		THROW;
	END CATCH;

END
GO

-- Source: Objects/Stored Procedures/dbo.SP_BonusVerificationSetCorrectStatusRefresh.sql
CREATE OR ALTER PROCEDURE [dbo].[SP_BonusVerificationSetCorrectStatusRefresh]
AS
BEGIN
	SET NOCOUNT ON;

/*
 Purpose: to sync the data between PEPSICO_BonusVerification_Status_MassUpload (Bonus Verification Status Mass Upload grid) and Bonus process, any new entry or altered entry in this grid that matches data
 in the Bonus process (is_error flag must be set as 0) will set status in the 'Bonus Verification' field to 'CORRECT' and will remove data from all editable fields from 'Bonus Team Review' indicator, moreover
 it will set value in 'Final Bonus Team' to the one from 'Preassigned Bonus Team' and set fields in 'Bonus Approval' indicator to 'Approved' status
 To be called from ETL process	

Date:			Author:			History:
20251209		Przemyslaw Kot	Creation
20251216		Przemyslaw Kot	Replace start_date and end_date columns with start_month and end_month and change their data type, add comment new column
20260114		Przemyslaw Kot	PEPPRT26-89 update also values in 'Last Changed By' and 'Last Changed Date' fields in the Bonus Process along with other fields
20261001		Przemyslaw Kot  PEPPRT26-143 replace APPROVED and PENDING static values with relevant values queried from vPEPSICO_Bonus_Approval_Statuses view
20261007		Tymoteusz Kruk	Add bonus_team_step_3 to the reset fields
20261029		Tymoteusz Kruk	Add mass rejection (SELECT/PREASSIGNED/PENDING), retaining approval behavior
*/

	-- Log SP Execution Start
	DECLARE @ProcName sysname = QUOTENAME(OBJECT_SCHEMA_NAME(@@PROCID))+'.'+QUOTENAME(OBJECT_NAME(@@PROCID))
	DECLARE @StartTime datetime = GETUTCDATE()
	DECLARE @SPLogID INT

	INSERT INTO dbo.SystemSPLog (ProcName, StartTime, Message) VALUES (@ProcName, @StartTime, 'Started')
	SELECT @SPLogID = SCOPE_IDENTITY()

	BEGIN TRY
	

	-- Check if there any rows to be processed (is_executed = 0)
	IF EXISTS (SELECT 1 FROM PEPSICO_BonusVerification_Status_MassUpload WHERE is_executed = 0)
	BEGIN

		-- variables definition
		DECLARE 
				@id_field_bonus_team_assignment_correct	INT		
		,		@id_field_bonus_team_step_1	INT					
		,		@id_field_bonus_team_step_2	INT					
		,		@id_field_bonus_team_step_3	INT
		,		@id_field_bonus_team_final INT					
		,		@id_field_bonus_team_prt_message INT			
		,		@id_field_bonus_team_comment INT				
		,		@id_field_bonus_approval_involvement_status INT 
		,		@id_field_bonus_approval_overall_status INT		
	
		DECLARE @CORRECT_value NVARCHAR(10) = 'CORRECT'
		DECLARE @SELECT_value NVARCHAR(10) = 'SELECT'
		--DECLARE @PENDING_value NVARCHAR(10) = 'PENDING'
		--DECLARE @APPROVED_value NVARCHAR(10) = 'APPROVED'
		DECLARE @id_plan_Bonus INT = (SELECT id_plan FROM k_m_plans WHERE name_plan = 'Bonus')
		DECLARE @CommentValue NVARCHAR(255) = 'Updated by setup from the Bonus Verification Status Mass Upload grid'
		DECLARE @SourceValue NVARCHAR(255) = 'SP_BonusVerificationSetCorrectStatusRefresh'
		DECLARE @id_indicator_bonus_team INT = (SELECT id_ind FROM k_m_indicators WHERE name_ind = 'pr_ind_bonus_team')
		DECLARE @bonus_approval_overall_status_APPROVED NVARCHAR(20) = (SELECT status_APPROVED FROM vPEPSICO_Bonus_Approval_Statuses)
		DECLARE @bonus_approval_overall_status_VALIDATED NVARCHAR(20) = (SELECT status_VALIDATED FROM vPEPSICO_Bonus_Approval_Statuses)
		DECLARE @bonus_approval_involvement_status_PREASSIGNED NVARCHAR(20) = (SELECT status_PREASSIGNED FROM vPEPSICO_Bonus_Approval_Statuses)
		DECLARE @bonus_approval_overall_status_PENDING NVARCHAR(20) = (SELECT status_PENDING FROM vPEPSICO_Bonus_Approval_Statuses)

		SELECT 
			@id_field_bonus_team_assignment_correct			= MAX(CASE WHEN code_field = 'bonus_team_assignment_correct'	 THEN id_field END)
		,	@id_field_bonus_team_step_1						= MAX(CASE WHEN code_field = 'bonus_team_step_1'				 THEN id_field END)
		,	@id_field_bonus_team_step_2						= MAX(CASE WHEN code_field = 'bonus_team_step_2'				 THEN id_field END)
		,	@id_field_bonus_team_step_3						= MAX(CASE WHEN code_field = 'bonus_team_step_3'				 THEN id_field END)
		,	@id_field_bonus_team_final						= MAX(CASE WHEN code_field = 'bonus_team_final'					 THEN id_field END)
		,	@id_field_bonus_team_prt_message				= MAX(CASE WHEN code_field = 'bonus_team_prt_message'			 THEN id_field END)
		,	@id_field_bonus_team_comment					= MAX(CASE WHEN code_field = 'bonus_team_comment'				 THEN id_field END)
		,	@id_field_bonus_approval_involvement_status		= MAX(CASE WHEN code_field = 'bonus_approval_involvement_status' THEN id_field END)
		,	@id_field_bonus_approval_overall_status			= MAX(CASE WHEN code_field = 'bonus_approval_overall_status'	 THEN id_field END)
		FROM k_m_fields
		WHERE code_field IN (
		    'bonus_team_assignment_correct', 'bonus_team_step_1', 'bonus_team_step_2', 'bonus_team_step_3', 'bonus_team_final', 'bonus_team_prt_message',
		    'bonus_team_comment', 'bonus_approval_involvement_status', 'bonus_approval_overall_status'
		);


		-- collecting all rows from PEPSICO_BonusVerification_Status_MassUpload table with flag is_executed = 0 (not yet processed)
		DROP TABLE IF EXISTS #BonusVerification_initial_data

		CREATE TABLE #BonusVerification_initial_data (
			[id] [int] NOT NULL,
			[GPID] [nvarchar](50) NOT NULL,
			[start_month] [nvarchar](20) NOT NULL,
			[end_month] [nvarchar](20) NOT NULL,
			[action] [nvarchar](10) NOT NULL,
			[comment] [nvarchar](max) NULL,
			[is_error] [bit] NULL,
			[error_message] [nvarchar](max) NULL,
			[is_executed] [bit] NULL,
			[execute_date] [datetime] NULL,
			[id_user_insert] [int] NULL,
			[insert_date] [datetime] NULL,
			[id_user_update] [int] NULL,
			[update_date] [datetime] NULL,
			[BonusTeamNameProcess] [nvarchar](255) NULL,
			[is_already_CORRECT] [bit] NULL,
			[is_already_rejected] [bit] NULL,
			[id_step] [int] NULL,
			[idPayee] [int] NULL
			)

		INSERT INTO #BonusVerification_initial_data (
				id
			,	GPID
			,	start_month
			,	end_month
			,	action
			,	comment
			,	is_error
			,	error_message
			,	is_executed
			,	execute_date
			,	id_user_insert
			,	insert_date
			,	id_user_update
			,	update_date
			,	BonusTeamNameProcess
			,	is_already_CORRECT
			,	id_step
			,	idPayee
		)
		SELECT
				id
			,	GPID
			,	start_month
			,	end_month
			,	action
			,	TRIM(comment) AS comment
			,	is_error
			,	error_message
			,	is_executed
			,	execute_date
			,	id_user_insert
			,	insert_date
			,	id_user_update
			,	update_date
			,	NULL AS BonusTeamNameProcess
			,	NULL AS is_already_CORRECT
			,	NULL AS id_step
			,	NULL AS idPayee
		FROM PEPSICO_BonusVerification_Status_MassUpload
		WHERE is_executed = 0;


		-- check again if data from PEPSICO_BonusVerification_Status_MassUpload table matches data in the Bonus process and set other values
		UPDATE bvid
			SET is_error =	CASE
								WHEN ba.id IS NULL THEN 1
								WHEN ba.id IS NOT NULL THEN 0
							END
				,error_message = CASE
									WHEN ba.id IS NULL THEN CONCAT('Error! Setup for ', bvid.GPID, ' GPID with ', bvid.start_month, ' Start Month and ', bvid.end_month, ' End Month does not exist in the Bonus process.')
									WHEN ba.id IS NOT NULL THEN NULL
								END
				,BonusTeamNameProcess =	CASE
											WHEN ba.id IS NULL THEN NULL
											WHEN ba.id IS NOT NULL THEN ba.BonusTeamNameProcess
										END
				,is_already_CORRECT =	CASE
											WHEN ba.id IS NULL THEN NULL
											WHEN ba.id IS NOT NULL AND kmv.input_value = @CORRECT_value THEN 1
											WHEN ba.id IS NOT NULL AND kmv.input_value <> @CORRECT_value THEN 0
										END
				,is_already_rejected = CASE
					WHEN ba.id IS NULL THEN NULL
					WHEN ba.id IS NOT NULL AND kmv.input_value = @SELECT_value THEN 1
					WHEN ba.id IS NOT NULL AND kmv.input_value <> @SELECT_value THEN 0
				END
				,id_step = kmpps.id_step
				,idPayee = ba.idPayee
		FROM #BonusVerification_initial_data AS bvid
		LEFT JOIN PEPSICO_Process_BonusApproval AS ba
			ON bvid.GPID = ba.gpid
			AND bvid.start_month = ba.start_month
			AND bvid.end_month = ba.end_month
		LEFT JOIN k_m_plans_payees_steps AS kmpps
			ON ba.idPayee = kmpps.id_payee
			AND ba.start_date_histo = kmpps.start_step
			AND kmpps.id_plan = @id_plan_Bonus
		LEFT JOIN k_m_values AS kmv
			ON kmpps.id_step = kmv.id_step
			AND kmv.id_field = @id_field_bonus_team_assignment_correct


		-- Only apply actions that are not already in their target state.
		DROP TABLE IF EXISTS #BonusVerification

		SELECT
			id
			,GPID
			,idPayee
			,id_step
			,start_month
			,end_month
			,action
			,BonusTeamNameProcess
			,is_error
			,error_message
			,COALESCE(id_user_update, id_user_insert) AS id_user
			,ku.login_user
			,comment
		INTO #BonusVerification
		FROM #BonusVerification_initial_data AS bvid
		LEFT JOIN k_users AS ku
			ON ku.id_user = COALESCE(id_user_update, id_user_insert)
		WHERE is_error = 0
		AND (
			(action = N'Approve' AND is_already_CORRECT = 0)
			OR (action = N'Reject' AND is_already_rejected = 0)
		)


		-- preparing insert or update data for bonus_team_comment field
		DROP TABLE IF EXISTS #bonus_team_comment

		SELECT
			@id_indicator_bonus_team AS id_ind
			,@id_field_bonus_team_comment AS id_field
			,id_step
			,comment AS input_value
			,@StartTime AS input_date
			,id_user
			,@CommentValue AS comment_value
			,@SourceValue AS source_value
			,1 AS value_type
			,0 AS idSim
		INTO #bonus_team_comment
		FROM #BonusVerification

		-- reseting values in bonus_team_prt_message, bonus_team_step_1, bonus_team_step_2 and bonus_team_step_3 fields 
		UPDATE kmv
		SET 
				kmv.input_value		= NULL
			,	kmv.input_date		= @StartTime
			,	kmv.id_user			= bv.id_user
			,	kmv.comment_value	= @CommentValue
			,	kmv.source_value	= @SourceValue
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user 
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		FROM #BonusVerification AS bv
		INNER JOIN k_m_values AS kmv
			ON kmv.id_step = bv.id_step
		WHERE kmv.id_field IN (@id_field_bonus_team_step_1, @id_field_bonus_team_step_2, @id_field_bonus_team_step_3, @id_field_bonus_team_prt_message)
		

		-- updating value in bonus_team_comment field
		;WITH TARGET AS (
			SELECT
				id_value
				,id_ind
				,id_field
				,id_step
				,input_value
				,input_value_int
				,input_value_numeric
				,input_value_date
				,input_date
				,id_user
				,comment_value
				,source_value
				,value_type
				,idSim
			FROM k_m_values
			WHERE id_field = @id_field_bonus_team_comment
			AND id_ind = @id_indicator_bonus_team
		)
		MERGE INTO TARGET
		USING #bonus_team_comment AS SOURCE
			ON TARGET.id_step = SOURCE.id_step
			AND TARGET.id_field = SOURCE.id_field
		WHEN MATCHED THEN UPDATE
			SET TARGET.input_value		= SOURCE.input_value
				,TARGET.input_date		= SOURCE.input_date
				,TARGET.id_user			= SOURCE.id_user
				,TARGET.comment_value	= SOURCE.comment_value
				,TARGET.source_value	= SOURCE.source_value
		WHEN NOT MATCHED BY TARGET THEN INSERT
				(id_ind
				,id_field
				,id_step
				,input_value
				,input_date
				,id_user
				,comment_value
				,source_value
				,value_type
				,idSim)
		VALUES (SOURCE.id_ind
				,SOURCE.id_field
				,SOURCE.id_step
				,SOURCE.input_value
				,SOURCE.input_date
				,SOURCE.id_user
				,SOURCE.comment_value
				,SOURCE.source_value
				,SOURCE.value_type
				,SOURCE.idSim)
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user 
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo);


		-- Approve verifies the assignment; Reject returns it to SELECT for review.
		UPDATE kmv
		SET 
				kmv.input_value		= CASE WHEN bv.action = N'Reject' THEN @SELECT_value ELSE @CORRECT_value END
			,	kmv.input_date		= @StartTime
			,	kmv.id_user			= bv.id_user
			,	kmv.comment_value	= @CommentValue
			,	kmv.source_value	= @SourceValue
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user 
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		FROM #BonusVerification AS bv
		INNER JOIN k_m_values AS kmv
			ON kmv.id_step = bv.id_step
			AND kmv.id_field = @id_field_bonus_team_assignment_correct


		-- reverting value in bonus_team_final field back to Preassigned Bonus Team
		UPDATE kmv
		SET 
				kmv.input_value		= bv.BonusTeamNameProcess
			,	kmv.input_date		= @StartTime
			,	kmv.id_user			= bv.id_user
			,	kmv.comment_value	= @CommentValue
			,	kmv.source_value	= @SourceValue
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user 
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		FROM #BonusVerification AS bv
		INNER JOIN k_m_values AS kmv
			ON kmv.id_step = bv.id_step
			AND kmv.id_field = @id_field_bonus_team_final
			

		-- Reject restores the initial involvement status; Approve retains VALIDATED.
		UPDATE kmv
		SET 
				--kmv.input_value		= @APPROVED_value
				kmv.input_value		= CASE WHEN bv.action = N'Reject'
					THEN @bonus_approval_involvement_status_PREASSIGNED
					ELSE @bonus_approval_overall_status_VALIDATED END
			,	kmv.input_date		= @StartTime
			,	kmv.id_user			= bv.id_user
			,	kmv.comment_value	= @CommentValue
			,	kmv.source_value	= @SourceValue
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user  
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		FROM #BonusVerification AS bv
		INNER JOIN k_m_values AS kmv
			ON kmv.id_step = bv.id_step
			AND kmv.id_field = @id_field_bonus_approval_involvement_status


		-- checking if all involvements of an employee have in bonus_approval_involvement_status field statuis = APPROVED
		DROP TABLE IF EXISTS #bonus_approval_involvement_status

		SELECT
			g.GPID
			,g.idPayee
			,MIN(g.is_approved) AS is_approved
			,CASE
				WHEN MAX(g.rn_id_user) > 1 AND MIN(g.id_user) <> MAX(g.id_user) THEN -1
				WHEN MAX(g.rn_id_user) > 1 AND MIN(g.id_user) = MAX(g.id_user) THEN MAX(g.id_user)
				WHEN MAX(g.rn_id_user) = 1 THEN MAX(g.id_user)
			END AS id_user
		INTO #bonus_approval_involvement_status
		FROM
			(
			SELECT
				app.GPID
				,app.idPayee
				,app.id_step
				,app.input_value
				,app.is_approved
				,app.id_user
				,ROW_NUMBER() OVER (PARTITION BY app.idPayee ORDER BY app.id_user) AS rn_id_user
			FROM
				(
				SELECT
					bv.GPID
					,bv.idPayee
					,kmpps.id_step
					,kmv.input_value
					,CASE
						--WHEN kmv.input_value = 'APPROVED' THEN 1
						WHEN kmv.input_value IN (@bonus_approval_overall_status_APPROVED, @bonus_approval_overall_status_VALIDATED) THEN 1
						--WHEN kmv.input_value <> 'APPROVED' THEN 0
						WHEN kmv.input_value NOT IN (@bonus_approval_overall_status_APPROVED, @bonus_approval_overall_status_VALIDATED) THEN 0
					END AS is_approved
					,kmv.id_user
				FROM (SELECT DISTINCT
						GPID
						,idPayee
					FROM #BonusVerification
					) AS bv
				INNER JOIN k_m_plans_payees_steps AS kmpps
					ON bv.idPayee = kmpps.id_payee		
					AND kmpps.id_plan = @id_plan_Bonus
					AND kmpps.locked = 0
				INNER JOIN k_m_values AS kmv
					ON kmv.id_step = kmpps.id_step
					AND kmv.id_field = @id_field_bonus_approval_involvement_status
				) AS app
			) AS g
		GROUP BY g.GPID, g.idPayee
		

		-- updating value in bonus_approval_overall_status field to APPROVED/VALIDATED if applicable (if all involments for a given employee have value = APPROVED/VALIDATED in bonus_approval_involvement_status field)
		UPDATE kmv
		SET 
				--kmv.input_value		= @APPROVED_value
				kmv.input_value		= CASE WHEN bais.is_approved = 1
					THEN @bonus_approval_overall_status_VALIDATED
					ELSE @bonus_approval_overall_status_PENDING END
			,	kmv.input_date		= @StartTime
			,	kmv.id_user			= COALESCE(rejected_actor.id_user, bais.id_user)
			,	kmv.comment_value	= @CommentValue
			,	kmv.source_value	= @SourceValue
		OUTPUT inserted.id_value, inserted.id_ind, inserted.id_field, inserted.id_step, inserted.input_value, inserted.input_value_int, inserted.input_value_numeric, inserted.input_value_date, 
			inserted.input_date, inserted.id_user, @CommentValue, @SourceValue, @StartTime, inserted.id_user 
		INTO k_m_values_histo (id_value, id_ind, id_field, id_step, input_value, input_value_int, input_value_numeric, input_value_date, 
			input_date, id_user, comment_value, source_value, date_histo, user_histo)
		FROM #bonus_approval_involvement_status AS bais
		INNER JOIN k_m_plans_payees_steps AS kmpps
			ON kmpps.id_plan = @id_plan_Bonus
			AND bais.idPayee = kmpps.id_payee
		INNER JOIN k_m_values AS kmv
			ON kmv.id_step = kmpps.id_step
			AND kmv.id_field = @id_field_bonus_approval_overall_status
		OUTER APPLY
			(SELECT CASE WHEN MIN(rejected.id_user) = MAX(rejected.id_user)
				THEN MAX(rejected.id_user) ELSE -1 END AS id_user
			 FROM #BonusVerification AS rejected
			 WHERE rejected.idPayee = bais.idPayee AND rejected.action = N'Reject'
			 HAVING COUNT(*) > 0) AS rejected_actor
		WHERE bais.is_approved = 1
			OR (kmpps.locked = 0 AND EXISTS
				(SELECT 1 FROM #BonusVerification AS rejected
				 WHERE rejected.idPayee = bais.idPayee AND rejected.action = N'Reject'))


		-- updating values in 'Last Changed By' and 'Last Changed Date' fields in the Bonus Process to keep the data changes consistent that the change of 'Bonus Verification' 
		-- and values in other fields come from the 'Bonus Verification Status Mass Upload' grid
		UPDATE ba
		SET
				ba.login_user_status = bv.login_user
			,	ba.changed_date = @StartTime
		FROM #BonusVerification AS bv	
		INNER JOIN PEPSICO_Process_BonusApproval AS ba
			ON bv.GPID = ba.GPID
			AND bv.start_month = ba.start_month
			AND bv.end_month = ba.end_month

		
		-- Complete processed uploads and valid actions already in their target status.
		UPDATE mu
		SET is_error = bvid.is_error, error_message = bvid.error_message,
			is_executed = 1, execute_date = @StartTime
		FROM dbo.PEPSICO_BonusVerification_Status_MassUpload AS mu
		INNER JOIN #BonusVerification_initial_data AS bvid ON bvid.id = mu.id
		WHERE bvid.is_error = 0
			AND (EXISTS (SELECT 1 FROM #BonusVerification AS processed WHERE processed.id = bvid.id)
				OR (bvid.action = N'Approve' AND bvid.is_already_CORRECT = 1)
				OR (bvid.action = N'Reject' AND bvid.is_already_rejected = 1));


		-- removing temp tables
		DROP TABLE IF EXISTS #BonusVerification_initial_data
		DROP TABLE IF EXISTS #BonusVerification
		DROP TABLE IF EXISTS #bonus_team_comment
		DROP TABLE IF EXISTS #bonus_approval_involvement_status

	END

		-- Log SP Execution success
	INSERT INTO dbo.SystemSPLog (StartSPLogID, ProcName, StartTime, EndTime, Message) VALUES (@SPLogID, @ProcName, @StartTime, GETUTCDATE(), 'Ended with success');

	END TRY

	BEGIN CATCH		
		-- Log SP Execution failure
		INSERT INTO dbo.SystemSPLog (StartSPLogID, ProcName, StartTime, EndTime, Message) VALUES (@SPLogID, @ProcName, @StartTime, GETUTCDATE(), 'Ended with failure. Error at line ' + CAST(ERROR_LINE() AS VARCHAR) + ': ' + ERROR_MESSAGE());

		THROW;
	END CATCH;
END
GO

-- Source: Scripts/PostDeploy/30_Wrappers/Grids/Parents/Bonus_Validation_Status_Mass_Upload.sql
/* ----------------------------------------------------------------------------- */
	/* GRID NAME: Bonus Validation Status Mass Upload                              */
	/* ----------------------------------------------------------------------------- */

	exec sp_client_std_synchronize 'PEPSICO_BonusVerification_Status_MassUpload', 'table', 0;
	EXEC sp_client_std_synchronize 'vPEPSICO_BonusVerification_MassUpload_Actions', 'View', 0;
	GO

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids                                                   */
	/* SCRIPT GENERATION TIME:     2026-10-26 00:00:00.                                                  */
	/* USER:                       krystian.kawa@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Bonus Validation Status Mass Upload                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'PEPSICO_BonusVerification_Status_MassUpload', 'Bonus Validation Upload', 'Bonus Validation Status Mass Upload', '-1', '#NULL#', '50', '1', '#NULL#', '#NULL#', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '0', '1', '-1', '0', '1', '4', '#NULL#', '1', '#NULL#', '#NULL#', '#NULL#', '', 'SP_Grid_Add_Post_PEPSICO_BonusVerification_Status_MassUpload', '', 'SP_Grid_Save_Post_PEPSICO_BonusVerification_Status_MassUpload', '', '', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '1', '1', '0', '#NULL#', '0', '0', '1', '1', '', '', '0')
	) s ( rn, ref_name_table_view, ref_name_folder, name_grid, type_grid, comments, page_size, is_addable, form_id, url, is_deletable, is_searchable, is_exportable, date_grid, grouping_field, frozen_column, active_trace, filtering_field, is_simulated, is_importable, idOwner, is_auto_resize, is_track_change, sort_grid, width, fit_to_screen, id_source_tenant, id_source, id_change_set, sp_grid_add_pre, sp_grid_add_post, sp_grid_save_pre, sp_grid_save_post, sp_grid_delete_pre, sp_grid_delete_post, is_bulk_insert, is_tree, master_id_table_view_field, child_id_table_view_field, parent_id_table_view_field, is_staging_area_enabled, is_export_template_enabled, show_default_security_view, use_attached_objects, tree_collapse_after_save, is_password_protection_enabled, apply_user_filter, wrap_header, header_tooltip, sp_grid_import_pre, sp_grid_import_post, allow_attached_file) ;


	exec [dbo].[_sp_sync_k_referential_grids_data_merge];

		exec sp_client_std_synchronize 'vPEPSICO_Bonus_Verification_Status_Mass_Upload_grid_users_lookup', 'View', 0;
		GO

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids_fields                                            */
	/* SCRIPT GENERATION TIME:     2026-10-26 00:00:00.                                                  */
	/* USER:                       krystian.kawa@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Bonus Validation Status Mass Upload                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Validation Status Mass Upload', 'GPID', 'GPID', '0', '1', '#NULL#', '1', '#NULL#', '#NULL#', '300', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', '#NULL#', '', '0', '0', '0')
, 	('2', 'Bonus Validation Status Mass Upload', 'start_month', 'Start Month', '1', '1', '#NULL#', '1', '#NULL#', '#NULL#', '100', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', '#NULL#', '', '0', '0', '0')
, 	('3', 'Bonus Validation Status Mass Upload', 'end_month', 'End Month', '2', '1', '#NULL#', '1', '#NULL#', '#NULL#', '100', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('4', 'Bonus Validation Status Mass Upload', 'comment', 'Comment', '4', '1', '#NULL#', '1', '#NULL#', '#NULL#', '400', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('5', 'Bonus Validation Status Mass Upload', 'is_error', 'Is Error', '5', '0', '#NULL#', '1', '#NULL#', '#NULL#', '100', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('6', 'Bonus Validation Status Mass Upload', 'error_message', 'Error Message', '6', '0', '#NULL#', '1', '#NULL#', '#NULL#', '500', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('7', 'Bonus Validation Status Mass Upload', 'is_executed', 'Is Executed', '7', '0', '#NULL#', '1', '#NULL#', '#NULL#', '100', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('8', 'Bonus Validation Status Mass Upload', 'execute_date', 'Executed Date', '8', '0', '#NULL#', '1', '#NULL#', '#NULL#', '150', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '', '0', '0', '0')
, 	('9', 'Bonus Validation Status Mass Upload', 'id_user_insert', 'Insert User', '9', '0', '#NULL#', '1', '#NULL#', '#NULL#', '200', 'vPEPSICO_Bonus_Verification_Status_Mass_Upload_grid_users_lookup', 'id_user', 'login_user', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', 'GV_SingleCombo', '#NULL#', '0', '0', '0')
, 	('10', 'Bonus Validation Status Mass Upload', 'insert_date', 'Insert Date', '10', '0', '#NULL#', '1', '#NULL#', '#NULL#', '150', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('11', 'Bonus Validation Status Mass Upload', 'id_user_update', 'Update User', '11', '0', '#NULL#', '1', '#NULL#', '#NULL#', '200', 'vPEPSICO_Bonus_Verification_Status_Mass_Upload_grid_users_lookup', 'id_user', 'login_user', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', 'GV_SingleCombo', '#NULL#', '0', '0', '0')
, 	('12', 'Bonus Validation Status Mass Upload', 'update_date', 'Update Date', '12', '0', '#NULL#', '1', '#NULL#', '#NULL#', '150', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
, 	('13', 'Bonus Validation Status Mass Upload', 'action', 'Action', '3', '1', '#NULL#', '1', '#NULL#', '#NULL#', '120', 'vPEPSICO_BonusVerification_MassUpload_Actions', 'action', 'action', 'Approve', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', 'Approve', '1', '0', 'GV_SingleCombo', '#NULL#', '0', '0', '0')
	) s ( rn, ref_name_grid, ref_name_field, name_column, order_column, is_editable, regular_expression, is_sortable, error_message, url, width, combo_datasource_name, combo_datavaluefield_name, combo_datatextfield_name, combo_defaultfield_value, combo_page_size, combo_filtered_column_name, combo_filtered_pattern, combo_allow_custom_text, group_index, is_frozen, thousand_separator, decimal_precision, filter_field, sort_order, column_align, is_flex_used, flex, id_source_tenant, id_source, id_change_set, is_mandatory, defaultfield_value, sort_direction, is_percentage_used, ref_name_combo_type, combo_dataparentvaluefield_name, is_bulk_apply_used, enable_row_validation, is_uid_reference) ;


	exec [dbo].[_sp_sync_k_referential_grids_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules                                                             */
	/* SCRIPT GENERATION TIME:     2026-10-26 00:00:00.                                                  */
	/* USER:                       krystian.kawa@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Bonus Validation Status Mass Upload                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'AC_Grids', 'Bonus Validation Status Mass Upload', '-6', 'Bonus Validation Status Mass Upload', '0', '#NULL#', '#NULL#', '#NULL#', '0', 'grid')
	) s ( rn, ref_parent_name_module, name_module, id_tab, ref_name_object, order_module, id_source_tenant, id_source, id_change_set, show_in_accordion, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules_rights                                                      */
	/* SCRIPT GENERATION TIME:     2026-10-26 00:00:00.                                                  */
	/* USER:                       krystian.kawa@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Bonus Validation Status Mass Upload                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Validation Status Mass Upload', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('2', 'Bonus Validation Status Mass Upload', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('3', 'Bonus Validation Status Mass Upload', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('4', 'Bonus Validation Status Mass Upload', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('5', 'Bonus Validation Status Mass Upload', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('6', 'Bonus Validation Status Mass Upload', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('7', 'Bonus Validation Status Mass Upload', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('8', 'Bonus Validation Status Mass Upload', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('9', 'Bonus Validation Status Mass Upload', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('10', 'Bonus Validation Status Mass Upload', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('11', 'Bonus Validation Status Mass Upload', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('12', 'Bonus Validation Status Mass Upload', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'grid')
	) s ( rn, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_rights_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_profiles_modules_rights                                             */
	/* SCRIPT GENERATION TIME:     2026-10-26 00:00:00.                                                  */
	/* USER:                       krystian.kawa@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Bonus Validation Status Mass Upload                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('2', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('3', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('4', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('5', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('6', 'Administrator', 'Bonus Validation Status Mass Upload', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('7', 'Comp Admin', 'Bonus Validation Status Mass Upload', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('8', 'Comp Admin', 'Bonus Validation Status Mass Upload', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('9', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('10', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('11', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('12', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('13', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('14', 'Super User', 'Bonus Validation Status Mass Upload', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('15', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('16', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('17', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('18', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('19', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('20', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('21', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('22', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('23', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('24', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('25', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
, 	('26', 'Tech Admin', 'Bonus Validation Status Mass Upload', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Bonus Validation Status Mass Upload')
	) s ( rn, ref_name_profile, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, start_date, end_date, ref_name_module_type, ref_name_module) ;


	exec [dbo].[_sp_sync_k_profiles_modules_rights_data_merge];

	GO
