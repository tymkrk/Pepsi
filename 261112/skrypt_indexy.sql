
SELECT
    fk.name AS foreign_key_name,
    OBJECT_SCHEMA_NAME(fkc.parent_object_id) AS referencing_schema,
    OBJECT_NAME(fkc.parent_object_id) AS referencing_table,
    pc.name AS referencing_column,
    OBJECT_SCHEMA_NAME(fkc.referenced_object_id) AS referenced_schema,
    OBJECT_NAME(fkc.referenced_object_id) AS referenced_table,
    rc.name AS referenced_column,
    fkc.constraint_column_id AS column_position,
    fk.is_disabled,
    fk.is_not_trusted,
    fk.delete_referential_action_desc AS delete_action
FROM sys.foreign_key_columns AS fkc
INNER JOIN sys.foreign_keys AS fk
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns AS pc
    ON pc.object_id = fkc.parent_object_id
    AND pc.column_id = fkc.parent_column_id
INNER JOIN sys.columns AS rc
    ON rc.object_id = fkc.referenced_object_id
    AND rc.column_id = fkc.referenced_column_id
WHERE fkc.referenced_object_id IN
(
    OBJECT_ID(N'dbo.k_referential_tables_views'),
    OBJECT_ID(N'dbo.k_referential_tables_views_fields')
)
ORDER BY
    referenced_table,
    referencing_schema,
    referencing_table,
    foreign_key_name,
    column_position;
