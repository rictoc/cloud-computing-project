output "external_load_balancer_sg" {
  value = aws_security_group.external_load_balancer_sg.id
}

output "internal_load_balancer_sg" {
  value = aws_security_group.internal_load_balancer_sg.id
}

output "frontend_host_sg" {
  value = aws_security_group.frontend_host_sg.id
}

output "backend_host_sg" {
  value = aws_security_group.backend_host_sg.id
}
