/* Delete ONE controlled batch of unused application registrations.
   1. Run find_unused_registered_sources.sql in the SAME SSMS connection.
   2. Run this file with @apply = 0 and review the proposed batch.
   3. Set @apply = 1 and @expected_database to the exact database name; run again.
   4. Each execution commits at most @batch_size sources. Rerun for the next batch.
   Physical tables/views are never dropped. Negative IDs and kernel flags are
   protected in candidate selection AND both deletion statements.
   Revalidates the same 58 dependency paths while holding serializable read locks.
   A newly detected use aborts the entire batch: rerun the audit to refresh scope.
   Unchecked JSON/GUID/embedded-SQL configuration remains outside audit coverage.
   Run as an administrator, outside application configuration changes (locks
   may block other sessions). No existing transaction is allowed.
   Successful writes retain JSON snapshots in dbo.PEPSICO_RegistryCleanup_Backup.
   Backup and deletes commit together. No persistent writes in preview mode.
   Session candidate snapshot survives commits; rerunning the audit replaces it.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @apply BIT = 0;
DECLARE @batch_size INT = 10;
DECLARE @expected_database SYSNAME = N''; -- Required for @apply = 1.
DECLARE @run_id UNIQUEIDENTIFIER = NEWID();
DECLARE @source_count INT, @deleted_source_count INT, @deleted_field_count INT;

IF @@TRANCOUNT <> 0
    THROW 51100, 'Run without an existing transaction.', 1;
IF @batch_size IS NULL OR @batch_size < 1 OR @batch_size > 100
    THROW 51101, 'batch_size must be between 1 and 100.', 1;
IF @apply IS NULL
    THROW 51102, 'apply must be 0 or 1.', 1;
IF @apply = 1 AND (NULLIF(@expected_database, N'') IS NULL OR @expected_database <> DB_NAME())
    THROW 51103, 'Set expected_database to the exact current database name before applying.', 1;
IF OBJECT_ID(N'tempdb..#unused_registered_sources') IS NULL
    THROW 51104, 'Run find_unused_registered_sources.sql first in this same connection.', 1;
IF EXISTS (SELECT 1 FROM #unused_registered_sources WHERE audited_database <> DB_NAME())
    THROW 51105, 'Candidate snapshot belongs to a different database. Rerun the audit.', 1;
IF HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'VIEW DEFINITION') <> 1
    THROW 51106, 'Database VIEW DEFINITION is required to check FK coverage.', 1;

-- Stop if a newly introduced FK consumer is absent from our checked paths.
IF EXISTS
(
    SELECT 1
    FROM sys.foreign_key_columns AS fk
    WHERE fk.referenced_object_id IN
        (OBJECT_ID(N'dbo.k_referential_tables_views'), OBJECT_ID(N'dbo.k_referential_tables_views_fields'))
      AND NOT (fk.parent_object_id = OBJECT_ID(N'dbo.k_referential_tables_views_fields')
               AND fk.referenced_object_id = OBJECT_ID(N'dbo.k_referential_tables_views'))
      AND NOT EXISTS
      (
          SELECT 1 FROM (VALUES
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
          ) AS checked_paths(dependency_type, dependency_location)
          WHERE checked_paths.dependency_type = CASE
              WHEN fk.referenced_object_id = OBJECT_ID(N'dbo.k_referential_tables_views')
              THEN N'SOURCE_ID' ELSE N'FIELD_ID' END
            AND checked_paths.dependency_location = QUOTENAME(OBJECT_SCHEMA_NAME(fk.parent_object_id))
                + N'.' + QUOTENAME(OBJECT_NAME(fk.parent_object_id))
                + N'.' + QUOTENAME(COL_NAME(fk.parent_object_id, fk.parent_column_id))
      )
)
    THROW 51107, 'An additional registry/field FK exists. Update the audit and cleanup checks first.', 1;

DROP TABLE IF EXISTS #cleanup_batch;
CREATE TABLE #cleanup_batch
(
    id_table_view INT NOT NULL PRIMARY KEY,
    uid_table_view UNIQUEIDENTIFIER NOT NULL,
    schema_table_view NVARCHAR(128) NOT NULL,
    name_table_view NVARCHAR(255) NOT NULL
);
DROP TABLE IF EXISTS #source_usage;
CREATE TABLE #source_usage
(
    id_table_view INT NOT NULL,
    dependency_type NVARCHAR(20) NOT NULL,
    dependency_location NVARCHAR(776) NOT NULL,
    referencing_row_count BIGINT NOT NULL
);

BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO #cleanup_batch (id_table_view, uid_table_view, schema_table_view, name_table_view)
    SELECT TOP (@batch_size) r.id_table_view, r.uid_table_view, r.schema_table_view, r.name_table_view
    FROM dbo.k_referential_tables_views AS r WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN #unused_registered_sources AS approved
        ON approved.id_table_view = r.id_table_view
        AND approved.uid_table_view = r.uid_table_view
        AND approved.schema_table_view = r.schema_table_view
        AND approved.name_table_view = r.name_table_view
    WHERE r.id_table_view >= 0 AND ISNULL(r.is_kernel, 0) = 0
    ORDER BY r.id_table_view;
    SET @source_count = @@ROWCOUNT;
    IF @source_count = 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'No remaining eligible entries in this candidate snapshot. Rerun the audit if needed.';
        RETURN;
    END;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[ads_gridRelation].[idCustomMapTableView]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[idCustomMapTableView]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_data_source].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_data_source] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_m_fields].[combo_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[combo_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_m_olap_references].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_relation].[id_custom_map_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_custom_map_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_security].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_security] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_object_security].[id_object_security_table_view]', COUNT_BIG(*)
FROM [dbo].[k_object_security] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_object_security_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_program_cond_universe_table] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_program_cond_universe_table].[id_table_view_transaction]', COUNT_BIG(*)
FROM [dbo].[k_program_cond_universe_table] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view_transaction]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_form].[table_view_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[table_view_id]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_form_field].[foreign_table_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[foreign_table_id]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_grids].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_table_view_api_integration].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_table_view_api_integration] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_referential_tables_views].[id_object_security_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_tables_views] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_object_security_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_report_model_template_field].[id_table_view_datasource]', COUNT_BIG(*)
FROM [dbo].[k_report_model_template_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view_datasource]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports].[id_dashboard_table_view]', COUNT_BIG(*)
FROM [dbo].[k_reports] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_dashboard_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports_files_sources].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_reports_files_sources] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_reports_model].[id_table_view_analytics_data_source]', COUNT_BIG(*)
FROM [dbo].[k_reports_model] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view_analytics_data_source]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[k_tqm_dimension].[id_table_view]', COUNT_BIG(*)
FROM [dbo].[k_tqm_dimension] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[dbo].[rps_audit].[id_table]', COUNT_BIG(*)
FROM [dbo].[rps_audit] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'SOURCE_ID', N'[statement].[bqm_template_data_source].[id_table_view]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_source] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapBaseField]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[idCustomMapBaseField]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[ads_gridRelation].[idCustomMapRelatedField]', COUNT_BIG(*)
FROM [dbo].[ads_gridRelation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[idCustomMapRelatedField]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idDisplayField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicCombo] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[idDisplayField]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicCombo].[idValueField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicCombo] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[idValueField]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_DynamicComboDetail].[idFilterField]', COUNT_BIG(*)
FROM [dbo].[k_DynamicComboDetail] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[idFilterField]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields].[combo_text_field]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[combo_text_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields].[combo_value_field]', COUNT_BIG(*)
FROM [dbo].[k_m_fields] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[combo_value_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_fields_relation].[id_field_table_view]', COUNT_BIG(*)
FROM [dbo].[k_m_fields_relation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_field_table_view]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_textfield]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_textfield]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_m_olap_references].[id_valuefield]', COUNT_BIG(*)
FROM [dbo].[k_m_olap_references] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_valuefield]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_base_field]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_custom_map_base_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_object_relation].[id_custom_map_related_field]', COUNT_BIG(*)
FROM [dbo].[k_object_relation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_custom_map_related_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[table_view_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[table_view_field_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[foreign_key_field_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_text_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[foreign_text_field_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_order_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[foreign_order_field_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[parent_key_field_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[parent_key_field_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_form_field].[foreign_key_field_parent_id]', COUNT_BIG(*)
FROM [dbo].[k_referential_form_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[foreign_key_field_parent_id]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_field_validation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_field_validation_formula_items].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_field_validation_formula_items] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_parent_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_tab_field_mapping] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_parent_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grid_tab_field_mapping].[id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grid_tab_field_mapping] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[child_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[child_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[master_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[master_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids].[parent_id_table_view_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[parent_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[id_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields].[hyperlink_id_display_field]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[hyperlink_id_display_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_referential_grids_fields_relation].[id_field_table_view]', COUNT_BIG(*)
FROM [dbo].[k_referential_grids_fields_relation] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_field_table_view]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[dbo].[k_report_model_template_field].[id_table_view_field_datasource_display]', COUNT_BIG(*)
FROM [dbo].[k_report_model_template_field] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_table_view_field_datasource_display]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[statement].[bqm_template_data_source].[sorting_id_table_view_field]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_source] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[sorting_id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view
UNION ALL
SELECT r.id_table_view, N'FIELD_ID', N'[statement].[bqm_template_data_variable].[id_table_view_field]', COUNT_BIG(*)
FROM [statement].[bqm_template_data_variable] AS x WITH (HOLDLOCK)
INNER JOIN dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK) ON f.id_field = x.[id_table_view_field]
INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = f.id_table_view
GROUP BY r.id_table_view;



-- Explicit non-FK references found in application table definitions / wrappers.
-- One-part names conservatively match all registered schemas with that name.
-- Qualified names respect schema; local database prefixes are accepted.
    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_NAME', N'[dbo].[k_referential_grids_fields].[combo_datasource_name]', COUNT_BIG(*)
    FROM dbo.[k_referential_grids_fields] AS x WITH (HOLDLOCK)
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[combo_datasource_name])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view
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
    FROM dbo.[k_reports_control] AS x WITH (HOLDLOCK)
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[source_name])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view
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
    FROM dbo.[k_parameters_control] AS x WITH (HOLDLOCK)
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[name_table])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view
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
    FROM dbo.[k_program_cond_fields] AS x WITH (HOLDLOCK)
    CROSS APPLY (VALUES (NULLIF(LTRIM(RTRIM(x.[table_field_preview])), N''))) AS n(source_name)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view
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
    FROM dbo.[k_program_cond_universe_table] AS x WITH (HOLDLOCK)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view_publication]
    GROUP BY r.id_table_view;

    INSERT INTO #source_usage
        (id_table_view, dependency_type, dependency_location, referencing_row_count)
    SELECT r.id_table_view, N'SOURCE_ID_NO_FK', N'[dbo].[nc_subscription].[id_table_view]', COUNT_BIG(*)
    FROM dbo.[nc_subscription] AS x WITH (HOLDLOCK)
    INNER JOIN dbo.k_referential_tables_views AS r WITH (HOLDLOCK)
INNER JOIN #cleanup_batch AS selected ON selected.id_table_view = r.id_table_view ON r.id_table_view = x.[id_table_view]
    GROUP BY r.id_table_view;



    IF EXISTS (SELECT 1 FROM #source_usage)
    BEGIN
        SELECT id_table_view, dependency_type, dependency_location, referencing_row_count
        FROM #source_usage ORDER BY id_table_view, dependency_location;
        THROW 51108, 'A batch entry now has dependencies. Nothing deleted; rerun the audit.', 1;
    END;

    SELECT DB_NAME() AS database_name, @run_id AS run_id, @apply AS apply_changes,
        b.id_table_view, b.schema_table_view, b.name_table_view,
        (SELECT COUNT_BIG(*) FROM dbo.k_referential_tables_views_fields AS f WITH (HOLDLOCK)
         WHERE f.id_table_view = b.id_table_view) AS registered_field_count
    FROM #cleanup_batch AS b ORDER BY b.id_table_view;

    IF @apply = 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'PREVIEW ONLY. No persistent writes. Set apply = 1 and expected_database to commit this batch.';
        RETURN;
    END;

    IF OBJECT_ID(N'dbo.PEPSICO_RegistryCleanup_Backup', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.PEPSICO_RegistryCleanup_Backup
        (
            run_id UNIQUEIDENTIFIER NOT NULL,
            backup_time_utc DATETIME2(7) NOT NULL,
            database_name SYSNAME NOT NULL,
            id_table_view INT NOT NULL,
            source_json NVARCHAR(MAX) NOT NULL,
            fields_json NVARCHAR(MAX) NOT NULL,
            CONSTRAINT PK_PEPSICO_RegistryCleanup_Backup PRIMARY KEY (run_id, id_table_view)
        );
    END;

    INSERT INTO dbo.PEPSICO_RegistryCleanup_Backup
        (run_id, backup_time_utc, database_name, id_table_view, source_json, fields_json)
    SELECT @run_id, SYSUTCDATETIME(), DB_NAME(), r.id_table_view,
        (SELECT r.[id_table_view], r.[name_table_view], r.[type_table_view], r.[type_data], r.[is_kernel], r.[dataset_query], r.[id_source_tenant], r.[id_source], r.[id_change_set], r.[id_object_security_table_view], r.[is_used_in_report_model], r.[id_analytics_datasource], r.[id_analytics_datasource_type], r.[uid_datasource], r.[is_view_editable], r.[uid_table_view], r.[schema_table_view] FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER),
        (SELECT f.[id_field], f.[id_table_view], f.[name_field], f.[type_field], f.[length_field], f.[constraint_null_field], f.[constraint_field], f.[order_field], f.[encrypt_field], f.[is_localizable], f.[is_unique], f.[id_source_tenant], f.[id_source], f.[id_change_set], f.[is_computed], f.[has_default_value], f.[default_value_definition], f.[is_key_field], f.[is_display_field], f.[sort_order], f.[sort_direction], f.[precision], f.[scale], f.[uid_datasource_attribute]
         FROM dbo.k_referential_tables_views_fields AS f WITH (UPDLOCK, HOLDLOCK)
         WHERE f.id_table_view = r.id_table_view
         ORDER BY f.id_field FOR JSON PATH, INCLUDE_NULL_VALUES)
    FROM dbo.k_referential_tables_views AS r
    INNER JOIN #cleanup_batch AS b ON b.id_table_view = r.id_table_view
        AND b.uid_table_view = r.uid_table_view;
    IF @@ROWCOUNT <> @source_count
        THROW 51109, 'Backup count mismatch. Batch rolled back.', 1;

    DELETE f
    FROM dbo.k_referential_tables_views_fields AS f
    INNER JOIN dbo.k_referential_tables_views AS r ON r.id_table_view = f.id_table_view
    INNER JOIN #cleanup_batch AS b ON b.id_table_view = r.id_table_view
        AND b.uid_table_view = r.uid_table_view
    WHERE r.id_table_view >= 0 AND ISNULL(r.is_kernel, 0) = 0
      AND NOT EXISTS (SELECT 1 FROM #source_usage AS u WHERE u.id_table_view = r.id_table_view);
    SET @deleted_field_count = @@ROWCOUNT;

    DELETE r
    FROM dbo.k_referential_tables_views AS r
    INNER JOIN #cleanup_batch AS b ON b.id_table_view = r.id_table_view
        AND b.uid_table_view = r.uid_table_view
    WHERE r.id_table_view >= 0 AND ISNULL(r.is_kernel, 0) = 0
      AND NOT EXISTS (SELECT 1 FROM #source_usage AS u WHERE u.id_table_view = r.id_table_view);
    SET @deleted_source_count = @@ROWCOUNT;
    IF @deleted_source_count <> @source_count
        THROW 51110, 'Deleted source count mismatch. Batch rolled back.', 1;

    COMMIT TRANSACTION;
    SELECT @run_id AS committed_run_id, @deleted_source_count AS deleted_registrations,
        @deleted_field_count AS deleted_field_definitions;
    SELECT id_table_view, schema_table_view, name_table_view
    FROM #cleanup_batch ORDER BY id_table_view;
    PRINT 'One batch committed. Rerun this file to process the next batch from the same snapshot.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
