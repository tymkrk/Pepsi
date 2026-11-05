/*
PepsiCo Bonus Team - complete branch upgrade - revised 2026-11-05
Run numbered sections in order in the intended existing PepsiCo/beqom database.
Use one SSMS session; include every GO belonging to the selected section.
Plain SQL with GO: no dynamic SQL, SQLCMD mode or external files required.
There is NO global transaction: completed batches remain committed after later failures.
On any error STOP, inspect the failed section and correct it before continuing.
For unattended execution use sqlcmd -b -f 65001 to stop on the first SQL error.
Individual configuration scripts retain their own local transactions.
Includes the complete Bonus metadata wrapper and supplied Kernel OnChange snapshot.
Includes one initial Division-cache refresh; no refresh schedule is added.
OPEN BUSINESS QUESTION: Lipton JV North America belongs only to IB (working assumption).
The source manifest at the end records embedded repository definitions.
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
IF @@TRANCOUNT <> 0
    THROW 51400, 'Run the deployment outside an existing transaction.', 1;
IF EXISTS
(
    SELECT 1 FROM (VALUES
        (N'dbo._sp_sync_k_modules_data_merge'),
        (N'dbo._sp_sync_k_modules_rights_data_merge'),
        (N'dbo._sp_sync_k_profiles_modules_rights_data_merge'),
        (N'dbo._sp_sync_process_k_m_fields_data_merge'),
        (N'dbo._sp_sync_process_k_m_indicators_data_merge'),
        (N'dbo._sp_sync_process_k_m_indicators_fields_data_merge'),
        (N'dbo._sp_sync_process_k_m_period_data_merge'),
        (N'dbo._sp_sync_process_k_m_plan_display_data_merge'),
        (N'dbo._sp_sync_process_k_m_plan_display_field_data_merge'),
        (N'dbo._sp_sync_process_k_m_plan_display_information_data_merge'),
        (N'dbo._sp_sync_process_k_m_plan_display_tab_data_merge'),
        (N'dbo._sp_sync_process_k_m_plan_profile_status_group_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_field_validation_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_field_validation_formula_items_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_form_report_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_indicators_data_merge'),
        (N'dbo._sp_sync_process_k_m_plans_informations_data_merge'),
        (N'dbo._sp_sync_process_k_m_type_plan_data_merge'),
        (N'dbo._sp_sync_process_k_m_workflow_data_merge'),
        (N'dbo._sp_sync_process_k_m_workflow_step_data_merge'),
        (N'dbo._sp_sync_process_k_m_workflow_step_group_data_merge'),
        (N'dbo._sp_sync_process_k_m_workflow_step_group_detail_data_merge'),
        (N'dbo._sp_sync_process_k_m_workflow_step_group_profile_data_merge'),
        (N'dbo._sp_sync_process_k_referential_grids_data_merge'),
        (N'dbo._sp_sync_process_k_referential_grids_fields_data_merge'),
        (N'dbo.sp_client_std_synchronize'),
        (N'dbo.PEPSICO_SP_Refresh_Translations'),
        (N'dbo.Kernel_SP_Process_DataOnChange')
    ) AS required_procedure(object_name)
    WHERE OBJECT_ID(required_procedure.object_name, N'P') IS NULL
)
    THROW 51406, 'Required beqom sync/translation/OnChange procedures are missing.', 1;
IF TYPE_ID(N'dbo.Kernel_Type_Process_Values') IS NULL
    OR TYPE_ID(N'dbo.PEPSICO_EmpPayComponentIncrease_param') IS NULL
    THROW 51407, 'Required Kernel table types are missing.', 1;
GO

-- SECTION 01: Objects/Tables/dbo.PEPSICO_bonus_team_business_mapping.sql
PRINT N'Objects/Tables/dbo.PEPSICO_bonus_team_business_mapping.sql';
GO

IF OBJECT_ID(N'dbo.PEPSICO_bonus_team_business_mapping', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[PEPSICO_bonus_team_business_mapping](
	[sector_name] [nvarchar](100) NOT NULL,
	[org_unit_name] [nvarchar](100) NULL,
	[bt_business_code] [nvarchar](50) NOT NULL,
	[is_region] [bit] NOT NULL,
 CONSTRAINT [UQ_PEPSICO_bonus_team_business_mapping] UNIQUE CLUSTERED
(
	[sector_name] ASC,
	[org_unit_name] ASC,
	[bt_business_code] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[PEPSICO_bonus_team_business_mapping] ADD CONSTRAINT [DF_PEPSICO_bonus_team_business_mapping_is_region] DEFAULT ((0)) FOR [is_region]
END;
GO

-- SECTION 02: Objects/Tables/dbo.PEPSICO_bonus_team_allocation_rule.sql
PRINT N'Objects/Tables/dbo.PEPSICO_bonus_team_allocation_rule.sql';
GO

IF OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule', N'U') IS NULL
BEGIN
CREATE TABLE [dbo].[PEPSICO_bonus_team_allocation_rule](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[comp_round_extended] [nvarchar](256) NOT NULL,
	[number_of_businesses] [int] NOT NULL,
	[split_rule] [nvarchar](200) NOT NULL,
	[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_bonus_team_allocation_rule_is_region] DEFAULT ((0)),
	[corporate_override] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_bonus_team_allocation_rule_corporate_override] DEFAULT ((0)),
 CONSTRAINT [PK_PEPSICO_bonus_team_allocation_rule] PRIMARY KEY CLUSTERED ([id]),
 CONSTRAINT [UQ_PEPSICO_bonus_team_allocation_rule_business_key] UNIQUE NONCLUSTERED
(
	[comp_round_extended] ASC,
	[number_of_businesses] ASC,
	[is_region] ASC,
	[split_rule] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
ALTER TABLE [dbo].[PEPSICO_bonus_team_allocation_rule] WITH CHECK ADD CONSTRAINT [CK_PEPSICO_bonus_team_allocation_rule_number_of_businesses] CHECK (([number_of_businesses] BETWEEN (1) AND (3)))
END;
GO

-- SECTION 03: Objects/Tables/dbo.PEPSICO_CompRoundExtendedRule.sql
PRINT N'Objects/Tables/dbo.PEPSICO_CompRoundExtendedRule.sql';
GO

IF OBJECT_ID(N'dbo.PEPSICO_CompRoundExtendedRule', N'U') IS NULL
BEGIN
CREATE TABLE dbo.PEPSICO_CompRoundExtendedRule
(
    id INT IDENTITY(1,1) NOT NULL,
    id_comp_group INT NOT NULL,
    division_code VARCHAR(256) NOT NULL,
    comp_round_extended NVARCHAR(256) NOT NULL,
    CONSTRAINT PK_PEPSICO_CompRoundExtendedRule PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_PEPSICO_CompRoundExtendedRule_business_key UNIQUE NONCLUSTERED (id_comp_group, division_code),
    CONSTRAINT FK_PEPSICO_CompRoundExtendedRule_CompGroup FOREIGN KEY (id_comp_group)
        REFERENCES dbo.PEPSICO_CompGroup (idCompGroup),
    CONSTRAINT CK_PEPSICO_CompRoundExtendedRule_name CHECK (LEN(LTRIM(RTRIM(comp_round_extended))) > 0)
);
END;
GO

-- SECTION 04: Objects/Tables/dbo.PEPSICO_EmployeeCompRoundException.sql
PRINT N'Objects/Tables/dbo.PEPSICO_EmployeeCompRoundException.sql';
GO

IF OBJECT_ID(N'dbo.PEPSICO_EmployeeCompRoundException', N'U') IS NULL
BEGIN
CREATE TABLE dbo.PEPSICO_EmployeeCompRoundException
(
    id INT IDENTITY(1,1) NOT NULL,
    id_step INT NOT NULL,
    id_comp_group INT NOT NULL,
    division_code VARCHAR(256) NOT NULL,
    comp_round_extended NVARCHAR(256) NOT NULL,
    refreshed_at DATETIME2(0) NOT NULL,
    CONSTRAINT PK_PEPSICO_EmployeeCompRoundException PRIMARY KEY CLUSTERED (id),
    CONSTRAINT UQ_PEPSICO_EmployeeCompRoundException_business_key UNIQUE NONCLUSTERED (id_step, id_comp_group)
);
END;
GO

-- SECTION 05: Upgrade pre-existing allocation table: corporate_override
PRINT N'Upgrade pre-existing allocation table: corporate_override';
GO

IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'corporate_override') IS NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule
    ADD corporate_override BIT NOT NULL CONSTRAINT DF_PEPSICO_bonus_team_allocation_rule_corporate_override DEFAULT (0);
GO

-- SECTION 06: Migrate allocation keys from Comp Group IDs to names
PRINT N'Migrate allocation keys from Comp Group IDs to names';
GO

IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'id_comp_group') IS NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ADD id_comp_group INT NULL;
IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'comp_round_extended') IS NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ADD comp_round_extended NVARCHAR(256) NULL;
GO
IF EXISTS
(
    SELECT 1 FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
    LEFT JOIN dbo.PEPSICO_CompGroup AS cg ON cg.idCompGroup = r.id_comp_group
    WHERE r.comp_round_extended IS NULL AND cg.idCompGroup IS NULL
)
    THROW 51030, 'Allocation migration: unresolved Comp Group ID.', 1;
IF EXISTS
(
    SELECT cg.CompGroupName, r.number_of_businesses, r.is_region
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
    INNER JOIN dbo.PEPSICO_CompGroup AS cg ON cg.idCompGroup = r.id_comp_group
    GROUP BY cg.CompGroupName, r.number_of_businesses, r.is_region
    HAVING COUNT(DISTINCT r.id_comp_group) > 1
) OR EXISTS
(
    SELECT cg.CompGroupName, r.number_of_businesses
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
    INNER JOIN dbo.PEPSICO_CompGroup AS cg ON cg.idCompGroup = r.id_comp_group
    WHERE r.corporate_override = 1
    GROUP BY cg.CompGroupName, r.number_of_businesses
    HAVING COUNT(DISTINCT r.id_comp_group) > 1
)
    THROW 51031, 'Allocation migration: multiple IDs map to the same extended-round key.', 1;
UPDATE r SET comp_round_extended = cg.CompGroupName
FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
INNER JOIN dbo.PEPSICO_CompGroup AS cg ON cg.idCompGroup = r.id_comp_group
WHERE r.comp_round_extended IS NULL;
ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ALTER COLUMN comp_round_extended NVARCHAR(256) NOT NULL;
GO

-- SECTION 07: Identity and business keys: PEPSICO_CompRoundExtendedRule
PRINT N'Identity and business keys: PEPSICO_CompRoundExtendedRule';
GO

IF COL_LENGTH(N'dbo.PEPSICO_CompRoundExtendedRule', N'id') IS NULL
    ALTER TABLE dbo.PEPSICO_CompRoundExtendedRule ADD id INT IDENTITY(1,1) NOT NULL;
GO
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_CompRoundExtendedRule') AND k.type = N'PK'
      AND k.name <> N'PK_PEPSICO_CompRoundExtendedRule'
)
    THROW 51408, 'Unexpected primary key name on PEPSICO_CompRoundExtendedRule; review this section before continuing.', 1;
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    INNER JOIN sys.index_columns AS ic ON ic.object_id = k.parent_object_id AND ic.index_id = k.unique_index_id
    INNER JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_CompRoundExtendedRule') AND k.type = N'PK'
      AND ic.key_ordinal > 0 AND (c.name <> N'id' OR ic.key_ordinal > 1)
)
    ALTER TABLE dbo.PEPSICO_CompRoundExtendedRule DROP CONSTRAINT PK_PEPSICO_CompRoundExtendedRule;
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PEPSICO_CompRoundExtendedRule') AND type = N'PK')
    ALTER TABLE dbo.PEPSICO_CompRoundExtendedRule ADD CONSTRAINT PK_PEPSICO_CompRoundExtendedRule PRIMARY KEY CLUSTERED (id);
IF OBJECT_ID(N'dbo.UQ_PEPSICO_CompRoundExtendedRule_business_key', N'UQ') IS NULL
    ALTER TABLE dbo.PEPSICO_CompRoundExtendedRule ADD CONSTRAINT UQ_PEPSICO_CompRoundExtendedRule_business_key UNIQUE NONCLUSTERED (id_comp_group, division_code);
GO

-- SECTION 08: Identity and business keys: PEPSICO_EmployeeCompRoundException
PRINT N'Identity and business keys: PEPSICO_EmployeeCompRoundException';
GO

IF COL_LENGTH(N'dbo.PEPSICO_EmployeeCompRoundException', N'id') IS NULL
    ALTER TABLE dbo.PEPSICO_EmployeeCompRoundException ADD id INT IDENTITY(1,1) NOT NULL;
GO
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_EmployeeCompRoundException') AND k.type = N'PK'
      AND k.name <> N'PK_PEPSICO_EmployeeCompRoundException'
)
    THROW 51408, 'Unexpected primary key name on PEPSICO_EmployeeCompRoundException; review this section before continuing.', 1;
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    INNER JOIN sys.index_columns AS ic ON ic.object_id = k.parent_object_id AND ic.index_id = k.unique_index_id
    INNER JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_EmployeeCompRoundException') AND k.type = N'PK'
      AND ic.key_ordinal > 0 AND (c.name <> N'id' OR ic.key_ordinal > 1)
)
    ALTER TABLE dbo.PEPSICO_EmployeeCompRoundException DROP CONSTRAINT PK_PEPSICO_EmployeeCompRoundException;
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PEPSICO_EmployeeCompRoundException') AND type = N'PK')
    ALTER TABLE dbo.PEPSICO_EmployeeCompRoundException ADD CONSTRAINT PK_PEPSICO_EmployeeCompRoundException PRIMARY KEY CLUSTERED (id);
IF OBJECT_ID(N'dbo.UQ_PEPSICO_EmployeeCompRoundException_business_key', N'UQ') IS NULL
    ALTER TABLE dbo.PEPSICO_EmployeeCompRoundException ADD CONSTRAINT UQ_PEPSICO_EmployeeCompRoundException_business_key UNIQUE NONCLUSTERED (id_step, id_comp_group);
GO

-- SECTION 09: Identity and business keys: PEPSICO_bonus_team_allocation_rule
PRINT N'Identity and business keys: PEPSICO_bonus_team_allocation_rule';
GO

IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'id') IS NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ADD id INT IDENTITY(1,1) NOT NULL;
GO
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule') AND k.type = N'PK'
      AND k.name <> N'PK_PEPSICO_bonus_team_allocation_rule'
)
    THROW 51408, 'Unexpected primary key name on PEPSICO_bonus_team_allocation_rule; review this section before continuing.', 1;
IF EXISTS
(
    SELECT 1 FROM sys.key_constraints AS k
    INNER JOIN sys.index_columns AS ic ON ic.object_id = k.parent_object_id AND ic.index_id = k.unique_index_id
    INNER JOIN sys.columns AS c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
    WHERE k.parent_object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule') AND k.type = N'PK'
      AND ic.key_ordinal > 0 AND (c.name <> N'id' OR ic.key_ordinal > 1)
)
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule DROP CONSTRAINT PK_PEPSICO_bonus_team_allocation_rule;
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule') AND type = N'PK')
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ADD CONSTRAINT PK_PEPSICO_bonus_team_allocation_rule PRIMARY KEY CLUSTERED (id);
IF OBJECT_ID(N'dbo.UQ_PEPSICO_bonus_team_allocation_rule_business_key', N'UQ') IS NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule ADD CONSTRAINT UQ_PEPSICO_bonus_team_allocation_rule_business_key UNIQUE NONCLUSTERED (comp_round_extended, number_of_businesses, is_region, split_rule);
GO

-- SECTION 10: Remove migrated legacy allocation ID column
PRINT N'Remove migrated legacy allocation ID column';
GO

IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'id_comp_group') IS NOT NULL
    ALTER TABLE dbo.PEPSICO_bonus_team_allocation_rule DROP COLUMN id_comp_group;
GO

-- SECTION 11: Objects/Functions/dbo._ufn_get_comp_round_extended.sql
PRINT N'Objects/Functions/dbo._ufn_get_comp_round_extended.sql';
GO

CREATE OR ALTER FUNCTION dbo._ufn_get_comp_round_extended
(
    @id_step INT,
    @id_comp_group INT
)
RETURNS NVARCHAR(256)
AS
BEGIN
    DECLARE @comp_round_extended NVARCHAR(256);
    SELECT @comp_round_extended = exception_row.comp_round_extended
    FROM dbo.PEPSICO_EmployeeCompRoundException AS exception_row
    WHERE exception_row.id_step = @id_step
      AND exception_row.id_comp_group = @id_comp_group;

    IF @comp_round_extended IS NULL
    BEGIN
        SELECT @comp_round_extended = comp_group.CompGroupName
        FROM dbo.PEPSICO_CompGroup AS comp_group
        WHERE comp_group.idCompGroup = @id_comp_group;
    END;
    RETURN @comp_round_extended;
END;
GO

-- SECTION 12: Objects/Functions/dbo._fn_get_bonus_team.sql
PRINT N'Objects/Functions/dbo._fn_get_bonus_team.sql';
GO

CREATE OR ALTER FUNCTION [dbo].[_fn_get_bonus_team]
(
    @comp_round_extended NVARCHAR(256),
    @Step1 NVARCHAR(255),
    @Step2 NVARCHAR(255),
    @Step3 NVARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    /*
    History:
    20251013 Danuta Lemma    Remove "100%" from final team name.
    20251126 Danuta Lemma    Added IB CompGroup logic.
    20251127 Danuta Lemma    Added ICC CompGroup logic.
    20261009 Tymoteusz Kruk  Added @Step3 and rule selection by step count and region flag;
                            resolve common OU/sector for OR rules, merge repeated teams,
                            and format percentages before alphabetically sorted team names
                            with a slash separator, Corporate last, explicit 100%, and Other for unresolved setups;
                            resolve incoming business names to codes and use CompGroup IDs as configuration keys;
                            Corporate inherits the common sector of the other selected businesses;
                            require a common is_region flag across all selected steps;
                            mixed region/non-region selections return Other;
                            return NULL for empty selections to preserve the preassigned-team fallback in OnChange.

    20261021 Tymoteusz Kruk  Select region rules when any selected business has is_region = 1;
                            regional 100% Sector uses only regional mappings, ignoring other steps;
                            multiple regional sectors return Other;
                            businesses spanning different EMEA OUs return Other after regional priority;
                            keep validation and allocation decisions inside individual split-rule branches;
                            configured Corporate selection overrides base rules and other-step validation.

    20261022 Tymoteusz Kruk  Unify Corporate rule names; retain override validation behavior by flag.

    20261023 Allocation lookup uses comp_round_extended; no employee timeline reads.

    20261104 Restore common EMEA sector across OUs for two/three businesses;
             omit 100% from final names, preserving blend percentages;
             Corporate GGF with two/three businesses resolves to Corporate.

    20261104 Regional OR rule for two/three businesses distinguishes regional selections:
             one region uses 75% selected sector / 25% Corporate; two or more regions use Corporate.

    Workflow: count nonblank steps -> any-region flag -> configured rule.
    OR rules use a common OU first, otherwise sector_name; unresolved setups return Other.
    */
    DECLARE @number_of_businesses INT,
            @is_region BIT = 0,
            @rule_count INT,
            @split_rule NVARCHAR(200),
            @corporate_override BIT = 0,
            @common_sector_name NVARCHAR(100),
            @common_ou_name NVARCHAR(100),
            @resolved_team_name NVARCHAR(100),
            @final_bonus_team NVARCHAR(MAX) = N'Other';

    DECLARE @steps TABLE
    (
        step_number INT NOT NULL,
        bt_business_code NVARCHAR(50) NULL,
        business_name NVARCHAR(100) NULL
    );

    -- RTC supplies business names; resolve codes internally without changing the arguments.
    INSERT INTO @steps (step_number, bt_business_code, business_name)
    SELECT s.step_number, b.bt_business_code, b.business_name
    FROM (VALUES (1, @Step1), (2, @Step2), (3, @Step3)) AS s(step_number, business_name)
    CROSS APPLY
    (
        SELECT LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(s.business_name,
            NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) AS business_name
    ) AS n
    OUTER APPLY
    (
        SELECT CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessCode) END AS bt_business_code,
               CASE WHEN COUNT(DISTINCT d.BTBusinessCode) = 1 THEN MAX(d.BTBusinessValue) END AS business_name
        FROM dbo.PEPSICO_Bonus_Team_Business AS d
        WHERE LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(d.BTBusinessValue,
            NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) = n.business_name
    ) AS b
    WHERE NULLIF(n.business_name, N'') IS NOT NULL;

    -- Count supplied steps, including repeated names; NULL/blank steps are ignored.
    SELECT @number_of_businesses = COUNT(*) FROM @steps;

    -- No correction selected: let OnChange fall back to the preassigned bonus team.
    IF @number_of_businesses = 0
    BEGIN
        RETURN NULL;
    END;

    IF NOT EXISTS
    (
        SELECT 1 WHERE NULLIF(LTRIM(RTRIM(@comp_round_extended)), N'') IS NOT NULL
    )
    BEGIN
        RETURN @final_bonus_team;
    END;

    -- Any region business selects region rules, including mixed region/non-region steps.
    SELECT @is_region = MAX(CONVERT(INT, m.is_region))
    FROM @steps AS s
    INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
        ON m.bt_business_code = s.bt_business_code;

    IF @is_region IS NULL
    BEGIN
        IF @comp_round_extended = N'Corporate GGF' AND @number_of_businesses IN (2, 3)
            SET @is_region = 0;
        ELSE
            RETURN @final_bonus_team;
    END;

    DECLARE @has_unmapped_step BIT = 0,
            @has_emea_ou_conflict BIT = 0;

    -- An unmapped step cannot be classified as non-region.
    IF EXISTS
    (
        SELECT 1 FROM @steps AS s
        WHERE s.bt_business_code IS NULL
           OR NULLIF(LTRIM(RTRIM(s.business_name)), N'') IS NULL OR NOT EXISTS
        (
            SELECT 1 FROM dbo.PEPSICO_bonus_team_business_mapping AS m
            WHERE m.bt_business_code = s.bt_business_code
        )
    )
    BEGIN
        SET @has_unmapped_step = 1;
    END;

    -- Different EMEA OUs use their common sector instead of a two-business blend.
    IF
    (
        SELECT COUNT(DISTINCT m.org_unit_name)
        FROM @steps AS s
        INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
            ON m.bt_business_code = s.bt_business_code
        WHERE m.sector_name = N'EMEA'
          AND m.org_unit_name IN (N'East Europe', N'Western Europe', N'MENAPAK')
    ) > 1
    BEGIN
        SET @has_emea_ou_conflict = 1;
    END;

    DECLARE @team_shares TABLE
    (
        team_name NVARCHAR(255) NOT NULL,
        team_pct DECIMAL(6, 2) NOT NULL
    );

    DECLARE @mapped_steps TABLE
    (
        step_number INT NOT NULL,
        sector_name NVARCHAR(100) NOT NULL,
        org_unit_name NVARCHAR(100) NULL
    );

    INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
    SELECT DISTINCT s.step_number, m.sector_name, NULLIF(LTRIM(RTRIM(m.org_unit_name)), N'')
    FROM @steps AS s
    INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
        ON m.bt_business_code = s.bt_business_code
    WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) <> N'Corporate';


    -- Corporate-specific rules take priority for the selected step count.
    -- Their region flag is ignored; normal allocation excludes override rows.
    SET @rule_count = 0;
    IF EXISTS
    (
        SELECT 1 FROM @steps
        WHERE LTRIM(RTRIM(REPLACE(business_name, NCHAR(160), N' '))) = N'Corporate'
    )
    BEGIN
        SELECT @rule_count = COUNT(*),
               @corporate_override = MAX(CONVERT(INT, r.corporate_override)),
               @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
        FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
        WHERE r.comp_round_extended = @comp_round_extended
          AND r.number_of_businesses = @number_of_businesses
          AND r.corporate_override = 1;
    END;

    IF @rule_count = 0
    BEGIN
        SET @corporate_override = 0;
        SELECT @rule_count = COUNT(*),
               @split_rule = CASE WHEN COUNT(*) = 1 THEN MAX(r.split_rule) END
        FROM dbo.PEPSICO_bonus_team_allocation_rule AS r
        WHERE r.comp_round_extended = @comp_round_extended
          AND r.number_of_businesses = @number_of_businesses
          AND r.is_region = @is_region
          AND r.corporate_override = 0;
    END;

    -- No fallback to a different flag or arbitrary candidate.
    IF @rule_count <> 1
    BEGIN
        RETURN @final_bonus_team;
    END;

    IF @split_rule = N'75% Bonus Team / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 75 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'100% 1st Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 100 FROM @steps WHERE step_number = 1;
    END
    ELSE IF @split_rule = N'50% 1st Bonus Team / 50% 2nd Bonus Team'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        IF @has_emea_ou_conflict = 1
           AND (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) = 1
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N'EMEA', 100);
        END
        ELSE
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct)
            SELECT business_name, 50 FROM @steps;
        END;
    END
    ELSE IF @split_rule = N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct)
        SELECT business_name, 37.5 FROM @steps;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% OU / 25% Corporate OR 75% sector / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct)
        VALUES (@resolved_team_name, 75), (N'Corporate', 25);
    END
    ELSE IF @split_rule = N'75% Selected Region / 25% Corporate OR 100% Corporate'
    BEGIN
        IF @has_unmapped_step = 1 OR @number_of_businesses NOT IN (2, 3)
        BEGIN
            RETURN N'Other';
        END;

        -- Count selected steps, not mappings or distinct sectors; repeated regions count twice.
        DECLARE @regional_step_count INT;
        SELECT @regional_step_count = COUNT(*)
        FROM @steps AS s
        WHERE EXISTS
        (
            SELECT 1 FROM dbo.PEPSICO_bonus_team_business_mapping AS m
            WHERE m.bt_business_code = s.bt_business_code AND m.is_region = 1
        );

        IF @regional_step_count >= 2
        BEGIN
            INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
        END
        ELSE IF @regional_step_count = 1
        BEGIN
            SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT m.sector_name) = 1
                                             THEN MAX(m.sector_name) END
            FROM @steps AS s
            INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
                ON m.bt_business_code = s.bt_business_code
            WHERE m.is_region = 1;

            IF @resolved_team_name IS NULL
                RETURN N'Other';

            INSERT INTO @team_shares (team_name, team_pct)
            VALUES (@resolved_team_name, 75), (N'Corporate', 25);
        END
        ELSE
            RETURN N'Other';
    END
    ELSE IF @split_rule = N'100% Corporate'
    BEGIN
        IF @corporate_override = 0
           AND NOT (@comp_round_extended = N'Corporate GGF' AND @number_of_businesses IN (2, 3))
           AND @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        INSERT INTO @team_shares (team_name, team_pct) VALUES (N'Corporate', 100);
    END
    ELSE IF @split_rule = N'100% OU or 100% Sector'
    BEGIN
        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        -- Resolve the sector from non-Corporate businesses only; none or multiple is unresolved.
        IF (SELECT COUNT(DISTINCT sector_name) FROM @mapped_steps) <> 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @common_sector_name = MAX(sector_name) FROM @mapped_steps;

        -- Corporate has mappings in several sectors; inherit the selected common sector without an OU.
        INSERT INTO @mapped_steps (step_number, sector_name, org_unit_name)
        SELECT s.step_number, @common_sector_name, NULL
        FROM @steps AS s
        WHERE LTRIM(RTRIM(REPLACE(s.business_name, NCHAR(160), N' '))) = N'Corporate';

        IF (SELECT COUNT(DISTINCT org_unit_name) FROM @mapped_steps) = 1
           AND NOT EXISTS (SELECT 1 FROM @mapped_steps WHERE org_unit_name IS NULL)
        BEGIN
            SELECT @common_ou_name = MAX(org_unit_name) FROM @mapped_steps;
        END;

        SET @resolved_team_name = COALESCE(@common_ou_name, @common_sector_name);
        INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
    END
    ELSE IF @split_rule = N'100% Sector'
    BEGIN
        -- Regional 100% Sector ignores non-region steps, including unresolved selections.
        -- More than one regional sector is ambiguous, regardless of step order.
        IF @is_region = 1
        BEGIN
            SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT m.sector_name) = 1
                                             THEN MAX(m.sector_name) END
            FROM @steps AS s
            INNER JOIN dbo.PEPSICO_bonus_team_business_mapping AS m
                ON m.bt_business_code = s.bt_business_code
            WHERE m.is_region = 1;

            RETURN CASE WHEN @resolved_team_name IS NOT NULL
                        THEN @resolved_team_name ELSE N'Other' END;
        END;

        IF @has_unmapped_step = 1
        BEGIN
            RETURN N'Other';
        END;

        SELECT @resolved_team_name = CASE WHEN COUNT(DISTINCT sector_name) = 1
                                         THEN MAX(sector_name) END
        FROM @mapped_steps;
        IF @resolved_team_name IS NULL
        BEGIN
            RETURN N'Other';
        END;
        INSERT INTO @team_shares (team_name, team_pct) VALUES (@resolved_team_name, 100);
    END
    ELSE
    BEGIN
        RETURN N'Other';
    END;

    -- Merge repeated teams, omit 100%, retain blend percentages and keep Corporate last.
    IF EXISTS (SELECT 1 FROM @team_shares)
    BEGIN
        SELECT @final_bonus_team = STRING_AGG
        (
            CAST
            (
                CASE WHEN t.team_pct = 100 THEN N''
                     ELSE CASE WHEN t.team_pct = FLOOR(t.team_pct)
                     THEN CONVERT(NVARCHAR(10), CONVERT(INT, t.team_pct))
                     ELSE CONVERT(NVARCHAR(10), CONVERT(DECIMAL(6, 1), t.team_pct))
                     END + N'% '
                END + t.team_name AS NVARCHAR(MAX)
            ), N' / '
        ) WITHIN GROUP (ORDER BY CASE WHEN t.team_name = N'Corporate' THEN 1 ELSE 0 END, t.team_name)
        FROM
        (
            SELECT team_name, SUM(team_pct) AS team_pct
            FROM @team_shares
            GROUP BY team_name
        ) AS t;
    END;

    RETURN @final_bonus_team;
END;
GO

-- SECTION 13: Objects/Functions/dbo._ufn_get_employee_bonus_team.sql
PRINT N'Objects/Functions/dbo._ufn_get_employee_bonus_team.sql';
GO

CREATE OR ALTER FUNCTION dbo._ufn_get_employee_bonus_team
(
    @id_step INT,
    @id_comp_group INT,
    @step_1 NVARCHAR(255),
    @step_2 NVARCHAR(255),
    @step_3 NVARCHAR(255)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @comp_round_extended NVARCHAR(256) = dbo._ufn_get_comp_round_extended(@id_step, @id_comp_group);
    RETURN dbo._fn_get_bonus_team(@comp_round_extended, @step_1, @step_2, @step_3);
END;
GO

-- SECTION 14: Objects/Stored Procedures/dbo.SP_RefreshEmployeeCompRoundException.sql
PRINT N'Objects/Stored Procedures/dbo.SP_RefreshEmployeeCompRoundException.sql';
GO

CREATE OR ALTER PROCEDURE dbo.SP_RefreshEmployeeCompRoundException
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Same process Comp Group source as Kernel_SP_Process_DataOnChange.
        -- Materialize candidates before touching the large involvement timeline.
        SELECT DISTINCT pps.id_step, pps.id_payee, pps.start_step,
               py.codePayee AS gpid, approval.idCompGroup AS id_comp_group
        INTO #candidates
        FROM dbo.k_m_plans AS plan_def
        INNER JOIN dbo.k_m_plans_payees_steps AS pps ON pps.id_plan = plan_def.id_plan
        INNER JOIN dbo.py_Payee AS py ON py.idPayee = pps.id_payee
        INNER JOIN dbo.PEPSICO_Process_BonusApproval AS approval
            ON approval.idPayee = pps.id_payee
           AND approval.start_date_histo = pps.start_step
        WHERE plan_def.name_plan = N'Bonus'
          AND EXISTS
          (
              SELECT 1 FROM dbo.PEPSICO_CompRoundExtendedRule AS rule_def
              WHERE rule_def.id_comp_group = approval.idCompGroup
          );

        SELECT DISTINCT candidate.id_step, candidate.id_comp_group, timeline.DivisionCode_nk AS division_code
        INTO #candidate_divisions
        FROM #candidates AS candidate
        INNER JOIN dbo.PEPSICO_EmpTimeline_BonusInvolvement_FYandOvrdDates AS timeline
            ON timeline.GPID = candidate.gpid
           AND timeline.StartDateInvolvement = candidate.start_step;

        -- NULL plus a known code is ambiguous too; identical duplicate rows are harmless.
        IF EXISTS
        (
            SELECT id_step FROM #candidate_divisions
            GROUP BY id_step
            HAVING COUNT(*) > 1
        )
            THROW 51020, 'Ambiguous Comp Group or Division for a Bonus involvement; exception cache was not refreshed.', 1;

        SELECT candidate.id_step, candidate.id_comp_group, candidate.division_code, rule_def.comp_round_extended
        INTO #exceptions
        FROM #candidate_divisions AS candidate
        INNER JOIN dbo.PEPSICO_CompRoundExtendedRule AS rule_def
            ON rule_def.id_comp_group = candidate.id_comp_group
           AND rule_def.division_code = candidate.division_code
        INNER JOIN dbo.PEPSICO_CompGroup AS comp_group ON comp_group.idCompGroup = candidate.id_comp_group
        WHERE rule_def.comp_round_extended <> comp_group.CompGroupName;

        BEGIN TRANSACTION;
        -- Serialize publication; DELETE and INSERT are one atomic replacement, including empty results.
        DELETE FROM dbo.PEPSICO_EmployeeCompRoundException WITH (TABLOCKX);
        INSERT INTO dbo.PEPSICO_EmployeeCompRoundException
            (id_step, id_comp_group, division_code, comp_round_extended, refreshed_at)
        SELECT id_step, id_comp_group, division_code, comp_round_extended, SYSUTCDATETIME()
        FROM #exceptions;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- SECTION 15: Objects/Views/dbo.vPEPSICO_bonus_team_step1_business.sql
PRINT N'Objects/Views/dbo.vPEPSICO_bonus_team_step1_business.sql';
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step1_business]
AS
	select 
		cgbt.BTBusinessCode,
		CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,
		ISNULL(cgbt.idCompGroup,0) as idCompGroup
	from PEPSICO_Bonus_Team_Business_per_CompGroup as cgbt
	join PEPSICO_Bonus_Team_Business AS btb
		on btb.BTBusinessCode = cgbt.BTBusinessCode
	ORDER BY CASE WHEN btb.BTBusinessValue = N'Other' THEN 1 ELSE 0 END,
		btb.BTBusinessValue ASC
	OFFSET 0 ROWS;
GO

-- SECTION 16: Objects/Views/dbo.vPEPSICO_bonus_team_step2_business.sql
PRINT N'Objects/Views/dbo.vPEPSICO_bonus_team_step2_business.sql';
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step2_business]
AS
SELECT
    bcg.BTBusinessCode,
    CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,
    ISNULL(bcg.idCompGroup, 0) AS idCompGroup,
    b.BTBusinessCode AS BTBusiness_filter
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg
INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb
    ON btb.BTBusinessCode = bcg.BTBusinessCode
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
WHERE b.BTBusinessCode <> bcg.BTBusinessCode
    AND NOT EXISTS
    (
        SELECT 1
        FROM dbo.PEPSICO_CompGroup AS cg
        WHERE cg.idCompGroup = bcg.idCompGroup
            AND cg.CompGroupName = N'North America'
    )
UNION ALL

SELECT DISTINCT
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusinessCode,
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(100)) AS BTBusinessValue,
    cg.idCompGroup,
    b.BTBusinessCode AS BTBusiness_filter
FROM dbo.PEPSICO_CompGroup AS cg
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b
WHERE cg.CompGroupName = N'North America';
GO

-- SECTION 17: Objects/Views/dbo.vPEPSICO_bonus_team_step3_business.sql
PRINT N'Objects/Views/dbo.vPEPSICO_bonus_team_step3_business.sql';
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_bonus_team_step3_business]  
AS  
/******************************************************************************  
Purpose: Data source for the Bonus process field bonus_team_step_3 drop-down.  
         Cascading filters (k_m_fields_relation):  
           idCompGroup          <- Comp Group of the process row  
           BTBusiness_filter_1  <- value selected in bonus_team_step_1  
           BTBusiness_filter_2  <- value selected in bonus_team_step_2  
         Returns Businesses mapped to the Comp Group, excluding the  
         Businesses already chosen in Step 1 and Step 2.  
******************************************************************************/  
SELECT  
    bcg.BTBusinessCode,  
    CASE WHEN btb.BTBusinessValue = N'Other' THEN btb.BTBusinessValue ELSE CONCAT(N' ', btb.BTBusinessValue) END AS BTBusinessValue,  
    ISNULL(bcg.idCompGroup, 0) AS idCompGroup,  
    s1.BTBusinessCode AS BTBusiness_filter_1,  
    s2.BTBusinessCode AS BTBusiness_filter_2  
FROM dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS bcg  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS btb  
    ON btb.BTBusinessCode = bcg.BTBusinessCode  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s1  
    ON ISNULL(s1.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)  
INNER JOIN dbo.PEPSICO_Bonus_Team_Business_per_CompGroup AS s2  
    ON ISNULL(s2.idCompGroup, 0) = ISNULL(bcg.idCompGroup, 0)  
WHERE s1.BTBusinessCode <> s2.BTBusinessCode  
    AND bcg.BTBusinessCode <> s1.BTBusinessCode  
    AND bcg.BTBusinessCode <> s2.BTBusinessCode  
    AND NOT EXISTS  
    (  
        SELECT 1  
        FROM dbo.PEPSICO_CompGroup AS cg  
        WHERE cg.idCompGroup = bcg.idCompGroup  
            AND cg.CompGroupName = N'North America'
    )  
UNION ALL  
  
SELECT DISTINCT  
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusinessCode,
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(100)) AS BTBusinessValue,
    cg.idCompGroup,  
    b.BTBusinessCode AS BTBusiness_filter_1,  
    CAST(N'Not Applicable for North America Bonus Design' AS NVARCHAR(50)) AS BTBusiness_filter_2
FROM dbo.PEPSICO_CompGroup AS cg  
CROSS JOIN dbo.PEPSICO_Bonus_Team_Business AS b  
WHERE cg.CompGroupName = N'North America';
GO

-- SECTION 18: Scripts/PostDeploy/30_Wrappers/Process/Bonus.sql
PRINT N'Scripts/PostDeploy/30_Wrappers/Process/Bonus.sql';
GO

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

-- SECTION 19: Scripts/PostDeploy/40_Config/add_step_3_to_bonus_process.sql
PRINT N'Scripts/PostDeploy/40_Config/add_step_3_to_bonus_process.sql';
GO

declare @now datetime = getutcdate()
declare @plan_id int = (select top 1 id_plan from k_m_plans where name_plan like 'Bonus')
declare @template_id int = 
	(select top 1 id_base_grid from k_m_type_plan where id_type_plan =
		(select top 1 id_type_plan from k_m_plans where id_plan = @plan_id))
declare @indicator_name nvarchar(100) = 'pr_ind_bonus_team' 
declare @id_ind int = (select top 1 id_ind from k_m_indicators where name_ind = @indicator_name)


if not exists (select 1 from k_m_fields where code_field = 'bonus_team_step_3')
insert into k_m_fields
(name_field,label_field,code_field,width,id_unit,id_field_type,id_control_type,type_value,is_olap,date_create_field,show_min,show_max,thousand_separator,decimal_precision,id_access_type,is_percentage_used,show_aggregated_result,threshold_min_value,threshold_max_value,is_threshold_enabled,show_only_aggregated_result ,aggregation_type)
select
	'Bonus Team Step 3','pr_col_bonus_team_step_3','bonus_team_step_3',194,-3,-3,-7,1,0,@now,1,1,0,0,-1,0,0,-1,0,0,0,1

declare @id_ind_field_3 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_3')
declare @id_ind_field_2 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_2')
declare @sort_ind_field_2 int = (select top 1 sort from k_m_indicators_fields where id_field = @id_ind_field_2)
declare @sort_ind int =  (select top 1 sort_plan_ind from k_m_plans_indicators where id_ind = @id_ind)

-- sort shift and indicator link only on first run
if not exists (select 1 from k_m_indicators_fields where id_ind = @id_ind and id_field = @id_ind_field_3)
begin
	update k_m_indicators_fields
	set sort = sort + 1
	where id_ind = @id_ind
	and sort > @sort_ind_field_2

	update k_m_plans_informations
	set sort = sort + 1
	where sort > @sort_ind
		and id_plan = @plan_id

	update k_m_plans_indicators
	set sort_plan_ind = sort_plan_ind + 1
	where sort_plan_ind > @sort_ind
		and id_plan = @plan_id

	insert into k_m_indicators_fields
	(id_ind
	,id_field
	,sort)
	select @id_ind, @id_ind_field_3, @sort_ind_field_2 + 1
end


insert into k_m_plan_display_field 
	(id_plan_display
	,id_indicator_field
	,available_plan_display_field
	,show_plan_display_field
	,optional_show_plan_display_field
	)
select 
	pd.id_plan_display
	,fi.id_indicator_field
	,1,1,1
from k_m_plan_display pd 
join k_profiles pr
	on pr.id_profile = pd.id_profile
	and pd.id_plan = @plan_id
	and pr.name_profile in 
	(
	'Administrator'
	,'Manager'
	,'Manager LG8'
	,'Human Resource'
	,'Human Resources LG8'
	,'Comp Admin'
	,'Super User'
	) 
join k_m_indicators_fields fi
	on fi.id_field in (@id_ind_field_3)
where not exists
	(select 1 from k_m_plan_display_field pdf
	where pdf.id_plan_display = pd.id_plan_display
		and pdf.id_indicator_field = fi.id_indicator_field)

--rollback



GO

insert into k_m_workflow_step_group_detail
	(id_wflstepgroup
	,id_field
	,is_editable
	,id_ind
	,is_readable)
select
	s.id_wflstepgroup
	,(select top 1 id_field from k_m_fields where name_field = 'Bonus Team Step 3')
	,s.is_editable
	,s.id_ind
	,s.is_readable
from k_m_workflow_step_group_detail s
where s.id_field = (select top 1 id_field from k_m_fields where name_field = 'Bonus Team Step 1')
	and not exists
		(select 1 from k_m_workflow_step_group_detail d
		where d.id_wflstepgroup = s.id_wflstepgroup
			and d.id_ind = s.id_ind
			and d.id_field = (select top 1 id_field from k_m_fields where name_field = 'Bonus Team Step 3'))


GO
/******************************************************************************
Purpose: Configure the Bonus process field bonus_team_step_3 as a cascading
         drop-down sourced from dbo.vPEPSICO_bonus_team_step3_business:
           - filtered by the Comp Group of the process row,
           - excluding the Business selected in bonus_team_step_1,
           - excluding the Business selected in bonus_team_step_2.
         Idempotent: all ids are resolved by name, relations are re-created.
Prereqs: - dbo.vPEPSICO_bonus_team_step3_business deployed,
         - field bonus_team_step_3 exists in the Bonus process (pr_ind_bonus_team),
         - bonus_team_step_1 already has its Comp Group relation (IC_ column).
******************************************************************************/

/* Register the view and its columns in k_referential_tables_views(_fields) */
EXEC sp_client_std_synchronize 'vPEPSICO_bonus_team_step3_business', 'view', 0;
GO


SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    DECLARE
        @id_plan                INT
    ,   @id_ind                 INT
    ,   @id_field_step_1        INT
    ,   @id_field_step_2        INT
    ,   @id_field_step_3        INT
    ,   @id_control_type        INT
    ,   @id_table_view          INT
    ,   @id_tv_code             INT
    ,   @id_tv_value            INT
    ,   @id_tv_comp_group       INT
    ,   @id_tv_filter_1         INT
    ,   @id_tv_filter_2         INT
    ,   @alias_step_1           NVARCHAR(255)
    ,   @alias_step_2           NVARCHAR(255)
    ,   @alias_step_3           NVARCHAR(255)
    ,   @parent_comp_group      NVARCHAR(255);

    SELECT @id_plan = id_plan
    FROM dbo.k_m_plans
    WHERE name_plan = 'Bonus';

    SELECT @id_ind = id_ind
    FROM dbo.k_m_indicators
    WHERE name_ind = 'pr_ind_bonus_team';

    SELECT
        @id_field_step_1 = MAX(CASE WHEN code_field = 'bonus_team_step_1' THEN id_field END)
    ,   @id_field_step_2 = MAX(CASE WHEN code_field = 'bonus_team_step_2' THEN id_field END)
    ,   @id_field_step_3 = MAX(CASE WHEN code_field = 'bonus_team_step_3' THEN id_field END)
    ,   @id_control_type = MAX(CASE WHEN code_field = 'bonus_team_step_1' THEN id_control_type END)
    FROM dbo.k_m_fields
    WHERE code_field IN ('bonus_team_step_1', 'bonus_team_step_2', 'bonus_team_step_3');

    SELECT @id_table_view = id_table_view
    FROM dbo.k_referential_tables_views
    WHERE name_table_view = 'vPEPSICO_bonus_team_step3_business';

    SELECT
        @id_tv_code         = MAX(CASE WHEN name_field = 'BTBusinessCode'      THEN id_field END)
    ,   @id_tv_value        = MAX(CASE WHEN name_field = 'BTBusinessValue'     THEN id_field END)
    ,   @id_tv_comp_group   = MAX(CASE WHEN name_field = 'idCompGroup'         THEN id_field END)
    ,   @id_tv_filter_1     = MAX(CASE WHEN name_field = 'BTBusiness_filter_1' THEN id_field END)
    ,   @id_tv_filter_2     = MAX(CASE WHEN name_field = 'BTBusiness_filter_2' THEN id_field END)
    FROM dbo.k_referential_tables_views_fields
    WHERE id_table_view = @id_table_view;

    IF @id_plan IS NULL OR @id_ind IS NULL
        THROW 50001, 'Bonus plan or indicator pr_ind_bonus_team not found.', 1;

    IF @id_field_step_1 IS NULL OR @id_field_step_2 IS NULL OR @id_field_step_3 IS NULL
        THROW 50002, 'Field bonus_team_step_1, bonus_team_step_2 or bonus_team_step_3 not found in k_m_fields.', 1;

    IF @id_tv_code IS NULL OR @id_tv_value IS NULL OR @id_tv_comp_group IS NULL
        OR @id_tv_filter_1 IS NULL OR @id_tv_filter_2 IS NULL
        THROW 50003, 'vPEPSICO_bonus_team_step3_business is not registered or misses columns.', 1;

    /* Field alias format used by process metadata: <id_plan>_<id_ind>_<id_field> */
    SET @alias_step_1 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_1);
    SET @alias_step_2 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_2);
    SET @alias_step_3 = CONCAT(@id_plan, '_', @id_ind, '_', @id_field_step_3);

    /* Reuse the Comp Group parent (IC_<id_column> of Bonus Verification grid) already used by Step 1 */
    SELECT TOP (1) @parent_comp_group = id_parent_field
    FROM dbo.k_m_fields_relation
    WHERE id_plan = @id_plan
        AND id_field = @alias_step_1
        AND id_parent_field LIKE 'IC[_]%'
    ORDER BY id_field_relation DESC;

    IF @parent_comp_group IS NULL
        THROW 50004, 'Comp Group relation for bonus_team_step_1 not found in k_m_fields_relation.', 1;

    BEGIN TRANSACTION;

        UPDATE dbo.k_m_fields
        SET id_control_type     = @id_control_type
        ,   combo_table_view    = @id_table_view
        ,   combo_value_field   = @id_tv_code
        ,   combo_text_field    = @id_tv_value
        WHERE id_field = @id_field_step_3;

        DELETE FROM dbo.k_m_fields_relation
        WHERE id_plan = @id_plan
            AND id_field = @alias_step_3;

        INSERT INTO dbo.k_m_fields_relation (id_plan, id_field, id_parent_field, id_field_table_view)
        VALUES
            (@id_plan, @alias_step_3, @parent_comp_group, @id_tv_comp_group)
        ,   (@id_plan, @alias_step_3, @alias_step_1,      @id_tv_filter_1)
        ,   (@id_plan, @alias_step_3, @alias_step_2,      @id_tv_filter_2);

    COMMIT TRANSACTION;

    PRINT CONCAT('bonus_team_step_3 drop-down configured: field ', @alias_step_3
        , ', table view ', @id_table_view, ', Comp Group parent ', @parent_comp_group, '.');
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

declare @id_step_3 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_3')
declare @id_step_1 int = (select top 1 id_field from k_m_fields where code_field = 'bonus_team_step_1')
declare @id_ind int = (select top 1 id_ind from k_m_indicators where name_ind = 'pr_ind_bonus_team')
declare @id_ind_field_step_1 int = (select TOP 1 id_indicator_field from k_m_indicators_fields where id_field = @id_step_1 and id_ind = @id_ind)
declare @id_ind_field_step_3 int = (select TOP 1 id_indicator_field from k_m_indicators_fields where id_field = @id_step_3 and id_ind = @id_ind)


insert into [k_m_plans_field_validation]
	(id_plan
	,id_indicator_field
	,id_planInfo
	,formula
	,action_false_allow_saving
	,action_false_show_error
	,action_false_error_message
	,action_false_use_field_style
	,action_false_text_color
	,action_false_border_color
	,action_false_background_color
	,action_true_use_field_style
	,action_true_text_color
	,action_true_border_color
	,action_true_background_color
	,id_plan_indicator
	,action_false_show_error_on_change
	,enable_client_side_validation
	,action_false_allow_editing)
select 
	id_plan
	,@id_ind_field_step_3
	,id_planInfo
	,formula
	,action_false_allow_saving
	,action_false_show_error
	,action_false_error_message
	,action_false_use_field_style
	,action_false_text_color
	,action_false_border_color
	,action_false_background_color
	,action_true_use_field_style
	,action_true_text_color
	,action_true_border_color
	,action_true_background_color
	,id_plan_indicator
	,action_false_show_error_on_change
	,enable_client_side_validation
	,action_false_allow_editing
from [dbo].[k_m_plans_field_validation] v
WHERE v.id_indicator_field =  @id_ind_field_step_1
	AND NOT EXISTS
		(SELECT 1 FROM [dbo].[k_m_plans_field_validation] v3
		WHERE v3.id_plan = v.id_plan
			AND v3.id_indicator_field = @id_ind_field_step_3)

/* Formula items: copy from the Step 1 validation, pointing Step 1 references to Step 3 */
INSERT INTO [dbo].[k_m_plans_field_validation_formula_items]
	(id_plans_field_validation
	,id_indicator_field
	,id_planInfo)
SELECT
	v3.id_plans_field_validation
	,CASE WHEN fi1.id_indicator_field = @id_ind_field_step_1 THEN @id_ind_field_step_3 ELSE fi1.id_indicator_field END
	,fi1.id_planInfo
FROM [dbo].[k_m_plans_field_validation] v1
JOIN [dbo].[k_m_plans_field_validation_formula_items] fi1
	ON fi1.id_plans_field_validation = v1.id_plans_field_validation
JOIN [dbo].[k_m_plans_field_validation] v3
	ON v3.id_plan = v1.id_plan
	AND v3.id_indicator_field = @id_ind_field_step_3
WHERE v1.id_indicator_field = @id_ind_field_step_1
	AND NOT EXISTS
		(SELECT 1 FROM [dbo].[k_m_plans_field_validation_formula_items] fi3
		WHERE fi3.id_plans_field_validation = v3.id_plans_field_validation)
GO

/* Translation for the Step 3 column header, derived from the Step 2 labels */
IF NOT EXISTS (SELECT 1 FROM dbo.PEPSICO_system_translations WHERE field_key = 'pr_col_bonus_team_step_3')
BEGIN
	INSERT INTO dbo.PEPSICO_system_translations
		(field_key
		,label_english
		,label_chinese
		,label_polish
		,label_german
		,label_portugees
		,label_spanish
		,label_italian
		,label_french
		,label_turkish)
	SELECT
		'pr_col_bonus_team_step_3'
		,REPLACE(label_english,   '2', '3')
		,REPLACE(label_chinese,   '2', '3')
		,REPLACE(label_polish,    '2', '3')
		,REPLACE(label_german,    '2', '3')
		,REPLACE(label_portugees, '2', '3')
		,REPLACE(label_spanish,   '2', '3')
		,REPLACE(label_italian,   '2', '3')
		,REPLACE(label_french,    '2', '3')
		,REPLACE(label_turkish,   '2', '3')
	FROM dbo.PEPSICO_system_translations
	WHERE field_key = 'pr_col_bonus_team_step_2';

	/* Fallback when Step 2 has no translation row */
	IF @@ROWCOUNT = 0
		INSERT INTO dbo.PEPSICO_system_translations (field_key, label_english)
		VALUES ('pr_col_bonus_team_step_3', 'Bonus Team Step 3');
END

/* Push translations to rps_localization */
EXEC dbo.PEPSICO_SP_Refresh_Translations;
GO
/* Report header for the new SelectBusiness3 column in Report_Bonus_Verification, derived from rep_select_business2 */
INSERT INTO dbo.PEPSICO_config_translation_for_reports
	(report_name
	,english_key
	,culture
	,[value])
SELECT
	t2.report_name
	,'rep_select_business3'
	,t2.culture
	,REPLACE(t2.[value], '2', '3')
FROM dbo.PEPSICO_config_translation_for_reports t2
WHERE t2.english_key = 'rep_select_business2'
	AND NOT EXISTS
		(SELECT 1 FROM dbo.PEPSICO_config_translation_for_reports t3
		WHERE ISNULL(t3.report_name, '') = ISNULL(t2.report_name, '')
			AND t3.culture = t2.culture
			AND t3.english_key = 'rep_select_business3');
GO

-- SECTION 20: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_step3_validation.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_step3_validation.sql';
GO

-- Step 2/3 client editability. Requires registered Step 3 metadata.
-- Retains the status/Double Hat condition from Step 1; rerunnable.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_plan INT = (SELECT idPlanBonusApproval FROM dbo.vPEPSICO_FocalPoint_Parameters);
    DECLARE @id_ind INT =
    (
        SELECT i.id_ind
        FROM dbo.k_m_indicators AS i
        INNER JOIN dbo.k_m_plans_indicators AS pi ON pi.id_ind = i.id_ind
        WHERE pi.id_plan = @id_plan AND i.comment_ind = N'bonus_team'
    );
    DECLARE @id_field_step_1 INT = (SELECT id_field FROM dbo.k_m_fields WHERE code_field = N'bonus_team_step_1');
    DECLARE @id_step_1 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_1'
    );
    DECLARE @id_step_2 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_2'
    );
    DECLARE @id_step_3 INT =
    (
        SELECT inf.id_indicator_field
        FROM dbo.k_m_indicators_fields AS inf
        INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
        WHERE inf.id_ind = @id_ind AND f.code_field = N'bonus_team_step_3'
    );
    DECLARE @other_code NVARCHAR(50) =
    (
        SELECT DISTINCT BTBusinessCode
        FROM dbo.vPEPSICO_bonus_team_step1_business
        WHERE LTRIM(RTRIM(REPLACE(BTBusinessValue, NCHAR(160), N' '))) = N'Other'
    );

    IF @id_plan IS NULL OR @id_ind IS NULL OR @id_step_1 IS NULL
        OR @id_step_2 IS NULL OR @id_step_3 IS NULL
        OR @id_field_step_1 IS NULL OR @other_code IS NULL
        THROW 50001, 'Missing Bonus metadata or Other code in the Step 1 dropdown.', 1;

    IF (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_1) <> 1
        OR (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
            WHERE id_plan = @id_plan AND id_indicator_field = @id_step_2) <> 1
        THROW 50002, 'Expected exactly one existing validation for Step 1 and Step 2.', 1;

    IF (SELECT COUNT(1) FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_3) > 1
        THROW 50003, 'Multiple Step 3 validations exist; resolve duplicates first.', 1;

    DECLARE @base_formula NVARCHAR(MAX) =
    (
        SELECT formula FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_1
    );
    IF NULLIF(LTRIM(RTRIM(@base_formula)), N'') IS NULL
        THROW 50004, 'Step 1 validation formula is empty.', 1;

    IF CHARINDEX(NCHAR(39), @other_code) > 0 OR CHARINDEX(NCHAR(92), @other_code) > 0
        THROW 50005, 'Dropdown code contains unsupported formula literal characters.', 1;

    -- Compare the Other dropdown code to the native [indicator_field] reference.
    -- The Step 1 selection contains BTBusinessCode, not its displayed name.
    DECLARE @formula NVARCHAR(MAX) = CONCAT(
        N'(', @base_formula, N')&&[', @id_ind, N'_', @id_field_step_1,
        N']!=', NCHAR(39), @other_code, NCHAR(39));

    IF NOT EXISTS (SELECT 1 FROM dbo.k_m_plans_field_validation
                   WHERE id_plan = @id_plan AND id_indicator_field = @id_step_3)
    BEGIN
        INSERT INTO dbo.k_m_plans_field_validation
        (
            id_plan, id_indicator_field, id_planInfo, formula,
            action_false_allow_saving, action_false_show_error, action_false_error_message,
            action_false_use_field_style, action_false_text_color, action_false_border_color,
            action_false_background_color, action_true_use_field_style, action_true_text_color,
            action_true_border_color, action_true_background_color, id_plan_indicator,
            action_false_show_error_on_change, enable_client_side_validation, action_false_allow_editing
        )
        SELECT id_plan, @id_step_3, id_planInfo, formula,
               action_false_allow_saving, action_false_show_error, action_false_error_message,
               action_false_use_field_style, action_false_text_color, action_false_border_color,
               action_false_background_color, action_true_use_field_style, action_true_text_color,
               action_true_border_color, action_true_background_color, id_plan_indicator,
               action_false_show_error_on_change, enable_client_side_validation, action_false_allow_editing
        FROM dbo.k_m_plans_field_validation
        WHERE id_plan = @id_plan AND id_indicator_field = @id_step_2;
    END;

    -- Preserve existing action/style settings; change only formula and editability flags.
    UPDATE dbo.k_m_plans_field_validation
    SET formula = @formula,
        enable_client_side_validation = 1,
        action_false_allow_editing = 0
    WHERE id_plan = @id_plan AND id_indicator_field IN (@id_step_2, @id_step_3);

    COMMIT TRANSACTION;

    SELECT v.id_plans_field_validation, v.id_plan, f.code_field, v.formula,
           v.enable_client_side_validation, v.action_false_allow_editing
    FROM dbo.k_m_plans_field_validation AS v
    INNER JOIN dbo.k_m_indicators_fields AS inf ON inf.id_indicator_field = v.id_indicator_field
    INNER JOIN dbo.k_m_fields AS f ON f.id_field = inf.id_field
    WHERE v.id_plan = @id_plan AND v.id_indicator_field IN (@id_step_2, @id_step_3);
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 21: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_00_comp_round_extended_rules.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_00_comp_round_extended_rules.sql';
GO

-- Confirmed Comp Group + Division mappings; resolve IDs by name across fiscal years.
-- Run before deploy_bonus_team_allocation_rule.sql, after deploying the configuration table.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    MERGE INTO dbo.PEPSICO_CompRoundExtendedRule WITH (HOLDLOCK) AS target
    USING
    (
        SELECT cg.idCompGroup AS id_comp_group, seed.division_code, seed.comp_round_extended
        FROM (VALUES
            (N'Global S&T', 'D101', N'Global S&T'),
            (N'Corporate GGF', 'D034', N'Global R&D'),
            (N'Corporate GGF', 'D033', N'Global Procurement')
        ) AS seed(comp_group_name, division_code, comp_round_extended)
        INNER JOIN dbo.PEPSICO_CompGroup AS cg
            ON cg.CompGroupName = seed.comp_group_name
    ) AS source
        ON target.id_comp_group = source.id_comp_group
       AND target.division_code = source.division_code
    WHEN MATCHED AND target.comp_round_extended <> source.comp_round_extended THEN
        UPDATE SET comp_round_extended = source.comp_round_extended
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (id_comp_group, division_code, comp_round_extended)
        VALUES (source.id_comp_group, source.division_code, source.comp_round_extended);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 22: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping.sql';
GO

-- Merge source snapshot by names resolved against the target environment.
-- Preserve target rows without a matching source; skip unresolved dictionary names.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Exported codes without dictionary names are deliberately not seeded:
    -- BTB0, BTB091, BTB094, BTB097, BTB100, BTB126, BTB139, BTB140, Not Applicable for North America Bonus Design.
    DECLARE @mapping_seed TABLE
    (
        sector_name NVARCHAR(100) NOT NULL,
        org_unit_name NVARCHAR(100) NULL,
        business_name NVARCHAR(500) NOT NULL,
        is_region BIT NOT NULL
    );

    INSERT INTO @mapping_seed
        (sector_name, org_unit_name, business_name, is_region)
    VALUES
        (N'APAC', NULL, N'ANZ Foods', 0),
        (N'APAC', NULL, N'APAC Foods Region', 1),
        (N'APAC', NULL, N'Asia Foods', 0),
        (N'APAC', NULL, N'Asia Foods PO1', 0),
        (N'APAC', NULL, N'B&C Po1', 0),
        (N'APAC', NULL, N'Be & Cheery', 0),
        (N'APAC', NULL, N'Corporate', 0),
        (N'APAC', NULL, N'GCR Food PO1', 0),
        (N'APAC', NULL, N'Greater China Foods', 0),
        (N'APAC', NULL, N'IndoChina Foods', 0),
        (N'APAC', NULL, N'Indonesia Foods', 0),
        (N'EMEA', NULL, N'BCCA', 0),
        (N'EMEA', NULL, N'Corporate', 0),
        (N'EMEA', NULL, N'EMEA Region', 1),
        (N'EMEA', NULL, N'RBCCA', 0),
        (N'EMEA', NULL, N'Russia', 0),
        (N'EMEA', NULL, N'Turkey', 0),
        (N'EMEA', NULL, N'UKI', 0),
        (N'EMEA', N'East Europe', N'East Balkans', 0),
        (N'EMEA', N'East Europe', N'East Europe', 0),
        (N'EMEA', N'East Europe', N'SEEB', 0),
        (N'EMEA', N'East Europe', N'Poland', 0),
        (N'EMEA', N'East Europe', N'Ukraine', 0),
        (N'EMEA', N'MENAPAK', N'Egypt Foods & COBO', 0),
        (N'EMEA', N'MENAPAK', N'MENAPAK', 0),
        (N'EMEA', N'MENAPAK', N'Middle East Foods', 0),
        (N'EMEA', N'MENAPAK', N'Pakistan Foods', 0),
        (N'EMEA', N'MENAPAK', N'Southern Africa', 0),
        (N'EMEA', N'Western Europe', N'BeNeLux', 0),
        (N'EMEA', N'Western Europe', N'France', 0),
        (N'EMEA', N'Western Europe', N'GroW', 0),
        (N'EMEA', N'Western Europe', N'Iberia', 0),
        (N'EMEA', N'Western Europe', N'Western Europe', 0),
        (N'International Beverages', NULL, N'ANZ FOBO', 0),
        (N'International Beverages', NULL, N'Asia', 0),
        (N'International Beverages', NULL, N'Corporate', 0),
        (N'International Beverages', NULL, N'Europe FOBO', 0),
        (N'International Beverages', NULL, N'Greater China FOBO', 0),
        (N'International Beverages', NULL, N'India Beverages', 0),
        (N'International Beverages', NULL, N'India Foods', 0),
        (N'International Beverages', NULL, N'India PO1', 0),
        (N'International Beverages', NULL, N'Intl. Beverages', 1),
        (N'International Beverages', NULL, N'LATAM FOBO', 0),
        (N'International Beverages', NULL, N'Lipton JV North America', 0),
        (N'International Beverages', NULL, N'MEA FOBO', 0),
        (N'International Beverages', NULL, N'Pakistan FOBO', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMEA ', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton LATAM Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMEA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMESA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton LATAM', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton AMESA', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton APAC', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton EU / AMEA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Global', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Europe Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton NA Technical', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton APAC Technical', 0),
        (N'International Beverages', NULL, N'PGCS China', 0),
        (N'International Beverages', NULL, N'PGCS India', 0),
        (N'International Beverages', NULL, N'PGCS Mexico', 0),
        (N'International Beverages', NULL, N'PGCS Pakistan', 0),
        (N'International Beverages', NULL, N'PGCS Global S&T', 0),
        (N'International Beverages', NULL, N'PGCS Uruguay', 0),
        (N'International Beverages', NULL, N'PGCS US', 0),
        (N'International Beverages', NULL, N'PGCS Global', 0),
        (N'International Beverages', NULL, N'Soda Stream Israel', 0),
        (N'International Beverages', NULL, N'Soda Stream NA', 0),
        (N'International Beverages', NULL, N'Soda Stream DACH', 0),
        (N'International Beverages', NULL, N'Soda Stream Argentina', 0),
        (N'International Beverages', NULL, N'Soda Stream ROW', 0),
        (N'International Beverages', NULL, N'Soda Stream Japan', 0),
        (N'International Beverages', NULL, N'Soda Stream South Africa', 0),
        (N'International Beverages', NULL, N'Soda Stream North EU', 0),
        (N'International Beverages', NULL, N'Soda Stream Australia', 0),
        (N'International Beverages', NULL, N'Soda Stream Global', 0),
        (N'International Beverages', NULL, N'Soda Stream Central EU', 0),
        (N'International Beverages', NULL, N'Soda Stream South EU', 0),
        (N'International Beverages', NULL, N'Soda Stream South Korea', 0),
        (N'International Beverages', NULL, N'SSA FOBO', 0),
        (N'International Beverages', NULL, N'Pepsi Lipton Europe', 0),
        (N'LATAM', NULL, N'Andean', 0),
        (N'LATAM', NULL, N'Caricam', 0),
        (N'LATAM', NULL, N'LATAM Foods Region', 1),
        (N'LATAM', NULL, N'PBF', 0),
        (N'LATAM', NULL, N'PMF', 0),
        (N'LATAM', NULL, N'South Cone', 0),
        (N'LATAM', NULL, N'Venezuela', 0),
        (N'North America', NULL, N'Costco Global', 0),
        (N'North America', NULL, N'Costco International', 0),
        (N'North America', NULL, N'North America Coffee Partnership', 0),
        (N'North America', NULL, N'Texoma PO1', 0),
        (N'North America', NULL, N'Walmart International', 0),
        (N'North America', NULL, N'Canada', 0),
        (N'North America', NULL, N'Corporate', 0),
        (N'North America', NULL, N'Digital Commerce', 0),
        (N'North America', NULL, N'FLC', 0),
        (N'North America', NULL, N'FLC SDL / Field Sales Leader', 0),
        (N'North America', NULL, N'North America', 1),
        (N'North America', NULL, N'PBC Canada', 0),
        (N'North America', NULL, N'PBUS', 0),
        (N'North America', NULL, N'7Eleven PBUS', 0),
        (N'North America', NULL, N'PBUS AFH', 0),
        (N'North America', NULL, N'PBUS Atlantic Region', 0),
        (N'North America', NULL, N'Costco PBUS', 0),
        (N'North America', NULL, N'Dollar General PBUS', 0),
        (N'North America', NULL, N'Kroger PBUS', 0),
        (N'North America', NULL, N'PBUS NorthCentral Region', 0),
        (N'North America', NULL, N'PBUS NorthEast Region', 0),
        (N'North America', NULL, N'Sam’s Club PBUS', 0),
        (N'North America', NULL, N'PBUS SouthEast Region', 0),
        (N'North America', NULL, N'Strategic Grocery Channel PBUS', 0),
        (N'North America', NULL, N'Target PBUS', 0),
        (N'North America', NULL, N'PBUS Texoma Region', 0),
        (N'North America', NULL, N'Walmart PBUS', 0),
        (N'North America', NULL, N'Walmart + Sam''s Club Global', 0),
        (N'North America', NULL, N'PBUS West Region', 0),
        (N'North America', NULL, N'PFUS', 0),
        (N'North America', NULL, N'PFUS Atlantic Region', 0),
        (N'North America', NULL, N'PFC Canada', 0),
        (N'North America', NULL, N'7Eleven PFUS', 0),
        (N'North America', NULL, N'Costco PFUS', 0),
        (N'North America', NULL, N'PFUS NorthCentral Region', 0),
        (N'North America', NULL, N'PFUS SouthEast Region', 0),
        (N'North America', NULL, N'PFUS Texoma Region', 0),
        (N'North America', NULL, N'PFUS NorthEast Region', 0),
        (N'North America', NULL, N'Dollar General PFUS', 0),
        (N'North America', NULL, N'Walmart PFUS', 0),
        (N'North America', NULL, N'Sam’s Club PFUS', 0),
        (N'North America', NULL, N'Walmart + Sam’s Club PFUS', 0),
        (N'North America', NULL, N'PFUS West Region', 0),
        (N'North America', NULL, N'Target PFUS', 0),
        (N'North America', NULL, N'PFUS Quaker', 0),
        (N'North America', NULL, N'Strategic Grocery Channel PFUS', 0),
        (N'North America', NULL, N'Kroger PFUS', 0),
        (N'North America', NULL, N'poppi', 0),
        (N'North America', NULL, N'Siete', 0),
        (N'North America', NULL, N'Sabra', 0),
        (N'North America', NULL, N'QFC', 0),
        (N'North America', NULL, N'7Eleven US PO1', 0),
        (N'North America', NULL, N'Dollar General US PO1', 0),
        (N'North America', NULL, N'Kroger US PO1', 0),
        (N'North America', NULL, N'Sam’s Club US PO1', 0),
        (N'North America', NULL, N'Strategic Grocery Channel US PO1', 0),
        (N'North America', NULL, N'Target US PO1', 0),
        (N'North America', NULL, N'Walmart US PO1', 0),
        (N'North America', NULL, N'Walmart + Sam’s Club US PO1', 0);

    -- Normalize NBSP and typographic apostrophes on both sides.
    ;WITH business_dictionary AS
    (
        SELECT
            LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(b.BTBusinessValue, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39)))) AS business_name,
            b.BTBusinessCode AS bt_business_code
        FROM dbo.PEPSICO_Bonus_Team_Business AS b
    ),
    unique_business AS
    (
        -- MIN only projects the one distinct code; ambiguous names are skipped.
        SELECT business_name, MIN(bt_business_code) AS bt_business_code
        FROM business_dictionary
        GROUP BY business_name
        HAVING COUNT(DISTINCT bt_business_code) = 1
    )
    MERGE INTO dbo.PEPSICO_bonus_team_business_mapping WITH (HOLDLOCK) AS target
    USING
    (
        SELECT DISTINCT s.sector_name, s.org_unit_name, b.bt_business_code, s.is_region
        FROM @mapping_seed AS s
        INNER JOIN unique_business AS b
            ON b.business_name = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(s.business_name, NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39))))
    ) AS source
        ON target.sector_name = source.sector_name
       AND (target.org_unit_name = source.org_unit_name
            OR (target.org_unit_name IS NULL AND source.org_unit_name IS NULL))
       AND target.bt_business_code = source.bt_business_code
    WHEN MATCHED AND target.is_region <> source.is_region THEN
        UPDATE SET is_region = source.is_region
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (sector_name, org_unit_name, bt_business_code, is_region)
        VALUES (source.sector_name, source.org_unit_name, source.bt_business_code, source.is_region);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 23: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping_cleanup.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping_cleanup.sql';
GO

-- Remove the red-marked mappings from Anchor Bonus Team in Bonus Teams Design 11.02.2026.xlsx.
-- Also retire North America's Lipton mapping under the agreed IB-only working assumption.
-- Resolve business codes by name and preserve all mappings outside these explicit scopes.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DELETE mapping
    FROM dbo.PEPSICO_bonus_team_business_mapping AS mapping
    INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS business
        ON business.BTBusinessCode = mapping.bt_business_code
    WHERE mapping.sector_name = N'EMEA'
      AND mapping.org_unit_name = N'MENAPAK'
      AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(business.BTBusinessValue,
          NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39))))
          IN (N'Ethiopia Foods', N'Nigeria Foods');

    DELETE mapping
    FROM dbo.PEPSICO_bonus_team_business_mapping AS mapping
    INNER JOIN dbo.PEPSICO_Bonus_Team_Business AS business
        ON business.BTBusinessCode = mapping.bt_business_code
    WHERE mapping.sector_name = N'North America'
      AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(business.BTBusinessValue,
          NCHAR(160), N' '), NCHAR(146), NCHAR(39)), NCHAR(8217), NCHAR(39))))
          = N'Lipton JV North America';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 24: Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_allocation_rule.sql
PRINT N'Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_allocation_rule.sql';
GO

-- Merge known allocation defaults for base and configured extended Comp Round names.
-- Run after deploy_bonus_team_00_comp_round_extended_rules.sql.
-- Custom extended allocation rules outside this seed remain maintained separately.
-- Preserve unmatched target rows except superseded regional rules in the explicit scope below.
-- Skip unresolved dictionary names.
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @allocation_seed TABLE
    (
        comp_round_extended NVARCHAR(256) NOT NULL,
        number_of_businesses INT NOT NULL,
        split_rule NVARCHAR(200) NOT NULL,
        is_region BIT NOT NULL,
        corporate_override BIT NOT NULL
    );

    INSERT INTO @allocation_seed
        (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
    VALUES
        (N'APAC Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'APAC Foods', 1, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'100% Sector', 1, 0),
        (N'APAC Foods', 3, N'100% Sector', 1, 0),
        (N'APAC Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'APAC Foods', 3, N'100% Sector', 0, 0),
        (N'Corporate GGF', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Corporate GGF', 1, N'100% Sector', 1, 0),
        (N'Corporate GGF', 2, N'100% Corporate', 0, 0),
        (N'Corporate GGF', 3, N'100% Corporate', 0, 0),
        (N'Corporate GGF', 2, N'100% Corporate', 1, 0),
        (N'Corporate GGF', 3, N'100% Corporate', 1, 0),
        (N'EMEA Foods', 1, N'100% 1st Bonus Team', 0, 0),
        (N'EMEA Foods', 1, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'100% Sector', 1, 0),
        (N'EMEA Foods', 3, N'100% Sector', 1, 0),
        (N'EMEA Foods', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'EMEA Foods', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global Procurement', 1, N'100% 1st Bonus Team', 0, 0),
        (N'Global Procurement', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global Procurement', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'Global Procurement', 2, N'100% Sector', 1, 0),
        (N'Global Procurement', 3, N'100% OU or 100% Sector', 0, 0),
        (N'Global Procurement', 3, N'100% Sector', 1, 0),
        (N'Global R&D', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global R&D', 1, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'100% Corporate', 0, 1),
        (N'Global R&D', 3, N'100% Corporate', 0, 1),
        (N'Global R&D', 2, N'37.5% 1st Bonus Team / 37.5% 2nd Bonus Team / 25% Corporate', 0, 0),
        (N'Global R&D', 2, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global R&D', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global R&D', 3, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global S&T', 1, N'75% Bonus Team / 25% Corporate', 0, 0),
        (N'Global S&T', 1, N'100% Corporate', 0, 1),
        (N'Global S&T', 2, N'100% Corporate', 0, 1),
        (N'Global S&T', 3, N'100% Corporate', 0, 1),
        (N'Global S&T', 1, N'75% Bonus Team / 25% Corporate', 1, 0),
        (N'Global S&T', 2, N'75% OU / 25% Corporate OR 75% sector / 25% Corporate', 0, 0),
        (N'Global S&T', 2, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'Global S&T', 3, N'75% Sector / 25% Corporate OR 75% OU / 25% Corporate', 0, 0),
        (N'Global S&T', 3, N'75% Selected Region / 25% Corporate OR 100% Corporate', 1, 0),
        (N'International Beverages', 1, N'100% 1st Bonus Team', 0, 0),
        (N'International Beverages', 1, N'100% Sector', 1, 0),
        (N'International Beverages', 2, N'100% Sector', 1, 0),
        (N'International Beverages', 3, N'100% Sector', 1, 0),
        (N'International Beverages', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'International Beverages', 3, N'100% Sector', 0, 0),
        (N'LATAM ', 1, N'100% 1st Bonus Team', 0, 0),
        (N'LATAM ', 1, N'100% Sector', 1, 0),
        (N'LATAM ', 2, N'100% Sector', 1, 0),
        (N'LATAM ', 3, N'100% Sector', 1, 0),
        (N'LATAM ', 2, N'50% 1st Bonus Team / 50% 2nd Bonus Team', 0, 0),
        (N'LATAM ', 3, N'100% Sector', 0, 0),
        (N'North America', 1, N'100% 1st Bonus Team', 0, 0),
        (N'North America', 1, N'100% Sector', 1, 0),
        (N'North America', 2, N'100% Sector', 1, 0),
        (N'North America', 3, N'100% Sector', 1, 0),
        (N'North America', 2, N'100% 1st Bonus Team', 0, 0),
        (N'North America', 3, N'100% 1st Bonus Team', 0, 0);

    -- Corporate is a conditional override, not a multi-sector regional mapping.
    -- R&D/S&T overrides are defined above; Corporate GGF already always returns Corporate for 2/3.
    INSERT INTO @allocation_seed
        (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
    SELECT round_def.comp_round_extended, business_count.number_of_businesses, N'100% Corporate', 0, 1
    FROM (VALUES (N'APAC Foods'), (N'EMEA Foods'), (N'LATAM'),
        (N'International Beverages'), (N'North America'), (N'Global Procurement')) AS round_def(comp_round_extended)
    CROSS JOIN (VALUES (2), (3)) AS business_count(number_of_businesses);

    ;WITH configured_comp_round AS
    (
        SELECT DISTINCT CompGroupName AS comp_round_extended
        FROM dbo.PEPSICO_CompGroup
        UNION
        SELECT comp_round_extended
        FROM dbo.PEPSICO_CompRoundExtendedRule
    )
    MERGE INTO dbo.PEPSICO_bonus_team_allocation_rule WITH (HOLDLOCK) AS target
    USING
    (
        SELECT DISTINCT cg.comp_round_extended, s.number_of_businesses, s.split_rule, s.is_region, s.corporate_override
        FROM @allocation_seed AS s
        INNER JOIN configured_comp_round AS cg
            ON cg.comp_round_extended = s.comp_round_extended
    ) AS source
        ON target.comp_round_extended = source.comp_round_extended
       AND target.number_of_businesses = source.number_of_businesses
       AND target.is_region = source.is_region
       AND target.split_rule = source.split_rule
    WHEN MATCHED AND target.corporate_override <> source.corporate_override THEN
        UPDATE SET corporate_override = source.corporate_override
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (comp_round_extended, number_of_businesses, split_rule, is_region, corporate_override)
        VALUES (source.comp_round_extended, source.number_of_businesses, source.split_rule, source.is_region, source.corporate_override)
    WHEN NOT MATCHED BY SOURCE
         AND (target.is_region = 1
              OR (target.comp_round_extended = N'Corporate GGF'
                  AND target.number_of_businesses IN (2, 3)))
         AND target.number_of_businesses BETWEEN 1 AND 3
         AND target.comp_round_extended IN
         (
             SELECT cg.comp_round_extended
             FROM configured_comp_round AS cg
             WHERE cg.comp_round_extended IN
                 (N'North America', N'EMEA Foods', N'APAC Foods',
                  N'LATAM', N'International Beverages', N'Corporate GGF')
                OR (cg.comp_round_extended = N'Global S&T'
                    AND target.number_of_businesses = 1
                    AND target.corporate_override = 0
                    AND target.split_rule = N'100% 1st Bonus Team')
         ) THEN
        DELETE;

    -- Procurement single non-region business follows 1 Business Supported, not Bonus with Corp Component.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    WHERE legacy.comp_round_extended = N'Global Procurement'
      AND legacy.number_of_businesses = 1
      AND legacy.is_region = 0
      AND legacy.corporate_override = 0
      AND legacy.split_rule = N'75% Bonus Team / 25% Corporate'
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS replacement
          WHERE replacement.comp_round_extended = legacy.comp_round_extended
            AND replacement.number_of_businesses = 1
            AND replacement.is_region = 0
            AND replacement.corporate_override = 0
            AND replacement.split_rule = N'100% 1st Bonus Team'
      );

    -- Retire superseded two/three-business regional rules only when their replacements exist.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    WHERE legacy.comp_round_extended IN (N'Global R&D', N'Global S&T')
      AND legacy.number_of_businesses IN (2, 3)
      AND legacy.is_region = 1
      AND legacy.corporate_override = 0
      AND legacy.split_rule IN (N'Corporate', N'100% Corporate')
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS replacement
          WHERE replacement.comp_round_extended = legacy.comp_round_extended
            AND replacement.number_of_businesses = legacy.number_of_businesses
            AND replacement.is_region = 1
            AND replacement.corporate_override = 0
            AND replacement.split_rule = N'75% Selected Region / 25% Corporate OR 100% Corporate'
      );

    -- Retire the old name only where its canonical replacement was seeded.
    DELETE legacy
    FROM dbo.PEPSICO_bonus_team_allocation_rule AS legacy
    INNER JOIN @allocation_seed AS s
        ON s.comp_round_extended = legacy.comp_round_extended
       AND s.number_of_businesses = legacy.number_of_businesses
       AND s.is_region = legacy.is_region
       AND s.corporate_override = legacy.corporate_override
       AND s.split_rule = N'100% Corporate'
    WHERE legacy.split_rule = N'Corporate'
      AND EXISTS
      (
          SELECT 1
          FROM dbo.PEPSICO_bonus_team_allocation_rule AS canonical
          WHERE canonical.comp_round_extended = legacy.comp_round_extended
            AND canonical.number_of_businesses = legacy.number_of_businesses
            AND canonical.is_region = legacy.is_region
            AND canonical.corporate_override = legacy.corporate_override
            AND canonical.split_rule = N'100% Corporate'
      );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- SECTION 25: AI/beqom_sync_objects/Stored Procedures/Kernel_SP_Process_DataOnChange.sql
PRINT N'AI/beqom_sync_objects/Stored Procedures/Kernel_SP_Process_DataOnChange.sql';
GO

CREATE OR ALTER PROCEDURE [dbo].[Kernel_SP_Process_DataOnChange]
	@uidObject UNIQUEIDENTIFIER,
	@uidProfile UNIQUEIDENTIFIER,
	@uidUser UNIQUEIDENTIFIER,
	@idStep int,
	@idTree int,
	@idTreeSecurity int,
	@Values AS [dbo].[Kernel_Type_Process_Values] READONLY
AS
BEGIN

-- created by James Mackay ?????? to update Process fields using RTC
-- modified by James Mackay 20210527 update ic_score range and merit_range when Performance Rating changes
-- modified by Yoann Schrago 20210607 added Merit_percent as a trigger
-- modified by Yoann Schrago 20210609 SYS2021-01 added promotion range
-- modified by Yoann Schrago 20210610 SYS2021-01 added equity range
-- modified by Yoann Schrago 20210614 SYS2021-01 added merit_amount, prom_percent, Prom_amount, equity_percent and equity_amount as triggers
-- modified by Yoann Schrago 20210615 SYS2021-01 modified to use values from k_m_values if no value found in [Kernel_Type_Process_Values]
-- modified by Yoann Schrago 20210616 SYS2021-01 added functions to refresh values
-- modified by Yoann Schrago 20210617 added dm_multiplier, stp, eligibility and CompaRatio refresh, added Promotion_type as Trigger
-- modified by Yoann Schrago 20210618 added Promotion_level, promotion_salaryPlan as triggers, refresh promotion drop down lists
-- modified by Yoann Schrago 20210621 changed functions to avoid code redundancy 
-- modified by Yoann Schrago 20210622 added compaRatio refresh into the process
-- modified by Yoann Schrago 20210629 Added rounding amounts and changed refresh functions
-- modified by Yoann Schrago 20210701 added egypt exception for @merit_percent
-- modified by Yoann Schrago 20210702 added deletion of promotion_cross_level if promotion_cross_type <> 'CROSS', 
									--added dm_manager_dm_increase as default value for dm_hr_dm_increase and delete dm_hr_dm_increase if NULL
-- modified by Yoann Schrago 20210708 fixed merit_percent when new value is NULL
-- modified by Yoann Schrago 20210709 use only values from [dbo].[Kernel_Type_Process_Values]
-- modified by Yoann Schrago 20210709 reset ic_score, ranges, increases and amounts if Performance Rating is set to NULL
-- modified by Yoann Schrago 20210712 avoid "edge" issue by rounding back the percentages to 2 decimals after the "Amount" rounding
-- modified by Yoann Schrgao 20210713 added @uidProfiles and profiles check before updating DM_Increases
-- modified by Yoann Schrgao 20210715 fix to trigger Widget Budget
-- modified by Yoann Schrago 20210723 Take compa ratios from k_m_values instead of EmpCompaRatio
-- modified by Yoann Schrago 20210723 Remove clearing of ic_score when Performance Rating is set to NULL
-- modified by Yoann Schrago 20210813 remove increases if Rating changes depending of the profile
-- modified by Yoann Schrago 20210817 added logic to clear Promotion_cross_Salary_Plan if promotion_type is null and fix Salary_Plan lookup
-- modified by Yoann Schrago 20210824 added FinalPayComponent refresh if final_lump_sum > 0, and refresh Compa_Ratio in this case and india check for xxx_amount values
-- modified by Yoann Schrago 20210826 fix Minimum_amount logic, added PEPSICO_FocalPoint_Minimum, clear promotion_cross_level if promotion_cross_type is NULL or 'IN'
-- modified by Yoann Schrago 20210826 changed Spend calculation to get merit_amount_prorated and the india exception
-- modified by Yoann Schrago 20210831 commented the refresh of lists fields when Promotion_type changes
-- modified by Yoann Schrago 20210902 #48705 fix to return a value in the #temp table even if they didn't change
-- modified by Yoann Schrago 20210908 #48104 ic_score cleared when Performance Rating changes
-- modified by Yoann Schrago 20210909 return in all cases ic_score, cleared or with the actual value. to avoid returning a NULL value to the PreSave
-- modified by Yoann Schrago 20211014 #50528 fix for Final Amount not showing if SalaryPlan is missing into PEPSICO_FocalPoint_LumpSum
-- modified by Yoann Schrago 20211025 fixed saving issue for Super user and Comp Admin
-- modified by Yoann Schrago 20211122 fix for RTC passing 0 for ic_score instead of NULL 
-- modified by James Mackay 20211201 changed vPEPSICO_SalaryPlan_All to PEPSICO_SalaryPlan_All
-- modified by Yoann Schrago 20211201 replace GPID by codepayee in JOIN
-- modified by Yoann Schrago 20211206 #52980 add default value for merit_percent AND Add IC Score as a TRIGGER to return itself
-- modified by Yoann Schrago 20211209 #52374 return only Performance Ratings if is_budget_exclude = 1
-- modified by Yoann Schrago 20211210 #53289 fix for LumpSum calculation JOIN on LegalEntity
-- modified by James Mackay 20220109 changed ic_score cast from INT to NUMERIC 
-- modified by Yoann Schrago 20221201 added WITH (NOLOCK) from k_m_values 
-- modified by James Mackay 20221205 #73981 changed to use PEPSICO_SalaryPlan_Exception
-- modified by Yoann Schrago 20230807 R/M2023-14 refresh final_proposal and final_proposal_rounded if equity_amount is entered
-- modified by James Mackay 20230827 R/M2023-15 added promotion_multiplier
-- modified by Yoann Schrago 20231019 R/M2023-07 india changes (pay Components)
-- modified by Yoann Schrago 20231208 #98549 set dm_hr_dm_increase with dm_manager_dm_increase
-- modified by James Mackay 20240106 #100112 fixed issues with increase amount calculations
-- modified by Yoann Schrago 20240627 Job Architecture poulate POC5 Job Title
-- modified by Yoann Schrago 20240712 Job Architecture lookup for POC5 JobTitle
-- modified by Yoann Schrago 20240806 Job Architecture lookup for POC5 JobTitle_2 and JobSubFamily_2
-- modified by Yoann Schrago 20240822 R/M2024-02 Remove Promotion and Equity Type when Performance Rating changes.
-- modified by Yoann Schrago 20240826 DM2024-03 remove dm_manager_dm_increase from MyTeams grid
-- modified by Yoann Schrago 20240827 DM2024-03 Add dm_amount
-- modified by Yoann Schrago 20240829 R/M2024-02 rollback changes
-- modified by Yoann Schrago 20240829_2 DM2024-02 cap equity range to the max of the salary range
-- modified by Yoann Schrago 20240829_3 DM2024-02 cap DM range to the max of the salary range
-- modified by Yoann Schrago 20240830 R/M2024-13 ZD113473 fix LumpSum calculation
-- modified by Yoann Schrago 20240918 DM2024-05 Change TARGETED to DIFFERENTIATED
-- modified by Yoann Schrago 20241003 R/M2024-08 add Promotion_Job_Code
-- modified by Kamil Roganowicz 20241017 R/M2024-19 ZD#116368 - rounding final_lump_sum
-- modified by Yoann Schrago 20241227 zd121084 adjust india increase amounts
-- modified by James Mackay 20250415 2025 Job Architecture changes
-- modified by James Mackay 20250612 moved check for Ratings process to the start of the ratings script -- IF @PlanId = @id_plan_focalpoint -- was doing lots of Ratings processing for Job Architecture
-- modified by Yoann Schrago 20250724 B2025-05 adding bonus process logic
-- modified by Yoann Schrago 20250818 B2025-05 adapt Bonus Process logic
-- modified by Yoann Schrago 20250826 new Final Bonus Team logic
-- modified by Kamil Roganowicz 20250916 ZD#138427 add logic for prt message 
-- modified by Yoann Schrago 20251020 R/M2025-05 add russian mandatory merit increase and modifiy LumpSum logic
-- modified by Yoann Schrago 20251113 R/M2025-13 Change in LumpSum calculation for EGY population
-- modified by Przemyslaw Kot 20251217 #ZD145010 Correct value assignment for @preassigned_bonus variable - should be BonusTeamNameProcess instead of BonusTeamName
-- modified by Przemyslaw Kot 20260211 #ZD148392 Take into consideration @finalSalaryPlanCode_nk and @LevelCodeFinal values while assigning value to @final_max_pay variable for Salaray Plan Codes stored in the PEPSICO_FocalPoint_Merit_Increase_forced table (Russia case)

--select * from k_profiles
--select * from k_users where login_user like '%yoann.schrago%'
--select * from hm_NodeTreePublished

----------------- TEST PARAMETERS 
---- select * from PEPSICO_Process_FocalPoint where gpid = '20620701'
----select * from PEPSICO_FocalPoint_EmpCurrentPayee where gpid = '20500320'
----select * from PEPSICO_Sector where SectorCode_nk = 'S03'
---- select * from py_payee where codePayee = '20500320' --idPayee 38552
---- select * from k_m_plans_payees_steps where id_payee = 285986 --id_step 1037110
---- STANDARD TEST: codepayee = '70178577'-- idPayee = 227488 id_step = 1042752
---- INDIAN TEST: codepayee = '20616772'-- idPayee = 179290 id_step = 1042169

------
--DECLARE @uidObject NVARCHAR(255) = '65509CA7-8A0E-49BB-BFB9-AA9A802FBA62', @uidProfile NVARCHAR(255) = '49D6E955-3E76-4105-93F4-7F0551D345F1', @uidUser NVARCHAR(255) = '7E70B506-C48E-4248-9F00-FC9EACC2ED10', @idTree int = 5, @idStep int = 3203396,  @idTreeSecurity int = 1111512 , @Values AS [dbo].[Kernel_Type_Process_Values]

--insert into @Values (idIndicator, idField, isTrigger, inputValue)
--select idIndicator, idField, isTrigger, inputValue from zz_temp_jm_Kernel_Type_Process_Values where insert_datetime = '2025-08-22 11:34:33.933'--equity_amount'2021-06-14 05:40:25.923'--equity_percent'2021-06-14 12:12:11.107'--promotion_amount'2021-06-15 12:54:15.873'--promotion_pct'2021-06-15 06:36:32.437'--merit_amount'2021-06-14 11:47:12.730'-- merit_pct'2021-06-15 12:54:01.967'


--insert into @Values (idIndicator, idField, isTrigger, inputValue)
--VALUES	
--	(21,137,0,'BonusTeamPreAssigned'),
--	(21,138,0,'NO'),
--	(21,139,0,'DATA'),
--	(21,140,0,'ENABLE'),
--	(21,141,1,'OU_MU'),
--	(21,142,0,'BTR001'),
--	(21,143,0,'BTOU001'),
--	(21,144,0,'BTOU004'),
--	(21,145,0,'BTOU003'),
--	(21,146,0,''),
--	(21,147,0,'OU')


----select * from @Values
--drop table if exists #tempTable
---------------END TEST PARAMETERS

	Declare 
		@TriggerAlias nvarchar(max) = '', 
		@TriggerValue nvarchar(max) = '',
		@PlanId int = 0,
		@calculatedValue int = 0;
	
	CREATE TABLE #tempTable  
	(  
		PrimaryKey   INT   NOT NULL ,  
		ObjectFieldAlias   VARCHAR(100),
		ObjectAttribute    VARCHAR(40),
		IsValid   BIT,
		InvalidReason   NVARCHAR(400),
		AllowEdit   BIT,
		NewValue   NVARCHAR(200),
	);  

-- for debugging 
INSERT INTO zz_temp_jm_Kernel_Type_Process_Values ([idIndicator], [idField], [isTrigger], [inputValue]) -- select top 1000 * from zz_temp_jm_Kernel_Type_Process_Values order by insert_datetime desc
SELECT [idIndicator], [idField], [isTrigger], [inputValue] FROM @Values

	-- PayComponent temp table for indian SalaryPLan
	DECLARE 
		@RTCPayComponent AS [PEPSICO_EmpPayComponentIncrease_param]

	--DECLARE @RTCPayComponent TABLE
	--(
	--	[FiscalYear] [int],
	--	[GPID] [nvarchar](50),
	--	[PayComponentCode_nk] [varchar](255),
	--	[MeritIncreaseTypeCode_nk] [varchar](50),
	--	[Amount] [numeric](18, 5),
	--	IncreasePercent [numeric](18, 5),
	--	[ProposedAmount] [numeric](18, 5)
	--)

	-- get some field details

	DECLARE 
		@idPayee INT,
		@codePayee NVARCHAR(50),
		@id_ind INT, 
		@id_field INT,
		@inputValue NVARCHAR(MAX),
		@id_plan_focalpoint INT,
		@FiscalYear INT = (SELECT FiscalYear from vPEPSICO_FocalPoint_Parameters),
		@id_ind_ci INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_comp_index'),	-- select * from k_m_indicators -- select * from k_m_fields
		@id_ind_ic_score INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'ic_score'),	
		@id_ind_merit INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_merit'),
		@id_ind_dm INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_differentiated_merit'),
		@id_ind_promotion INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_cross'),
		@id_ind_equity INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_equity'),
		@id_ind_minimum INT = (SELECT id_ind from k_m_indicators where comment_ind = 'focal_point_minimum'),
		@id_ind_final INT = (SELECT id_ind FROM k_m_indicators WHERE comment_ind = 'focal_point_final'),
		@id_field_ci INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci'),		
		@id_field_ic_score INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score'),		
		@id_field_ic_score_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score_min'),		
		@id_field_ic_score_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score_max'),		
		@id_field_merit_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_range_min'),	
		@id_field_merit_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_range_max'),	
		@id_field_merit_percent int = (SELECT id_field from k_m_fields where code_field = 'merit_percent'),
		@id_field_merit_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_amount'),
		@id_field_merit_spend INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_spend'),
		@id_field_merit_spend_2 INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_spend_2'),
		@id_field_merit_proposal_prorated INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_proposal_prorated'),
		--@id_field_dm_manager_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_manager_dm_increase'), -- YS 20240826
		@id_field_dm_hr_dm_increase INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hr_dm_increase'),
		@id_field_dm_hr_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_hr_proposal'),
		@id_field_dm_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_amount'), -- YS 20240827
		@id_field_dm_spend INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'dm_spend'),
		@id_field_promotion_cross_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_range_min'),
		@id_field_promotion_cross_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_range_max'),
		@id_field_promotion_percent INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_percent'),
		@id_field_promotion_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_amount'),
		@id_field_promotion_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_proposal'),
		@id_field_promotion_cross_level INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_level'),
		@id_field_promotion_cross_salary_plan INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_salary_plan'),
		@id_field_promotion_cross_type INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_cross_type'),
		@id_field_promotion_job_code INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'promotion_job_code'), -- YS 20241003
		@id_field_equity_range_min INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_range_min'),
		@id_field_equity_range_max INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_range_max'),
		@id_field_equity_percent INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_percent'),
		@id_field_equity_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_amount'),
		@id_field_equity_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_proposal'),
		@id_field_equity_type INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'equity_type'), --YS 20240822
		@id_field_minimum_amount INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'minimum_amount'),
		@id_field_minimum_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'minimum_proposal'),
		@id_field_final_proposal INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_proposal'),
		@id_field_final_proposal_rounded INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_proposal_rounded'),
		@id_field_final_lump_sum INT = (SELECT id_field FROM k_m_fields WHERE code_field = 'final_lump_sum'),
		@uidProfileManager NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 2), --select * from k_profiles
		@uidProfileManagerLG8 NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 3),
		@uidProfileHR NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 4),
		@uidProfileHRLG8 NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 5),
		@uidProfileCompAdmin NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 6),
		@uidProfileSuperUser NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = 7),
		@uidProfileAdmin NVARCHAR(50) = (SELECT uid_profile FROM k_profiles where id_profile = -1)

	SELECT
		@id_plan_focalpoint = idPlanFocalPoint
	FROM vPEPSICO_FocalPoint_Parameters -- select * from vPEPSICO_FocalPoint_Parameters

	DECLARE 
		@id_plan_job_architecture INT = (SELECT idPlanJobArchitecture FROM vPEPSICO_FocalPoint_Parameters), -- YS 20240627
		@id_ind_ja_poc5 int = (SELECT id_ind from k_m_indicators where comment_ind = 'ja_poc5'), --YS 20240627
		@id_field_ja_poc5_new_job_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_family'), --YS 20240627
		@id_field_ja_poc5_new_job_family_description int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_family_description'), --YS 20240627
		@id_field_ja_poc5_new_job_sub_family int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family'), --YS 20240627
		@id_field_ja_poc5_new_job_sub_family_description int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family_description'), --YS 20240627
		@id_field_ja_new_job_title int = (SELECT id_field from k_m_fields where code_field = 'ja_new_job_title'),
		--@id_field_ja_poc5_new_job_title_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title_2'), --YS 20240627
		@id_field_ja_poc5_new_job_title int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title') --YS 20240627
		--@id_field_ja_poc5_new_title int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_title'), --YS 20240627
		--@id_field_ja_poc5_new_job_sub_family_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_sub_family_2'), --YS 20240806
		--@id_field_ja_poc5_new_job_title_2 int = (SELECT id_field from k_m_fields where code_field = 'ja_poc5_new_job_title_2') --YS 20240806

	DECLARE 
		@id_plan_bonus INT = (SELECT idPlanBonusApproval FROM vPEPSICO_FocalPoint_Parameters), --YS 20250724
		@id_ind_bonus_team int = (SELECT id_ind from k_m_indicators where comment_ind = 'bonus_team'), --YS 20250724
		--@id_field_bonus_team_preassigned int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_preassigned'), --YS 20250724
		@id_field_bonus_team_assignment_correct int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_assignment_correct'), --YS 20250724
		--@id_field_bonus_team_correction_reason int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_correction_reason'), --YS 20250724
		--@id_field_bonus_team_enabling int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_enabling'), --YS 20250724
		@id_field_bonus_team_step_1 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_1'), --YS 20250724 
		@id_field_bonus_team_step_2 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_2'), --YS 20250724 
		@id_field_bonus_team_step_3 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_3'), --YS 20250724 
		--@id_field_bonus_team_step_35 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_35'), --YS 20250724
		--@id_field_bonus_team_step_4 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_4'), --YS 20250724
		--@id_field_bonus_team_step_5 int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_step_5'), --YS 20250724
		@id_field_bonus_team_final int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_final'), --YS 20250724
		--@id_field_bonus_team_double_hatter int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_double_hatter'), --YS 20250818
		@id_field_bonus_team_comment int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_comment'), --YS 20250818
		@id_field_bonus_team_prt_message int = (SELECT id_field from k_m_fields where code_field = 'bonus_team_prt_message') --YS 20250818

	-- get the plan

	SELECT @PlanId = id_plan 
	FROM k_m_plans 
	WHERE 
		uid_object = @uidObject;

	-- get the id payee and code payee

	SELECT 
		@idPayee = py.idPayee, --227488
		@codePayee = py.codePayee
	FROM k_m_plans_payees_steps AS pps
	JOIN py_Payee AS py
		ON py.idPayee = pps.id_payee
	WHERE 
		pps.id_step = @idStep
			   		 
	-- get the field that triggered the Stored Procedure

	SELECT TOP 1
		@id_ind = idIndicator,
		@id_field = idField,
		@inputValue = inputValue
	FROM @Values 
	WHERE 
		isTrigger = 1

	------------------------------------------------------------------------------------------------------------------------------------
	------------------------------------------------------- Ratings Process START-------------------------------------------------------
	IF @PlanId = @id_plan_focalpoint
	BEGIN

		----------------- is_budget_excluded Condition START -------------------- YS 20211209
		IF EXISTS (SELECT 1 FROM PEPSICO_Process_FocalPoint where codePayee = @codePayee AND is_budget_exclude = 0)
		BEGIN

			-- get all variables usefull for the calculations from @Values, vPEPSICO_Process_FocalPoint_Values_Pivoted or PEPSICO_FocalPoint_EmpCompaRatio
			DECLARE
				@ci							INT,
				@ic_score					INT,
				@merit_percent				NUMERIC(18,5),
				@merit_amount				NUMERIC(18,5),
				@merit_amount_prorated		NUMERIC(18,5),
				@merit_proposal_prorated	NUMERIC(18,5),
				@dm_hr_dm_increase			NUMERIC(18,5),
				--@dm_manager_dm_increase		NUMERIC(18,5), -- YS 20240826
				@dm_hr_proposal				NUMERIC(18,5),
				@dm_amount					NUMERIC(18,5), -- YS 20240827
				@promotion_cross_percent	NUMERIC(18,5),
				@promotion_cross_percent_multiplier NUMERIC(18,5),
				@promotion_cross_amount		NUMERIC(18,5),
				@promotion_cross_proposal	NUMERIC(18,5),
				@promotion_cross_type		VARCHAR(256),
				@promotion_job_code			VARCHAR(256), -- YS 20241003
				@equity_percent				NUMERIC(18,5),
				@equity_amount				NUMERIC(18,5),
				@equity_proposal			NUMERIC(18,5),
				@equity_type				VARCHAR(256), -- YS 20240822
				@minimum_amount				NUMERIC(18,5),
				@minimum_proposal			NUMERIC(18,5),
				@final_lump_sum				NUMERIC(18,5),
				@final_proposal				NUMERIC(18,5),
				@final_proposal_rounded		NUMERIC(18,5),
				@final_increase_rounded		NUMERIC(18,5),
				@cr_merit					NUMERIC(18,5),
				@cr_targeted				NUMERIC(18,5),
				@cr_promotion				NUMERIC(18,5),
				@cr_equity					NUMERIC(18,5),
				@cr_minimum					NUMERIC(18,5),
				@cr_lump					NUMERIC(18,5),
				@cr_final					NUMERIC(18,5),
				@LevelCodeFinal				VARCHAR(256),
				@SalaryPlanCode_nk			VARCHAR(256),
				@finalSalaryPlanCode_nk		VARCHAR(256),
				@min_pay					NUMERIC(18,0),
				@mid_point_pay				NUMERIC(18,0),
				@max_pay					NUMERIC(18,0),
				@final_min_pay				NUMERIC(18,0),
				@final_mid_point_pay		NUMERIC(18,0),
				@final_max_pay				NUMERIC(18,0)
		
		
			SELECT
				@ci =						TRY_CAST(p_kmv.ci AS INT),-- NUMERIC(18,5)), 
				@ic_score =					TRY_CAST(p_kmv.ic_score AS NUMERIC), -- JM 20220109 changed from INT to NUMERIC 
				@merit_percent =			TRY_CAST(p_kmv.merit_percent AS NUMERIC(18,5)), 
				@merit_amount =				TRY_CAST(p_kmv.merit_amount AS NUMERIC(18,5)),
				@merit_amount_prorated =	TRY_CAST(p_kmv.merit_amount_prorated AS NUMERIC(18,5)),
				--@dm_manager_dm_increase =	ISNULL(TRY_CAST(kmv_dm_hr.input_value_numeric AS NUMERIC(18,5)),TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5))), --COALESCE(TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5)), piv.dm_manager_dm_increase, 0.0), -- YS 20240826
				@dm_hr_dm_increase =		TRY_CAST(p_kmv.dm_hr_dm_increase AS NUMERIC(18,5)), --COALESCE(TRY_CAST(p_kmv.dm_hr_dm_increase AS NUMERIC(18,5)), TRY_CAST(p_kmv.dm_manager_dm_increase AS NUMERIC(18,5))),
				@dm_amount =				TRY_CAST(p_kmv.dm_amount AS NUMERIC(18,5)), -- YS 20240827
				@promotion_cross_percent =	TRY_CAST(p_kmv.promotion_cross_percent AS NUMERIC(18,5)),
				@promotion_cross_percent_multiplier = ((1.0 + TRY_CAST(p_kmv.promotion_cross_percent AS NUMERIC(18,5)) / 100.0) * pfp.promotion_multiplier - 1.0) * 100.0,				
				@promotion_cross_amount =	TRY_CAST(p_kmv.promotion_cross_amount AS NUMERIC(18,5)), 
				@promotion_cross_type =		NULLIF(p_kmv.promotion_cross_type,''),
				@promotion_job_code =		NULLIF(p_kmv.promotion_job_code,''), -- YS 20241003
				@equity_percent =			TRY_CAST(p_kmv.equity_percent AS NUMERIC(18,5)),
				@equity_amount =			TRY_CAST(p_kmv.equity_amount AS NUMERIC(18,5)),
				@equity_type =				NULLIF(p_kmv.equity_type,''), -- YS 20240822
				@minimum_amount =			TRY_CAST(p_kmv.minimum_amount AS NUMERIC(18,5)),
				@final_lump_sum =			TRY_CAST(p_kmv.final_lump_sum AS NUMERIC(18,5)), 
				@cr_merit =					cr_merit.CompaRatio,
				@cr_targeted =				TRY_CAST(p_kmv.merit_dm_compa_ratio AS NUMERIC(18,5)) ,				 
				@cr_promotion =				TRY_CAST(p_kmv.dm_promotion_compa_ratio AS NUMERIC(18,5)) ,			 
				@cr_equity =				TRY_CAST(p_kmv.promotion_cross_equity_compa_ratio AS NUMERIC(18,5)),  
				@cr_minimum =				TRY_CAST(p_kmv.equity_minimum_compa_ratio AS NUMERIC(18,5)) ,		 
				@cr_lump =					TRY_CAST(p_kmv.minimum_lump_compa_ratio AS NUMERIC(18,5)) ,			 
				@cr_final =					TRY_CAST(p_kmv.final_compa_ratio AS NUMERIC(18,5)) ,				 
				@LevelCodeFinal =			COALESCE(NULLIF(p_kmv.promotion_cross_level,''), pfp.LevelCodeFinal, pfp.LevelCode),
				@SalaryPlanCode_nk =		pfp.SalaryPlanCode_nk,
				@finalSalaryPlanCode_nk	=	COALESCE(NULLIF(p_kmv.promotion_cross_salary_plan,''), pfp.SalaryPlanCode_nk),
				@min_pay =					pr.MinPay,
				@mid_point_pay =			pr.MidPointPay,
				@max_pay =					pr.MaxPay,
				@final_min_pay =			fpr.MinPay,
				@final_mid_point_pay =		fpr.MidPointPay,
				@final_max_pay =			fpr.MaxPay
			FROM  vPEPSICO_Process_FocalPoint_Values_Pivoted AS piv
			JOIN PEPSICO_Process_FocalPoint AS pfp 
				ON pfp.idPayee = piv.id_payee
			LEFT JOIN k_m_values AS kmv_dm_hr WITH (NOLOCK) -- YS 20221201
				ON kmv_dm_hr.id_step = piv.id_step
				AND id_field = @id_field_dm_hr_dm_increase
			LEFT JOIN 
			(
				SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
				FROM @Values AS kmv
				JOIN k_m_fields as kmf on kmf.id_field = kmv.idField
				WHERE kmf.code_field  IN (
					'ci', 'ic_score',
					'merit_percent', 'merit_amount', 'merit_amount_prorated', 'merit_proposal_prorated', /*dm_manager_dm_increase',*/ 'dm_hr_dm_increase', 'dm_hr_proposal', 'dm_amount',  -- YS 20240826 -- YS 20240827
					'promotion_cross_percent', 'promotion_cross_amount', 'promotion_cross_proposal', 'promotion_cross_level', 'promotion_cross_type', 'promotion_cross_salary_plan', 'promotion_job_code', -- YS 20241003
					'equity_percent', 'equity_amount', 'equity_proposal','equity_type', 'minimum_amount', 'minimum_proposal', 'final_proposal', 'final_lump_sum',
					'merit_dm_compa_ratio', 'dm_promotion_compa_ratio', 'promotion_cross_equity_compa_ratio', 'equity_minimum_compa_ratio', 'minimum_lump_compa_ratio', 'final_compa_ratio')
			) AS s
			PIVOT
			(
				MAX(inputValue)
				FOR s.code_field  IN (
					ci, ic_score,
					merit_percent, merit_amount, merit_amount_prorated, merit_proposal_prorated, /*dm_manager_dm_increase,*/ dm_hr_dm_increase, dm_hr_proposal, dm_amount,  -- YS 20240826 -- YS 20240827
					promotion_cross_percent, promotion_cross_amount, promotion_cross_proposal, promotion_cross_level, promotion_cross_type, promotion_cross_salary_plan, promotion_job_code, -- YS 20241003
					equity_percent, equity_amount, equity_proposal, equity_type, minimum_amount, minimum_proposal, final_proposal, final_lump_sum,
					merit_dm_compa_ratio, dm_promotion_compa_ratio, promotion_cross_equity_compa_ratio, equity_minimum_compa_ratio, minimum_lump_compa_ratio, final_compa_ratio)
			) AS p_kmv ON p_kmv.idStep = piv.id_step
			LEFT JOIN PEPSICO_FocalPoint_EmpCompaRatio AS cr_merit
				ON cr_merit.GPID = @codePayee AND cr_merit.MeritIncreaseTypeCode_nk = 'MERIT'
			LEFT JOIN PEPSICO_SalaryPlan_All AS sp
				ON sp.SalaryPlanCode_nk = ISNULL(NULLIF(p_kmv.promotion_cross_salary_plan, ''), pfp.SalaryPlanCode_nk) 
			LEFT JOIN PEPSICO_FocalPoint_PayRange AS fpr 
				ON fpr.SalaryPlanCode_nk = ISNULL(NULLIF(p_kmv.promotion_cross_salary_plan, ''), pfp.SalaryPlanCode_nk)
				AND fpr.LevelCode = COALESCE(NULLIF(p_kmv.promotion_cross_level,''), pfp.LevelCodeFinal, pfp.LevelCode)
				AND sp.PayRange_Date_Lookup BETWEEN fpr.PayRangeStartDate AND fpr.PayRangeEndDate
			LEFT JOIN PEPSICO_FocalPoint_PayRange AS pr 
				ON pr.SalaryPlanCode_nk = pfp.SalaryPlanCode_nk
				AND pr.LevelCode = pfp.LevelCode
				AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate
			WHERE piv.id_step = @idStep

	/* -- YS 20240826
			IF @id_field = @id_field_dm_manager_dm_increase
				SELECT @dm_hr_dm_increase = @dm_manager_dm_increase

			IF @dm_hr_dm_increase is null and @dm_manager_dm_increase is not null -- YS 20231208 
				SELECT @dm_hr_dm_increase = @dm_manager_dm_increase
	 -- YS 20240826 
	 */

		--select @ci, @merit_percent, @merit_amount, @merit_amount_prorated, @merit_proposal_prorated, @dm_manager_dm_increase, @dm_hr_dm_increase, @dm_hr_proposal, @dm_amount, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type, @equity_percent, @equity_amount, @equity_proposal, @minimum_amount, @final_lump_sum, @final_proposal_rounded AS finalRounded, @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final, @LevelCodeFinal, @finalSalaryPlanCode_nk, @min_pay, @mid_point_pay, @max_pay, @final_min_pay, @final_mid_point_pay, @final_max_pay				
	--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal
			-------------------------- CLEAR Percentages and Amounts if Performance Ratings is set to NULL

			--IF @id_field = @id_field_ci AND @inputValue = '' --YS 20210813
			IF @id_field = @id_field_ci
			BEGIN
				IF @uidProfile IN (@uidProfileManager, @uidProfileManagerLG8)
				BEGIN
					SELECT
						@ic_score = NULL,
						@merit_percent = NULL,
						@merit_amount = NULL,
	--					@dm_manager_dm_increase = NULL -- YS 20240826
						@dm_hr_dm_increase = NULL, -- YS 20240829
						@dm_amount = NULL -- YS 20240829
						--@dm_hr_dm_increase = NULL,
						--@promotion_cross_percent = NULL,
						--@promotion_cross_amount = NULL,
						--@equity_percent = NULL,
						--@equity_amount = NULL

					print'reset percentages for Managers'
				END
				ELSE 
				BEGIN
					SELECT
						@ic_score = NULL,
						@merit_percent = NULL,
						@merit_amount = NULL,
	--					@dm_manager_dm_increase = NULL, -- YS 20240826
						@dm_hr_dm_increase = NULL,
						@dm_amount = NULL, -- YS 20240827
						@promotion_cross_percent = NULL,
						@promotion_cross_amount = NULL,
						--@promotion_cross_type = NULL, --YS 20240822 -- YS 20240829
						@equity_percent = NULL,
						@equity_amount = NULL
						--@equity_type = NULL --YS 20240822 -- YS 20240829

					print'reset percentages for Admin'
				END

				-- Insert Merit_percent default value --YS 20211206
				IF @inputValue <> ''
				BEGIN
					SELECT 
						@merit_percent = ir.MeritPercent
					FROM vPEPSICO_Parameters AS par
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp 
						ON emp.idPayee = @idPayee
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON pfp.idPayee = @idPayee
						AND pfp.is_eligible = 1
						AND pfp.is_merit_eligible = 1
					LEFT JOIN PEPSICO_FocalPoint_MeritIncreaseRange AS ir 
						ON	ir.SalaryPlanCode_nk = emp.SalaryPlanCode_nk
						AND ir.CompensationIndex = @ci
						AND @cr_merit BETWEEN ISNULL(ir.CompaRatioMin, 0) AND ISNULL(ir.CompaRatioMax, 99999999)
						AND emp.LevelCode = ISNULL(ir.LevelCode, emp.LevelCode)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
					WHERE @merit_percent IS NULL
				END
			END
			ELSE

			-------------------------- PROMOTION LEVEL UPDATE
			--delete the promotion_cross_level if the promotion_cross_type <> 'CROSS'
			IF @promotion_cross_type = 'IN'
				SELECT @LevelCodeFinal = pfp.LevelCode
				FROM PEPSICO_Process_FocalPoint AS pfp
				WHERE pfp.idPayee = @idPayee
			-------------------------- PROMOTION SALARY PLAN UPDATE
			--delete the promotion_cross_level if the promotion_cross_type = ''
			IF @promotion_cross_type IS NULL
				SELECT @finalSalaryPlanCode_nk = pfp.SalaryPlanCode_nk,
				@LevelCodeFinal = pfp.LevelCode, --YS 20210826
				@final_min_pay = @min_pay,
				@final_mid_point_pay = @mid_point_pay,
				@final_max_pay = @max_pay
				FROM PEPSICO_Process_FocalPoint AS pfp
				WHERE pfp.idPayee = @idPayee


			-------------------------- R/M2025-05 Russia Mandatory Merit Increase -- YS 20251020
			IF @SalaryPlanCode_nk IN (SELECT SalaryplanCode_nk FROM PEPSICO_FocalPoint_Merit_Increase_forced)
			BEGIN
				SELECT 
					@final_max_pay = CASE WHEN emp.AnnualAmount * (100.0+mif.Merit_percent)/100.0 > pr.MaxPay
						THEN emp.AnnualAmount * (100.0+mif.Merit_percent)/100.0
						ELSE pr.MaxPay
					END ,
					@merit_percent = CASE WHEN ISNULL(@ci,0) <> 0 
						THEN CASE WHEN ISNULL(@merit_percent,0) > mif.Merit_percent
							THEN @merit_percent
							ELSE mif.merit_percent
						END
						ELSE NULL
					END 
				from py_payee as py -- use #py
				join PEPSICO_FocalPoint_EmpCurrentPayee AS emp
					on emp.idPayee = py.idPayee
				join PEPSICO_FocalPoint_Merit_Increase_forced as mif
					--on mif.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					on mif.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
				JOIN vPEPSICO_SalaryPlan_All AS sp
					--ON sp.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					ON sp.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
				LEFT JOIN PEPSICO_FocalPoint_PayRange AS pr
					--ON pr.SalaryPlanCode_nk = emp.SalaryPlanCode_nk	--PK 20260211 #ZD148392
					ON pr.SalaryPlanCode_nk = @finalSalaryPlanCode_nk	--PK 20260211 #ZD148392
					--AND pr.LevelCode = emp.LevelCode					--PK 20260211 #ZD148392
					AND pr.LevelCode = @LevelCodeFinal					--PK 20260211 #ZD148392
					AND sp.PayRange_Date_Lookup BETWEEN pr.PayRangeStartDate AND pr.PayRangeEndDate 
				where emp.GPID = @codePayee
			END
			

			-------------------------INDIAN PAY COMPONENT CALCULATION
			INSERT INTO @RTCPayComponent(FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, IncreasePercent, ProposedAmount)
			SELECT FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, IncreasePercent, ProposedAmount
			FROM _ufn_rtc_pay_components_refresh (@idPayee, @PlanId, @merit_percent, @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @SalaryPlanCode_nk)

		--select * from @RTCPayComponent 

			-- If the Employee is INDIAN, RECALCULATE @merit_amount,@dm_hr_proposal, @promotion_amount and @equity_amount
			IF EXISTS (SELECT 1 FROM @RTCPayComponent)
			BEGIN

				--@merit_amount
				; WITH cte_merit AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'MERIT'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004') 
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227
				)

				SELECT 
					@merit_amount = ROUND((inc.ProposedAmount - inc.Amount) / NULLIF(pfp.merit_proration, 0), 4)
				FROM PEPSICO_Process_FocalPoint AS pfp
				JOIN cte_merit AS inc
					ON 1=1 
				WHERE 
					pfp.idPayee = @idPayee

				--@@dm_hr_proposal
				--@dm_amount -- YS 20240827
				;WITH cte_dm AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						--MeritIncreaseTypeCode_nk = 'TARGETED'
						MeritIncreaseTypeCode_nk = 'DIFFERENTIATED'-- YS 20240918
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004')
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227 
				)

				SELECT
					--@dm_hr_proposal = ROUND(@merit_proposal_prorated + inc.ProposedAmount - inc.Amount, 4)
					@dm_amount =  ROUND((inc.ProposedAmount - inc.Amount), 4), -- YS 20240827
					@dm_hr_proposal = ROUND(inc.ProposedAmount, 4)
				FROM cte_dm AS inc

				--@promotion_amount
				;WITH cte_promotion AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'PROMOTION'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					-- AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004')
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227 
				)

				SELECT
					@promotion_cross_amount = ROUND((inc.ProposedAmount - inc.Amount), 4)
				FROM cte_promotion AS inc

				--@equity_amount
				;WITH cte_equity AS (
					SELECT
						SUM(Amount) AS Amount,
						SUM(ProposedAmount) AS ProposedAmount
					FROM @RTCPayComponent
					WHERE 
						MeritIncreaseTypeCode_nk = 'EQUITY'
					--AND PayComponentCode_nk IN ('PC-GBL0001', 'PC-IND0004', 'PC-IND0049', 'PC-IND0050', 'PC-IND0003', 'PC-IND0061') --YS 20231019
					--AND PayComponentCode_nk IN ('PC-GBL0084') -- JM 20240106
					--AND PayComponentCode_nk IN ('PC-IND0046', 'PC-IND0061', 'PC-IND0003', 'PC-IND0004') 
					AND PayComponentCode_nk IN ('PC-GBL0001') -- YS 20241227
				)
				SELECT
					@equity_amount = ROUND((inc.ProposedAmount - inc.Amount), 4)
				FROM cte_equity AS inc

			END
			----------------------- EGYPT EXCEPTION FOR @merit_percent
			IF EXISTS 
			(
				SELECT TOP 1 * 
				FROM PEPSICO_Process_FocalPoint AS pfp 
				JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS gov 
					ON gov.FiscalYear = @FiscalYear AND gov.GPID = pfp.codePayee
				WHERE pfp.idPayee = @idPayee
			)
				SELECT @merit_percent = 
						CASE WHEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) > ISNULL(@merit_percent, 0.0000) --YS 20210708
							THEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) 
							ELSE @merit_percent
						END
		
				FROM vPEPSICO_FocalPoint_Parameters AS par 
				JOIN k_m_plans_payees_steps AS pps 
					ON pps.id_plan = par.idPlanFocalPoint
				JOIN PEPSICO_Process_FocalPoint AS pfp
					ON pfp.idPayee = pps.id_payee
					AND pfp.is_eligible = 1 --YS 20210506
				JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS gov -- select * from PEPSICO_FocalPoint_EmpGovernmentIncrease
					ON gov.FiscalYear = par.FiscalYear -- select fiscalyear from vPEPSICO_FocalPoint_Parameters
					AND gov.GPID = pfp.codePayee
				JOIN vPEPSICO_Process_FocalPoint_Values_Pivoted AS val
					ON val.id_step = pps.id_step
				JOIN k_m_values AS kmv WITH (NOLOCK)-- YS 20221201
					ON kmv.id_step = pps.id_step
				JOIN k_m_fields AS kmf
					ON kmf.id_field = kmv.id_field AND kmf.code_field = 'merit_percent' 
				WHERE
					@merit_percent <> 
						CASE WHEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) > ISNULL(@merit_percent, 0.0000) --YS 20210708
							THEN ROUND(ISNULL((gov.IncreaseAmount + gov.IncreaseAmount2) / NULLIF(pfp.merit_proration, 0) / NULLIF(pfp.base_salary, 0) * 100, 0), 4, 1) 
							ELSE @merit_percent
						END
					AND pfp.idPayee = @idPayee

			----------------------- EGYPT EXCEPTION FOR @merit_percent END

			-- Calculation of proposals based on increases. They are used to define increase percentages when an Amount is entered
			SELECT
				@merit_proposal_prorated = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) --LIKE 'SP-IND%' 
						THEN pfp.base_salary + ISNULL(@merit_amount,0.0) * pfp.merit_proration 
						ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee--YS 20210708
	

			SELECT 
				@dm_hr_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @dm_hr_proposal
						ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee--YS 20210708

			SELECT	
				@promotion_cross_proposal =	
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @dm_hr_proposal + @promotion_cross_amount
						-- JM 20230827 promotion multiplier 
						--ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000)
						ELSE pfp.base_salary * 
								(1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
								* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
								* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee


			-- YS 20230807 recalculate Equity_percent and Equity_Amount
			-- IF @equity_percent IS ENTERED
			IF @id_field = @id_field_equity_percent AND  @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 Added india check
			BEGIN

				-- work out @equity_amount Rounded 
				SELECT
					-- JM 20230827 promotion multiplier 
					--@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					@equity_amount = ROUND(pfp.base_salary 
											* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
											* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
											* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
											* @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
				FROM PEPSICO_Process_FocalPoint AS pfp
				LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
					ON rnd.GPID = pfp.gpid
					AND rnd.RoundIncreasesFlag = 1
				WHERE pfp.idPayee = @idPayee

				--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @equity_percent IS NOT NULL --YS 20210708 --YS20210824 COMMENTED
					-- ADJUST @equity_percent ROUNDED
				SELECT
					@equity_percent = @equity_amount / NULLIF(@promotion_cross_proposal,0) * 100.0000

			END
			-- IF @equity_amount IS ENTERED
			IF @id_field = @id_field_equity_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
			BEGIN

				--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
				-- work out Equity Percent and do the same logic as above
				SELECT
					@equity_percent = ROUND( ROUND(@equity_amount, ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@promotion_cross_proposal, 0.0) * 100.0000, 2) --YS 20210712 	
					--/*potentially needed*/,@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
			
				FROM PEPSICO_Process_FocalPoint AS pfp
				LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
					ON rnd.GPID = pfp.gpid
					AND rnd.RoundIncreasesFlag = 1
				WHERE pfp.idPayee = @idPayee
			END

			SELECT	
				@equity_proposal =
				CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN  @promotion_cross_proposal + @equity_amount
						-- JM 20230827 promotion multiplier 
						--ELSE pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
						ELSE	pfp.base_salary 
								* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
								* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
								* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000)
								* (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
				END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee


			----------------------------------- Refresh Minimum_amount
				--minimum_amount
			;WITH cte_min
			AS(
				SELECT
				adj_ovr.id as id_ovr,
				ir.id AS id_min,
				pfp.idpayee,
					CASE WHEN adj_ovr.GPID IS NOT NULL --YS 20201030
						THEN
							--Override part
							CASE WHEN adj_ovr.Yes_No = 'YES'
								THEN
								CASE WHEN @equity_proposal * pfp.merit_annualised_factor < @final_min_pay 
									THEN @final_min_pay / NULLIF(pfp.merit_annualised_factor, 0) - @equity_proposal 
									ELSE 0 
								END 
								ELSE 0 
							END
						--Normal calculation
						ELSE
							CASE WHEN @equity_proposal * pfp.merit_annualised_factor < @final_min_pay 
								THEN @final_min_pay / NULLIF(pfp.merit_annualised_factor, 0) - @equity_proposal
								ELSE 0  
							END
					END
					AS MinimumAmount
				FROM PEPSICO_Process_FocalPoint AS pfp
				JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
					ON emp.idPayee = pfp.idPayee
				LEFT JOIN PEPSICO_FocalPoint_Minimum AS ir -- YS 20210826
					ON	ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					AND ISNULL(@ci, 10) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
					AND @cr_minimum BETWEEN ISNULL(ir.CompaRatioMin, 0) AND ISNULL(ir.CompaRatioMax, 99999999)
					AND @LevelCodeFinal = ISNULL(ir.LevelCode, @LevelCodeFinal)
					AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
					AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
					AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
					AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
					AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
					AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
					AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
				LEFT JOIN PEPSICO_FocalPoint_AdjustmentToMinimum_GPID AS adj_ovr
					ON adj_ovr.GPID = pfp.gpid
				WHERE pfp.idPayee = @idPayee
				--AND (ir.id IS NOT NULL OR adj_ovr.id IS NOT NULL)

			)
			SELECT
				 @minimum_amount = 
					 CASE WHEN (cte.id_min IS NOT NULL OR cte.id_ovr IS NOT NULL) 
						THEN cte.MinimumAmount
						ELSE 0.00
					END
			FROM cte_min AS cte

			-- Calculate @minimum_proposal
			SELECT 
				@minimum_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @minimum_amount
						+ @equity_proposal
						ELSE	@minimum_amount
						-- JM 20230827 promotion multiplier 
						--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
						--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
						+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
						+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
						+ pfp.base_salary 
					END
			FROM PEPSICO_Process_FocalPoint AS pfp
			WHERE pfp.idPayee = @idPayee
	

			------------------------------------ Refresh Lump Sum Amount

			SELECT
				@final_lump_sum =
					CASE WHEN lump_ovr.GPID IS NOT NULL 
						THEN
							--Override part
							CASE WHEN lump_ovr.Yes_No = 'YES'
								THEN
								CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
									THEN 
									CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
											--OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
											OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) ) -- YS 20251113
										--THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase 
										THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- YS 20251113                 
										ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
									ELSE 0 
								END 
								ELSE 0
							END
						--Normal calculation
						ELSE 
							CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
								THEN 
									CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
											--OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
											OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) ) -- YS 20251113
										--THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase  
										THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- YS 20251113                  
										ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
								END
								ELSE 0 
							END 
					END
				--AS LumpSumAmount

			FROM vPEPSICO_FocalPoint_Parameters AS par
			JOIN PEPSICO_Process_FocalPoint AS pfp 
				ON 1 = 1
			JOIN py_Payee AS py 
				ON py.idPayee = pfp.idPayee
			JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
				ON emp.idPayee = pfp.idPayee
			JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
				ON kmv.idpayee = pfp.idPayee
			JOIN PEPSICO_SalaryPlan_All AS sp
				ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
			--JOIN PEPSICO_FocalPoint_EmpCompaRatio AS ecr 
			--	ON ecr.GPID = pfp.codePayee 
			--	AND ecr.MeritIncreaseTypeCode_nk = 'LUMP'
			LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
				ON	
				--ir.SalaryPlanCode_nk = ISNULL(kmv.promotion_cross_salary_plan, pfp.SalaryPlanCode_nk)
				ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
				AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
				AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
				AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
				AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
				AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
				AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
				AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
				AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
				AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
				AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
				AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
				AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
			LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
				ON lump_ovr.GPID = pfp.gpid 
			LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
				ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
			LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
				ON egi.gpid = py.codePayee 
				AND egi.FiscalYear = par.FiscalYear 
			LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
				ON er.FiscalYear = par.FiscalYear 
				AND er.gpid = pfp.codePayee
			WHERE 
				(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
				AND py.idPayee = @idPayee


			IF @final_lump_sum IS NULL	-- YS 20211014
				SELECT @final_lump_sum = 0.000

			------------------------------------ Refresh Lump Sum Amount END
		--select @final_lump_sum
			------------------------------------ Set @final_proposal and @final_proposal_rounded
			SELECT 
				@final_proposal = 
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
						ELSE
							@minimum_amount 
							-- JM 20230827 promotion multiplier 
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
							+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
							- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
						END,
				@final_proposal_rounded=
					CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
						THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
						ELSE ROUND(@minimum_amount 
							-- JM 20230827 promotion multiplier 
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							--+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
							+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
							+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
							- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
							, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
						END
			FROM PEPSICO_Process_FocalPoint AS pfp 
			JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
			LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
			WHERE pfp.idPayee = @idPayee

			SELECT
				@final_increase_rounded = (@final_proposal_rounded / pfp.base_salary - 1.00000) * 100.00000
			FROM PEPSICO_Process_FocalPoint AS pfp 
			--WHERE pfp.gpid = @codePayee --YS 20211201
			WHERE pfp.codePayee = @codePayee

			--Recalculate Final Pay Component if Lump Sum is not null
			IF @final_lump_sum > 0 
			BEGIN
				UPDATE pc
				SET
					pc.Amount = pcf.Amount,
					pc.IncreasePercent = pcf.IncreasePercent,
					pc.ProposedAmount = pcf.ProposedAmount
				FROM @RTCPayComponent AS pc
				JOIN _ufn_rtc_pay_components_final_refresh (@RTCPayComponent, @final_increase_rounded, @final_max_pay) AS pcf
					ON pcf.MeritIncreaseTypeCode_nk = pc.MeritIncreaseTypeCode_nk
					AND pcf.PayComponentCode_nk = pc.PayComponentCode_nk
				WHERE pc.MeritIncreaseTypeCode_nk = 'FINAL'

			END

			-- Refresh Compa Ratios 
			SELECT 
				@cr_merit = cr_merit,
				@cr_targeted = cr_targeted,
				@cr_promotion = cr_promotion,
				@cr_equity	= cr_equity,
				@cr_minimum	= cr_minimum,
				@cr_lump = cr_lump,
				@cr_final = cr_final
			--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
			FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr


	--select @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final, @final_lump_sum as lumpsum, @final_proposal, @final_proposal_rounded as final_Prop_Round, @min_pay as min_pay, @mid_point_pay, @max_pay, @final_min_pay as finalminpay, @final_mid_point_pay, @final_max_pay
	--select @ci,@merit_percent	,@merit_amount	,@merit_amount_prorated,@merit_proposal_prorated,@dm_hr_dm_increase,@dm_hr_proposal,@promotion_cross_percent,@promotion_cross_amount,@promotion_cross_proposal,@promotion_cross_type,@equity_percent,@equity_amount	,@equity_proposal,@minimum_amount,@final_lump_sum,@final_proposal_rounded, @cr_merit,@cr_targeted,@cr_promotion,@cr_equity,@cr_minimum,@cr_lump,@cr_final,@LevelCodeFinal,@finalSalaryPlanCode_nk,@min_pay,@mid_point_pay,@max_pay,@final_min_pay,@final_mid_point_pay,@final_max_pay				
--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal	
	

			----------------------------------------------- Performance Ratings Field START -------------------------------------------------

			IF @id_field = @id_field_ci
			BEGIN
				-- Refresh ic score range based on Performance Rating and Merit Compa_ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_icscore_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_merit)

				-- Refresh merit range based on Performance Rating and Merit Compa_ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_range_refresh(@PlanId, @idStep, @idPayee, @ci,  @cr_merit)

				-- Refresh promotion range based on Performance Rating, Promotion_Type, Promotion_CompaRatio, LevelCodeFinal, SalaryPlanCodeFinal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_range_refresh(@PlanId, @idStep, @idPayee, @ci, @promotion_cross_type, @cr_promotion, @LevelCodeFinal, @finalSalaryPlanCode_nk)
			
				-- Refresh equity range based on Performance Rating, Equity CompaRatio, LevelCodeFinal, SalaryPlanCodeFinal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2


--insert into zz_jm_temp_rtc_dm (PlanId, idStep, idPayee, ci, cr_targeted, FinalSalaryPlanCode_nk, LevelCodeFinal, merit_percent, mid_point_pay, uidProfile, max_pay)
--select
--	@PlanId,
--	@idStep,
--	@idPayee,
--	@ci,
--	@cr_targeted ,
--	@FinalSalaryPlanCode_nk ,
--	@LevelCodeFinal ,
--	@merit_percent ,
--	@mid_point_pay ,
--	@uidProfile ,
--	@max_pay 

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3


				-- Refresh IC Score, Merit, DM, Promotion, Equity, Minimum, Lump Sum and Final
				--IF @inputValue = '' --YS 20210813 commented
				--BEGIN

				---- Clear ic score"--YS 20210908
				--INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				--SELECT 
				--	@idStep AS PrimaryKey, 
				--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30))) AS ObjectFieldAlias,
				--	'' AS ObjectAttribute,
				--	1 AS IsValid,
				--	'' AS InvalidReason,
				--	1 AS AllowEdit,
				--	NULL AS NewValue

				-- Refresh merit_amount, merit_proposal_prorated
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount, @merit_proposal_prorated)

/* -- YS 20240826
				IF @uidProfile IN (@uidProfileManager, @uidProfileManagerLG8, @uidProfileAdmin) --YS 20210713
					--Refresh dm_manager_dm_increase
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_dm AS NVARCHAR(30)), '_', CAST(@id_field_dm_manager_dm_increase AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,			
						CAST(@dm_manager_dm_increase AS NVARCHAR) AS NewValue
-- YS 20240826
*/
/* YS 20240827 Now done in _ufn_rtc_dm_fields_refresh with @dm_amount and @dm_hr_proposal

				IF @uidProfile IN (@uidProfileHR, @uidProfileHRLG8, @uidProfileCompAdmin, @uidProfileSuperUser, @uidProfileAdmin) --YS 20210713
					-- Refresh dm_hr_dm_increase
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_dm AS NVARCHAR(30)), '_', CAST(@id_field_dm_hr_dm_increase AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,			
						CAST(@dm_hr_dm_increase AS NVARCHAR) AS NewValue
*/
				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_percent, promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee, @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
				
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			
				--END--YS 20210813 commented


			END
			--------------------------------------------- Performance Ratings Field END ----------------------------------------------

			--------------------------------------------- Merit Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_merit_percent, @id_field_merit_amount) 
			BEGIN

				IF @id_field = @id_field_merit_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN
					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Merit_percent if Merit_Amount is entered
					SELECT
						@merit_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(pfp.base_salary,0.0) * 100.0000,2) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629 --select * from PEPSICO_FocalPoint_EmpRounding
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--Refresh proposals with the correct merit_percent
					SELECT
						@merit_proposal_prorated = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration), --YS 20210708
						@dm_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20240827
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END				
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830
					
					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END

				IF @id_field = @id_field_merit_percent AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 added india check
				BEGIN
					--Calculate @merit_amount rounded
					SELECT 
						@merit_amount = ROUND(pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					----------------------- ADJUST @merit_percent based on @merit_amount rounded IF NOT INDIAN
					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @merit_percent IS NOT NULL --YS 20210708 --YS 20210824 COMMENTED
	
					SELECT 
						@merit_percent = ROUND(@merit_amount  / NULLIF(pfp.base_salary,0.0) * 100.0000, 2) --YS 20210712
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

			

					--Refresh proposals with the correct merit_percent
					SELECT
						@merit_proposal_prorated = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration), --YS 20210708
						@dm_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20240827
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						-- JM 20230827 * pfp.promotion_multiplier
						--@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000), --YS 20210708
						--@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee
				END
			
				-- Refresh merit_amount, merit_proposal_prorated
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_merit_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount, @merit_proposal_prorated)

				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3
			
			END
			--------------------------------------------- Merit Percent and Amount Field END ---------------------------------------------
/*-- START COMMENT YS 20240826
			--------------------------------------------- Differentiated Merit Manager Percent Field ---------------------------------------------
			IF @id_field = @id_field_dm_manager_dm_increase
			BEGIN

				-- Refresh dm_hr_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal) --YS 20210629
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal) --YS 20210629
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_manager_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_manager_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee, @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee,@final_proposal, @final_proposal_rounded, @cr_final)
			
				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
			
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)


			END
			--------------------------------------------- Differentiated Merit Manager Percent Field END ---------------------------------------------
-- END COMMENT YS 20240826
*/
			--------------------------------------------- Differentiated Merit HR Percent Field ---------------------------------------------
			IF @id_field IN (@id_field_dm_hr_dm_increase,@id_field_dm_amount) -- YS 20240827
			BEGIN
				IF @id_field = @id_field_dm_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN
					-- work out DM_percent if DM_Amount is entered
					SELECT
						@dm_hr_dm_increase = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@merit_proposal_prorated, 0.0) * 100.0000, 2)
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee
					
					--Refresh proposals with the correct merit_percent
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END	
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END
				
				IF @id_field = @id_field_dm_hr_dm_increase AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception)
				BEGIN
--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal	
					--Calculate @dm_amount rounded
					SELECT 
						@dm_amount = 
							ROUND(	pfp.base_salary 
										* (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) 
										* (CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) 
									, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK)
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					----------------------- ADJUST @dm_hr_dm_increase based on @dm_amount rounded IF NOT INDIAN
	
					SELECT 
						@dm_hr_dm_increase = ROUND(@dm_amount  / NULLIF(@merit_proposal_prorated,0.0) * 100.0000, 2) --YS 20210712
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee


--select @dm_amount, @dm_hr_dm_increase, @dm_hr_proposal			

					--Refresh proposals with the correct merit_percent
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee
					
				END

				-- Refresh dm_hr_proposal, dm_amount and dm_hr_dm_increase
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal)-- @merit_percent,  @dm_hr_dm_increase)
				FROM _ufn_rtc_dm_fields_refresh(@PlanId, @idStep, @idPayee, @dm_hr_proposal, @dm_hr_dm_increase, @dm_amount)-- YS 20240827

				-- Refresh promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh merit_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh DM_spend
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_dm_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)
			
				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr
			
				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025	
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3

			END
			--------------------------------------------- Differentiated Merit HR Percent Field END ---------------------------------------------

			--------------------------------------------- Promotion Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_promotion_percent, @id_field_promotion_amount)
			BEGIN

				IF @id_field = @id_field_promotion_percent AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 added india check
				BEGIN
					-- CALCULATE @promotion_cross_amount ROUNDED
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_amount = ROUND(pfp.base_salary * (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) * (1.0000 + CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) * try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000 , ISNULL(rnd.DecimalRoundingFactor,2)) 
						@promotion_cross_amount = 
							ROUND(	pfp.base_salary 
										* (1.0000 + CAST(ISNULL(@merit_percent, 0.0000) AS numeric(18,5)) / 100.0000 * pfp.merit_proration) 
										* (1.0000 + CAST(ISNULL(@dm_hr_dm_increase, 0.0000) AS numeric(18,5)) / 100.0000) 
--										* (try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000 * pfp.promotion_multiplier) 
										* (try_cast(@promotion_cross_percent as numeric(18,5)) / 100.0000) -- JM 20230915 removed promotion multiplier
									, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @promotion_cross_percent IS NOT NULL --YS 20210708 --YS 20210824 commented
						-- ADJUST @promotion_cross_percent based on @promotion_cross_amount rounded
					SELECT
--						@promotion_cross_percent = @promotion_cross_amount / NULLIF(@dm_hr_proposal, 0.0) * 100.0000
--						@promotion_cross_percent = @promotion_cross_amount / pfp.promotion_multiplier / NULLIF(@dm_hr_proposal, 0.0) * 100.0000 -- JM 20230827 add promotion mulitplier
						@promotion_cross_percent = @promotion_cross_amount / NULLIF(@dm_hr_proposal, 0.0) * 100.0000 -- JM 20230915 removed promotion multiplier
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					--Refresh proposals with the correct equity_percent -- YS 20240830
					SELECT
						@dm_hr_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000), --YS 20210708
						@promotion_cross_amount =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20240827
						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000), --YS 20210708
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20210708
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000) --YS 20210708
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

				END
			
				IF @id_field = @id_field_promotion_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Promotion Percent and do the same logic as above
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2)  --YS 20210712
--						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / pfp.promotion_multiplier / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2)  
						@promotion_cross_percent = ROUND(ROUND(ISNULL(@inputValue, 0.0), ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@dm_hr_proposal, 0.0) * 100.0000, 2) -- JM 20230915 removed promotion multiplier 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee	

					--refresh @promotion_cross_percent_multiplier --YS 20240830
					SELECT @promotion_cross_percent_multiplier = ((1.0 + @promotion_cross_percent / 100.0) * pfp.promotion_multiplier - 1.0) * 100.0
					FROM PEPSICO_Process_FocalPoint as pfp
					WHERE pfp.idPayee = @idPayee	

			
					--Refresh proposals with the correct @promotion_cross_percent
					SELECT
-- JM 20230827 changed to use promotion multiplier
--						@promotion_cross_proposal =	pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000),
--						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000)
						@promotion_cross_proposal =	pfp.base_salary 
														* (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) 
														* (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) 
														* (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000),
						@equity_amount = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (ISNULL(@equity_percent, 0.0000) / 100.0000), --YS 20240830
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000),
						@minimum_proposal =  -- YS 20240830
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_amount
								+ @equity_proposal
								ELSE	@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary 
							END	
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					------------------------------------ Refresh Lump Sum Amount -- YS 20240830

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor -- if final - max > 
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0)) -- JM 20201231
												THEN ROUND((@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- JM 20201013 removed government increase                      
												ELSE ROUND((@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding)) -- - ISNULL(egi.IncreaseAmount, 0) - ISNULL(egi.IncreaseAmount2, 0) -- JM 20201013 removed government increase        -- final - max
										END
										ELSE 0 
									END 
							END
						--AS LumpSumAmount

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 			
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK)
						ON er.FiscalYear = par.FiscalYear 
						AND er.gpid = pfp.codePayee
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL	-- YS 20211014
						SELECT @final_lump_sum = 0.000

					------------------------------------ Refresh Lump Sum Amount END
					--select @final_lump_sum
					------------------------------------ Set @final_proposal and @final_proposal_rounded  -- YS 20240830
					SELECT 
						@final_proposal = 
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN @minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								ELSE
									@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								END,
						@final_proposal_rounded=
							CASE WHEN pfp.SalaryPlanCode_nk IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE 'SP-IND%' 
								THEN ROUND(@minimum_proposal - (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor), ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								ELSE ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent_multiplier, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
								END
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

				END

				-- Refresh promotion_percent,  promotion_amount, promotion_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal)
				--FROM _ufn_rtc_promotion_fields_refresh(@PlanId, @idStep, @idPayee, @promotion_cross_percent, @promotion_cross_amount, @promotion_cross_proposal, @promotion_cross_type) -- YS 20240822 -- COMMENTED YS 20240829
				
				-- Refresh equity range -- YS 20240829_2
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey,  ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh  merit_spend,
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)

			END 
			--------------------------------------------- Promotion Percent and Amount Field END ---------------------------------------------

			--------------------------------------------- Promotion Type Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_type
			BEGIN
				-- Refresh Promotion Range,  
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_promotion_range_refresh(@PlanId, @idStep, @idPayee, @ci, @promotion_cross_type, @cr_promotion, @LevelCodeFinal, @finalSalaryPlanCode_nk)


				--Refresh k_m_fields_values for SalaryPlan_List, Level_List
				--EXEC SP_RTC_FieldValuesRefresh @idStep, @idPayee, @promotion_cross_type, @finalSalaryPlanCode_nk --YS 20210831 Commented

				--Set promotion_cross_level to NULL if promotion_cross_type = 'IN' or ''
				IF @promotion_cross_type = 'IN' OR @promotion_cross_type IS NULL --YS 20210826
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_level AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,
						NULL AS NewValue

				--Set promotion_cross_salary_plan to NULL if promotion_cross_type = ''
				IF @promotion_cross_type IS NULL
					INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
					SELECT 
						@idStep AS PrimaryKey, 
						CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_salary_plan AS NVARCHAR(30))) AS ObjectFieldAlias,
						'' AS ObjectAttribute,
						1 AS IsValid,
						'' AS InvalidReason,
						1 AS AllowEdit,
						NULL AS NewValue
				
			END
			--------------------------------------------- Promotion Type Field END ---------------------------------------------

			--------------------------------------------- Promotion Level Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_level
			BEGIN
				-- Refresh Equity_range
				-- equity range 
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, Targeted Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025	
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3

			END
			--------------------------------------------- Promotion Level Field END ---------------------------------------------

			--------------------------------------------- Promotion Salary Plan Field ---------------------------------------------
			IF @id_field = @id_field_promotion_cross_salary_plan
			BEGIN
				-- Refresh Equity_range, all CompaRatio, DM_Multiplier, DM_Cap
				-- equity range 
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk)
				FROM _ufn_rtc_equity_range_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_equity, @LevelCodeFinal, @finalSalaryPlanCode_nk, @promotion_cross_proposal) -- YS 20240829_2

				-- Refresh Compa Ratios for DM Range
				SELECT 
					@cr_merit = cr_merit,
					@cr_targeted = cr_targeted,
					@cr_promotion = cr_promotion,
					@cr_equity	= cr_equity,
					@cr_minimum	= cr_minimum,
					@cr_lump = cr_lump,
					@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				-- Refresh DM_Multiplier, dm_STP, DM_Eligible, DM_Compa_Ratio
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay)	--ys 20211025		
				--FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile)
				FROM _ufn_rtc_dm_multiplier_refresh(@PlanId, @idStep, @idPayee, @ci, @cr_targeted, @FinalSalaryPlanCode_nk, @LevelCodeFinal, @merit_percent, @mid_point_pay, @uidProfile, @max_pay) -- YS 20240829_3
			END
			--------------------------------------------- Promotion Salary Plan Field END ---------------------------------------------

			--------------------------------------------- Equity Percent and Amount Field ---------------------------------------------
			IF @id_field IN (@id_field_equity_percent, @id_field_equity_amount) 
			BEGIN
/*				-- IF @equity_percent IS ENTERED
				IF @id_field = @id_field_equity_percent AND  @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%' --YS 20210824 Added india check
				BEGIN

					-- work out @equity_amount Rounded 
					SELECT
						@equity_amount = ROUND(pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * @equity_percent / 100.0000, ISNULL(rnd.DecimalRoundingFactor,2)) 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%' AND @equity_percent IS NOT NULL --YS 20210708 --YS20210824 COMMENTED
						-- ADJUST @equity_percent ROUNDED
					SELECT
						@equity_percent = @equity_amount / NULLIF(@promotion_cross_proposal,0) * 100.0000

				END
				-- IF @equity_amount IS ENTERED
				IF @id_field = @id_field_equity_amount AND @finalSalaryPlanCode_nk NOT IN (SELECT SalaryPlanCode_nk FROM PEPSICO_SalaryPlan_Exception) -- LIKE '%SP-IND%'
				BEGIN

					--IF @finalSalaryPlanCode_nk NOT LIKE '%SP-IND%'
					-- work out Equity Percent and do the same logic as above
					SELECT
						@equity_percent = ROUND( ROUND(@equity_amount, ISNULL(rnd.DecimalRoundingFactor,2)) / NULLIF(@promotion_cross_proposal, 0.0) * 100.0000, 2) --YS 20210712 
					FROM PEPSICO_Process_FocalPoint AS pfp
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS rnd  WITH (NOLOCK) --YS 20210629
						ON rnd.GPID = pfp.gpid
						AND rnd.RoundIncreasesFlag = 1
					WHERE pfp.idPayee = @idPayee
		
					--Refresh proposals with the correct @equity_percent
					SELECT
						@equity_proposal = pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * (1.0000 + ISNULL(@equity_percent, 0.0000) / 100.0000)
					FROM PEPSICO_Process_FocalPoint AS pfp
					WHERE pfp.idPayee = @idPayee

					-- Refresh minimum, lump sum and Final proposal as the equity_percent has been calculated right now -- YS 20230807

					-- Calculate @minimum_proposal -- YS 20230807
					SELECT 
						@minimum_proposal =
							@minimum_amount
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * (1 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary * ISNULL(@merit_percent, 0.0000) / 100.0000 * pfp.merit_proration 
								+ pfp.base_salary
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee



					------------------------------------ Refresh Lump Sum Amount -- YS 20230807

					SELECT
						@final_lump_sum =
							CASE WHEN lump_ovr.GPID IS NOT NULL 
								THEN
									--Override part
									CASE WHEN lump_ovr.Yes_No = 'YES'
										THEN
										CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) 
											THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0))
												THEN (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0)                   
												ELSE (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor
												END
											ELSE 0 
										END 
										ELSE 0
									END
								--Normal calculation
								ELSE 
									CASE WHEN @minimum_proposal * pfp.merit_annualised_factor > ISNULL(tcc.MinPay, @final_max_pay) -- final above max pay
										THEN 
											CASE WHEN (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor > (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor
													OR (egi.id IS NOT NULL AND (@final_max_pay - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor < ISNULL(egi.IncreaseAmount, 0.0) + ISNULL(egi.IncreaseAmount2, 0.0))
												THEN (@minimum_proposal - pfp.base_salary) * pfp.merit_annualised_factor * pfp.FTEFactor - ISNULL(egi.IncreaseAmount, 0.0) - ISNULL(egi.IncreaseAmount2, 0.0)                     
												ELSE (@minimum_proposal * pfp.merit_annualised_factor - ISNULL(tcc.MinPay, @final_max_pay)) * pfp.FTEFactor
										END
										ELSE 0 
									END 
							END

					FROM vPEPSICO_FocalPoint_Parameters AS par
					JOIN PEPSICO_Process_FocalPoint AS pfp 
						ON 1 = 1
					JOIN py_Payee AS py 
						ON py.idPayee = pfp.idPayee
					JOIN PEPSICO_FocalPoint_EmpCurrentPayee AS emp
						ON emp.idPayee = pfp.idPayee
					JOIN vPEPSICO_Process_FocalPoint_Values AS kmv 
						ON kmv.idpayee = pfp.idPayee
					JOIN PEPSICO_SalaryPlan_All AS sp
						ON sp.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk 
					LEFT JOIN PEPSICO_FocalPoint_LumpSum AS ir 
						ON	
						ir.SalaryPlanCode_nk = @FinalSalaryPlanCode_nk
						AND ISNULL(@ci, 5) BETWEEN ISNULL(ir.CompensationIndexMin, 0) AND ISNULL(ir.CompensationIndexMin, 100) 
						AND @cr_lump BETWEEN ISNULL(ir.CompaRatioMin, 0.0) AND ISNULL(ir.CompaRatioMax, 9999999.9)
						AND @LevelCodeFinal = COALESCE(ir.LevelCode, @LevelCodeFinal)
						AND emp.SectorCode_nk = ISNULL(ir.SectorCode_nk, emp.SectorCode_nk)
						AND emp.DivisionCode_nk = ISNULL(ir.DivisionCode_nk, emp.DivisionCode_nk)
						AND emp.RegionCode_nk = ISNULL(ir.RegionCode_nk, emp.RegionCode_nk)
						AND emp.BusinessUnitCode_nk = ISNULL(ir.BusinessUnitCode_nk, emp.BusinessUnitCode_nk)
						AND emp.MarketUnitCode_nk = ISNULL(ir.MarketUnitCode_nk, emp.MarketUnitCode_nk)
						AND emp.WorkLocationCode_nk = ISNULL(ir.WorkLocationCode_nk, emp.WorkLocationCode_nk)
						AND emp.EmpTypeCode = ISNULL(ir.EmpTypeCode, emp.EmpTypeCode)
						AND ISNULL(emp.idCompGroup, -1) = ISNULL(ir.idCompGroup, ISNULL(emp.idCompGroup, -1))
						AND emp.LegalEntityCode_nk = ISNULL(ir.LegalEntityCode_nk, emp.LegalEntityCode_nk) -- YS 20211210
					LEFT JOIN PEPSICO_FocalPoint_LumpSum_GPID AS lump_ovr 
						ON lump_ovr.GPID = pfp.gpid 
					LEFT JOIN PEPSICO_PayRangeTCC AS tcc 
						ON ir.is_tcc = 1 AND tcc.LevelCode = @LevelCodeFinal
					LEFT JOIN PEPSICO_FocalPoint_EmpGovernmentIncrease AS egi 
						ON egi.gpid = py.codePayee 
						AND egi.FiscalYear = par.FiscalYear 
					WHERE 
						(ir.id IS NOT NULL OR lump_ovr.id IS NOT NULL)
						AND py.idPayee = @idPayee


					IF @final_lump_sum IS NULL
						SELECT @final_lump_sum = 0.000


					-- Refresh Final_proposal and final_proposal_rounded -- YS 20230807
					SELECT
						@final_proposal =
							@minimum_amount 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
								+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
								+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
								- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
								,
						@final_proposal_rounded=
							ROUND(@minimum_amount 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * (1.0000 + ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) * ISNULL(@equity_percent, 0.0000) / 100.0000)
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * (1.0000 + ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000) * ISNULL(@promotion_cross_percent, 0.0000) / 100.0000) 
									+ (pfp.base_salary * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration) * ISNULL(@dm_hr_dm_increase, 0.0000) / 100.0000)
									+ pfp.base_salary  * (1.0000 + ISNULL(@merit_percent, 0.000) / 100.0000 * pfp.merit_proration)
									- (@final_lump_sum / pfp.merit_annualised_factor / pfp.FTEFactor)
									, ISNULL(er.DecimalRoundingFactor, par.FocalPointDefaultRounding))
					FROM PEPSICO_Process_FocalPoint AS pfp 
					JOIN vPEPSICO_FocalPoint_Parameters AS par ON 1 = 1
					LEFT JOIN PEPSICO_FocalPoint_EmpRounding AS er WITH(NOLOCK) ON er.FiscalYear = par.FiscalYear AND er.gpid = pfp.codePayee
					WHERE pfp.idPayee = @idPayee

					-- Refresh Compa Ratios -- YS 20230807
					SELECT 
						@cr_merit = cr_merit,
						@cr_targeted = cr_targeted,
						@cr_promotion = cr_promotion,
						@cr_equity	= cr_equity,
						@cr_minimum	= cr_minimum,
						@cr_lump = cr_lump,
						@cr_final = cr_final
					FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

				END
*/

				-- Refresh equity_percent, equity_amount, equity_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal)
				--FROM _ufn_rtc_equity_fields_refresh(@PlanId, @idStep, @idPayee, @equity_percent, @equity_amount, @equity_proposal, @equity_type) -- YS 20240822 -- COMMENTED YS 20240829

				-- Refresh  merit_spend,
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				--FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent,  @dm_hr_dm_increase, @promotion_cross_percent, @equity_percent, @minimum_amount, @final_lump_sum)
				FROM _ufn_rtc_merit_spend_fields_refresh(@PlanId, @idStep, @idPayee, @merit_percent, @merit_amount,  @dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_amount, @equity_percent, @equity_amount, @minimum_amount, @final_lump_sum, @finalSalaryPlanCode_nk)

				-- Refresh minimum_amount and minimum_proposal
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_minimum_fields_refresh(@PlanId, @idStep, @idPayee,  @minimum_amount, @minimum_proposal)

				-- Refresh lump_sum
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_lump_fields_refresh(@PlanId, @idStep, @idPayee,@final_lump_sum)
			
				-- Refresh final_proposal, final_proposal_rounded, Compa Ratio final
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT
					PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
				FROM _ufn_rtc_final_fields_refresh(@PlanId, @idStep, @idPayee, @final_proposal, @final_proposal_rounded, @cr_final)


			END
			--------------------------------------------- Equity Percent and Amount Field END ---------------------------------------------

		----------------------------------------------- Compa Ratio Refresh ---------------------------------------------
			-- Refresh Compa Ratios
			SELECT 
				@cr_merit = cr_merit,
				@cr_targeted = cr_targeted,
				@cr_promotion = cr_promotion,
				@cr_equity	= cr_equity,
				@cr_minimum	= cr_minimum,
				@cr_lump = cr_lump,
				@cr_final = cr_final
				--FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr -- YS 20241003
				FROM _ufn_rtc_all_compa_ratio_refresh(@idPayee,@PlanId ,@merit_percent ,@dm_hr_dm_increase, @promotion_cross_percent, @promotion_cross_percent_multiplier, @promotion_job_code, @equity_percent, @minimum_amount, @final_lump_sum, @mid_point_pay, @final_mid_point_pay, @finalSalaryPlanCode_nk, @RTCPayComponent) AS cr

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT
				PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue
			FROM _ufn_rtc_compa_ratio_fields_refresh(@PlanId, @idStep, @idPayee, @cr_merit, @cr_targeted, @cr_promotion, @cr_equity, @cr_minimum, @cr_lump, @cr_final)

		--------------------------------------------- Compa Ratio Refresh END -------------------------------------------

		-------------------------------------------- Refresh ic_score----------------------------------

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
			SELECT 
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@ic_score AS NewValue
			

		-- REMOVED TEMPORARY FIX YS 20210826
	----TEMPORARY FIX TO UPDATE PROMOTION_LEVEL--Set promotion_cross_level to NULL if promotion_cross_type = IN
	--	IF @promotion_cross_type = 'IN'
	--		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
	--		SELECT 
	--			@idStep AS PrimaryKey, 
	--			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_promotion AS NVARCHAR(30)), '_', CAST(@id_field_promotion_cross_level AS NVARCHAR(30))) AS ObjectFieldAlias,
	--			'' AS ObjectAttribute,
	--			1 AS IsValid,
	--			'' AS InvalidReason,
	--			1 AS AllowEdit,
	--			NULL AS NewValue

		
		END
		--------------------------------------------- Ratings Process End ---------------------------------------------

	END
	----------------- END is_budget_exclude condition-------------------- YS 20211209
	
------------------------------------------------------- JOB ARCHITECTURE Process START------------------------------------------------------- -- YS 20240627
	IF @PlanId = @id_plan_job_architecture -- YS 20240627
	BEGIN

INSERT into zz_temp_jm (temp_datetime, temp_value) values (getdate(), 'input value ' + @inputValue)
		
		IF @id_field = @id_field_ja_poc5_new_job_family
		BEGIN

			DECLARE @job_family_description NVARCHAR(200) = 'Job Family changed. Description will be updated after saving changes.'

			--SELECT 
			--	@job_family_description = JobFamilyDescription -- too long for the max 200 characters :(
			--FROM _tb_ja_JobFamily
			--WHERE JobFamilyCode = @inputValue
		
			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				ISNULL(@job_family_description, 'Description not available') AS NewValue

			--UNION ALL -- JM 20250913 commented

			--IF NOT EXISTS ( -- JM 20250913 added
			--		SELECT *
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee
			--		JOIN _tb_ja_employee_job_title_lookup_exception AS ex
			--			ON ex.GPID = jap.gpid
			--		WHERE
			--			pps.id_step = @idStep)
			--BEGIN
			--	INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			--	SELECT
			--		@idStep AS PrimaryKey, 
			--		CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--		'' AS ObjectAttribute,
			--		1 AS IsValid,
			--		'' AS InvalidReason,
			--		1 AS AllowEdit,
			--		NULL AS NewValue
			--END

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NULL AS NewValue

		END

		IF @id_field = @id_field_ja_poc5_new_job_sub_family
		BEGIN

			DECLARE 
				@job_sub_family_description NVARCHAR(200)  = 'Job Sub Family changed. Description will be updated after saving changes.',
				@job_title_code VARCHAR(50), 
				@job_title_name NVARCHAR(256),
				@GPID NVARCHAR(50)

			-- get new job title

			SELECT TOP 1
				@job_title_code = 
					CASE	
						WHEN jt.JobTitleCode IS NULL THEN 'Not Found' 
						WHEN ex.id IS NOT NULL THEN 'Exception' 
						ELSE jt.JobTitleCode 
					END,
				@job_title_name = jt.JobTitleName,
				@GPID = jap.gpid
			FROM k_m_plans_payees_steps AS pps
			JOIN _tb_ja_process AS jap
				ON jap.idPayee = pps.id_payee
			LEFT JOIN _tb_ja_JobTitle AS jt
				ON jt.JobSubFamilyCode = @inputValue
				AND jt.LevelCode = jap.LevelCode
			LEFT JOIN _tb_ja_employee_job_title_lookup_exception AS ex
				ON ex.GPID = jap.gpid
			WHERE
				pps.id_step = @idStep

			-- add rows to temp table

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				ISNULL(@job_sub_family_description, 'Description not available') AS NewValue
	
			UNION ALL

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@job_title_name AS NewValue
			WHERE 
				@GPID NOT IN (SELECT GPID FROM _tb_ja_employee_job_title_lookup_exception)

			UNION ALL

			SELECT
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@job_title_code AS NewValue
			--WHERE 
			--	@job_title_code <> 'Exception'

--			IF @job_title_code IS NOT NULL
--			BEGIN

--INSERT into zz_temp_jm (temp_datetime, temp_value) values (getdate(), 'job title code ' + @job_title_code)

--				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

--				SELECT
--					@idStep AS PrimaryKey, 
--					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
--					'' AS ObjectAttribute,
--					1 AS IsValid,
--					'' AS InvalidReason,
--					1 AS AllowEdit,
--					@job_title_code AS NewValue
--			END

			--SELECT 
			--	@job_sub_family_description = JobSubFamilyDescription -- too long for the max 200 characters :(
			--FROM _tb_ja_JobSubFamily
			--WHERE JobSubFamilyCode = @inputValue
		
			--DECLARE @job_title_name NVARCHAR(256)

			--; WITH cte_ja_job_title AS (

			--	SELECT 
			--		NewValue,
			--		ROW_NUMBER() OVER (ORDER BY sort_order) AS rn
			--	FROM (
			--		SELECT 
			--			jt.JobTitleName AS NewValue,
			--			2 AS sort_order
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee
			--		JOIN _tb_ja_title_level AS tl
			--			ON tl.LevelCode = jap.LevelCode
			--		JOIN _tb_ja_JobTitle AS jt
			--			ON jt.JobSubFamilyCode = @inputValue
			--			AND jt.titleCode = tl.titleCode
			--		WHERE
			--			pps.id_step = @idStep
			--			--pay.current_JobSubFamilyCode IS NOT NULL

			--		UNION ALL -- YS 20240806_2
		
			--		SELECT 
			--			jt.JobTitleName AS NewValue,
			--			1 as sort_order
			--		FROM k_m_plans_payees_steps AS pps
			--		JOIN _tb_ja_process AS jap
			--			ON jap.idPayee = pps.id_payee		
			--		JOIN @Values AS kmv 
			--			ON kmv.idField = @id_field_ja_poc5_new_job_family
			--		JOIN _tb_ja_title_level_jobfunction AS tlj
			--			ON tlj.LevelCode = jap.levelCode
			--			AND tlj.JobFunctionCode_nk = kmv.inputValue -- even though JobFunctionCode_nk, this is the job family
			--		JOIN _tb_ja_JobTitle AS jt
			--			ON jt.JobSubFamilyCode = @inputValue
			--			AND jt.titleCode = tlj.titleCode
			--		WHERE
			--			pps.id_step = @idStep

			--		UNION ALL -- YS 20240806_2
		
			--		SELECT 
			--			NULL AS NewValue,
			--			3 as sort_order
			--	) AS s
			--)

			--INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_description AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	@job_sub_family_description AS NewValue

			--UNION ALL

			--SELECT TOP 1
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
			--	NewValue
			--FROM cte_ja_job_title
			--WHERE
			--	rn = 1

			--UNION ALL

			--SELECT
			--	@idStep AS PrimaryKey, 
			--	CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
			--	'' AS ObjectAttribute,
			--	1 AS IsValid,
			--	'' AS InvalidReason,
			--	1 AS AllowEdit,
				--NULL AS NewValue

		END


--		DECLARE
--			@job_sub_family_code NVARCHAR(256),
--			@title_code NVARCHAR(256),
--			@job_sub_family_name NVARCHAR(256),
--			@title_name NVARCHAR(256),
--			@job_title_name NVARCHAR(256),
--			@job_sub_family_name_2 NVARCHAR(256), -- YS 20240806
--			@job_title_code_2 NVARCHAR(256) -- YS 20240806

--		SELECT
--			@job_sub_family_code =			NULLIF(p_kmv.ja_poc5_new_job_sub_family,''), -- YS 20240627
--			@title_code =					NULLIF(p_kmv.ja_poc5_new_title,''), -- YS 20240627
--			@job_sub_family_name =			NULLIF(jsf.jobSubFamilyName,''), -- YS 20240627
--			@title_name =					NULLIF(t.titleName,''), -- YS 20240627
--			@job_title_code_2 =				NULLIF(p_kmv.ja_poc5_new_job_title_2,''), -- YS 20240806
--			@job_sub_family_name_2 =		NULLIF(jsf_2.JobSubFamilyName,'') -- YS 20240806
			
--		FROM   
--		(
--			SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
--			FROM @Values AS kmv
--			JOIN k_m_fields as kmf on kmf.id_field = kmv.idField
--			WHERE kmf.code_field  IN (
--				--'ja_poc5_new_job_title', 'ja_poc5_new_title', 'ja_poc5_new_job_sub_family')
--				'ja_poc5_new_job_title', 'ja_poc5_new_title', 'ja_poc5_new_job_sub_family', 'ja_poc5_new_job_title_2') -- YS 20240806
--		) AS s
--		PIVOT
--		(
--			MAX(inputValue)
--			FOR s.code_field  IN (
--				--ja_poc5_new_job_title, ja_poc5_new_title, ja_poc5_new_job_sub_family)
--				ja_poc5_new_job_title, ja_poc5_new_title, ja_poc5_new_job_sub_family,ja_poc5_new_job_title_2) -- YS 20240806
--		) AS p_kmv
--		LEFT JOIN _tb_ja_JobSubFamily AS jsf
--			ON jsf.JobSubFamilyCode = p_kmv.ja_poc5_new_job_sub_family
--		LEFT JOIN _tb_ja_title AS t
--			ON t.titleCode = p_kmv.ja_poc5_new_title
--		LEFT JOIN _tb_ja_JobTitle AS jt_2 -- YS 20240806
--			ON jt_2.JobTitleCode = p_kmv.ja_poc5_new_job_title_2
--		LEFT JOIN _tb_ja_JobSubFamily AS jsf_2 -- YS 20240806
--			ON jsf_2.JobSubFamilyCode = jt_2.JobSubFamilyCode


--		--SELECT @job_title_name = CONCAT(@job_sub_family_name + ' ', @title_name) -- YS 20240712

--		SELECT @job_title_name = JobTitleName
--		FROM _tb_ja_JobTitle
--		WHERE titleCode = @title_code
--		and JobSubFamilyCode = @job_sub_family_code

----select @job_sub_family_code, @job_sub_family_name, @title_code, @title_name, @job_title_name
--		----------------------------------------------- Title Field START -------------------------------------------------

--		IF @id_field = @id_field_ja_poc5_new_title
--		BEGIN
		
--			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
--			SELECT
--				@idStep AS PrimaryKey, 
--				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_title AS NVARCHAR(30))) AS ObjectFieldAlias,
--				'' AS ObjectAttribute,
--				1 AS IsValid,
--				'' AS InvalidReason,
--				1 AS AllowEdit,
--				@job_title_name AS NewValue

--		END
--		----------------------------------------------- Title Field END -------------------------------------------------
--		----------------------------------------------- JobTitle_2 Field START ------------------------------------------------- -- YS 20240806

--		IF @id_field = @id_field_ja_poc5_new_job_title_2
--		BEGIN
		
--			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
--			SELECT
--				@idStep AS PrimaryKey, 
--				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ja_poc5 AS NVARCHAR(30)), '_', CAST(@id_field_ja_poc5_new_job_sub_family_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
--				'' AS ObjectAttribute,
--				1 AS IsValid,
--				'' AS InvalidReason,
--				1 AS AllowEdit,
--				@job_sub_family_name_2 AS NewValue

--		END
		----------------------------------------------- JobTitle_2 Field END ------------------------------------------------- -- YS 20240806

		
	END
------------------------------------------------------- JOB ARCHITECTURE Process END------------------------------------------------------- -- YS 20240627
------------------------------------------------------- BONUS Process START------------------------------------------------------- --YS 20250724

	IF @PlanId = @id_plan_bonus  --YS 20250724
	BEGIN
		DECLARE 
			@preassigned_bonus nvarchar(max)
		,	@is_correct nvarchar(50)
		,	@bonus_team_correction_reason nvarchar(255)
		,	@bonus_team_enabling nvarchar(255)
		,	@step_1 nvarchar(255)
		,	@step_2 nvarchar(255)
		,	@step_3 nvarchar(255)
		,	@step_35 nvarchar(255)
		,	@step_4 nvarchar(255)
		,	@step_5 nvarchar(255)
		,	@step_1_name nvarchar(255)
		,	@step_2_name nvarchar(255)
		,	@step_3_name nvarchar(255)
		,	@step_4_name nvarchar(255)
		,	@step_5_name nvarchar(255)
		,	@bonus_team_final nvarchar(255)
		,	@double_hatter nvarchar(255)
		,	@prt_message nvarchar(255)
		,	@comment nvarchar(255)
		,	@idCompGroup INT
		,	@is_double_hat bit	

		SELECT
			@is_correct =					NULLIF(p_kmv.bonus_team_assignment_correct,''),
			@bonus_team_correction_reason =	NULLIF(p_kmv.bonus_team_correction_reason,''),
			@bonus_team_enabling =			NULLIF(p_kmv.bonus_team_enabling,''),
			@step_1 =						NULLIF(p_kmv.bonus_team_step_1,''),
			@step_2 =						NULLIF(p_kmv.bonus_team_step_2,''),
			@step_3 =						NULLIF(p_kmv.bonus_team_step_3,''),
			@step_35 =						NULLIF(p_kmv.bonus_team_step_35,''),
			@step_4 =						NULLIF(p_kmv.bonus_team_step_4,''),
			@step_5 =						NULLIF(p_kmv.bonus_team_step_5,''),
			@double_hatter =				NULLIF(p_kmv.bonus_team_double_hatter,''),
			@prt_message =					NULLIF(p_kmv.bonus_team_prt_message,''),
			@comment =						NULLIF(p_kmv.bonus_team_comment,'')
		from (
				SELECT @idStep AS idStep, kmv.inputValue, kmf.code_field
				FROM @Values AS kmv
				JOIN k_m_fields as kmf on kmf.id_field = kmv.idField -- select * from k_m_fields
				WHERE kmf.code_field  IN (
					'bonus_team_assignment_correct','bonus_team_correction_reason','bonus_team_enabling',
					'bonus_team_step_1','bonus_team_step_2','bonus_team_step_3','bonus_team_step_35','bonus_team_step_4','bonus_team_step_5',
					'bonus_team_double_hatter','bonus_team_prt_message','bonus_team_comment'
					)
				) AS s
			PIVOT
			(
				MAX(inputValue)
				FOR s.code_field  IN (
					bonus_team_preassigned,bonus_team_assignment_correct,bonus_team_correction_reason,bonus_team_enabling,
					bonus_team_step_1,bonus_team_step_2,bonus_team_step_3,bonus_team_step_35,bonus_team_step_4,bonus_team_step_5,
					bonus_team_double_hatter,bonus_team_prt_message,bonus_team_comment
				)
					
			) AS p_kmv

		-- Get Preassigned Bonus Team from process grid info field
		SELECT @preassigned_bonus =	BonusTeamNameProcess,	--BonusTeamName,	--PK 20251217
			@idCompGroup = idCompGroup,
			@is_double_hat = cast(isnull(pba.IsDoubleHat, 0) as bit)
		from k_m_plans_payees_steps as pps
		JOIN PEPSICO_Process_BonusApproval as pba
			on pps.id_payee = pba.idPayee
			and pps.start_step = pba.start_date_histo
		where pps.id_step = @idStep





--SELECT @preassigned_bonus as preassigned_bonus,@is_correct as is_correct,@bonus_team_correction_reason as bonus_team_correction_reason ,@bonus_team_enabling as bonus_team_enabling ,@step_1 as step_1 ,@step_2 as step_2 ,@step_3 as step_3 ,@step_35 as step_35 ,@step_4 as step_4 ,@step_5 as step_5,@double_hatter as double_hatter ,@prt_message as prt_message,@comment as comment
		-- If Enable is the trigger, nothing to set
		IF @id_field = @id_field_bonus_team_assignment_correct --YS 20250818
		BEGIN
			IF @inputValue IN ('CORRECT', 'SELECT','INCORRECT_DATA')
			BEGIN

				SET @step_1 = NULL
				SET @step_2 = NULL
				SET @step_3 = NULL -- 20261103: Reset all Business selections on validation reset.
				SET @comment = NULL

				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_1 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_1 AS NewValue
				UNION ALL
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_2 AS NewValue
				UNION ALL
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_3 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@step_3 AS NewValue
			IF @inputValue IN ('CORRECT', 'SELECT')
			BEGIN
				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
				SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_comment AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					1 AS IsValid,
					'' AS InvalidReason,
					0 AS AllowEdit,
					@comment AS NewValue
			END

			END

			--SET prt_message depending on assignment_correct_code --YS 20250818
			SELECT @prt_message = ISNULL(prt_message,'')
			FROM PEPSICO_bonus_team_assignment_correct
			WHERE assignment_correct_code = @is_correct
			AND manually_configured_bonus_team = @is_double_hat

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
			SELECT 
				@idStep AS PrimaryKey, 
				CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_prt_message AS NVARCHAR(30))) AS ObjectFieldAlias,
				'' AS ObjectAttribute,
				1 AS IsValid,
				'' AS InvalidReason,
				1 AS AllowEdit,
				@prt_message AS NewValue

		END

		
		-- 20261023: Clear dependent Business selections before recalculating Bonus Team.
		IF @id_field IN (@id_field_bonus_team_step_1, @id_field_bonus_team_step_2)
		BEGIN
			IF @id_field = @id_field_bonus_team_step_1
			BEGIN
				SET @step_2 = NULL;

				INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
				SELECT @idStep,
					CONCAT(@PlanId, '_', @id_ind_bonus_team, '_', @id_field_bonus_team_step_2),
					'', 1, '', 1, NULL;
			END;

			SET @step_3 = NULL;

			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT @idStep,
				CONCAT(@PlanId, '_', @id_ind_bonus_team, '_', @id_field_bonus_team_step_3),
				'', 1, '', 1, NULL;
		END;
		
		---- If Step 2 is the trigger, nothing to set
		IF @id_field = @id_field_bonus_team_step_2 --YS 20250821
		BEGIN
			
			INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)
			SELECT 
					@idStep AS PrimaryKey, 
					CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_step_2 AS NVARCHAR(30))) AS ObjectFieldAlias,
					'' AS ObjectAttribute,
					0 AS IsValid,
					'Employees should only be assigned a combined bonus team when their role consistently and significantly supports multiple parts of the business. HRBPs will review bonus team changes.' AS InvalidReason,
					0 AS AllowEdit,
					@inputValue AS NewValue
		END

		---- Get Bonus Parameter names from lookup views
		select @step_1_name = BTBusinessValue from PEPSICO_Bonus_Team_Business where BTBusinessCode = @step_1
		select @step_2_name = BTBusinessValue from PEPSICO_Bonus_Team_Business where BTBusinessCode = @step_2
		select @step_3_name = BTBusinessValue from PEPSICO_Bonus_Team_Business where BTBusinessCode = @step_3 ----TK 20261008

		---- Set Bonus team Name based on parameters
		--SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team_ys(@idCompGroup ,@step_1_name,@step_2_name), @preassigned_bonus) ----YS 20250821
		--SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team(@idCompGroup ,@step_1_name,@step_2_name), @preassigned_bonus) ----YS 20250826
		SELECT @bonus_team_final = ISNULL(dbo._fn_get_bonus_team(dbo._ufn_get_comp_round_extended(@idStep,@idCompGroup),@step_1_name,@step_2_name,@step_3_name), @preassigned_bonus) ----TK 20261008

		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
		SELECT 
			@idStep AS PrimaryKey, 
			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_bonus_team AS NVARCHAR(30)), '_', CAST(@id_field_bonus_team_final AS NVARCHAR(30))) AS ObjectFieldAlias,
			'' AS ObjectAttribute,
			1 AS IsValid,
			'' AS InvalidReason,
			1 AS AllowEdit,
			@bonus_team_final AS NewValue

	END

------------------------------------------------------- BONUS Process END------------------------------------------------------- --YS 20250724
	---------------------------- Return the entered value if it is not already in the returned table --YS 20210901

	IF NOT EXISTS (SELECT * FROM #tempTable WHERE ObjectFieldAlias = CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))))
	BEGIN
		INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	
		SELECT 
			@idStep AS PrimaryKey, 
			CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))) AS ObjectFieldAlias,
			'' AS ObjectAttribute,
			1 AS IsValid,
			'' AS InvalidReason,
			1 AS AllowEdit,
			@inputValue AS NewValue
	END

	-- YS 20211122 FIX: Return ic_score = NULL for inelligible payees instead of 0
	--IF (SELECT is_sc_eligible FROM PEPSICO_Process_FocalPoint WHERE gpid = @codePayee) = 0 --YS 20211201
	IF (SELECT is_sc_eligible FROM PEPSICO_Process_FocalPoint WHERE codePayee = @codePayee) = 0
	BEGIN
		UPDATE #tempTable
		SET NewValue = NULL
		WHERE ObjectFieldAlias = CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind_ic_score AS NVARCHAR(30)), '_', CAST(@id_field_ic_score AS NVARCHAR(30)))
	END

------------------------------- this is for testing START

	--IF NOT EXISTS (SELECT * FROM #tempTable)
	--BEGIN
	--	INSERT INTO #tempTable (PrimaryKey, ObjectFieldAlias, ObjectAttribute, IsValid, InvalidReason, AllowEdit, NewValue)	

	--	SELECT 
	--		@idStep AS PrimaryKey, 
	--		CONCAT(CAST(@PlanId AS NVARCHAR(30)), '_', CAST(@id_ind AS NVARCHAR(30)), '_', CAST(@id_field AS NVARCHAR(30))) AS ObjectFieldAlias,
	--		'' AS ObjectAttribute,
	--		1 AS IsValid,
	--		'' AS InvalidReason,
	--		1 AS AllowEdit,
	--		@inputValue AS NewValue
	--END

------------------------------- this is for testing END

---- for debugging	
--insert into zz_temp_jm_tempTable -- select top 1000* from zz_temp_jm_tempTable order by insertdatetime desc
--select *, getdate() from #tempTable


----- DEBUG PAY COMPONENT

--INSERT INTO zz_temp_PayComponentInrcease(FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, Increasepercent, proposedAmount)
--SELECT FiscalYear, GPID, PayComponentCode_nk, MeritIncreaseTypeCode_nk, Amount, Increasepercent, proposedAmount
--FROM @RTCPayComponent


	-- return the results

	SELECT * FROM #tempTable

END
GO

-- SECTION 26: Verify the deployed full OnChange definition
PRINT N'Verify the deployed full OnChange definition';
GO

IF CHARINDEX(N'dbo._ufn_get_comp_round_extended(@idStep,@idCompGroup)',
    OBJECT_DEFINITION(OBJECT_ID(N'dbo.Kernel_SP_Process_DataOnChange'))) = 0
    THROW 51043, 'OnChange does not use the Comp Round Extended lookup.', 1;
GO

-- SECTION 27: Initial Division exception-cache refresh; no scheduler is added
PRINT N'Initial Division exception-cache refresh; no scheduler is added';
GO

EXEC dbo.SP_RefreshEmployeeCompRoundException;
GO

-- SECTION 28: Validate final schema and allocation selector uniqueness
PRINT N'Validate final schema and allocation selector uniqueness';
GO

IF COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'id_comp_group') IS NOT NULL
    OR COL_LENGTH(N'dbo.PEPSICO_bonus_team_allocation_rule', N'comp_round_extended') IS NULL
    THROW 51402, 'Allocation schema upgrade was not completed.', 1;
IF ISNULL(COLUMNPROPERTY(OBJECT_ID(N'dbo.PEPSICO_bonus_team_allocation_rule'), N'id', 'IsIdentity'), 0) <> 1
    THROW 51403, 'Allocation identity key was not installed.', 1;
IF EXISTS
(
    SELECT comp_round_extended, number_of_businesses, is_region
    FROM dbo.PEPSICO_bonus_team_allocation_rule
    WHERE corporate_override = 0
      AND comp_round_extended IN (N'Global S&T', N'Global R&D', N'Global Procurement',
          N'Corporate GGF', N'EMEA Foods', N'APAC Foods', N'LATAM', N'International Beverages', N'North America')
    GROUP BY comp_round_extended, number_of_businesses, is_region
    HAVING COUNT(*) > 1
) OR EXISTS
(
    SELECT comp_round_extended, number_of_businesses
    FROM dbo.PEPSICO_bonus_team_allocation_rule
    WHERE corporate_override = 1
    GROUP BY comp_round_extended, number_of_businesses
    HAVING COUNT(*) > 1
)
    THROW 51404, 'Ambiguous allocation rules remain; stop and review the allocation section.', 1;
GO
PRINT N'PASS: all Bonus Team deployment sections completed.';
GO

-- SHA256 6868a211689cc81181d93b89bb8209d1fa31d7d277f570e482ba6a0f3db1336c  Objects/Tables/dbo.PEPSICO_bonus_team_business_mapping.sql
-- SHA256 b8497faf2dd67ffb3443daffa014066b83f94c9354285e4c209d7f61417cd295  Objects/Tables/dbo.PEPSICO_bonus_team_allocation_rule.sql
-- SHA256 49ac7fe5eb3614e16707fd174bcbfb9661d18e5387a4f63fef5b69e8def42743  Objects/Tables/dbo.PEPSICO_CompRoundExtendedRule.sql
-- SHA256 4a914fedfcf60960de0cb14ed0835776c03caeb7d29f2544a3e29ef62c487567  Objects/Tables/dbo.PEPSICO_EmployeeCompRoundException.sql
-- SHA256 55827bf8b6beb0bf81d6601beda67093aba30d4664a596d82c77ed787181c32a  Objects/Functions/dbo._ufn_get_comp_round_extended.sql
-- SHA256 6f8d06f49d22102a712efa4d0937c08bf29689ab4ad0d63103d5a60b0f726e17  Objects/Functions/dbo._fn_get_bonus_team.sql
-- SHA256 7b53cf7f4254688424490c28b193f86ada3140deea3eeceb541603ccbad5583a  Objects/Functions/dbo._ufn_get_employee_bonus_team.sql
-- SHA256 2eb12eeb223d2786b3dd071f1bf250e130258c8a694679ce24e4246f035f19eb  Objects/Stored Procedures/dbo.SP_RefreshEmployeeCompRoundException.sql
-- SHA256 c66fd1b8adeea2845d2fdda8a9702dec94012235060a6670f7d396bbc1fa74f0  Objects/Views/dbo.vPEPSICO_bonus_team_step1_business.sql
-- SHA256 8b16507bc9395e408b0a11a9d43729e330d954801d69f365f70d8d0351bf7f8c  Objects/Views/dbo.vPEPSICO_bonus_team_step2_business.sql
-- SHA256 44a61d2df2fa3b0a4d95e7c03b9e0366589a00685f88b7248806fc7a42673e15  Objects/Views/dbo.vPEPSICO_bonus_team_step3_business.sql
-- SHA256 b0d761096a66369f53359f985ed415a57d2036afb739f71ee58512ed38dcb93a  Scripts/PostDeploy/30_Wrappers/Process/Bonus.sql
-- SHA256 1e759e5c9414911758eb4aaf972dd504a856f4db545104ee3c3eb35b3c3057df  Scripts/PostDeploy/40_Config/add_step_3_to_bonus_process.sql
-- SHA256 db2483fb53e5f989c703501db60cb9f52597d57b356ff9f8aee953ccf0fa7157  Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_step3_validation.sql
-- SHA256 e261d2f0d7fccd5c3aa88a97bbd1bbe81d6b4b2dd7e42c8c915904b4a644173b  Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_00_comp_round_extended_rules.sql
-- SHA256 c1f0a0e848689c3c3bec8e4a2d3456a8c81089fed5e4e03d016cbdd4d9636814  Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping.sql
-- SHA256 98931d99fc2306641b949704d33469c8e908dfbcc7dfe95a21556e80678500bf  Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_business_mapping_cleanup.sql
-- SHA256 410d832875f0530d9df23aad5103ec4af2cd94e972437f8be7bc21e5c260ec82  Scripts/PostDeploy/90_PostDeploy/deploy_bonus_team_allocation_rule.sql
-- SHA256 c3cd0e8ec20690ecaf856a2225da2e0b6c0ee5c7830af739c499db7f05278318  AI/beqom_sync_objects/Stored Procedures/Kernel_SP_Process_DataOnChange.sql
