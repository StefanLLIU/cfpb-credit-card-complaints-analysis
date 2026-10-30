# Tableau metric definitions

Use the actual field names in the imported CSV; source suffixes may vary.

## Total Complaints
```tableau
COUNTD([Complaint ID])
```

## Timely Response Rate
```tableau
COUNTD(IF [Timely response?] = "Yes" THEN [Complaint ID] END)
/
COUNTD(IF [Timely response?] = "Yes" OR [Timely response?] = "No"
       THEN [Complaint ID] END)
```

## Untimely Complaint Count
```tableau
COUNTD(IF [Timely response?] = "No" THEN [Complaint ID] END)
```

## Untimely Response Rate
```tableau
COUNTD(IF [Timely response?] = "No" THEN [Complaint ID] END)
/
COUNTD(IF [Timely response?] = "Yes" OR [Timely response?] = "No"
       THEN [Complaint ID] END)
```

The scatter plot places COUNTD(Complaint ID) on Columns, Untimely Response Rate on Rows, and Issue on Detail. Rates must be calculated at the displayed issue/year selection, not averaged from precomputed percentages.

| Year selection | Total Complaints | Timely Response Rate | Untimely Complaints |
|---|---:|---:|---:|
| Both | 165,967 | 99.71% | 483 |
| 2024 | 75,989 | 99.82% | 138 |
| 2025 | 89,978 | 99.62% | 345 |

Apply the receiving-year filter to all three KPI sheets and all three analysis sheets. The two-year purchase-statement issue count is 34,405. January 2025 has 9,073 complaints; August 2024 has 7,355.
