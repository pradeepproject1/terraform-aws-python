output "instance_id" {
  value = aws_instance.demo.id
}

output "instance_public_ip" {
  value = aws_instance.demo.public_ip
}

output "start_rule_arn" {
  value = aws_cloudwatch_event_rule.start_ec2.arn
}

output "stop_rule_arn" {
  value = aws_cloudwatch_event_rule.stop_ec2.arn
}