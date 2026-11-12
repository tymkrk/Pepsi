/* Read-only audit of beqom registered sources. Run the WHOLE batch in SSMS.
   Result 1: candidates with no detected inbound use; result 2: usage evidence.
   Scans ALL user-table text columns (including history): can be expensive.
   Name matches are conservative substrings: comments/history may block candidates.
   Not proof of non-use outside this database or by dynamically assembled names.
   Requires VIEW DEFINITION and SELECT on all scanned tables. No NOLOCK.
   Run on a stable database snapshot / outside configuration changes.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF HAS_PERMS_BY_NAME(DB_NAME(), 'DATABASE', 'VIEW DEFINITION') <> 1
    THROW 51000, 'Database VIEW DEFINITION is required.', 1;

DROP TABLE IF EXISTS #sources;
DROP TABLE IF EXISTS #usage;
DROP TABLE IF EXISTS #scan;

SELECT r.id_table_view, r.schema_table_view, r.name_table_view,
    r.type_table_view, r.is_kernel, r.is_used_in_report_model,
    OBJECT_ID(QUOTENAME(r.schema_table_view) + N'.' + QUOTENAME(r.name_table_view)) AS object_id
INTO #sources
FROM dbo.k_referential_tables_views AS r;

CREATE TABLE #usage
(
    id_table_view INT NOT NULL,
    usage_type NVARCHAR(40) NOT NULL,
    usage_location NVARCHAR(776) NOT NULL
);

-- Registration of a source's own fields is not use. Other consumers of those
-- field IDs are use, including form fields, grid columns and business universes.
CREATE TABLE #scan
(
    object_id INT NOT NULL,
    column_id INT NOT NULL,
    match_type VARCHAR(10) NOT NULL,
    PRIMARY KEY (object_id, column_id, match_type)
);

INSERT INTO #scan (object_id, column_id, match_type)
SELECT DISTINCT fk.parent_object_id, fk.parent_column_id,
    CASE WHEN fk.referenced_object_id = OBJECT_ID(N'dbo.k_referential_tables_views')
         THEN 'SOURCE_ID' ELSE 'FIELD_ID' END
FROM sys.foreign_key_columns AS fk
WHERE fk.referenced_object_id IN
    (OBJECT_ID(N'dbo.k_referential_tables_views'), OBJECT_ID(N'dbo.k_referential_tables_views_fields'))
  AND NOT (fk.parent_object_id = OBJECT_ID(N'dbo.k_referential_tables_views_fields')
           AND fk.referenced_object_id = OBJECT_ID(N'dbo.k_referential_tables_views'));

-- Also catch conventional ID columns without declared foreign keys.
INSERT INTO #scan (object_id, column_id, match_type)
SELECT c.object_id, c.column_id,
    CASE WHEN c.name LIKE N'%id%table%view%' THEN 'SOURCE_ID' ELSE 'FIELD_ID' END
FROM sys.columns AS c
INNER JOIN sys.tables AS t ON t.object_id = c.object_id
WHERE t.is_ms_shipped = 0
  AND c.system_type_id IN (48, 52, 56, 127)
  AND (c.name LIKE N'%id%table%view%' OR c.name = N'id_field')
  AND c.object_id NOT IN
      (OBJECT_ID(N'dbo.k_referential_tables_views'), OBJECT_ID(N'dbo.k_referential_tables_views_fields'))
  AND NOT EXISTS (SELECT 1 FROM #scan AS s WHERE s.object_id = c.object_id AND s.column_id = c.column_id);

INSERT INTO #scan (object_id, column_id, match_type)
SELECT c.object_id, c.column_id, 'TEXT'
FROM sys.columns AS c
INNER JOIN sys.tables AS t ON t.object_id = c.object_id
WHERE t.is_ms_shipped = 0
  AND c.system_type_id IN (35, 99, 167, 175, 231, 239, 241)
  -- Ignore registration names/types, but retain embedded dataset SQL.
  AND (c.object_id <> OBJECT_ID(N'dbo.k_referential_tables_views') OR c.name = N'dataset_query')
  AND c.object_id <> OBJECT_ID(N'dbo.k_referential_tables_views_fields');

DECLARE @object_id INT, @column_id INT, @match_type VARCHAR(10),
    @table_name NVARCHAR(517), @column_name NVARCHAR(258),
    @location NVARCHAR(776), @sql NVARCHAR(MAX);

DECLARE scan_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT object_id, column_id, match_type FROM #scan;
OPEN scan_cursor;
FETCH NEXT FROM scan_cursor INTO @object_id, @column_id, @match_type;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @table_name = QUOTENAME(OBJECT_SCHEMA_NAME(@object_id)) + N'.' + QUOTENAME(OBJECT_NAME(@object_id));
    SET @column_name = QUOTENAME(COL_NAME(@object_id, @column_id));
    SET @location = @table_name + N'.' + @column_name;
    SET @sql = N'INSERT INTO #usage (id_table_view, usage_type, usage_location)
        SELECT r.id_table_view, @kind, @location FROM #sources AS r WHERE EXISTS
        (SELECT 1 FROM ' + @table_name + N' AS x ';
    IF @match_type = 'SOURCE_ID'
        SET @sql += N'WHERE x.' + @column_name + N' = r.id_table_view';
    ELSE IF @match_type = 'FIELD_ID'
        SET @sql += N'INNER JOIN dbo.k_referential_tables_views_fields AS f
            ON f.id_field = x.' + @column_name + N' WHERE f.id_table_view = r.id_table_view';
    ELSE
        SET @sql += N'WHERE CHARINDEX(r.name_table_view COLLATE DATABASE_DEFAULT,
            CONVERT(NVARCHAR(MAX), x.' + @column_name + N') COLLATE DATABASE_DEFAULT) > 0';
    SET @sql += N');';
    -- An inaccessible table aborts the audit; never return a clean candidate list
    -- from a partially successful scan.
    BEGIN TRY
        EXEC sys.sp_executesql @sql, N'@kind NVARCHAR(40), @location NVARCHAR(776)',
            @kind = @match_type, @location = @location;
    END TRY
    BEGIN CATCH
        PRINT @location;
        THROW;
    END CATCH;
    FETCH NEXT FROM scan_cursor INTO @object_id, @column_id, @match_type;
END;
CLOSE scan_cursor;
DEALLOCATE scan_cursor;

INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT DISTINCT r.id_table_view, N'SQL_DEPENDENCY',
    QUOTENAME(OBJECT_SCHEMA_NAME(d.referencing_id)) + N'.' + QUOTENAME(OBJECT_NAME(d.referencing_id))
FROM #sources AS r
INNER JOIN sys.sql_expression_dependencies AS d ON d.referenced_id = r.object_id
WHERE d.referencing_id <> r.object_id;

-- Text catches literal dynamic SQL and references absent from dependency metadata.
INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT r.id_table_view, N'SQL_TEXT',
    QUOTENAME(OBJECT_SCHEMA_NAME(m.object_id)) + N'.' + QUOTENAME(OBJECT_NAME(m.object_id))
FROM #sources AS r
INNER JOIN sys.sql_modules AS m
    ON CHARINDEX(r.name_table_view COLLATE DATABASE_DEFAULT, m.definition COLLATE DATABASE_DEFAULT) > 0
WHERE m.object_id <> ISNULL(r.object_id, -1);

INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT r.id_table_view, N'SYNONYM', QUOTENAME(SCHEMA_NAME(s.schema_id)) + N'.' + QUOTENAME(s.name)
FROM #sources AS r
INNER JOIN sys.synonyms AS s ON CHARINDEX(r.name_table_view COLLATE DATABASE_DEFAULT,
    s.base_object_name COLLATE DATABASE_DEFAULT) > 0;

INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT r.id_table_view, N'FOREIGN_KEY',
    QUOTENAME(OBJECT_SCHEMA_NAME(f.parent_object_id)) + N'.' + QUOTENAME(OBJECT_NAME(f.parent_object_id))
FROM #sources AS r
INNER JOIN sys.foreign_keys AS f ON f.referenced_object_id = r.object_id
WHERE f.parent_object_id <> r.object_id;

INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT id_table_view, N'REPORT_MODEL', N'is_used_in_report_model = 1'
FROM #sources WHERE is_used_in_report_model = 1;
INSERT INTO #usage (id_table_view, usage_type, usage_location)
SELECT id_table_view, N'KERNEL', N'is_kernel = 1'
FROM #sources WHERE is_kernel = 1;

-- Encrypted SQL cannot be inspected: suppress candidates rather than claim no use.
IF EXISTS (SELECT 1 FROM sys.sql_modules WHERE definition IS NULL)
    THROW 51001, 'Uninspectable SQL modules exist. Audit incomplete; no candidate list returned.', 1;

SELECT r.id_table_view, r.schema_table_view, r.name_table_view, r.type_table_view,
    CASE WHEN r.object_id IS NULL THEN N'MISSING_PHYSICAL_OBJECT' ELSE N'NO_DETECTED_USE' END AS audit_status
FROM #sources AS r
WHERE NOT EXISTS (SELECT 1 FROM #usage AS u WHERE u.id_table_view = r.id_table_view)
ORDER BY r.schema_table_view, r.name_table_view;

SELECT DISTINCT r.id_table_view, r.schema_table_view, r.name_table_view,
    u.usage_type, u.usage_location
FROM #sources AS r
INNER JOIN #usage AS u ON u.id_table_view = r.id_table_view
ORDER BY r.schema_table_view, r.name_table_view, u.usage_type, u.usage_location;
