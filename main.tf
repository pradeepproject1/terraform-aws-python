resource "aws_instance" "demo" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.instance_name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ec2_control" {
  name = "${var.instance_name}-ec2-control"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_control" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ec2_control.arn
}

resource "aws_lambda_function" "start_ec2" {
  filename         = data.archive_file.start_ec2.output_path
  function_name    = "${var.instance_name}-start"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "start_ec2.lambda_handler"
  source_code_hash = data.archive_file.start_ec2.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.demo.id
    }
  }
}

resource "aws_lambda_function" "stop_ec2" {
  filename         = data.archive_file.stop_ec2.output_path
  function_name    = "${var.instance_name}-stop"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "stop_ec2.lambda_handler"
  source_code_hash = data.archive_file.stop_ec2.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30

  environment {
    variables = {
      EC2_INSTANCE_ID = aws_instance.demo.id
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = 0
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "start_ec2" {
  type        = "zip"
  source_file = "${path.module}/start_ec2.py"
  output_path = "${path.module}/start_ec2.zip"
}

data "archive_file" "stop_ec2" {
  type        = "zip"
  source_file = "${path.module}/stop_ec2.py"
  output_path = "${path.module}/stop_ec2.zip"
}