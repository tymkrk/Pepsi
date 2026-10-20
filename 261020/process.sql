
	/* ----------------------------------------------------------------------------- */
	/* PROCESS NAME: Bonus                                                              */
	/* ----------------------------------------------------------------------------- */

	exec sp_client_std_synchronize 'PEPSICO_Process_BonusApproval', 'table', -14;
	GO

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids                                                   */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'PEPSICO_Process_BonusApproval', 'ND_Grid', 'Bonus Verification', '-4', '#NULL#', '20', '0', '#NULL#', '#NULL#', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '0', '0', '-1', '0', '0', '53', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '0', '1', '0', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#', '0', '#NULL#')
	) s ( rn, ref_name_table_view, ref_name_parent_folder, name_grid, type_grid, comments, page_size, is_addable, form_id, url, is_deletable, is_searchable, is_exportable, date_grid, grouping_field, frozen_column, active_trace, filtering_field, is_simulated, is_importable, idOwner, is_auto_resize, is_track_change, sort_grid, width, fit_to_screen, id_source_tenant, id_source, id_change_set, sp_grid_add_pre, sp_grid_add_post, sp_grid_save_pre, sp_grid_save_post, sp_grid_delete_pre, sp_grid_delete_post, is_bulk_insert, is_tree, ref_name_field_master, ref_name_field_child, ref_name_field_parent, is_staging_area_enabled, is_export_template_enabled, show_default_security_view, use_attached_objects, tree_collapse_after_save, is_password_protection_enabled, apply_user_filter, wrap_header, header_tooltip, sp_grid_import_pre, sp_grid_import_post, allow_attached_file, uid_object) ;


	exec [dbo].[_sp_sync_process_k_referential_grids_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_referential_grids_fields                                            */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Verification', 'id', 'pr_inf_bon_id', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('2', 'Bonus Verification', 'id_histo', 'pr_inf_bon_id_histo', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('3', 'Bonus Verification', 'idPayee', 'pr_inf_bon_idPayee', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('4', 'Bonus Verification', 'codePayee', 'pr_inf_bon_codePayee', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('5', 'Bonus Verification', 'gpid', 'pr_inf_bon_gpid', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('6', 'Bonus Verification', 'start_date_histo', 'pr_inf_bon_start_date_histo', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('7', 'Bonus Verification', 'end_date_histo', 'pr_inf_bon_end_date_histo', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('8', 'Bonus Verification', 'fullname', 'pr_inf_bon_fullname', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('9', 'Bonus Verification', 'BonusTeamName', 'pr_inf_bon_BonusTeamName', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('10', 'Bonus Verification', 'LevelCode', 'pr_inf_bon_LevelCode', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('11', 'Bonus Verification', 'AnnualBonusPct', 'pr_inf_bon_annualBonusPct', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '2', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('12', 'Bonus Verification', 'PremBonusPct', 'pr_inf_bon_PremBonusPct', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('13', 'Bonus Verification', 'BDIShortTermTarget', 'pr_inf_bon_BDIShortTermTarget', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('14', 'Bonus Verification', 'salary', 'pr_inf_bon_salary', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '2', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('15', 'Bonus Verification', 'currency', 'pr_inf_bon_currency', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('16', 'Bonus Verification', 'start_month', 'pr_inf_bon_start_month', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('17', 'Bonus Verification', 'end_month', 'pr_inf_bon_end_month', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('18', 'Bonus Verification', 'overall_status', 'pr_inf_bon_overall_status', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '', '', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('19', 'Bonus Verification', 'login_user_status', 'pr_inf_bon_login_user_status', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('20', 'Bonus Verification', 'login_user_status', 'GF_login_user_status', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('21', 'Bonus Verification', 'CompGroupName', 'pr_inf_bon_CompGroupName', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('22', 'Bonus Verification', 'CompGroupName', 'GF_CompGroupName', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('23', 'Bonus Verification', 'SalaryPlan', 'pr_inf_fp_SalaryPlan', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('24', 'Bonus Verification', 'SalaryPlan', 'GF_SalaryPlan', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('25', 'Bonus Verification', 'is_red_circle', 'Red Circle', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('26', 'Bonus Verification', 'is_red_circle', 'GF_is_red_circle', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('27', 'Bonus Verification', 'LOAProration', 'pr_inf_bon_loa_proration', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '2', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('28', 'Bonus Verification', 'LOAProration', 'GF_LOAProration', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('29', 'Bonus Verification', 'changed_date', 'pr_inf_bon_changed_date', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('30', 'Bonus Verification', 'changed_date', 'GF_changed_date', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('31', 'Bonus Verification', 'idCompGroup', 'idCompGroup', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('32', 'Bonus Verification', 'idCompGroup', 'GF_idCompGroup', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('33', 'Bonus Verification', 'IsDoubleHat', 'pr_inf_bon_IsDoubleHat', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('34', 'Bonus Verification', 'IsDoubleHat', 'GF_IsDoubleHat', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('35', 'Bonus Verification', 'IsDoubleHat_Text', 'pr_inf_bon_IsDoubleHat_Text', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('36', 'Bonus Verification', 'IsDoubleHat_Text', 'GF_IsDoubleHat_Text', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
, 	('37', 'Bonus Verification', 'BonusTeamNameProcess', 'pr_inf_bon_BonusTeamNameProcess', '0', '0', '#NULL#', '0', '#NULL#', '#NULL#', '100', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '0', '0', '0', '0', '#NULL#', '#NULL#')
	) s ( rn, ref_name_grid, ref_name_field, name_column, order_column, is_editable, regular_expression, is_sortable, error_message, url, width, combo_datasource_name, combo_datavaluefield_name, combo_datatextfield_name, combo_defaultfield_value, combo_page_size, combo_filtered_column_name, combo_filtered_pattern, combo_allow_custom_text, group_index, is_frozen, thousand_separator, decimal_precision, filter_field, sort_order, column_align, is_flex_used, flex, id_source_tenant, id_source, id_change_set, is_mandatory, defaultfield_value, sort_direction, is_percentage_used, ref_name_combotype, combo_dataparentvaluefield_name, is_bulk_apply_used, enable_row_validation, is_uid_reference, hyperlink_enabled, ref_name_field_display, hyperlink_default_display_text) ;


	exec [dbo].[_sp_sync_process_k_referential_grids_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_type_plan                                                         */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Verification', '#NULL#', 'Bonus Verification', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '0')
	) s ( rn, name_type_plan, sort, ref_name_grid, id_source_tenant, id_source, id_change_set, is_estimator_enabled, post_crediting_stored_procedure, estimator_data_formatter_stored_procedure, estimator_result_producer_stored_procedure, use_cte_in_process_load) ;


	exec [dbo].[_sp_sync_process_k_m_type_plan_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_period                                                            */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Approval 2026', 'Jan  1 2026 12:00AM', '#NULL#', '12', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'Dec 31 2026 12:00AM', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, name_period, start_date, status_period, length_period, sort, id_user_create, date_create_period, id_user_update, date_update_period, end_date, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_period_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_workflow                                                          */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'WFL_Bonus Verification', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, name_workflow, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_workflow_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_fields                                                            */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Approval Involvement Status', 'pr_col_bonus_approval_involvement_status', 'bonus_approval_involvement_status', '205', 'N/A', 'GV_Other', 'type_saisie_list', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Mar 27 2018  7:06AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('2', 'Bonus Approval Overall Status', 'pr_col_bonus_approval_overall_status', 'bonus_approval_overall_status', '129', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Mar 27 2018  7:09AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('3', 'Bonus Approval Reason', 'pr_col_bonus_approval_reason', 'bonus_approval_reason', '257', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Mar 27 2018  7:08AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('4', 'Bonus Team Assignment Correct', 'pr_col_bonus_team_assignment_correct', 'bonus_team_assignment_correct', '220', 'N/A', 'GV_Other', 'type_list_tableView', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:13AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('5', 'Bonus Team Comment', 'pr_col_bonus_team_comment', 'bonus_team_comment', '292', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:14AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('6', 'Bonus Team Comment Check', 'pr_col_bonus_team_comment_check', 'bonus_team_comment_check', '100', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:16AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('7', 'Bonus Team Final', 'pr_col_bonus_team_final', 'bonus_team_final', '278', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:16AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('8', 'Bonus Team PRT Message', 'pr_col_bonus_team_prt_message', 'bonus_team_prt_message', '326', 'N/A', 'GV_Other', 'type_saisie_free', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:13AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('9', 'Bonus Team Step 1', 'pr_col_bonus_team_step_1', 'bonus_team_step_1', '272', 'N/A', 'GV_Other', 'type_list_tableView', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:14AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('10', 'Bonus Team Step 2', 'pr_col_bonus_team_step_2', 'bonus_team_step_2', '275', 'N/A', 'GV_Other', 'type_list_tableView', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct 28 2025  7:15AM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
, 	('11', 'Bonus Team Step 3', 'pr_col_bonus_team_step_3', 'bonus_team_step_3', '200', 'N/A', 'GV_Other', 'type_list_tableView', 'GV_List', 'String', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '#NULL#', 'Oct  1 2026  1:42PM', '#NULL#', '#NULL#', '1', '1', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'GV_None', '0', '#NULL#', '0', '#NULL#', '0', '0', '0', '0', '1')
	) s ( rn, name_field, label_field, code_field, width, ref_name_unit, ref_name_field_type, ref_name_control_type, ref_name_value_type, ref_name_value_type_format_name, default_type, default_value, min_type, min_value, max_type, max_value, percentage_type, percentage_value, percentage_mode, is_olap, olap_aggregate_function, id_user_create, date_create_field, id_user_update, date_update_field, show_min, show_max, formula, thousand_separator, decimal_precision, id_source_tenant, id_source, id_change_set, ref_name_olap_reference, ref_name_field_access_type, is_percentage_used, value_filter, show_aggregated_result, threshold_comparison_field, threshold_min_value, threshold_max_value, is_threshold_enabled, show_only_aggregated_result, aggregation_type) ;


	exec [dbo].[_sp_sync_process_k_m_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_indicators                                                        */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'pr_ind_bonus_approval', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'bonus_approval', 'GV_Objective', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', 'Mar 27 2018  7:10AM', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('2', 'pr_ind_bonus_team', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'bonus_team', 'GV_Objective', '#NULL#', '0', '#NULL#', '#NULL#', '#NULL#', 'Oct 28 2025  7:17AM', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, name_ind, ref_categorie1_ind_name, ref_category_parent_name_1, ref_categorie2_ind_name, ref_category_parent_name_2, ref_categorie3_ind_name, ref_category_parent_name_3, status_ind, comment_ind, ref_indicator_type_name, id_mask, is_olap, id_perimeter, olap_dimension_date, id_owner, date_create_ind, id_user_update, date_update_ind, id_timeframe, id_source_tenant, id_source, id_change_set, ref_perspective_name) ;


	exec [dbo].[_sp_sync_process_k_m_indicators_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_indicators_fields                                                 */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'pr_ind_bonus_approval', 'Bonus Approval Involvement Status', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('2', 'pr_ind_bonus_approval', 'Bonus Approval Overall Status', '2', '#NULL#', '#NULL#', '#NULL#')
, 	('3', 'pr_ind_bonus_approval', 'Bonus Approval Reason', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('4', 'pr_ind_bonus_team', 'Bonus Team Assignment Correct', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('5', 'pr_ind_bonus_team', 'Bonus Team Comment', '2', '#NULL#', '#NULL#', '#NULL#')
, 	('6', 'pr_ind_bonus_team', 'Bonus Team Comment Check', '3', '#NULL#', '#NULL#', '#NULL#')
, 	('7', 'pr_ind_bonus_team', 'Bonus Team Final', '7', '#NULL#', '#NULL#', '#NULL#')
, 	('8', 'pr_ind_bonus_team', 'Bonus Team PRT Message', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('9', 'pr_ind_bonus_team', 'Bonus Team Step 1', '4', '#NULL#', '#NULL#', '#NULL#')
, 	('10', 'pr_ind_bonus_team', 'Bonus Team Step 2', '5', '#NULL#', '#NULL#', '#NULL#')
, 	('11', 'pr_ind_bonus_team', 'Bonus Team Step 3', '6', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_indicator, ref_name_field, sort, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_indicators_fields_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_workflow_step                                                     */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'WFL_Bonus Verification', 'pr_wfs_approval', '1', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_workflow, name_step, sort_step, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_workflow_step_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_workflow_step_group                                               */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_workflow                                                        */
	/* FILTER 1 - VALUE:           WFL_Bonus Verification                                                */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'WFL_Bonus Verification', '1317', 'pr_wfs_approval', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', 'bonus_approval_involvement_status1121::bonus_approval_overall_status0121::bonus_approval_reason1121::bonus_team_assignment_correct1211::bonus_team_comment1211::bonus_team_comment_check0211::bonus_team_final1211::bonus_team_prt_message1211::bonus_team_step_11211::bonus_team_step_21211::bonus_team_step_31211::', 'Administrator::Comp Admin::Human Resource::Human Resources LG8::Manager::Manager LG8::Super User::')
	) s ( rn, name_workflow, id_wflstepgroup, ref_name_step, level_step, is_min_level, enable_validation, enable_invalidation, enable_massvalidation, enable_massinvalidation, id_source_tenant, id_source, id_change_set, detail_attr, profile_attr) ;


	exec [dbo].[_sp_sync_process_k_m_workflow_step_group_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_workflow_step_group_detail                                        */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_workflow                                                        */
	/* FILTER 1 - VALUE:           WFL_Bonus Verification                                                */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', '1317', 'Bonus Approval Involvement Status', '1', 'pr_ind_bonus_approval', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('2', '1317', 'Bonus Approval Overall Status', '0', 'pr_ind_bonus_approval', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('3', '1317', 'Bonus Approval Reason', '1', 'pr_ind_bonus_approval', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('4', '1317', 'Bonus Team Assignment Correct', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('5', '1317', 'Bonus Team Comment', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('6', '1317', 'Bonus Team Comment Check', '0', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('7', '1317', 'Bonus Team Final', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('8', '1317', 'Bonus Team PRT Message', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('9', '1317', 'Bonus Team Step 1', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('10', '1317', 'Bonus Team Step 2', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
, 	('11', '1317', 'Bonus Team Step 3', '1', 'pr_ind_bonus_team', '1', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_id_wflstepgroup, ref_name_field, is_editable, ref_name_indicator, is_readable, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_workflow_step_group_detail_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_workflow_step_group_profile                                       */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_workflow                                                        */
	/* FILTER 1 - VALUE:           WFL_Bonus Verification                                                */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', '1317', 'Administrator', '#NULL#', '#NULL#', '#NULL#')
, 	('2', '1317', 'Comp Admin', '#NULL#', '#NULL#', '#NULL#')
, 	('3', '1317', 'Human Resource', '#NULL#', '#NULL#', '#NULL#')
, 	('4', '1317', 'Human Resources LG8', '#NULL#', '#NULL#', '#NULL#')
, 	('5', '1317', 'Manager', '#NULL#', '#NULL#', '#NULL#')
, 	('6', '1317', 'Manager LG8', '#NULL#', '#NULL#', '#NULL#')
, 	('7', '1317', 'Super User', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_id_wflstepgroup, ref_name_profile, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_workflow_step_group_profile_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans                                                             */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', '#NULL#', '#NULL#', 'ND_Processes', '#NULL#', '#NULL#', '#NULL#', 'Bonus Verification', 'GV_Yearly', 'Bonus Approval 2026', 'WFL_Bonus Verification', '#NULL#', '#NULL#', '-1', '#NULL#', '#NULL#', '#NULL#', '0', '-1', 'Jan  1 2026 12:00AM', 'Dec 31 2026 11:59PM', '0', '-1', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '1', '1', '0', '#NULL#', '0', '-2', '25', '0', '0', '0', '0', '34', '35', '32', '33', '1', '1', '1', '1', '0', '0', '0', '0', '1', '0', '0', '0', '0', '0', '50', '1', '1', '100', '100', '100', '100', '0', '0', '0', '65509CA7-8A0E-49BB-BFB9-AA9A802FBA62', '89E323D4-000B-4F4D-88B6-07F4B33B574D')
	) s ( rn, name_plan, comment_plan, nb_frozen_columns, ref_name_folder, nb_default_page_size, nb_indicator_plan, status_plan, ref_name_type_plan, ref_name_frequency, ref_name_period, ref_name_workflow, id_form, id_report, id_owner, date_create_plan, id_user_update, date_update_plan, selfAppraisal, idLevelComment, start_date_plan, end_date_plan, is_begin_date_frequency_start, id_plan_layout_type, root_form_container_id, id_source_tenant, id_source, id_change_set, is_workflow_active, show_employee_info_template, is_quota_enabled, id_structure, tqm_showExtraColumns, id_plan_importexport_options, page_size, is_level_calculation_payee_only, filter_start_date_visibility, filter_end_date_visibility, filter_workflow_step_visibility, sort_order_start_date, sort_order_end_date, sort_order_workflow_step, sort_order_workflow_status, available_start_date, available_end_date, available_workflow_status, available_workflow_step_name, start_date_is_locked, end_date_is_locked, workflow_status_is_locked, workflow_step_is_locked, default_level, is_data_grouping_allowed, is_simulatable, attached_object_close_after_save, attached_object_refresh_after_save, attached_object_refresh_after_save_always, attached_object_height, wrap_header, header_tooltip, width_start_date, width_end_date, width_workflow_status, width_workflow_step_name, is_picture_shown, enable_group_summary, allow_attached_file, uid_object, uid_datasource) ;


	exec [dbo].[_sp_sync_process_k_m_plans_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_indicators                                                  */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', 'pr_ind_bonus_approval', '591', '#NULL#', '26', 'Jan  1 2026 12:00AM', 'Dec 31 2026 11:59PM', '#NULL#', '#NULL#', '#NULL#', '0', '#ffffff')
, 	('2', 'Bonus', 'pr_ind_bonus_team', '1763', '#NULL#', '18', 'Jan  1 2026 12:00AM', 'Dec 31 2026 11:59PM', '#NULL#', '#NULL#', '#NULL#', '0', '#ffffff')
	) s ( rn, ref_name_plan, ref_name_indicator, weight_plan_ind, comment_plan_ind, sort_plan_ind, start_date_plan_ind, end_date_plan_ind, id_source_tenant, id_source, id_change_set, is_frozen, color_code) ;


	exec [dbo].[_sp_sync_process_k_m_plans_indicators_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_informations                                                */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', 'idCompGroup', 'Bonus Verification', '100', '11', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('2', 'Bonus', 'pr_inf_bon_annualBonusPct', 'Bonus Verification', '88', '8', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('3', 'Bonus', 'pr_inf_bon_BDIShortTermTarget', 'Bonus Verification', '106', '7', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('4', 'Bonus', 'pr_inf_bon_BonusTeamNameProcess', 'Bonus Verification', '228', '17', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('5', 'Bonus', 'pr_inf_bon_changed_date', 'Bonus Verification', '160', '31', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('6', 'Bonus', 'pr_inf_bon_CompGroupName', 'Bonus Verification', '144', '12', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('7', 'Bonus', 'pr_inf_bon_currency', 'Bonus Verification', '100', '4', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('8', 'Bonus', 'pr_inf_bon_end_month', 'Bonus Verification', '93', '14', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('9', 'Bonus', 'pr_inf_bon_fullname', 'Bonus Verification', '184', '0', '1', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('10', 'Bonus', 'pr_inf_bon_gpid', 'Bonus Verification', '89', '1', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('11', 'Bonus', 'pr_inf_bon_IsDoubleHat', 'Bonus Verification', '145', '15', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('12', 'Bonus', 'pr_inf_bon_IsDoubleHat_Text', 'Bonus Verification', '176', '16', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('13', 'Bonus', 'pr_inf_bon_LevelCode', 'Bonus Verification', '119', '2', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('14', 'Bonus', 'pr_inf_bon_loa_proration', 'Bonus Verification', '100', '10', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('15', 'Bonus', 'pr_inf_bon_login_user_status', 'Bonus Verification', '145', '30', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('16', 'Bonus', 'pr_inf_bon_PremBonusPct', 'Bonus Verification', '108', '9', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('17', 'Bonus', 'pr_inf_bon_salary', 'Bonus Verification', '107', '5', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('18', 'Bonus', 'pr_inf_bon_start_month', 'Bonus Verification', '92', '13', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('19', 'Bonus', 'pr_inf_fp_SalaryPlan', 'Bonus Verification', '165', '3', '0', '#NULL#', '#NULL#', '#NULL#', '1')
, 	('20', 'Bonus', 'Red Circle', 'Bonus Verification', '100', '6', '0', '#NULL#', '#NULL#', '#NULL#', '1')
	) s ( rn, ref_name_plan, ref_name_grid_field, ref_name_grid, width, sort, is_locked, id_source_tenant, id_source, id_change_set, type) ;


	exec [dbo].[_sp_sync_process_k_m_plans_informations_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plan_display                                                      */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', 'Administrator', '0', '0', '0', '1', '0', '0', '0', '1', '0', '0', '0', '1', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('2', 'Bonus', 'Comp Admin', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('3', 'Bonus', 'Etl Tester', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('4', 'Bonus', 'Human Resource', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('5', 'Bonus', 'Human Resources LG8', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('6', 'Bonus', 'Manager', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('7', 'Bonus', 'Manager LG8', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('8', 'Bonus', 'No access', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
, 	('9', 'Bonus', 'Super User', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '0', '#NULL#', '1')
	) s ( rn, ref_name_plan, ref_name_profile, available_start_date, available_end_date, available_workflow_status, available_workflow_step_name, show_start_date, show_end_date, show_workflow_status, show_workflow_step_name, optional_show_start_date, optional_show_end_date, optional_show_workflow_status, optional_show_workflow_step_name, id_source_tenant, id_source, id_change_set, available_default_form_header, workflow_level, refresh_grid_after_save) ;


	exec [dbo].[_sp_sync_process_k_m_plan_display_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plan_display_field                                                */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus;;;Administrator', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('2', 'Bonus;;;Administrator', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('3', 'Bonus;;;Administrator', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('4', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('5', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('6', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('7', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('8', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('9', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('10', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('11', 'Bonus;;;Administrator', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('12', 'Bonus;;;Comp Admin', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('13', 'Bonus;;;Comp Admin', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('14', 'Bonus;;;Comp Admin', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('15', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('16', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('17', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('18', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('19', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('20', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('21', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('22', 'Bonus;;;Comp Admin', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('23', 'Bonus;;;Etl Tester', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('24', 'Bonus;;;Etl Tester', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('25', 'Bonus;;;Etl Tester', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('26', 'Bonus;;;Human Resource', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('27', 'Bonus;;;Human Resource', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('28', 'Bonus;;;Human Resource', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('29', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('30', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('31', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('32', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('33', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('34', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('35', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('36', 'Bonus;;;Human Resource', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('37', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('38', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('39', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('40', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('41', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('42', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('43', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('44', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('45', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('46', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('47', 'Bonus;;;Human Resources LG8', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('48', 'Bonus;;;Manager', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('49', 'Bonus;;;Manager', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('50', 'Bonus;;;Manager', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('51', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('52', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('53', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('54', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('55', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('56', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('57', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('58', 'Bonus;;;Manager', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('59', 'Bonus;;;Manager LG8', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('60', 'Bonus;;;Manager LG8', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('61', 'Bonus;;;Manager LG8', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('62', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('63', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('64', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('65', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('66', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('67', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('68', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('69', 'Bonus;;;Manager LG8', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('70', 'Bonus;;;No access', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('71', 'Bonus;;;No access', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('72', 'Bonus;;;No access', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('73', 'Bonus;;;Super User', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('74', 'Bonus;;;Super User', 'pr_ind_bonus_approval;;;Bonus Approval Overall Status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('75', 'Bonus;;;Super User', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('76', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('77', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Comment', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('78', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('79', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Final', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('80', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('81', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Step 1', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('82', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Step 2', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('83', 'Bonus;;;Super User', 'pr_ind_bonus_team;;;Bonus Team Step 3', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_plan_display, ref_name_indicator_field, available_plan_display_field, show_plan_display_field, optional_show_plan_display_field, id_source_tenant, id_source, id_change_set, filter_order) ;


	exec [dbo].[_sp_sync_process_k_m_plan_display_field_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plan_display_information                                          */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus_Administrator', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('2', 'Bonus_Administrator', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('3', 'Bonus_Administrator', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('4', 'Bonus_Administrator', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('5', 'Bonus_Administrator', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('6', 'Bonus_Administrator', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('7', 'Bonus_Administrator', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('8', 'Bonus_Administrator', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('9', 'Bonus_Administrator', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('10', 'Bonus_Administrator', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('11', 'Bonus_Administrator', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('12', 'Bonus_Administrator', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('13', 'Bonus_Administrator', 'Bonus_pr_inf_bon_loa_proration', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('14', 'Bonus_Administrator', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('15', 'Bonus_Administrator', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('16', 'Bonus_Administrator', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('17', 'Bonus_Administrator', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('18', 'Bonus_Administrator', 'Bonus_pr_inf_fp_SalaryPlan', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('19', 'Bonus_Administrator', 'Bonus_Red Circle', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('20', 'Bonus_Comp Admin', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('21', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('22', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('23', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('24', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('25', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('26', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('27', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('28', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('29', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('30', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('31', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('32', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_loa_proration', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('33', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('34', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('35', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('36', 'Bonus_Comp Admin', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('37', 'Bonus_Comp Admin', 'Bonus_pr_inf_fp_SalaryPlan', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('38', 'Bonus_Comp Admin', 'Bonus_Red Circle', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('39', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_annualBonusPct', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('40', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_BDIShortTermTarget', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('41', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_CompGroupName', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('42', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_currency', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('43', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_end_month', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('44', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_gpid', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('45', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_LevelCode', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('46', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_login_user_status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('47', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_PremBonusPct', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('48', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_salary', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('49', 'Bonus_Etl Tester', 'Bonus_pr_inf_bon_start_month', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('50', 'Bonus_Human Resource', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('51', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('52', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('53', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('54', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('55', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('56', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('57', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('58', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('59', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('60', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('61', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('62', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_loa_proration', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('63', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('64', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('65', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('66', 'Bonus_Human Resource', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('67', 'Bonus_Human Resource', 'Bonus_pr_inf_fp_SalaryPlan', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('68', 'Bonus_Human Resource', 'Bonus_Red Circle', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('69', 'Bonus_Human Resources LG8', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('70', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('71', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('72', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('73', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('74', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('75', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('76', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('77', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('78', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('79', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('80', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('81', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('82', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('83', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('84', 'Bonus_Human Resources LG8', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('85', 'Bonus_Manager', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('86', 'Bonus_Manager', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('87', 'Bonus_Manager', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('88', 'Bonus_Manager', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('89', 'Bonus_Manager', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('90', 'Bonus_Manager', 'Bonus_pr_inf_bon_CompGroupName', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('91', 'Bonus_Manager', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('92', 'Bonus_Manager', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('93', 'Bonus_Manager', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('94', 'Bonus_Manager', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('95', 'Bonus_Manager', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('96', 'Bonus_Manager', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('97', 'Bonus_Manager', 'Bonus_pr_inf_bon_loa_proration', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('98', 'Bonus_Manager', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('99', 'Bonus_Manager', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('100', 'Bonus_Manager', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('101', 'Bonus_Manager', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('102', 'Bonus_Manager', 'Bonus_pr_inf_fp_SalaryPlan', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('103', 'Bonus_Manager', 'Bonus_Red Circle', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('104', 'Bonus_Manager LG8', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('105', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('106', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('107', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('108', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('109', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('110', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('111', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('112', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('113', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('114', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('115', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('116', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('117', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('118', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('119', 'Bonus_Manager LG8', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('120', 'Bonus_No access', 'Bonus_pr_inf_bon_annualBonusPct', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('121', 'Bonus_No access', 'Bonus_pr_inf_bon_BDIShortTermTarget', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('122', 'Bonus_No access', 'Bonus_pr_inf_bon_CompGroupName', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('123', 'Bonus_No access', 'Bonus_pr_inf_bon_currency', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('124', 'Bonus_No access', 'Bonus_pr_inf_bon_end_month', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('125', 'Bonus_No access', 'Bonus_pr_inf_bon_gpid', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('126', 'Bonus_No access', 'Bonus_pr_inf_bon_LevelCode', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('127', 'Bonus_No access', 'Bonus_pr_inf_bon_login_user_status', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('128', 'Bonus_No access', 'Bonus_pr_inf_bon_PremBonusPct', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('129', 'Bonus_No access', 'Bonus_pr_inf_bon_salary', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('130', 'Bonus_No access', 'Bonus_pr_inf_bon_start_month', '0', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('131', 'Bonus_Super User', 'Bonus_idCompGroup', '1', '0', '0', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('132', 'Bonus_Super User', 'Bonus_pr_inf_bon_annualBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('133', 'Bonus_Super User', 'Bonus_pr_inf_bon_BDIShortTermTarget', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('134', 'Bonus_Super User', 'Bonus_pr_inf_bon_BonusTeamNameProcess', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('135', 'Bonus_Super User', 'Bonus_pr_inf_bon_changed_date', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('136', 'Bonus_Super User', 'Bonus_pr_inf_bon_CompGroupName', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('137', 'Bonus_Super User', 'Bonus_pr_inf_bon_currency', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('138', 'Bonus_Super User', 'Bonus_pr_inf_bon_end_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('139', 'Bonus_Super User', 'Bonus_pr_inf_bon_gpid', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('140', 'Bonus_Super User', 'Bonus_pr_inf_bon_IsDoubleHat', '1', '0', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('141', 'Bonus_Super User', 'Bonus_pr_inf_bon_IsDoubleHat_Text', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('142', 'Bonus_Super User', 'Bonus_pr_inf_bon_LevelCode', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('143', 'Bonus_Super User', 'Bonus_pr_inf_bon_loa_proration', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('144', 'Bonus_Super User', 'Bonus_pr_inf_bon_login_user_status', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('145', 'Bonus_Super User', 'Bonus_pr_inf_bon_PremBonusPct', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('146', 'Bonus_Super User', 'Bonus_pr_inf_bon_salary', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('147', 'Bonus_Super User', 'Bonus_pr_inf_bon_start_month', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('148', 'Bonus_Super User', 'Bonus_pr_inf_fp_SalaryPlan', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
, 	('149', 'Bonus_Super User', 'Bonus_Red Circle', '1', '1', '1', '#NULL#', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_plan_display, ref_name_plan_information, available_plan_display_information, show_plan_display_information, optional_show_plan_display_information, id_source_tenant, id_source, id_change_set, filter_order) ;


	exec [dbo].[_sp_sync_process_k_m_plan_display_information_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plan_profile_status_group                                         */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', 'Administrator', '')
, 	('2', 'Bonus', 'Comp Admin', '')
, 	('3', 'Bonus', 'Human Resource', '')
, 	('4', 'Bonus', 'Human Resources LG8', '')
, 	('5', 'Bonus', 'Manager', '')
, 	('6', 'Bonus', 'Manager LG8', '')
, 	('7', 'Bonus', 'Super User', '')
	) s ( rn, ref_name_plan, ref_name_profile, description) ;


	exec [dbo].[_sp_sync_process_k_m_plan_profile_status_group_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_field_validation                                            */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Compensation Review                                                   */
	/* ================================================================================================= */

				if object_id('tempdb..#sync_data_diff') is not null
					drop table #sync_data_diff
				go

				select	*
				into	#sync_data_diff
				from	(values
				
	('1', 'Bonus Verification', '12_54', 'IN', '#NULL#', 'pr_ind_bonus_approval', 'Bonus Approval Involvement Status')
, 	('2', 'Bonus Verification', '12_55', 'IN', '#NULL#', 'pr_ind_bonus_approval', 'Bonus Approval Reason')
, 	('3', 'Bonus Verification', '21_137', 'IN', '#NULL#', 'pr_ind_bonus_team', 'Bonus Team Assignment Correct')
, 	('4', 'Bonus Verification', '21_139', 'IN', '#NULL#', 'pr_ind_bonus_team', 'Bonus Team Comment')
, 	('5', 'Bonus Verification', '21_140', 'IN', '#NULL#', 'pr_ind_bonus_team', 'Bonus Team Step 1')
, 	('6', 'Bonus Verification', 'ic_18739', 'PC', 'pr_inf_bon_IsDoubleHat', '#NULL#', '#NULL#')
	) s ( rn, ref_name_grid, formula, type_column, name_column, id_ind, id_ind_field) ;



	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_field_validation                                            */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_approval;;;Bonus Approval Involvement Status', '#NULL#', '1==2', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_approval', '0', '1', '0')
, 	('2', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '#NULL#', '[12_54]!=''REJECTED'' || [12_54]==''REJECTED'' && [12_55] != ''''', '0', '1', 'Reject Reason must be entered when Rejecting a Bonus', '1', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_approval', '0', '1', '1')
, 	('3', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '#NULL#', '[21_137]==''SELECT''||[21_137]==''CORRECT''||[21_137]==''INCORRECT_DATA''||([21_137]==''INCORRECT_TEAM''&&([21_140]!=''''||[ic_18739]==1))||([21_137]==''INCORRECT_TEAM_DATA''&&([21_140]!=''''||[ic_18739]==1))', '1', '1', 'Choose a business to adjust the Bonus Team', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '1')
, 	('4', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Comment', '#NULL#', '[21_137]==''INCORRECT_TEAM''||[21_137]==''INCORRECT_TEAM_DATA''||[21_137]==''INCORRECT_DATA''', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
, 	('5', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '#NULL#', '(([21_137]==''INCORRECT_DATA''
||
[21_137]==''INCORRECT_TEAM_DATA'')
&&[21_139]!='''') ||[21_137]==''CORRECT''||[21_137]==''SELECT''||[21_137]==''INCORRECT_TEAM''', '0', '1', 'Comment is mandatory when the Involvement Data is incorrect', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '1', '1', '1')
, 	('6', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Final', '#NULL#', '1==2', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
, 	('7', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team PRT Message', '#NULL#', '1==2', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
, 	('8', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Step 1', '#NULL#', '([21_137]==''INCORRECT_TEAM''
||[21_137]==''INCORRECT_TEAM_DATA''
)&&[ic_18739]==0', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
, 	('9', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Step 2', '#NULL#', '(([21_137]==''INCORRECT_TEAM''
||[21_137]==''INCORRECT_TEAM_DATA''
)&&[ic_18739]==0)&&[21_140]!=''BTB047''', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
, 	('10', 'Bonus Verification', 'Bonus', 'pr_ind_bonus_team;;;Bonus Team Step 3', '#NULL#', '(([21_137]==''INCORRECT_TEAM''
||[21_137]==''INCORRECT_TEAM_DATA''
)&&[ic_18739]==0)&&[21_140]!=''BTB047''', '1', '0', '', '0', '000000', 'C30014', 'FDF3F3', '0', '000000', '3FA440', '94CD94', 'Bonus;;;pr_ind_bonus_team', '0', '1', '0')
	) s ( rn, ref_name_grid, ref_name_plan, ref_name_indicator_field, ref_name_plan_information, formula, action_false_allow_saving, action_false_show_error, action_false_error_message, action_false_use_field_style, action_false_text_color, action_false_border_color, action_false_background_color, action_true_use_field_style, action_true_text_color, action_true_border_color, action_true_background_color, ref_name_plan_indicator, action_false_show_error_on_change, enable_client_side_validation, action_false_allow_editing) ;


	exec [dbo].[_sp_sync_process_k_m_plans_field_validation_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_field_validation_formula_items                              */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus;;;pr_ind_bonus_approval;;;Bonus Approval Reason', 'pr_ind_bonus_approval;;;Bonus Approval Reason', '#NULL#')
, 	('2', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Assignment Correct', 'pr_ind_bonus_team;;;Bonus Team Assignment Correct', '#NULL#')
, 	('3', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Comment', 'pr_ind_bonus_team;;;Bonus Team Comment', '#NULL#')
, 	('4', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Comment Check', 'pr_ind_bonus_team;;;Bonus Team Comment Check', '#NULL#')
, 	('5', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Step 1', 'pr_ind_bonus_team;;;Bonus Team Step 1', '#NULL#')
, 	('6', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Step 2', 'pr_ind_bonus_team;;;Bonus Team Step 2', '#NULL#')
, 	('7', 'Bonus;;;pr_ind_bonus_team;;;Bonus Team Step 3', 'pr_ind_bonus_team;;;Bonus Team Step 3', '#NULL#')
	) s ( rn, ref_name_plan_field_validation, ref_name_indicator_field, ref_name_plan_info) ;


	exec [dbo].[_sp_sync_process_k_m_plans_field_validation_formula_items_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plans_form_report                                                 */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus', 'Process Bonus Involvements and Overrides', 'Involvements and Overrides', 'Employee Report', '#NULL#', '#NULL#', '#NULL#', '0', '1', 'A90392DA-BAD5-4C59-BB83-EFD5F42CEAD7')
, 	('2', 'Bonus', 'Process Bonus Team Details', 'rep_process_emp_team_details', 'Employee Report', '#NULL#', '#NULL#', '#NULL#', '0', '0', 'AC81F4E3-0D29-44F3-93D5-EBD45DBDBABF')
, 	('3', 'Bonus', 'Process Parameter Report Employee', 'Parameters', 'Employee Report', '#NULL#', '#NULL#', '#NULL#', '0', '3', '1926044E-23E0-4051-8BA3-DF1EF301485C')
, 	('4', 'Bonus', 'Process Values Employee', 'rep_process_emp_change_history', 'Employee Report', '#NULL#', '#NULL#', '#NULL#', '0', '2', '857063BC-0B77-4E27-ABB1-5E0CA4177972')
, 	('5', 'Bonus', 'Process Help', 'rep_process_man_bonus', 'Manager Report', '#NULL#', '#NULL#', '#NULL#', '0', '0', 'BE6DC61F-9EC2-464C-9889-FB697A857C3F')
, 	('6', 'Bonus', 'Process Parameter Report Manager', 'rep_process_emp_parameters', 'Manager Report', '#NULL#', '#NULL#', '#NULL#', '0', '1', 'CA91FC7A-A5FD-4A44-858F-B90ACE13AE04')
	) s ( rn, ref_name_plan, ref_name_report, name_form, ref_name_plan_form_report_type, id_source_tenant, id_source, id_change_set, show_by_default, sort_order, uid_object_relation) ;


	exec [dbo].[_sp_sync_process_k_m_plans_form_report_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_m_plan_display_tab                                                  */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Bonus;;;Administrator', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('2', 'Bonus;;;Administrator', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('3', 'Bonus;;;Administrator', '#NULL#', 'Bonus;;;Process Parameter Report Employee;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('4', 'Bonus;;;Administrator', '#NULL#', 'Bonus;;;Process Parameter Report Manager;;;Manager Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('5', 'Bonus;;;Administrator', '#NULL#', 'Bonus;;;Process Values Employee;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('6', 'Bonus;;;Comp Admin', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('7', 'Bonus;;;Comp Admin', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('8', 'Bonus;;;Comp Admin', '#NULL#', 'Bonus;;;Process Values Employee;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('9', 'Bonus;;;Human Resource', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('10', 'Bonus;;;Human Resource', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('11', 'Bonus;;;Human Resources LG8', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('12', 'Bonus;;;Human Resources LG8', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('13', 'Bonus;;;Manager', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('14', 'Bonus;;;Manager', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('15', 'Bonus;;;Manager LG8', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('16', 'Bonus;;;Manager LG8', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('17', 'Bonus;;;Super User', '#NULL#', 'Bonus;;;Process Bonus Involvements and Overrides;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('18', 'Bonus;;;Super User', '#NULL#', 'Bonus;;;Process Bonus Team Details;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
, 	('19', 'Bonus;;;Super User', '#NULL#', 'Bonus;;;Process Values Employee;;;Employee Report', '0', '#NULL#', '#NULL#', '#NULL#')
	) s ( rn, ref_name_plan_display, ref_name_plan_tab_standard, ref_name_plan_form_report, display_order, id_source_tenant, id_source, id_change_set) ;


	exec [dbo].[_sp_sync_process_k_m_plan_display_tab_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules                                                             */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'ND_ProcessReports', 'Process Bonus Involvements and Overrides', '-9', 'Process Bonus Involvements and Overrides', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
, 	('2', 'ND_ProcessReports', 'Process Bonus Team Details', '-9', 'Process Bonus Team Details', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
, 	('3', 'ND_ProcessReports', 'Process Help', '-9', 'Process Help', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
, 	('4', 'ND_ProcessReports', 'Process Parameter Report Employee', '-9', 'Process Parameter Report Employee', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
, 	('5', 'ND_ProcessReports', 'Process Parameter Report Manager', '-9', 'Process Parameter Report Manager', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
, 	('6', 'ND_ProcessReports', 'Process Values Employee', '-9', 'Process Values Employee', '0', '#NULL#', '#NULL#', '#NULL#', '1', 'report')
	) s ( rn, ref_parent_name_module, name_module, id_tab, ref_name_object, order_module, id_source_tenant, id_source, id_change_set, show_in_accordion, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_modules_rights                                                      */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
, 	('2', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
, 	('3', 'Process Parameter Report Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
, 	('4', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
, 	('5', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
, 	('6', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'report')
	) s ( rn, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, ref_name_module_type) ;


	exec [dbo].[_sp_sync_k_modules_rights_data_merge];

	/* ================================================================================================= */
	/* TABLE NAME:                 k_profiles_modules_rights                                             */
	/* SCRIPT GENERATION TIME:     2026-10-20 09:12:32.                                                  */
	/* USER:					   tymoteusz.kruk@beqom.com                                              */
	/* FILTER 1 - NAME:            @name_process                                                         */
	/* FILTER 1 - VALUE:           Bonus                                                                 */
	/* ================================================================================================= */

			if object_id('tempdb..#sync_data') is not null
				drop table #sync_data
			go
		
			select	*
			into	#sync_data
			from	(values
			
	('1', 'Administrator', 'Process Parameter Report Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('2', 'Administrator', 'Process Parameter Report Employee', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('3', 'Administrator', 'Process Parameter Report Employee', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('4', 'Administrator', 'Process Parameter Report Employee', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('5', 'Administrator', 'Process Parameter Report Employee', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('6', 'Administrator', 'Process Parameter Report Employee', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('7', 'Administrator', 'Process Parameter Report Employee', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('8', 'Administrator', 'Process Parameter Report Employee', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('9', 'Administrator', 'Process Parameter Report Employee', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('10', 'Administrator', 'Process Parameter Report Employee', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('11', 'Administrator', 'Process Parameter Report Employee', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('12', 'Administrator', 'Process Parameter Report Employee', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Name Title')
, 	('13', 'Administrator', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('14', 'Administrator', 'Process Parameter Report Manager', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('15', 'Administrator', 'Process Parameter Report Manager', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('16', 'Administrator', 'Process Parameter Report Manager', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('17', 'Administrator', 'Process Parameter Report Manager', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('18', 'Administrator', 'Process Parameter Report Manager', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('19', 'Administrator', 'Process Parameter Report Manager', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('20', 'Administrator', 'Process Parameter Report Manager', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('21', 'Administrator', 'Process Parameter Report Manager', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('22', 'Administrator', 'Process Parameter Report Manager', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('23', 'Administrator', 'Process Parameter Report Manager', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('24', 'Administrator', 'Process Parameter Report Manager', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Type')
, 	('25', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('26', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('27', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('28', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('29', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('30', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('31', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('32', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('33', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('34', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('35', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('36', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'LG vs eCom Level Types')
, 	('37', 'Administrator', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('38', 'Administrator', 'Process Bonus Team Details', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('39', 'Administrator', 'Process Bonus Team Details', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('40', 'Administrator', 'Process Bonus Team Details', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('41', 'Administrator', 'Process Bonus Team Details', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('42', 'Administrator', 'Process Bonus Team Details', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('43', 'Administrator', 'Process Bonus Team Details', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('44', 'Administrator', 'Process Bonus Team Details', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('45', 'Administrator', 'Process Bonus Team Details', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('46', 'Administrator', 'Process Bonus Team Details', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('47', 'Administrator', 'Process Bonus Team Details', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('48', 'Administrator', 'Process Bonus Team Details', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Employee Status')
, 	('49', 'Administrator', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('50', 'Administrator', 'Process Help', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('51', 'Administrator', 'Process Help', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('52', 'Administrator', 'Process Help', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('53', 'Administrator', 'Process Help', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('54', 'Administrator', 'Process Help', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('55', 'Administrator', 'Process Help', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('56', 'Administrator', 'Process Help', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('57', 'Administrator', 'Process Help', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('58', 'Administrator', 'Process Help', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('59', 'Administrator', 'Process Help', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('60', 'Administrator', 'Process Help', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'Vehicle Type')
, 	('61', 'Administrator', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('62', 'Administrator', 'Process Values Employee', 'EXC_modify', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('63', 'Administrator', 'Process Values Employee', 'EXC_create', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('64', 'Administrator', 'Process Values Employee', 'EXC_delete', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('65', 'Administrator', 'Process Values Employee', 'EXC_export', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('66', 'Administrator', 'Process Values Employee', 'EXC_import', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('67', 'Administrator', 'Process Values Employee', 'EXC_publish_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('68', 'Administrator', 'Process Values Employee', 'EXC_validate_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('69', 'Administrator', 'Process Values Employee', 'EXC_access_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('70', 'Administrator', 'Process Values Employee', 'EXC_delete_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('71', 'Administrator', 'Process Values Employee', 'EXC_modify_staging', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('72', 'Administrator', 'Process Values Employee', 'EXC_execute_sp', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'grid', 'PEPSICO_stg_EmpPayComponentRecurring_Error')
, 	('73', 'Administrator', 'Process Parameter Report Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Parameter Report Employee')
, 	('74', 'Administrator', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('75', 'Administrator', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('76', 'Administrator', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('77', 'Administrator', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Values Employee')
, 	('78', 'Administrator', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'node', '_vw_ad_hoc_dataset_dlti')
, 	('79', 'Manager', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'Jan  1 2025 12:00AM', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('80', 'Manager', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('81', 'Manager', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('82', 'Manager LG8', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('83', 'Manager LG8', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('84', 'Manager LG8', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('85', 'Human Resource', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('86', 'Human Resource', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('87', 'Human Resource', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('88', 'Human Resource', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', 'Jan  1 2025 12:00AM', '#NULL#', 'report', 'Process Values Employee')
, 	('89', 'Human Resource', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'node', '_vw_ad_hoc_dataset_dlti')
, 	('90', 'Human Resources LG8', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('91', 'Human Resources LG8', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('92', 'Human Resources LG8', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('93', 'Human Resources LG8', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Values Employee')
, 	('94', 'Comp Admin', 'Process Parameter Report Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Parameter Report Employee')
, 	('95', 'Comp Admin', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('96', 'Comp Admin', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('97', 'Comp Admin', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('98', 'Comp Admin', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Values Employee')
, 	('99', 'Comp Admin', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'node', '_vw_ad_hoc_dataset_dlti')
, 	('100', 'Super User', 'Process Parameter Report Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Parameter Report Employee')
, 	('101', 'Super User', 'Process Bonus Involvements and Overrides', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Involvements and Overrides')
, 	('102', 'Super User', 'Process Bonus Team Details', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Bonus Team Details')
, 	('103', 'Super User', 'Process Help', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Help')
, 	('104', 'Super User', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Values Employee')
, 	('105', 'Super User', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'node', '_vw_ad_hoc_dataset_dlti')
, 	('106', 'Tech Admin', 'Process Parameter Report Manager', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'node', '_vw_ad_hoc_dataset_dlti')
, 	('107', 'Job Architecture Admin', 'Process Values Employee', 'EXC_read', '#NULL#', '#NULL#', '#NULL#', '#NULL#', '#NULL#', 'report', 'Process Values Employee')
	) s ( rn, ref_name_profile, ref_name_object, ref_name_right, id_source_tenant, id_source, id_change_set, start_date, end_date, ref_name_module_type, ref_name_module) ;


	exec [dbo].[_sp_sync_k_profiles_modules_rights_data_merge];

	GO

