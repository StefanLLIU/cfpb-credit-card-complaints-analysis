USE CFPB_Complaints;
GO

-- Expected total: 165967; 75989 in 2024 and 89978 in 2025.
SELECT source_year, COUNT(*) AS total_rows
FROM dbo.v_complaints_raw
GROUP BY source_year
ORDER BY source_year;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT NULLIF(TRIM(Complaint_ID), ''))
        AS unique_complaint_ids,
    SUM(
        CASE
            WHEN NULLIF(TRIM(Complaint_ID), '') IS NULL
            THEN 1 ELSE 0
        END
    ) AS missing_ids
FROM dbo.v_complaints_raw;

SELECT
    TRIM(Complaint_ID) AS complaint_id,
    COUNT(*) AS record_count
FROM dbo.v_complaints_raw
WHERE NULLIF(TRIM(Complaint_ID), '') IS NOT NULL
GROUP BY TRIM(Complaint_ID)
HAVING COUNT(*) > 1;

SELECT
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN NULLIF(TRIM(Date_received), '') IS NULL
        THEN 1 ELSE 0
    END) AS missing_received_dates,

    SUM(CASE
        WHEN NULLIF(TRIM(Date_received), '') IS NOT NULL
         AND TRY_CONVERT(
             datetimeoffset(3), Date_received, 127
         ) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_received_dates,

    SUM(CASE
        WHEN NULLIF(TRIM(Date_sent_to_company), '') IS NULL
        THEN 1 ELSE 0
    END) AS missing_sent_dates,

    SUM(CASE
        WHEN NULLIF(TRIM(Date_sent_to_company), '') IS NOT NULL
         AND TRY_CONVERT(
             datetimeoffset(3), Date_sent_to_company, 127
         ) IS NULL
        THEN 1 ELSE 0
    END) AS invalid_sent_dates

FROM dbo.v_complaints_raw;

SELECT
    COUNT(*) AS total_rows,

    COUNT(DISTINCT complaint_id) AS unique_ids,

    SUM(CASE
        WHEN complaint_id IS NULL
        THEN 1 ELSE 0
    END) AS invalid_ids,

    SUM(CASE
        WHEN sent_to_company_at < received_at
        THEN 1 ELSE 0
    END) AS sent_before_received,

    SUM(CASE
        WHEN YEAR(received_at) <> source_year
        THEN 1 ELSE 0
    END) AS source_year_mismatches

FROM dbo.v_complaints_clean;
