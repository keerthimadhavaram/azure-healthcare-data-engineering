-- ============================================================
-- Gold layer: business-ready KPI tables (consumed by Power BI)
-- ============================================================
CREATE OR REPLACE TABLE gold.department_kpis AS
SELECT
    department,
    COUNT(*) AS total_visits,
    SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
    ROUND(SUM(CASE WHEN appointment_status = 'No-Show' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) AS no_show_rate_pct,
    ROUND(AVG(wait_time_minutes), 1) AS avg_wait_minutes,
    ROUND(SUM(CASE WHEN appointment_status = 'Completed' THEN charges ELSE 0 END), 2) AS total_revenue,
    ROUND(SUM(readmission_flag) / NULLIF(SUM(CASE WHEN appointment_status='Completed' THEN 1 ELSE 0 END),0) * 100, 1) AS readmission_rate_pct
FROM silver.visits
GROUP BY department;

CREATE OR REPLACE TABLE gold.monthly_kpis AS
SELECT
    visit_month,
    COUNT(*) AS total_visits,
    ROUND(SUM(CASE WHEN appointment_status = 'Completed' THEN charges ELSE 0 END), 2) AS total_revenue
FROM silver.visits
GROUP BY visit_month
ORDER BY visit_month;

CREATE OR REPLACE TABLE gold.insurance_distribution AS
SELECT insurance_type, COUNT(DISTINCT patient_id) AS patient_count
FROM silver.visits
GROUP BY insurance_type;
