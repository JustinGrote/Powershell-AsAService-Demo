variable "name" {
    default = "poshaasdemotf"
}
variable "region" {
    default = "us-west-2"
}
variable "aws_lambda_package_path" {
    description = "The path to your AWS Lambda Package"
}

variable "aws_lambda_handler" {
    description = "The handler name for your AWS Lambda Package"
}