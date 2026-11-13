/* Read-only grid visibility candidates, based on application configuration.
   Does NOT prove actual invisibility: administrators, child-grid inheritance,
   parent-menu rights, deep links and application-specific access rules need review.
   No usage logs or object-security criteria evaluated. No deletes.
   Run with SELECT access to all metadata, without RLS filtering.
   Time follows database clock; change @as_of if permission dates use another zone.
*/
SET NOCOUNT ON;
DECLARE @as_of DATETIME = GETDATE();

DROP TABLE IF EXISTS #grid_modules;
DROP TABLE IF EXISTS #grid_profile_access;
DROP TABLE IF EXISTS #grid_visibility;

-- Resolve polymorphic id_item only for modules of type 'grid'.
SELECT g.id_grid, m.id_module, N'GRID_MODULE' AS access_path,
    CAST(NULL AS INT) AS required_right_id
INTO #grid_modules
FROM dbo.k_referential_grids AS g
INNER JOIN dbo.k_modules AS m ON m.id_item = g.id_grid
INNER JOIN dbo.k_modules_types AS mt ON mt.id_module_type = m.id_module_type
WHERE mt.name_module_type = N'grid'
UNION ALL
SELECT km.id_grid, km.id_module, N'KERNEL_MAPPING', km.id_right
FROM dbo.k_referential_grid_kernel_module_right AS km;

-- A kernel mapping uses its explicitly configured right, not necessarily EXC_read.
SELECT DISTINCT gm.id_grid, gm.id_module, gm.access_path,
    pmr.id_profile, rights.name_right
INTO #grid_profile_access
FROM #grid_modules AS gm
INNER JOIN dbo.k_modules_rights AS mr ON mr.id_module = gm.id_module
INNER JOIN dbo.k_rights AS rights ON rights.id_right = mr.id_right
INNER JOIN dbo.k_profiles_modules_rights AS pmr ON pmr.id_module_right = mr.id_module_right
WHERE ((gm.access_path = N'GRID_MODULE' AND rights.name_right = N'EXC_read')
       OR (gm.access_path = N'KERNEL_MAPPING' AND mr.id_right = gm.required_right_id))
  AND (pmr.start_date IS NULL OR pmr.start_date <= @as_of)
  AND (pmr.end_date IS NULL OR pmr.end_date >= @as_of);

SELECT g.id_grid, g.name_grid, g.id_table_view,
    tv.schema_table_view, tv.name_table_view, tv.is_kernel,
    g.id_grid_parent,
    (SELECT COUNT(*) FROM dbo.k_referential_grid_tab AS t
     WHERE t.id_grid = g.id_grid) AS parent_tab_count,
    (SELECT COUNT(DISTINCT gm.id_module) FROM #grid_modules AS gm
     WHERE gm.id_grid = g.id_grid AND gm.access_path = N'GRID_MODULE') AS grid_module_count,
    (SELECT COUNT(*) FROM dbo.k_referential_grid_kernel_module_right AS km
     WHERE km.id_grid = g.id_grid) AS kernel_mapping_count,
    (SELECT COUNT(DISTINCT pa.id_profile) FROM #grid_profile_access AS pa
     WHERE pa.id_grid = g.id_grid) AS current_access_profile_count,
    (SELECT COUNT(DISTINCT u.id_user)
     FROM #grid_profile_access AS pa
     INNER JOIN dbo.k_users_profiles AS up ON up.id_profile = pa.id_profile
     INNER JOIN dbo.k_users AS u ON u.id_user = up.id_user
     WHERE pa.id_grid = g.id_grid AND u.active_user = 1) AS active_user_count,
    (SELECT COUNT(DISTINCT u.id_user)
     FROM #grid_profile_access AS pa
     INNER JOIN dbo.k_users_profiles AS up ON up.id_profile = pa.id_profile
     INNER JOIN dbo.k_users AS u ON u.id_user = up.id_user
     WHERE pa.id_grid = g.id_grid AND u.active_user = 1
       AND ISNULL(u.isadmin_user, 0) = 0) AS active_nonadmin_user_count
INTO #grid_visibility
FROM dbo.k_referential_grids AS g
LEFT JOIN dbo.k_referential_tables_views AS tv ON tv.id_table_view = g.id_table_view;

-- 1. Candidates: no active users on a current explicit access path.
SELECT v.id_grid, v.name_grid, v.id_table_view, v.schema_table_view, v.name_table_view,
    v.is_kernel, v.id_grid_parent, v.parent_tab_count, v.grid_module_count,
    v.kernel_mapping_count, v.current_access_profile_count,
    v.active_user_count, v.active_nonadmin_user_count,
    CASE
        WHEN v.id_grid_parent IS NOT NULL OR v.parent_tab_count > 0
            THEN N'CHILD_GRID_REQUIRES_PARENT_ACCESS_REVIEW'
        WHEN v.grid_module_count = 0 AND v.kernel_mapping_count = 0
            THEN N'NO_MODULE_OR_KERNEL_MAPPING'
        WHEN v.current_access_profile_count = 0
            THEN N'NO_CURRENT_ACCESS_PROFILE'
        ELSE N'ACCESS_PROFILES_HAVE_NO_ACTIVE_USERS'
    END AS review_reason
FROM #grid_visibility AS v
WHERE v.active_user_count = 0
ORDER BY review_reason, v.name_grid;

-- 2. All grids, including grids accessible only to explicitly assigned admins.
SELECT id_grid, name_grid, id_table_view, schema_table_view, name_table_view,
    is_kernel, id_grid_parent, parent_tab_count, grid_module_count,
    kernel_mapping_count, current_access_profile_count,
    active_user_count, active_nonadmin_user_count
FROM #grid_visibility
ORDER BY active_user_count, name_grid;

-- 3. Profile evidence for current access paths (including profiles with no users).
SELECT pa.id_grid, g.name_grid, pa.id_module, pa.access_path,
    pa.name_right, pa.id_profile, p.name_profile,
    COUNT(DISTINCT u.id_user) AS active_user_count
FROM #grid_profile_access AS pa
INNER JOIN dbo.k_referential_grids AS g ON g.id_grid = pa.id_grid
INNER JOIN dbo.k_profiles AS p ON p.id_profile = pa.id_profile
LEFT JOIN dbo.k_users_profiles AS up ON up.id_profile = pa.id_profile
LEFT JOIN dbo.k_users AS u ON u.id_user = up.id_user AND u.active_user = 1
GROUP BY pa.id_grid, g.name_grid, pa.id_module, pa.access_path,
    pa.name_right, pa.id_profile, p.name_profile
ORDER BY g.name_grid, p.name_profile;

-- Admin access may exist outside the explicit paths counted above.
SELECT COUNT(*) AS active_administrator_count
FROM dbo.k_users WHERE active_user = 1 AND isadmin_user = 1;
