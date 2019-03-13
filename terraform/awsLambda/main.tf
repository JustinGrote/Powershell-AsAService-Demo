provider "aws" {
  version = "~> 2.1"
  region  = "us-west-2"
}

data "aws_caller_identity" "this" {}

# API Gateway
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.name}"
}

resource "aws_api_gateway_resource" "this" {
  path_part   = "resource"
  parent_id   = "${aws_api_gateway_rest_api.this.root_resource_id}"
  rest_api_id = "${aws_api_gateway_rest_api.this.id}"
}

resource "aws_api_gateway_method" "this" {
  rest_api_id   = "${aws_api_gateway_rest_api.this.id}"
  resource_id   = "${aws_api_gateway_resource.this.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "this" {
  rest_api_id             = "${aws_api_gateway_rest_api.this.id}"
  resource_id             = "${aws_api_gateway_resource.this.id}"
  http_method             = "${aws_api_gateway_method.this.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.this.arn}/invocations"
}

# Lambda
resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.this.arn}"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.this.id}/*/${aws_api_gateway_method.this.http_method}/${aws_api_gateway_resource.this.path}"
}

resource "aws_lambda_function" "this" {
  filename         = "${var.aws_lambda_package_path}"
  function_name    = "${var.name}"
  role             = "${aws_iam_role.this.arn}"
  handler          = "${var.aws_lambda_handler}"
  runtime          = "dotnetcore2.1"
  source_code_hash = "${base64sha256(file("${var.aws_lambda_package_path}"))}"
}

# IAM
resource "aws_iam_role" "this" {
  name = "${var.name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}