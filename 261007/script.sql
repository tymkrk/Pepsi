
declare @now datetime = getutcdate()
declare @plan_id int = (select top 1 id_plan from k_m_plans where name_plan like 'Bonus')
declare @template_id int = 
	(select top 1 id_base_grid from k_m_type_plan where id_type_plan =
		(select top 1 id_type_plan from k_m_plans where id_plan = @plan_id))
declare @indicator_name nvarchar(100) = 'pr_ind_bonus_team' 
declare @id_ind int = (select top 1 id_ind from k_m_indicators where name_ind = @indicator_name)


insert into k_m_fields
(name_field,label_field,code_field,width,id_unit,id_field_type,id_control_type,type_value,is_olap,date_create_field,show_min,show_max,thousand_separator,decimal_precision,id_access_type,is_percentage_used,show_aggregated_result,threshold_min_value,threshold_max_value,is_threshold_enabled,show_only_aggregated_result ,aggregation_type)
select
	'Bonus Team Step 3','pr_col_bonus_team_step_3','bonus_team_step_3',194,-3,-3,-7,1,0,@now,1,1,0,0,-1,0,0,-1,0,0,0,1

declare @id_ind_field_3 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_3')
declare @id_ind_field_2 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_2')
declare @sort_ind_field_2 int = (select top 1 sort from k_m_indicators_fields where id_field = @id_ind_field_2)
declare @sort_ind int =  (select top 1 sort_plan_ind from k_m_plans_indicators where id_ind = @id_ind)

update k_m_indicators_fields
set sort = sort + 1
where id_ind = 21
and sort > @sort_ind_field_2

update k_m_plans_informations
set sort = sort + 1
where sort > @sort_ind
	and id_plan = @plan_id

update k_m_plans_indicators
set sort_plan_ind = sort_plan_ind + 1
where sort_plan_ind > @sort_ind
	and id_plan = @plan_id

insert into k_m_indicators_fields
(id_ind
,id_field
,sort)
select @id_ind, @id_ind_field_3, @id_ind_field_2 + 1


insert into k_m_plan_display_field 
	(id_plan_display
	,id_indicator_field
	,available_plan_display_field
	,show_plan_display_field
	,optional_show_plan_display_field
	)
select 
	pd.id_plan_display
	,fi.id_indicator_field
	,1,1,1
from k_m_plan_display pd 
join k_profiles pr
	on pr.id_profile = pd.id_profile
	and pd.id_plan = @plan_id
	and pr.name_profile in 
	(
	'Administrator'
	,'Manager'
	,'Manager LG8'
	,'Human Resource'
	,'Human Resources LG8'
	,'Comp Admin'
	,'Super User'
	) 
join k_m_indicators_fields fi 
	on fi.id_field in (@id_ind_field_3)

--rollback



GO

insert into k_m_workflow_step_group_detail
	(id_wflstepgroup
	,id_field
	,is_editable
	,id_ind
	,is_readable)
select 
	id_wflstepgroup
	,(select top 1 id_field from k_m_fields where name_field = 'Bonus Team Step 3')
	,is_editable
	,id_ind
	,is_readable
from k_m_workflow_step_group_detail
where id_field = (select top 1 id_field from k_m_fields where name_field = 'Bonus Team Step 1')


GO
/******************************************************************************
Purpose: Configure the Bonus process field bonus_team_step_3 as a cascading
         drop-down sourced from dbo.vPEPSICO_bonus_team_step3_business:
           - filtered by the Comp Group of the process row,
           - excluding the Business selected in bonus_team_step_1,
           - excluding the Business selected in bonus_team_step_2.
         Idempotent: all ids are resolved by name, relations are re-created.
Prereqs: - dbo.vPEPSICO_bonus_team_step3_business deployed,
         - field bonus_team_step_3 exists in the Bonus process (pr_ind_bonus_team),
         - bonus_team_step_1 already has its Comp Group relation (IC_ column).
******************************************************************************/

/* Register the view and its columns in k_referential_tables_views(_fields) */
EXEC sp_client_std_synchronize 'vPEPSICO_bonus_team_step3_business', 'view', 0;
GO


SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    DECLARE
        @id_plan                INT
    ,   @id_ind                 INT
    ,   @id_field_step_1        INT
    ,   @id_field_step_2        INT
    ,   @id_field_step_3        INT
    ,   @id_control_type        INT
    ,   @id_table_view          INT
    ,   @id_tv_code             INT
    ,   @id_tv_value            INT
    ,   @id_tv_comp_group       INT
    ,   @id_tv_filter_1         INT
    ,   @id_tv_filter_2         INT
    ,   @alias_step_1           NVARCHAR(255)
    ,   @alias_step_2           NVARCHAR(255)
    ,   @alias_step_3           NVARCHAR(255)
    ,   @parent_comp_group      NVARCHAR(255);

    SELECT @id_plan = id_plan
    FROM dbo.k_m_plans
    WHERE name_plan = 'Bonus';

    SELECT @id_ind = id_ind
    FROM dbo.k_m_indicators
    WHERE name_ind = 'pr_ind_bonus_team';

    SELECT
        @id_field_step_1 = MAX(CASE WHEN code_field = 'bonus_team_step_1' THEN id_field END)
    ,   @id_field_step_2 = MAX(CASE WHEN code_field = 'bonus_team_step_2' THEN id_field END)
    ,   @id_field_step_3 = MAX(CASE WHEN code_field = 'bonus_team_step_3' THEN id_field END)
    ,   @id_control_type = MAX(CASE WHEN code_field = 'bonus_team_step_1' THEN id_control_type END)
    FROM dbo.k_m_fields
    WHERE code_field IN ('bonus_team_step_1', 'bonus_team_step_2', 'bonus_team_step_3');

    SELECT @id_table_view = id_table_view
    FROM dbo.k_referential_tables_views
    WHERE name_table_view = 'vPEPSICO_bonus_team_step3_business';

    SELECT
        @id_tv_code         = MAX(CASE WHEN name_field = 'BTBusinessCode'      THEN id_field END)
    ,   @id_tv_value        = MAX(CASE WHEN name_field = 'BTBusinessValue'     THEN id_field END)
    ,   @id_tv_comp_group   = MAX(CASE WHEN name_field = 'idCompGroup'         THEN id_field END)
    ,   @id_tv_filter_1     = MAX(CASE WHEN name_field = 'BTBusiness_filter_1' THEN id_field END)
    ,   @id_tv_filter_2     = MAX(CASE WHEN name_field = 'BTBusiness_filter_2' THEN id_field END)
    FROM dbo.k_referential_tables_views_fields
    WHERE id_table_view = @id_table_view;

    IF @id_plan IS NULL OR @id_ind IS NULL
        THROW 50001, 'Bonus plan or indicator pr_ind_bonus_team not found.', 1;

    IF @id_field_step_1 IS NULL OR @id_field_step_2 IS NULL OR @id_field_step_3 IS NULL
        THROW 50002, 'Field bonus_team_step_1, bonus_team_step_2 or bonus_team_step_3 not found in k_m_fields.', 1;

    IF @id_tv_code IS NULL OR @id_tv_value IS NULL OR @id_tv_comp_group IS NULL
        OR @id_tv_filter_1 IS NULL OR @id_tv_filter_2 IS NULL
        THROW 50003, 'vPEPSICO_bonus_team_step3_business is not registered or misses columns.', 1;

    /* Field alias format used by process metadata: <id_plan>_<id_ind>_<id_field> */
    SET @alias_step_1 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_1);
    SET @alias_step_2 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_2);
    SET @alias_step_3 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_3);

    /* Reuse the Comp Group parent (IC_<id_column> of Bonus Verification grid) already used by Step 1 */
    SELECT TOP (1) @parent_comp_group = id_parent_field
    FROM dbo.k_m_fields_relation
    WHERE id_plan = @id_plan
        AND id_field = @alias_step_1
        AND id_parent_field LIKE 'IC[_]%'
    ORDER BY id_field_relation DESC;

    IF @parent_comp_group IS NULL
        THROW 50004, 'Comp Group relation for bonus_team_step_1 not found in k_m_fields_relation.', 1;

    BEGIN TRANSACTION;

        UPDATE dbo.k_m_fields
        SET id_control_type     = @id_control_type
        ,   combo_table_view    = @id_table_view
        ,   combo_value_field   = @id_tv_code
        ,   combo_text_field    = @id_tv_value
        WHERE id_field = @id_field_step_3;

        DELETE FROM dbo.k_m_fields_relation
        WHERE id_plan = @id_plan
            AND id_field = @alias_step_3;

        INSERT INTO dbo.k_m_fields_relation (id_plan, id_field, id_parent_field, id_field_table_view)
        VALUES
            (@id_plan, @alias_step_3, @parent_comp_group, @id_tv_comp_group)
        ,   (@id_plan, @alias_step_3, @alias_step_1,      @id_tv_filter_1)
        ,   (@id_plan, @alias_step_3, @alias_step_2,      @id_tv_filter_2);

    COMMIT TRANSACTION;

    PRINT CONCAT('bonus_team_step_3 drop-down configured: field ', @alias_step_3
        , ', table view ', @id_table_view, ', Comp Group parent ', @parent_comp_group, '.');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

declare @id_step_3 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_3')
declare @id_step_1 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_1')
declare @id_ind int = (select top 1 id_ind from k_m_indicators where name_ind = 'pr_ind_bonus_team')
declare @id_ind_field_step_1 int = (select TOP 1 id_indicator_field from k_m_indicators_fields where id_field = @id_step_1 and id_ind = @id_ind)
declare @id_ind_field_step_3 int = (select TOP 1 id_indicator_field from k_m_indicators_fields where id_field = @id_step_3 and id_ind = @id_ind)


insert into [k_m_plans_field_validation]
	(id_plan
	,id_indicator_field
	,id_planInfo
	,formula
	,action_false_allow_saving
	,action_false_show_error
	,action_false_error_message
	,action_false_use_field_style
	,action_false_text_color
	,action_false_border_color
	,action_false_background_color
	,action_true_use_field_style
	,action_true_text_color
	,action_true_border_color
	,action_true_background_color
	,id_plan_indicator
	,action_false_show_error_on_change
	,enable_client_side_validation
	,action_false_allow_editing)
select 
	id_plan
	,@id_ind_field_step_3
	,id_planInfo
	,formula
	,action_false_allow_saving
	,action_false_show_error
	,action_false_error_message
	,action_false_use_field_style
	,action_false_text_color
	,action_false_border_color
	,action_false_background_color
	,action_true_use_field_style
	,action_true_text_color
	,action_true_border_color
	,action_true_background_color
	,id_plan_indicator
	,action_false_show_error_on_change
	,enable_client_side_validation
	,action_false_allow_editing
from [dbo].[k_m_plans_field_validation] WHERE id_indicator_field =  @id_ind_field_step_1
