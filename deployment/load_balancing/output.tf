output "external_lb_listener" {
  value = aws_lb_listener.external_lb_http_listener.id
}

output "external_lb_dns_name" {
  value = aws_lb.external_load_balancer.dns_name
}

output "internal_lb_listener" {
  value = aws_lb_listener.internal_lb_http_listener.id
}

output "internal_lb_dns_name" {
  value = aws_lb.internal_load_balancer.dns_name
}
