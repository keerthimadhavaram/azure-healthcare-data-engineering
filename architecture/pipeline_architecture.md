# Architecture

```
┌──────────────────┐
│  Source Systems   │  EHR, scheduling, claims, operational apps
│  (daily extracts) │
└─────────┬─────────┘
          │  Azure Data Factory (scheduled trigger, daily)
          ▼
┌──────────────────┐
│     Landing        │  data/landing/  — raw files exactly as received
└─────────┬─────────┘
          │  ADF Copy activity (PL_Ingest_Landing_To_Bronze)
          ▼
┌──────────────────┐
│      Bronze         │  data/bronze/  — raw + ingestion metadata
│                      │  (_source_system, _ingested_at, _batch_id)
└─────────┬─────────┘
          │  Databricks notebook (bronze_to_silver.py)
          ▼
┌──────────────────┐
│      Silver          │  data/silver/ — cleaned, deduped, joined,
│                       │  validated visit + patient data
└─────────┬─────────┘
          │  Databricks notebook (silver_to_gold.py)
          ▼
┌──────────────────┐
│       Gold             │  data/gold/ — business-ready KPI tables
└─────────┬─────────┘
          │  ADF Copy activity (PL_Silver_To_Gold) -> COPY INTO
          ▼
┌──────────────────┐
│     Snowflake            │  snowflake/ — gold.department_kpis,
│                          │  gold.monthly_kpis, gold.insurance_distribution
└─────────┬─────────┘
          │
          ▼
┌──────────────────┐
│     Power BI              │  consumes gold tables directly
│  (powerbi-healthcare-      │  (see the powerbi-healthcare-dashboard
│   dashboard project)        │   project in this profile)
└──────────────────┘
```

## Orchestration
- **Azure Data Factory** owns scheduling and the landing→bronze copy,
  and triggers the Databricks notebooks for bronze→silver and
  silver→gold (`adf/pipeline_ingest_landing_to_bronze.json`,
  `adf/pipeline_silver_to_gold.json`).
- **Databricks (PySpark)** owns the actual transformation logic —
  deduplication, null handling, joins, and KPI aggregation
  (`databricks/bronze_to_silver.py`, `databricks/silver_to_gold.py`).
- **Snowflake** is the serving warehouse for BI tools, loaded via
  `COPY INTO` from the gold Parquet output
  (`snowflake/04_copy_into_examples.sql`).

## Incremental loading
Each ADF pipeline run is parameterized by `RunDate`, so only that
day's landing file is processed — avoiding a full reprocess of
history on every run. The `_batch_id` stamped in bronze supports
lineage/debugging if a specific day's load needs to be traced or
reprocessed.
