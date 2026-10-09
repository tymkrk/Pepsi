CREATE TABLE [dbo].[PEPSICO_bonus_team_allocation_rule](
	[id_comp_group] [int] NOT NULL,
	[number_of_businesses] [int] NOT NULL,
	[split_rule] [nvarchar](200) NOT NULL,
	[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_bonus_team_allocation_rule_is_region] DEFAULT ((0)),
 CONSTRAINT [PK_PEPSICO_bonus_team_allocation_rule] PRIMARY KEY CLUSTERED
(
	[id_comp_group] ASC,
	[number_of_businesses] ASC,
	[split_rule] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEPSICO_bonus_team_allocation_rule] WITH CHECK ADD CONSTRAINT [CK_PEPSICO_bonus_team_allocation_rule_number_of_businesses] CHECK (([number_of_businesses] BETWEEN (1) AND (3)))
GO
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
GO
ALTER TABLE [dbo].[PEPSICO_bonus_team_business_mapping] ADD CONSTRAINT [DF_PEPSICO_bonus_team_business_mapping_is_region] DEFAULT ((0)) FOR [is_region]
GO
