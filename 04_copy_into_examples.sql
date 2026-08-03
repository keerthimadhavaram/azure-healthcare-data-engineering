-- Example COPY INTO statements for loading Parquet from the ADF/Databricks
-- pipeline output (staged in an external Azure stage) into bronze.

CREATE OR REPLACE STAGE bronze.adls_stage
  URL = 'azure://healthcaredatalake.blob.core.windows.net/bronze'
  CREDENTIALS = (AZURE_SAS_TOKEN = '<sas_token>')
  FILE_FORMAT = (TYPE = PARQUET);

COPY INTO bronze.visits
FROM @bronze.adls_stage/visits/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'ABORT_STATEMENT';

COPY INTO bronze.patients
FROM @bronze.adls_stage/patients/
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = 'ABORT_STATEMENT';
