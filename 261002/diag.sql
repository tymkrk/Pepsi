-- 1. Wszystkie foldery 'Bonus Setup' (w nawiasach lista ID, które merge pomija)
SELECT f.id_folder, f.name_folder, f.id_parent_folder, p.name_folder AS parent_folder,
       CASE WHEN f.id_parent_folder IN (89,90,143,189,192,228,231,273,310,330,193,232,323) THEN 'excluded' ELSE 'USED BY MERGE' END AS merge_status
FROM dbo.k_referential_grid_folders AS f
LEFT JOIN dbo.k_referential_grid_folders AS p ON p.id_folder = f.id_parent_folder
WHERE f.name_folder = 'Bonus Setup';

-- 2. W którym folderze siedzi istniejący grid 'Bonus Team Business'
SELECT g.name_grid, g.id_grid_parent
FROM dbo.k_referential_grids AS g
WHERE g.name_grid IN ('Bonus Team Business', 'Sector Business Mapping');

-- 3. Kontrolnie: czy tabela nie jest zarejestrowana dwa razy
SELECT id_table_view, name_table_view FROM dbo.k_referential_tables_views
WHERE name_table_view = 'PEPSICO_sector_business_mapping';
