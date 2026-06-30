# Azure Healthcare Data Engineering

## Project Overview
This project demonstrates a cloud data engineering pipeline design for healthcare analytics using Azure Data Factory, Azure Data Lake concepts, Databricks-style transformation logic, Snowflake-style data warehouse modeling, and KPI reporting.

It is designed for Data Analyst, Healthcare Data Analyst, Business Intelligence Analyst, Analytics Engineer, and Junior Data Engineer roles.

## Business Problem
Healthcare organizations receive daily patient and appointment data from multiple systems such as EHR platforms, scheduling tools, claims systems, and operational applications. This raw data must be ingested, validated, transformed, modeled, and made available for analytics and dashboards.

## Architecture Flow
```text
Source Systems → Azure Data Factory → Landing → Bronze → Silver → Gold → Snowflake → Power BI
```

## Tools and Concepts Used
- Azure Data Factory
- Azure Data Lake Storage
- Databricks / PySpark-style transformations
- Snowflake data warehouse design
- Incremental loading
- Medallion architecture
- SQL data modeling
- Healthcare analytics
- KPI reporting
- Data validation
- Pipeline monitoring

## Repository Structure
```text
azure-healthcare-data-engineering/
├── README.md
├── UPLOAD_STEPS.md
├── data/
│   ├── landing/
│   ├── bronze/
│   ├── silver/
│   └── gold/
├── adf/
├── databricks/
├── snowflake/
├── docs/
├── architecture/
└── screenshots/
```

## Medallion Layers
- **Landing:** Raw daily extracts from source systems.
- **Bronze:** Raw data with source metadata.
- **Silver:** Cleaned, joined, validated healthcare visit data.
- **Gold:** Business-ready KPI tables for dashboards.

## Business KPIs
- Total visits
- Total revenue
- Average wait time
- No-show rate
- Readmission rate
- Department performance
- Insurance distribution
- Monthly healthcare trends

## Resume Alignment
This project supports Azure Data Factory, Databricks, Snowflake, ETL pipelines, data warehousing, data modeling, healthcare analytics, KPI reporting, data validation, and business intelligence.

## Author
**Keerthi Madhavaram**  
Data Analyst | Healthcare Analytics | Business Intelligence
