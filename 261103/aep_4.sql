<?xml version="1.0" encoding="utf-16"?>
<ShowPlanXML xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" Version="1.613" Build="18.0.319.205" xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan">
  <BatchSequence>
    <Batch>
      <Statements>
        <StmtSimple StatementCompId="1" StatementEstRows="1" StatementId="1" QueryCompilationReplay="1" StatementOptmLevel="FULL" StatementOptmEarlyAbortReason="TimeOut" CardinalityEstimationModelVersion="160" StatementSubTreeCost="801.068" StatementText="select * from vPEPSICO_send_mail_notification_bonus_v4" StatementType="SELECT" QueryHash="0x1DC26478F98F1A59" QueryPlanHash="0x020224AA6076A3BF" RetrievedFromCache="true" StatementSqlHandle="0x0900D5C2BF7949B6244622990891CE6490500000000000000000000000000000000000000000000000000000" DatabaseContextSettingsId="8" ParentObjectId="0" StatementParameterizationType="0" SecurityPolicyApplied="false" BatchModeOnRowStoreUsed="true">
          <StatementSetOptions ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" ARITHABORT="true" CONCAT_NULL_YIELDS_NULL="true" NUMERIC_ROUNDABORT="false" QUOTED_IDENTIFIER="true" />
          <QueryPlan DegreeOfParallelism="0" NonParallelPlanReason="TSQLUserDefinedFunctionsNotParallelizable" MemoryGrant="2174208" CachedPlanSize="1176" CompileTime="3789" CompileCPU="3789" CompileMemory="74872">
            <Warnings>
              <PlanAffectingConvert ConvertIssue="Cardinality Estimate" Expression="CONVERT_IMPLICIT(int,STRING_SPLIT.[value],0)" />
              <PlanAffectingConvert ConvertIssue="Cardinality Estimate" Expression="CONVERT_IMPLICIT(int,STRING_SPLIT.[value],0)" />
              <PlanAffectingConvert ConvertIssue="Cardinality Estimate" Expression="CONVERT_IMPLICIT(int,[u].[id_external_user],0)" />
            </Warnings>
            <MemoryGrantInfo SerialRequiredMemory="13376" SerialDesiredMemory="2174208" RequiredMemory="13376" DesiredMemory="2174208" RequestedMemory="2174208" GrantWaitTime="0" GrantedMemory="2174208" MaxUsedMemory="156088" MaxQueryMemory="16750928" LastRequestedMemory="0" IsMemoryGrantFeedbackAdjusted="No: First Execution" />
            <OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="544256" EstimatedPagesCached="680320" EstimatedAvailableDegreeOfParallelism="8" MaxCompileMemory="74025328" />
            <OptimizerStatsUsage>
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[nci_wi_hm_NodelinkPublished_EEE77BB266B1AC930775A2597DB8ED3C]" ModificationCount="3777" SamplingPercent="8.54219" LastUpdate="2026-10-31T19:18:50.27" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[nc_MailQueue]" Statistics="[IX__nc_MailQueue__mailSubject_createDate]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-11-03T13:25:38.2" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Statistics="[PK_PEPSICO_FocalPoint_EmpCurrentPayee]" ModificationCount="0" SamplingPercent="2.76884" LastUpdate="2026-11-03T08:10:24.97" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Statistics="[nci_wi_PEPSICO_FocalPoint_EmpCurrentPayee_7EDAA04ED81147DA03A3E8098B0E3ACE]" ModificationCount="0" SamplingPercent="2.95632" LastUpdate="2026-11-03T08:34:48.67" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Parameters]" Statistics="[_WA_Sys_00000003_5E00C4E5]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-02-24T04:03:40.98" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[_WA_Sys_00000017_3E28F230]" ModificationCount="1647" SamplingPercent="18.7102" LastUpdate="2026-10-31T18:47:52.09" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grids]" Statistics="[_WA_Sys_00000002_22751F6C]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:36:21.76" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users_profiles]" Statistics="[IX_k_users_profiles_id_user_id_profile]" ModificationCount="272" SamplingPercent="100" LastUpdate="2026-10-27T12:46:01.5" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[IX_k_m_values_idSim_idOrg]" ModificationCount="343" SamplingPercent="1.867" LastUpdate="2026-11-03T09:09:59.12" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[_WA_Sys_00000003_2610A626]" ModificationCount="3777" SamplingPercent="8.29029" LastUpdate="2026-10-31T19:18:49.52" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Statistics="[_WA_Sys_00000002_4F9D96F5]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-19T12:40:29.2" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[_WA_Sys_00000006_2610A626]" ModificationCount="7600" SamplingPercent="8.54219" LastUpdate="2026-10-31T19:18:50.21" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[IX_k_users_login_user]" ModificationCount="5472" SamplingPercent="36.8482" LastUpdate="2026-11-01T19:35:06.75" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[_WA_Sys_00000015_3E28F230]" ModificationCount="1647" SamplingPercent="18.7102" LastUpdate="2026-10-31T18:09:05.83" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_fields]" Statistics="[_WA_Sys_00000004_25DB9BFC]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-19T12:34:47.37" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[IX_k_m_plans_payees_steps_idPayee]" ModificationCount="775" SamplingPercent="100" LastUpdate="2026-11-01T00:25:06.69" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grids]" Statistics="[_WA_Sys_00000003_22751F6C]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:36:21.77" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_00000008_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.56" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Parameters]" Statistics="[_WA_Sys_00000006_5E00C4E5]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-02-24T04:03:41.01" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[nc_MailQueue]" Statistics="[_WA_Sys_00000004_3E3D3572]" ModificationCount="64" SamplingPercent="19.4479" LastUpdate="2026-10-27T12:40:56.95" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_tables_views]" Statistics="[PK_k_referential_tables_views]" ModificationCount="3" SamplingPercent="100" LastUpdate="2026-10-27T12:35:36.94" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[nci_k_users_activesuer]" ModificationCount="892" SamplingPercent="36.825" LastUpdate="2026-11-03T08:00:47.48" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grids]" Statistics="[PK_k_referential_grids_1]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-27T12:36:21.71" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_00000006_5EAA0504]" ModificationCount="351" SamplingPercent="1.867" LastUpdate="2026-11-03T09:14:38.47" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[nci_k_m_values_idfield]" ModificationCount="343" SamplingPercent="1.867" LastUpdate="2026-11-03T09:09:59.64" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_00000002_5EAA0504]" ModificationCount="343" SamplingPercent="1.70619" LastUpdate="2026-11-03T09:09:58.92" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[_WA_Sys_00000006_607251E5]" ModificationCount="2633" SamplingPercent="11.3681" LastUpdate="2026-10-31T16:54:04.71" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[py_Payee]" Statistics="[PK_k_collaborateurs]" ModificationCount="1504" SamplingPercent="4.97417" LastUpdate="2026-10-27T12:44:04.83" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[py_Payee]" Statistics="[nci_py_payee_activesuer]" ModificationCount="1673" SamplingPercent="4.9963" LastUpdate="2026-10-27T12:44:07.42" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[IX_PEPSICO_Process_FocalPoint_idPayee]" ModificationCount="369" SamplingPercent="100" LastUpdate="2026-11-01T00:14:23.38" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_0000000F_5EAA0504]" ModificationCount="343" SamplingPercent="1.6817" LastUpdate="2026-11-03T09:09:59.46" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_tables_views]" Statistics="[_WA_Sys_00000002_151B244E]" ModificationCount="5" SamplingPercent="100" LastUpdate="2026-10-27T12:35:36.97" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_00000009_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.55" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users_profiles]" Statistics="[_WA_Sys_00000003_7BE56230]" ModificationCount="287" SamplingPercent="100" LastUpdate="2026-10-27T12:46:01.48" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[IX_k_users_firstname_user_lastname_user]" ModificationCount="5476" SamplingPercent="36.8482" LastUpdate="2026-11-01T19:34:02.05" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[_WA_Sys_0000001E_3E28F230]" ModificationCount="1647" SamplingPercent="19.0057" LastUpdate="2026-10-31T18:17:53.63" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[PK_k_m_values]" ModificationCount="187" SamplingPercent="1.70619" LastUpdate="2026-11-03T09:09:59.26" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[_WA_Sys_00000007_3E28F230]" ModificationCount="1732" SamplingPercent="18.7" LastUpdate="2026-10-31T18:09:04.37" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[ix_gpid]" ModificationCount="1647" SamplingPercent="100" LastUpdate="2026-11-01T00:14:23.47" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[IX__PEPSICO_Process_BonusApproval__idPayee_start_date_histo]" ModificationCount="1038" SamplingPercent="100" LastUpdate="2026-11-01T00:23:45.24" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_00000012_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.62" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_0000000B_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.53" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[_WA_Sys_0000000A_5C786F26]" ModificationCount="9782" SamplingPercent="16.3326" LastUpdate="2026-10-30T17:01:27.16" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[nc_MailQueue]" Statistics="[PK_nc_MailQueue]" ModificationCount="30" SamplingPercent="19.4479" LastUpdate="2026-10-27T12:40:56.73" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[py_Payee]" Statistics="[nci_wi_py_Payee_5932390CCAA29A71A8CEEC12A50FAA15]" ModificationCount="1673" SamplingPercent="5.08993" LastUpdate="2026-10-27T12:44:06.4" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Statistics="[_WA_Sys_00000024_759922AB]" ModificationCount="0" SamplingPercent="2.95632" LastUpdate="2026-11-03T08:11:19.89" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_00000002_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.52" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Statistics="[UI_PEPSICO_FocalPoint_EmpCurrentPayee_GPID]" ModificationCount="0" SamplingPercent="2.76884" LastUpdate="2026-11-03T08:33:58.52" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grid_folders]" Statistics="[PK_k_referential_grid_folders]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-27T12:42:34.33" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[nc_MailQueue]" Statistics="[_WA_Sys_00000008_3E3D3572]" ModificationCount="60" SamplingPercent="19.4479" LastUpdate="2026-10-27T12:41:47.86" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[py_Payee]" Statistics="[IX_k_collaborateurs]" ModificationCount="1504" SamplingPercent="5.55862" LastUpdate="2026-10-27T12:44:05.12" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[_WA_Sys_0000000B_607251E5]" ModificationCount="2006" SamplingPercent="10.9008" LastUpdate="2026-10-31T16:54:04.76" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[NonClusteredIndex-PayeeStepIdPlan-WithDate]" ModificationCount="13077" SamplingPercent="13.4854" LastUpdate="2026-10-27T12:43:14.23" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[_WA_Sys_00000012_1C5231C2]" ModificationCount="3123" SamplingPercent="36.825" LastUpdate="2026-11-02T13:46:38.61" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[ix_hm_NodelinkPublished_idType]" ModificationCount="3777" SamplingPercent="7.32382" LastUpdate="2026-10-31T19:18:50.31" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[nci_wi_hm_NodelinkPublished_03CA99151611881E2731B285F6EB7914]" ModificationCount="3207" SamplingPercent="100" LastUpdate="2026-10-31T23:12:56.98" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_profiles]" Statistics="[_WA_Sys_00000002_7B4643B2]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-19T12:45:11.45" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[IX__PEPSICO_Process_BonusApproval__gpid_start_month_end_month]" ModificationCount="797" SamplingPercent="100" LastUpdate="2026-11-02T17:31:36.52" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_00000007_5EAA0504]" ModificationCount="351" SamplingPercent="1.76407" LastUpdate="2026-11-03T09:14:31.7" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_00000005_5EAA0504]" ModificationCount="483" SamplingPercent="1.867" LastUpdate="2026-11-03T09:14:36.89" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[_WA_Sys_00000014_5C786F26]" ModificationCount="9765" SamplingPercent="16.3326" LastUpdate="2026-10-30T14:41:15.11" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users_profiles]" Statistics="[UC_k_users_profiles_id_user_id_profile]" ModificationCount="108" SamplingPercent="100" LastUpdate="2026-11-01T02:02:12.55" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_0000000A_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.55" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[IX_startdate_enddate]" ModificationCount="1732" SamplingPercent="18.7" LastUpdate="2026-10-31T18:09:04.63" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[nci_wi_hm_NodelinkPublished_5F8B028DA52242978B1328A7FE61B227]" ModificationCount="10878" SamplingPercent="100" LastUpdate="2026-10-31T23:12:57.34" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[PK_k_m_plans_payees_steps]" ModificationCount="13077" SamplingPercent="14.5355" LastUpdate="2026-10-27T12:43:13.42" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[py_Payee]" Statistics="[_WA_Sys_00000003_6A50C1DA]" ModificationCount="1673" SamplingPercent="4.9963" LastUpdate="2026-10-27T12:44:05.52" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[IX_k_users_idExternalSSO]" ModificationCount="5480" SamplingPercent="36.8482" LastUpdate="2026-11-01T19:35:06.45" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grids]" Statistics="[_WA_Sys_00000004_22751F6C]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-27T12:36:21.81" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Statistics="[_WA_Sys_0000000F_3E28F230]" ModificationCount="1647" SamplingPercent="18.7102" LastUpdate="2026-10-31T18:17:52.74" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grids]" Statistics="[IX__k_referential_grids__id_grid_parent]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:36:22.03" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[PK_k_users]" ModificationCount="81" SamplingPercent="36.1108" LastUpdate="2026-10-27T12:35:53.55" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[IX_hm_NodelinkPublished_idTree_idType_idParent]" ModificationCount="3207" SamplingPercent="100" LastUpdate="2026-10-31T23:12:55.69" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[_WA_Sys_00000007_5C786F26]" ModificationCount="9784" SamplingPercent="16.4744" LastUpdate="2026-10-30T11:27:22.89" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[_WA_Sys_00000002_1C5231C2]" ModificationCount="5357" SamplingPercent="36.7157" LastUpdate="2026-11-01T20:20:51.98" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[UQ_k_m_values]" ModificationCount="343" SamplingPercent="1.867" LastUpdate="2026-11-03T09:09:58.68" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[IX_hm_NodelinkPublished_idChild_idTree_idType]" ModificationCount="3207" SamplingPercent="100" LastUpdate="2026-10-31T23:12:55.39" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_values]" Statistics="[_WA_Sys_00000004_5EAA0504]" ModificationCount="343" SamplingPercent="1.70619" LastUpdate="2026-11-03T09:09:58.8" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Statistics="[_WA_Sys_00000003_32AEB491]" ModificationCount="1" SamplingPercent="100" LastUpdate="2026-10-27T12:40:01.53" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_users]" Statistics="[_WA_Sys_00000004_1C5231C2]" ModificationCount="5476" SamplingPercent="40.4346" LastUpdate="2026-11-01T19:34:02.47" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[_WA_Sys_00000005_607251E5]" ModificationCount="2094" SamplingPercent="10.9008" LastUpdate="2026-10-31T16:54:04.19" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_referential_grid_folders]" Statistics="[_WA_Sys_00000003_53D770D6]" ModificationCount="0" SamplingPercent="100" LastUpdate="2026-10-27T12:42:34.37" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[PK_hm_NodelinkPublished]" ModificationCount="2693" SamplingPercent="100" LastUpdate="2026-11-01T12:58:17.05" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Statistics="[IX_hm_NodelinkPublished_idTree_idType_idRealParent]" ModificationCount="3207" SamplingPercent="100" LastUpdate="2026-10-31T23:12:56.02" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[IX_k_m_plans_payees_steps_plan_locked_start]" ModificationCount="13077" SamplingPercent="13.7363" LastUpdate="2026-10-27T12:43:15.9" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Statistics="[_WA_Sys_00000006_5C786F26]" ModificationCount="4273" SamplingPercent="16.7865" LastUpdate="2026-10-30T11:26:42.37" />
              <StatisticsInfo Database="[f7d84398-526a-43c6-ac71-ee4de648f15f]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Statistics="[IX_k_m_plans_payees_steps_id_assignment]" ModificationCount="13077" SamplingPercent="13.7363" LastUpdate="2026-10-27T12:43:14.15" />
            </OptimizerStatsUsage>
            <WaitStats>
              <Wait WaitType="RESERVED_MEMORY_ALLOCATION_EXT" WaitTimeMs="34" WaitCount="20681" />
              <Wait WaitType="MEMORY_ALLOCATION_EXT" WaitTimeMs="21" WaitCount="22714" />
              <Wait WaitType="SOS_SCHEDULER_YIELD" WaitTimeMs="5" WaitCount="1470" />
              <Wait WaitType="PREEMPTIVE_VIRTUALALLOC" WaitTimeMs="1" WaitCount="384" />
            </WaitStats>
            <QueryTimeStats CpuTime="5904" ElapsedTime="5905" />
            <RelOp AvgRowSize="240" EstimateCPU="1E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Compute Scalar" NodeId="0" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="801.068">
              <OutputList>
                <ColumnReference Column="Union1359" />
                <ColumnReference Column="Union1360" />
                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                <ColumnReference Column="Expr1369" />
                <ColumnReference Column="Expr1377" />
                <ColumnReference Column="Expr1378" />
                <ColumnReference Column="Expr1379" />
                <ColumnReference Column="Expr1380" />
                <ColumnReference Column="Expr1381" />
                <ColumnReference Column="Expr1382" />
                <ColumnReference Column="Expr1383" />
                <ColumnReference Column="Expr1384" />
                <ColumnReference Column="Expr1385" />
                <ColumnReference Column="Expr1386" />
                <ColumnReference Column="Expr1387" />
                <ColumnReference Column="Expr1388" />
                <ColumnReference Column="Expr1389" />
                <ColumnReference Column="Expr1390" />
              </OutputList>
              <ComputeScalar>
                <DefinedValues>
                  <DefinedValue>
                    <ColumnReference Column="Expr1378" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1379" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1380" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1381" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1382" />
                    <ScalarOperator ScalarString="getdate()">
                      <Identifier>
                        <ColumnReference Column="ConstExpr1408">
                          <ScalarOperator>
                            <Intrinsic FunctionName="getdate" />
                          </ScalarOperator>
                        </ColumnReference>
                      </Identifier>
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1383" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1384" />
                    <ScalarOperator ScalarString="(0)">
                      <Const ConstValue="(0)" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1385" />
                    <ScalarOperator ScalarString="NULL">
                      <Const ConstValue="NULL" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1386" />
                    <ScalarOperator ScalarString="(2)">
                      <Const ConstValue="(2)" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1387" />
                    <ScalarOperator ScalarString="(1)">
                      <Const ConstValue="(1)" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1388" />
                    <ScalarOperator ScalarString="(3)">
                      <Const ConstValue="(3)" />
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1389" />
                    <ScalarOperator ScalarString="getdate()">
                      <Identifier>
                        <ColumnReference Column="ConstExpr1409">
                          <ScalarOperator>
                            <Intrinsic FunctionName="getdate" />
                          </ScalarOperator>
                        </ColumnReference>
                      </Identifier>
                    </ScalarOperator>
                  </DefinedValue>
                  <DefinedValue>
                    <ColumnReference Column="Expr1390" />
                    <ScalarOperator ScalarString="(0)">
                      <Const ConstValue="(0)" />
                    </ScalarOperator>
                  </DefinedValue>
                </DefinedValues>
                <RelOp AvgRowSize="178" EstimateCPU="8E-08" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Compute Scalar" NodeId="1" Parallel="false" PhysicalOp="Sequence Project" EstimatedTotalSubtreeCost="801.068">
                  <OutputList>
                    <ColumnReference Column="Union1359" />
                    <ColumnReference Column="Union1360" />
                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                    <ColumnReference Column="Expr1369" />
                    <ColumnReference Column="Expr1377" />
                  </OutputList>
                  <RunTimeInformation>
                    <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5902" ActualCPUms="5902" />
                  </RunTimeInformation>
                  <SequenceProject>
                    <DefinedValues>
                      <DefinedValue>
                        <ColumnReference Column="Expr1377" />
                        <ScalarOperator ScalarString="row_number">
                          <Sequence FunctionName="row_number" />
                        </ScalarOperator>
                      </DefinedValue>
                    </DefinedValues>
                    <RelOp AvgRowSize="178" EstimateCPU="2E-08" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Segment" NodeId="2" Parallel="false" PhysicalOp="Segment" EstimatedTotalSubtreeCost="801.068">
                      <OutputList>
                        <ColumnReference Column="Union1358" />
                        <ColumnReference Column="Union1359" />
                        <ColumnReference Column="Union1360" />
                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                        <ColumnReference Column="Expr1369" />
                        <ColumnReference Column="Segment2323" />
                      </OutputList>
                      <RunTimeInformation>
                        <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5902" ActualCPUms="5901" />
                      </RunTimeInformation>
                      <Segment>
                        <GroupBy />
                        <SegmentColumn>
                          <ColumnReference Column="Segment2323" />
                        </SegmentColumn>
                        <RelOp AvgRowSize="174" EstimateCPU="1E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Compute Scalar" NodeId="3" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="801.068">
                          <OutputList>
                            <ColumnReference Column="Union1358" />
                            <ColumnReference Column="Union1359" />
                            <ColumnReference Column="Union1360" />
                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                            <ColumnReference Column="Expr1369" />
                          </OutputList>
                          <ComputeScalar>
                            <DefinedValues>
                              <DefinedValue>
                                <ColumnReference Column="Expr1369" />
                                <ScalarOperator ScalarString="'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'">
                                  <Const ConstValue="'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'" />
                                </ScalarOperator>
                              </DefinedValue>
                            </DefinedValues>
                            <RelOp AvgRowSize="138" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Outer Join" NodeId="4" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.068">
                              <OutputList>
                                <ColumnReference Column="Union1358" />
                                <ColumnReference Column="Union1359" />
                                <ColumnReference Column="Union1360" />
                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                              </OutputList>
                              <RunTimeInformation>
                                <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5902" ActualCPUms="5901" />
                              </RunTimeInformation>
                              <NestedLoops Optimized="false">
                                <RelOp AvgRowSize="138" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="5" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="801.061">
                                  <OutputList>
                                    <ColumnReference Column="Union1358" />
                                    <ColumnReference Column="Union1359" />
                                    <ColumnReference Column="Union1360" />
                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                  </OutputList>
                                  <RunTimeInformation>
                                    <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5901" ActualCPUms="5901" />
                                  </RunTimeInformation>
                                  <Filter StartupExpression="false">
                                    <RelOp AvgRowSize="142" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Outer Join" NodeId="6" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.061">
                                      <OutputList>
                                        <ColumnReference Column="Union1358" />
                                        <ColumnReference Column="Union1359" />
                                        <ColumnReference Column="Union1360" />
                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                      </OutputList>
                                      <RunTimeInformation>
                                        <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5901" ActualCPUms="5900" />
                                      </RunTimeInformation>
                                      <NestedLoops Optimized="false">
                                        <Predicate>
                                          <ScalarOperator ScalarString="[peptest].[dbo].[nc_MailQueue].[sentTo] as [mq].[sentTo]=[peptest].[dbo].[k_users].[mail_user] as [u].[mail_user]">
                                            <Compare CompareOp="EQ">
                                              <ScalarOperator>
                                                <Identifier>
                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="sentTo" />
                                                </Identifier>
                                              </ScalarOperator>
                                              <ScalarOperator>
                                                <Identifier>
                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                </Identifier>
                                              </ScalarOperator>
                                            </Compare>
                                          </ScalarOperator>
                                        </Predicate>
                                        <RelOp AvgRowSize="138" EstimateCPU="4.28971E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="7" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.055">
                                          <OutputList>
                                            <ColumnReference Column="Union1358" />
                                            <ColumnReference Column="Union1359" />
                                            <ColumnReference Column="Union1360" />
                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                          </OutputList>
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5896" ActualCPUms="5896" />
                                          </RunTimeInformation>
                                          <NestedLoops Optimized="false">
                                            <Predicate>
                                              <ScalarOperator ScalarString="[Expr1421]=[peptest].[dbo].[k_users_profiles].[id_profile] as [kup].[id_profile]">
                                                <Compare CompareOp="EQ">
                                                  <ScalarOperator>
                                                    <Identifier>
                                                      <ColumnReference Column="Expr1421" />
                                                    </Identifier>
                                                  </ScalarOperator>
                                                  <ScalarOperator>
                                                    <Identifier>
                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Alias="[kup]" Column="id_profile" />
                                                    </Identifier>
                                                  </ScalarOperator>
                                                </Compare>
                                              </ScalarOperator>
                                            </Predicate>
                                            <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="8" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.00330254">
                                              <OutputList>
                                                <ColumnReference Column="Expr1421" />
                                              </OutputList>
                                              <RunTimeInformation>
                                                <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                              </RunTimeInformation>
                                              <Assert StartupExpression="false">
                                                <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="9" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00330206">
                                                  <OutputList>
                                                    <ColumnReference Column="Expr1420" />
                                                    <ColumnReference Column="Expr1421" />
                                                  </OutputList>
                                                  <RunTimeInformation>
                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                  </RunTimeInformation>
                                                  <StreamAggregate>
                                                    <DefinedValues>
                                                      <DefinedValue>
                                                        <ColumnReference Column="Expr1420" />
                                                        <ScalarOperator ScalarString="Count(*)">
                                                          <Aggregate AggType="countstar" Distinct="false" />
                                                        </ScalarOperator>
                                                      </DefinedValue>
                                                      <DefinedValue>
                                                        <ColumnReference Column="Expr1421" />
                                                        <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_profiles].[id_profile])">
                                                          <Aggregate AggType="ANY" Distinct="false">
                                                            <ScalarOperator>
                                                              <Identifier>
                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_profiles]" Column="id_profile" />
                                                              </Identifier>
                                                            </ScalarOperator>
                                                          </Aggregate>
                                                        </ScalarOperator>
                                                      </DefinedValue>
                                                    </DefinedValues>
                                                    <RelOp AvgRowSize="41" EstimateCPU="0.0001702" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="12" LogicalOp="Clustered Index Scan" NodeId="10" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.0032952" TableCardinality="12">
                                                      <OutputList>
                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_profiles]" Column="id_profile" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="12" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="3" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                      </RunTimeInformation>
                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                        <DefinedValues>
                                                          <DefinedValue>
                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_profiles]" Column="id_profile" />
                                                          </DefinedValue>
                                                        </DefinedValues>
                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_profiles]" Index="[PK_k_profile]" IndexKind="Clustered" Storage="RowStore" />
                                                        <Predicate>
                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_profiles].[name_profile]=N'Manager'">
                                                            <Compare CompareOp="EQ">
                                                              <ScalarOperator>
                                                                <Identifier>
                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_profiles]" Column="name_profile" />
                                                                </Identifier>
                                                              </ScalarOperator>
                                                              <ScalarOperator>
                                                                <Const ConstValue="N'Manager'" />
                                                              </ScalarOperator>
                                                            </Compare>
                                                          </ScalarOperator>
                                                        </Predicate>
                                                      </IndexScan>
                                                    </RelOp>
                                                  </StreamAggregate>
                                                </RelOp>
                                                <Predicate>
                                                  <ScalarOperator ScalarString="CASE WHEN [Expr1420]&gt;(1) THEN (0) ELSE NULL END">
                                                    <IF>
                                                      <Condition>
                                                        <ScalarOperator>
                                                          <Compare CompareOp="GT">
                                                            <ScalarOperator>
                                                              <Identifier>
                                                                <ColumnReference Column="Expr1420" />
                                                              </Identifier>
                                                            </ScalarOperator>
                                                            <ScalarOperator>
                                                              <Const ConstValue="(1)" />
                                                            </ScalarOperator>
                                                          </Compare>
                                                        </ScalarOperator>
                                                      </Condition>
                                                      <Then>
                                                        <ScalarOperator>
                                                          <Const ConstValue="(0)" />
                                                        </ScalarOperator>
                                                      </Then>
                                                      <Else>
                                                        <ScalarOperator>
                                                          <Const ConstValue="NULL" />
                                                        </ScalarOperator>
                                                      </Else>
                                                    </IF>
                                                  </ScalarOperator>
                                                </Predicate>
                                              </Assert>
                                            </RelOp>
                                            <RelOp AvgRowSize="142" EstimateCPU="4.28971E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1.02625" LogicalOp="Inner Join" NodeId="11" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.051">
                                              <OutputList>
                                                <ColumnReference Column="Union1358" />
                                                <ColumnReference Column="Union1359" />
                                                <ColumnReference Column="Union1360" />
                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Alias="[kup]" Column="id_profile" />
                                              </OutputList>
                                              <RunTimeInformation>
                                                <RunTimeCountersPerThread Thread="0" ActualRows="1739" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5896" ActualCPUms="5895" />
                                              </RunTimeInformation>
                                              <NestedLoops Optimized="false">
                                                <OuterReferences>
                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                </OuterReferences>
                                                <RelOp AvgRowSize="142" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1.00047" LogicalOp="Inner Join" NodeId="12" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.048">
                                                  <OutputList>
                                                    <ColumnReference Column="Union1358" />
                                                    <ColumnReference Column="Union1359" />
                                                    <ColumnReference Column="Union1360" />
                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                  </OutputList>
                                                  <RunTimeInformation>
                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5892" ActualCPUms="5892" />
                                                  </RunTimeInformation>
                                                  <NestedLoops Optimized="false">
                                                    <OuterReferences>
                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="codePayee" />
                                                    </OuterReferences>
                                                    <RelOp AvgRowSize="160" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="13" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="801.045">
                                                      <OutputList>
                                                        <ColumnReference Column="Union1358" />
                                                        <ColumnReference Column="Union1359" />
                                                        <ColumnReference Column="Union1360" />
                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="codePayee" />
                                                      </OutputList>
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5887" ActualCPUms="5886" />
                                                      </RunTimeInformation>
                                                      <NestedLoops Optimized="false">
                                                        <OuterReferences>
                                                          <ColumnReference Column="Expr1422" />
                                                        </OuterReferences>
                                                        <RelOp AvgRowSize="146" EstimateCPU="0.000100146" EstimateIO="0.00375375" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Sort" NodeId="14" Parallel="false" PhysicalOp="Sort" EstimatedTotalSubtreeCost="801.041">
                                                          <OutputList>
                                                            <ColumnReference Column="Union1358" />
                                                            <ColumnReference Column="Union1359" />
                                                            <ColumnReference Column="Union1360" />
                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                            <ColumnReference Column="Expr1422" />
                                                          </OutputList>
                                                          <MemoryFractions Input="0.0308215" Output="0.0308215" />
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="2" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                          </RunTimeInformation>
                                                          <Sort Distinct="false">
                                                            <OrderBy>
                                                              <OrderByColumn Ascending="true">
                                                                <ColumnReference Column="Union1358" />
                                                              </OrderByColumn>
                                                            </OrderBy>
                                                            <RelOp AvgRowSize="146" EstimateCPU="0.00915023" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Inner Join" NodeId="15" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="801.038">
                                                              <OutputList>
                                                                <ColumnReference Column="Union1358" />
                                                                <ColumnReference Column="Union1359" />
                                                                <ColumnReference Column="Union1360" />
                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                <ColumnReference Column="Expr1422" />
                                                              </OutputList>
                                                              <MemoryFractions Input="1.48091E-05" Output="1.48091E-05" />
                                                              <RunTimeInformation>
                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="28" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="1" ActualCPUms="1" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                              </RunTimeInformation>
                                                              <Hash BitmapCreator="true">
                                                                <DefinedValues>
                                                                  <DefinedValue>
                                                                    <ColumnReference Column="Opt_Bitmap2249" />
                                                                  </DefinedValue>
                                                                </DefinedValues>
                                                                <HashKeysBuild>
                                                                  <ColumnReference Column="Union1358" />
                                                                </HashKeysBuild>
                                                                <HashKeysProbe>
                                                                  <ColumnReference Column="Expr1422" />
                                                                </HashKeysProbe>
                                                                <ProbeResidual>
                                                                  <ScalarOperator ScalarString="[Union1358]=[Expr1422]">
                                                                    <Compare CompareOp="EQ">
                                                                      <ScalarOperator>
                                                                        <Identifier>
                                                                          <ColumnReference Column="Union1358" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                      <ScalarOperator>
                                                                        <Identifier>
                                                                          <ColumnReference Column="Expr1422" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                    </Compare>
                                                                  </ScalarOperator>
                                                                </ProbeResidual>
                                                                <RelOp AvgRowSize="84" EstimateCPU="2.36827E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2" LogicalOp="Aggregate" NodeId="16" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="798.147">
                                                                  <OutputList>
                                                                    <ColumnReference Column="Union1358" />
                                                                    <ColumnReference Column="Union1359" />
                                                                    <ColumnReference Column="Union1360" />
                                                                  </OutputList>
                                                                  <RunTimeInformation>
                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1739" Batches="2" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="5845" ActualCPUms="5845" />
                                                                  </RunTimeInformation>
                                                                  <StreamAggregate>
                                                                    <DefinedValues />
                                                                    <GroupBy>
                                                                      <ColumnReference Column="Union1358" />
                                                                      <ColumnReference Column="Union1359" />
                                                                      <ColumnReference Column="Union1360" />
                                                                    </GroupBy>
                                                                    <RelOp AvgRowSize="84" EstimateCPU="0.000294826" EstimateIO="0.00375375" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="45.3654" LogicalOp="Sort" NodeId="17" Parallel="false" PhysicalOp="Sort" EstimatedTotalSubtreeCost="798.147">
                                                                      <OutputList>
                                                                        <ColumnReference Column="Union1358" />
                                                                        <ColumnReference Column="Union1359" />
                                                                        <ColumnReference Column="Union1360" />
                                                                      </OutputList>
                                                                      <MemoryFractions Input="0.0385111" Output="0.0385111" />
                                                                      <RunTimeInformation>
                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="3032" Batches="4" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="1" ActualCPUms="1" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                      </RunTimeInformation>
                                                                      <Sort Distinct="false">
                                                                        <OrderBy>
                                                                          <OrderByColumn Ascending="true">
                                                                            <ColumnReference Column="Union1358" />
                                                                          </OrderByColumn>
                                                                          <OrderByColumn Ascending="true">
                                                                            <ColumnReference Column="Union1359" />
                                                                          </OrderByColumn>
                                                                          <OrderByColumn Ascending="true">
                                                                            <ColumnReference Column="Union1360" />
                                                                          </OrderByColumn>
                                                                        </OrderBy>
                                                                        <RelOp AvgRowSize="84" EstimateCPU="2.26827E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="45.3654" LogicalOp="Concatenation" NodeId="18" Parallel="false" PhysicalOp="Concatenation" EstimatedTotalSubtreeCost="798.143">
                                                                          <OutputList>
                                                                            <ColumnReference Column="Union1358" />
                                                                            <ColumnReference Column="Union1359" />
                                                                            <ColumnReference Column="Union1360" />
                                                                          </OutputList>
                                                                          <RunTimeInformation>
                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="3032" Batches="12" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                          </RunTimeInformation>
                                                                          <Concat>
                                                                            <DefinedValues>
                                                                              <DefinedValue>
                                                                                <ColumnReference Column="Union1358" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                              </DefinedValue>
                                                                              <DefinedValue>
                                                                                <ColumnReference Column="Union1359" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                              </DefinedValue>
                                                                              <DefinedValue>
                                                                                <ColumnReference Column="Union1360" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                              </DefinedValue>
                                                                            </DefinedValues>
                                                                            <RelOp AvgRowSize="84" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Semi Join" NodeId="19" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="9.30941">
                                                                              <OutputList>
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                              </OutputList>
                                                                              <RunTimeInformation>
                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="2" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1247" ActualCPUms="1247" />
                                                                              </RunTimeInformation>
                                                                              <NestedLoops Optimized="false">
                                                                                <OuterReferences>
                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                </OuterReferences>
                                                                                <RelOp AvgRowSize="84" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Filter" NodeId="20" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="9.24484">
                                                                                  <OutputList>
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                  </OutputList>
                                                                                  <RunTimeInformation>
                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="18" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                  </RunTimeInformation>
                                                                                  <Filter StartupExpression="false">
                                                                                    <RelOp AvgRowSize="92" EstimateCPU="5E-08" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Window Aggregate" NodeId="21" Parallel="false" PhysicalOp="Window Aggregate" EstimatedTotalSubtreeCost="9.24483">
                                                                                      <OutputList>
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                        <ColumnReference Column="Expr1010" />
                                                                                      </OutputList>
                                                                                      <RunTimeInformation>
                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="18" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="1" ActualCPUms="1" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                      </RunTimeInformation>
                                                                                      <WindowAggregate>
                                                                                        <DefinedValues>
                                                                                          <DefinedValue>
                                                                                            <ColumnReference Column="Expr1010" />
                                                                                            <ScalarOperator ScalarString="row_number">
                                                                                              <Sequence FunctionName="row_number" />
                                                                                            </ScalarOperator>
                                                                                          </DefinedValue>
                                                                                        </DefinedValues>
                                                                                        <RelOp AvgRowSize="96" EstimateCPU="0.000100096" EstimateIO="0.00375375" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Sort" NodeId="22" Parallel="false" PhysicalOp="Sort" EstimatedTotalSubtreeCost="9.24483">
                                                                                          <OutputList>
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                          </OutputList>
                                                                                          <MemoryFractions Input="0.935548" Output="0.935548" />
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="18" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="12" ActualCPUms="12" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                          </RunTimeInformation>
                                                                                          <Sort Distinct="false">
                                                                                            <OrderBy>
                                                                                              <OrderByColumn Ascending="true">
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                              </OrderByColumn>
                                                                                              <OrderByColumn Ascending="false">
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                              </OrderByColumn>
                                                                                              <OrderByColumn Ascending="true">
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                              </OrderByColumn>
                                                                                            </OrderBy>
                                                                                            <RelOp AvgRowSize="96" EstimateCPU="0.00907553" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" LogicalOp="Inner Join" NodeId="23" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="9.24098">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                              </OutputList>
                                                                                              <MemoryFractions Input="0.000449512" Output="0.000449512" />
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="18" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                              </RunTimeInformation>
                                                                                              <Hash BitmapCreator="true">
                                                                                                <DefinedValues>
                                                                                                  <DefinedValue>
                                                                                                    <ColumnReference Column="Opt_Bitmap1665" />
                                                                                                  </DefinedValue>
                                                                                                </DefinedValues>
                                                                                                <HashKeysBuild>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                </HashKeysBuild>
                                                                                                <HashKeysProbe>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                </HashKeysProbe>
                                                                                                <ProbeResidual>
                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grids].[id_grid] as [krg].[id_grid]=[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[related_notification_grid] as [smns].[related_notification_grid]">
                                                                                                    <Compare CompareOp="EQ">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                </ProbeResidual>
                                                                                                <RelOp AvgRowSize="11" EstimateCPU="2E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="24" Parallel="false" PhysicalOp="Adaptive Join" IsAdaptive="true" AdaptiveThresholdRows="20.4864" EstimatedTotalSubtreeCost="0.0453275" EstimatedJoinType="Nested Loops">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="1" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualJoinType="Nested Loops" />
                                                                                                  </RunTimeInformation>
                                                                                                  <AdaptiveJoin Optimized="false">
                                                                                                    <DefinedValues>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                      </DefinedValue>
                                                                                                    </DefinedValues>
                                                                                                    <HashKeysBuild>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                    </HashKeysBuild>
                                                                                                    <HashKeysProbe>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="id_table_view" />
                                                                                                    </HashKeysProbe>
                                                                                                    <ProbeResidual>
                                                                                                      <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_tables_views].[id_table_view] as [krtv].[id_table_view]=[peptest].[dbo].[k_referential_grids].[id_table_view] as [krg].[id_table_view]">
                                                                                                        <Compare CompareOp="EQ">
                                                                                                          <ScalarOperator>
                                                                                                            <Identifier>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="id_table_view" />
                                                                                                            </Identifier>
                                                                                                          </ScalarOperator>
                                                                                                          <ScalarOperator>
                                                                                                            <Identifier>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                            </Identifier>
                                                                                                          </ScalarOperator>
                                                                                                        </Compare>
                                                                                                      </ScalarOperator>
                                                                                                    </ProbeResidual>
                                                                                                    <OuterReferences>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                    </OuterReferences>
                                                                                                    <RelOp AvgRowSize="85" EstimateCPU="2.68427E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="6.41777" LogicalOp="Inner Join" NodeId="26" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0280545">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="7" Batches="1" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <NestedLoops Optimized="false">
                                                                                                        <OuterReferences>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                        </OuterReferences>
                                                                                                        <RelOp AvgRowSize="11" EstimateCPU="2.68427E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="6.42169" LogicalOp="Inner Join" NodeId="27" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0107251">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="8" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <NestedLoops Optimized="false">
                                                                                                            <OuterReferences>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Alias="[krgf]" Column="id_folder" />
                                                                                                            </OuterReferences>
                                                                                                            <RelOp AvgRowSize="45" EstimateCPU="0.0004518" EstimateIO="0.0068287" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="268" LogicalOp="Clustered Index Scan" NodeId="28" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.0072805" TableCardinality="268">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Alias="[krgf]" Column="id_folder" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="268" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="8" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Alias="[krgf]" Column="id_folder" />
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Index="[PK_k_referential_grid_folders]" Alias="[krgf]" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grid_folders].[name_folder] as [krgf].[name_folder]=N'Notifications Setup'">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Alias="[krgf]" Column="name_folder" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Const ConstValue="N'Notifications Setup'" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </IndexScan>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="11" EstimateCPU="0.000164064" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="6.42169" EstimatedRowsRead="6.42169" LogicalOp="Index Seek" NodeId="29" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.00328906" TableCardinality="1640">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="8" ActualRowsRead="8" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="2" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Index="[IX__k_referential_grids__id_grid_parent]" Alias="[krg]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                <SeekPredicates>
                                                                                                                  <SeekPredicateNew>
                                                                                                                    <SeekKeys>
                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                        <RangeColumns>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid_parent" />
                                                                                                                        </RangeColumns>
                                                                                                                        <RangeExpressions>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grid_folders].[id_folder] as [krgf].[id_folder]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grid_folders]" Alias="[krgf]" Column="id_folder" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                        </RangeExpressions>
                                                                                                                      </Prefix>
                                                                                                                    </SeekKeys>
                                                                                                                  </SeekPredicateNew>
                                                                                                                </SeekPredicates>
                                                                                                              </IndexScan>
                                                                                                            </RelOp>
                                                                                                          </NestedLoops>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="270" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="5.42169" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="0.99939" LogicalOp="Clustered Index Seek" NodeId="31" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.0173026" TableCardinality="1640">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="7" ActualRowsRead="8" Batches="0" ActualEndOfScans="1" ActualExecutions="8" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="16" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Index="[PK_k_referential_grids_1]" Alias="[krg]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                            <SeekPredicates>
                                                                                                              <SeekPredicateNew>
                                                                                                                <SeekKeys>
                                                                                                                  <Prefix ScanType="EQ">
                                                                                                                    <RangeColumns>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                                    </RangeColumns>
                                                                                                                    <RangeExpressions>
                                                                                                                      <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grids].[id_grid] as [krg].[id_grid]">
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_grid" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </RangeExpressions>
                                                                                                                  </Prefix>
                                                                                                                </SeekKeys>
                                                                                                              </SeekPredicateNew>
                                                                                                            </SeekPredicates>
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grids].[name_grid] as [krg].[name_grid]&lt;&gt;N'Manager Notification Setup'">
                                                                                                                <Compare CompareOp="NE">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="name_grid" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Const ConstValue="N'Manager Notification Setup'" />
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </IndexScan>
                                                                                                        </RelOp>
                                                                                                      </NestedLoops>
                                                                                                    </RelOp>
                                                                                                    <RelOp AvgRowSize="87" EstimateCPU="0.0026045" EstimateIO="0.0409028" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1.00135" EstimatedRowsRead="2225" LogicalOp="Clustered Index Scan" NodeId="32" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.0435073" TableCardinality="2225">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="id_table_view" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                        <DefinedValues>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="id_table_view" />
                                                                                                          </DefinedValue>
                                                                                                        </DefinedValues>
                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Index="[PK_k_referential_tables_views]" Alias="[krtv]" IndexKind="Clustered" Storage="RowStore" />
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_tables_views].[name_table_view] as [krtv].[name_table_view]=N'vPEPSICO_send_mail_notification_bonus'">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="name_table_view" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Const ConstValue="N'vPEPSICO_send_mail_notification_bonus'" />
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </IndexScan>
                                                                                                    </RelOp>
                                                                                                    <RelOp AvgRowSize="83" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="5.4176" EstimateRewinds="0.000173958" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Clustered Index Seek" NodeId="35" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.0172398" TableCardinality="2225">
                                                                                                      <OutputList />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="7" Batches="0" ActualEndOfScans="6" ActualExecutions="7" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="14" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                        <DefinedValues />
                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Index="[PK_k_referential_tables_views]" Alias="[krtv]" IndexKind="Clustered" Storage="RowStore" />
                                                                                                        <SeekPredicates>
                                                                                                          <SeekPredicateNew>
                                                                                                            <SeekKeys>
                                                                                                              <Prefix ScanType="EQ">
                                                                                                                <RangeColumns>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="id_table_view" />
                                                                                                                </RangeColumns>
                                                                                                                <RangeExpressions>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_grids].[id_table_view] as [krg].[id_table_view]">
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_grids]" Alias="[krg]" Column="id_table_view" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                </RangeExpressions>
                                                                                                              </Prefix>
                                                                                                            </SeekKeys>
                                                                                                          </SeekPredicateNew>
                                                                                                        </SeekPredicates>
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_referential_tables_views].[name_table_view] as [krtv].[name_table_view]=N'vPEPSICO_send_mail_notification_bonus'">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_referential_tables_views]" Alias="[krtv]" Column="name_table_view" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Const ConstValue="N'vPEPSICO_send_mail_notification_bonus'" />
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </IndexScan>
                                                                                                    </RelOp>
                                                                                                  </AdaptiveJoin>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="100" EstimateCPU="0.000356828" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="85.3656" LogicalOp="Left Semi Join" NodeId="36" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="9.18647">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="18" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="414" ActualCPUms="414" />
                                                                                                  </RunTimeInformation>
                                                                                                  <NestedLoops Optimized="false">
                                                                                                    <OuterReferences>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                    </OuterReferences>
                                                                                                    <RelOp AvgRowSize="215" EstimateCPU="0.000356828" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="85.3656" LogicalOp="Left Semi Join" NodeId="37" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="9.18598">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="202" ActualCPUms="202" />
                                                                                                      </RunTimeInformation>
                                                                                                      <NestedLoops Optimized="false">
                                                                                                        <OuterReferences>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                        </OuterReferences>
                                                                                                        <RelOp AvgRowSize="282" EstimateCPU="0.0102283" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="85.3656" LogicalOp="Inner Join" NodeId="38" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="9.18549">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                          </OutputList>
                                                                                                          <MemoryFractions Input="0.000449512" Output="0.000449512" />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="82472" Batches="94" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="9" ActualCPUms="9" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Hash BitmapCreator="true">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Column="Opt_Bitmap1638" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <HashKeysBuild>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="CompGroupName" />
                                                                                                            </HashKeysBuild>
                                                                                                            <HashKeysProbe>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                            </HashKeysProbe>
                                                                                                            <ProbeResidual>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_CompGroup].[CompGroupName] as [cg].[CompGroupName]=[peptest].[dbo].[PEPSICO_Process_BonusApproval].[CompGroupName] as [pba].[CompGroupName]">
                                                                                                                <Compare CompareOp="EQ">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="CompGroupName" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </ProbeResidual>
                                                                                                            <RelOp AvgRowSize="266" EstimateCPU="0.00020064" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="39" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.00684707">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="CompGroupName" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="48" Batches="1" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <NestedLoops Optimized="false">
                                                                                                                <RelOp AvgRowSize="249" EstimateCPU="0.000171287" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" EstimatedRowsRead="13" LogicalOp="Table Scan" NodeId="41" Parallel="false" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="0.00329629" TableCardinality="13">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="13" Batches="1" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="1" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" TableReferenceId="1" IndexKind="Heap" Storage="RowStore" />
                                                                                                                    <Predicate>
                                                                                                                      <ScalarOperator ScalarString="getdate()&gt;=[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[BonusStartDate] as [smns].[BonusStartDate] AND getdate()&lt;=[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[BonusEndDate] as [smns].[BonusEndDate] AND [peptest].[dbo].[PEPSICO_send_mail_notification_setup].[SendBonusNotifications] as [smns].[SendBonusNotifications]=(1) AND PROBE([Opt_Bitmap1665],[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[related_notification_grid] as [smns].[related_notification_grid])">
                                                                                                                        <Logical Operation="AND">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Logical Operation="AND">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Compare CompareOp="GE">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Column="ConstExpr1393">
                                                                                                                                        <ScalarOperator>
                                                                                                                                          <Intrinsic FunctionName="getdate" />
                                                                                                                                        </ScalarOperator>
                                                                                                                                      </ColumnReference>
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="BonusStartDate" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Compare>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Compare CompareOp="LE">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Column="ConstExpr1394">
                                                                                                                                        <ScalarOperator>
                                                                                                                                          <Intrinsic FunctionName="getdate" />
                                                                                                                                        </ScalarOperator>
                                                                                                                                      </ColumnReference>
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="BonusEndDate" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Compare>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Compare CompareOp="EQ">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="SendBonusNotifications" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Const ConstValue="(1)" />
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Compare>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Logical>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Intrinsic FunctionName="PROBE">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Column="Opt_Bitmap1665" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="related_notification_grid" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Intrinsic>
                                                                                                                          </ScalarOperator>
                                                                                                                        </Logical>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Predicate>
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                                <RelOp AvgRowSize="33" EstimateCPU="0.0002098" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="48" EstimatedRowsRead="48" LogicalOp="Clustered Index Scan" NodeId="42" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.0033348" TableCardinality="48">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="CompGroupName" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="48" ActualRowsRead="48" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="3" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="CompGroupName" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Index="[PK_CompGroup]" Alias="[cg]" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                              </NestedLoops>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="67" EstimateCPU="0.111635" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="85.3656" LogicalOp="Filter" NodeId="43" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="9.16841">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="82472" Batches="94" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="8" ActualCPUms="8" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="75" EstimateCPU="0.139574" EstimateIO="8.9172" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="85.3656" EstimatedRowsRead="126858" LogicalOp="Table Scan" NodeId="44" Parallel="false" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="9.05677" TableCardinality="126858">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="82472" ActualRowsRead="126858" Batches="94" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="68" ActualCPUms="68" ActualScans="1" ActualLogicalReads="16585" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="gpid" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" TableReferenceId="2" IndexKind="Heap" Storage="RowStore" />
                                                                                                                    <Predicate>
                                                                                                                      <ScalarOperator ScalarString="getdate()&gt;=[peptest].[dbo].[PEPSICO_Process_BonusApproval].[start_date_histo] as [pba].[start_date_histo] AND getdate()&lt;=[peptest].[dbo].[PEPSICO_Process_BonusApproval].[end_date_histo] as [pba].[end_date_histo]">
                                                                                                                        <Logical Operation="AND">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Compare CompareOp="GE">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Column="ConstExpr1391">
                                                                                                                                    <ScalarOperator>
                                                                                                                                      <Intrinsic FunctionName="getdate" />
                                                                                                                                    </ScalarOperator>
                                                                                                                                  </ColumnReference>
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="start_date_histo" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Compare>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Compare CompareOp="LE">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Column="ConstExpr1392">
                                                                                                                                    <ScalarOperator>
                                                                                                                                      <Intrinsic FunctionName="getdate" />
                                                                                                                                    </ScalarOperator>
                                                                                                                                  </ColumnReference>
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="end_date_histo" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Compare>
                                                                                                                          </ScalarOperator>
                                                                                                                        </Logical>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Predicate>
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="PROBE([Opt_Bitmap1638],[peptest].[dbo].[PEPSICO_Process_BonusApproval].[CompGroupName] as [pba].[CompGroupName])">
                                                                                                                    <Intrinsic FunctionName="PROBE">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Column="Opt_Bitmap1638" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="CompGroupName" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Intrinsic>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                          </Hash>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="9" EstimateCPU="8.07107E-07" EstimateIO="0" EstimateRebinds="73.1705" EstimateRewinds="11.1951" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="8.07107" LogicalOp="Concatenation" NodeId="45" Parallel="false" PhysicalOp="Concatenation" EstimatedTotalSubtreeCost="0.000134935">
                                                                                                          <OutputList />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="66862" ActualExecutions="82472" ActualExecutionMode="Row" ActualElapsedms="81" ActualCPUms="81" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Concat>
                                                                                                            <DefinedValues />
                                                                                                            <RelOp AvgRowSize="9" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="73.1705" EstimateRewinds="11.1951" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="46" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.000126498">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRebinds="82472" ActualRewinds="0" ActualRows="0" Batches="0" ActualEndOfScans="82472" ActualExecutions="82472" ActualExecutionMode="Row" ActualElapsedms="10" ActualCPUms="10" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="true">
                                                                                                                <RelOp AvgRowSize="9" EstimateCPU="1.157E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="84.3656" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Constant Scan" NodeId="47" Parallel="false" PhysicalOp="Constant Scan" EstimatedTotalSubtreeCost="8.55226E-05">
                                                                                                                  <OutputList />
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <ConstantScan />
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[CompGroupList] as [smns].[CompGroupList]='-1'">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Const ConstValue="'-1'" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="9" EstimateCPU="2.4E-05" EstimateIO="0" EstimateRebinds="73.1705" EstimateRewinds="11.1951" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="7.07107" LogicalOp="Filter" NodeId="48" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.000953886">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="66862" ActualExecutions="82472" ActualExecutionMode="Row" ActualElapsedms="45" ActualCPUms="45" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="11" EstimateCPU="5E-06" EstimateIO="0" EstimateRebinds="73.1705" EstimateRewinds="11.1951" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Compute Scalar" NodeId="49" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="0.000664145">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Column="Expr1423" />
                                                                                                                  </OutputList>
                                                                                                                  <ComputeScalar>
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1423" />
                                                                                                                        <ScalarOperator ScalarString="CONVERT_IMPLICIT(int,STRING_SPLIT.[value],0)">
                                                                                                                          <Convert DataType="int" Style="0" Implicit="true">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                          </Convert>
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <RelOp AvgRowSize="2011" EstimateCPU="5.0157E-05" EstimateIO="0" EstimateRebinds="73.1705" EstimateRewinds="11.1951" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Table-valued function" NodeId="50" Parallel="false" PhysicalOp="Table-valued function" EstimatedTotalSubtreeCost="0.000603783">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                      </OutputList>
                                                                                                                      <MemoryFractions Input="0" Output="0" />
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRebinds="82472" ActualRewinds="0" ActualRows="82472" Batches="0" ActualEndOfScans="66862" ActualExecutions="82472" ActualExecutionMode="Row" ActualElapsedms="25" ActualCPUms="25" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <TableValuedFunction>
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Table="[STRING_SPLIT]" />
                                                                                                                        <ParameterList>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[CompGroupList] as [smns].[CompGroupList]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator ScalarString="','">
                                                                                                                            <Const ConstValue="','" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </ParameterList>
                                                                                                                      </TableValuedFunction>
                                                                                                                    </RelOp>
                                                                                                                  </ComputeScalar>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_CompGroup].[idCompGroup] as [cg].[idCompGroup]=[Expr1423]">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_CompGroup]" Alias="[cg]" Column="idCompGroup" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Column="Expr1423" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                          </Concat>
                                                                                                        </RelOp>
                                                                                                      </NestedLoops>
                                                                                                    </RelOp>
                                                                                                    <RelOp AvgRowSize="9" EstimateCPU="8.07107E-07" EstimateIO="0" EstimateRebinds="83.0379" EstimateRewinds="1.32768" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="8.07107" LogicalOp="Concatenation" NodeId="51" Parallel="false" PhysicalOp="Concatenation" EstimatedTotalSubtreeCost="0.000134935">
                                                                                                      <OutputList />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="0" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="202" ActualCPUms="202" />
                                                                                                      </RunTimeInformation>
                                                                                                      <Concat>
                                                                                                        <DefinedValues />
                                                                                                        <RelOp AvgRowSize="9" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="83.0379" EstimateRewinds="1.32768" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="52" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.000126498">
                                                                                                          <OutputList />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRebinds="15610" ActualRewinds="0" ActualRows="0" Batches="0" ActualEndOfScans="15610" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="2" ActualCPUms="2" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Filter StartupExpression="true">
                                                                                                            <RelOp AvgRowSize="9" EstimateCPU="1.157E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="84.3656" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Constant Scan" NodeId="53" Parallel="false" PhysicalOp="Constant Scan" EstimatedTotalSubtreeCost="8.55226E-05">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <ConstantScan />
                                                                                                            </RelOp>
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[LevelCodeList] as [smns].[LevelCodeList]='-1'">
                                                                                                                <Compare CompareOp="EQ">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Const ConstValue="'-1'" />
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </Filter>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="9" EstimateCPU="2.4E-05" EstimateIO="0" EstimateRebinds="83.0379" EstimateRewinds="1.32768" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="7.07107" LogicalOp="Filter" NodeId="54" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.000893523">
                                                                                                          <OutputList />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="0" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="195" ActualCPUms="195" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Filter StartupExpression="false">
                                                                                                            <RelOp AvgRowSize="2011" EstimateCPU="5.0157E-05" EstimateIO="0" EstimateRebinds="83.0379" EstimateRewinds="1.32768" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Table-valued function" NodeId="55" Parallel="false" PhysicalOp="Table-valued function" EstimatedTotalSubtreeCost="0.000603783">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                              </OutputList>
                                                                                                              <MemoryFractions Input="0" Output="0" />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRebinds="15610" ActualRewinds="0" ActualRows="912747" Batches="0" ActualEndOfScans="0" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="123" ActualCPUms="123" />
                                                                                                              </RunTimeInformation>
                                                                                                              <TableValuedFunction>
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <Object Table="[STRING_SPLIT]" />
                                                                                                                <ParameterList>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[LevelCodeList] as [smns].[LevelCodeList]">
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator ScalarString="','">
                                                                                                                    <Const ConstValue="','" />
                                                                                                                  </ScalarOperator>
                                                                                                                </ParameterList>
                                                                                                              </TableValuedFunction>
                                                                                                            </RelOp>
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_BonusApproval].[LevelCode] as [pba].[LevelCode]=STRING_SPLIT.[value]">
                                                                                                                <Compare CompareOp="EQ">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="LevelCode" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </Filter>
                                                                                                        </RelOp>
                                                                                                      </Concat>
                                                                                                    </RelOp>
                                                                                                  </NestedLoops>
                                                                                                </RelOp>
                                                                                              </Hash>
                                                                                            </RelOp>
                                                                                          </Sort>
                                                                                        </RelOp>
                                                                                      </WindowAggregate>
                                                                                    </RelOp>
                                                                                    <Predicate>
                                                                                      <ScalarOperator ScalarString="[Expr1010]=(1)">
                                                                                        <Compare CompareOp="EQ">
                                                                                          <ScalarOperator>
                                                                                            <Identifier>
                                                                                              <ColumnReference Column="Expr1010" />
                                                                                            </Identifier>
                                                                                          </ScalarOperator>
                                                                                          <ScalarOperator>
                                                                                            <Const ConstValue="(1)" />
                                                                                          </ScalarOperator>
                                                                                        </Compare>
                                                                                      </ScalarOperator>
                                                                                    </Predicate>
                                                                                  </Filter>
                                                                                </RelOp>
                                                                                <RelOp AvgRowSize="9" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Semi Join" NodeId="56" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0645686">
                                                                                  <OutputList />
                                                                                  <MemoryFractions Input="0" Output="0.000449512" />
                                                                                  <RunTimeInformation>
                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="0" ActualEndOfScans="13974" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="801" ActualCPUms="801" InputMemoryGrant="0" OutputMemoryGrant="1480" UsedMemoryGrant="0" />
                                                                                  </RunTimeInformation>
                                                                                  <NestedLoops Optimized="true">
                                                                                    <OuterReferences>
                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                      <ColumnReference Column="Expr1413" />
                                                                                    </OuterReferences>
                                                                                    <RelOp AvgRowSize="15" EstimateCPU="9.68074E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Semi Join" NodeId="58" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0579932">
                                                                                      <OutputList>
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                        <ColumnReference Column="Expr1413" />
                                                                                      </OutputList>
                                                                                      <MemoryFractions Input="0" Output="0.000449512" />
                                                                                      <RunTimeInformation>
                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="0" ActualEndOfScans="13974" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="783" ActualCPUms="783" InputMemoryGrant="0" OutputMemoryGrant="1480" UsedMemoryGrant="16" />
                                                                                      </RunTimeInformation>
                                                                                      <NestedLoops Optimized="true">
                                                                                        <OuterReferences>
                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                          <ColumnReference Column="Expr1411" />
                                                                                        </OuterReferences>
                                                                                        <RelOp AvgRowSize="19" EstimateCPU="9.68074E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2.31597" LogicalOp="Inner Join" NodeId="60" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0509904">
                                                                                          <OutputList>
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                            <ColumnReference Column="Expr1411" />
                                                                                            <ColumnReference Column="Expr1413" />
                                                                                          </OutputList>
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1661" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="763" ActualCPUms="763" />
                                                                                          </RunTimeInformation>
                                                                                          <NestedLoops Optimized="false">
                                                                                            <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="61" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.00867733">
                                                                                              <OutputList>
                                                                                                <ColumnReference Column="Expr1413" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="2" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="345" ActualCPUms="345" />
                                                                                              </RunTimeInformation>
                                                                                              <Assert StartupExpression="false">
                                                                                                <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="62" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00867685">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Column="Expr1412" />
                                                                                                    <ColumnReference Column="Expr1413" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="2" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="342" ActualCPUms="342" />
                                                                                                  </RunTimeInformation>
                                                                                                  <StreamAggregate>
                                                                                                    <DefinedValues>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Column="Expr1412" />
                                                                                                        <ScalarOperator ScalarString="Count(*)">
                                                                                                          <Aggregate AggType="countstar" Distinct="false" />
                                                                                                        </ScalarOperator>
                                                                                                      </DefinedValue>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Column="Expr1413" />
                                                                                                        <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_m_fields].[id_field])">
                                                                                                          <Aggregate AggType="ANY" Distinct="false">
                                                                                                            <ScalarOperator>
                                                                                                              <Identifier>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                              </Identifier>
                                                                                                            </ScalarOperator>
                                                                                                          </Aggregate>
                                                                                                        </ScalarOperator>
                                                                                                      </DefinedValue>
                                                                                                    </DefinedValues>
                                                                                                    <RelOp AvgRowSize="270" EstimateCPU="0.0003022" EstimateIO="0.00831019" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="132" LogicalOp="Clustered Index Scan" NodeId="63" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00861239" TableCardinality="132">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="15610" ActualRowsRead="2060520" Batches="0" ActualEndOfScans="15610" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="335" ActualCPUms="335" ActualScans="15610" ActualLogicalReads="156100" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                        <DefinedValues>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                          </DefinedValue>
                                                                                                        </DefinedValues>
                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Index="[PK_k_m_fields]" TableReferenceId="2" IndexKind="Clustered" Storage="RowStore" />
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_fields].[code_field]=N'bonus_approval_involvement_status'">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="code_field" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Const ConstValue="N'bonus_approval_involvement_status'" />
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </IndexScan>
                                                                                                    </RelOp>
                                                                                                  </StreamAggregate>
                                                                                                </RelOp>
                                                                                                <Predicate>
                                                                                                  <ScalarOperator ScalarString="CASE WHEN [Expr1412]&gt;(1) THEN (0) ELSE NULL END">
                                                                                                    <IF>
                                                                                                      <Condition>
                                                                                                        <ScalarOperator>
                                                                                                          <Compare CompareOp="GT">
                                                                                                            <ScalarOperator>
                                                                                                              <Identifier>
                                                                                                                <ColumnReference Column="Expr1412" />
                                                                                                              </Identifier>
                                                                                                            </ScalarOperator>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="(1)" />
                                                                                                            </ScalarOperator>
                                                                                                          </Compare>
                                                                                                        </ScalarOperator>
                                                                                                      </Condition>
                                                                                                      <Then>
                                                                                                        <ScalarOperator>
                                                                                                          <Const ConstValue="(0)" />
                                                                                                        </ScalarOperator>
                                                                                                      </Then>
                                                                                                      <Else>
                                                                                                        <ScalarOperator>
                                                                                                          <Const ConstValue="NULL" />
                                                                                                        </ScalarOperator>
                                                                                                      </Else>
                                                                                                    </IF>
                                                                                                  </ScalarOperator>
                                                                                                </Predicate>
                                                                                              </Assert>
                                                                                            </RelOp>
                                                                                            <RelOp AvgRowSize="15" EstimateCPU="9.68074E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2.31597" LogicalOp="Inner Join" NodeId="64" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0423034">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                <ColumnReference Column="Expr1411" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1661" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="410" ActualCPUms="410" />
                                                                                              </RunTimeInformation>
                                                                                              <NestedLoops Optimized="false">
                                                                                                <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="65" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.00867733">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Column="Expr1411" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="2" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="340" ActualCPUms="340" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Assert StartupExpression="false">
                                                                                                    <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="66" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00867685">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Column="Expr1410" />
                                                                                                        <ColumnReference Column="Expr1411" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="15610" Batches="0" ActualEndOfScans="2" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="337" ActualCPUms="337" />
                                                                                                      </RunTimeInformation>
                                                                                                      <StreamAggregate>
                                                                                                        <DefinedValues>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Column="Expr1410" />
                                                                                                            <ScalarOperator ScalarString="Count(*)">
                                                                                                              <Aggregate AggType="countstar" Distinct="false" />
                                                                                                            </ScalarOperator>
                                                                                                          </DefinedValue>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Column="Expr1411" />
                                                                                                            <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_m_fields].[id_field])">
                                                                                                              <Aggregate AggType="ANY" Distinct="false">
                                                                                                                <ScalarOperator>
                                                                                                                  <Identifier>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                  </Identifier>
                                                                                                                </ScalarOperator>
                                                                                                              </Aggregate>
                                                                                                            </ScalarOperator>
                                                                                                          </DefinedValue>
                                                                                                        </DefinedValues>
                                                                                                        <RelOp AvgRowSize="48" EstimateCPU="0.0003022" EstimateIO="0.00831019" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="132" LogicalOp="Clustered Index Scan" NodeId="67" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00861239" TableCardinality="132">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="15610" ActualRowsRead="2060520" Batches="0" ActualEndOfScans="15610" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="331" ActualCPUms="331" ActualScans="15610" ActualLogicalReads="156100" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Index="[PK_k_m_fields]" TableReferenceId="1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_fields].[code_field]=N'bonus_team_assignment_correct'">
                                                                                                                <Compare CompareOp="EQ">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="code_field" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Const ConstValue="N'bonus_team_assignment_correct'" />
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </IndexScan>
                                                                                                        </RelOp>
                                                                                                      </StreamAggregate>
                                                                                                    </RelOp>
                                                                                                    <Predicate>
                                                                                                      <ScalarOperator ScalarString="CASE WHEN [Expr1410]&gt;(1) THEN (0) ELSE NULL END">
                                                                                                        <IF>
                                                                                                          <Condition>
                                                                                                            <ScalarOperator>
                                                                                                              <Compare CompareOp="GT">
                                                                                                                <ScalarOperator>
                                                                                                                  <Identifier>
                                                                                                                    <ColumnReference Column="Expr1410" />
                                                                                                                  </Identifier>
                                                                                                                </ScalarOperator>
                                                                                                                <ScalarOperator>
                                                                                                                  <Const ConstValue="(1)" />
                                                                                                                </ScalarOperator>
                                                                                                              </Compare>
                                                                                                            </ScalarOperator>
                                                                                                          </Condition>
                                                                                                          <Then>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="(0)" />
                                                                                                            </ScalarOperator>
                                                                                                          </Then>
                                                                                                          <Else>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="NULL" />
                                                                                                            </ScalarOperator>
                                                                                                          </Else>
                                                                                                        </IF>
                                                                                                      </ScalarOperator>
                                                                                                    </Predicate>
                                                                                                  </Assert>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="12" EstimateCPU="9.68074E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2.31597" LogicalOp="Inner Join" NodeId="68" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0336152">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1661" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="64" ActualCPUms="64" />
                                                                                                  </RunTimeInformation>
                                                                                                  <NestedLoops Optimized="false">
                                                                                                    <OuterReferences>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                    </OuterReferences>
                                                                                                    <RelOp AvgRowSize="11" EstimateCPU="1.14174E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2.31597" LogicalOp="Inner Join" NodeId="69" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0297499">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1661" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="57" ActualCPUms="57" />
                                                                                                      </RunTimeInformation>
                                                                                                      <NestedLoops Optimized="false">
                                                                                                        <OuterReferences>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                        </OuterReferences>
                                                                                                        <RelOp AvgRowSize="11" EstimateCPU="1.79232E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="2.73145" LogicalOp="Inner Join" NodeId="70" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.0246316">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1651" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="48" ActualCPUms="48" />
                                                                                                          </RunTimeInformation>
                                                                                                          <NestedLoops Optimized="false">
                                                                                                            <OuterReferences>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                            </OuterReferences>
                                                                                                            <RelOp AvgRowSize="11" EstimateCPU="2.24522E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="4.28785" LogicalOp="Inner Join" NodeId="71" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.015299">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1651" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="38" ActualCPUms="38" />
                                                                                                              </RunTimeInformation>
                                                                                                              <NestedLoops Optimized="false">
                                                                                                                <OuterReferences>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                </OuterReferences>
                                                                                                                <RelOp AvgRowSize="15" EstimateCPU="0.000162908" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="5.37135" EstimatedRowsRead="5.37135" LogicalOp="Index Seek" NodeId="72" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.00328791" TableCardinality="815317">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1650" ActualRowsRead="1650" Batches="0" ActualEndOfScans="13975" ActualExecutions="15610" ActualExecutionMode="Row" ActualElapsedms="31" ActualCPUms="31" ActualScans="15610" ActualLogicalReads="46919" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Index="[nci_wi_hm_NodelinkPublished_5F8B028DA52242978B1328A7FE61B227]" Alias="[n]" TableReferenceId="1" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                    <SeekPredicates>
                                                                                                                      <SeekPredicateNew>
                                                                                                                        <SeekKeys>
                                                                                                                          <Prefix ScanType="EQ">
                                                                                                                            <RangeColumns>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idTree" />
                                                                                                                            </RangeColumns>
                                                                                                                            <RangeExpressions>
                                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_BonusApproval].[idPayee] as [pba].[idPayee]">
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator ScalarString="(4)">
                                                                                                                                <Const ConstValue="(4)" />
                                                                                                                              </ScalarOperator>
                                                                                                                            </RangeExpressions>
                                                                                                                          </Prefix>
                                                                                                                        </SeekKeys>
                                                                                                                      </SeekPredicateNew>
                                                                                                                    </SeekPredicates>
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                                <RelOp AvgRowSize="11" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="4.37135" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="73" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.0119887" TableCardinality="126858">
                                                                                                                  <OutputList />
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1651" ActualRowsRead="1651" Batches="0" ActualEndOfScans="15" ActualExecutions="1650" ActualExecutionMode="Row" ActualElapsedms="5" ActualCPUms="5" ActualScans="1650" ActualLogicalReads="4979" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues />
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Index="[IX__PEPSICO_Process_BonusApproval__idPayee_start_date_histo]" Alias="[pba]" TableReferenceId="1" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                    <SeekPredicates>
                                                                                                                      <SeekPredicateNew>
                                                                                                                        <SeekKeys>
                                                                                                                          <Prefix ScanType="EQ">
                                                                                                                            <RangeColumns>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_BonusApproval]" Alias="[pba]" Column="idPayee" />
                                                                                                                            </RangeColumns>
                                                                                                                            <RangeExpressions>
                                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idChild] as [n].[idChild]">
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                            </RangeExpressions>
                                                                                                                          </Prefix>
                                                                                                                        </SeekKeys>
                                                                                                                      </SeekPredicateNew>
                                                                                                                    </SeekPredicates>
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                              </NestedLoops>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="24" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="2.76315" EstimateRewinds="0.524694" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Clustered Index Seek" NodeId="74" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.00931257" TableCardinality="1614300">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1651" ActualRowsRead="1651" Batches="0" ActualEndOfScans="0" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="6" ActualCPUms="6" ActualScans="0" ActualLogicalReads="4953" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                <DefinedValues />
                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Index="[PK_k_collaborateurs]" Alias="[py]" TableReferenceId="1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                <SeekPredicates>
                                                                                                                  <SeekPredicateNew>
                                                                                                                    <SeekKeys>
                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                        <RangeColumns>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                        </RangeColumns>
                                                                                                                        <RangeExpressions>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idChild] as [n].[idChild]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                        </RangeExpressions>
                                                                                                                      </Prefix>
                                                                                                                    </SeekKeys>
                                                                                                                  </SeekPredicateNew>
                                                                                                                </SeekPredicates>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[py_Payee].[ss_nb] as [py].[ss_nb]=N'payee'">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="ss_nb" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Const ConstValue="N'payee'" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </IndexScan>
                                                                                                            </RelOp>
                                                                                                          </NestedLoops>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="11" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="1.20675" EstimateRewinds="0.524692" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="75" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.00510694" TableCardinality="738293">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1661" ActualRowsRead="1661" Batches="0" ActualEndOfScans="16" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="6" ActualCPUms="6" ActualScans="1651" ActualLogicalReads="4963" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Index="[IX_k_m_plans_payees_steps_idPayee]" Alias="[pps]" TableReferenceId="1" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                            <SeekPredicates>
                                                                                                              <SeekPredicateNew>
                                                                                                                <SeekKeys>
                                                                                                                  <Prefix ScanType="EQ">
                                                                                                                    <RangeColumns>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_plan" />
                                                                                                                    </RangeColumns>
                                                                                                                    <RangeExpressions>
                                                                                                                      <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idChild] as [n].[idChild]">
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator ScalarString="(3)">
                                                                                                                        <Const ConstValue="(3)" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </RangeExpressions>
                                                                                                                  </Prefix>
                                                                                                                  <StartRange ScanType="GT">
                                                                                                                    <RangeColumns>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="start_step" />
                                                                                                                    </RangeColumns>
                                                                                                                    <RangeExpressions>
                                                                                                                      <ScalarOperator ScalarString="'2000-01-01 00:00:00.000'">
                                                                                                                        <Const ConstValue="'2000-01-01 00:00:00.000'" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </RangeExpressions>
                                                                                                                  </StartRange>
                                                                                                                </SeekKeys>
                                                                                                              </SeekPredicateNew>
                                                                                                            </SeekPredicates>
                                                                                                          </IndexScan>
                                                                                                        </RelOp>
                                                                                                      </NestedLoops>
                                                                                                    </RelOp>
                                                                                                    <RelOp AvgRowSize="9" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0.253838" EstimateRewinds="1.06213" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="77" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.00385564" TableCardinality="738293">
                                                                                                      <OutputList />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1661" ActualRowsRead="1661" Batches="0" ActualEndOfScans="0" ActualExecutions="1661" ActualExecutionMode="Row" ActualElapsedms="4" ActualCPUms="4" ActualScans="0" ActualLogicalReads="4983" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                        <DefinedValues />
                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Index="[PK_k_m_plans_payees_steps]" Alias="[pps]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                        <SeekPredicates>
                                                                                                          <SeekPredicateNew>
                                                                                                            <SeekKeys>
                                                                                                              <Prefix ScanType="EQ">
                                                                                                                <RangeColumns>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                </RangeColumns>
                                                                                                                <RangeExpressions>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                </RangeExpressions>
                                                                                                              </Prefix>
                                                                                                            </SeekKeys>
                                                                                                          </SeekPredicateNew>
                                                                                                        </SeekPredicates>
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_plans_payees_steps].[locked] as [pps].[locked]=(0)">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="locked" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Const ConstValue="(0)" />
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </IndexScan>
                                                                                                    </RelOp>
                                                                                                  </NestedLoops>
                                                                                                </RelOp>
                                                                                              </NestedLoops>
                                                                                            </RelOp>
                                                                                          </NestedLoops>
                                                                                        </RelOp>
                                                                                        <RelOp AvgRowSize="9" EstimateCPU="4.80008E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="1.31597" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="78" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.00699311">
                                                                                          <OutputList />
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="0" ActualEndOfScans="15" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="13" ActualCPUms="13" />
                                                                                          </RunTimeInformation>
                                                                                          <Filter StartupExpression="false">
                                                                                            <RelOp AvgRowSize="91" EstimateCPU="4.18007E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="1.31597" EstimatedExecutionMode="Row" EstimateRows="1.00002" LogicalOp="Inner Join" NodeId="79" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.006992">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="input_value" />
                                                                                              </OutputList>
                                                                                              <MemoryFractions Input="0" Output="0.000449512" />
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1651" Batches="0" ActualEndOfScans="15" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="12" ActualCPUms="12" InputMemoryGrant="0" OutputMemoryGrant="1480" UsedMemoryGrant="0" />
                                                                                              </RunTimeInformation>
                                                                                              <NestedLoops Optimized="true">
                                                                                                <OuterReferences>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_value" />
                                                                                                </OuterReferences>
                                                                                                <RelOp AvgRowSize="15" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="1.31597" EstimatedExecutionMode="Row" EstimateRows="1.00002" EstimatedRowsRead="1.00002" LogicalOp="Index Seek" NodeId="81" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.00349115" TableCardinality="7408150">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_value" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1651" ActualRowsRead="1651" Batches="0" ActualEndOfScans="15" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="5" ActualCPUms="5" ActualScans="1651" ActualLogicalReads="4959" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                    <DefinedValues>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_value" />
                                                                                                      </DefinedValue>
                                                                                                    </DefinedValues>
                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[UQ_k_m_values]" Alias="[team_value]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                    <SeekPredicates>
                                                                                                      <SeekPredicateNew>
                                                                                                        <SeekKeys>
                                                                                                          <Prefix ScanType="EQ">
                                                                                                            <RangeColumns>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_field" />
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_step" />
                                                                                                            </RangeColumns>
                                                                                                            <RangeExpressions>
                                                                                                              <ScalarOperator ScalarString="[Expr1411]">
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Column="Expr1411" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                            </RangeExpressions>
                                                                                                          </Prefix>
                                                                                                        </SeekKeys>
                                                                                                      </SeekPredicateNew>
                                                                                                    </SeekPredicates>
                                                                                                  </IndexScan>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="4035" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="1.31601" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="83" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.00349116" TableCardinality="7408150">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="input_value" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1651" ActualRowsRead="1651" Batches="0" ActualEndOfScans="0" ActualExecutions="1651" ActualExecutionMode="Row" ActualElapsedms="5" ActualCPUms="5" ActualScans="0" ActualLogicalReads="6604" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                    <DefinedValues>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="input_value" />
                                                                                                      </DefinedValue>
                                                                                                    </DefinedValues>
                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[PK_k_m_values]" Alias="[team_value]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                    <SeekPredicates>
                                                                                                      <SeekPredicateNew>
                                                                                                        <SeekKeys>
                                                                                                          <Prefix ScanType="EQ">
                                                                                                            <RangeColumns>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_value" />
                                                                                                            </RangeColumns>
                                                                                                            <RangeExpressions>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[id_value] as [team_value].[id_value]">
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="id_value" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                            </RangeExpressions>
                                                                                                          </Prefix>
                                                                                                        </SeekKeys>
                                                                                                      </SeekPredicateNew>
                                                                                                    </SeekPredicates>
                                                                                                  </IndexScan>
                                                                                                </RelOp>
                                                                                              </NestedLoops>
                                                                                            </RelOp>
                                                                                            <Predicate>
                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[input_value] as [team_value].[input_value]=N'SELECT'">
                                                                                                <Compare CompareOp="EQ">
                                                                                                  <ScalarOperator>
                                                                                                    <Identifier>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[team_value]" Column="input_value" />
                                                                                                    </Identifier>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Const ConstValue="N'SELECT'" />
                                                                                                  </ScalarOperator>
                                                                                                </Compare>
                                                                                              </ScalarOperator>
                                                                                            </Predicate>
                                                                                          </Filter>
                                                                                        </RelOp>
                                                                                      </NestedLoops>
                                                                                    </RelOp>
                                                                                    <RelOp AvgRowSize="9" EstimateCPU="8.80015E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="84" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.00657126">
                                                                                      <OutputList />
                                                                                      <RunTimeInformation>
                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="0" ActualEndOfScans="0" ActualExecutions="1636" ActualExecutionMode="Row" ActualElapsedms="11" ActualCPUms="11" />
                                                                                      </RunTimeInformation>
                                                                                      <Filter StartupExpression="false">
                                                                                        <RelOp AvgRowSize="4035" EstimateCPU="4.18007E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1.00002" LogicalOp="Inner Join" NodeId="85" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.00657038">
                                                                                          <OutputList>
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="input_value" />
                                                                                          </OutputList>
                                                                                          <MemoryFractions Input="0" Output="0.000449512" />
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1636" Batches="0" ActualEndOfScans="0" ActualExecutions="1636" ActualExecutionMode="Row" ActualElapsedms="10" ActualCPUms="10" InputMemoryGrant="0" OutputMemoryGrant="1480" UsedMemoryGrant="0" />
                                                                                          </RunTimeInformation>
                                                                                          <NestedLoops Optimized="true">
                                                                                            <OuterReferences>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_value" />
                                                                                            </OuterReferences>
                                                                                            <RelOp AvgRowSize="15" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1.00002" EstimatedRowsRead="1.00002" LogicalOp="Index Seek" NodeId="87" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="7408150">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_value" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1636" ActualRowsRead="1636" Batches="0" ActualEndOfScans="0" ActualExecutions="1636" ActualExecutionMode="Row" ActualElapsedms="5" ActualCPUms="5" ActualScans="1636" ActualLogicalReads="4921" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                              </RunTimeInformation>
                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                <DefinedValues>
                                                                                                  <DefinedValue>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_value" />
                                                                                                  </DefinedValue>
                                                                                                </DefinedValues>
                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[UQ_k_m_values]" Alias="[status_value]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                <SeekPredicates>
                                                                                                  <SeekPredicateNew>
                                                                                                    <SeekKeys>
                                                                                                      <Prefix ScanType="EQ">
                                                                                                        <RangeColumns>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_field" />
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_step" />
                                                                                                        </RangeColumns>
                                                                                                        <RangeExpressions>
                                                                                                          <ScalarOperator ScalarString="[Expr1413]">
                                                                                                            <Identifier>
                                                                                                              <ColumnReference Column="Expr1413" />
                                                                                                            </Identifier>
                                                                                                          </ScalarOperator>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                            <Identifier>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                            </Identifier>
                                                                                                          </ScalarOperator>
                                                                                                        </RangeExpressions>
                                                                                                      </Prefix>
                                                                                                    </SeekKeys>
                                                                                                  </SeekPredicateNew>
                                                                                                </SeekPredicates>
                                                                                              </IndexScan>
                                                                                            </RelOp>
                                                                                            <RelOp AvgRowSize="4035" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="1.68683E-05" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="89" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="7408150">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="input_value" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1636" ActualRowsRead="1636" Batches="0" ActualEndOfScans="0" ActualExecutions="1636" ActualExecutionMode="Row" ActualElapsedms="4" ActualCPUms="4" ActualScans="0" ActualLogicalReads="6544" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                              </RunTimeInformation>
                                                                                              <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                <DefinedValues>
                                                                                                  <DefinedValue>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="input_value" />
                                                                                                  </DefinedValue>
                                                                                                </DefinedValues>
                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[PK_k_m_values]" Alias="[status_value]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                <SeekPredicates>
                                                                                                  <SeekPredicateNew>
                                                                                                    <SeekKeys>
                                                                                                      <Prefix ScanType="EQ">
                                                                                                        <RangeColumns>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_value" />
                                                                                                        </RangeColumns>
                                                                                                        <RangeExpressions>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[id_value] as [status_value].[id_value]">
                                                                                                            <Identifier>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="id_value" />
                                                                                                            </Identifier>
                                                                                                          </ScalarOperator>
                                                                                                        </RangeExpressions>
                                                                                                      </Prefix>
                                                                                                    </SeekKeys>
                                                                                                  </SeekPredicateNew>
                                                                                                </SeekPredicates>
                                                                                              </IndexScan>
                                                                                            </RelOp>
                                                                                          </NestedLoops>
                                                                                        </RelOp>
                                                                                        <Predicate>
                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[input_value] as [status_value].[input_value]=N'PREASSIGNED' OR [peptest].[dbo].[k_m_values].[input_value] as [status_value].[input_value]=N'REOPENED'">
                                                                                            <Logical Operation="OR">
                                                                                              <ScalarOperator>
                                                                                                <Compare CompareOp="EQ">
                                                                                                  <ScalarOperator>
                                                                                                    <Identifier>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="input_value" />
                                                                                                    </Identifier>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Const ConstValue="N'PREASSIGNED'" />
                                                                                                  </ScalarOperator>
                                                                                                </Compare>
                                                                                              </ScalarOperator>
                                                                                              <ScalarOperator>
                                                                                                <Compare CompareOp="EQ">
                                                                                                  <ScalarOperator>
                                                                                                    <Identifier>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[status_value]" Column="input_value" />
                                                                                                    </Identifier>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Const ConstValue="N'REOPENED'" />
                                                                                                  </ScalarOperator>
                                                                                                </Compare>
                                                                                              </ScalarOperator>
                                                                                            </Logical>
                                                                                          </ScalarOperator>
                                                                                        </Predicate>
                                                                                      </Filter>
                                                                                    </RelOp>
                                                                                  </NestedLoops>
                                                                                </RelOp>
                                                                              </NestedLoops>
                                                                            </RelOp>
                                                                            <RelOp AvgRowSize="567" EstimateCPU="0.00937302" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="44.3654" LogicalOp="Inner Join" NodeId="91" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="788.834">
                                                                              <OutputList>
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                              </OutputList>
                                                                              <MemoryFractions Input="0.00770444" Output="0.00770444" />
                                                                              <RunTimeInformation>
                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1396" Batches="10" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="2" ActualCPUms="2" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                              </RunTimeInformation>
                                                                              <Hash BitmapCreator="true">
                                                                                <DefinedValues>
                                                                                  <DefinedValue>
                                                                                    <ColumnReference Column="Opt_Bitmap2247" />
                                                                                  </DefinedValue>
                                                                                </DefinedValues>
                                                                                <HashKeysBuild>
                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                </HashKeysBuild>
                                                                                <HashKeysProbe>
                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                </HashKeysProbe>
                                                                                <ProbeResidual>
                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idParent] as [n].[idParent]=[peptest].[dbo].[PEPSICO_Process_FocalPoint].[idPayee] as [pfp].[idPayee]">
                                                                                    <Compare CompareOp="EQ">
                                                                                      <ScalarOperator>
                                                                                        <Identifier>
                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                        </Identifier>
                                                                                      </ScalarOperator>
                                                                                      <ScalarOperator>
                                                                                        <Identifier>
                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                        </Identifier>
                                                                                      </ScalarOperator>
                                                                                    </Compare>
                                                                                  </ScalarOperator>
                                                                                </ProbeResidual>
                                                                                <RelOp AvgRowSize="11" EstimateCPU="0.276649" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="45.1105" LogicalOp="Aggregate" NodeId="92" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="27.4101">
                                                                                  <OutputList>
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                  </OutputList>
                                                                                  <MemoryFractions Input="0.00768223" Output="0.00768223" />
                                                                                  <RunTimeInformation>
                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="21673" Batches="25" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="9" ActualCPUms="9" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                  </RunTimeInformation>
                                                                                  <Hash>
                                                                                    <DefinedValues />
                                                                                    <HashKeysBuild>
                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                    </HashKeysBuild>
                                                                                    <BuildResidual>
                                                                                      <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idParent] as [n].[idParent] = [peptest].[dbo].[hm_NodelinkPublished].[idParent] as [n].[idParent]">
                                                                                        <Compare CompareOp="IS">
                                                                                          <ScalarOperator>
                                                                                            <Identifier>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                            </Identifier>
                                                                                          </ScalarOperator>
                                                                                          <ScalarOperator>
                                                                                            <Identifier>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                            </Identifier>
                                                                                          </ScalarOperator>
                                                                                        </Compare>
                                                                                      </ScalarOperator>
                                                                                    </BuildResidual>
                                                                                    <RelOp AvgRowSize="11" EstimateCPU="0.124043" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="84547.4" LogicalOp="Filter" NodeId="93" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="27.1335">
                                                                                      <OutputList>
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                      </OutputList>
                                                                                      <RunTimeInformation>
                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="105277" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="1" ActualCPUms="1" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                      </RunTimeInformation>
                                                                                      <Filter StartupExpression="false">
                                                                                        <RelOp AvgRowSize="45" EstimateCPU="0.820799" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="86141.3" LogicalOp="Right Outer Join" NodeId="94" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="27.0094">
                                                                                          <OutputList>
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="input_value_numeric" />
                                                                                          </OutputList>
                                                                                          <MemoryFractions Input="0.00766371" Output="0.00766371" />
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="2" ActualCPUms="2" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                          </RunTimeInformation>
                                                                                          <Hash>
                                                                                            <DefinedValues />
                                                                                            <HashKeysBuild>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_step" />
                                                                                            </HashKeysBuild>
                                                                                            <HashKeysProbe>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                            </HashKeysProbe>
                                                                                            <ProbeResidual>
                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[id_step] as [kmv_ic_score].[id_step]=[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                <Compare CompareOp="EQ">
                                                                                                  <ScalarOperator>
                                                                                                    <Identifier>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_step" />
                                                                                                    </Identifier>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Identifier>
                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                    </Identifier>
                                                                                                  </ScalarOperator>
                                                                                                </Compare>
                                                                                              </ScalarOperator>
                                                                                            </ProbeResidual>
                                                                                            <RelOp AvgRowSize="20" EstimateCPU="0.36007" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86141.3" LogicalOp="Inner Join" NodeId="95" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.845304">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_step" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="input_value_numeric" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="17" Batches="1" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                              </RunTimeInformation>
                                                                                              <NestedLoops Optimized="false">
                                                                                                <OuterReferences>
                                                                                                  <ColumnReference Column="Expr1419" />
                                                                                                </OuterReferences>
                                                                                                <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="96" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.00867733">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Column="Expr1419" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Assert StartupExpression="false">
                                                                                                    <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="97" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00867685">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Column="Expr1418" />
                                                                                                        <ColumnReference Column="Expr1419" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <StreamAggregate>
                                                                                                        <DefinedValues>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Column="Expr1418" />
                                                                                                            <ScalarOperator ScalarString="Count(*)">
                                                                                                              <Aggregate AggType="countstar" Distinct="false" />
                                                                                                            </ScalarOperator>
                                                                                                          </DefinedValue>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Column="Expr1419" />
                                                                                                            <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_m_fields].[id_field])">
                                                                                                              <Aggregate AggType="ANY" Distinct="false">
                                                                                                                <ScalarOperator>
                                                                                                                  <Identifier>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                  </Identifier>
                                                                                                                </ScalarOperator>
                                                                                                              </Aggregate>
                                                                                                            </ScalarOperator>
                                                                                                          </DefinedValue>
                                                                                                        </DefinedValues>
                                                                                                        <RelOp AvgRowSize="270" EstimateCPU="0.0003022" EstimateIO="0.00831019" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="132" LogicalOp="Clustered Index Scan" NodeId="98" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00861239" TableCardinality="132">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="132" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="10" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Index="[PK_k_m_fields]" TableReferenceId="5" IndexKind="Clustered" Storage="RowStore" />
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_m_fields].[code_field]=N'ic_score'">
                                                                                                                <Compare CompareOp="EQ">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="code_field" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Const ConstValue="N'ic_score'" />
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </IndexScan>
                                                                                                        </RelOp>
                                                                                                      </StreamAggregate>
                                                                                                    </RelOp>
                                                                                                    <Predicate>
                                                                                                      <ScalarOperator ScalarString="CASE WHEN [Expr1418]&gt;(1) THEN (0) ELSE NULL END">
                                                                                                        <IF>
                                                                                                          <Condition>
                                                                                                            <ScalarOperator>
                                                                                                              <Compare CompareOp="GT">
                                                                                                                <ScalarOperator>
                                                                                                                  <Identifier>
                                                                                                                    <ColumnReference Column="Expr1418" />
                                                                                                                  </Identifier>
                                                                                                                </ScalarOperator>
                                                                                                                <ScalarOperator>
                                                                                                                  <Const ConstValue="(1)" />
                                                                                                                </ScalarOperator>
                                                                                                              </Compare>
                                                                                                            </ScalarOperator>
                                                                                                          </Condition>
                                                                                                          <Then>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="(0)" />
                                                                                                            </ScalarOperator>
                                                                                                          </Then>
                                                                                                          <Else>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="NULL" />
                                                                                                            </ScalarOperator>
                                                                                                          </Else>
                                                                                                        </IF>
                                                                                                      </ScalarOperator>
                                                                                                    </Predicate>
                                                                                                  </Assert>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="20" EstimateCPU="0.0949124" EstimateIO="0.381644" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86141.3" EstimatedRowsRead="86141.3" LogicalOp="Index Seek" NodeId="99" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.476556" TableCardinality="7408150">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_step" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="input_value_numeric" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="17" ActualRowsRead="17" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="6" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                    <DefinedValues>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_step" />
                                                                                                      </DefinedValue>
                                                                                                      <DefinedValue>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="input_value_numeric" />
                                                                                                      </DefinedValue>
                                                                                                    </DefinedValues>
                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[nci_k_m_values_idfield]" Alias="[kmv_ic_score]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                    <SeekPredicates>
                                                                                                      <SeekPredicateNew>
                                                                                                        <SeekKeys>
                                                                                                          <Prefix ScanType="EQ">
                                                                                                            <RangeColumns>
                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="id_field" />
                                                                                                            </RangeColumns>
                                                                                                            <RangeExpressions>
                                                                                                              <ScalarOperator ScalarString="[Expr1419]">
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Column="Expr1419" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                            </RangeExpressions>
                                                                                                          </Prefix>
                                                                                                        </SeekKeys>
                                                                                                      </SeekPredicateNew>
                                                                                                    </SeekPredicates>
                                                                                                  </IndexScan>
                                                                                                </RelOp>
                                                                                              </NestedLoops>
                                                                                            </RelOp>
                                                                                            <RelOp AvgRowSize="40" EstimateCPU="0.0948514" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86141.3" LogicalOp="Left Outer Join" NodeId="100" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="25.1879">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="2999" ActualCPUms="2999" />
                                                                                              </RunTimeInformation>
                                                                                              <NestedLoops Optimized="false">
                                                                                                <OuterReferences>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                </OuterReferences>
                                                                                                <RelOp AvgRowSize="36" EstimateCPU="0.753655" EstimateIO="0.00375375" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="22691.7" LogicalOp="Sort" NodeId="101" Parallel="false" PhysicalOp="Sort" EstimatedTotalSubtreeCost="17.7853">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                  </OutputList>
                                                                                                  <MemoryFractions Input="0.04713" Output="0.04713" />
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="22" ActualCPUms="22" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Sort Distinct="false">
                                                                                                    <OrderBy>
                                                                                                      <OrderByColumn Ascending="true">
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                      </OrderByColumn>
                                                                                                    </OrderBy>
                                                                                                    <RelOp AvgRowSize="36" EstimateCPU="0.207018" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="22691.7" LogicalOp="Left Outer Join" NodeId="102" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="17.0279">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                      </OutputList>
                                                                                                      <MemoryFractions Input="0.0163233" Output="0.0163233" />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="125" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="13" ActualCPUms="13" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <Hash BitmapCreator="true">
                                                                                                        <DefinedValues>
                                                                                                          <DefinedValue>
                                                                                                            <ColumnReference Column="Opt_Bitmap2223" />
                                                                                                          </DefinedValue>
                                                                                                        </DefinedValues>
                                                                                                        <HashKeysBuild>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                        </HashKeysBuild>
                                                                                                        <HashKeysProbe>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                        </HashKeysProbe>
                                                                                                        <ProbeResidual>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[id_step] as [kmv_merit].[id_step]=[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </ProbeResidual>
                                                                                                        <RelOp AvgRowSize="27" EstimateCPU="0.0103999" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="21666.5" LogicalOp="Filter" NodeId="103" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="15.9755">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="121" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Filter StartupExpression="false">
                                                                                                            <RelOp AvgRowSize="31" EstimateCPU="0.124626" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="43333" LogicalOp="Right Outer Join" NodeId="104" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="15.9651">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="id" />
                                                                                                              </OutputList>
                                                                                                              <MemoryFractions Input="0.0150053" Output="0.0150053" />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="121" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="9" ActualCPUms="9" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Hash>
                                                                                                                <DefinedValues />
                                                                                                                <HashKeysBuild>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="GPID" />
                                                                                                                </HashKeysBuild>
                                                                                                                <HashKeysProbe>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                </HashKeysProbe>
                                                                                                                <ProbeResidual>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_FocalPoint].[gpid] as [pfp].[gpid]=[peptest].[dbo].[PEPSICO_FocalPoint_Budget_Exclude].[GPID] as [be].[GPID]">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="GPID" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </ProbeResidual>
                                                                                                                <RelOp AvgRowSize="115" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Scan" NodeId="105" Parallel="false" PhysicalOp="Index Scan" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="0">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="id" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="GPID" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="id" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="GPID" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Index="[UK_PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                                <RelOp AvgRowSize="47" EstimateCPU="0.456105" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="43333.6" LogicalOp="Inner Join" NodeId="106" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="15.8372">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                  </OutputList>
                                                                                                                  <MemoryFractions Input="0.0149313" Output="0.0149313" />
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="121" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="13" ActualCPUms="12" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <Hash BitmapCreator="true">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Opt_Bitmap2207" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <HashKeysBuild>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                    </HashKeysBuild>
                                                                                                                    <HashKeysProbe>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                    </HashKeysProbe>
                                                                                                                    <RelOp AvgRowSize="19" EstimateCPU="0.473887" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="59418.5" LogicalOp="Inner Join" NodeId="107" Parallel="false" PhysicalOp="Hash Match" EstimatedTotalSubtreeCost="12.3436">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                      </OutputList>
                                                                                                                      <MemoryFractions Input="0.011925" Output="0.011925" />
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="105297" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="10" ActualCPUms="10" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <Hash BitmapCreator="true">
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Column="Opt_Bitmap2157" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <HashKeysBuild>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                        </HashKeysBuild>
                                                                                                                        <HashKeysProbe>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                        </HashKeysProbe>
                                                                                                                        <RelOp AvgRowSize="15" EstimateCPU="0.0067218" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="67218" LogicalOp="Inner Join" NodeId="108" Parallel="false" PhysicalOp="Adaptive Join" IsAdaptive="true" AdaptiveThresholdRows="7169.01" EstimatedTotalSubtreeCost="10.7215" EstimatedJoinType="Hash Match">
                                                                                                                          <OutputList>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                          </OutputList>
                                                                                                                          <RunTimeInformation>
                                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="105373" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" ActualJoinType="Hash Match" />
                                                                                                                          </RunTimeInformation>
                                                                                                                          <AdaptiveJoin BitmapCreator="true" Optimized="false">
                                                                                                                            <DefinedValues>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Column="Opt_Bitmap2154" />
                                                                                                                              </DefinedValue>
                                                                                                                            </DefinedValues>
                                                                                                                            <HashKeysBuild>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                            </HashKeysBuild>
                                                                                                                            <HashKeysProbe>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                            </HashKeysProbe>
                                                                                                                            <OuterReferences>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                            </OuterReferences>
                                                                                                                            <RelOp AvgRowSize="15" EstimateCPU="0.116228" EstimateIO="1.62379" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="105519" EstimatedRowsRead="105519" LogicalOp="Index Seek" NodeId="110" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="1.74002" TableCardinality="815317">
                                                                                                                              <OutputList>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                              </OutputList>
                                                                                                                              <RunTimeInformation>
                                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105374" ActualRowsRead="105374" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="21" ActualCPUms="21" ActualScans="1" ActualLogicalReads="2902" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                              </RunTimeInformation>
                                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                                <DefinedValues>
                                                                                                                                  <DefinedValue>
                                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                  </DefinedValue>
                                                                                                                                  <DefinedValue>
                                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idParent" />
                                                                                                                                  </DefinedValue>
                                                                                                                                </DefinedValues>
                                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Index="[nci_wi_hm_NodelinkPublished_EEE77BB266B1AC930775A2597DB8ED3C]" Alias="[n]" TableReferenceId="2" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                                <SeekPredicates>
                                                                                                                                  <SeekPredicateNew>
                                                                                                                                    <SeekKeys>
                                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                                        <RangeColumns>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idTree" />
                                                                                                                                        </RangeColumns>
                                                                                                                                        <RangeExpressions>
                                                                                                                                          <ScalarOperator ScalarString="(1)">
                                                                                                                                            <Const ConstValue="(1)" />
                                                                                                                                          </ScalarOperator>
                                                                                                                                        </RangeExpressions>
                                                                                                                                      </Prefix>
                                                                                                                                    </SeekKeys>
                                                                                                                                  </SeekPredicateNew>
                                                                                                                                </SeekPredicates>
                                                                                                                              </IndexScan>
                                                                                                                            </RelOp>
                                                                                                                            <RelOp AvgRowSize="11" EstimateCPU="1.1303" EstimateIO="6.96101" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="102834" EstimatedRowsRead="1028340" LogicalOp="Index Seek" NodeId="112" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="8.09131" TableCardinality="1614300">
                                                                                                                              <OutputList>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                              </OutputList>
                                                                                                                              <RunTimeInformation>
                                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105373" ActualRowsRead="1044757" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="110" ActualCPUms="110" ActualScans="1" ActualLogicalReads="9119" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                              </RunTimeInformation>
                                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                                <DefinedValues>
                                                                                                                                  <DefinedValue>
                                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                                  </DefinedValue>
                                                                                                                                </DefinedValues>
                                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Index="[nci_wi_py_Payee_5932390CCAA29A71A8CEEC12A50FAA15]" Alias="[py]" TableReferenceId="2" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                                <SeekPredicates>
                                                                                                                                  <SeekPredicateNew>
                                                                                                                                    <SeekKeys>
                                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                                        <RangeColumns>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="ss_nb" />
                                                                                                                                        </RangeColumns>
                                                                                                                                        <RangeExpressions>
                                                                                                                                          <ScalarOperator ScalarString="N'payee'">
                                                                                                                                            <Const ConstValue="N'payee'" />
                                                                                                                                          </ScalarOperator>
                                                                                                                                        </RangeExpressions>
                                                                                                                                      </Prefix>
                                                                                                                                    </SeekKeys>
                                                                                                                                  </SeekPredicateNew>
                                                                                                                                </SeekPredicates>
                                                                                                                                <Predicate>
                                                                                                                                  <ScalarOperator ScalarString="PROBE([Opt_Bitmap2154],[peptest].[dbo].[py_Payee].[idPayee] as [py].[idPayee])">
                                                                                                                                    <Intrinsic FunctionName="PROBE">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Column="Opt_Bitmap2154" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Intrinsic>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Predicate>
                                                                                                                              </IndexScan>
                                                                                                                            </RelOp>
                                                                                                                            <RelOp AvgRowSize="61" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="105518" EstimateRewinds="0.321644" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Clustered Index Seek" NodeId="115" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="122.803" TableCardinality="1614300">
                                                                                                                              <OutputList />
                                                                                                                              <RunTimeInformation>
                                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                              </RunTimeInformation>
                                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                                <DefinedValues />
                                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Index="[PK_k_collaborateurs]" Alias="[py]" TableReferenceId="2" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                                <SeekPredicates>
                                                                                                                                  <SeekPredicateNew>
                                                                                                                                    <SeekKeys>
                                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                                        <RangeColumns>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="idPayee" />
                                                                                                                                        </RangeColumns>
                                                                                                                                        <RangeExpressions>
                                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[hm_NodelinkPublished].[idChild] as [n].[idChild]">
                                                                                                                                            <Identifier>
                                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[hm_NodelinkPublished]" Alias="[n]" Column="idChild" />
                                                                                                                                            </Identifier>
                                                                                                                                          </ScalarOperator>
                                                                                                                                        </RangeExpressions>
                                                                                                                                      </Prefix>
                                                                                                                                    </SeekKeys>
                                                                                                                                  </SeekPredicateNew>
                                                                                                                                </SeekPredicates>
                                                                                                                                <Predicate>
                                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[py_Payee].[ss_nb] as [py].[ss_nb]=N'payee'">
                                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[py]" Column="ss_nb" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Const ConstValue="N'payee'" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Predicate>
                                                                                                                              </IndexScan>
                                                                                                                            </RelOp>
                                                                                                                          </AdaptiveJoin>
                                                                                                                        </RelOp>
                                                                                                                        <RelOp AvgRowSize="15" EstimateCPU="0.230863" EstimateIO="0.924055" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="20992.3" EstimatedRowsRead="209923" LogicalOp="Index Seek" NodeId="117" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="1.15492" TableCardinality="738293">
                                                                                                                          <OutputList>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                          </OutputList>
                                                                                                                          <RunTimeInformation>
                                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="105297" ActualRowsRead="115770" Batches="119" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="24" ActualCPUms="24" ActualScans="1" ActualLogicalReads="972" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                          </RunTimeInformation>
                                                                                                                          <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                            <DefinedValues>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                              </DefinedValue>
                                                                                                                            </DefinedValues>
                                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Index="[IX_k_m_plans_payees_steps_plan_locked_start]" Alias="[pps]" TableReferenceId="2" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                            <SeekPredicates>
                                                                                                                              <SeekPredicateNew>
                                                                                                                                <SeekKeys>
                                                                                                                                  <Prefix ScanType="EQ">
                                                                                                                                    <RangeColumns>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_plan" />
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="locked" />
                                                                                                                                    </RangeColumns>
                                                                                                                                    <RangeExpressions>
                                                                                                                                      <ScalarOperator ScalarString="(1)">
                                                                                                                                        <Const ConstValue="(1)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator ScalarString="(0)">
                                                                                                                                        <Const ConstValue="(0)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </RangeExpressions>
                                                                                                                                  </Prefix>
                                                                                                                                  <StartRange ScanType="GT">
                                                                                                                                    <RangeColumns>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="start_step" />
                                                                                                                                    </RangeColumns>
                                                                                                                                    <RangeExpressions>
                                                                                                                                      <ScalarOperator ScalarString="'2000-01-01 00:00:00.000'">
                                                                                                                                        <Const ConstValue="'2000-01-01 00:00:00.000'" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </RangeExpressions>
                                                                                                                                  </StartRange>
                                                                                                                                </SeekKeys>
                                                                                                                              </SeekPredicateNew>
                                                                                                                            </SeekPredicates>
                                                                                                                            <Predicate>
                                                                                                                              <ScalarOperator ScalarString="PROBE([Opt_Bitmap2157],[peptest].[dbo].[k_m_plans_payees_steps].[id_payee] as [pps].[id_payee])">
                                                                                                                                <Intrinsic FunctionName="PROBE">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Column="Opt_Bitmap2157" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_payee" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Intrinsic>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Predicate>
                                                                                                                          </IndexScan>
                                                                                                                        </RelOp>
                                                                                                                      </Hash>
                                                                                                                    </RelOp>
                                                                                                                    <RelOp AvgRowSize="43" EstimateCPU="0.127388" EstimateIO="2.7735" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="11577" EstimatedRowsRead="115770" LogicalOp="Index Scan" NodeId="119" Parallel="false" PhysicalOp="Index Scan" EstimatedTotalSubtreeCost="2.90088" TableCardinality="115770">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                                      </OutputList>
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="105294" ActualRowsRead="115770" Batches="121" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="37" ActualCPUms="37" ActualScans="1" ActualLogicalReads="3795" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                          </DefinedValue>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                          </DefinedValue>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                                          </DefinedValue>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                                          </DefinedValue>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Index="[IX_startdate_enddate]" Alias="[pfp]" TableReferenceId="1" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                        <Predicate>
                                                                                                                          <ScalarOperator ScalarString="([peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_eligible] as [pfp].[is_eligible]=(1) OR [peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_merit_eligible] as [pfp].[is_merit_eligible]=(1) OR [peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_sc_eligible] as [pfp].[is_sc_eligible]=(1)) AND PROBE([Opt_Bitmap2207],[peptest].[dbo].[PEPSICO_Process_FocalPoint].[idPayee] as [pfp].[idPayee])">
                                                                                                                            <Logical Operation="AND">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Logical Operation="OR">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Const ConstValue="(1)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Const ConstValue="(1)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Const ConstValue="(1)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Logical>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Intrinsic FunctionName="PROBE">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Column="Opt_Bitmap2207" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Intrinsic>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Logical>
                                                                                                                          </ScalarOperator>
                                                                                                                        </Predicate>
                                                                                                                      </IndexScan>
                                                                                                                    </RelOp>
                                                                                                                  </Hash>
                                                                                                                </RelOp>
                                                                                                              </Hash>
                                                                                                            </RelOp>
                                                                                                            <Predicate>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_FocalPoint_Budget_Exclude].[id] as [be].[id] IS NULL">
                                                                                                                <Compare CompareOp="IS">
                                                                                                                  <ScalarOperator>
                                                                                                                    <Identifier>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_Budget_Exclude]" Alias="[be]" Column="id" />
                                                                                                                    </Identifier>
                                                                                                                  </ScalarOperator>
                                                                                                                  <ScalarOperator>
                                                                                                                    <Const ConstValue="NULL" />
                                                                                                                  </ScalarOperator>
                                                                                                                </Compare>
                                                                                                              </ScalarOperator>
                                                                                                            </Predicate>
                                                                                                          </Filter>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="20" EstimateCPU="0.36007" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86.1413" LogicalOp="Inner Join" NodeId="120" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.845304">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="6486" Batches="8" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="3" ActualCPUms="3" />
                                                                                                          </RunTimeInformation>
                                                                                                          <NestedLoops Optimized="false">
                                                                                                            <OuterReferences>
                                                                                                              <ColumnReference Column="Expr1415" />
                                                                                                            </OuterReferences>
                                                                                                            <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="121" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.00867733">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Column="Expr1415" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Assert StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="122" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.00867685">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Column="Expr1414" />
                                                                                                                    <ColumnReference Column="Expr1415" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <StreamAggregate>
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1414" />
                                                                                                                        <ScalarOperator ScalarString="Count(*)">
                                                                                                                          <Aggregate AggType="countstar" Distinct="false" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1415" />
                                                                                                                        <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_m_fields].[id_field])">
                                                                                                                          <Aggregate AggType="ANY" Distinct="false">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                          </Aggregate>
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <RelOp AvgRowSize="270" EstimateCPU="0.0003022" EstimateIO="0.00831019" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="132" LogicalOp="Clustered Index Scan" NodeId="123" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.00861239" TableCardinality="132">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                      </OutputList>
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="132" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="10" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Index="[PK_k_m_fields]" TableReferenceId="3" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                        <Predicate>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_fields].[code_field]=N'merit_percent'">
                                                                                                                            <Compare CompareOp="EQ">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="code_field" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Const ConstValue="N'merit_percent'" />
                                                                                                                              </ScalarOperator>
                                                                                                                            </Compare>
                                                                                                                          </ScalarOperator>
                                                                                                                        </Predicate>
                                                                                                                      </IndexScan>
                                                                                                                    </RelOp>
                                                                                                                  </StreamAggregate>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="CASE WHEN [Expr1414]&gt;(1) THEN (0) ELSE NULL END">
                                                                                                                    <IF>
                                                                                                                      <Condition>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Compare CompareOp="GT">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Column="Expr1414" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                            <ScalarOperator>
                                                                                                                              <Const ConstValue="(1)" />
                                                                                                                            </ScalarOperator>
                                                                                                                          </Compare>
                                                                                                                        </ScalarOperator>
                                                                                                                      </Condition>
                                                                                                                      <Then>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Const ConstValue="(0)" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </Then>
                                                                                                                      <Else>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Const ConstValue="NULL" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </Else>
                                                                                                                    </IF>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Assert>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="20" EstimateCPU="0.0949124" EstimateIO="0.381644" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86141.3" LogicalOp="Filter" NodeId="124" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.476556">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="6486" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="2" ActualCPUms="2" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="20" EstimateCPU="0.0949124" EstimateIO="0.381644" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="86141.3" EstimatedRowsRead="86141.3" LogicalOp="Index Seek" NodeId="125" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.476556" TableCardinality="7408150">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="8376" ActualRowsRead="8376" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1" ActualCPUms="1" ActualScans="1" ActualLogicalReads="57" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[nci_k_m_values_idfield]" Alias="[kmv_merit]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                    <SeekPredicates>
                                                                                                                      <SeekPredicateNew>
                                                                                                                        <SeekKeys>
                                                                                                                          <Prefix ScanType="EQ">
                                                                                                                            <RangeColumns>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_field" />
                                                                                                                            </RangeColumns>
                                                                                                                            <RangeExpressions>
                                                                                                                              <ScalarOperator ScalarString="[Expr1415]">
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Column="Expr1415" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                            </RangeExpressions>
                                                                                                                          </Prefix>
                                                                                                                        </SeekKeys>
                                                                                                                      </SeekPredicateNew>
                                                                                                                    </SeekPredicates>
                                                                                                                  </IndexScan>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="PROBE([Opt_Bitmap2223],[peptest].[dbo].[k_m_values].[id_step] as [kmv_merit].[id_step])">
                                                                                                                    <Intrinsic FunctionName="PROBE">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Column="Opt_Bitmap2223" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="id_step" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Intrinsic>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                          </NestedLoops>
                                                                                                        </RelOp>
                                                                                                      </Hash>
                                                                                                    </RelOp>
                                                                                                  </Sort>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="11" EstimateCPU="0.00010028" EstimateIO="0.01" EstimateRebinds="344.219" EstimateRewinds="22346.5" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Lazy Spool" NodeId="126" Parallel="false" PhysicalOp="Table Spool" EstimatedTotalSubtreeCost="7.30766">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                  </OutputList>
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRebinds="105294" ActualRewinds="0" ActualRows="17" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2637" ActualCPUms="2637" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Spool>
                                                                                                    <RelOp AvgRowSize="11" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="344.219" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="127" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="1.58218">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                      </OutputList>
                                                                                                      <MemoryFractions Input="0" Output="1.48091E-05" />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="17" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2554" ActualCPUms="2554" InputMemoryGrant="0" OutputMemoryGrant="544" UsedMemoryGrant="0" />
                                                                                                      </RunTimeInformation>
                                                                                                      <NestedLoops Optimized="true">
                                                                                                        <OuterReferences>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                        </OuterReferences>
                                                                                                        <RelOp AvgRowSize="15" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="344.219" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="129" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.844088">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="17" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2518" ActualCPUms="2518" />
                                                                                                          </RunTimeInformation>
                                                                                                          <NestedLoops Optimized="false">
                                                                                                            <OuterReferences>
                                                                                                              <ColumnReference Column="Expr1417" />
                                                                                                            </OuterReferences>
                                                                                                            <RelOp AvgRowSize="11" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="344.219" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Assert" NodeId="130" Parallel="false" PhysicalOp="Assert" EstimatedTotalSubtreeCost="0.108033">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Column="Expr1417" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2308" ActualCPUms="2307" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Assert StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="19" EstimateCPU="1.1E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="344.219" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Aggregate" NodeId="131" Parallel="false" PhysicalOp="Stream Aggregate" EstimatedTotalSubtreeCost="0.107867">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Column="Expr1416" />
                                                                                                                    <ColumnReference Column="Expr1417" />
                                                                                                                  </OutputList>
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="105294" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2278" ActualCPUms="2277" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <StreamAggregate>
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1416" />
                                                                                                                        <ScalarOperator ScalarString="Count(*)">
                                                                                                                          <Aggregate AggType="countstar" Distinct="false" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1417" />
                                                                                                                        <ScalarOperator ScalarString="ANY([peptest].[dbo].[k_m_fields].[id_field])">
                                                                                                                          <Aggregate AggType="ANY" Distinct="false">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                          </Aggregate>
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <RelOp AvgRowSize="270" EstimateCPU="0.0002237" EstimateIO="0.00838869" EstimateRebinds="0" EstimateRewinds="344.219" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="132" LogicalOp="Clustered Index Scan" NodeId="132" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="0.0856141" TableCardinality="132">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                      </OutputList>
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="105294" ActualRowsRead="13898808" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="2229" ActualCPUms="2229" ActualScans="105294" ActualLogicalReads="1052940" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <IndexScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="id_field" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Index="[PK_k_m_fields]" TableReferenceId="4" IndexKind="Clustered" Storage="RowStore" />
                                                                                                                        <Predicate>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_fields].[code_field]=N'ci'">
                                                                                                                            <Compare CompareOp="EQ">
                                                                                                                              <ScalarOperator>
                                                                                                                                <Identifier>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_fields]" Column="code_field" />
                                                                                                                                </Identifier>
                                                                                                                              </ScalarOperator>
                                                                                                                              <ScalarOperator>
                                                                                                                                <Const ConstValue="N'ci'" />
                                                                                                                              </ScalarOperator>
                                                                                                                            </Compare>
                                                                                                                          </ScalarOperator>
                                                                                                                        </Predicate>
                                                                                                                      </IndexScan>
                                                                                                                    </RelOp>
                                                                                                                  </StreamAggregate>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="CASE WHEN [Expr1416]&gt;(1) THEN (0) ELSE NULL END">
                                                                                                                    <IF>
                                                                                                                      <Condition>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Compare CompareOp="GT">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Column="Expr1416" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                            <ScalarOperator>
                                                                                                                              <Const ConstValue="(1)" />
                                                                                                                            </ScalarOperator>
                                                                                                                          </Compare>
                                                                                                                        </ScalarOperator>
                                                                                                                      </Condition>
                                                                                                                      <Then>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Const ConstValue="(0)" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </Then>
                                                                                                                      <Else>
                                                                                                                        <ScalarOperator>
                                                                                                                          <Const ConstValue="NULL" />
                                                                                                                        </ScalarOperator>
                                                                                                                      </Else>
                                                                                                                    </IF>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Assert>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="15" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="344.219" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="133" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.734612" TableCardinality="7408150">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="17" ActualRowsRead="17" Batches="0" ActualEndOfScans="105294" ActualExecutions="105294" ActualExecutionMode="Row" ActualElapsedms="178" ActualCPUms="178" ActualScans="105294" ActualLogicalReads="315882" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[UQ_k_m_values]" Alias="[kmv_ci]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                <SeekPredicates>
                                                                                                                  <SeekPredicateNew>
                                                                                                                    <SeekKeys>
                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                        <RangeColumns>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_field" />
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_step" />
                                                                                                                        </RangeColumns>
                                                                                                                        <RangeExpressions>
                                                                                                                          <ScalarOperator ScalarString="[Expr1417]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Column="Expr1417" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[k_m_plans_payees_steps].[id_step] as [pps].[id_step]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_plans_payees_steps]" Alias="[pps]" Column="id_step" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                        </RangeExpressions>
                                                                                                                      </Prefix>
                                                                                                                    </SeekKeys>
                                                                                                                  </SeekPredicateNew>
                                                                                                                </SeekPredicates>
                                                                                                              </IndexScan>
                                                                                                            </RelOp>
                                                                                                          </NestedLoops>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="11" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="344.219" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="135" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.736651" TableCardinality="7408150">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                          </OutputList>
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="17" ActualRowsRead="17" Batches="0" ActualEndOfScans="0" ActualExecutions="17" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="68" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Index="[PK_k_m_values]" Alias="[kmv_ci]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                                                                            <SeekPredicates>
                                                                                                              <SeekPredicateNew>
                                                                                                                <SeekKeys>
                                                                                                                  <Prefix ScanType="EQ">
                                                                                                                    <RangeColumns>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                                    </RangeColumns>
                                                                                                                    <RangeExpressions>
                                                                                                                      <ScalarOperator ScalarString="[peptest].[dbo].[k_m_values].[id_value] as [kmv_ci].[id_value]">
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="id_value" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </RangeExpressions>
                                                                                                                  </Prefix>
                                                                                                                </SeekKeys>
                                                                                                              </SeekPredicateNew>
                                                                                                            </SeekPredicates>
                                                                                                          </IndexScan>
                                                                                                        </RelOp>
                                                                                                      </NestedLoops>
                                                                                                    </RelOp>
                                                                                                  </Spool>
                                                                                                </RelOp>
                                                                                              </NestedLoops>
                                                                                            </RelOp>
                                                                                          </Hash>
                                                                                        </RelOp>
                                                                                        <Predicate>
                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_eligible] as [pfp].[is_eligible]=(1) AND [peptest].[dbo].[k_m_values].[input_value_int] as [kmv_ci].[input_value_int] IS NULL OR [peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_merit_eligible] as [pfp].[is_merit_eligible]=(1) AND [peptest].[dbo].[k_m_values].[input_value_numeric] as [kmv_merit].[input_value_numeric] IS NULL OR [peptest].[dbo].[PEPSICO_Process_FocalPoint].[is_sc_eligible] as [pfp].[is_sc_eligible]=(1) AND CASE WHEN [peptest].[dbo].[k_m_values].[input_value_int] as [kmv_ci].[input_value_int] IS NULL THEN NULL ELSE [peptest].[dbo].[k_m_values].[input_value_numeric] as [kmv_ic_score].[input_value_numeric] END IS NULL">
                                                                                            <Logical Operation="OR">
                                                                                              <ScalarOperator>
                                                                                                <Logical Operation="AND">
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="EQ">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_eligible" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="(1)" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="IS">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="NULL" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                </Logical>
                                                                                              </ScalarOperator>
                                                                                              <ScalarOperator>
                                                                                                <Logical Operation="AND">
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="EQ">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_merit_eligible" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="(1)" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="IS">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_merit]" Column="input_value_numeric" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="NULL" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                </Logical>
                                                                                              </ScalarOperator>
                                                                                              <ScalarOperator>
                                                                                                <Logical Operation="AND">
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="EQ">
                                                                                                      <ScalarOperator>
                                                                                                        <Identifier>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="is_sc_eligible" />
                                                                                                        </Identifier>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="(1)" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                  <ScalarOperator>
                                                                                                    <Compare CompareOp="IS">
                                                                                                      <ScalarOperator>
                                                                                                        <IF>
                                                                                                          <Condition>
                                                                                                            <ScalarOperator>
                                                                                                              <Compare CompareOp="IS">
                                                                                                                <ScalarOperator>
                                                                                                                  <Identifier>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ci]" Column="input_value_int" />
                                                                                                                  </Identifier>
                                                                                                                </ScalarOperator>
                                                                                                                <ScalarOperator>
                                                                                                                  <Const ConstValue="NULL" />
                                                                                                                </ScalarOperator>
                                                                                                              </Compare>
                                                                                                            </ScalarOperator>
                                                                                                          </Condition>
                                                                                                          <Then>
                                                                                                            <ScalarOperator>
                                                                                                              <Const ConstValue="NULL" />
                                                                                                            </ScalarOperator>
                                                                                                          </Then>
                                                                                                          <Else>
                                                                                                            <ScalarOperator>
                                                                                                              <Identifier>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_m_values]" Alias="[kmv_ic_score]" Column="input_value_numeric" />
                                                                                                              </Identifier>
                                                                                                            </ScalarOperator>
                                                                                                          </Else>
                                                                                                        </IF>
                                                                                                      </ScalarOperator>
                                                                                                      <ScalarOperator>
                                                                                                        <Const ConstValue="NULL" />
                                                                                                      </ScalarOperator>
                                                                                                    </Compare>
                                                                                                  </ScalarOperator>
                                                                                                </Logical>
                                                                                              </ScalarOperator>
                                                                                            </Logical>
                                                                                          </ScalarOperator>
                                                                                        </Predicate>
                                                                                      </Filter>
                                                                                    </RelOp>
                                                                                  </Hash>
                                                                                </RelOp>
                                                                                <RelOp AvgRowSize="567" EstimateCPU="2.73959E-05" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="114.149" LogicalOp="Filter" NodeId="136" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="761.414">
                                                                                  <OutputList>
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                  </OutputList>
                                                                                  <RunTimeInformation>
                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1396" Batches="10" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                  </RunTimeInformation>
                                                                                  <Filter StartupExpression="false">
                                                                                    <RelOp AvgRowSize="575" EstimateCPU="0.00913195" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="114.149" LogicalOp="Compute Scalar" NodeId="137" Parallel="false" PhysicalOp="Sequence Project" EstimatedTotalSubtreeCost="761.414">
                                                                                      <OutputList>
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                        <ColumnReference Column="Expr1190" />
                                                                                      </OutputList>
                                                                                      <RunTimeInformation>
                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="10" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1578" ActualCPUms="1578" />
                                                                                      </RunTimeInformation>
                                                                                      <SequenceProject>
                                                                                        <DefinedValues>
                                                                                          <DefinedValue>
                                                                                            <ColumnReference Column="Expr1190" />
                                                                                            <ScalarOperator ScalarString="row_number">
                                                                                              <Sequence FunctionName="row_number" />
                                                                                            </ScalarOperator>
                                                                                          </DefinedValue>
                                                                                        </DefinedValues>
                                                                                        <RelOp AvgRowSize="575" EstimateCPU="0.00228299" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="114.149" LogicalOp="Segment" NodeId="138" Parallel="false" PhysicalOp="Segment" EstimatedTotalSubtreeCost="761.405">
                                                                                          <OutputList>
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                            <ColumnReference Column="Segment2322" />
                                                                                          </OutputList>
                                                                                          <RunTimeInformation>
                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1576" ActualCPUms="1576" />
                                                                                          </RunTimeInformation>
                                                                                          <Segment>
                                                                                            <GroupBy>
                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                            </GroupBy>
                                                                                            <SegmentColumn>
                                                                                              <ColumnReference Column="Segment2322" />
                                                                                            </SegmentColumn>
                                                                                            <RelOp AvgRowSize="571" EstimateCPU="0.477145" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="114149" LogicalOp="Left Semi Join" NodeId="139" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="761.402">
                                                                                              <OutputList>
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                              </OutputList>
                                                                                              <RunTimeInformation>
                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1574" ActualCPUms="1574" />
                                                                                              </RunTimeInformation>
                                                                                              <NestedLoops Optimized="false">
                                                                                                <OuterReferences>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                </OuterReferences>
                                                                                                <RelOp AvgRowSize="2577" EstimateCPU="4.4014" EstimateIO="0.00375375" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="114149" LogicalOp="Sort" NodeId="140" Parallel="false" PhysicalOp="Sort" EstimatedTotalSubtreeCost="760.744">
                                                                                                  <OutputList>
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                  </OutputList>
                                                                                                  <MemoryFractions Input="0.204621" Output="0.204621" />
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="10" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="6" ActualCPUms="6" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Sort Distinct="false">
                                                                                                    <OrderBy>
                                                                                                      <OrderByColumn Ascending="true">
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                      </OrderByColumn>
                                                                                                      <OrderByColumn Ascending="true">
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                      </OrderByColumn>
                                                                                                    </OrderBy>
                                                                                                    <RelOp AvgRowSize="2590" EstimateCPU="0.477145" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="114149" LogicalOp="Left Semi Join" NodeId="141" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="756.202">
                                                                                                      <OutputList>
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                      </OutputList>
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="10" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1402" ActualCPUms="1402" />
                                                                                                      </RunTimeInformation>
                                                                                                      <NestedLoops Optimized="false">
                                                                                                        <OuterReferences>
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idCompGroup" />
                                                                                                        </OuterReferences>
                                                                                                        <RelOp AvgRowSize="4601" EstimateCPU="0.483919" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="114149" LogicalOp="Inner Join" NodeId="142" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="755.373">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idCompGroup" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                          </OutputList>
                                                                                                          <MemoryFractions Input="0" Output="0.339891" />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="105120" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="1246" ActualCPUms="1245" InputMemoryGrant="0" OutputMemoryGrant="734952" UsedMemoryGrant="75792" />
                                                                                                          </RunTimeInformation>
                                                                                                          <NestedLoops Optimized="true" WithUnorderedPrefetch="true">
                                                                                                            <OuterReferences>
                                                                                                              <ColumnReference Column="Bmk1185" />
                                                                                                              <ColumnReference Column="Expr2321" />
                                                                                                            </OuterReferences>
                                                                                                            <RelOp AvgRowSize="4600" EstimateCPU="0.483919" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="115770" LogicalOp="Compute Scalar" NodeId="145" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="40.752">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                <ColumnReference Column="Bmk1185" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                <ColumnReference Column="Expr2320" />
                                                                                                              </OutputList>
                                                                                                              <ComputeScalar>
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Column="Expr2320" />
                                                                                                                    <ScalarOperator ScalarString="BmkToPage([Bmk1185])">
                                                                                                                      <Intrinsic FunctionName="BmkToPage">
                                                                                                                        <ScalarOperator>
                                                                                                                          <Identifier>
                                                                                                                            <ColumnReference Column="Bmk1185" />
                                                                                                                          </Identifier>
                                                                                                                        </ScalarOperator>
                                                                                                                      </Intrinsic>
                                                                                                                    </ScalarOperator>
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <RelOp AvgRowSize="4600" EstimateCPU="0.483919" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="115770" LogicalOp="Inner Join" NodeId="146" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="40.752">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                    <ColumnReference Column="Bmk1185" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                  </OutputList>
                                                                                                                  <MemoryFractions Input="0" Output="0.33901" />
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="115770" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="587" ActualCPUms="587" InputMemoryGrant="0" OutputMemoryGrant="733056" UsedMemoryGrant="75792" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <NestedLoops Optimized="true" WithUnorderedPrefetch="true">
                                                                                                                    <OuterReferences>
                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                      <ColumnReference Column="Expr2319" />
                                                                                                                    </OuterReferences>
                                                                                                                    <RelOp AvgRowSize="4588" EstimateCPU="0.483919" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="115770" LogicalOp="Inner Join" NodeId="149" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="3.38156">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                      </OutputList>
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="115770" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="39" ActualCPUms="39" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <NestedLoops Optimized="false">
                                                                                                                        <RelOp AvgRowSize="4530" EstimateCPU="0.0001713" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="13" LogicalOp="Table Scan" NodeId="150" Parallel="false" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="0.0032963" TableCardinality="13">
                                                                                                                          <OutputList>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                          </OutputList>
                                                                                                                          <RunTimeInformation>
                                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="13" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="1" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                          </RunTimeInformation>
                                                                                                                          <TableScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                            <DefinedValues>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="PrioritySequence" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="comment" />
                                                                                                                              </DefinedValue>
                                                                                                                            </DefinedValues>
                                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" TableReferenceId="2" IndexKind="Heap" Storage="RowStore" />
                                                                                                                            <Predicate>
                                                                                                                              <ScalarOperator ScalarString="CONVERT(date,getdate(),0)&gt;=[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[BonusStartDate] as [smns].[BonusStartDate] AND CONVERT(date,getdate(),0)&lt;=[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[BonusEndDate] as [smns].[BonusEndDate] AND [peptest].[dbo].[PEPSICO_send_mail_notification_setup].[SendBonusNotifications] as [smns].[SendBonusNotifications]=(1)">
                                                                                                                                <Logical Operation="AND">
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="GE">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Column="ConstExpr1400">
                                                                                                                                            <ScalarOperator>
                                                                                                                                              <Convert DataType="date" Style="0" Implicit="false">
                                                                                                                                                <ScalarOperator>
                                                                                                                                                  <Intrinsic FunctionName="getdate" />
                                                                                                                                                </ScalarOperator>
                                                                                                                                              </Convert>
                                                                                                                                            </ScalarOperator>
                                                                                                                                          </ColumnReference>
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="BonusStartDate" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="LE">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Column="ConstExpr1401">
                                                                                                                                            <ScalarOperator>
                                                                                                                                              <Convert DataType="date" Style="0" Implicit="false">
                                                                                                                                                <ScalarOperator>
                                                                                                                                                  <Intrinsic FunctionName="getdate" />
                                                                                                                                                </ScalarOperator>
                                                                                                                                              </Convert>
                                                                                                                                            </ScalarOperator>
                                                                                                                                          </ColumnReference>
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="BonusEndDate" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                  <ScalarOperator>
                                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Identifier>
                                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="SendBonusNotifications" />
                                                                                                                                        </Identifier>
                                                                                                                                      </ScalarOperator>
                                                                                                                                      <ScalarOperator>
                                                                                                                                        <Const ConstValue="(1)" />
                                                                                                                                      </ScalarOperator>
                                                                                                                                    </Compare>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </Logical>
                                                                                                                              </ScalarOperator>
                                                                                                                            </Predicate>
                                                                                                                          </TableScan>
                                                                                                                        </RelOp>
                                                                                                                        <RelOp AvgRowSize="73" EstimateCPU="0.127504" EstimateIO="2.76683" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="115770" EstimatedRowsRead="115770" LogicalOp="Index Scan" NodeId="151" Parallel="false" PhysicalOp="Index Scan" EstimatedTotalSubtreeCost="2.89433" TableCardinality="115770">
                                                                                                                          <OutputList>
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                          </OutputList>
                                                                                                                          <RunTimeInformation>
                                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="115770" ActualRowsRead="115770" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="30" ActualCPUms="30" ActualScans="1" ActualLogicalReads="3770" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                          </RunTimeInformation>
                                                                                                                          <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                            <DefinedValues>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="gpid" />
                                                                                                                              </DefinedValue>
                                                                                                                              <DefinedValue>
                                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                              </DefinedValue>
                                                                                                                            </DefinedValues>
                                                                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Index="[IX_PEPSICO_Process_FocalPoint_idPayee]" Alias="[pfp]" TableReferenceId="2" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                          </IndexScan>
                                                                                                                        </RelOp>
                                                                                                                      </NestedLoops>
                                                                                                                    </RelOp>
                                                                                                                    <RelOp AvgRowSize="19" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="115769" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="152" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="36.8865" TableCardinality="1044370">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Column="Bmk1185" />
                                                                                                                      </OutputList>
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="115770" ActualRowsRead="115770" Batches="0" ActualEndOfScans="0" ActualExecutions="115770" ActualExecutionMode="Row" ActualElapsedms="136" ActualCPUms="136" ActualScans="0" ActualLogicalReads="332822" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Column="Bmk1185" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Index="[PK_PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" IndexKind="NonClustered" Storage="RowStore" />
                                                                                                                        <SeekPredicates>
                                                                                                                          <SeekPredicateNew>
                                                                                                                            <SeekKeys>
                                                                                                                              <Prefix ScanType="EQ">
                                                                                                                                <RangeColumns>
                                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idPayee" />
                                                                                                                                </RangeColumns>
                                                                                                                                <RangeExpressions>
                                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_FocalPoint].[idPayee] as [pfp].[idPayee]">
                                                                                                                                    <Identifier>
                                                                                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                                                    </Identifier>
                                                                                                                                  </ScalarOperator>
                                                                                                                                </RangeExpressions>
                                                                                                                              </Prefix>
                                                                                                                            </SeekKeys>
                                                                                                                          </SeekPredicateNew>
                                                                                                                        </SeekPredicates>
                                                                                                                      </IndexScan>
                                                                                                                    </RelOp>
                                                                                                                  </NestedLoops>
                                                                                                                </RelOp>
                                                                                                              </ComputeScalar>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="143" EstimateCPU="0.0001581" EstimateIO="0.00608796" EstimateRebinds="115769" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="0.986002" LogicalOp="RID Lookup" NodeId="154" Parallel="false" PhysicalOp="RID Lookup" EstimatedTotalSubtreeCost="714.137" TableCardinality="1044370">
                                                                                                              <OutputList>
                                                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idCompGroup" />
                                                                                                              </OutputList>
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="105120" ActualRowsRead="115770" Batches="0" ActualEndOfScans="10650" ActualExecutions="115770" ActualExecutionMode="Row" ActualElapsedms="227" ActualCPUms="227" ActualScans="0" ActualLogicalReads="115770" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                                                              </RunTimeInformation>
                                                                                                              <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                                                                <DefinedValues>
                                                                                                                  <DefinedValue>
                                                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idCompGroup" />
                                                                                                                  </DefinedValue>
                                                                                                                </DefinedValues>
                                                                                                                <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" TableReferenceId="-1" IndexKind="Heap" Storage="RowStore" />
                                                                                                                <SeekPredicates>
                                                                                                                  <SeekPredicateNew>
                                                                                                                    <SeekKeys>
                                                                                                                      <Prefix ScanType="EQ">
                                                                                                                        <RangeColumns>
                                                                                                                          <ColumnReference Column="Bmk1185" />
                                                                                                                        </RangeColumns>
                                                                                                                        <RangeExpressions>
                                                                                                                          <ScalarOperator ScalarString="[Bmk1185]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Column="Bmk1185" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                        </RangeExpressions>
                                                                                                                      </Prefix>
                                                                                                                    </SeekKeys>
                                                                                                                  </SeekPredicateNew>
                                                                                                                </SeekPredicates>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_FocalPoint_EmpCurrentPayee].[LevelCode] as [emp].[LevelCode]&lt;&gt;'LG6' AND [peptest].[dbo].[PEPSICO_FocalPoint_EmpCurrentPayee].[LevelCode] as [emp].[LevelCode]&lt;&gt;'LG7' AND [peptest].[dbo].[PEPSICO_FocalPoint_EmpCurrentPayee].[LevelCode] as [emp].[LevelCode]&lt;&gt;'LG8' AND [peptest].[dbo].[PEPSICO_FocalPoint_EmpCurrentPayee].[LevelCode] as [emp].[LevelCode]&lt;&gt;'LG9'">
                                                                                                                    <Logical Operation="AND">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Compare CompareOp="NE">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="LevelCode" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Const ConstValue="'LG6'" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </Compare>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Compare CompareOp="NE">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="LevelCode" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Const ConstValue="'LG7'" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </Compare>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Compare CompareOp="NE">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="LevelCode" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Const ConstValue="'LG8'" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </Compare>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Compare CompareOp="NE">
                                                                                                                          <ScalarOperator>
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="LevelCode" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator>
                                                                                                                            <Const ConstValue="'LG9'" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </Compare>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Logical>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </IndexScan>
                                                                                                            </RelOp>
                                                                                                          </NestedLoops>
                                                                                                        </RelOp>
                                                                                                        <RelOp AvgRowSize="9" EstimateCPU="8.07107E-07" EstimateIO="0" EstimateRebinds="99880.8" EstimateRewinds="14267.7" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="8.07107" LogicalOp="Concatenation" NodeId="155" Parallel="false" PhysicalOp="Concatenation" EstimatedTotalSubtreeCost="0.180356">
                                                                                                          <OutputList />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="97050" ActualExecutions="105120" ActualExecutionMode="Row" ActualElapsedms="110" ActualCPUms="110" />
                                                                                                          </RunTimeInformation>
                                                                                                          <Concat>
                                                                                                            <DefinedValues />
                                                                                                            <RelOp AvgRowSize="9" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="99880.8" EstimateRewinds="14267.7" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="156" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.168941">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRebinds="105120" ActualRewinds="0" ActualRows="0" Batches="0" ActualEndOfScans="105120" ActualExecutions="105120" ActualExecutionMode="Row" ActualElapsedms="15" ActualCPUms="15" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="true">
                                                                                                                <RelOp AvgRowSize="9" EstimateCPU="1.157E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="114148" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Constant Scan" NodeId="157" Parallel="false" PhysicalOp="Constant Scan" EstimatedTotalSubtreeCost="0.11415">
                                                                                                                  <OutputList />
                                                                                                                  <RunTimeInformation>
                                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                                  </RunTimeInformation>
                                                                                                                  <ConstantScan />
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[CompGroupList] as [smns].[CompGroupList]='-1'">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Const ConstValue="'-1'" />
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                            <RelOp AvgRowSize="9" EstimateCPU="2.4E-05" EstimateIO="0" EstimateRebinds="99880.8" EstimateRewinds="14267.7" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="7.07107" LogicalOp="Filter" NodeId="158" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="1.27531">
                                                                                                              <OutputList />
                                                                                                              <RunTimeInformation>
                                                                                                                <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="97050" ActualExecutions="105120" ActualExecutionMode="Row" ActualElapsedms="62" ActualCPUms="62" />
                                                                                                              </RunTimeInformation>
                                                                                                              <Filter StartupExpression="false">
                                                                                                                <RelOp AvgRowSize="11" EstimateCPU="5E-06" EstimateIO="0" EstimateRebinds="99880.8" EstimateRewinds="14267.7" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Compute Scalar" NodeId="159" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="0.887874">
                                                                                                                  <OutputList>
                                                                                                                    <ColumnReference Column="Expr1424" />
                                                                                                                  </OutputList>
                                                                                                                  <ComputeScalar>
                                                                                                                    <DefinedValues>
                                                                                                                      <DefinedValue>
                                                                                                                        <ColumnReference Column="Expr1424" />
                                                                                                                        <ScalarOperator ScalarString="CONVERT_IMPLICIT(int,STRING_SPLIT.[value],0)">
                                                                                                                          <Convert DataType="int" Style="0" Implicit="true">
                                                                                                                            <ScalarOperator>
                                                                                                                              <Identifier>
                                                                                                                                <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                              </Identifier>
                                                                                                                            </ScalarOperator>
                                                                                                                          </Convert>
                                                                                                                        </ScalarOperator>
                                                                                                                      </DefinedValue>
                                                                                                                    </DefinedValues>
                                                                                                                    <RelOp AvgRowSize="2011" EstimateCPU="5.0157E-05" EstimateIO="0" EstimateRebinds="99880.8" EstimateRewinds="14267.7" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Table-valued function" NodeId="160" Parallel="false" PhysicalOp="Table-valued function" EstimatedTotalSubtreeCost="0.807159">
                                                                                                                      <OutputList>
                                                                                                                        <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                      </OutputList>
                                                                                                                      <MemoryFractions Input="0" Output="0" />
                                                                                                                      <RunTimeInformation>
                                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRebinds="105120" ActualRewinds="0" ActualRows="105120" Batches="0" ActualEndOfScans="97050" ActualExecutions="105120" ActualExecutionMode="Row" ActualElapsedms="36" ActualCPUms="36" />
                                                                                                                      </RunTimeInformation>
                                                                                                                      <TableValuedFunction>
                                                                                                                        <DefinedValues>
                                                                                                                          <DefinedValue>
                                                                                                                            <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                          </DefinedValue>
                                                                                                                        </DefinedValues>
                                                                                                                        <Object Table="[STRING_SPLIT]" />
                                                                                                                        <ParameterList>
                                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[CompGroupList] as [smns].[CompGroupList]">
                                                                                                                            <Identifier>
                                                                                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="CompGroupList" />
                                                                                                                            </Identifier>
                                                                                                                          </ScalarOperator>
                                                                                                                          <ScalarOperator ScalarString="','">
                                                                                                                            <Const ConstValue="','" />
                                                                                                                          </ScalarOperator>
                                                                                                                        </ParameterList>
                                                                                                                      </TableValuedFunction>
                                                                                                                    </RelOp>
                                                                                                                  </ComputeScalar>
                                                                                                                </RelOp>
                                                                                                                <Predicate>
                                                                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_FocalPoint_EmpCurrentPayee].[idCompGroup] as [emp].[idCompGroup]=[Expr1424]">
                                                                                                                    <Compare CompareOp="EQ">
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[emp]" Column="idCompGroup" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                      <ScalarOperator>
                                                                                                                        <Identifier>
                                                                                                                          <ColumnReference Column="Expr1424" />
                                                                                                                        </Identifier>
                                                                                                                      </ScalarOperator>
                                                                                                                    </Compare>
                                                                                                                  </ScalarOperator>
                                                                                                                </Predicate>
                                                                                                              </Filter>
                                                                                                            </RelOp>
                                                                                                          </Concat>
                                                                                                        </RelOp>
                                                                                                      </NestedLoops>
                                                                                                    </RelOp>
                                                                                                  </Sort>
                                                                                                </RelOp>
                                                                                                <RelOp AvgRowSize="9" EstimateCPU="8.07107E-07" EstimateIO="0" EstimateRebinds="112073" EstimateRewinds="2075.5" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="8.07107" LogicalOp="Concatenation" NodeId="161" Parallel="false" PhysicalOp="Concatenation" EstimatedTotalSubtreeCost="0.180356">
                                                                                                  <OutputList />
                                                                                                  <RunTimeInformation>
                                                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="0" ActualExecutions="8070" ActualExecutionMode="Row" ActualElapsedms="161" ActualCPUms="161" />
                                                                                                  </RunTimeInformation>
                                                                                                  <Concat>
                                                                                                    <DefinedValues />
                                                                                                    <RelOp AvgRowSize="9" EstimateCPU="4.8E-07" EstimateIO="0" EstimateRebinds="112073" EstimateRewinds="2075.5" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Filter" NodeId="162" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="0.168941">
                                                                                                      <OutputList />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRebinds="8070" ActualRewinds="0" ActualRows="0" Batches="0" ActualEndOfScans="8070" ActualExecutions="8070" ActualExecutionMode="Row" ActualElapsedms="1" ActualCPUms="1" />
                                                                                                      </RunTimeInformation>
                                                                                                      <Filter StartupExpression="true">
                                                                                                        <RelOp AvgRowSize="9" EstimateCPU="1.157E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="114148" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Constant Scan" NodeId="163" Parallel="false" PhysicalOp="Constant Scan" EstimatedTotalSubtreeCost="0.11415">
                                                                                                          <OutputList />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                                                                                          </RunTimeInformation>
                                                                                                          <ConstantScan />
                                                                                                        </RelOp>
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[LevelCodeList] as [smns].[LevelCodeList]='-1'">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Const ConstValue="'-1'" />
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </Filter>
                                                                                                    </RelOp>
                                                                                                    <RelOp AvgRowSize="9" EstimateCPU="2.4E-05" EstimateIO="0" EstimateRebinds="112073" EstimateRewinds="2075.5" EstimatedExecutionMode="Row" EstimateRows="1" EstimateRowsWithoutRowGoal="7.07107" LogicalOp="Filter" NodeId="164" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="1.19459">
                                                                                                      <OutputList />
                                                                                                      <RunTimeInformation>
                                                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="8070" Batches="0" ActualEndOfScans="0" ActualExecutions="8070" ActualExecutionMode="Row" ActualElapsedms="157" ActualCPUms="157" />
                                                                                                      </RunTimeInformation>
                                                                                                      <Filter StartupExpression="false">
                                                                                                        <RelOp AvgRowSize="2011" EstimateCPU="5.0157E-05" EstimateIO="0" EstimateRebinds="112073" EstimateRewinds="2075.5" EstimatedExecutionMode="Row" EstimateRows="7.07107" EstimateRowsWithoutRowGoal="50" LogicalOp="Table-valued function" NodeId="165" Parallel="false" PhysicalOp="Table-valued function" EstimatedTotalSubtreeCost="0.807159">
                                                                                                          <OutputList>
                                                                                                            <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                          </OutputList>
                                                                                                          <MemoryFractions Input="0" Output="0" />
                                                                                                          <RunTimeInformation>
                                                                                                            <RunTimeCountersPerThread Thread="0" ActualRebinds="8070" ActualRewinds="0" ActualRows="740974" Batches="0" ActualEndOfScans="0" ActualExecutions="8070" ActualExecutionMode="Row" ActualElapsedms="101" ActualCPUms="101" />
                                                                                                          </RunTimeInformation>
                                                                                                          <TableValuedFunction>
                                                                                                            <DefinedValues>
                                                                                                              <DefinedValue>
                                                                                                                <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                              </DefinedValue>
                                                                                                            </DefinedValues>
                                                                                                            <Object Table="[STRING_SPLIT]" />
                                                                                                            <ParameterList>
                                                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_send_mail_notification_setup].[LevelCodeList] as [smns].[LevelCodeList]">
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_send_mail_notification_setup]" Alias="[smns]" Column="LevelCodeList" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator ScalarString="','">
                                                                                                                <Const ConstValue="','" />
                                                                                                              </ScalarOperator>
                                                                                                            </ParameterList>
                                                                                                          </TableValuedFunction>
                                                                                                        </RelOp>
                                                                                                        <Predicate>
                                                                                                          <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Process_FocalPoint].[LevelCode] as [pfp].[LevelCode]=STRING_SPLIT.[value]">
                                                                                                            <Compare CompareOp="EQ">
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="LevelCode" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                              <ScalarOperator>
                                                                                                                <Identifier>
                                                                                                                  <ColumnReference Table="[STRING_SPLIT]" Column="value" />
                                                                                                                </Identifier>
                                                                                                              </ScalarOperator>
                                                                                                            </Compare>
                                                                                                          </ScalarOperator>
                                                                                                        </Predicate>
                                                                                                      </Filter>
                                                                                                    </RelOp>
                                                                                                  </Concat>
                                                                                                </RelOp>
                                                                                              </NestedLoops>
                                                                                            </RelOp>
                                                                                          </Segment>
                                                                                        </RelOp>
                                                                                      </SequenceProject>
                                                                                    </RelOp>
                                                                                    <Predicate>
                                                                                      <ScalarOperator ScalarString="[Expr1190]=(1) AND PROBE([Opt_Bitmap2247],[peptest].[dbo].[PEPSICO_Process_FocalPoint].[idPayee] as [pfp].[idPayee])">
                                                                                        <Logical Operation="AND">
                                                                                          <ScalarOperator>
                                                                                            <Compare CompareOp="EQ">
                                                                                              <ScalarOperator>
                                                                                                <Identifier>
                                                                                                  <ColumnReference Column="Expr1190" />
                                                                                                </Identifier>
                                                                                              </ScalarOperator>
                                                                                              <ScalarOperator>
                                                                                                <Const ConstValue="(1)" />
                                                                                              </ScalarOperator>
                                                                                            </Compare>
                                                                                          </ScalarOperator>
                                                                                          <ScalarOperator>
                                                                                            <Intrinsic FunctionName="PROBE">
                                                                                              <ScalarOperator>
                                                                                                <Identifier>
                                                                                                  <ColumnReference Column="Opt_Bitmap2247" />
                                                                                                </Identifier>
                                                                                              </ScalarOperator>
                                                                                              <ScalarOperator>
                                                                                                <Identifier>
                                                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Process_FocalPoint]" Alias="[pfp]" Column="idPayee" />
                                                                                                </Identifier>
                                                                                              </ScalarOperator>
                                                                                            </Intrinsic>
                                                                                          </ScalarOperator>
                                                                                        </Logical>
                                                                                      </ScalarOperator>
                                                                                    </Predicate>
                                                                                  </Filter>
                                                                                </RelOp>
                                                                              </Hash>
                                                                            </RelOp>
                                                                          </Concat>
                                                                        </RelOp>
                                                                      </Sort>
                                                                    </RelOp>
                                                                  </StreamAggregate>
                                                                </RelOp>
                                                                <RelOp AvgRowSize="71" EstimateCPU="0.0578178" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="2.47379" LogicalOp="Filter" NodeId="166" Parallel="false" PhysicalOp="Filter" EstimatedTotalSubtreeCost="2.88145">
                                                                  <OutputList>
                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                    <ColumnReference Column="Expr1422" />
                                                                  </OutputList>
                                                                  <RunTimeInformation>
                                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1737" Batches="28" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                  </RunTimeInformation>
                                                                  <Filter StartupExpression="false">
                                                                    <RelOp AvgRowSize="72" EstimateCPU="3.2851E-07" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="2.47379" LogicalOp="Compute Scalar" NodeId="167" Parallel="false" PhysicalOp="Compute Scalar" EstimatedTotalSubtreeCost="2.82364">
                                                                      <OutputList>
                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                        <ColumnReference Column="Expr1422" />
                                                                      </OutputList>
                                                                      <RunTimeInformation>
                                                                        <RunTimeCountersPerThread Thread="0" ActualRows="24780" Batches="28" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                      </RunTimeInformation>
                                                                      <ComputeScalar>
                                                                        <DefinedValues>
                                                                          <DefinedValue>
                                                                            <ColumnReference Column="Expr1422" />
                                                                            <ScalarOperator ScalarString="CONVERT_IMPLICIT(int,[peptest].[dbo].[k_users].[id_external_user] as [u].[id_external_user],0)">
                                                                              <Convert DataType="int" Style="0" Implicit="true">
                                                                                <ScalarOperator>
                                                                                  <Identifier>
                                                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_external_user" />
                                                                                  </Identifier>
                                                                                </ScalarOperator>
                                                                              </Convert>
                                                                            </ScalarOperator>
                                                                          </DefinedValue>
                                                                        </DefinedValues>
                                                                        <RelOp AvgRowSize="81" EstimateCPU="0.0723635" EstimateIO="2.75127" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Batch" EstimateRows="2.47379" EstimatedRowsRead="65702" LogicalOp="Clustered Index Scan" NodeId="168" Parallel="false" PhysicalOp="Clustered Index Scan" EstimatedTotalSubtreeCost="2.82364" TableCardinality="65702">
                                                                          <OutputList>
                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_external_user" />
                                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                          </OutputList>
                                                                          <RunTimeInformation>
                                                                            <RunTimeCountersPerThread Thread="0" ActualRows="24780" ActualRowsRead="65702" Batches="28" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Batch" ActualElapsedms="33" ActualCPUms="33" ActualScans="1" ActualLogicalReads="3723" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                                          </RunTimeInformation>
                                                                          <IndexScan Ordered="false" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                                            <DefinedValues>
                                                                              <DefinedValue>
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                              </DefinedValue>
                                                                              <DefinedValue>
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_external_user" />
                                                                              </DefinedValue>
                                                                              <DefinedValue>
                                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                              </DefinedValue>
                                                                            </DefinedValues>
                                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[k_users]" Index="[PK_k_users]" Alias="[u]" IndexKind="Clustered" Storage="RowStore" />
                                                                            <Predicate>
                                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_users].[active_user] as [u].[active_user]=(1) AND [peptest].[dbo].[k_users].[mail_user] as [u].[mail_user]&lt;&gt;N'noreply@gmail.com'">
                                                                                <Logical Operation="AND">
                                                                                  <ScalarOperator>
                                                                                    <Compare CompareOp="EQ">
                                                                                      <ScalarOperator>
                                                                                        <Identifier>
                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="active_user" />
                                                                                        </Identifier>
                                                                                      </ScalarOperator>
                                                                                      <ScalarOperator>
                                                                                        <Const ConstValue="(1)" />
                                                                                      </ScalarOperator>
                                                                                    </Compare>
                                                                                  </ScalarOperator>
                                                                                  <ScalarOperator>
                                                                                    <Compare CompareOp="NE">
                                                                                      <ScalarOperator>
                                                                                        <Identifier>
                                                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="mail_user" />
                                                                                        </Identifier>
                                                                                      </ScalarOperator>
                                                                                      <ScalarOperator>
                                                                                        <Const ConstValue="N'noreply@gmail.com'" />
                                                                                      </ScalarOperator>
                                                                                    </Compare>
                                                                                  </ScalarOperator>
                                                                                </Logical>
                                                                              </ScalarOperator>
                                                                            </Predicate>
                                                                          </IndexScan>
                                                                        </RelOp>
                                                                      </ComputeScalar>
                                                                    </RelOp>
                                                                    <Predicate>
                                                                      <ScalarOperator ScalarString="PROBE([Opt_Bitmap2249],[Expr1422])">
                                                                        <Intrinsic FunctionName="PROBE">
                                                                          <ScalarOperator>
                                                                            <Identifier>
                                                                              <ColumnReference Column="Opt_Bitmap2249" />
                                                                            </Identifier>
                                                                          </ScalarOperator>
                                                                          <ScalarOperator>
                                                                            <Identifier>
                                                                              <ColumnReference Column="Expr1422" />
                                                                            </Identifier>
                                                                          </ScalarOperator>
                                                                        </Intrinsic>
                                                                      </ScalarOperator>
                                                                    </Predicate>
                                                                  </Filter>
                                                                </RelOp>
                                                              </Hash>
                                                            </RelOp>
                                                          </Sort>
                                                        </RelOp>
                                                        <RelOp AvgRowSize="27" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Clustered Index Seek" NodeId="169" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="1614300">
                                                          <OutputList>
                                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="codePayee" />
                                                          </OutputList>
                                                          <RunTimeInformation>
                                                            <RunTimeCountersPerThread Thread="0" ActualRows="1737" ActualRowsRead="1737" Batches="0" ActualEndOfScans="0" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="4" ActualCPUms="4" ActualScans="0" ActualLogicalReads="5211" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                          </RunTimeInformation>
                                                          <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                            <DefinedValues>
                                                              <DefinedValue>
                                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="codePayee" />
                                                              </DefinedValue>
                                                            </DefinedValues>
                                                            <Object Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Index="[PK_k_collaborateurs]" Alias="[pp]" IndexKind="Clustered" Storage="RowStore" />
                                                            <SeekPredicates>
                                                              <SeekPredicateNew>
                                                                <SeekKeys>
                                                                  <Prefix ScanType="EQ">
                                                                    <RangeColumns>
                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="idPayee" />
                                                                    </RangeColumns>
                                                                    <RangeExpressions>
                                                                      <ScalarOperator ScalarString="[Expr1422]">
                                                                        <Identifier>
                                                                          <ColumnReference Column="Expr1422" />
                                                                        </Identifier>
                                                                      </ScalarOperator>
                                                                    </RangeExpressions>
                                                                  </Prefix>
                                                                </SeekKeys>
                                                              </SeekPredicateNew>
                                                            </SeekPredicates>
                                                          </IndexScan>
                                                        </RelOp>
                                                      </NestedLoops>
                                                    </RelOp>
                                                    <RelOp AvgRowSize="9" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="170" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="1044370">
                                                      <OutputList />
                                                      <RunTimeInformation>
                                                        <RunTimeCountersPerThread Thread="0" ActualRows="1737" ActualRowsRead="1737" Batches="0" ActualEndOfScans="0" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="5" ActualCPUms="5" ActualScans="0" ActualLogicalReads="5211" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                      </RunTimeInformation>
                                                      <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                        <DefinedValues />
                                                        <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Index="[UI_PEPSICO_FocalPoint_EmpCurrentPayee_GPID]" Alias="[l]" IndexKind="NonClustered" Storage="RowStore" />
                                                        <SeekPredicates>
                                                          <SeekPredicateNew>
                                                            <SeekKeys>
                                                              <Prefix ScanType="EQ">
                                                                <RangeColumns>
                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_FocalPoint_EmpCurrentPayee]" Alias="[l]" Column="GPID" />
                                                                </RangeColumns>
                                                                <RangeExpressions>
                                                                  <ScalarOperator ScalarString="[peptest].[dbo].[py_Payee].[codePayee] as [pp].[codePayee]">
                                                                    <Identifier>
                                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[py_Payee]" Alias="[pp]" Column="codePayee" />
                                                                    </Identifier>
                                                                  </ScalarOperator>
                                                                </RangeExpressions>
                                                              </Prefix>
                                                            </SeekKeys>
                                                          </SeekPredicateNew>
                                                        </SeekPredicates>
                                                      </IndexScan>
                                                    </RelOp>
                                                  </NestedLoops>
                                                </RelOp>
                                                <RelOp AvgRowSize="11" EstimateCPU="0.000158128" EstimateIO="0.003125" EstimateRebinds="0.000465816" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1.02577" EstimatedRowsRead="1.02577" LogicalOp="Index Seek" NodeId="171" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.0032832" TableCardinality="35109">
                                                  <OutputList>
                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Alias="[kup]" Column="id_profile" />
                                                  </OutputList>
                                                  <RunTimeInformation>
                                                    <RunTimeCountersPerThread Thread="0" ActualRows="1739" ActualRowsRead="1739" Batches="0" ActualEndOfScans="1737" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="3" ActualCPUms="3" ActualScans="1737" ActualLogicalReads="3492" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                                  </RunTimeInformation>
                                                  <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                    <DefinedValues>
                                                      <DefinedValue>
                                                        <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Alias="[kup]" Column="id_profile" />
                                                      </DefinedValue>
                                                    </DefinedValues>
                                                    <Object Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Index="[IX_k_users_profiles_id_user_id_profile]" Alias="[kup]" IndexKind="NonClustered" Storage="RowStore" />
                                                    <SeekPredicates>
                                                      <SeekPredicateNew>
                                                        <SeekKeys>
                                                          <Prefix ScanType="EQ">
                                                            <RangeColumns>
                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users_profiles]" Alias="[kup]" Column="id_user" />
                                                            </RangeColumns>
                                                            <RangeExpressions>
                                                              <ScalarOperator ScalarString="[peptest].[dbo].[k_users].[id_user] as [u].[id_user]">
                                                                <Identifier>
                                                                  <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[k_users]" Alias="[u]" Column="id_user" />
                                                                </Identifier>
                                                              </ScalarOperator>
                                                            </RangeExpressions>
                                                          </Prefix>
                                                        </SeekKeys>
                                                      </SeekPredicateNew>
                                                    </SeekPredicates>
                                                  </IndexScan>
                                                </RelOp>
                                              </NestedLoops>
                                            </RelOp>
                                          </NestedLoops>
                                        </RelOp>
                                        <RelOp AvgRowSize="96" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Inner Join" NodeId="172" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.00657038">
                                          <OutputList>
                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                            <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="sentTo" />
                                          </OutputList>
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="1737" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="4" ActualCPUms="4" />
                                          </RunTimeInformation>
                                          <NestedLoops Optimized="false">
                                            <OuterReferences>
                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                            </OuterReferences>
                                            <RelOp AvgRowSize="11" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="1" LogicalOp="Index Seek" NodeId="173" Parallel="false" PhysicalOp="Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="67842">
                                              <OutputList>
                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                              </OutputList>
                                              <RunTimeInformation>
                                                <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="1737" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="4" ActualCPUms="4" ActualScans="1737" ActualLogicalReads="6948" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                              </RunTimeInformation>
                                              <IndexScan Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                <DefinedValues>
                                                  <DefinedValue>
                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                                  </DefinedValue>
                                                </DefinedValues>
                                                <Object Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Index="[IX__nc_MailQueue__mailSubject_createDate]" Alias="[mq]" IndexKind="NonClustered" Storage="RowStore" />
                                                <SeekPredicates>
                                                  <SeekPredicateNew>
                                                    <SeekKeys>
                                                      <Prefix ScanType="EQ">
                                                        <RangeColumns>
                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="mailSubject" />
                                                        </RangeColumns>
                                                        <RangeExpressions>
                                                          <ScalarOperator ScalarString="N'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'">
                                                            <Const ConstValue="N'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'" />
                                                          </ScalarOperator>
                                                        </RangeExpressions>
                                                      </Prefix>
                                                      <StartRange ScanType="GT">
                                                        <RangeColumns>
                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="createDate" />
                                                        </RangeColumns>
                                                        <RangeExpressions>
                                                          <ScalarOperator ScalarString="dateadd(hour,(-12),getdate())">
                                                            <Identifier>
                                                              <ColumnReference Column="ConstExpr1407">
                                                                <ScalarOperator>
                                                                  <Intrinsic FunctionName="dateadd">
                                                                    <ScalarOperator>
                                                                      <Const ConstValue="(6)" />
                                                                    </ScalarOperator>
                                                                    <ScalarOperator>
                                                                      <Const ConstValue="(-12)" />
                                                                    </ScalarOperator>
                                                                    <ScalarOperator>
                                                                      <Intrinsic FunctionName="getdate" />
                                                                    </ScalarOperator>
                                                                  </Intrinsic>
                                                                </ScalarOperator>
                                                              </ColumnReference>
                                                            </Identifier>
                                                          </ScalarOperator>
                                                        </RangeExpressions>
                                                      </StartRange>
                                                    </SeekKeys>
                                                  </SeekPredicateNew>
                                                </SeekPredicates>
                                              </IndexScan>
                                            </RelOp>
                                            <RelOp AvgRowSize="4035" EstimateCPU="0.0001581" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Clustered Index Seek" NodeId="175" Parallel="false" PhysicalOp="Clustered Index Seek" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="67842">
                                              <OutputList>
                                                <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="sentTo" />
                                              </OutputList>
                                              <RunTimeInformation>
                                                <RunTimeCountersPerThread Thread="0" ActualRows="0" Batches="0" ActualEndOfScans="0" ActualExecutions="0" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="0" ActualLogicalReads="0" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                              </RunTimeInformation>
                                              <IndexScan Lookup="true" Ordered="true" ScanDirection="FORWARD" ForcedIndex="false" ForceSeek="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                                <DefinedValues>
                                                  <DefinedValue>
                                                    <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="sentTo" />
                                                  </DefinedValue>
                                                </DefinedValues>
                                                <Object Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Index="[PK_nc_MailQueue]" Alias="[mq]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore" />
                                                <SeekPredicates>
                                                  <SeekPredicateNew>
                                                    <SeekKeys>
                                                      <Prefix ScanType="EQ">
                                                        <RangeColumns>
                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                                        </RangeColumns>
                                                        <RangeExpressions>
                                                          <ScalarOperator ScalarString="[peptest].[dbo].[nc_MailQueue].[id] as [mq].[id]">
                                                            <Identifier>
                                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                                            </Identifier>
                                                          </ScalarOperator>
                                                        </RangeExpressions>
                                                      </Prefix>
                                                    </SeekKeys>
                                                  </SeekPredicateNew>
                                                </SeekPredicates>
                                              </IndexScan>
                                            </RelOp>
                                          </NestedLoops>
                                        </RelOp>
                                      </NestedLoops>
                                    </RelOp>
                                    <Predicate>
                                      <ScalarOperator ScalarString="[peptest].[dbo].[nc_MailQueue].[id] as [mq].[id] IS NULL">
                                        <Compare CompareOp="IS">
                                          <ScalarOperator>
                                            <Identifier>
                                              <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[nc_MailQueue]" Alias="[mq]" Column="id" />
                                            </Identifier>
                                          </ScalarOperator>
                                          <ScalarOperator>
                                            <Const ConstValue="NULL" />
                                          </ScalarOperator>
                                        </Compare>
                                      </ScalarOperator>
                                    </Predicate>
                                  </Filter>
                                </RelOp>
                                <RelOp AvgRowSize="9" EstimateCPU="0.0001001" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Lazy Spool" NodeId="176" Parallel="false" PhysicalOp="Row Count Spool" EstimatedTotalSubtreeCost="0.00672168">
                                  <OutputList />
                                  <RunTimeInformation>
                                    <RunTimeCountersPerThread Thread="0" ActualRebinds="1" ActualRewinds="1736" ActualRows="1737" Batches="0" ActualEndOfScans="1737" ActualExecutions="1737" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                  </RunTimeInformation>
                                  <RowCountSpool>
                                    <RelOp AvgRowSize="9" EstimateCPU="4.18E-06" EstimateIO="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" LogicalOp="Left Semi Join" NodeId="177" Parallel="false" PhysicalOp="Nested Loops" EstimatedTotalSubtreeCost="0.00662158">
                                      <OutputList />
                                      <RunTimeInformation>
                                        <RunTimeCountersPerThread Thread="0" ActualRows="1" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" />
                                      </RunTimeInformation>
                                      <NestedLoops Optimized="false">
                                        <RelOp AvgRowSize="44" EstimateCPU="0.0001735" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="15" LogicalOp="Table Scan" NodeId="178" Parallel="false" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="0.0032985" TableCardinality="15">
                                          <OutputList />
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="15" Batches="0" ActualEndOfScans="1" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="1" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                          </RunTimeInformation>
                                          <TableScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                            <DefinedValues />
                                            <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Parameters]" TableReferenceId="1" IndexKind="Heap" Storage="RowStore" />
                                            <Predicate>
                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Parameters].[ParameterCode]=N'MAIL_FAKE_EMAIL_LIST'">
                                                <Compare CompareOp="EQ">
                                                  <ScalarOperator>
                                                    <Identifier>
                                                      <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Parameters]" Column="ParameterCode" />
                                                    </Identifier>
                                                  </ScalarOperator>
                                                  <ScalarOperator>
                                                    <Const ConstValue="N'MAIL_FAKE_EMAIL_LIST'" />
                                                  </ScalarOperator>
                                                </Compare>
                                              </ScalarOperator>
                                            </Predicate>
                                          </TableScan>
                                        </RelOp>
                                        <RelOp AvgRowSize="65" EstimateCPU="0.0001735" EstimateIO="0.003125" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row" EstimateRows="1" EstimatedRowsRead="15" LogicalOp="Table Scan" NodeId="179" Parallel="false" PhysicalOp="Table Scan" EstimatedTotalSubtreeCost="0.0032985" TableCardinality="15">
                                          <OutputList />
                                          <RunTimeInformation>
                                            <RunTimeCountersPerThread Thread="0" ActualRows="1" ActualRowsRead="8" Batches="0" ActualEndOfScans="0" ActualExecutions="1" ActualExecutionMode="Row" ActualElapsedms="0" ActualCPUms="0" ActualScans="1" ActualLogicalReads="1" ActualPhysicalReads="0" ActualReadAheads="0" ActualLobLogicalReads="0" ActualLobPhysicalReads="0" ActualLobReadAheads="0" />
                                          </RunTimeInformation>
                                          <TableScan Ordered="false" ForcedIndex="false" ForceScan="false" NoExpandHint="false" Storage="RowStore">
                                            <DefinedValues />
                                            <Object Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Parameters]" TableReferenceId="2" IndexKind="Heap" Storage="RowStore" />
                                            <Predicate>
                                              <ScalarOperator ScalarString="[peptest].[dbo].[PEPSICO_Parameters].[ValueINT]=(1) AND [peptest].[dbo].[PEPSICO_Parameters].[ParameterCode]=N'MAIL_USE_FAKE_EMAIL'">
                                                <Logical Operation="AND">
                                                  <ScalarOperator>
                                                    <Compare CompareOp="EQ">
                                                      <ScalarOperator>
                                                        <Identifier>
                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Parameters]" Column="ValueINT" />
                                                        </Identifier>
                                                      </ScalarOperator>
                                                      <ScalarOperator>
                                                        <Const ConstValue="(1)" />
                                                      </ScalarOperator>
                                                    </Compare>
                                                  </ScalarOperator>
                                                  <ScalarOperator>
                                                    <Compare CompareOp="EQ">
                                                      <ScalarOperator>
                                                        <Identifier>
                                                          <ColumnReference Database="[peptest]" Schema="[dbo]" Table="[PEPSICO_Parameters]" Column="ParameterCode" />
                                                        </Identifier>
                                                      </ScalarOperator>
                                                      <ScalarOperator>
                                                        <Const ConstValue="N'MAIL_USE_FAKE_EMAIL'" />
                                                      </ScalarOperator>
                                                    </Compare>
                                                  </ScalarOperator>
                                                </Logical>
                                              </ScalarOperator>
                                            </Predicate>
                                          </TableScan>
                                        </RelOp>
                                      </NestedLoops>
                                    </RelOp>
                                  </RowCountSpool>
                                </RelOp>
                              </NestedLoops>
                            </RelOp>
                          </ComputeScalar>
                        </RelOp>
                      </Segment>
                    </RelOp>
                  </SequenceProject>
                </RelOp>
              </ComputeScalar>
            </RelOp>
          </QueryPlan>
        </StmtSimple>
      </Statements>
    </Batch>
  </BatchSequence>
</ShowPlanXML>
