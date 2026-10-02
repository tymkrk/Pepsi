/* =================================================================================================
   Sector Business Mapping - one-shot deployment script (re-runnable)
   1. Table   dbo.PEPSICO_sector_business_mapping       (created if missing; old name-based draft is rebuilt)
   2. Views   dbo.vPEPSICO_sector_business_mapping_sector_lookup
              dbo.vPEPSICO_sector_business_mapping_org_unit_lookup
   3. Proc    dbo.SP_Grid_Save_Post_PEPSICO_sector_business_mapping
   4. Grid    'Sector Business Mapping' (metadata, fields, module, rights)
   5. Initial data load (rows already present are skipped)
   Run as one batch in SSMS / Azure Data Studio against the target beqom database.
   ================================================================================================= */

SET NOCOUNT ON;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 1. TABLE                                                                                        */
/* ------------------------------------------------------------------------------------------------- */
-- Earlier draft stored names (sector_code / org_unit_code). It held only seed data, so rebuild it.
IF COL_LENGTH('dbo.PEPSICO_sector_business_mapping', 'sector_code') IS NOT NULL
BEGIN
	DROP TABLE dbo.PEPSICO_sector_business_mapping;
	PRINT 'Dropped name-based draft of dbo.PEPSICO_sector_business_mapping.';
END

IF COL_LENGTH('dbo.PEPSICO_sector_business_mapping_xhisto', 'sector_code') IS NOT NULL
BEGIN
	DROP TABLE dbo.PEPSICO_sector_business_mapping_xhisto;
	PRINT 'Dropped name-based draft of dbo.PEPSICO_sector_business_mapping_xhisto.';
END
GO

IF OBJECT_ID('dbo.PEPSICO_sector_business_mapping', 'U') IS NULL
BEGIN
	CREATE TABLE [dbo].[PEPSICO_sector_business_mapping](
		[id] [int] IDENTITY(1,1) NOT NULL,
		[id_sector] [int] NOT NULL,
		[id_org_unit] [int] NULL,
		[bt_business_code] [nvarchar](50) NOT NULL,
		[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_sector_business_mapping_is_region] DEFAULT ((0)),
	 CONSTRAINT [PK_PEPSICO_sector_business_mapping] PRIMARY KEY NONCLUSTERED 
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

CREATE OR ALTER VIEW [dbo].[vPEPSICO_sector_business_mapping_org_unit_lookup]
AS

-- Organizational Unit dropdown for grid 'Sector Business Mapping'.
-- Temporary static list (to be replaced by a data-driven source when confirmed).
-- id_org_unit values are stored in dbo.PEPSICO_sector_business_mapping - never renumber existing entries.
-- id_sector = parent sector from dbo.vPEPSICO_sector_business_mapping_sector_lookup.

	SELECT
		v.id_org_unit,
		CAST(v.org_unit_name AS VARCHAR(256)) AS org_unit_name,
		v.id_sector,
		v.id_org_unit AS sort_order
	FROM
	(
		VALUES
			(1, 'East Europe', 2),
			(2, 'Western Europe', 2),
			(3, 'MENAPAK', 2)
	) AS v (id_org_unit, org_unit_name, id_sector)
GO

/* ------------------------------------------------------------------------------------------------- */
/* 3. GRID HOOK PROCEDURE                                                                          */
/* ------------------------------------------------------------------------------------------------- */
CREATE OR ALTER PROCEDURE [dbo].[SP_Grid_Save_Post_PEPSICO_sector_business_mapping]
	@UniqueKey NVARCHAR(MAX), @idUser INT, @idProfile INT, @primaryKey INT
AS
BEGIN
	-- Add/Save post hook for grid 'Sector Business Mapping'.
	-- Blocks duplicate Sector + Organizational Unit + Business combinations.

	SET NOCOUNT ON;

	DECLARE @ResultStatus BIT = 1, @ResultMessage NVARCHAR(255) = '';

	BEGIN TRY

		IF EXISTS
		(
			SELECT 1
			FROM dbo.PEPSICO_sector_business_mapping AS cur
			INNER JOIN dbo.PEPSICO_sector_business_mapping AS oth
				ON oth.id_sector = cur.id_sector
				AND ISNULL(oth.id_org_unit, 0) = ISNULL(cur.id_org_unit, 0)
				AND oth.bt_business_code = cur.bt_business_code
				AND oth.id <> cur.id
			WHERE cur.id = @primaryKey
		)
		BEGIN
			SET @ResultStatus = 0;
			SET @ResultMessage = 'This Sector / Organizational Unit / Business combination already exists.';
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
	/* GRID NAME: Sector Business Mapping                                            */
	/* ----------------------------------------------------------------------------- */

	exec sp_client_std_synchronize 'PEPSICO_sector_business_mapping', 'table', 0;
	GO
	exec sp_client_std_synchronize 'vPEPSICO_sector_business_mapping_sector_lookup', 'view', 0;
	GO
	exec sp_client_std_synchronize 'vPEPSICO_sector_business_mapping_org_unit_lookup', 'view', 0;
	GO
	exec sp_client_std_synchronize 'PEPSICO_Bonus_Team_Business', 'table', 0;
	GO

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids                                                   */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Mapping                                               */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'PEPSICO_sector_business_mapping', 'ND_Grid', 'Sector Business Mapping', '-1', '#NULL#', '50', '1', '#NULL#', '#NULL#', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '0', '0', '-1', '0', '1', '15', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '', 'SP_Grid_Save_Post_PEPSICO_sector_business_mapping', '', 'SP_Grid_Save_Post_PEPSICO_sector_business_mapping', '', '', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '0', '1', '0', '#NULL#', '0', '0', '1', '1', '', '', '0')
	) s ( rn, ref_name_table_view, ref_name_folder, name_grid, type_grid, comments, page_size, is_addable, form_id, url, is_deletable, is_searchable, is_exportable, date_grid, grouping_field, frozen_column, active_trace, filtering_field, is_simulated, is_importable, idOwner, is_auto_resize, is_track_change, sort_grid, width, fit_to_screen, id_source_tenant, id_source, id_change_set, sp_grid_add_pre, sp_grid_add_post, sp_grid_save_pre, sp_grid_save_post, sp_grid_delete_pre, sp_grid_delete_post, is_bulk_insert, is_tree, master_id_table_view_field, child_id_table_view_field, parent_id_table_view_field, is_staging_area_enabled, is_export_template_enabled, show_default_security_view, use_attached_objects, tree_collapse_after_save, is_password_protection_enabled, apply_user_filter, wrap_header, header_tooltip, sp_grid_import_pre, sp_grid_import_post, allow_attached_file) ;


	exec [dbo].[_sp_sync_k_referential_grids_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids_fields                                            */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Mapping                                               */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Sector Business Mapping', 'id_sector', 'Sector', '0', '1', '#NULL#', '1', '#NULL#', '#NULL#', '250', 'vPEPSICO_sector_business_mapping_sector_lookup', 'id_sector', 'sector_name', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
, 	('2', 'Sector Business Mapping', 'id_org_unit', 'Organizational Unit', '1', '1', '#NULL#', '1', '#NULL#', '#NULL#', '250', 'vPEPSICO_sector_business_mapping_org_unit_lookup', 'id_org_unit', 'org_unit_name', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
, 	('3', 'Sector Business Mapping', 'bt_business_code', 'Business', '2', '1', '#NULL#', '1', '#NULL#', '#NULL#', '250', 'PEPSICO_Bonus_Team_Business', 'BTBusinessCode', 'BTBusinessValue', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1', '#NULL#', '1', '0', 'GV_SingleCombo', '', '0', '0', '0')
, 	('4', 'Sector Business Mapping', 'is_region', 'Is Region', '3', '1', '#NULL#', '1', '#NULL#', '#NULL#', '100', '', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '', '0', 'left', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', 'False', '1', '0', '#NULL#', '#NULL#', '0', '0', '0')
	) s ( rn, ref_name_grid, ref_name_field, name_column, order_column, is_editable, regular_expression, is_sortable, error_message, url, width, combo_datasource_name, combo_datavaluefield_name, combo_datatextfield_name, combo_defaultfield_value, combo_page_size, combo_filtered_column_name, combo_filtered_pattern, combo_allow_custom_text, group_index, is_frozen, thousand_separator, decimal_precision, filter_field, sort_order, column_align, is_flex_used, flex, id_source_tenant, id_source, id_change_set, is_mandatory, defaultfield_value, sort_direction, is_percentage_used, ref_name_combo_type, combo_dataparentvaluefield_name, is_bulk_apply_used, enable_row_validation, is_uid_reference) ;


	exec [dbo].[_sp_sync_k_referential_grids_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules                                                             */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Mapping                                               */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'AC_Grids', 'Sector Business Mapping', '-6', 'Sector Business Mapping', '0', '#NULL#', '#NULL#', '#NULL#', '0', 'grid')
	) s ( rn, ref_parent_name_module, name_module, id_tab, ref_name_object, order_module, id_source_tenant, id_source, id_change_set, show_in_accordion, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules_rights                                                      */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Mapping                                               */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Sector Business Mapping', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('2', 'Sector Business Mapping', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('3', 'Sector Business Mapping', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('4', 'Sector Business Mapping', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('5', 'Sector Business Mapping', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('6', 'Sector Business Mapping', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('7', 'Sector Business Mapping', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('8', 'Sector Business Mapping', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('9', 'Sector Business Mapping', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('10', 'Sector Business Mapping', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('11', 'Sector Business Mapping', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', 'grid')
, 	('12', 'Sector Business Mapping', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'grid')
	) s ( rn, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_rights_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_profiles_modules_rights                                             */
	/* FILTER 1 - NAME:            @name_grid                                                            */
	/* FILTER 1 - VALUE:           Sector Business Mapping                                               */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Administrator', 'Sector Business Mapping', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('2', 'Administrator', 'Sector Business Mapping', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('3', 'Administrator', 'Sector Business Mapping', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('4', 'Administrator', 'Sector Business Mapping', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('5', 'Administrator', 'Sector Business Mapping', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('6', 'Administrator', 'Sector Business Mapping', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('7', 'Administrator', 'Sector Business Mapping', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('8', 'Administrator', 'Sector Business Mapping', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('9', 'Administrator', 'Sector Business Mapping', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('10', 'Administrator', 'Sector Business Mapping', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('11', 'Administrator', 'Sector Business Mapping', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('12', 'Administrator', 'Sector Business Mapping', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('13', 'Tech Admin', 'Sector Business Mapping', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('14', 'Tech Admin', 'Sector Business Mapping', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('15', 'Tech Admin', 'Sector Business Mapping', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('16', 'Tech Admin', 'Sector Business Mapping', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('17', 'Tech Admin', 'Sector Business Mapping', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('18', 'Tech Admin', 'Sector Business Mapping', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('19', 'Tech Admin', 'Sector Business Mapping', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('20', 'Tech Admin', 'Sector Business Mapping', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('21', 'Tech Admin', 'Sector Business Mapping', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('22', 'Tech Admin', 'Sector Business Mapping', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('23', 'Tech Admin', 'Sector Business Mapping', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
, 	('24', 'Tech Admin', 'Sector Business Mapping', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Sector Business Mapping')
	) s ( rn, ref_name_profile, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, start_date, end_date, ref_name_module_type, ref_name_module) ;


	exec [dbo].[_sp_sync_k_profiles_modules_rights_data_merge];

	GO

/* ------------------------------------------------------------------------------------------------- */
/* 5. INITIAL DATA LOAD                                                                            */
/* ------------------------------------------------------------------------------------------------- */
/*    Seed rows hold id_sector / id_org_unit as in the lookup views:
         id_sector:   1 North America, 2 EMEA, 3 APAC, 4 LATAM, 5 International Beverages, 6 Global, 7 Corporate
         id_org_unit: 1 East Europe, 2 Western Europe, 3 MENAPAK
       Business code resolved by name from dbo.PEPSICO_Bonus_Team_Business (BTBusinessValue, then BTBusinessCode).
       Rows already present are skipped; unresolved rows are listed at the end. */
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#seed') IS NOT NULL
	DROP TABLE #seed;

CREATE TABLE #seed
(
	seed_order INT IDENTITY(1,1) NOT NULL,
	id_sector INT NOT NULL,
	id_org_unit INT NULL,
	business_name NVARCHAR(100) NOT NULL,
	is_region BIT NOT NULL
);

INSERT INTO #seed (id_sector, id_org_unit, business_name, is_region)
VALUES
	-- 1 = North America
	(1, NULL, 'North America', 1),
	(1, NULL, 'Digital Commerce', 0),
	(1, NULL, 'Texoma US PO1', 0),
	(1, NULL, 'US PO1 Kroger', 0),
	(1, NULL, 'US PO1 Costco', 0),
	(1, NULL, 'US PO1 Target', 0),
	(1, NULL, 'US PO1 Dollar General', 0),
	(1, NULL, 'US PO1 7Eleven', 0),
	(1, NULL, 'US PO1 Walmart', 0),
	(1, NULL, 'US PO1 Walmart + Sam''s Club', 0),
	(1, NULL, 'US PO1 Sam''s Club', 0),
	(1, NULL, 'US PO1 Strategic Grocery Channel', 0),
	(1, NULL, 'PBUS', 0),
	(1, NULL, 'PBUS Northeast', 0),
	(1, NULL, 'PBUS Atlantic', 0),
	(1, NULL, 'PBUS Northcentral', 0),
	(1, NULL, 'PBUS Texoma', 0),
	(1, NULL, 'PBUS Southeast', 0),
	(1, NULL, 'PBUS West', 0),
	(1, NULL, 'PBUS Kroger', 0),
	(1, NULL, 'PBUS Costco', 0),
	(1, NULL, 'PBUS Target', 0),
	(1, NULL, 'PBUS Dollar General', 0),
	(1, NULL, 'PBUS 7Eleven', 0),
	(1, NULL, 'PBUS Walmart', 0),
	(1, NULL, 'PBUS Walmart + Sam''s Club', 0),
	(1, NULL, 'PBUS Sam''s Club', 0),
	(1, NULL, 'PBUS Strategic Grocery Channel', 0),
	(1, NULL, 'PBUS AFH', 0),
	(1, NULL, 'poppi', 0),
	(1, NULL, 'PFUS', 0),
	(1, NULL, 'PFUS Northeast', 0),
	(1, NULL, 'PFUS Atlantic', 0),
	(1, NULL, 'PFUS Northcentral', 0),
	(1, NULL, 'PFUS Texoma', 0),
	(1, NULL, 'PFUS Southeast', 0),
	(1, NULL, 'PFUS West', 0),
	(1, NULL, 'PFUS Kroger', 0),
	(1, NULL, 'PFUS Costco', 0),
	(1, NULL, 'PFUS Target', 0),
	(1, NULL, 'PFUS Dollar General', 0),
	(1, NULL, 'PFUS 7Eleven', 0),
	(1, NULL, 'PFUS Walmart', 0),
	(1, NULL, 'PFUS Walmart + Sam''s Club', 0),
	(1, NULL, 'PFUS Sam''s Club', 0),
	(1, NULL, 'PFUS Strategic Grocery Channel', 0),
	(1, NULL, 'PFUS Quaker', 0),
	(1, NULL, 'Sabra', 0),
	(1, NULL, 'Siete', 0),
	(1, NULL, 'Canada', 0),
	(1, NULL, 'PBC Canada', 0),
	(1, NULL, 'PFC Canada', 0),
	(1, NULL, 'FLC', 0),
	(1, NULL, 'QFC', 0),
	(1, NULL, 'FLC SDL / Field Sales Leader', 0),
	(1, NULL, 'Corporate', 0),
	(1, NULL, 'Other', 0),
	-- 2 = EMEA
	(2, NULL, 'EMEA Region', 1),
	(2, NULL, 'Turkey', 0),
	(2, NULL, 'UKI', 0),
	(2, NULL, 'RBCCA', 0),
	(2, NULL, 'BCCA', 0),
	(2, NULL, 'Russia', 0),
	-- 2 = EMEA, OU 1 = East Europe
	(2, 1, 'East Europe', 0),
	(2, 1, 'Poland', 0),
	(2, 1, 'SEEB', 0),
	(2, 1, 'East Balkans', 0),
	(2, 1, 'Ukraine', 0),
	-- 2 = EMEA, OU 2 = Western Europe
	(2, 2, 'Western Europe', 0),
	(2, 2, 'France', 0),
	(2, 2, 'Iberia', 0),
	(2, 2, 'GroW', 0),
	(2, 2, 'BeNeLux', 0),
	-- 2 = EMEA, OU 3 = MENAPAK
	(2, 3, 'MENAPAK', 0),
	(2, 3, 'Egypt Foods & COBO', 0),
	(2, 3, 'Middle East Foods', 0),
	(2, 3, 'Pakistan Foods', 0),
	(2, 3, 'Ethiopia Foods', 0),
	(2, 3, 'Nigeria Foods', 0),
	(2, 3, 'Southern Africa', 0),
	-- 2 = EMEA
	(2, NULL, 'Corporate', 0),
	(2, NULL, 'Other', 0),
	-- 3 = APAC
	(3, NULL, 'APAC Foods Region', 1),
	(3, NULL, 'ANZ Foods', 0),
	(3, NULL, 'IndoChina Foods', 0),
	(3, NULL, 'Greater China Foods', 0),
	(3, NULL, 'Asia Foods', 0),
	(3, NULL, 'Indonesia Foods', 0),
	(3, NULL, 'Be & Cheery', 0),
	(3, NULL, 'GCR Food PO1', 0),
	(3, NULL, 'B&C Po1', 0),
	(3, NULL, 'Asia Foods PO1', 0),
	(3, NULL, 'Corporate', 0),
	(3, NULL, 'Other', 0),
	-- 4 = LATAM
	(4, NULL, 'LATAM Foods Region', 1),
	(4, NULL, 'PMF', 0),
	(4, NULL, 'PBF', 0),
	(4, NULL, 'South Cone', 0),
	(4, NULL, 'Andean', 0),
	(4, NULL, 'Caricam', 0),
	(4, NULL, 'Venezuela', 0),
	(4, NULL, 'Other', 0),
	-- 5 = International Beverages
	(5, NULL, 'Intl. Beverages', 1),
	(5, NULL, 'India PO1', 0),
	(5, NULL, 'India Foods', 0),
	(5, NULL, 'India Beverages', 0),
	(5, NULL, 'LATAM FOBO', 0),
	(5, NULL, 'Europe FOBO', 0),
	(5, NULL, 'Asia', 0),
	(5, NULL, 'ANZ FOBO', 0),
	(5, NULL, 'MEA FOBO', 0),
	(5, NULL, 'Greater China FOBO', 0),
	(5, NULL, 'Pakistan FOBO', 0),
	(5, NULL, 'SSA FOBO', 0),
	(5, NULL, 'PGCS Global', 0),
	(5, NULL, 'PGCS Pakistan', 0),
	(5, NULL, 'PGCS India', 0),
	(5, NULL, 'PGCS China', 0),
	(5, NULL, 'PGCS Mexico', 0),
	(5, NULL, 'PGCS Uruguay', 0),
	(5, NULL, 'PGCS US', 0),
	(5, NULL, 'Soda Stream Global', 0),
	(5, NULL, 'Soda Stream NA', 0),
	(5, NULL, 'Soda Stream DACH', 0),
	(5, NULL, 'Soda Stream South EU', 0),
	(5, NULL, 'Soda Stream North EU', 0),
	(5, NULL, 'Soda Stream Central EU', 0),
	(5, NULL, 'Soda Stream ROW', 0),
	(5, NULL, 'Soda Stream Argentina', 0),
	(5, NULL, 'Soda Stream Japan', 0),
	(5, NULL, 'Soda Stream Australia', 0),
	(5, NULL, 'Soda Stream Israel', 0),
	(5, NULL, 'Soda Stream South Africa', 0),
	(5, NULL, 'Soda Stream South Korea', 0),
	(5, NULL, 'Corporate', 0),
	(5, NULL, 'Other', 0),
	(5, NULL, 'Pepsi Lipton Global', 0),
	(5, NULL, 'Pepsi Lipton Europe', 0),
	(5, NULL, 'Lipton JV North America', 0),
	(5, NULL, 'Pepsi Lipton LATAM', 0),
	(5, NULL, 'Pepsi Lipton AMEA', 0),
	(5, NULL, 'Pepsi Lipton AMESA', 0),
	(5, NULL, 'Pepsi Lipton APAC', 0),
	(5, NULL, 'Pepsi Lipton LATAM Technical', 0),
	(5, NULL, 'Pepsi Lipton NA Technical', 0),
	(5, NULL, 'Pepsi Lipton Europe Technical', 0),
	(5, NULL, 'Pepsi Lipton AMEA Technical', 0),
	(5, NULL, 'Pepsi Lipton APAC Technical', 0),
	(5, NULL, 'Pepsi Lipton AMESA Technical', 0),
	(5, NULL, 'Pepsi Lipton EU / AMEA Technical', 0);

IF OBJECT_ID('tempdb..#seed_resolved') IS NOT NULL
	DROP TABLE #seed_resolved;

SELECT
	s.seed_order,
	s.id_sector,
	s.id_org_unit,
	s.business_name,
	s.is_region,
	CASE WHEN sec.id_sector IS NULL THEN 0 ELSE 1 END AS is_sector_valid,
	CASE WHEN s.id_org_unit IS NULL OR ou.id_org_unit IS NOT NULL THEN 1 ELSE 0 END AS is_org_unit_valid,
	b.BTBusinessCode AS bt_business_code
INTO #seed_resolved
FROM #seed AS s
LEFT JOIN dbo.vPEPSICO_sector_business_mapping_sector_lookup AS sec
	ON sec.id_sector = s.id_sector
LEFT JOIN dbo.vPEPSICO_sector_business_mapping_org_unit_lookup AS ou
	ON ou.id_org_unit = s.id_org_unit
OUTER APPLY
(
	SELECT TOP (1) btb.BTBusinessCode
	FROM dbo.PEPSICO_Bonus_Team_Business AS btb
	WHERE LTRIM(RTRIM(btb.BTBusinessValue)) = s.business_name
		OR LTRIM(RTRIM(btb.BTBusinessCode)) = s.business_name
	ORDER BY
		CASE WHEN LTRIM(RTRIM(btb.BTBusinessValue)) = s.business_name THEN 0 ELSE 1 END,
		btb.id
) AS b;

BEGIN TRY
	BEGIN TRANSACTION;

	INSERT INTO dbo.PEPSICO_sector_business_mapping (id_sector, id_org_unit, bt_business_code, is_region)
	SELECT
		r.id_sector,
		r.id_org_unit,
		r.bt_business_code,
		r.is_region
	FROM #seed_resolved AS r
	WHERE r.is_sector_valid = 1
		AND r.is_org_unit_valid = 1
		AND r.bt_business_code IS NOT NULL
		AND NOT EXISTS
		(
			SELECT 1
			FROM dbo.PEPSICO_sector_business_mapping AS m
			WHERE m.id_sector = r.id_sector
				AND ISNULL(m.id_org_unit, 0) = ISNULL(r.id_org_unit, 0)
				AND m.bt_business_code = r.bt_business_code
		)
	ORDER BY r.seed_order;

	PRINT CONCAT('Inserted rows: ', @@ROWCOUNT);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;
	THROW;
END CATCH;

-- Seed rows that could not be resolved (fix the source / add the business, then re-run)
SELECT
	CASE
		WHEN r.is_sector_valid = 0 THEN 'ID_SECTOR NOT IN LOOKUP VIEW'
		WHEN r.is_org_unit_valid = 0 THEN 'ID_ORG_UNIT NOT IN LOOKUP VIEW'
		ELSE 'NOT FOUND IN PEPSICO_Bonus_Team_Business'
	END AS [check],
	r.id_sector,
	r.id_org_unit,
	r.business_name,
	r.is_region
FROM #seed_resolved AS r
WHERE r.is_sector_valid = 0
	OR r.is_org_unit_valid = 0
	OR r.bt_business_code IS NULL
ORDER BY r.seed_order;

DROP TABLE #seed_resolved;
DROP TABLE #seed;
GO

/* ------------------------------------------------------------------------------------------------- */
/* 6. QUICK CHECK                                                                                  */
/* ------------------------------------------------------------------------------------------------- */
SELECT g.id_grid, g.name_grid, rtv.name_table_view, rgf.name_folder, g.id_grid_parent, g.is_track_change
FROM dbo.k_referential_grids AS g
LEFT JOIN dbo.k_referential_tables_views AS rtv
	ON rtv.id_table_view = g.id_table_view
LEFT JOIN dbo.k_referential_grid_folders AS rgf
	ON rgf.id_folder = g.id_grid_parent
WHERE g.name_grid = 'Sector Business Mapping';

SELECT id_sector, sector_name FROM dbo.vPEPSICO_sector_business_mapping_sector_lookup ORDER BY sort_order;
SELECT id_org_unit, org_unit_name, id_sector FROM dbo.vPEPSICO_sector_business_mapping_org_unit_lookup ORDER BY sort_order;

SELECT
	m.id,
	m.id_sector,
	sec.sector_name,
	m.id_org_unit,
	ou.org_unit_name,
	m.bt_business_code,
	b.BTBusinessValue,
	m.is_region
FROM dbo.PEPSICO_sector_business_mapping AS m
LEFT JOIN dbo.vPEPSICO_sector_business_mapping_sector_lookup AS sec
	ON sec.id_sector = m.id_sector
LEFT JOIN dbo.vPEPSICO_sector_business_mapping_org_unit_lookup AS ou
	ON ou.id_org_unit = m.id_org_unit
LEFT JOIN dbo.PEPSICO_Bonus_Team_Business AS b
	ON b.BTBusinessCode = m.bt_business_code
ORDER BY m.id;
GO
