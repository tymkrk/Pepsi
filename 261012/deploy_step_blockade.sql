-- Step 2/3 client editability. Requires registered Step 3 metadata.
-- Retains the status/Double Hat condition from Step 1; rerunnable.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_plan INT = (SELECT idPlanBonusApproval FROM dbo.vPEPSICO_FocalPoint_Parameters);
    DECLARE @id_ind INT =
    (
        SELECT i.id_ind
        FROM dbo.k_m_indicators AS i
        INNER JOIN dbo.k_m_plans_indicators AS pi ON pi.id_ind = i.id_ind
        WHERE pi.id_plan = @id_plan AND i.comment_ind = N'bonus_team'
    );
    DECLARE @id_field_step_1 INT = (SELECT id_field FROM dbo.k_m_fields WHERE code_field = N'bonus_team_step_1');
    DECLARE @id_step_1 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_1'
    );
    DECLARE @id_step_2 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_2'
    );
    DECLARE @id_step_3 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_3'
    );
    DECLARE @north_america_code NVARCHAR(50) =
    (
        SELECT DISTINCT BTBusinessCode
        FROM dbo.vPEPSICO_bonus_team_step1_business
        WHERE BTBusinessValue = N'North America'
    );
    DECLARE @other_code NVARCHAR(50) =
    (
        SELECT DISTINCT BTBusinessCode
        FROM dbo.vPEPSICO_bonus_team_step1_business
        WHERE LTRIM(RTRIM(REPLACE(BTBusinessValue, NCHAR(160), N' '))) = N'Other'
    );

    IF @id_plan IS NULL OR @id_ind IS NULL OR @id_step_1 IS NULL
        OR @id_step_2 IS NULL OR @id_step_3 IS NULL
        OR @id_field_step_1 IS NULL OR @north_america_code IS NULL OR @other_code IS NULL
        THROW 50001, 'Missing Bonus metadata or North America/Other codes in the Step 1 dropdown.', 1;

    IF (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_1) <> 1
        OR (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
            WHERE id_plan = @id_plan AND id_indicator_field = @id_step_2) <> 1
        THROW 50002, 'Expected exactly one existing validation for Step 1 and Step 2.', 1;

    IF (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_3) > 1
        THROW 50003, 'Multiple Step 3 validations exist; resolve duplicates first.', 1;

    DECLARE @base_formula NVARCHAR(MAX) =
    (
        SELECT formula FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_1
    );
    IF NULLIF(LTRIM(RTRIM(@base_formula)), N'') IS NULL
        THROW 50004, 'Step 1 validation formula is empty.', 1;

    IF CHARINDEX(NCHAR(39), @other_code) > 0 OR CHARINDEX(NCHAR(92), @other_code) > 0
        OR CHARINDEX(NCHAR(39), @north_america_code) > 0 OR CHARINDEX(NCHAR(92), @north_america_code) > 0
        THROW 50005, 'Dropdown code contains unsupported formula literal characters.', 1;

    -- Compare both excluded dropdown codes to the native [indicator_field] reference.
    -- The Step 1 selection contains BTBusinessCode, not its displayed name.
    DECLARE @formula NVARCHAR(MAX) = CONCAT(
        N'(', @base_formula, N')&&[', @id_ind, N'_', @id_field_step_1,
        N']!=', NCHAR(39), @other_code, NCHAR(39),
        N'&&[', @id_ind, N'_', @id_field_step_1, N']!=',
        NCHAR(39), @north_america_code, NCHAR(39));

    IF NOT EXISTS (SELECT 1 FROM dbo.k_m_plans_field_validation
                   WHERE id_plan = @id_plan AND id_indicator_field = @id_step_3)
    BEGIN
        INSERT INTO dbo.k_m_plans_field_validation
        (
            id_plan, id_indicator_field, id_planInfo, formula,
            action_false_allow_saving, action_false_show_error, action_false_error_message,
            action_false_use_field_style, action_false_text_color, action_false_border_color,
            action_false_background_color, action_true_use_field_style, action_true_text_color,
            action_true_border_color, action_true_background_color, id_plan_indicator,
            action_false_show_error_on_change, enable_client_side_validation, action_false_allow_editing
        )
        SELECT id_plan, @id_step_3, id_planInfo, formula,
               action_false_allow_saving, action_false_show_error, action_false_error_message,
               action_false_use_field_style, action_false_text_color, action_false_border_color,
               action_false_background_color, action_true_use_field_style, action_true_text_color,
               action_true_border_color, action_true_background_color, id_plan_indicator,
               action_false_show_error_on_change, enable_client_side_validation, action_false_allow_editing
        FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_2;
    END;

    -- Preserve existing action/style settings; change only formula and editability flags.
    UPDATE dbo.k_m_plans_field_validation
    SET formula = @formula,
        enable_client_side_validation = 1,
        action_false_allow_editing = 0
    WHERE id_plan = @id_plan AND id_indicator_field IN (@id_step_2, @id_step_3);

    COMMIT TRANSACTION;

    SELECT v.id_plans_field_validation, v.id_plan, f.code_field, v.formula,
           v.enable_client_side_validation, v.action_false_allow_editing
    FROM dbo.k_m_plans_field_validation AS v
    INNER JOIN dbo.k_m_indicators_fields AS inf ON inf.id_indicator_field = v.id_indicator_field
    INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
    WHERE v.id_plan = @id_plan AND v.id_indicator_field IN (@id_step_2, @id_step_3);
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
