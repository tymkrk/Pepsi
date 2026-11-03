/****** Object:  View [dbo].[vPEPSICO_send_mail_notification_bonus]    Script Date: 11/3/2026 2:31:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vPEPSICO_send_mail_notification_bonus] 
AS

-- Created by Yoann Schrago 20231127 get values to insert into nc_MailQueue for Bonus Verification 
-- modified by Kamil Roganowicz 20241202 - #118941 changed header and footer
-- modified by Yoann Schrago 20250826 B2025-05 change condition from UNAPPROVED to PENDING
-- modified by Przemyslaw Kot 20251017 - PEPPRT26-35 and PEPPRT26-37 Join notification for Bonus and Ratings processes
-- modified by Przemyslaw Kot 20251120 - PEPPRT26-40 comment out part of code for mail content and move it to newly created vPEPSICO_send_mail_notification_bonus_with_mail_content view
-- modified by Przemyslaw Kot 20251203 - PEPPRT26-99 change layout of notification, mainly logo, due to PepsiCo rebranding
-- modified by Przemyslaw Kot 20251209 - PEPPRT26-104 adjust logic for Bonus process - not select employees with 'APPROVED' value in 'Status' field
-- modified by Przemyslaw Kot 20251211 - PEPPRT26-105 adjust logic for Ratings process - not select employees with entries in PEPSICO_FocalPoint_Budget_Exclude table
-- modified by Przemyslaw Kot 20261002 - PEPPRT26-143 replace APPROVED static value with APPROVED and VALIDATED values queried from vPEPSICO_Bonus_Approval_Statuses view
-- modified by Przemyslaw Kot 20261027 - PEPPRT26-150 adjust the code and html to the new requirements in 2026 comp round

	-- list of employees with direct managers from Bonus Process with SELECT status in Bonus Verification field
	WITH cte_bonus AS (
		SELECT 
			pba.idPayee,
			pba.fullname,
			py.firstname,
			py.lastname,
			'Bonus' AS process_name,
			emp.Comment,
			n.idParent,
			emp.GPID
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
		JOIN vPEPSICO_send_mail_notification_setup_bonus as emp
			ON emp.idPayee = n.idParent
		LEFT JOIN k_m_values AS kmv_btac WITH(NOLOCK)
			ON kmv_btac.id_step = pps.id_step
			AND kmv_btac.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_team_assignment_correct')
		LEFT JOIN k_m_values AS kmv_bais WITH(NOLOCK)
			ON kmv_bais.id_step = pps.id_step
			AND kmv_bais.id_field = (SELECT id_field FROM k_m_fields WHERE code_field = 'bonus_approval_involvement_status')
		CROSS JOIN
			dbo.vPEPSICO_Bonus_Approval_Statuses AS bas
		WHERE kmv_btac.input_value = 'SELECT'
		--AND kmv_bais.input_value <> 'APPROVED'
		--AND kmv_bais.input_value NOT IN (bas.status_APPROVED, bas.status_VALIDATED)
		AND kmv_bais.input_value IN (bas.status_PREASSIGNED, bas.status_REOPENED)
		GROUP BY pba.idPayee, pba.fullname, py.firstname, py.lastname, emp.Comment, n.idParent, emp.GPID
		--ORDER BY n.idParent ASC
	)

	-- now work out who to send an email to in regard to Bonus process
	, cte_bonus_email AS (
		SELECT DISTINCT 
			t.idParent,
			t.Comment,
			t.GPID
		FROM cte_bonus AS t
	)

	--list of employees with direct managers from Ratings Process with suitable conditions
	, cte_ratings AS (
		SELECT 
			pfp.idPayee,
			pfp.fullname,
			py.firstname,
			py.lastname,
			kmv_ci.input_value_int AS rating,
			CASE WHEN kmv_ci.input_value_int IS NULL THEN NULL ELSE kmv_ic_score.input_value_numeric END AS ic_score,
			kmv_merit.input_value_numeric AS merit_percent,
			pfp.is_eligible,
			pfp.is_merit_eligible,
			pfp.is_sc_eligible,
			'Ratings' AS process_name,
			emp.Comment,
			n.idParent,
			emp.GPID
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
		JOIN vPEPSICO_send_mail_notification_setup_ratings as emp
			ON emp.idPayee = n.idParent
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
		WHERE
			be.id IS NULL AND
			(  (pfp.is_eligible = 1 AND kmv_ci.input_value_int IS NULL) 
			OR (pfp.is_merit_eligible = 1 AND kmv_merit.input_value_numeric IS NULL) 
			OR (pfp.is_sc_eligible = 1 AND CASE WHEN kmv_ci.input_value_int IS NULL THEN NULL ELSE kmv_ic_score.input_value_numeric END IS NULL)
			)
	)

	, cte_ratings_grouped AS (
		SELECT
			idPayee,
			fullname,
			firstname,
			lastname,
			process_name,
			Comment,
			idParent,
			GPID
		FROM cte_ratings
		GROUP BY idPayee, fullname, firstname, lastname, process_name, Comment, idParent, GPID
	)

	-- now work out who to send an email to in regard to Ratings process
	, cte_ratings_email AS (
		SELECT DISTINCT 
			t.idParent,
			t.Comment,
			t.GPID
		FROM cte_ratings_grouped AS t
	)

	-- combining lists of managers to whom notifications should be sent
	, cte_common_bonus_and_ratings_email AS (
		SELECT
			idParent
			,Comment
			,GPID
		FROM cte_bonus_email

		UNION

		SELECT
			idParent
			,Comment
			,GPID
		FROM cte_ratings_email
	)
/*
	-- combining lists of employees with their data whose notifications concern
	, cte_common_bonus_and_ratings AS (
		SELECT
			idPayee
			,fullname
			,firstname
			,lastname
			,prt_message
			,idParent
			,ROW_NUMBER() OVER (PARTITION BY idParent ORDER BY idPayee ASC) AS rn
		FROM
			(
			SELECT
				ug.idPayee
				,ug.fullname
				,ug.firstname
				,ug.lastname
				,CASE
					WHEN ug.cnt = 1 AND b.process_name = 'Bonus' THEN 'Missing Bonus Validation'
					WHEN ug.cnt = 1 AND r.process_name = 'Ratings' THEN 'Missing Performance Rating and Merit Increase'
					WHEN ug.cnt = 2 THEN 'Missing Performance Rating, Merit Increase, I/C Score and Bonus Validation'
				END AS prt_message
				,ug.idParent
			FROM
				(
				SELECT
					u.idPayee
					,u.fullname
					,u.firstname
					,u.lastname
					,u.idParent
					,COUNT(*) AS cnt
				FROM
					(
					SELECT
						idPayee
						,fullname
						,firstname
						,lastname
						--,prt_message
						,process_name
						,idParent
					FROM cte_bonus

					UNION ALL

					SELECT
						idPayee
						,fullname
						,firstname
						,lastname
						--,prt_message
						,process_name
						,idParent
					FROM cte_ratings_grouped
					) AS u
				GROUP BY u.idPayee, u.fullname, u.firstname, u.lastname, u.idParent
				) AS ug
			LEFT JOIN cte_bonus AS b
				ON ug.idPayee = b.idPayee
			LEFT JOIN cte_ratings_grouped AS r
				ON ug.idPayee = r.idPayee
		) AS f
	)

	, cte_top25 AS (
		SELECT
			idPayee
			,fullname
			,firstname
			,lastname
			,prt_message
			,idParent
		FROM cte_common_bonus_and_ratings
		WHERE rn <= 25
	)
*/
	, cte_fake_mail AS(
		SELECT ValueNVARCHAR AS fake_email
		FROM PEPSICO_Parameters 
		where ParameterCode = 'MAIL_FAKE_EMAIL_LIST'
		AND exists (SELECT ValueNVARCHAR AS fake_email
			FROM PEPSICO_Parameters 
			WHERE ParameterCode = 'MAIL_USE_FAKE_EMAIL' AND ValueINT = 1)
	)

	, cte_mail_subject AS (
		SELECT mailSubject = 'ACTION REQUIRED: Complete Your Year-End Actions and Bonus Validation'
	)
/*
	, cte_mail_header AS (
		SELECT mail_header = '<html>
								<body align="left" style="font-size:11.0pt; font-family: Gilroy">
									<table role="presentation"
										width="100%"
										cellspacing="0"
										cellpadding="0"
										border="0">
											<tr>
											    <td align="left">
											        <img src="https://digitalassets.pepsico.com/asset/84b63d70-15cc-4a7d-963a-ca4780c8e1ce/pepsico_email_header.png"
											             alt="Performance Management Header"
											             width="800"
											             style="display:block;width:100%;max-width:800px;height:auto;border:0;">
											    </td>
											</tr>
									</table>
								<br>'
	)

	, cte_mail_body_1 AS (
		SELECT mail_body_1 = '<p>This is an automated message from the Performance Rewards Tool (PRT) to inform you that a <b>Performance Rating, Merit Increase and/or Individual Contribution Score (I/C)</b> has not been entered, and/or a <b>Bonus Team</b> has not been validated for one or more members of your team (I/C Scores and Bonus Validation are required for annual bonus eligible employees only).</p><br>
							<p>As a manager you are responsible for making pay decisions for your team, including base salary increases, I/C scores that impact bonus payouts and validating bonus records.</p><br>
							<p>The table below shows the missing data for your team. Ensure you review and enter this information in PRT by <b>Friday December 18<sup>th</sup></b>.</p><br>'
	)

	, cte_mail_body_2 AS (
		SELECT mail_body_2 = '<p><br>Click here to access <a href="https://passport.beqom.com/Pepsico" target="_blank">Performance Rewards Tool</a> and select &ldquo;My Team&rdquo; to enter any missing data for your team.</p><br>
							<p>Watch these videos to learn more about how to enter <a href="https://www.mypepsico.com/sys_attachment.do?sys_id=129fac944719be54f153dc41516d4313&view=true" target="_blank">Performance Ratings/Pay Decisions</a> and <a href="https://www.mypepsico.com/sys_attachment.do?sys_id=d99f2c944719be54f153dc41516d43df&view=true" target="_blank">Validate the Bonus Records</a> or go to <a href="https://pepsico.service-now.com/mypepsico?id=mypepsico_emp_taxonomy_topic_new&topic_id=cc3b9cf48323da10294d97d6feaad300" target="_blank">&ldquo;Finish Strong&rdquo; Page</a> to get more information on Year-End Process.</p><br>
							<p>If you require any additional support on Performance Rewards Tool or any inputs in the system, raise the ticket through <a href="https://pepsico.service-now.com/mypepsico?id=sc_cat_item&table=sc_cat_item&sys_id=4438f701d5f64fd475af4025e1c5eb1c" target="_blank">the dedicated myServices form</a>.</p><br>
							<p>Best regards,
							<br>Performance Management Process Team.
							<br></p><br>_____________</p><br>
							<br><p><b>Key Year-End Dates Reminder:</b></p><br>
							<p>December 11<sup>th</sup>: submit <a href="https://pepsico.service-now.com/mypepsico?id=sc_cat_item&sys_id=d88769a94756e11013ca96f4126d431b" target="_blank">Job Evaluation</a> request, if required for promotions effective at Focal Point (March 1<sup>st</sup>)</p><br>
							<p>December 18<sup>th</sup>: complete the Year-End inputs and bonus validation for your teams in <a href="https://passport.beqom.com/Pepsico" target="_blank">PRT</a></p><br>
							<p>January 6<sup>th</sup>: document your Year-End comments in each direct report''s <a href="https://nam12.safelinks.protection.outlook.com/?url=https%3A%2F%2Fcontactmonkey.com%2Fapi%2Fv1%2Ftracker%3Fcm_session%3D4dbbac7b-dde1-43a1-b8d4-d324099402ca%26cs%3Dabd380b5-25d2-4c6e-b4d8-455b253b3110%26i%3D3de9e68cf92546372521cd197ec434205d24cd73b%26cm_type%3Dlink%26cm_link%3D5957ba78-b112-4eec-adc4-e2a0005789a3%26cm_destination%3Dhttps%3A%2F%2Fpm8-cncdn.successfactors.com%2Fsf%2Fpmreviews%3Fbplte_company%3DPepsiCoECPROD%26_s.crb%3DJ9hugKAqfnjGCN84ttU33hncQGORP2SAMCK08OGa7PM%253d&data=05%7C02%7CTiffany.Gramarossa%40pepsico.com%7C63d8b1d84f9a407acda908dcfcddb6e0%7C42cc3295cd0e449cb98e5ce5b560c1d3%7C0%7C0%7C638663279218105291%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C0%7C%7C%7C&sdata=fGw2LBTRqpZ7FG7GGGDER35u%2FvNTdHjge7WSXQaJmwE%3D&reserved=0" target="_blank">PDR</a> form</p><br>
							<p>January 22<sup>nd</sup>: submit promotion requests effective at Focal Point (March 1<sup>st</sup>), via the <a href="https://pepsico.service-now.com/mypepsico?id=sc_cat_item&sys_id=6e94680ac3fb3150b1f5981f050131fc" target="_blank">''Request Compensation Offer''</a> service in myServices</p><br>
							<p>February 1<sup>st</sup> - March 2<sup>nd</sup>: Blackout window</p><br>
							<p>February 22<sup>nd</sup> - March 3<sup>rd</sup>: deliver Year-End performance feedback to your direct reports</p><br>
							'
	)



	, cte_table_def AS (
		SELECT table_def = '
							<table border="0" cellspacing="0" cellpadding="4" width="800">  
							<tbody><tr>  
							 <td width="200" valign="center" style="text-align:center;font-size:10.0pt;mso-bidi-font-family:Gilroy;mso-bidi-theme-font:Gilroy;  
							 border-top:solid; border-left:solid;border-right:solid;border-bottom:solid;border-width:1px ;"><font style="font-weight:bold">Employee Name</font>  
							 </td>
							  <td width="600" valign="center" style="text-align:center;font-size:10.0pt;mso-bidi-font-family:Gilroy;mso-bidi-theme-font:Gilroy;  
							 border-top:solid; border-left:none;border-right:solid;border-bottom:solid;border-width:1px ;"><font style="font-weight:bold">Missing Data in PRT</font>  
							 </td>
							</tr>  
							'
	)

	, cte_table_content AS (
		SELECT table_content = CONCAT(td.table_def, STRING_AGG(CAST('
								<tr>  
								<td width="200" valign="center" style="text-align:left;font-size:10.0pt;mso-bidi-font-family:Gilroy;mso-bidi-theme-font:Gilroy;  
								border-top:none; border-left:solid;border-right:solid;border-bottom:solid;border-width:1px">' + fullname + '  
								</td>  

								<td width="600" valign="center" style="text-align:left;font-size:10.0pt;mso-bidi-font-family:Gilroy;mso-bidi-theme-font:Gilroy;  
								border-top:none; border-left:none;border-right:solid;border-bottom:solid;border-width:1px">' + prt_message + '  
								</td>
								</tr>
								' AS VARCHAR(MAX)), ' ') WITHIN GROUP (ORDER BY t25.lastname ASC, t25.firstname ASC) )
				,t25.idParent
		FROM cte_table_def AS td
		INNER JOIN cte_top25 AS t25
			ON 1= 1
		GROUP BY td.table_def, t25.idParent
	)

	, cte_table_complete AS (
		SELECT table_complete_text = CONCAT(table_content, 
									'</tbody>  
									</table>'  
									)
				,idParent
		FROM cte_table_content
	)

	, cte_mail_footer AS (
		SELECT mail_footer = '<table role="presentation"
								width="100%"
								cellspacing="0"
								cellpadding="0"
								border="0">
									<tr>
									    <td align="left">
									        <img src="https://digitalassets.pepsico.com/asset/964604ee-be42-4e10-9713-82c6e6bfef3c/pepsico_email_footer.png"
									             alt="PepsiCo Footer"
									             width="800"
									             style="display:block;width:100%;max-width:800px;height:auto;border:0;">
									    </td>
									</tr>
							</table>
						</body>
					</html>'
	)

	, cte_mail_content AS (
		SELECT mailContent = CONCAT(mh.mail_header, mb1.mail_body_1, t.table_complete_text, mb2.mail_body_2, mf.mail_footer)
				,idParent
		FROM cte_table_complete AS t
		INNER JOIN cte_mail_body_1 AS mb1
			ON 1= 1
		INNER JOIN cte_mail_body_2 AS mb2
			ON 1 = 1
		INNER JOIN cte_mail_header AS mh
			ON 1 = 1
		INNER JOIN cte_mail_footer AS mf
			ON 1 = 1
	)
*/
	SELECT
		ROW_NUMBER()OVER(ORDER BY p.idParent) AS id,
		--CONCAT('(sent to: ', ISNULL(fe.fake_email, u.mail_user), ') ', ms.mailSubject) AS mailSubject,
		ms.mailSubject AS mailSubject,
		NULL AS mailContent,	--mc.mailContent,
		--ISNULL(fe.fake_email, u.mail_user) AS sentTo,
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
	FROM cte_common_bonus_and_ratings_email AS p
	JOIN k_users AS u
		ON u.id_external_user = p.idParent
		AND u.active_user = 1
		AND u.mail_user <> 'noreply@gmail.com'
	JOIN py_Payee pp
		on pp.idPayee=p.idParent
	JOIN PEPSICO_FocalPoint_EmpCurrentPayee l
		on l.GPID=pp.codePayee
	JOIN k_users_profiles AS kup
		ON u.id_user = kup.id_user
		AND kup.id_profile = (SELECT id_profile FROM k_profiles WHERE name_profile = 'Manager')
	JOIN cte_mail_subject AS ms
		ON 1 = 1
--	JOIN cte_mail_content AS mc
--		ON mc.idParent = p.idParent
	LEFT JOIN nc_MailQueue AS mq
		ON mq.sentTo = u.mail_user
		AND mq.mailSubject = ms.mailSubject
		--AND mq.isSent = 1
		--AND mq.createDate > DATEADD(day, -1, getdate())
		AND mq.createDate > DATEADD(HOUR, -12, getdate())
	LEFT JOIN cte_fake_mail AS fe
		ON 1=1
	WHERE 
		mq.id IS NULL-- and 
	--	l.LevelCode in ('L00','L01','L02','L03','L04','L05','L06','L07','L08','L09','L10','L11')
		--l.LevelCode in ('LG6','LG7','LG8')

GO


