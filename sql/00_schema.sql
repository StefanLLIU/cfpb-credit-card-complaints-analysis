-- Execute once in a new project database. Original CSV values are staged as text.
IF DB_ID(N'CFPB_Complaints') IS NULL
    EXEC(N'CREATE DATABASE CFPB_Complaints');
GO
USE CFPB_Complaints;
GO

IF OBJECT_ID(N'dbo.complaints_2024_raw', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.complaints_2024_raw (
        [Date_received] nvarchar(50) NULL,
        [Product] nvarchar(100) NULL,
        [Sub_product] nvarchar(100) NULL,
        [Issue] nvarchar(1000) NULL,
        [Sub_issue] nvarchar(1000) NULL,
        [Company_public_response] nvarchar(1000) NULL,
        [Company] nvarchar(500) NULL,
        [State] nvarchar(100) NULL,
        [ZIP_code] nvarchar(100) NULL,
        [Tags] nvarchar(100) NULL,
        [Submitted_via] nvarchar(100) NULL,
        [Date_sent_to_company] nvarchar(50) NULL,
        [Company_response_to_consumer] nvarchar(1000) NULL,
        [Timely_response] nvarchar(100) NULL,
        [Complaint_ID] nvarchar(100) NULL
    );
END;
GO

IF OBJECT_ID(N'dbo.complaints_2025_raw', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.complaints_2025_raw (
        [Date_received] nvarchar(50) NULL,
        [Product] nvarchar(100) NULL,
        [Sub_product] nvarchar(100) NULL,
        [Issue] nvarchar(1000) NULL,
        [Sub_issue] nvarchar(1000) NULL,
        [Company_public_response] nvarchar(1000) NULL,
        [Company] nvarchar(500) NULL,
        [State] nvarchar(100) NULL,
        [ZIP_code] nvarchar(100) NULL,
        [Tags] nvarchar(100) NULL,
        [Submitted_via] nvarchar(100) NULL,
        [Date_sent_to_company] nvarchar(50) NULL,
        [Company_response_to_consumer] nvarchar(1000) NULL,
        [Timely_response] nvarchar(100) NULL,
        [Complaint_ID] nvarchar(100) NULL
    );
END;
GO
