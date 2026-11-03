/*******************************************************************************
Created: 2026-11-03
Purpose: Performance improvements for dbo.vPEPSICO_send_mail_notification_bonus.
Append subsequent improvements for this view to this script.

Changes:
  (1) 2026-11-03: Index the mail subject and creation date used by the
      last-12-hours duplicate notification check.

Baseline (peptest actual plan): 1,737 scans of nc_MailQueue,
117,841,554 rows read and 18,841,239 logical reads at node 186.

The initial index intentionally has no INCLUDE (sentTo), to limit storage
and write overhead. Measure the view again before extending the index.
Existing indexes with the same leading keys are reused.
*******************************************************************************/
SET NOCOUNT ON;

IF OBJECT_ID(N'dbo.nc_MailQueue', N'U') IS NULL
BEGIN
    THROW 50001, 'Required table dbo.nc_MailQueue does not exist.', 1;
END;

-- (1) Support equality on mailSubject followed by the createDate range.
IF EXISTS
(
    SELECT 1
    FROM sys.indexes AS i
    INNER JOIN sys.index_columns AS ic_subject
        ON ic_subject.object_id = i.object_id
        AND ic_subject.index_id = i.index_id
        AND ic_subject.key_ordinal = 1
    INNER JOIN sys.columns AS c_subject
        ON c_subject.object_id = ic_subject.object_id
        AND c_subject.column_id = ic_subject.column_id
    INNER JOIN sys.index_columns AS ic_date
        ON ic_date.object_id = i.object_id
        AND ic_date.index_id = i.index_id
        AND ic_date.key_ordinal = 2
    INNER JOIN sys.columns AS c_date
        ON c_date.object_id = ic_date.object_id
        AND c_date.column_id = ic_date.column_id
    WHERE i.object_id = OBJECT_ID(N'dbo.nc_MailQueue')
        AND i.type = 2
        AND i.is_disabled = 0
        AND i.is_hypothetical = 0
        AND i.has_filter = 0
        AND c_subject.name = N'mailSubject'
        AND c_date.name = N'createDate'
)
BEGIN
    PRINT N'nc_MailQueue: an enabled index with leading keys (mailSubject, createDate) already exists; skipped.';
END
ELSE
BEGIN
    IF EXISTS
    (
        SELECT 1
        FROM sys.indexes AS i
        WHERE i.object_id = OBJECT_ID(N'dbo.nc_MailQueue')
            AND i.name = N'IX__nc_MailQueue__mailSubject_createDate'
    )
    BEGIN
        THROW 50002, 'IX__nc_MailQueue__mailSubject_createDate exists but is disabled or has a different definition. Inspect it before continuing.', 1;
    END;

    CREATE NONCLUSTERED INDEX [IX__nc_MailQueue__mailSubject_createDate]
        ON [dbo].[nc_MailQueue] ([mailSubject], [createDate])
        WITH (ONLINE = ON, MAXDOP = 2);

    PRINT N'Created IX__nc_MailQueue__mailSubject_createDate.';
END;
GO
