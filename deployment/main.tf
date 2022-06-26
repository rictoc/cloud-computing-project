module "vpc" {
  source             = "./vpc"
  project_name       = var.project_name
  availability_zones = 2
}

module "security_groups" {
  source         = "./security_groups"
  project_name   = var.project_name
  vpc_id         = module.vpc.id
  vpc_cidr_block = module.vpc.cidr_block
}

module "load_balancing" {
  source                    = "./load_balancing"
  project_name              = var.project_name
  vpc_id                    = module.vpc.id
  public_subnets            = module.vpc.public_subnets
  private_subnets           = module.vpc.private_subnets
  external_load_balancer_sg = module.security_groups.external_load_balancer_sg
  internal_load_balancer_sg = module.security_groups.internal_load_balancer_sg
}

module "frontend_service" {
  source           = "./frontend_service"
  project_name     = var.project_name
  vpc_id           = module.vpc.id
  subnets          = module.vpc.private_subnets
  target_group     = module.load_balancing.frontend_hosts_tg_arn
  security_group   = module.security_groups.frontend_host_sg
  image_name       = "cc-project/frontend"
  ami_id           = data.aws_ami.amazon-linux-2.id
  instance_type    = "t2.large"
  backend_hostname = module.load_balancing.internal_lb_dns_name
}

module "backend_service" {
  source         = "./backend_service"
  project_name   = var.project_name
  vpc_id         = module.vpc.id
  subnets        = module.vpc.private_subnets
  target_group   = module.load_balancing.backend_hosts_tg_arn
  security_group = module.security_groups.backend_host_sg
  image_name     = "cc-project/backend"
  ami_id         = data.aws_ami.amazon-linux-2.id
  instance_type  = "t2.large"
}