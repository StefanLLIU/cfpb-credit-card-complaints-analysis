USE CFPB_Complaints;
GO

-- Preserve both source cohorts, then standardize types and blanks.
CREATE OR ALTER VIEW dbo.v_complaints_raw AS

SELECT
    Date_received,
    Product,
    Sub_product,
    Issue,
    Sub_issue,
    Company_public_response,
    Company,
    State,
    ZIP_code,
    Tags,
    Submitted_via,
    Date_sent_to_company,
    Company_response_to_consumer,
    Timely_response,
    Complaint_ID,
    2024 AS source_year
FROM dbo.complaints_2024_raw

UNION ALL

SELECT
    Date_received,
    Product,
    Sub_product,
    Issue,
    Sub_issue,
    Company_public_response,
    Company,
    State,
    ZIP_code,
    Tags,
    Submitted_via,
    Date_sent_to_company,
    Company_response_to_consumer,
    Timely_response,
    Complaint_ID,
    2025 AS source_year
FROM dbo.complaints_2025_raw;
GO

CREATE OR ALTER VIEW dbo.v_complaints_clean AS
SELECT
    TRY_CONVERT(bigint, TRIM(Complaint_ID)) AS complaint_id,

    TRY_CONVERT(datetimeoffset(3), Date_received, 127)
        AS received_at,

    TRY_CONVERT(datetimeoffset(3), Date_sent_to_company, 127)
        AS sent_to_company_at,

    NULLIF(TRIM(Product), '') AS product,
    NULLIF(TRIM(Sub_product), '') AS sub_product,
    NULLIF(TRIM(Issue), '') AS issue,
    NULLIF(TRIM(Sub_issue), '') AS sub_issue,
    NULLIF(TRIM(Company), '') AS company,
    NULLIF(TRIM(State), '') AS state,
    NULLIF(TRIM(ZIP_code), '') AS zip_code,
    NULLIF(TRIM(Submitted_via), '') AS submitted_via,
    NULLIF(TRIM(Company_public_response), '')
        AS company_public_response,
    NULLIF(TRIM(Company_response_to_consumer), '')
        AS company_response,
    NULLIF(TRIM(Timely_response), '') AS timely_response,
    NULLIF(TRIM(Tags), '') AS tags,
    source_year
FROM dbo.v_complaints_raw;
GO
