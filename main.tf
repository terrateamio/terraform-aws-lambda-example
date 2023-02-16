terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
 
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
 
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.example.id
  availability_zone = "us-west-2b"
 
  tags = {
    Name = "example-subnet"
  }
}

resource "aws_security_group" "example" {
  name_prefix = "example-sg"
  vpc_id = aws_vpc.example.id
 
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
 
  egress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "example" {
  name = "example-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
 
resource "aws_iam_policy" "example" {
  name        = "example-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = ["arn:aws:logs:*:*:*"]
    },{
      Effect = "Allow"
      Action = [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ]
      Resource = ["*"]
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = aws_iam_policy.example.arn
  role = aws_iam_role.example.name
}

resource "aws_lambda_function" "example" {
  function_name    = "example-lambda"
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
  handler          = "index.handler"
  role             = aws_iam_role.example.arn
  runtime          = "nodejs14.x"
  vpc_config {
    subnet_ids = [aws_subnet.example.id]
    security_group_ids = [aws_security_group.example.id]
  }
}
