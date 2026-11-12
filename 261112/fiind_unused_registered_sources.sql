/* Application registration dependency audit.
   Based on the FK inventory supplied on 2026-11-12 (including statement schema).
   Run the WHOLE batch in the intended database, outside configuration changes.
   Checks actual referencing rows, including disabled/untrusted FK consumers.
   Own field definitions are registration details and do not count as usage.
   rps_audit and self-referencing security mappings DO count as dependencies.
   Negative source IDs and is_kernel = 1 are protected; report-model flag is informational.
   Also checks six explicit application references without FK (names / IDs).
   No broad text scans, SQL module scans, business-object dependency scans or deletes.
   Scope: supplied FK relationships plus the six explicit checks below.
   Other untyped names/IDs, embedded SQL and JSON are outside coverage. Refresh the inventory if application schema changes.
   Requires SELECT on all referenced configuration tables, without RLS filtering.

   Result 1: registry entries without any of these application dependencies.
   Result 2: dependency details and referencing row counts for used entries.
   Result 3: checked relationships, including those with zero referencing rows.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DROP TABLE IF EXISTS #source_usage;
DROP TABLE IF EXISTS #unused_registered_sources;
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


-- Explicit non-FK references found in application table definitions / wrappers.
-- One-part names conservatively match all registered schemas with that name.
-- Qualified names respect schema; local database prefixes are accepted.
BEGIN TRY
    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_NAME', N'[dbo].[k_referential_grids_fields].[combo_datasource_name]', COUNT_BIG(*)
    FROM dbo.[k_referential_grids_fields] AS x
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[combo_datasource_name])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r
        ON PARSENAME(n.source_name, 1) COLLATE DATABASE_DEFAULT = r.name_table_view COLLATE DATABASE_DEFAULT
        AND (PARSENAME(n.source_name, 2) IS NULL
             OR PARSENAME(n.source_name, 2) COLLATE DATABASE_DEFAULT = r.schema_table_view COLLATE DATABASE_DEFAULT)
        AND (PARSENAME(n.source_name, 3) IS NULL
             OR PARSENAME(n.source_name, 3) COLLATE DATABASE_DEFAULT = DB_NAME() COLLATE DATABASE_DEFAULT)
        AND PARSENAME(n.source_name, 4) IS NULL
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_NAME', N'[dbo].[k_reports_control].[source_name]', COUNT_BIG(*)
    FROM dbo.[k_reports_control] AS x
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[source_name])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r
        ON PARSENAME(n.source_name, 1) COLLATE DATABASE_DEFAULT = r.name_table_view COLLATE DATABASE_DEFAULT
        AND (PARSENAME(n.source_name, 2) IS NULL
             OR PARSENAME(n.source_name, 2) COLLATE DATABASE_DEFAULT = r.schema_table_view COLLATE DATABASE_DEFAULT)
        AND (PARSENAME(n.source_name, 3) IS NULL
             OR PARSENAME(n.source_name, 3) COLLATE DATABASE_DEFAULT = DB_NAME() COLLATE DATABASE_DEFAULT)
        AND PARSENAME(n.source_name, 4) IS NULL
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_NAME', N'[dbo].[k_parameters_control].[name_table]', COUNT_BIG(*)
    FROM dbo.[k_parameters_control] AS x
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[name_table])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r
        ON PARSENAME(n.source_name, 1) COLLATE DATABASE_DEFAULT = r.name_table_view COLLATE DATABASE_DEFAULT
        AND (PARSENAME(n.source_name, 2) IS NULL
             OR PARSENAME(n.source_name, 2) COLLATE DATABASE_DEFAULT = r.schema_table_view COLLATE DATABASE_DEFAULT)
        AND (PARSENAME(n.source_name, 3) IS NULL
             OR PARSENAME(n.source_name, 3) COLLATE DATABASE_DEFAULT = DB_NAME() COLLATE DATABASE_DEFAULT)
        AND PARSENAME(n.source_name, 4) IS NULL
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_NAME', N'[dbo].[k_program_cond_fields].[table_field_preview]', COUNT_BIG(*)
    FROM dbo.[k_program_cond_fields] AS x
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[table_field_preview])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r
        ON PARSENAME(n.source_name, 1) COLLATE DATABASE_DEFAULT = r.name_table_view COLLATE DATABASE_DEFAULT
        AND (PARSENAME(n.source_name, 2) IS NULL
             OR PARSENAME(n.source_name, 2) COLLATE DATABASE_DEFAULT = r.schema_table_view COLLATE DATABASE_DEFAULT)
        AND (PARSENAME(n.source_name, 3) IS NULL
             OR PARSENAME(n.source_name, 3) COLLATE DATABASE_DEFAULT = DB_NAME() COLLATE DATABASE_DEFAULT)
        AND PARSENAME(n.source_name, 4) IS NULL
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_ID_NO_FK', N'[dbo].[k_program_cond_universe_table].[id_table_view_publication]', COUNT_BIG(*)
    FROM dbo.[k_program_cond_universe_table] AS x
    INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view_publication]
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_ID_NO_FK', N'[dbo].[nc_subscription].[id_table_view]', COUNT_BIG(*)
    FROM dbo.[nc_subscription] AS x
    INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = x.[id_table_view]
    GROUP BY r.id_table_view;

END TRY
BEGIN CATCH
    THROW;
END CATCH;

-- 1. No referencing rows in any of the checked relationships.
SELECT r.id_table_view, r.schema_table_view, r.name_table_view,
    r.type_table_view, r.is_kernel, r.is_used_in_report_model,
    r.uid_table_view, DB_NAME() AS audited_database,
    (SELECT COUNT_BIG(*) FROM dbo.k_referential_tables_views_fields AS f
     WHERE f.id_table_view = r.id_table_view) AS registered_field_count
INTO #unused_registered_sources
FROM dbo.k_referential_tables_views AS r
WHERE r.id_table_view >= 0
  AND ISNULL(r.is_kernel, 0) = 0
  AND NOT EXISTS
(
    SELECT 1 FROM #source_usage AS u WHERE u.id_table_view = r.id_table_view
)
;

SELECT id_table_view, schema_table_view, name_table_view, type_table_view,
    is_kernel, is_used_in_report_model, registered_field_count
FROM #unused_registered_sources
ORDER BY schema_table_view, name_table_view;

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
    (N'FIELD_ID', N'[statement].[bqm_template_data_variable].[id_table_view_field]'),
    (N'SOURCE_NAME', N'[dbo].[k_referential_grids_fields].[combo_datasource_name]'),
    (N'SOURCE_NAME', N'[dbo].[k_reports_control].[source_name]'),
    (N'SOURCE_NAME', N'[dbo].[k_parameters_control].[name_table]'),
    (N'SOURCE_NAME', N'[dbo].[k_program_cond_fields].[table_field_preview]'),
    (N'SOURCE_ID_NO_FK', N'[dbo].[k_program_cond_universe_table].[id_table_view_publication]'),
    (N'SOURCE_ID_NO_FK', N'[dbo].[nc_subscription].[id_table_view]')
) AS v(dependency_type, dependency_location)
ORDER BY v.dependency_type, v.dependency_location;
