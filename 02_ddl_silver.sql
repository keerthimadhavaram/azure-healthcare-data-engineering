-- ============================================================
-- Silver layer: cleaned, validated, joined
-- ============================================================
CREATE OR REPLACE TABLE silver.visits (
    visit_id            VARCHAR PRIMARY KEY,
    patient_id          VARCHAR,
    visit_date           DATE,
    department           VARCHAR,
    doctor                VARCHAR,
    appointment_status    VARCHAR,
    wait_time_minutes     NUMBER,
    diagnosis             VARCHAR,
    charges               NUMBER(10,2),
    readmission_flag      NUMBER(1),
    visit_month            VARCHAR,
    full_name               VARCHAR,
    age                      NUMBER,
    gender                   VARCHAR,
    city                     VARCHAR,
    state                    VARCHAR,
    insurance_type           VARCHAR
);

-- Silver load from bronze with cleaning rules applied
INSERT OVERWRITE INTO silver.visits
SELECT
    v.visit_id, v.patient_id, v.visit_date, v.department, v.doctor,
    v.appointment_status,
    COALESCE(
        NULLIF(v.wait_time_minutes, -1),
        MEDIAN(v.wait_time_minutes) OVER (PARTITION BY v.department)
    ) AS wait_time_minutes,
    v.diagnosis,
    COALESCE(v.charges, 0) AS charges,
    v.readmission_flag,
    TO_CHAR(v.visit_date, 'YYYY-MM') AS visit_month,
    CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    COALESCE(p.age, MEDIAN(p.age) OVER ()) AS age,
    p.gender, p.city, p.state,
    COALESCE(NULLIF(p.insurance_type, ''), 'Unknown') AS insurance_type
FROM bronze.visits v
LEFT JOIN bronze.patients p ON v.patient_id = p.patient_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY v.visit_id ORDER BY v._ingested_at DESC) = 1;
