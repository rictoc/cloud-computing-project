output "external_lb_dns_name" {
  value = aws_lb.external_load_balancer.dns_name
}

output "internal_lb_dns_name" {
  value = aws_lb.internal_load_balancer.dns_name
}

output "frontend_hosts_tg_arn" {
  value = aws_lb_target_group.frontend_hosts_tg.arn
}

output "backend_hosts_tg_arn" {
  value = aws_lb_target_group.backend_hosts_tg.arn
}