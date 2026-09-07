import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import col

# Initialize Glue and Spark
args = getResolvedOptions(sys.argv, ["JOB_NAME", "BUCKET_NAME"])

sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

# Read raw customer CSV data from S3
df = spark.read\
    .option("header", "true") \
    .csv(f"s3://{args['BUCKET_NAME']}/raw/customers/")

# Remove duplicate customer records, ignoring the source ID.
df_clean = df.dropDuplicates(["name", "age", "city", "salary"])

# Remove records with null values
df_clean = df_clean.dropna()

# Convert age and salary to integer
df_clean = df_clean.withColumn(
    "age",
    col("age").cast("int")
)

df_clean = df_clean.withColumn(
    "salary",
    col("salary").cast("int")
)

# Filter customers above 18 years
df_clean = df_clean.filter(col("age") > 18)

# Write processed data as Parquet
df_clean.write \
    .mode("overwrite") \
    .parquet(f"s3://{args['BUCKET_NAME']}/processed/customers/")

job.commit()