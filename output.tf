output "instance_id" {
  value = aws_instance.demo.id
}

output "instance_public_ip" {
  value = aws_instance.demo.public_ip
}