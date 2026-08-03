# Data Dictionary

## Bronze (data/bronze/)
Same columns as the source extract, plus:
- `_source_system` — originating system (e.g. EHR_PROD)
- `_ingested_at` — UTC ingestion timestamp
- `_batch_id` — the ADF pipeline run that landed this record

## Silver (data/silver/)
Deduplicated, joined visits + patients, with wait_time_minutes and age
imputed (department-median / overall-median respectively) and
insurance_type blanks standardized to "Unknown" — same cleaning rules
as the `healthcare-etl-pipeline` project, implemented here in
Spark/Snowflake SQL instead of pandas.

## Gold (data/gold/)
- `gold_department_kpis.csv` — total_visits, total_revenue, no_shows,
  no_show_rate_pct per department.
- `gold_monthly_kpis.csv` — total_visits, total_revenue per month.

These match the KPI definitions used in `sql-healthcare-analytics` and
`powerbi-healthcare-dashboard` so all four data-focused projects in
this profile report consistent numbers.
