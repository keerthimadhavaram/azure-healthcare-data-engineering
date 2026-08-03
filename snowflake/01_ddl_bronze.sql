-- ============================================================
-- Bronze layer: raw + ingestion metadata, minimal transformation
-- ============================================================
CREATE OR REPLACE TABLE bronze.visits (
    visit_id            VARCHAR,
    patient_id          VARCHAR,
    visit_date           DATE,
    department           VARCHAR,
    doctor                VARCHAR,
    appointment_status    VARCHAR,
    wait_time_minutes     NUMBER,
    diagnosis             VARCHAR,
    charges               NUMBER(10,2),
    readmission_flag      NUMBER(1),
    _source_system         VARCHAR,
    _ingested_at            TIMESTAMP_NTZ,
    _batch_id                VARCHAR
);

CREATE OR REPLACE TABLE bronze.patients (
    patient_id          VARCHAR,
    first_name           VARCHAR,
    last_name             VARCHAR,
    age                    NUMBER,
    gender                 VARCHAR,
    city                   VARCHAR,
    state                  VARCHAR,
    insurance_type         VARCHAR,
    registration_date      DATE,
    _source_system         VARCHAR,
    _ingested_at            TIMESTAMP_NTZ,
    _batch_id                VARCHAR
);
