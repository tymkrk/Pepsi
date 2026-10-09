
declare 
@id_global_st int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'Global S&T')
--@id_global_rd int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'Global R&D')
--@id_global_proc int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'Global Procurement')
,@id_EMEA	int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'EMEA Foods')
,@id_APAC	int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'APAC Foods')
,@id_LATAM	int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'LATAM')
,@id_IB		int = (select top 1 idCompGroup from PEPSICO_CompGroup where CompGroupName = 'International Beverages')
--1.
select dbo._fn_get_bonus_team_tk(@id_global_st, 'UKI',null,null) -- UKI 75% / Corporate 25%
--2.
select dbo._fn_get_bonus_team_tk(@id_EMEA		,'UKI',	'Western Europe',null)
select dbo._fn_get_bonus_team_tk(@id_APAC		,'ANZ Foods',	'IndoChina Foods',null)
select dbo._fn_get_bonus_team_tk(@id_LATAM		,'PMF',	'PBF',null)
select dbo._fn_get_bonus_team_tk(@id_IB			,'LATAM FOBO',	'Europe FOBO',null)
select dbo._fn_get_bonus_team_tk(@id_global_st	,'Poland','SEEB',null)
select dbo._fn_get_bonus_team_tk(@id_global_st	,'PMF','PBF',null)
select dbo._fn_get_bonus_team_tk(@id_global_st	,'EMEA Region','APAC Foods Region',null)
--3.
select dbo._fn_get_bonus_team_tk(@id_EMEA		,'UKI','Western Europe','Turkey')
select dbo._fn_get_bonus_team_tk(@id_EMEA		,'Poland','SEEB','East Balkans')
select dbo._fn_get_bonus_team_tk(@id_EMEA		,'France','Iberia','GroW')
select dbo._fn_get_bonus_team_tk(@id_EMEA		,'Egypt Foods & COBO','Middle East Foods','Pakistan Foods')
select dbo._fn_get_bonus_team_tk(@id_APAC		,'ANZ Foods','IndoChina Foods','Be & Cheery')
select dbo._fn_get_bonus_team_tk(@id_LATAM		,'PMF','PBF','Andean')
select dbo._fn_get_bonus_team_tk(@id_IB			,'LATAM FOBO','Europe FOBO','Asia')
select dbo._fn_get_bonus_team_tk(@id_global_st	,'Poland','SEEB','East Balkans')
select dbo._fn_get_bonus_team_tk(@id_global_st	,'PMF','PBF','Andean')
select dbo._fn_get_bonus_team_tk(@id_global_st	,'EMEA Region','APAC Foods Region','LATAM Foods Region')


