"""
Databricks notebook (PySpark): Silver -> Gold
Builds the business-ready KPI tables consumed by Power BI / Snowflake.
"""
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = SparkSession.builder.appName("silver_to_gold").getOrCreate()

silver = spark.read.format("delta").load("/mnt/datalake/silver/visits_silver/")

gold_department_kpis = (
    silver.groupBy("department")
    .agg(
        F.count("*").alias("total_visits"),
        F.sum(F.when(F.col("appointment_status") == "No-Show", 1).otherwise(0)).alias("no_shows"),
        F.round(F.avg("wait_time_minutes"), 1).alias("avg_wait_minutes"),
        F.round(F.sum(F.when(F.col("appointment_status") == "Completed", F.col("charges")).otherwise(0)), 2)
            .alias("total_revenue"),
        F.round(F.sum("readmission_flag") /
                F.sum(F.when(F.col("appointment_status") == "Completed", 1).otherwise(0)) * 100, 1)
            .alias("readmission_rate_pct"),
    )
    .withColumn("no_show_rate_pct", F.round(F.col("no_shows") / F.col("total_visits") * 100, 1))
)

gold_monthly_kpis = (
    silver.groupBy("visit_month")
    .agg(
        F.count("*").alias("total_visits"),
        F.round(F.sum(F.when(F.col("appointment_status") == "Completed", F.col("charges")).otherwise(0)), 2)
            .alias("total_revenue"),
    )
    .orderBy("visit_month")
)

(gold_department_kpis.write.mode("overwrite").format("delta").save("/mnt/datalake/gold/department_kpis/"))
(gold_monthly_kpis.write.mode("overwrite").format("delta").save("/mnt/datalake/gold/monthly_kpis/"))

print("Gold layer written: department_kpis + monthly_kpis")
