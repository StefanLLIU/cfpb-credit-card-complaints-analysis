# Credit Card Complaints and Response Performance

An analysis of **165,967 published credit card complaints received in 2024–2025**, using real CFPB public data, SQL Server, and Tableau Public.

[Open the interactive Tableau dashboard](https://public.tableau.com/views/CreditCardComplaintsAnalysis2024-2025/Dashboard1)

## Business questions

- How did complaint volume change between 2024 and 2025?
- Which issues contributed most to the increase?
- How did response timeliness vary by year and issue?
- How was elapsed time from receipt to forwarding distributed?

## Findings

| Metric | 2024 | 2025 |
|---|---:|---:|
| Complaints | 75,989 | 89,978 |
| Timely response rate | 99.82% | 99.62% |
| Complaints marked not timely | 138 | 345 |
| Average forwarding interval, days | 0.49 | 1.78 |
| Forwarding interval at least 30 days | 148 (0.19%) | 2,158 (2.40%) |

Complaint volume increased **18.41%**. Purchase-statement problems increased by **5,215 complaints**, contributing about **37.28% of net growth**. January had the largest monthly year-over-year increase: **72.92%**. These are descriptive findings, not estimates of underlying customer harm or company performance adjusted for exposure.

## Workflow

1. Download two annual CSV exports from the [CFPB Consumer Complaint Database](https://www.consumerfinance.gov/data-research/consumer-complaints/), filtered to Product = Credit card and Date received = each complete calendar year.
2. Stage source values as text in SQL Server. Validate row counts, unique IDs, date parsing, chronology, and year coverage.
3. Combine sources with `UNION ALL` and standardize types in views. Use CTEs, `LAG`, conditional aggregation, and aggregate-before-join comparisons.
4. Analyze forwarding intervals directly from each annual raw table when the combined-view query encounters memory pressure.
5. Combine the original CSVs for Tableau. Build distinct-count KPIs, monthly trends, issue rankings, and an issue-level scatter plot with shared year filters.

**Tableau reads the combined original CSV, not a live SQL connection or a SQL-exported dataset.** SQL analysis was performed separately and results were cross-checked with the dashboard.

## Repository contents

- `sql/00_schema.sql`: optional raw-table setup.
- `sql/01_views.sql`: combined and cleaned views.
- `sql/02_quality_checks.sql`: completeness, uniqueness, parsing, and chronology checks.
- `sql/03_volume_and_response.sql`: annual growth and response analysis.
- `sql/04_growth_by_month_and_issue.sql`: monthly and issue growth comparisons.
- `sql/05_forwarding_intervals.sql`: annual interval statistics, extreme-record inspection, and distribution bands.
- `scripts/combine_sources.py`: validate and combine the two original exports using Python standard library only.
- `results/`: aggregate findings independently recalculated from the supplied CSV snapshot.
- `data/source_manifest.json`: original file fingerprints and validation counts.
- `docs/case-study.md`: interpretation, investigation priorities, and limitations.
- `docs/tableau-calculations.md`: metric definitions and dashboard validation targets.

## Reproduce

Use SQL Server 2017 or newer with SSMS. Place the original exports in `data/`, using the filenames recorded in the manifest, or pass paths to the Python script.

```sh
python scripts/combine_sources.py --input-2024 "data/Credit_card_2024.csv.csv" --input-2025 "data/Credit_card_2025.csv.csv" --output "data/CFPB_2024_2025.csv"
```

For SQL, create `CFPB_Complaints` and import each CSV with SSMS Import Flat File as `dbo.complaints_2024_raw` and `dbo.complaints_2025_raw`. Match the column names and text widths in `sql/00_schema.sql`, allow nulls, and preserve ZIP codes as text. The wizard creates the tables, so use either the wizard or the optional schema script, not both for table creation. If using the schema script, load CSV records into its existing tables with an appropriate SQL Server import tool.

Run scripts 01 through 05 in order, one statement/batch at a time. They assume the source tables already contain the data. `GO` is an SSMS batch separator. Scripts contain no automatic CSV loading or destructive cleanup. Views are replaced on rerun. Large queries may require available memory; `MAXDOP 1` is a query-level choice used in this project and is not a guarantee against memory errors.

Import the combined CSV into Tableau Public. Keep receipt and forwarding fields as Date & Time, and count Complaint ID distinctly. Use continuous **month date values**, not month-of-year numbers, for the 24-month trend.

## Data and interpretation limits

- This is a downloaded snapshot of published CFPB complaints, not all consumer experiences. Counts may change as the live database changes.
- A complaint is not proof of wrongdoing. Volumes are not adjusted for customer base or market share.
- Timely response is the source Yes/No flag; it does not mean resolution or satisfaction. Unknown statuses are excluded from rate denominators and checked separately.
- Forwarding interval measures receipt to sending to the company, not company response or resolution. UTC timestamp differences are used. Bands are analytical, not regulatory thresholds.
- The 2024 received-year cohort includes a complaint forwarded in 2026. Cohorts are based on receipt, not forwarding year.
- The 445.82-day maximum was retained and flagged for review; no cause is inferred.
- The original SQL was executed interactively during the guided project. The reorganized scripts have been reviewed but were not rerun against SQL Server after the local instance became unavailable. Aggregate CSV outputs were independently recalculated from the original files.

Raw complaint exports are not included in this repository. Retrieve the data from CFPB; the manifest identifies the original snapshot. No synthetic records were used.
