CREATE PROCEDURE [dbo].[SP_Report_User_Activity]
    @report_date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Based on SP_Report_Check_User_Activity: one user per local hour,
        -- using requestTime stored in UTC. Eastern Standard Time includes DST.
        SET @report_date = ISNULL(@report_date,
            CONVERT(DATE, SYSUTCDATETIME() AT TIME ZONE 'UTC'
                AT TIME ZONE 'Eastern Standard Time'));

        DECLARE @utc_from DATETIME = CONVERT(DATETIME,
            CONVERT(DATETIME2, @report_date) AT TIME ZONE 'Eastern Standard Time'
                AT TIME ZONE 'UTC');
        DECLARE @utc_to DATETIME = CONVERT(DATETIME,
            CONVERT(DATETIME2, DATEADD(DAY, 1, @report_date))
                AT TIME ZONE 'Eastern Standard Time' AT TIME ZONE 'UTC');

        ;WITH hours AS
        (
            SELECT h.hour_stat
            FROM (VALUES (0), (1), (2), (3), (4), (5), (6), (7),
                (8), (9), (10), (11), (12), (13), (14), (15),
                (16), (17), (18), (19), (20), (21), (22), (23)) AS h(hour_stat)
        ), distinct_users AS
        (
            SELECT DISTINCT
                DATEPART(HOUR, s.requestTime AT TIME ZONE 'UTC'
                    AT TIME ZONE 'Eastern Standard Time') AS hour_stat,
                s.id_user
            FROM dbo.k_stats AS s
            WHERE s.requestTime >= @utc_from
                AND s.requestTime < @utc_to
        ), hourly_counts AS
        (
            -- COUNT(1) preserves the source procedure's NULL-user behavior.
            -- On the autumn transition, deduplicate across both repeated hours.
            SELECT u.hour_stat, COUNT(1) AS count_stat
            FROM distinct_users AS u
            GROUP BY u.hour_stat
        )
        SELECT @report_date AS date_stat,
            h.hour_stat,
            ISNULL(c.count_stat, 0) AS count_stat
        FROM hours AS h
        LEFT JOIN hourly_counts AS c ON c.hour_stat = h.hour_stat
        ORDER BY h.hour_stat;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH;
END;
GO
