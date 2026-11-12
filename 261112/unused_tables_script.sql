/* Application registration dependency audit.
   Based on the FK inventory supplied on 2026-11-12 (including statement schema).
   Run the WHOLE batch in the intended database, outside configuration changes.
   Checks actual referencing rows, including disabled/untrusted FK consumers.
   Own field definitions are registration details and do not count as usage.
   rps_audit and self-referencing security mappings DO count as dependencies.
   Kernel/report-model flags are informational, not dependency evidence.
   No text scans, SQL module scans, business-object dependency scans or deletes.
   Scope: only the supplied FK relationships; names/IDs without these FKs are
   outside coverage. Refresh the inventory if application schema changes.
   Requires SELECT on all referenced configuration tables, without RLS filtering.

   Result 1: registry entries without any of these application dependencies.
   Result 2: dependency details and referencing row counts for used entries.
   Result 3: checked relationships, including those with zero referencing rows.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DROP TABLE IF EXISTS #source_usage;
CREATE TABLE #source_usage
(
    id_table_view INT NOT NULL,
    dependency_type NVARCHAR(20) NOT NULL,
    dependency_location NVARCHAR(776) NOT NULL,
    referencing_row_count BIGINT NOT NULL
);

-- Each query checks one FK column from the supplied inventory.
-- If any check fails, stop before returning candidates.
BEGIN TRY
    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[ads_gridRelation].[idCustomMapTableView]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[idCustomMapTableView]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_data_source].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_data_source] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_m_fields].[combo_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[combo_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_m_olap_references].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_relation].[id_custom_map_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_custom_map_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_security].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_security] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_security].[id_object_security_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_security] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_object_security_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_program_cond_universe_table] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view_transaction]', COUNT_BIG(*)
FROM [dbo].[k_program_cond_universe_table] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view_transaction]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_form].[table_view_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[table_view_id]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_form_field].[foreign_table_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[foreign_table_id]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_grids].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_table_view_api_integration].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_table_view_api_integration] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_tables_views].[id_object_security_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_tables_views] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_object_security_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_report_model_template_field].[id_table_view_datasource]', COUNT_BIG(*)
FROM [dbo].[k_report_model_template_field] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view_datasource]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports].[id_dashboard_table_view]', COUNT_BIG(*)
FROM [dbo].[k_reports] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_dashboard_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports_files_sources].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_reports_files_sources] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports_model].[id_table_view_analytics_data_source]', COUNT_BIG(*)
FROM [dbo].[k_reports_model] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view_analytics_data_source]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_tqm_dimension].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_tqm_dimension] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[rps_audit].[id_table]', COUNT_BIG(*)
FROM [dbo].[rps_audit] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[statement].[bqm_template_data_source].[id_table_view]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_source] AS x
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapBaseField]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[idCustomMapBaseField]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapRelatedField]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[idCustomMapRelatedField]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idDisplayField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicCombo] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[idDisplayField]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idValueField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicCombo] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[idValueField]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicComboDetail].[idFilterField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicComboDetail] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[idFilterField]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields].[combo_text_field]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[combo_text_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields].[combo_value_field]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[combo_value_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields_relation].[id_field_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_fields_relation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_field_table_view]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_textfield]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_textfield]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_valuefield]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_valuefield]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_base_field]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_custom_map_base_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_related_field]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_custom_map_related_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[table_view_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[table_view_field_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[foreign_key_field_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_text_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[foreign_text_field_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_order_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[foreign_order_field_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[parent_key_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[parent_key_field_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_parent_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[foreign_key_field_parent_id]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_field_validation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation_formula_items].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_field_validation_formula_items] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_parent_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_tab_field_mapping] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_parent_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_tab_field_mapping] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[child_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[child_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[master_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[master_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[parent_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[parent_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[hyperlink_id_display_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[hyperlink_id_display_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields_relation].[id_field_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields_relation] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_field_table_view]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_report_model_template_field].[id_table_view_field_datasource_display]', COUNT_BIG(*)
FROM [dbo].[k_report_model_template_field] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_table_view_field_datasource_display]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[statement].[bqm_template_data_source].[sorting_id_table_view_field]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_source] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[sorting_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[statement].[bqm_template_data_variable].[id_table_view_field]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_variable] AS x
INNER JOIN dbo.k_referential_tables_views_fields AS f ON f.id_field = x.[id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view;
END TRY
BEGIN CATCH
    THROW;
END CATCH;

-- 1. No referencing rows in any of the checked relationships.
SELECT r.id_table_view, r.schema_table_view, r.name_table_view,
    r.type_table_view, r.is_kernel, r.is_used_in_report_model,
    (SELECT COUNT_BIG(*) FROM dbo.k_referential_tables_views_fields AS f
     WHERE f.id_table_view = r.id_table_view) AS registered_field_count
FROM dbo.k_referential_tables_views AS r
WHERE NOT EXISTS
(
    SELECT 1 FROM #source_usage AS u WHERE u.id_table_view = r.id_table_view
)
ORDER BY r.schema_table_view, r.name_table_view;

-- 2. Why each other registration is used / has a dependent row.
-- Counts are per FK column; do not sum them as a distinct consumer count.
SELECT r.id_table_view, r.schema_table_view, r.name_table_view,
    u.dependency_type, u.dependency_location, u.referencing_row_count
FROM dbo.k_referential_tables_views AS r
INNER JOIN #source_usage AS u ON u.id_table_view = r.id_table_view
ORDER BY r.schema_table_view, r.name_table_view, u.dependency_location;

-- 3. Full checked relationship list, including unused relationships.
SELECT v.dependency_type, v.dependency_location
FROM (VALUES
    (N'SOURCE_ID', N'[dbo].[ads_gridRelation].[idCustomMapTableView]'),
    (N'SOURCE_ID', N'[dbo].[k_data_source].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_m_fields].[combo_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_m_olap_references].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_object_relation].[id_custom_map_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_object_security].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_object_security].[id_object_security_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view_transaction]'),
    (N'SOURCE_ID', N'[dbo].[k_referential_form].[table_view_id]'),
    (N'SOURCE_ID', N'[dbo].[k_referential_form_field].[foreign_table_id]'),
    (N'SOURCE_ID', N'[dbo].[k_referential_grids].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_referential_table_view_api_integration].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_referential_tables_views].[id_object_security_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_report_model_template_field].[id_table_view_datasource]'),
    (N'SOURCE_ID', N'[dbo].[k_reports].[id_dashboard_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_reports_files_sources].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[k_reports_model].[id_table_view_analytics_data_source]'),
    (N'SOURCE_ID', N'[dbo].[k_tqm_dimension].[id_table_view]'),
    (N'SOURCE_ID', N'[dbo].[rps_audit].[id_table]'),
    (N'SOURCE_ID', N'[statement].[bqm_template_data_source].[id_table_view]'),
    (N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapBaseField]'),
    (N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapRelatedField]'),
    (N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idDisplayField]'),
    (N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idValueField]'),
    (N'FIELD_ID', N'[dbo].[k_DynamicComboDetail].[idFilterField]'),
    (N'FIELD_ID', N'[dbo].[k_m_fields].[combo_text_field]'),
    (N'FIELD_ID', N'[dbo].[k_m_fields].[combo_value_field]'),
    (N'FIELD_ID', N'[dbo].[k_m_fields_relation].[id_field_table_view]'),
    (N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_textfield]'),
    (N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_valuefield]'),
    (N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_base_field]'),
    (N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_related_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[table_view_field_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_text_field_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_order_field_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[parent_key_field_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_parent_id]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation].[id_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation_formula_items].[id_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_parent_table_view_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_table_view_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids].[child_id_table_view_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids].[master_id_table_view_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids].[parent_id_table_view_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[id_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[hyperlink_id_display_field]'),
    (N'FIELD_ID', N'[dbo].[k_referential_grids_fields_relation].[id_field_table_view]'),
    (N'FIELD_ID', N'[dbo].[k_report_model_template_field].[id_table_view_field_datasource_display]'),
    (N'FIELD_ID', N'[statement].[bqm_template_data_source].[sorting_id_table_view_field]'),
    (N'FIELD_ID', N'[statement].[bqm_template_data_variable].[id_table_view_field]')
) AS v(dependency_type, dependency_location)
ORDER BY v.dependency_type, v.dependency_location;
