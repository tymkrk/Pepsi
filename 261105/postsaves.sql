





CREATE PROCEDURE [dbo].[SP_Grid_Save_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate]
	(
	@UniqueKey NVARCHAR(MAX)
	, @idUser INT
	, @idProfile INT
	, @primaryKey INT
	)
AS
BEGIN
/****************************************************************************************************
Purpose: Return failure / message if month overlaps found

Note:
	- Call to this procedure is set from Advanced tab of Grid Editor.

History:
	(0) 2018-04-27 /Sandip Keni/ Created
	(1) 2025-09-19 /Danuta Lemma/ Change target table to PEPSICO_OvrdBonusTeam_ProcessUpdate
	(2) 2026-10-12 /Bartosz Ryżak/ PEPPRT26-117 Reject a grid row that overlaps a MyTeam Bonus process Bonus Team Override (dbo.SP_OvrdBonusTeam_OverlapCheck)
	(3) 2026-10-16 /Bartosz Ryżak/ PEPPRTCR25-79 BT-GAP-07 GPID / StartDate change: Final row of the old GPID / StartDate marked for deletion (dbo.SP_MergeOvrdBonusTeamProcess @mark_old_key = 1)
		; parameter list in brackets, data types uppercase
	(4) 2026-10-16 /Bartosz Ryżak/ PEPPRT26-117 overlap rejection (2) removed; a material HR Override takes priority over overlapping manager Final rows in its period; the merge (3) detects a real change and removes the MyTeam Bonus rows of the period, new parameter @is_grid_add
		; comment 'Bonus Process' rejected (reserved for MyTeam Bonus rows)
		; old values for the Save Post written by the merge to dbo.grid_data_temp_values (Process_Type 'PEP')
	(5) 2026-10-22 /Michal Czarnecki/ PEPPRTCR25-76 require Override Bonus Team or Create New Team Named

	(6) 2026-11-05 /Tymoteusz Kruk/ Require exactly one of Override Bonus Team and Create New Team Named

****************************************************************************************************/
	DECLARE @TableName varchar(200) = 'PEPSICO_OvrdBonusTeam_ProcessUpdate'
	DECLARE @IdentityColumn varchar(200) = 'idOvrdBonusTeam'
	DECLARE @OverlapCheckColumn varchar(200) = 'GPID'
	DECLARE @StartDateColumn varchar(200) = 'StartDate'
	DECLARE @EndDateColumn varchar(200) = 'EndDate'
	DECLARE @OverlapCheckColumnLabel varchar(200) = 'GPID'
	DECLARE @StartDateColumnLabel varchar(200) = 'Start Month'
	DECLARE @EndDateColumnLabel varchar(200) = 'End Month'

	DECLARE @ResultStatus bit = 1
	DECLARE @ResultMessage nvarchar(max) = ''
	DECLARE @procedure_name NVARCHAR(255) = OBJECT_NAME(@@PROCID) --(4)
	DECLARE @null_value NVARCHAR(10) = N'_null_' --(5)

	EXEC SP_Grid_AddSave_DateOverlapCheck @UniqueKey ,@primaryKey
		,@TableName ,@IdentityColumn ,@OverlapCheckColumn ,@StartDateColumn ,@EndDateColumn
		,@OverlapCheckColumnLabel ,@StartDateColumnLabel ,@EndDateColumnLabel
		,@ResultMessage OUTPUT

	--(6) Require exactly one populated team field after applying pending changes.
	IF @ResultMessage = N''
		AND NOT EXISTS
			(
			SELECT
				1
			FROM
				dbo.PEPSICO_OvrdBonusTeam_ProcessUpdate AS pu
			CROSS JOIN
				(
				SELECT
					MAX(CASE WHEN gdtv.Column_Name = N'idBonusTeam' THEN gdtv.Column_Value END) AS idBonusTeam
					, MAX(CASE WHEN gdtv.Column_Name = N'NewTeamName' THEN gdtv.Column_Value END) AS NewTeamName
				FROM
					dbo.grid_data_temp_values AS gdtv
				WHERE 1 = 1
					AND gdtv.Unique_Key = @UniqueKey
					AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
					AND gdtv.Process_Type = N'UPD'
				) AS b
			WHERE 1 = 1
				AND pu.idOvrdBonusTeam = @primaryKey
				AND
					(
					CASE WHEN CASE WHEN b.idBonusTeam = @null_value THEN NULL ELSE COALESCE(TRY_CONVERT(INT, b.idBonusTeam), pu.idBonusTeam) END IS NOT NULL THEN 1 ELSE 0 END
					+ CASE WHEN CASE WHEN b.NewTeamName = @null_value THEN NULL ELSE NULLIF(LTRIM(RTRIM(COALESCE(b.NewTeamName, pu.NewTeamName))), N'') END IS NOT NULL THEN 1 ELSE 0 END = 1
					)
			)
	BEGIN
		SET @ResultMessage = N'Exactly one of Override Bonus Team or Create New Team Named must be provided.';
	END;

	--(4)
	/**
	the comment 'Bonus Process' marks MyTeam Bonus rows in Final, an HR row must not carry it
	**/
	IF @ResultMessage = N''
		AND EXISTS
			(
			SELECT 1
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Column_Name = N'Comments'
				AND LTRIM(RTRIM(gdtv.Column_Value)) = N'Bonus Process'
			)
	BEGIN
		SET @ResultMessage = N'Comment "Bonus Process" is reserved for MyTeam Bonus changes. Please use a different comment.';
		PRINT CONCAT(CONVERT(VARCHAR(25), GETUTCDATE(), 121), ' ', @procedure_name, ' -- comment Bonus Process rejected');
	---------- 
	END;

	--(3)
	/**
	no overlap: the stored row still has the old values; a real change removes the MyTeam Bonus rows of the new period, a GPID change rebuilds the old GPID --(4)
	!!! ATTENTION: NEEDED IN THE SAVE POST !!! the merge also writes the real-change flag and the old GPID / StartDate / EndDate to dbo.grid_data_temp_values (Process_Type 'PEP');
	dbo.SP_Grid_Save_Post_PEPSICO_OvrdBonusTeam_ProcessUpdate reads them (the row is already updated there): Bonus Team Review cleared only on a real change, new and old period --(4)
	**/
	IF @ResultMessage = N''
	BEGIN
		EXEC dbo.SP_MergeOvrdBonusTeamProcess
			@primaryKey = @primaryKey
			, @UniqueKey = @UniqueKey
			, @is_grid_add = 0 --(4)
			, @is_grid_delete = 0
			, @mark_old_key = 1
			, @result_message = @ResultMessage OUTPUT
		;
		PRINT '-- AFTER dbo.SP_MergeOvrdBonusTeamProcess';
	---------- 
	END;

	IF @ResultMessage <> '' --overlaps found
	BEGIN
		SET @ResultStatus = 0 --failure
	END

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
END
GO


CREATE PROCEDURE [dbo].[SP_Grid_Add_Pre_PEPSICO_OvrdBonusTeam_ProcessUpdate]
	(
	@UniqueKey nvarchar(max)
	,@idUser int
	,@idProfile int
	,@primaryKey int
	)
AS
BEGIN
/****************************************************************************************************
Purpose: Return failure / message if month overlaps found

History:
	(0) 20180427		Sandip Keni			Created
	(1) 20250919		Danuta Lemma		Change target table to PEPSICO_OvrdBonusTeam_ProcessUpdate
	(2) 2026-10-12 /Bartosz Ryżak/ PEPPRT26-117 Reject a grid row that overlaps a MyTeam Bonus process Bonus Team Override (dbo.SP_OvrdBonusTeam_OverlapCheck)
	(3) 2026-10-16 /Bartosz Ryżak/ PEPPRT26-117 overlap rejection (2) removed; a material HR Override takes priority over overlapping manager Final rows in its period through dbo.SP_MergeOvrdBonusTeamProcess; comment 'Bonus Process' rejected (reserved for MyTeam Bonus rows)
	(4) 2026-10-22 /Michal Czarnecki/ PEPPRTCR25-76 require Override Bonus Team or Create New Team Named

	(5) 2026-11-05 /Tymoteusz Kruk/ Require exactly one of Override Bonus Team and Create New Team Named

****************************************************************************************************/
	DECLARE @TableName varchar(200) = 'PEPSICO_OvrdBonusTeam_ProcessUpdate'
	DECLARE @IdentityColumn varchar(200) = 'idOvrdBonusTeam'
	DECLARE @OverlapCheckColumn varchar(200) = 'GPID'
	DECLARE @StartDateColumn varchar(200) = 'StartDate'
	DECLARE @EndDateColumn varchar(200) = 'EndDate'
	DECLARE @OverlapCheckColumnLabel varchar(200) = 'GPID'
	DECLARE @StartDateColumnLabel varchar(200) = 'Start Month'
	DECLARE @EndDateColumnLabel varchar(200) = 'End Month'

	DECLARE @ResultStatus bit = 1
	DECLARE @ResultMessage nvarchar(max) = ''
	DECLARE @procedure_name NVARCHAR(255) = OBJECT_NAME(@@PROCID) --(3)

	EXEC SP_Grid_AddSave_DateOverlapCheck @UniqueKey ,@primaryKey
		,@TableName ,@IdentityColumn ,@OverlapCheckColumn ,@StartDateColumn ,@EndDateColumn
		,@OverlapCheckColumnLabel ,@StartDateColumnLabel ,@EndDateColumnLabel
		,@ResultMessage OUTPUT

	--(5) Require exactly one populated team field.
	IF @ResultMessage = N''
		AND (
			SELECT
				COUNT(DISTINCT gdtv.Column_Name)
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Process_Type = N'ADD'
				AND gdtv.Column_Name IN (N'idBonusTeam', N'NewTeamName')
				AND NULLIF(LTRIM(RTRIM(gdtv.Column_Value)), N'') IS NOT NULL
				AND gdtv.Column_Value <> N'_null_'
			) <> 1
	BEGIN
		SET @ResultMessage = N'Exactly one of Override Bonus Team or Create New Team Named must be provided.';
	END;

	--(3)
	/**
	the comment 'Bonus Process' marks MyTeam Bonus rows in Final, an HR row must not carry it
	**/
	IF @ResultMessage = N''
		AND EXISTS
			(
			SELECT 1
			FROM
				dbo.grid_data_temp_values AS gdtv
			WHERE 1 = 1
				AND gdtv.Unique_Key = @UniqueKey
				AND gdtv.PK_Id = CAST(@primaryKey AS NVARCHAR(50))
				AND gdtv.Column_Name = N'Comments'
				AND LTRIM(RTRIM(gdtv.Column_Value)) = N'Bonus Process'
			)
	BEGIN
		SET @ResultMessage = N'Comment "Bonus Process" is reserved for MyTeam Bonus changes. Please use a different comment.';
		PRINT CONCAT(CONVERT(VARCHAR(25), GETUTCDATE(), 121), ' ', @procedure_name, ' -- comment Bonus Process rejected');
	---------- 
	END;

	IF @ResultMessage <> '' --overlaps found
	BEGIN
		SET @ResultStatus = 0 --failure
	END

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage
END
GO
