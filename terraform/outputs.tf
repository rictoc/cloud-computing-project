output "application_dns_name" {
  value = "http://${aws_lb.external_load_balancer.dns_name}"
}
