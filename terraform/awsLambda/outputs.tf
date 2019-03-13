output "functionHandler" {
    value = "${aws_lambda_function.this.handler}"
}
output "lambdaPackage" {
    value = "${aws_lambda_function.this.filename}"
}