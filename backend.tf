terraform {
  backend "s3" {
    bucket = "terraform-state-aws-glue-etl"
    key    = "aws-glue-pyspark-etl/terraform.tfstate"
    region = "us-east-1"
  }
}
