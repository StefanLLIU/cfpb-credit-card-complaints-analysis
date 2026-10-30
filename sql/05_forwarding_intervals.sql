USE CFPB_Complaints;
GO

-- Elapsed UTC time from receipt to forwarding, not company response time.
-- Bands are analytical categories, not regulatory SLA limits.
-- Run one statement at a time on memory-constrained instances.
WITH forwarding AS (
    SELECT
        DATEDIFF_BIG(
            SECOND,
            TRY_CONVERT(
                datetimeoffset(3), Date_received, 127
            ),
            TRY_CONVERT(
                datetimeoffset(3), Date_sent_to_company, 127
            )
        ) / 86400.0 AS forwarding_days
    FROM dbo.complaints_2024_raw
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(forwarding_days) AS valid_intervals,
    CAST(AVG(forwarding_days)
        AS decimal(12,2)) AS avg_forwarding_days,
    CAST(MAX(forwarding_days)
        AS decimal(12,2)) AS max_forwarding_days
FROM forwarding
OPTION (MAXDOP 1);

WITH forwarding AS (
    SELECT
        Complaint_ID,
        Company,
        Issue,
        TRY_CONVERT(
            datetimeoffset(3), Date_received, 127
        ) AS received_at,
        TRY_CONVERT(
            datetimeoffset(3), Date_sent_to_company, 127
        ) AS sent_at
    FROM dbo.complaints_2024_raw
)
SELECT
    Complaint_ID,
    Company,
    Issue,
    received_at,
    sent_at,
    CAST(
        DATEDIFF_BIG(SECOND, received_at, sent_at)
        / 86400.0
        AS decimal(12,2)
    ) AS forwarding_days
FROM forwarding
WHERE sent_at > DATEADD(DAY, 365, received_at)
OPTION (MAXDOP 1);

WITH forwarding AS (
    SELECT
        DATEDIFF_BIG(
            SECOND,
            TRY_CONVERT(
                datetimeoffset(3), Date_received, 127
            ),
            TRY_CONVERT(
                datetimeoffset(3), Date_sent_to_company, 127
            )
        ) / 86400.0 AS forwarding_days
    FROM dbo.complaints_2025_raw
)
SELECT
    COUNT(*) AS total_rows,
    COUNT(forwarding_days) AS valid_intervals,
    CAST(AVG(forwarding_days)
        AS decimal(12,2)) AS avg_forwarding_days,
    CAST(MAX(forwarding_days)
        AS decimal(12,2)) AS max_forwarding_days
FROM forwarding
OPTION (MAXDOP 1);

WITH forwarding AS (
    SELECT
        DATEDIFF_BIG(
            SECOND,
            TRY_CONVERT(
                datetimeoffset(3), Date_received, 127
            ),
            TRY_CONVERT(
                datetimeoffset(3), Date_sent_to_company, 127
            )
        ) AS forwarding_seconds
    FROM dbo.complaints_2025_raw
),
bands AS (
    SELECT
        CASE
            WHEN forwarding_seconds IS NULL OR forwarding_seconds < 0 THEN 0
            WHEN forwarding_seconds < 86400 THEN 1
            WHEN forwarding_seconds < 604800 THEN 2
            WHEN forwarding_seconds < 2592000 THEN 3
            ELSE 4
        END AS band_order,
        CASE
            WHEN forwarding_seconds IS NULL OR forwarding_seconds < 0 THEN 'Invalid interval'
            WHEN forwarding_seconds < 86400 THEN 'Under 1 day'
            WHEN forwarding_seconds < 604800 THEN '1 to under 7 days'
            WHEN forwarding_seconds < 2592000 THEN '7 to under 30 days'
            ELSE '30 days or more'
        END AS forwarding_band
    FROM forwarding
)
SELECT
    forwarding_band,
    COUNT(*) AS complaint_count,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS decimal(6,2)
    ) AS share_pct
FROM bands
GROUP BY band_order, forwarding_band
ORDER BY band_order
OPTION (MAXDOP 1);



WITH forwarding AS (
    SELECT
        DATEDIFF_BIG(
            SECOND,
            TRY_CONVERT(
                datetimeoffset(3), Date_received, 127
            ),
            TRY_CONVERT(
                datetimeoffset(3), Date_sent_to_company, 127
            )
        ) AS forwarding_seconds
    FROM dbo.complaints_2024_raw
),
bands AS (
    SELECT
        CASE
            WHEN forwarding_seconds IS NULL OR forwarding_seconds < 0 THEN 0
            WHEN forwarding_seconds < 86400 THEN 1
            WHEN forwarding_seconds < 604800 THEN 2
            WHEN forwarding_seconds < 2592000 THEN 3
            ELSE 4
        END AS band_order,
        CASE
            WHEN forwarding_seconds IS NULL OR forwarding_seconds < 0 THEN 'Invalid interval'
            WHEN forwarding_seconds < 86400 THEN 'Under 1 day'
            WHEN forwarding_seconds < 604800 THEN '1 to under 7 days'
            WHEN forwarding_seconds < 2592000 THEN '7 to under 30 days'
            ELSE '30 days or more'
        END AS forwarding_band
    FROM forwarding
)
SELECT
    forwarding_band,
    COUNT(*) AS complaint_count,
    CAST(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER ()
        AS decimal(6,2)
    ) AS share_pct
FROM bands
GROUP BY band_order, forwarding_band
ORDER BY band_order
OPTION (MAXDOP 1);