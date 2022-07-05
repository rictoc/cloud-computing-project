output "vpc_id" {
  value = module.vpc.id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "application_dns_name" {
  value = "http://${module.load_balancing.external_lb_dns_name}"
}
