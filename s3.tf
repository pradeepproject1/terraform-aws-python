resource "aws_s3_bucket" "etl_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    project     = var.project_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "etl_bucket_versioning" {
  bucket = aws_s3_bucket.etl_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "etl_bucket_encryption" {
  bucket = aws_s3_bucket.etl_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "glue_script" {
  bucket = aws_s3_bucket.etl_bucket.id
  key    = "scripts/customer_etl.py"
  source = "${path.module}/glue-scripts/customer_etl.py"

  etag = filemd5("${path.module}/glue-scripts/customer_etl.py")
}
resource "aws_s3_object" "raw_customer_data" {
  bucket = aws_s3_bucket.etl_bucket.id
  key    = "raw/customers/customers.csv"
  source = "${path.module}/sample-data/customers.csv"

  etag = filemd5("${path.module}/sample-data/customers.csv")
}