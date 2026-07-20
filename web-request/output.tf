output "instance_id" {
  value = aws_instance.demo.id
}

output "instance_public_ip" {
  value = aws_instance.demo.public_ip
}

output "start_url" {
  value = "${aws_apigatewayv2_stage.default.invoke_url}/start"
}

output "stop_url" {
  value = "${aws_apigatewayv2_stage.default.invoke_url}/stop"
}