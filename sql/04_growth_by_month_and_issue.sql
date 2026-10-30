USE CFPB_Complaints;
GO

-- Aggregate each source before joining; retain unmatched issue categories.
SELECT
    LEFT(Date_received, 7) AS received_month,
    COUNT(*) AS complaint_count
FROM dbo.complaints_2024_raw
GROUP BY LEFT(Date_received, 7)
ORDER BY received_month
OPTION (MAXDOP 1);

SELECT
    LEFT(Date_received, 7) AS received_month,
    COUNT(*) AS complaint_count
FROM dbo.complaints_2025_raw
GROUP BY LEFT(Date_received, 7)
ORDER BY received_month
OPTION (MAXDOP 1);

WITH monthly_2024 AS (
    SELECT
        SUBSTRING(Date_received, 6, 2) AS month_number,
        COUNT(*) AS complaints_2024
    FROM dbo.complaints_2024_raw
    GROUP BY SUBSTRING(Date_received, 6, 2)
),
monthly_2025 AS (
    SELECT
        SUBSTRING(Date_received, 6, 2) AS month_number,
        COUNT(*) AS complaints_2025
    FROM dbo.complaints_2025_raw
    GROUP BY SUBSTRING(Date_received, 6, 2)
)
SELECT
    a.month_number,
    a.complaints_2024,
    b.complaints_2025,
    b.complaints_2025 - a.complaints_2024 AS change_count,

    CAST(
        100.0 * (b.complaints_2025 - a.complaints_2024)
        / NULLIF(a.complaints_2024, 0)
        AS decimal(10,2)
    ) AS yoy_growth_pct

FROM monthly_2024 AS a
JOIN monthly_2025 AS b
    ON a.month_number = b.month_number
ORDER BY a.month_number
OPTION (MAXDOP 1);

WITH issue_2024 AS (
    SELECT
        COALESCE(NULLIF(TRIM(Issue), ''), 'Not reported') AS issue,
        COUNT(*) AS complaints_2024
    FROM dbo.complaints_2024_raw
    GROUP BY COALESCE(NULLIF(TRIM(Issue), ''), 'Not reported')
),
issue_2025 AS (
    SELECT
        COALESCE(NULLIF(TRIM(Issue), ''), 'Not reported') AS issue,
        COUNT(*) AS complaints_2025
    FROM dbo.complaints_2025_raw
    GROUP BY COALESCE(NULLIF(TRIM(Issue), ''), 'Not reported')
)
SELECT
    COALESCE(a.issue, b.issue) AS issue,
    COALESCE(a.complaints_2024, 0) AS complaints_2024,
    COALESCE(b.complaints_2025, 0) AS complaints_2025,

    COALESCE(b.complaints_2025, 0)
        - COALESCE(a.complaints_2024, 0) AS change_count,

    CAST(
        100.0 * (
            COALESCE(b.complaints_2025, 0)
            - COALESCE(a.complaints_2024, 0)
        ) / NULLIF(a.complaints_2024, 0)
        AS decimal(10,2)
    ) AS yoy_growth_pct

FROM issue_2024 AS a
FULL OUTER JOIN issue_2025 AS b
    ON a.issue = b.issue
ORDER BY change_count DESC
OPTION (MAXDOP 1);
