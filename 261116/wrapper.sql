
	/* ----------------------------------------------------------------------------- */
	/* REPORT NAME: User Activity                                                      */
	/* ----------------------------------------------------------------------------- */

	/* ================================================================================================= */
	/* TABLE NAME:                 k_reports                                                             */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'ND_StandardReports', 'User Activity', '#NULL#', 'User_Activities', '#NULL#', '39', '#NULL#', '#NULL#', '-1', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '#NULL#', '0', 'SSRS', '#NULL#', '#NULL#', '0', '0')
	) s ( rn, ref_name_folder, name_report, id_bar, url_report, sort_report, type, visual_type, description, id_owner, id_source_tenant, id_source, id_change_set, configuration_report, id_report_model, is_password_protection_enabled, show_description, description_original, use_translate, ref_name_report_source, id_dashboard, id_dashboard_table_view, show_filter_panel, configuration_report_version) ;


	exec [dbo].[_sp_sync_k_reports_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_reports_control                                                     */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Date', 'GV_DatePicker', 'Date', '150', '50', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', 'Nov 29 2024  6:00AM', '#NULL#', '#NULL#', '0', '#NULL#', '1', 'dynamic', 'false', 'SP_Report_Filter_date_default', 'date_current', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, control_name, ref_name_control_type, layout_label, layout_width, layout_height, source_type, source_name, source_display_field, source_value_field, source_parent_display_field, source_multi_select_used, date_creation, date_modification, culture, source_root_included, auto_select, is_default_value, default_value_type, default_elementId, default_SP_name, default_column_name, id_source_tenant, id_source, id_change_set, page_size, allow_empty, source_filter_used, source_filter_field, source_filter_type, source_filter_value) ;


	exec [dbo].[_sp_sync_k_reports_control_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_reports_control_link                                                */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'User Activity', 'Date', 'report_date', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_report, ref_name_control, report_filter_name, is_filtered, is_required, sort, goto_line, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_k_reports_control_link_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules                                                             */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'ND_StandartReports', 'User Activity', '-9', 'User Activity', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
	) s ( rn, ref_parent_name_module, name_module, id_tab, ref_name_object, order_module, id_source_tenant, id_source, id_change_set, show_in_accordion, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules_rights                                                      */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'User Activity', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
	) s ( rn, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_rights_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_profiles_modules_rights                                             */
	/* SCRIPT GENERATION TIME:     2026-11-17 10:20:13.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_report                                                          */
	/* FILTER 1 - VALUE:           User Activity                                                         */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Administrator', 'User Activity', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'User Activity')
	) s ( rn, ref_name_profile, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, start_date, end_date, ref_name_module_type, ref_name_module) ;


	exec [dbo].[_sp_sync_k_profiles_modules_rights_data_merge];

	GO

Completion time: 2026-11-17T11:20:13.6813466+01:00
