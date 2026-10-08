







CREATE FUNCTION [dbo].[_fn_get_bonus_team]
	(

	@idCompGroup INT,
	@Step1 NVARCHAR(255),
	@Step2 NVARCHAR(255),
	@Step3 NVARCHAR(255)
	)
RETURNS NVARCHAR(MAX)
AS
BEGIN

/*

History:
20251013	Danuta Lemma	Remove "100%" from final team name
20251126	Danuta Lemma	Added IB CompGroup logic
20251127	Danuta Lemma	Added ICC CompGroup logic
20261008	Tymoteusz Kruk	Added @Step3 parameter (bonus_team_step_3 name); not used in the team-name logic yet

	--possible options
	DECLARE @idCompGroup INT = 78 --36 -- 65 -- 77 --78 
	DECLARE @Step1 NVARCHAR(255) = 'region1'; --NULL
	DECLARE @Step2 NVARCHAR(255) = 'region2'; --NULL 

	--example runs
	SELECT [dbo].[_fn_get_bonus_team] (36, 'Region1', 'Region2', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (77, 'XYZRegion3', 'ABCRegion4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (65, 'Region1', NULL, NULL)
	SELECT [dbo].[_fn_get_bonus_team] (40, 'Region1', 'Region2', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (87, 'Region1', NULL, NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, 'Region1', 'Region2', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, NULL, 'Region2', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, 'Corporate', 'Corporate', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, 'Region3', 'Region4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, 'Region4', 'Region3', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, 'Region4', NULL, NULL)
	SELECT [dbo].[_fn_get_bonus_team] (15, NULL, 'region4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (40, 'Corporate', NULL, NULL)
	SELECT [dbo].[_fn_get_bonus_team] (40, 'Region3', 'Region4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (77, 'XYZRegion3', 'ABCRegion4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (78, 'XYZRegion3', 'ABCRegion4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (78, 'abc', 'ABCRegion4', NULL)
	SELECT [dbo].[_fn_get_bonus_team] (78, 'zbc', NULL, NULL)
	SELECT [dbo].[_fn_get_bonus_team] (78, 'zbc', 'Nothing', NULL)
*/	



	DECLARE @corporate NVARCHAR(10)		= 'Corporate'
	,		@75_pct NVARCHAR(4)			= '75%'
	,		@62_5_pct NVARCHAR(5)		= '62.5%'
	,		@50_pct NVARCHAR(4)			= '50%'
	,		@37_5_pct NVARCHAR(5)		= '37.5%'
	,		@25_pct NVARCHAR(4)			= '25%'
	,		@spc NVARCHAR(1)			= ' '
	,		@spc_slh_spc NVARCHAR(3)	= ' / '
	,		@final_bonus_team NVARCHAR(max)

	DECLARE @RD NVARCHAR(25) = 'Global R&D';
	DECLARE @ST NVARCHAR(25) = 'Global S&T';
	DECLARE @IB NVARCHAR(25) = 'International Beverages';
	DECLARE @ICC NVARCHAR(3) = 'ICC'
	
	DECLARE @RD_id INT = (SELECT DISTINCT idCompGroup FROM PEPSICO_CompGroup WHERE CompGroupName = @RD);
	DECLARE @ST_id INT = (SELECT DISTINCT idCompGroup FROM PEPSICO_CompGroup WHERE CompGroupName = @ST);
	DECLARE @IB_id INT = (SELECT DISTINCT idCompGroup FROM PEPSICO_CompGroup WHERE CompGroupName = @IB);
	DECLARE @ICC_id INT = (SELECT DISTINCT idCompGroup FROM PEPSICO_CompGroup WHERE CompGroupName = @ICC);


	IF @Step1 IS NULL
	BEGIN
		SET @final_bonus_team = NULL
	END



----------------------------------------------------------------


	IF @idCompGroup = @RD_id OR @idCompGroup = @ST_id OR @idCompGroup = @ICC_id
	BEGIN
		SET @final_bonus_team = 
			CASE 
				WHEN @Step2 IS NULL AND @Step1 = @Corporate				
					THEN @Corporate																											--1
				WHEN @Step2 IS NULL AND @Step1 != @Corporate			
					THEN @Step1 + @spc + @75_pct + @spc_slh_spc + @Corporate + @spc + @25_pct												--2
				WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 = @Corporate AND @Step2 = @Corporate) 
					THEN @Corporate																											--3
				WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND @Step1 = @Corporate 
					THEN @Step2 + @spc + @37_5_pct + @spc_slh_spc + @Corporate + @spc + @62_5_pct											--4
				WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND @Step2 = @Corporate 
					THEN @Step1 + @spc + @37_5_pct + @spc_slh_spc + @Corporate + @spc + @62_5_pct											--5
				WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 != @Corporate AND @Step2 != @Corporate) AND @Step1 < @Step2
					THEN @Step1 + @spc + @37_5_pct + @spc_slh_spc + @Step2 +  @spc + @37_5_pct + @spc_slh_spc + @Corporate + @spc + @25_pct	--6
				WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 != @Corporate AND @Step2 != @Corporate) AND @Step1 > @Step2
					THEN @Step2 + @spc + @37_5_pct + @spc_slh_spc + @Step1 +  @spc + @37_5_pct + @spc_slh_spc + @Corporate + @spc + @25_pct	--7
				WHEN @Step1 = @Step2 AND @Step1 != @Corporate
					THEN @Step1 + @spc + @75_pct + @spc_slh_spc + @Corporate + @spc + @25_pct												--8
			END

	END


--------------------------------------------------------------------------------------------------------------


	IF @idCompGroup = @IB_id
	BEGIN
		SET @final_bonus_team = 
		CASE 
			WHEN @Step2 IS NULL AND @Step1 = @IB				
				THEN @IB																											--1
			WHEN @Step2 IS NULL AND @Step1 != @IB			
				THEN @Step1 + @spc + @75_pct + @spc_slh_spc + @IB + @spc + @25_pct												--2
			WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 = @IB AND @Step2 = @IB) 
				THEN @IB																											--3
			WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND @Step1 = @IB 
				THEN @Step2 + @spc + @37_5_pct + @spc_slh_spc + @IB + @spc + @62_5_pct											--4
			WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND @Step2 = @IB 
				THEN @Step1 + @spc + @37_5_pct + @spc_slh_spc + @IB + @spc + @62_5_pct											--5
			WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 != @IB AND @Step2 != @IB) AND @Step1 < @Step2
				THEN @Step1 + @spc + @37_5_pct + @spc_slh_spc + @Step2 +  @spc + @37_5_pct + @spc_slh_spc + @IB + @spc + @25_pct	--6
			WHEN (@Step1 IS NOT NULL AND @Step2 IS NOT NULL) AND (@Step1 != @IB AND @Step2 != @IB) AND @Step1 > @Step2
				THEN @Step2 + @spc + @37_5_pct + @spc_slh_spc + @Step1 +  @spc + @37_5_pct + @spc_slh_spc + @IB + @spc + @25_pct	--7
			WHEN @Step1 = @Step2 AND @Step1 != @IB
				THEN @Step1 + @spc + @75_pct + @spc_slh_spc + @IB + @spc + @25_pct												--8
		END
	END



	IF (@idCompGroup != @ST_id AND @idCompGroup != @RD_id AND @idCompGroup != @IB_id AND @idCompGroup != @ICC_id)
	BEGIN
		IF @Step2 IS NULL
			BEGIN
				SET @final_bonus_team = @Step1
			END
		IF @Step2 IS NOT NULL 
			IF @step1 < @step2 
			BEGIN
				SET @final_bonus_team = @Step1 + @spc + @50_pct + @spc_slh_spc + @Step2 + @spc + @50_pct
			END
			ELSE 
			BEGIN
				SET @final_bonus_team = @Step2 + @spc + @50_pct + @spc_slh_spc + @Step1 + @spc + @50_pct
			END
	END


	RETURN @final_bonus_team

END
GO
