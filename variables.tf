variable "aws_region" {
  description = "The AWS region where the resources will be created."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "aws-glue-pyspark-etl"
}
variable "bucket_name" {
  description = "The name of the S3 bucket to store the Glue job scripts."
  type        = string
  #default     = "my-glue-job-scripts"
}