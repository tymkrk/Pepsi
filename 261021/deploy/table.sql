CREATE TABLE [dbo].[PEPSICO_bonus_team_allocation_rule](
	[id_comp_group] [int] NOT NULL,
	[number_of_businesses] [int] NOT NULL,
	[split_rule] [nvarchar](200) NOT NULL,
	[is_region] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_bonus_team_allocation_rule_is_region] DEFAULT ((0)),
	[corporate_override] [bit] NOT NULL CONSTRAINT [DF_PEPSICO_bonus_team_allocation_rule_corporate_override] DEFAULT ((0)),
 CONSTRAINT [PK_PEPSICO_bonus_team_allocation_rule] PRIMARY KEY CLUSTERED
(
	[id_comp_group] ASC,
	[number_of_businesses] ASC,
	[is_region] ASC,
	[split_rule] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PEPSICO_bonus_team_allocation_rule] WITH CHECK ADD CONSTRAINT [CK_PEPSICO_bonus_team_allocation_rule_number_of_businesses] CHECK (([number_of_businesses] BETWEEN (1) AND (3)))
GO
