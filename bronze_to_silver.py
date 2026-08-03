"""
Databricks notebook (PySpark): Bronze -> Silver
Cleans and joins the bronze visits/patients tables into a validated,
analysis-ready silver table.

Run in a Databricks workspace or any environment with PySpark
installed. Not executed in the portfolio build sandbox (no Spark
runtime there) — logic mirrors the pandas equivalent in the
`healthcare-etl-pipeline` project, which IS executed and tested there.
"""
from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window

spark = SparkSession.builder.appName("bronze_to_silver").getOrCreate()

bronze_visits = spark.read.parquet("/mnt/datalake/bronze/visits/")
bronze_patients = spark.read.parquet("/mnt/datalake/bronze/patients/")

# --- clean patients ---
silver_patients = (
    bronze_patients
    .dropDuplicates(["patient_id"])
    .withColumn("age", F.when(F.col("age").isNull(), F.lit(None)).otherwise(F.col("age")))
    .withColumn("insurance_type", F.when(F.col("insurance_type") == "", "Unknown")
                .otherwise(F.col("insurance_type")))
    .withColumn("full_name", F.concat_ws(" ", F.col("first_name"), F.col("last_name")))
)
median_age = silver_patients.approxQuantile("age", [0.5], 0.01)[0]
silver_patients = silver_patients.fillna({"age": median_age})

# --- clean visits ---
w = Window.partitionBy("department")
silver_visits = (
    bronze_visits
    .dropDuplicates(["visit_id"])
    .withColumn("wait_time_minutes",
                F.when(F.col("wait_time_minutes") < 0, None).otherwise(F.col("wait_time_minutes")))
    .withColumn("wait_time_minutes",
                F.coalesce(F.col("wait_time_minutes"),
                           F.expr("percentile_approx(wait_time_minutes, 0.5)").over(w)))
    .withColumn("charges", F.coalesce(F.col("charges"), F.lit(0.0)))
    .withColumn("visit_month", F.date_format("visit_date", "yyyy-MM"))
)

# --- join for the silver reporting table ---
silver = (
    silver_visits.alias("v")
    .join(silver_patients.alias("p"), on="patient_id", how="left")
    .select(
        "v.visit_id", "v.patient_id", "v.visit_date", "v.department", "v.doctor",
        "v.appointment_status", "v.wait_time_minutes", "v.diagnosis", "v.charges",
        "v.readmission_flag", "v.visit_month",
        "p.full_name", "p.age", "p.gender", "p.city", "p.state", "p.insurance_type",
    )
)

(silver.write.mode("overwrite").format("delta").save("/mnt/datalake/silver/visits_silver/"))

print(f"Silver layer written: {silver.count()} rows")
