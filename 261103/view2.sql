SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER VIEW [dbo].[vPEPSICO_send_mail_notification_bonus_v2]
AS
-- 2026-11-03: Alternative for comparison with the current production view.
-- Values are read live; no helper tables or changes to k_m_values indexes.
-- EXISTS replaces employee-level grouping. UNION preserves recipient tuple
-- deduplication by idParent, Comment and GPID across both processes.
WITH cte_recipients AS
(
    SELECT emp.idPayee AS idParent, emp.Comment, emp.GPID
    FROM dbo.vPEPSICO_send_mail_notification_setup_bonus AS emp
    WHERE EXISTS
    (
        SELECT 1
        FROM vPEPSICO_FocalPoint_Parameters AS par WITH(NOLOCK)
        JOIN PEPSICO_Process_BonusApproval AS pba WITH(NOLOCK)
            ON 1 = 1
        JOIN py_Payee AS py WITH(NOLOCK)
            ON py.idPayee = pba.idPayee
            AND py.ss_nb = 'payee'
        JOIN hm_NodelinkPublished AS n WITH(NOLOCK)
            ON n.idTree = par.idTreePublishedManagerBonus
            AND n.idChild = pba.idPayee
        JOIN k_m_plans_payees_steps AS pps WITH(NOLOCK)
            ON pps.id_payee = py.idPayee
            AND pps.id_plan = par.idPlanBonusApproval
            AND pps.locked = 0
            AND pps.start_step > '2000-01-01'

        INNER JOIN k_m_values AS kmv_btac WITH(NOLOCK)
            ON kmv_btac.id_step = pps.id_step
            AND kmv_btac.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_assignment_correct')
        INNER JOIN k_m_values AS kmv_bais WITH(NOLOCK)
            ON kmv_bais.id_step = pps.id_step
            AND kmv_bais.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status')
        CROSS JOIN
            dbo.vPEPSICO_Bonus_Approval_Statuses AS bas
        WHERE n.idParent = emp.idPayee
            AND kmv_btac.input_value = 'SELECT'

        AND kmv_bais.input_value IN (bas.status_PREASSIGNED, bas.status_REOPENED)
    )

    UNION

    SELECT emp.idPayee AS idParent, emp.Comment, emp.GPID
    FROM dbo.vPEPSICO_send_mail_notification_setup_ratings AS emp
    WHERE EXISTS
    (
        SELECT 1
        FROM vPEPSICO_FocalPoint_Parameters AS par WITH(NOLOCK)
        JOIN PEPSICO_Process_FocalPoint AS pfp WITH(NOLOCK)
            ON 1 = 1
        JOIN py_Payee AS py WITH(NOLOCK)
            ON py.idPayee = pfp.idPayee
            AND py.ss_nb = 'payee'
        JOIN hm_NodelinkPublished AS n
            ON n.idTree = par.idTreeManager
            AND n.idChild = pfp.idPayee
        JOIN k_m_plans_payees_steps AS pps
            ON pps.id_payee = py.idPayee
            AND pps.id_plan = par.idPlanFocalPoint
            AND pps.locked = 0
            AND pps.start_step > '2000-01-01'

        LEFT JOIN PEPSICO_FocalPoint_Budget_Exclude AS be
            ON pfp.gpid = be.GPID
        LEFT JOIN k_m_values AS kmv_merit WITH(NOLOCK)
            ON kmv_merit.id_step = pps.id_step
            AND kmv_merit.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'merit_percent')
        LEFT JOIN k_m_values AS kmv_ci WITH(NOLOCK)
            ON kmv_ci.id_step = pps.id_step
            AND kmv_ci.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'ci')
        LEFT JOIN k_m_values AS kmv_ic_score WITH(NOLOCK)
            ON kmv_ic_score.id_step = pps.id_step
            AND kmv_ic_score.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'ic_score')
        WHERE n.idParent = emp.idPayee
            AND be.id IS NULL AND
            (  (pfp.is_eligible = 1 AND kmv_ci.input_value_int IS NULL)
            OR (pfp.is_merit_eligible = 1 AND kmv_merit.input_value_numeric IS NULL)
            OR (pfp.is_sc_eligible = 1 AND CASE WHEN kmv_ci.input_value_int IS NULL THEN NULL ELSE kmv_ic_score.input_value_numeric END IS NULL)
            )
    )
)
, cte_fake_mail AS(
        SELECT ValueNVARCHAR AS fake_email
        FROM PEPSICO_Parameters
        WHERE ParameterCode = 'MAIL_FAKE_EMAIL_LIST'
        AND EXISTS (SELECT ValueNVARCHAR AS fake_email
            FROM PEPSICO_Parameters
            WHERE ParameterCode = 'MAIL_USE_FAKE_EMAIL' AND ValueINT = 1)
    )

    , cte_mail_subject AS (
        SELECT mailSubject = 'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'
    )

    SELECT
        ROW_NUMBER()OVER(ORDER BY p.idParent) AS id,

        ms.mailSubject AS mailSubject,
        NULL AS mailContent,

        u.mail_user AS sentTo,
        NULL AS mailCC,
        NULL AS mailBCC,
        NULL AS mailAttach,
        GETDATE() AS createDate,
        NULL AS sentDate,
        0 AS isSent,
        NULL AS sendTryCount,
        2 AS [priority],
        1 AS sourceId,
        3 AS typeSource,
        GETDATE() AS scheduleDate,
        0 AS isDeleted,
        p.Comment,
        p.GPID
    FROM cte_recipients AS p
    JOIN k_users AS u
        ON u.id_external_user = p.idParent
        AND u.active_user = 1
        AND u.mail_user <> 'noreply@gmail.com'
    JOIN py_Payee pp
        ON pp.idPayee=p.idParent
    JOIN PEPSICO_FocalPoint_EmpCurrentPayee l
        ON l.GPID=pp.codePayee
    JOIN k_users_profiles AS kup
        ON u.id_user = kup.id_user
        AND kup.id_profile = (SELECT id_profile FROM k_profiles WHERE name_profile = 'Manager')
    JOIN cte_mail_subject AS ms
        ON 1 = 1

    LEFT JOIN nc_MailQueue AS mq
        ON mq.sentTo = u.mail_user
        AND mq.mailSubject = ms.mailSubject

        AND mq.createDate > DATEADD(HOUR, -12, GETDATE())
    LEFT JOIN cte_fake_mail AS fe
        ON 1=1
    WHERE
        mq.id IS NULL

GO
