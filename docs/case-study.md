# Case study

## Context
An operations analyst wants to understand credit card complaint growth and response patterns using public CFPB reports. The unit of analysis is a complaint ID, not a customer or account.

## Method
Two annual exports contained 75,989 and 89,978 records. Checks found no missing or duplicate complaint IDs, no missing or unparseable timestamps, no forwarding timestamps before receipt, and no receipt-year/source mismatches. SQL views preserve the raw staging tables. Monthly and issue cohorts were aggregated before joining, preventing record multiplication. Tableau uses a separately combined CSV and shared receiving-year filters.

## Findings and investigation priorities
1. Complaint volume increased 18.41%. Purchase-statement problems contributed 5,215 of the 13,989 net additional complaints. Prioritize an investigation of its sub-issues and company/channel mix; the data does not establish a cause.
2. Untimely complaints rose from 138 to 345, while the timely rate remained above 99.6% in each year. Review counts and rates together, including category denominators, rather than ranking small groups by percentage alone.
3. At-least-30-day forwarding intervals increased from 0.19% to 2.40%. Inspect cohort composition and source handling before assigning responsibility. This interval describes forwarding, not a company's response time, and the analytical threshold is not an SLA.

## Quality and limitations
The 2024 cohort has a 445.82-day interval spanning into 2026. It was retained, not removed as an assumed error. Published complaint volume has no exposure denominator, cannot establish wrongdoing, and cannot support company safety rankings. No customer-level causation, regulatory compliance finding, or measured business improvement is claimed.

## Interview explanation
I analyzed real CFPB credit card complaints using SQL Server and Tableau. I validated IDs and timestamps, combined annual datasets, and used CTEs and window functions to investigate growth and response patterns. I then built an interactive dashboard using the original combined CSV, with distinct-count KPIs and a shared year filter. I documented the difference between timely response, resolution, and forwarding intervals to avoid misleading conclusions.
