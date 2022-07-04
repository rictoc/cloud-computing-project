output "instance_public_ip" {
  value = aws_instance.load_test_instance.public_ip
}