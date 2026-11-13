SELECT g.id_grid, g.name_grid, g.id_table_view
FROM dbo.k_referential_grids AS g
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.k_modules AS m
    INNER JOIN dbo.k_modules_types AS mt
        ON mt.id_module_type = m.id_module_type
    INNER JOIN dbo.k_modules_rights AS mr
        ON mr.id_module = m.id_module
    INNER JOIN dbo.k_profiles_modules_rights AS pmr
        ON pmr.id_module_right = mr.id_module_right
    WHERE mt.name_module_type = N'grid'
      AND m.id_item = g.id_grid
)
AND NOT EXISTS
(
    SELECT 1
    FROM dbo.k_referential_grid_kernel_module_right AS km
    INNER JOIN dbo.k_modules_rights AS mr
        ON mr.id_module = km.id_module
        AND mr.id_right = km.id_right
    INNER JOIN dbo.k_profiles_modules_rights AS pmr
        ON pmr.id_module_right = mr.id_module_right
    WHERE km.id_grid = g.id_grid
)
ORDER BY g.name_grid;
