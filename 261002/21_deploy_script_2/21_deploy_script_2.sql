/* =================================================================================================
   Sector Business Rule - one-shot deployment script (re-runnable)
   Prerequisite: dbo.vPEPSICO_sector_business_mapping_sector_lookup (created by deploy_sector_business_mapping.sql;
                 also re-created below so this script can run on its own)
   1. Table   dbo.PEPSICO_sector_business_rule            (created only if missing)
   2. Views   dbo.vPEPSICO_sector_business_mapping_sector_lookup
              dbo.vPEPSICO_business_split_rule_lookup
              dbo.vPEPSICO_number_of_businesses_lookup
   3. Proc    dbo.SP_Grid_Save_Post_PEPSICO_sector_business_rule
   4. Grid    'Sector Business Rule' (metadata, fields, module, rights)
   NOTE: grid folder (ref_name_folder) is still to be confirmed - see AI/notes_2026-10-02.md.
   ================================================================================================= */

SET NOCOUNT ON;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 1. TABLE                                                                                        */
/* ------------------------------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.PEPSICO_sector_business_rule', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[PEPSICO_sector_business_rule](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[id_sector] [int] NOT NULL,
		[id_rule] [int] NOT NULL,
		[number_of_businesses] [int] NOT NULL CONSTRAINT [CK_PEPSICO_sector_business_rule_number_of_businesses] CHECK ([number_of_businesses] BETWEEN 1 AND 3),
	 CONSTRAINT [PK_PEPSICO_sector_business_rule] PRIMARY KEY NONCLUSTERED 
	(
		[id] ASC
	)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

/* ------------------------------------------------------------------------------------------------- */
/* 2. LOOKUP VIEWS                                                                                 */
/* ------------------------------------------------------------------------------------------------- */
CREATE OR ALTER VIEW [dbo].[vPEPSICO_sector_business_mapping_sector_lookup]
AS

-- Sector dropdown for grid 'Sector Business Mapping'.
-- Temporary static list (to be replaced by a data-driven source when confirmed).
-- id_sector values are stored in dbo.PEPSICO_sector_business_mapping - never renumber existing entries.

	SELECT
		v.id_sector,
		CAST(v.sector_name AS VARCHAR(256)) AS sector_name,
		v.id_sector AS sort_order
	FROM
	(
		VALUES
			(1, 'North America'),
			(2, 'EMEA'),
			(3, 'APAC'),
			(4, 'LATAM'),
			(5, 'International Beverages'),
			(6, 'Global'),
			(7, 'Corporate')
	) AS v (id_sector, sector_name)
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_business_split_rule_lookup]
AS

-- Rule dropdown for grid 'Sector Business Rule'.
-- Temporary static list (to be replaced by a data-driven source when confirmed).
-- id_rule values are stored in dbo.PEPSICO_sector_business_rule - never renumber existing entries.

	SELECT
		v.id_rule,
		CAST(v.rule_name AS VARCHAR(256)) AS rule_name,
		v.id_rule AS sort_order
	FROM
	(
		VALUES
			(1, '50% 1st Bonus Team / 50% 2nd Bonus Team'),
			(2, '37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate'),
			(3, '75% OU / 25% Corporate'),
			(4, '75% Region / 25% Corporate'),
			(5, '100% APAC Foods Region'),
			(6, '100% LATAM Foods Region'),
			(7, '100% International Beverages'),
			(8, 'Corporate'),
			(9, '100% OU'),
			(10, '100% Region')
	) AS v (id_rule, rule_name)
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_number_of_businesses_lookup]
AS

-- Number of businesses dropdown for grid 'Sector Business Rule'.

	SELECT
		v.number_of_businesses,
		CAST(v.number_of_businesses AS VARCHAR(10)) AS number_of_businesses_label
	FROM
	(
		VALUES
			(1),
			(2),
			(3)
	) AS v (number_of_businesses)
GO

/* ------------------------------------------------------------------------------------------------- */
/* 3. GRID HOOK PROCEDURE                                                                          */
/* ------------------------------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Save_Post_PEPSICO_sector_business_rule]
	@UniqueKey NVARCHAR(MAX), @idUser INT, @idProfile INT, @primaryKey INT
AS
BEGIN
	-- Add/Save post hook for grid 'Sector Business Rule'.
	-- Blocks duplicate Sector + Number of Businesses combinations.

	SET NOCOUNT ON;

	DECLARE @ResultStatus BIT = 1, @ResultMessage NVARCHAR(255) = '';

	BEGIN TRY

		IF EXISTS
		(
			SELECT 1
			FROM dbo.PEPSICO_sector_business_rule AS cur
			INNER JOIN dbo.PEPSICO_sector_business_rule AS oth
				ON oth.id_sector = cur.id_sector
				AND oth.number_of_businesses = cur.number_of_businesses
				AND oth.id <> cur.id
			WHERE cur.id = @primaryKey
		)
		BEGIN
			SET @ResultStatus = 0;
			SET @ResultMessage = 'A rule for this Sector and Number of Businesses already exists.';
		END

	END TRY
	BEGIN CATCH
		SET @ResultStatus = 0;
		SET @ResultMessage = LEFT(ERROR_MESSAGE(), 255);
	END CATCH

	SELECT @ResultStatus AS ResultStatus, @ResultMessage AS ResultMessage;

END
GO

/* ------------------------------------------------------------------------------------------------- */
/* 4. GRID WRAPPER                                                                                 */
/* ------------------------------------------------------------------------------------------------- */
	/* ----------------------------------------------------------------------------- */
	/* GRID NAME: Sector Business Rule                                               */
	/* ----------------------------------------------------------------------------- */

	exec sp_client_std_synchronize 'PEPSICO_sector_business_rule', 'table', 0;
	GO
	exec sp_client_std_synchronize 'vPEPSICO_sector_business_mapping_sector_lookup', 'view', 0;
	GO
	exec sp_client_std_synchronize 'vPEPSICO_business_split_rule_lookup', 'view', 0;
	GO
	exec sp_client_std_synchronize 'vPEPSICO_number_of_businesses_lookup', 'view', 0;
	GO

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids                                                   */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Rule                                                  */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'PEPSICO_sector_business_rule', 'ND_Grid', 'Sector Business Rule', '-1', '#NULL#', '50', '1', '#NULL#', '#NULL#', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '0', '0', '-1', '0', '1', '16', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '', 'SP_Grid_Save_Post_PEPSICO_sector_business_rule', '', 'SP_Grid_Save_Post_PEPSICO_sector_business_rule', '', '', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '0', '1', '0', '#NULL#', '0', '0', '1', '1', '', '', '0')
	) s ( rn, ref_name_table_view, ref_name_folder, name_grid, type_grid, comments, page_size, is_addable, form_id, url, is_deletable, is_searchable, is_exportable, date_grid, grouping_field, frozen_column, active_trace, filtering_field, is_simulated, is_importable, idOwner, is_auto_resize, is_track_change, sort_grid, width, fit_to_screen, id_source_tenant, id_source, id_change_set, sp_grid_add_pre, sp_grid_add_post, sp_grid_save_pre, sp_grid_save_post, sp_grid_delete_pre, sp_grid_delete_post, is_bulk_insert, is_tree, master_id_table_view_field, child_id_table_view_field, parent_id_table_view_field, is_staging_area_enabled, is_export_template_enabled, show_default_security_view, use_attached_objects, tree_collapse_after_save, is_password_protection_enabled, apply_user_filter, wrap_header, header_tooltip, sp_grid_import_pre, sp_grid_import_post, allow_attached_file) ;


	exec [dbo].[_sp_sync_k_referential_grids_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids_fields                                            */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Rule                                                  */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Sector Business Rule', 'id_sector', 'Sector', '0', '1', '#NULL#', '1', '#NULL#', '#NULL#', '250', 'vPEPSICO_sector_business_mapping_sector_lookup', 'id_sector', 'sector_name', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
, 	('2', 'Sector Business Rule', 'id_rule', 'Rule', '1', '1', '#NULL#', '1', '#NULL#', '#NULL#', '400', 'vPEPSICO_business_split_rule_lookup', 'id_rule', 'rule_name', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
, 	('3', 'Sector Business Rule', 'number_of_businesses', 'Number of Businesses', '2', '1', '#NULL#', '1', '#NULL#', '#NULL#', '150', 'vPEPSICO_number_of_businesses_lookup', 'number_of_businesses', 'number_of_businesses_label', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
	) s ( rn, ref_name_grid, ref_name_field, name_column, order_column, is_editable, regular_expression, is_sortable, error_message, url, width, combo_datasource_name, combo_datavaluefield_name, combo_datatextfield_name, combo_defaultfield_value, combo_page_size, combo_filtered_column_name, combo_filtered_pattern, combo_allow_custom_text, group_index, is_frozen, thousand_separator, decimal_precision, filter_field, sort_order, column_align, is_flex_used, flex, id_source_tenant, id_source, id_change_set, is_mandatory, defaultfield_value, sort_direction, is_percentage_used, ref_name_combo_type, combo_dataparentvaluefield_name, is_bulk_apply_used, enable_row_validation, is_uid_reference) ;


	exec [dbo].[_sp_sync_k_referential_grids_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules                                                             */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Rule                                                  */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'AC_Grids', 'Sector Business Rule', '-6', 'Sector Business Rule', '0', '#NULL#', '#NULL#', '#NULL#', '0', 'grid')
	) s ( rn, ref_parent_name_module, name_module, id_tab, ref_name_object, order_module, id_source_tenant, id_source, id_change_set, show_in_accordion, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules_rights                                                      */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Rule                                                  */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Sector Business Rule', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('2', 'Sector Business Rule', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('3', 'Sector Business Rule', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('4', 'Sector Business Rule', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('5', 'Sector Business Rule', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('6', 'Sector Business Rule', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('7', 'Sector Business Rule', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('8', 'Sector Business Rule', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('9', 'Sector Business Rule', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('10', 'Sector Business Rule', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('11', 'Sector Business Rule', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('12', 'Sector Business Rule', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'grid')
	) s ( rn, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_rights_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_profiles_modules_rights                                             */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Rule                                                  */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Administrator', 'Sector Business Rule', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('2', 'Administrator', 'Sector Business Rule', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('3', 'Administrator', 'Sector Business Rule', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('4', 'Administrator', 'Sector Business Rule', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('5', 'Administrator', 'Sector Business Rule', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('6', 'Administrator', 'Sector Business Rule', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('7', 'Administrator', 'Sector Business Rule', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('8', 'Administrator', 'Sector Business Rule', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('9', 'Administrator', 'Sector Business Rule', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('10', 'Administrator', 'Sector Business Rule', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('11', 'Administrator', 'Sector Business Rule', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('12', 'Administrator', 'Sector Business Rule', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('13', 'Tech Admin', 'Sector Business Rule', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('14', 'Tech Admin', 'Sector Business Rule', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('15', 'Tech Admin', 'Sector Business Rule', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('16', 'Tech Admin', 'Sector Business Rule', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('17', 'Tech Admin', 'Sector Business Rule', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('18', 'Tech Admin', 'Sector Business Rule', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('19', 'Tech Admin', 'Sector Business Rule', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('20', 'Tech Admin', 'Sector Business Rule', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('21', 'Tech Admin', 'Sector Business Rule', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('22', 'Tech Admin', 'Sector Business Rule', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('23', 'Tech Admin', 'Sector Business Rule', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
, 	('24', 'Tech Admin', 'Sector Business Rule', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Rule')
	) s ( rn, ref_name_profile, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, start_date, end_date, ref_name_module_type, ref_name_module) ;


	exec [dbo].[_sp_sync_k_profiles_modules_rights_data_merge];

	GO

/* ------------------------------------------------------------------------------------------------- */
/* 5. QUICK CHECK                                                                                  */
/* ------------------------------------------------------------------------------------------------- */
SELECT g.id_grid, g.name_grid, rtv.name_table_view, rgf.name_folder, g.id_grid_parent, g.is_track_change
FROM dbo.k_referential_grids AS g
LEFT JOIN dbo.k_referential_tables_views AS rtv
	ON rtv.id_table_view = g.id_table_view
LEFT JOIN dbo.k_referential_grid_folders AS rgf
	ON rgf.id_folder = g.id_grid_parent
WHERE g.name_grid = 'Sector Business Rule';

SELECT id_rule, rule_name FROM dbo.vPEPSICO_business_split_rule_lookup ORDER BY sort_order;
SELECT number_of_businesses, number_of_businesses_label FROM dbo.vPEPSICO_number_of_businesses_lookup ORDER BY number_of_businesses;

SELECT
	r.id,
	r.id_sector,
	sec.sector_name,
	r.id_rule,
	rl.rule_name,
	r.number_of_businesses
FROM dbo.PEPSICO_sector_business_rule AS r
LEFT JOIN dbo.vPEPSICO_sector_business_mapping_sector_lookup AS sec
	ON sec.id_sector = r.id_sector
LEFT JOIN dbo.vPEPSICO_business_split_rule_lookup AS rl
	ON rl.id_rule = r.id_rule
ORDER BY r.id_sector, r.number_of_businesses;
GO
