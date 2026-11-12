-- ============================================================================
-- EXECUTION CONTEXT PARAMETERS 
-- ============================================================================
DECLARE @endDateFilter DATETIME = '3000-01-01 00:00:00.480';
DECLARE @startDateFilter DATETIME = '1980-01-01 00:00:00.288';
DECLARE @id_plan INT = 3;
DECLARE @id_profile INT = 2;
DECLARE @Culture INT = -3;
DECLARE @PayeeOnlyLevelCalculation BIT = 0;
DECLARE @IdTreeSecurity INT = 1100593;
DECLARE @IdNodeManager INT = 6776850;
DECLARE @Level NVARCHAR(1) = N'1';
DECLARE @IdLoggedInUserNode INT = 6776850;

-- [PROVEN FIX]: Restored 4-quote escape sequence ('''') to preserve the 
-- string boundary during inner dynamic SQL execution inside Kernel_SP_Process_GetPayeeIdListGeneric.
DECLARE @FilterCTE NVARCHAR(MAX) = N'InfoColumns AS 
(
SELECT * 
  FROM (SELECT ic.idPayee, ic.fullname, ic.start_date_histo, ic.end_date_histo, ic.[gpid], ic.[LevelCode], ic.[currency], ic.[salary], ic.[BDIShortTermTarget], ic.[AnnualBonusPct], ic.[PremBonusPct], ic.[idCompGroup], ic.[start_month], ic.[end_month], ic.[IsDoubleHat], ic.[IsDoubleHat_Text], ic.[BonusTeamNameProcess], ic.[login_user_status], ic.[changed_date] FROM PEPSICO_Process_BonusApproval AS ic) sub
 WHERE ''''3000-01-01 00:00:00'''' > sub.start_date_histo
   AND ''''1980-01-01 00:00:00'''' <= sub.end_date_histo
),
FilteredCTE
as
(
select distinct ic.idPayee, ic.fullname,ps.id_step 
from InfoColumns ic
inner join k_m_plans_payees_steps ps
    on ps.id_payee = ic.idPayee
 --left join k_m_plans_payees_steps_workflow ws on ps.id_step = ws.id_step
WHERE 1=1
    and ps.end_step > ic.start_date_histo
    and ps.start_step <= ic.end_date_histo
    and ps.id_plan = 3
    and ps.start_step < ''''3000-01-01 00:00:00''''
    and ps.end_step > ''''1980-01-01 00:00:00''''
     AND [idPayee] <> 16061 -- where cond
     -- wflStep filter
)';

DECLARE @UseSort BIT = 0;
DECLARE @UsePaging BIT = 1;
DECLARE @pageSize INT = 50;
DECLARE @isSelfAppraisal INT = 0;
DECLARE @WFCulture NVARCHAR(5) = N'en-US';
DECLARE @IdStepFilter INT = 0;
DECLARE @idTree INT = 4;
DECLARE @idUser INT = 12676;
DECLARE @FilterCTEParameterType NVARCHAR(4000) = N'';
DECLARE @FilterCTEParameterValue NVARCHAR(4000) = N'';
DECLARE @pageNum INT = 0;

-- ============================================================================
-- MAIN QUERY EXECUTION
-- ============================================================================
DROP TABLE IF EXISTS #PayeeStepListAll;
CREATE TABLE #PayeeStepListAll
(
	IdNode INT,
	IdPayee INT,
	Level INT,
    Sort_Order INT,
	IdStep INT,
    INDEX IX_payee NONCLUSTERED (IdPayee),
    INDEX IX_step CLUSTERED (IdStep)
);

DROP TABLE IF EXISTS #PayeeListAll;
CREATE TABLE #PayeeListAll
(
	IdNode INT,
	IdPayee INT,
	Level INT,
    Sort_Order INT,
	INDEX IX_payee CLUSTERED (IdPayee)
);

DROP TABLE IF EXISTS #WorkflowStepLocalization;
CREATE TABLE #WorkflowStepLocalization
(
    id_wflstep INT,
    id_workflow INT,
	name_step_translated NVARCHAR(500),
    sort_step INT
);

INSERT INTO #WorkflowStepLocalization
(id_wflstep, name_step_translated, id_workflow, sort_step)
SELECT ws.id_wflstep, ISNULL(RPSLOC.[value], ws.name_step), ws.id_workflow, ws.sort_step
FROM k_m_workflow_step ws
LEFT JOIN (SELECT DISTINCT name, culture, value FROM rps_localization) [RPSLOC]
ON ws.name_step = RPSLOC.[name] AND RPSLOC.culture = @WFCulture;

DECLARE @CanSeeHimSelf BIT;
DECLARE @PlanType INT;
SELECT @PlanType = id_plan_layout_type FROM k_m_plans WHERE id_plan = @id_plan;
SELECT @CanSeeHimSelf = selfAppraisal FROM k_m_plans WHERE id_plan = @id_plan;

DECLARE @isApplyFilter BIT;
DECLARE @isIncluded BIT;
DECLARE @userlevel int;
DECLARE @managerlevel int;
DECLARE @diff int;
DECLARE @IdManager int;
DECLARE @hidUserNode hierarchyid;
DECLARE @hidNodeManager hierarchyid;
DECLARE @isManagerDescendantOfLoggedUser BIT;

SELECT @IdManager = idChild FROM hm_NodelinkPublished WHERE id = @IdNodeManager AND idType = 14;
SELECT @userlevel = hidLevel, @hidUserNode = hid FROM hm_nodelinkPublishedhierarchy WHERE id_nodelinkpublished = @IdLoggedInUserNode;
SELECT @managerlevel = hidLevel, @hidNodeManager = hid, @isManagerDescendantOfLoggedUser = hid.IsDescendantOf(@hidUserNode) FROM hm_nodelinkPublishedhierarchy WHERE id_nodelinkpublished = @IdNodeManager;

DECLARE @disableStdHierAccess bit;
SELECT @disableStdHierAccess = p.value_parameter FROM k_parameters p WHERE id_parameter = -33;
SET @diff = @managerLevel- @userLevel;

IF(@IdStepFilter = 0)
BEGIN
    -- SET SELF APPRAISAL IF NOT GIVEN
	IF(@isSelfAppraisal = 0)
	BEGIN
		-- checking whether node is leaf or simplified, it should check population exclusions and security exceptions
		IF EXISTS(SELECT 1 FROM hm_NodeLinkPublishedHierarchy WHERE hidParent = @hidNodeManager)
		BEGIN
			SET @isSelfAppraisal = -1;
			SELECT @isSelfAppraisal = uplan.self_appraisal FROM k_users_profiles uprof
				JOIN k_user_plan uplan ON uplan.id_user_profile = uprof.idUserProfile and uplan.id_plan = @id_plan
			WHERE uprof.id_user = @idUser 
				AND uprof.id_profile = @id_profile
				AND uplan.self_appraisal IS NOT NULL
				AND uplan.self_appraisal != 0
		END
		ELSE
		BEGIN
			SET @isSelfAppraisal = -2;
		END
	END

    IF(@PlanType = -2) -- FORM
    BEGIN
	    insert into #PayeeListAll(IdNode, IdPayee, Level)
	    select id, idChild,@diff from hm_NodelinkPublished where id = @IdNodeManager and idType = 14
    END
    ELSE
    BEGIN
        IF(@IdTreeSecurity = 0)
	    BEGIN
            IF(@disableStdHierAccess = 0 AND (@CanSeeHimSelf = 1 OR @IdNodeManager != @IdLoggedInUserNode) AND (@isSelfAppraisal = -2 OR @isSelfAppraisal = -3) AND @isManagerDescendantOfLoggedUser = 1)
		    BEGIN
				 INSERT INTO #PayeeListAll(IdNode, IdPayee, Level)
				 SELECT DISTINCT id_NodelinkPublished, @IdManager, @diff
				 FROM  hm_NodelinkPublishedHierarchy nph 
				 WHERE nph.idChild = @IdManager
					AND nph.idType = 14
					AND nph.idTree = @idTree
			END         
        END
        ELSE
	    BEGIN
        IF (@isSelfAppraisal = -2 OR @isSelfAppraisal = -3)
		    BEGIN
			    DECLARE @filterCTEForManagerNode NVARCHAR(MAX) = N'FilteredCTE
			            AS
			            (
				            select idPayee, firstname as fullname from py_payee
				            where idPayee = '+ CAST(@IdManager AS nvarchar(10))  +'
			            )'  
			    DECLARE @ManagerNode table
			    (
                    IdNode INT,
				    IdPayee INT,
				    Level INT
			    )
			    
                insert into @ManagerNode(IdNode, IdPayee, Level)
			    exec dbo.Kernel_SP_Process_GetPayeeIdListGeneric_printonly
                    @PayeeBasedLevel=1,@IdTreeSecurity=@IdTreeSecurity,@IdNodeManager=@IdNodeManager,@Level='0',@FilterCTE=@filterCTEForManagerNode,@FilterCTEParameterType = '',@FilterCTEParameterValue='' WITH RECOMPILE
			
			    insert into #PayeeListAll(IdNode, IdPayee, Level)
			    select IdNode, IdPayee, @managerlevel from @ManagerNode
            END
        END

        --Add child nodes, Same for hierarchy security and standard hierarchy
        IF(@isSelfAppraisal = -1 OR @isSelfAppraisal = -3)
        BEGIN
	        
            IF(@IdTreeSecurity <> 0 OR (@IdTreeSecurity = 0 AND @isManagerDescendantOfLoggedUser = 1 AND @disableStdHierAccess = 0))
			BEGIN
                insert into #PayeeListAll(IdNode, IdPayee, Level)
				exec dbo.Kernel_SP_Process_GetPayeeIdListGeneric_printonly
                @PayeeBasedLevel=@PayeeOnlyLevelCalculation,@IdTreeSecurity=@IdTreeSecurity,@IdNodeManager=@IdNodeManager, @Level=@Level,@FilterCTE=@FilterCTE,@FilterCTEParameterType = @FilterCTEParameterType,@FilterCTEParameterValue=@FilterCTEParameterValue WITH RECOMPILE
			END
            UPDATE #PayeeListAll
            SET Level = @diff + Level
        END
	    ELSE IF (@isSelfAppraisal = -2)
	    BEGIN
	        UPDATE #PayeeListAll SET Level = @diff
	    END
    END

    INSERT INTO #PayeeStepListAll
    (IdNode, IdPayee, Level, Sort_Order,IdStep)
    SELECT DISTINCT pla.[IdNode] as idNode, pla.[IdPayee], pla.[Level], pla.Sort_Order,ps.id_step as IdStep
      FROM #PayeeListAll as pla
      INNER JOIN k_m_plans_payees_steps ps
      ON ps.id_payee =  pla.IdPayee
      AND ps.id_plan = @id_plan
      AND ps.start_step < @endDateFilter
      AND ps.end_step > @startDateFilter
    
update pa set pa.Sort_Order = ndp.sort_order, IdNode = ndp.Id
from #PayeeListAll pa
join hm_NodelinkPublished ndp
on pa.IdPayee = ndp.idChild and ndp.idType = 14 
where ndp.idTree = (select top 1 idTree from hm_NodelinkPublished where id = @IdNodeManager) 
    
    -- Delete Duplicate Records BY IdStep
    IF OBJECT_ID('tempdb.dbo.#PayeeStepFilter') IS NOT NULL
    BEGIN
    DELETE PSLA
    FROM #PayeeStepListAll PSLA
    WHERE PSLA.IdStep NOT IN (SELECT PSF.IdStep
							    FROM #PayeeStepFilter PSF)
    END
END
ELSE
BEGIN
	
IF(@IdTreeSecurity = 0 AND @disableStdHierAccess = 0)
 BEGIN
    INSERT INTO #PayeeStepListAll
	SELECT DISTINCT
	    nph.id_NodelinkPublished, id_payee, 1, 1, @IdStepFilter
	FROM k_m_plans_payees_steps  ps
	JOIN hm_NodelinkPublishedHierarchy nph ON ps.id_payee =  nph.idChild
	WHERE ps.id_step = @IdStepFilter
		AND ps.id_plan = @id_plan
		AND nph.idType = 14
		AND nph.idTree = @idTree
		AND nph.hid.IsDescendantOf(@hidUserNode) = 1
 END
 ELSE
 BEGIN
	DECLARE @hidSecurityRootNode hierarchyid;
	SELECT 
		@isApplyFilter = sec.is_apply_filter
		,@isIncluded = sec.is_included
		,@hidSecurityRootNode = h.hid
	FROM k_tree_security sec 
	JOIN hm_NodeLinkPublishedHierarchy h ON sec.id_tree_node_published = h.id_NodelinkPublished
	WHERE sec.id_tree_security = @idTreeSecurity 
	AND sec.begin_date < GETUTCDATE() AND (sec.end_date IS NULL OR sec.end_date > GETUTCDATE()) 
	
	IF(@hidSecurityRootNode IS NULL)
		THROW 50001, 'RETURN: No such security record in k_tree_security', 1
	
	INSERT INTO #PayeeStepListAll
	SELECT DISTINCT
	    nph.id_NodelinkPublished, id_payee, 1, 1, @IdStepFilter
	FROM k_m_plans_payees_steps  ps
	JOIN hm_NodelinkPublishedHierarchy nph ON ps.id_payee =  nph.idChild
	LEFT JOIN k_tree_security_filter tsf ON tsf.id_tree_security = @IdTreeSecurity
	LEFT JOIN pop_Population pop ON pop.idPop = tsf.id_pop
	LEFT JOIN pop_VersionContent vc ON  vc.idPopVersion = pop.lastVersion AND vc.idColl = nph.idChild
	WHERE ps.id_step = @IdStepFilter
		AND ps.id_plan = @id_plan
		AND nph.idType = 14
		AND nph.idTree = @idTree
		AND nph.hid.IsDescendantOf(@hidSecurityRootNode) = 1 
		AND (@isApplyFilter = 0							
			OR (@isIncluded = 1 AND vc.id IS NOT NULL)	
			OR (@isIncluded = 0 AND vc.id IS NULL)		
			) 
        AND NOT EXISTS 
		(
			SELECT 1
			FROM k_tree_security_exception tse
			JOIN hm_NodeLinkPublishedHierarchy e on e.id_NodelinkPublished = tse.id_tree_node_published
			WHERE tse.id_tree_security = @IdTreeSecurity
			AND nph.hid.IsDescendantOf(e.hid) = 1
		)
 END
END

DROP TABLE IF EXISTS #GlobalInfoColumns;
SELECT ic.idPayee, ic.fullname, ic.start_date_histo, ic.end_date_histo, ic.[gpid], ic.[LevelCode], ic.[currency], ic.[salary], ic.[BDIShortTermTarget], ic.[AnnualBonusPct], ic.[PremBonusPct], ic.[idCompGroup], ic.[start_month], ic.[end_month], ic.[IsDoubleHat], ic.[IsDoubleHat_Text], ic.[BonusTeamNameProcess], ic.[login_user_status], ic.[changed_date]
INTO #GlobalInfoColumns
FROM ( (SELECT ic.idPayee, ic.fullname, ic.start_date_histo, ic.end_date_histo, ic.[gpid], ic.[LevelCode], ic.[currency], ic.[salary], ic.[BDIShortTermTarget], ic.[AnnualBonusPct], ic.[PremBonusPct], ic.[idCompGroup], ic.[start_month], ic.[end_month], ic.[IsDoubleHat], ic.[IsDoubleHat_Text], ic.[BonusTeamNameProcess], ic.[login_user_status], ic.[changed_date] FROM PEPSICO_Process_BonusApproval AS ic WHERE EXISTS (SELECT ic.idPayee FROM #PayeeStepListAll pl WHERE pl.idPayee = ic.idPayee)) ) ic
WHERE @endDateFilter > ic.start_date_histo
AND @startDateFilter <= ic.end_date_histo;

CREATE NONCLUSTERED INDEX IX_idpayee ON #GlobalInfoColumns(idPayee,start_date_histo,end_date_histo);

DECLARE @TotalCount INT;
;WITH FilteredCTE
        as
        (
            select distinct ic.idPayee, ic.fullname, ps.id_step
            from #GlobalInfoColumns ic
            inner join k_m_plans_payees_steps ps
                on ps.id_payee = ic.idPayee
            WHERE 1=1
                and ps.end_step > ic.start_date_histo
                and ps.start_step <= ic.end_date_histo
                and ps.id_plan = 3
                and ps.start_step < '3000-01-01 00:00:00'
                and ps.end_step > '1980-01-01 00:00:00'
                 AND ic.[idPayee] <> 16061 
        )
SELECT @TotalCount = COUNT(*) from #PayeeStepListAll psla
join FilteredCTE p on psla.IdStep = p.id_step;

DROP TABLE IF EXISTS #PayeeStepList;
create table #PayeeStepList
(
	IdNode INT,
	IdPayee INT,
	Level INT,
	IdStep INT,
	INDEX UIX_step UNIQUE CLUSTERED (IdStep),
	INDEX IX_payee NONCLUSTERED (IdPayee)
);

;WITH FilteredCTE
        as
        (
            select distinct ic.idPayee, ic.fullname, ps.id_step
            from #GlobalInfoColumns ic
            inner join k_m_plans_payees_steps ps
                on ps.id_payee = ic.idPayee
            WHERE 1=1
                and ps.end_step > ic.start_date_histo
                and ps.start_step <= ic.end_date_histo
                and ps.id_plan = 3
                and ps.start_step < '3000-01-01 00:00:00'
                and ps.end_step > '1980-01-01 00:00:00'
                 AND ic.[idPayee] <> 16061 
        )
		    INSERT INTO #PayeeStepList
		    select psla.IdNode, psla.IdPayee, psla.Level, psla.IdStep  
		    from #PayeeStepListAll psla
            join FilteredCTE p on psla.IdStep = p.id_step
            WHERE 1 = 1
            ORDER BY  psla.Sort_Order ASC, p.fullname ASC
                        OFFSET @pageNum * @pageSize ROWS
                        FETCH NEXT @pageSize ROWS ONLY;
    
DROP TABLE IF EXISTS #ValidationSteps;
CREATE TABLE #ValidationSteps
(
	id_step				INT,
	idPayee				INT,
    Level				INT,
	WStep				NVARCHAR(50),
	WStatusId			NVARCHAR(255),
	WStatus				INT,
	WStatusByManagerId	INT	
);
CREATE CLUSTERED INDEX Cl_Ix_id_step_idPayee ON #ValidationSteps (id_step,idPayee);

DROP TABLE IF EXISTS #WorkFlowStepInfo;
CREATE TABLE #WorkFlowStepInfo
(
	id_step	 INT,
	idPayee	INT,
	id_wfl_step	INT,
	Status INT
);
CREATE CLUSTERED INDEX Cl_Ix_id_step_idPayee_#WorkFlowStepInfo ON #WorkFlowStepInfo (id_step,idPayee);

INSERT INTO #ValidationSteps
(idPayee, Level, id_step)
SELECT psl.[IdPayee], psl.[Level], psl.[IdStep]
  FROM #PayeeStepList as psl;

DECLARE @defaultWflStepProfile INT;
SELECT TOP 1 @defaultWflStepProfile = mw.id_wflstep
FROM k_m_workflow_step mw
INNER JOIN k_m_plans mp ON mw.id_workflow = mp.id_workflow AND mp.id_plan = @id_plan
INNER JOIN k_m_workflow_step_group wsg ON mw.id_wflstep = wsg.id_wflstep
INNER JOIN k_m_workflow_step_group_profile wsgp ON wsg.id_wflstepgroup = wsgp.id_wflstepgroup
WHERE wsgp.id_profile = @id_profile
ORDER BY mw.sort_step ASC, mw.id_wflstep ASC;

DECLARE @defaultWflStepGlobal INT;
SELECT TOP 1 @defaultWflStepGlobal = mw.id_wflstep
FROM k_m_workflow_step mw
INNER JOIN k_m_plans mp ON mw.id_workflow = mp.id_workflow AND mp.id_plan = @id_plan
ORDER BY mw.sort_step ASC, mw.id_wflstep ASC;

;with WorkFlowStepInfo
as
(
select vs.id_step,vs.idPayee
	   ,COALESCE(sw.id_wflstep, sw2.id_wflstep, @defaultWflStepProfile, @defaultWflStepGlobal) as id_wfl_step
	   ,COALESCE(sw.statut_step, sw2.statut_step, -1, -1) as [Status]
  from #ValidationSteps as vs
	left outer join (
		select ws.id_wflstep,ws.id_workflow,ws.name_step,ws.sort_step,ps.id_step,ps.id_payee,sw.statut_step
						  from dbo.k_m_workflow_step ws
			inner join dbo.k_m_plans mp on ws.id_workflow = mp.id_workflow
							inner join dbo.k_m_plans_payees_steps_workflow as sw
				inner join dbo.k_m_workflow_step ws2 on sw.id_workflow_step = ws2.id_wflstep
								on ws.sort_step = ws2.sort_step
			inner join dbo.k_m_plans_payees_steps ps on sw.id_step = ps.id_step and ps.id_plan = @id_plan
			inner join k_m_workflow_step_group wsg on ws.id_wflstep = wsg.id_wflstep
			inner join k_m_workflow_step_group_profile wsgp on wsg.id_wflstepgroup = wsgp.id_wflstepgroup
			where wsgp.id_profile = @id_profile
						   and mp.id_plan = @id_plan
					) as sw
		on vs.id_step = sw.id_step
		and vs.idPayee = sw.id_payee
	left outer join (
		select ws.id_wflstep,ws.id_workflow,ws.name_step,ws.sort_step,ws.id_step,ws.id_payee, ws.statut_step
						  from (
								select ws.*, ps.id_step, ps.id_payee, sw.statut_step, ROW_NUMBER() OVER(PARTITION BY ps.id_step ORDER BY sw.id) AS RN
									from dbo.k_m_workflow_step ws
									inner join  dbo.k_m_plans_payees_steps_workflow as sw
										on ws.id_wflstep = sw.id_workflow_step
									inner join dbo.k_m_plans_payees_steps ps
										on sw.id_step = ps.id_step
										and ps.id_plan = @id_plan
							) ws
						 where ws.RN = 1
					) as sw2
		on vs.id_step = sw2.id_step
		and vs.idPayee = sw2.id_payee
)
INSERT INTO #WorkFlowStepInfo
SELECT * FROM WorkFlowStepInfo;

;WITH Step2WFL as (
select vs.id_step, vs.idPayee, vs.Level, wsl.name_step_translated  as WStep, ws.id_wflstep as WStatusId, wsi.Status, wsg.level_step as levelStep, wsg.is_min_level as IsMinLevel, wsgp.id_wflstepgroupprofile
  from #ValidationSteps vs
	inner join #WorkFlowStepInfo wsi
		on vs.id_step = wsi.id_step
		and vs.idPayee = wsi.idPayee
	inner join dbo.k_m_workflow_step ws
		on wsi.id_wfl_step = ws.id_wflstep
    inner join k_m_workflow_step_group wsg on ws.id_wflstep = wsg.id_wflstep
    left join k_m_workflow_step_group_profile wsgp on wsg.id_wflstepgroup = wsgp.id_wflstepgroup AND wsgp.id_profile = @id_profile
    LEFT JOIN #WorkflowStepLocalization wsl on wsl.id_wflstep = ws.id_wflstep
)
,Step3WFL
as
(select s.*
	   ,CASE WHEN s.[Status] IN (-1, -3 /* EnWfStatus.Pending , EnWfStatus.Invalidated */)
			 THEN CASE WHEN id_wflstepgroupprofile IS NULL THEN 1 /*EnWfStatusByManager.ComingFromDown*/
                       WHEN s.Level = s.levelStep THEN 2 /*EnWfStatusByManager.PendingOnMe*/
					   WHEN s.Level > s.levelStep AND s.IsMinLevel = 1 THEN 4 /*EnWfStatusByManager.IAcceptedStillInProcess*/
					   WHEN s.Level > s.levelStep AND s.IsMinLevel != 1 THEN 1 /*EnWfStatusByManager.ComingFromDown*/
					   WHEN s.Level < s.levelStep AND s.Status = -3 /* EnWfStatus.Invalidated */ THEN 3 /*EnWfStatusByManager.Rejected*/
					   WHEN s.Level < s.levelStep AND s.Status != -3 /* EnWfStatus.Invalidated */ THEN 4 /*EnWfStatusByManager.IAcceptedStillInProcess*/
					END
			 WHEN s.[Status] = -2 /* EnWfStatus.Validated */
			 THEN 5 /* EnWfStatusByManager.AllAccepted */
			 ELSE 4 /* EnWfStatusByManager.IAcceptedStillInProcess */ END AS StatusByManager
  from Step2WFL AS s
)
update vs
   set WStatus = sw.StatusByManager, 
	   WStatusId = sw.WStatusId,
	   WStep = sw.WStep,
	   WStatusByManagerId = sw.StatusByManager
  from #ValidationSteps vs
	inner join Step3WFL sw
		on vs.id_step = sw.id_step
		and vs.idPayee = sw.idPayee;

DECLARE @MaxLevelCount INT;
Select @MaxLevelCount = MAX(Level) FROM #PayeeStepList;

DROP TABLE IF EXISTS #TreePlanRecursiveExceptionFiltered;
Create table #TreePlanRecursiveExceptionFiltered
(
	id									   INT,
	idChild								   INT,
	idParent							   INT,
	idType								   INT,
	id_tree_security_plan_level_exception  INT,
	is_override_workflow_permission		   BIT,
	is_validate							   BIT,
	is_invalidate						   BIT,
	is_mass_validate					   BIT,
	is_mass_invalidate					   BIT,
	is_edit								   BIT,
	is_read								   BIT,
	main_is_override_workflow_permission   BIT,
	main_is_validate					   BIT,
	main_is_invalidate					   BIT,
	main_is_mass_validate				   BIT,
	main_is_mass_invalidate				   BIT,
	main_is_edit						   BIT,
	main_is_read						   BIT,
	id_step								   INT
);

;WITH
TreeData
AS
(
	select id, idChild, idType, idParent, idTypeParent
	from hm_NodelinkPublished
	where idTree in 
	(
		select p.idTree from k_tree_security ts
		join hm_NodelinkPublished p
			on p.id = ts.id_tree_node_published
		where ts.id_tree_security =  1100593
	)
)
, PlanLevelExceptions
as
(
	select np.id, np.idChild, tsple.*
	from k_tree_security_plan_level tspl
	join k_m_plan_data_security pds
		on tspl.id_tree_security_plan_level = pds.id_tree_security_plan_level
	join k_tree_security ts
		on ts.id_tree_security = tspl.id_tree_security
	join k_tree_security_plan_level_exception tsple
		on tsple.id_tree_security_plan_level = tspl.id_tree_security_plan_level
	join hm_NodelinkPublished np
		on np.id = tsple.id_tree_node_published
	where pds.id_process = 3
    AND tspl.id_tree_security_plan_level IN
    (
 SELECT TOP 1
   tspl.id_tree_security_plan_level
		FROM k_tree_security_plan_level tspl
		inner join  k_m_plan_data_security pds
on tspl.id_tree_security_plan_level = pds.id_tree_security_plan_level
		where tspl.id_tree_security = 1100593 and pds.id_process = 3
     AND begin_date <= getutcdate() 
     AND (end_Date is null OR end_date > getutcdate())
    )
)
, TreePlanExceptions
as
(
	SELECT 
		tr.*, pe.id_tree_security_plan_level_exception, pe.is_override_workflow_permission, pe.is_validate, pe.is_invalidate, 
		pe.is_mass_invalidate, pe.is_mass_validate, pe.is_edit, pe.is_read
	FROM TreeData tr
	LEFT JOIN PlanLevelExceptions pe
	ON pe.id = tr.id
)
, TreePlanExceptionsInherited
AS
(
	SELECT 
		 tr.id
		,tr.idChild
		,tr.idType
		,tr.idParent
		,tr.idTypeParent
		,pe.id_tree_security_plan_level_exception
		,pe.is_override_workflow_permission
		,pe.is_validate
		,pe.is_invalidate
		,pe.is_mass_invalidate
		,pe.is_mass_validate
		,pe.is_edit
		,pe.is_read
	FROM TreeData tr
	INNER JOIN PlanLevelExceptions pe
		ON pe.id = tr.id
	UNION ALL
	SELECT 
		 pe.id
		,pe.idChild
		,pe.idType
		,pe.idParent
		,pe.idTypeParent
		,pei.id_tree_security_plan_level_exception
		,pei.is_override_workflow_permission
		,pei.is_validate
		,pei.is_invalidate
		,pei.is_mass_invalidate
		,pei.is_mass_validate
		,pei.is_edit
		,pei.is_read
	FROM
	TreePlanExceptionsInherited pei
	JOIN TreePlanExceptions pe
		ON pei.idChild = pe.idParent AND pei.idType = pe.idTypeParent
	WHERE pe.id_tree_security_plan_level_exception IS NULL
)
, ActualPlanLevelExceptions
AS
(
	SELECT 
		 tr.id
		,tr.idChild
		,tr.idType
		,tr.idParent
		,tr.idTypeParent
		,pei.id_tree_security_plan_level_exception
		,ISNULL(pei.is_override_workflow_permission, M.main_is_override_workflow_permission) is_override_workflow_permission
		,ISNULL(pei.is_validate, M.main_is_validate) is_validate
		,ISNULL(pei.is_invalidate, M.main_is_invalidate) is_invalidate
		,ISNULL(pei.is_mass_validate, M.main_is_mass_validate) is_mass_validate
		,ISNULL(pei.is_mass_invalidate, M.main_is_mass_invalidate) is_mass_invalidate
		,ISNULL(pei.is_edit, M.main_is_edit) is_edit
		,ISNULL(pei.is_read, M.main_is_read) is_read
		,M.main_is_override_workflow_permission
		,M.main_is_validate
		,M.main_is_invalidate
		,M.main_is_mass_validate
		,M.main_is_mass_invalidate
		,M.main_is_edit
		,M.main_is_read
	FROM TreeData tr
	LEFT JOIN TreePlanExceptionsInherited pei
		ON tr.id = pei.id
	CROSS JOIN 
	(
		SELECT TOP 1
		 is_override_workflow_permission main_is_override_workflow_permission
		,is_edit main_is_edit
		,is_read main_is_read
		,is_mass_validate main_is_mass_validate
		,is_mass_invalidate main_is_mass_invalidate
		,is_invalidate main_is_invalidate
		,is_validate main_is_validate
FROM k_tree_security_plan_level tspl
inner join  k_m_plan_data_security pds
on tspl.id_tree_security_plan_level = pds.id_tree_security_plan_level
where tspl.id_tree_security = 1100593  and pds.id_process = 3
        AND begin_date <= getutcdate() 
        AND (end_Date is null OR end_date > getutcdate())
	) AS M
)
,TreePlanRecursiveExceptionFiltered
as
(
	select te.* ,p.IdStep as id_step
	from ActualPlanLevelExceptions te
    join #PayeeStepList p on p.[IdPayee] = te.idChild AND te.idType = 14
)
INSERT INTO #TreePlanRecursiveExceptionFiltered 
(
 id
,idChild
,idParent
,idType
,id_tree_security_plan_level_exception
,is_override_workflow_permission
,is_validate
,is_invalidate
,is_mass_validate
,is_mass_invalidate
,is_edit
,is_read
,main_is_override_workflow_permission
,main_is_validate
,main_is_invalidate
,main_is_mass_validate
,main_is_mass_invalidate
,main_is_edit
,main_is_read
,id_step
)
select
 id
,idChild
,idParent
,idType
,id_tree_security_plan_level_exception
,is_override_workflow_permission
,is_validate
,is_invalidate
,is_mass_validate
,is_mass_invalidate
,is_edit
,is_read
,main_is_override_workflow_permission
,main_is_validate
,main_is_invalidate
,main_is_mass_validate
,main_is_mass_invalidate
,main_is_edit
,main_is_read
,id_step
from TreePlanRecursiveExceptionFiltered;

DROP TABLE IF EXISTS #SourceData;
CREATE TABLE #SourceData (
    RN INT,
    id_step INT,
    ind_field NVARCHAR(50),
    ind_field_lbl NVARCHAR(50),
    
    hasKMValueRow NVARCHAR(50),
    input_value NVARCHAR(4000),
    input_label NVARCHAR(4000)
);
CREATE NONCLUSTERED INDEX IX_SourceData ON #SourceData(RN, id_step);

;WITH filteredPayeeSteps AS
(
	select ps.* ,psla.Sort_Order as RN from k_m_plans_payees_steps ps
            left join k_m_plans_payees_steps_workflow ws on ps.id_step = ws.id_step
             join #PayeeStepListAll psla on ps.id_step = psla.IdStep 
            WHERE 1=1
), 
sourcequery AS
(
select ps.RN, kv.id_value, kv.id_ind, kv.id_field, ps.id_step, ps.start_step, ps.end_step, 
kv.input_value as input_value,CASE WHEN kf.id_field=137 THEN listTable_1.assignment_correct_value  WHEN kf.id_field=140 THEN listTable_2.BTBusinessValue  WHEN kf.id_field=141 THEN listTable_3.BTBusinessValue  WHEN kf.id_field=144 THEN listTable_4.BTBusinessValue  WHEN 1 = 1 THEN kfv.label ELSE NULL END AS input_label
, 
CAST(3 AS nvarchar(5)) + '_' + CAST(mpi.id_ind AS nvarchar(5)) + '_' + CAST(mif.id_field AS nvarchar(5)) as ind_field,
CASE WHEN kf.id_control_type in (-1, -7)
THEN
CAST(3 AS nvarchar(5)) + '_' + CAST(mpi.id_ind AS nvarchar(5)) + '_' + CAST(mif.id_field AS nvarchar(5)) + '_lbl' 
ELSE NULL
END as ind_field_lbl,
CAST(3 AS nvarchar(5)) + '_' + CAST(mpi.id_ind AS nvarchar(5)) + '_' + CAST(mif.id_field AS nvarchar(5))+'_' +case when kv.id_value is not null then '1' else '0' end hasKMValueRow
  from filteredPayeeSteps ps
    inner join k_m_plans_indicators mpi
		on ps.id_plan = mpi.id_plan
	inner join k_m_indicators_fields mif
		on mpi.id_ind = mif.id_ind
	left outer join dbo.Kernel_View_k_m_values kv
		on kv.id_step = ps.id_step and kv.id_ind = mpi.id_ind and kv.id_field = mif.id_field 
    left outer join k_m_fields kf
		on kv.id_field = kf.id_field
 left outer join dbo.k_m_fields_values kfv
                                        on kv.id_field = kfv.id_field
                                        and kv.input_value = kfv.value
                                        and kfv.culture = @Culture
                                        and kf.id_control_type = -1
  left outer join PEPSICO_bonus_team_assignment_correct listTable_1
                                    on kv.id_field = 137
                                    and kv.input_value = listTable_1.assignment_correct_code
                                    and kf.id_control_type = -7 left outer join vPEPSICO_bonus_team_step1_business listTable_2
                                    on kv.id_field = 140
                                    and kv.input_value = listTable_2.BTBusinessCode
                                    and kf.id_control_type = -7 left outer join vPEPSICO_bonus_team_step2_business listTable_3
                                    on kv.id_field = 141
                                    and kv.input_value = listTable_3.BTBusinessCode
                                    and kf.id_control_type = -7 left outer join vPEPSICO_bonus_team_step3_business listTable_4
                                    on kv.id_field = 144
                                    and kv.input_value = listTable_4.BTBusinessCode
                                    and kf.id_control_type = -7
 where ps.id_plan = 3
   and ps.id_payee IN (SELECT [IdPayee] FROM #PayeeStepList)
)
 INSERT INTO #SourceData
                        SELECT RN, id_step, ind_field, ind_field_lbl, hasKMValueRow, CAST(input_value AS NVARCHAR(4000)), CAST(input_label AS NVARCHAR(4000))
                        FROM sourcequery
                        ;WITH __sourceDataMaterialized AS (SELECT 1 AS __x) 
,  tmp_InfoColumns AS (
    SELECT ic.* 
    FROM #GlobalInfoColumns ic
    WHERE ic.idPayee IN (SELECT [IdPayee] FROM #PayeeStepList) 
)
select  psl.IdNode, psl.Level as Level, pvt.id_step,ps.uid_reference, ic.idPayee, ic.fullname,
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[gpid]
WHEN is_override_workflow_permission = 0 then ic.[gpid]
END AS [gpid],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[LevelCode]
WHEN is_override_workflow_permission = 0 then ic.[LevelCode]
END AS [LevelCode],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[currency]
WHEN is_override_workflow_permission = 0 then ic.[currency]
END AS [currency],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[salary]
WHEN is_override_workflow_permission = 0 then ic.[salary]
END AS [salary],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[BDIShortTermTarget]
WHEN is_override_workflow_permission = 0 then ic.[BDIShortTermTarget]
END AS [BDIShortTermTarget],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[AnnualBonusPct]
WHEN is_override_workflow_permission = 0 then ic.[AnnualBonusPct]
END AS [AnnualBonusPct],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[PremBonusPct]
WHEN is_override_workflow_permission = 0 then ic.[PremBonusPct]
END AS [PremBonusPct],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[idCompGroup]
WHEN is_override_workflow_permission = 0 then ic.[idCompGroup]
END AS [idCompGroup],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[start_month]
WHEN is_override_workflow_permission = 0 then ic.[start_month]
END AS [start_month],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[end_month]
WHEN is_override_workflow_permission = 0 then ic.[end_month]
END AS [end_month],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[IsDoubleHat]
WHEN is_override_workflow_permission = 0 then ic.[IsDoubleHat]
END AS [IsDoubleHat],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[IsDoubleHat_Text]
WHEN is_override_workflow_permission = 0 then ic.[IsDoubleHat_Text]
END AS [IsDoubleHat_Text],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[BonusTeamNameProcess]
WHEN is_override_workflow_permission = 0 then ic.[BonusTeamNameProcess]
END AS [BonusTeamNameProcess],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[login_user_status]
WHEN is_override_workflow_permission = 0 then ic.[login_user_status]
END AS [login_user_status],
CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
WHEN is_override_workflow_permission = 1 AND is_read = 1 then ic.[changed_date]
WHEN is_override_workflow_permission = 0 then ic.[changed_date]
END AS [changed_date] ,case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_137]
else 
 pvt.[3_21_137]  end as [3_21_137], pvt.[3_21_137_lbl] AS [3_21_137_lbl],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_138]
else 
 pvt.[3_21_138]  end as [3_21_138],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_139]
else 
 pvt.[3_21_139]  end as [3_21_139],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_143]
else 
 pvt.[3_21_143]  end as [3_21_143],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_140]
else 
 pvt.[3_21_140]  end as [3_21_140], pvt.[3_21_140_lbl] AS [3_21_140_lbl],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_141]
else 
 pvt.[3_21_141]  end as [3_21_141], pvt.[3_21_141_lbl] AS [3_21_141_lbl],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_144]
else 
 pvt.[3_21_144]  end as [3_21_144], pvt.[3_21_144_lbl] AS [3_21_144_lbl],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_21_142]
else 
 pvt.[3_21_142]  end as [3_21_142],case when pef.is_override_workflow_permission = 1 AND pef.is_read = 0 then null
when is_override_workflow_permission = 1 AND is_read = 1 then 
pvt.[3_12_54]
else 
 pvt.[3_12_54]  end as [3_12_54], pvt.[3_12_54_lbl] AS [3_12_54_lbl] , case when pef.is_override_workflow_permission = 1 then 1
    when pef.is_override_workflow_permission = 0 then vs.WStatus
                                                    else vs.WStatus end AS S_3,CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
	WHEN is_override_workflow_permission = 1 AND is_read = 1 then vs.WStatusId
    WHEN is_override_workflow_permission = 0 then vs.WStatusId
                                                end as WStatusId,CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
	WHEN is_override_workflow_permission = 1 AND is_read = 1 then vs.WStep
    WHEN is_override_workflow_permission = 0 then vs.WStep
                                                    end AS S_4,CASE WHEN pef.is_override_workflow_permission = 1 AND pef.is_read = 0 THEN null
	WHEN is_override_workflow_permission = 1 AND is_read = 1 then vs.WStatusByManagerId
    WHEN is_override_workflow_permission = 0 THEN vs.WStatusByManagerId
                                                end as WStatusByManagerId  ,1 as is_tree_security_exist
    ,pef.id_tree_security_plan_level_exception 
    ,pef.is_override_workflow_permission
	,pef.is_read
	,pef.is_edit, @TotalCount as total_count
                    from (
                        select RN, id_step, pvt.[3_21_137] as [3_21_137],pvt.[3_21_137_lbl] as [3_21_137_lbl],ISNULL(pvt.[3_21_137_0],0) + ISNULL(pvt.[3_21_137_1],0) AS [3_21_137_HasKMValue],pvt.[3_21_138] as [3_21_138],pvt.[3_21_138_lbl] as [3_21_138_lbl],ISNULL(pvt.[3_21_138_0],0) + ISNULL(pvt.[3_21_138_1],0) AS [3_21_138_HasKMValue],pvt.[3_21_139] as [3_21_139],pvt.[3_21_139_lbl] as [3_21_139_lbl],ISNULL(pvt.[3_21_139_0],0) + ISNULL(pvt.[3_21_139_1],0) AS [3_21_139_HasKMValue],pvt.[3_21_143] as [3_21_143],pvt.[3_21_143_lbl] as [3_21_143_lbl],ISNULL(pvt.[3_21_143_0],0) + ISNULL(pvt.[3_21_143_1],0) AS [3_21_143_HasKMValue],pvt.[3_21_140] as [3_21_140],pvt.[3_21_140_lbl] as [3_21_140_lbl],ISNULL(pvt.[3_21_140_0],0) + ISNULL(pvt.[3_21_140_1],0) AS [3_21_140_HasKMValue],pvt.[3_21_141] as [3_21_141],pvt.[3_21_141_lbl] as [3_21_141_lbl],ISNULL(pvt.[3_21_141_0],0) + ISNULL(pvt.[3_21_141_1],0) AS [3_21_141_HasKMValue],pvt.[3_21_144] as [3_21_144],pvt.[3_21_144_lbl] as [3_21_144_lbl],ISNULL(pvt.[3_21_144_0],0) + ISNULL(pvt.[3_21_144_1],0) AS [3_21_144_HasKMValue],pvt.[3_21_142] as [3_21_142],pvt.[3_21_142_lbl] as [3_21_142_lbl],ISNULL(pvt.[3_21_142_0],0) + ISNULL(pvt.[3_21_142_1],0) AS [3_21_142_HasKMValue],pvt.[3_12_54] as [3_12_54],pvt.[3_12_54_lbl] as [3_12_54_lbl],ISNULL(pvt.[3_12_54_0],0) + ISNULL(pvt.[3_12_54_1],0) AS [3_12_54_HasKMValue]
                        from (
                            select RN, id_step, MIN(CASE WHEN ind_field = '3_21_137' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_137],MIN(CASE WHEN hasKMValueRow = '3_21_137_0' THEN '1' END) as [3_21_137_0],MIN(CASE WHEN hasKMValueRow = '3_21_137_1' THEN '1' END) as [3_21_137_1],MIN(CASE WHEN ind_field_lbl = '3_21_137_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_137_lbl],MIN(CASE WHEN ind_field = '3_21_138' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_138],MIN(CASE WHEN hasKMValueRow = '3_21_138_0' THEN '1' END) as [3_21_138_0],MIN(CASE WHEN hasKMValueRow = '3_21_138_1' THEN '1' END) as [3_21_138_1],MIN(CASE WHEN ind_field_lbl = '3_21_138_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_138_lbl],MIN(CASE WHEN ind_field = '3_21_139' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_139],MIN(CASE WHEN hasKMValueRow = '3_21_139_0' THEN '1' END) as [3_21_139_0],MIN(CASE WHEN hasKMValueRow = '3_21_139_1' THEN '1' END) as [3_21_139_1],MIN(CASE WHEN ind_field_lbl = '3_21_139_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_139_lbl],MIN(CASE WHEN ind_field = '3_21_143' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_143],MIN(CASE WHEN hasKMValueRow = '3_21_143_0' THEN '1' END) as [3_21_143_0],MIN(CASE WHEN hasKMValueRow = '3_21_143_1' THEN '1' END) as [3_21_143_1],MIN(CASE WHEN ind_field_lbl = '3_21_143_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_143_lbl],MIN(CASE WHEN ind_field = '3_21_140' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_140],MIN(CASE WHEN hasKMValueRow = '3_21_140_0' THEN '1' END) as [3_21_140_0],MIN(CASE WHEN hasKMValueRow = '3_21_140_1' THEN '1' END) as [3_21_140_1],MIN(CASE WHEN ind_field_lbl = '3_21_140_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_140_lbl],MIN(CASE WHEN ind_field = '3_21_141' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_141],MIN(CASE WHEN hasKMValueRow = '3_21_141_0' THEN '1' END) as [3_21_141_0],MIN(CASE WHEN hasKMValueRow = '3_21_141_1' THEN '1' END) as [3_21_141_1],MIN(CASE WHEN ind_field_lbl = '3_21_141_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_141_lbl],MIN(CASE WHEN ind_field = '3_21_144' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_144],MIN(CASE WHEN hasKMValueRow = '3_21_144_0' THEN '1' END) as [3_21_144_0],MIN(CASE WHEN hasKMValueRow = '3_21_144_1' THEN '1' END) as [3_21_144_1],MIN(CASE WHEN ind_field_lbl = '3_21_144_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_144_lbl],MIN(CASE WHEN ind_field = '3_21_142' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_21_142],MIN(CASE WHEN hasKMValueRow = '3_21_142_0' THEN '1' END) as [3_21_142_0],MIN(CASE WHEN hasKMValueRow = '3_21_142_1' THEN '1' END) as [3_21_142_1],MIN(CASE WHEN ind_field_lbl = '3_21_142_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_21_142_lbl],MIN(CASE WHEN ind_field = '3_12_54' THEN CAST(input_value AS NVARCHAR(4000)) END) as [3_12_54],MIN(CASE WHEN hasKMValueRow = '3_12_54_0' THEN '1' END) as [3_12_54_0],MIN(CASE WHEN hasKMValueRow = '3_12_54_1' THEN '1' END) as [3_12_54_1],MIN(CASE WHEN ind_field_lbl = '3_12_54_lbl' THEN CAST(input_label AS NVARCHAR(4000)) END) as [3_12_54_lbl]
                            from #SourceData
                            group by RN, id_step
                        ) as pvt
                    ) as pvt
                    inner join dbo.k_m_plans_payees_steps ps
                        on pvt.id_step = ps.id_step
    left outer join #TreePlanRecursiveExceptionFiltered pef
		on pef.idChild = ps.id_payee and pef.id_step = ps.id_step
    
    inner join #ValidationSteps vs
        on ps.id_step = vs.id_step
        and ps.id_payee = vs.idPayee
    
    outer apply (
          select top 1 ic.*
            from tmp_InfoColumns ic
              inner join k_m_plans_payees_steps ps3
            on ps3.id_payee = ic.idPayee
            and ps3.end_step > ic.start_date_histo
            and ps3.start_step <= ic.end_date_histo
            and ps3.id_plan = @id_plan
          where ps.id_step = ps3.id_step 
          order by ic.start_date_histo DESC
            ) ic
    
join #PayeeStepList psl
    on ps.id_step = psl.IdStep 
    WHERE 1 = 1  AND ic.[idPayee] <> 16061  
  order by ic.fullname, ps.start_step;
