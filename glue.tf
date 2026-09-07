resource "aws_glue_catalog_database" "raw_database" {
  name        = "${replace(var.project_name, "-", "_")}_raw_database"
  description = "Glue Data Catalog database for raw customer data"
}

resource "aws_glue_catalog_database" "processed_database" {
  name        = "${replace(var.project_name, "-", "_")}_processed_database"
  description = "Glue Data Catalog database for processed customer data"
}

resource "aws_glue_job" "customer_etl_job" {
  name     = "${var.project_name}-customer-etl-job"
  role_arn = aws_iam_role.glue_role.arn

  glue_version = "5.0"

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.etl_bucket.bucket}/scripts/customer_etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language" = "python"
    "--BUCKET_NAME"  = aws_s3_bucket.etl_bucket.bucket
  }

  worker_type       = "G.1X"
  number_of_workers = 2

  depends_on = [
    aws_s3_object.glue_script,
    aws_iam_role_policy.glue_s3_access
  ]
}

resource "aws_glue_crawler" "raw_customer_crawler" {
  name          = "${var.project_name}-raw-customer-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.raw_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.etl_bucket.bucket}/raw/customers/"
  }

  table_prefix = "raw_"

  depends_on = [
    aws_s3_object.raw_customer_data,
    aws_iam_role_policy.glue_s3_access
  ]
}

resource "aws_glue_crawler" "processed_customer_crawler" {
  name          = "${var.project_name}-processed-customer-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.processed_database.name

  s3_target {
    path = "s3://${aws_s3_bucket.etl_bucket.bucket}/processed/customers/"
  }

  table_prefix = "processed_"

  depends_on = [
    aws_iam_role_policy.glue_s3_access
  ]
}