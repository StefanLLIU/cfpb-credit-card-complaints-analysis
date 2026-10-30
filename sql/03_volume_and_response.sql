USE CFPB_Complaints;
GO

-- Receiving-year cohorts; timely response is not resolution.
WITH yearly_counts AS (
    SELECT
        YEAR(received_at) AS received_year,
        COUNT(*) AS complaint_count
    FROM dbo.v_complaints_clean
    GROUP BY YEAR(received_at)
),
yearly_comparison AS (
    SELECT
        received_year,
        complaint_count,
        LAG(complaint_count) OVER (
            ORDER BY received_year
        ) AS prior_year_count
    FROM yearly_counts
)
SELECT
    received_year,
    complaint_count,
    prior_year_count,
    complaint_count - prior_year_count AS change_count,
    ROUND(
        100.0 * (complaint_count - prior_year_count)
        / NULLIF(prior_year_count, 0),
        2
    ) AS yoy_growth_pct
FROM yearly_comparison
ORDER BY received_year;

SELECT
    YEAR(received_at) AS received_year,
    COUNT(*) AS complaint_count,

    SUM(CASE WHEN timely_response = 'Yes'
        THEN 1 ELSE 0 END) AS timely_count,

    SUM(CASE WHEN timely_response = 'No'
        THEN 1 ELSE 0 END) AS not_timely_count,

    SUM(CASE
        WHEN timely_response IN ('Yes', 'No')
        THEN 0 ELSE 1
    END) AS unknown_response_count,

    CAST(
        100.0 *
        SUM(CASE WHEN timely_response = 'Yes'
            THEN 1 ELSE 0 END)
        /
        NULLIF(
            SUM(CASE
                WHEN timely_response IN ('Yes', 'No')
                THEN 1 ELSE 0
            END),
            0
        )
        AS decimal(6,2)
    ) AS timely_response_pct

FROM dbo.v_complaints_clean
GROUP BY YEAR(received_at)
ORDER BY received_year;

SELECT
    COALESCE(issue, 'Not reported') AS issue,
    COUNT(*) AS complaint_count,

    SUM(CASE WHEN timely_response = 'No'
        THEN 1 ELSE 0 END) AS not_timely_count,

    CAST(
        100.0 *
        SUM(CASE WHEN timely_response = 'No'
            THEN 1 ELSE 0 END)
        /
        NULLIF(
            SUM(CASE WHEN timely_response IN ('Yes', 'No')
                THEN 1 ELSE 0 END),
            0
        )
        AS decimal(6,2)
    ) AS not_timely_pct

FROM dbo.v_complaints_clean
WHERE received_at >= '2025-01-01T00:00:00+00:00'
  AND received_at <  '2026-01-01T00:00:00+00:00'
GROUP BY COALESCE(issue, 'Not reported')
ORDER BY not_timely_count DESC, complaint_count DESC;
