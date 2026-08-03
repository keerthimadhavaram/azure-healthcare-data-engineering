# Interview Prep — Questions This Project Answers

1. **Why a medallion architecture instead of just cleaning data in one step?**
   Separating landing/bronze/silver/gold means each layer has a clear
   contract: bronze preserves raw data with lineage for
   debugging/reprocessing, silver is the single validated source of
   truth, and gold is pre-aggregated for fast BI consumption — you
   don't want reporting queries scanning raw, messy data every time.

2. **How does orchestration split between ADF and Databricks here?**
   ADF handles scheduling, file movement, and triggering — Databricks
   (PySpark) handles the actual transformation logic. This keeps
   compute-heavy work in Spark, which scales, while ADF stays a thin
   orchestration layer.

3. **How would you handle a late-arriving or corrected file?**
   The `_batch_id` and `RunDate` parameter support reprocessing a
   specific day without touching the rest of history — rerun the
   pipeline for that date and the bronze/silver/gold layers for that
   partition get overwritten.

4. **Why load into Snowflake instead of querying the Delta lake directly from Power BI?**
   Snowflake is the shared, governed serving layer other BI tools and
   analysts query against — it decouples the warehouse from the
   underlying lake format and gives consistent SQL access control.

5. **How do you keep bronze/silver/gold consistent with the SQL and Power BI projects in this portfolio?**
   Same source data and identical KPI formulas (no-show rate, revenue,
   readmission rate) — see `docs/data_dictionary.md` and compare to
   `sql-healthcare-analytics/sql/10_healthcare_kpi_queries.sql`.
