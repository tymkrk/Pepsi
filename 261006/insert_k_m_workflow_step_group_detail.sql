/******************************************************************************
Purpose: Make the Bonus process field bonus_team_step_3 readable/editable in
         workflow step groups by adding it to k_m_workflow_step_group_detail.
         Rights are copied from bonus_team_step_2 for every step group where
         Step 2 is configured (WFL_Bonus Verification / pr_wfs_approval).
         Idempotent: existing Step 3 rows are aligned, missing ones inserted.
Prereqs: field bonus_team_step_3 exists in k_m_fields and is attached to
         indicator pr_ind_bonus_team.
******************************************************************************/
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    DECLARE
        @id_ind             INT
    ,   @id_field_step_2    INT
    ,   @id_field_step_3    INT
    ,   @rows_updated       INT
    ,   @rows_inserted      INT;

    SELECT @id_ind = id_ind
    FROM dbo.k_m_indicators
    WHERE name_ind = 'pr_ind_bonus_team';

    SELECT
        @id_field_step_2 = MAX(CASE WHEN code_field = 'bonus_team_step_2' THEN id_field END)
    ,   @id_field_step_3 = MAX(CASE WHEN code_field = 'bonus_team_step_3' THEN id_field END)
    FROM dbo.k_m_fields
    WHERE code_field IN ('bonus_team_step_2', 'bonus_team_step_3');

    IF @id_ind IS NULL
        THROW 50001, 'Indicator pr_ind_bonus_team not found.', 1;

    IF @id_field_step_2 IS NULL OR @id_field_step_3 IS NULL
        THROW 50002, 'Field bonus_team_step_2 or bonus_team_step_3 not found in k_m_fields.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.k_m_indicators_fields
        WHERE id_ind = @id_ind
            AND id_field = @id_field_step_3
    )
        THROW 50003, 'Field bonus_team_step_3 is not attached to indicator pr_ind_bonus_team.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.k_m_workflow_step_group_detail
        WHERE id_field = @id_field_step_2
            AND id_ind = @id_ind
    )
        THROW 50004, 'No workflow step group detail found for bonus_team_step_2 to copy from.', 1;

    BEGIN TRANSACTION;

        UPDATE s3
        SET s3.is_editable = s2.is_editable
        ,   s3.is_readable = s2.is_readable
        FROM dbo.k_m_workflow_step_group_detail AS s3
        INNER JOIN dbo.k_m_workflow_step_group_detail AS s2
            ON s2.id_wflstepgroup = s3.id_wflstepgroup
            AND s2.id_field = @id_field_step_2
            AND s2.id_ind = @id_ind
        WHERE s3.id_field = @id_field_step_3
            AND s3.id_ind = @id_ind
            AND (s3.is_editable <> s2.is_editable OR s3.is_readable <> s2.is_readable);

        SET @rows_updated = @@ROWCOUNT;

        INSERT INTO dbo.k_m_workflow_step_group_detail (id_wflstepgroup, id_field, is_editable, id_ind, is_readable)
        SELECT
            s2.id_wflstepgroup
        ,   @id_field_step_3
        ,   s2.is_editable
        ,   @id_ind
        ,   s2.is_readable
        FROM dbo.k_m_workflow_step_group_detail AS s2
        WHERE s2.id_field = @id_field_step_2
            AND s2.id_ind = @id_ind
            AND NOT EXISTS (
                SELECT 1
                FROM dbo.k_m_workflow_step_group_detail AS s3
                WHERE s3.id_wflstepgroup = s2.id_wflstepgroup
                    AND s3.id_field = @id_field_step_3
                    AND s3.id_ind = @id_ind
            );

        SET @rows_inserted = @@ROWCOUNT;

    COMMIT TRANSACTION;

    PRINT CONCAT('bonus_team_step_3 workflow step group detail: ', @rows_inserted, ' inserted, ', @rows_updated, ' updated.');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
