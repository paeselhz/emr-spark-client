module "s3" {
  source = "./modules/s3"
  name   = var.name
}

module "iam" {
  source = "./modules/iam"
}

module "security" {
  source              = "./modules/security"
  name                = var.name
  vpc_id              = module.network.vpc_id
  ingress_cidr_blocks = var.ingress_cidr_blocks
}

module "network" {
  source              = "./modules/network"
  region              = var.region
  ingress_cidr_blocks = var.ingress_cidr_blocks
}

module "emr" {
  source                    = "./modules/emr"
  name                      = var.name
  release_label             = var.release_label
  applications              = var.applications
  subnet_id                 = module.network.subnet_id
  key_name                  = var.key_name
  master_instance_type      = var.master_instance_type
  master_ebs_size           = var.master_ebs_size
  master_bid_price          = var.master_bid_price
  core_instance_type        = var.core_instance_type
  core_instance_count       = var.core_instance_count
  core_bid_price            = var.core_bid_price
  core_ebs_size             = var.core_ebs_size
  emr_master_security_group = module.security.emr_master_security_group
  emr_slave_security_group  = module.security.emr_slave_security_group
  emr_ec2_instance_profile  = module.iam.emr_ec2_instance_profile
  emr_service_role          = module.iam.emr_service_role
  emr_autoscaling_role      = module.iam.emr_autoscaling_role
}

module "rstudio" {
  source                   = './modules/rstudio'
  name                     = var.name
  key_name                 = var.key_name
  subnet_id                = module.network.subnet_id
  vpc_id                   = module.network.vpc_id
  region                   = var.region
  ec2_instance_type        = var.rstudio_instance_type
  ec2_security_groups      = module.security.rstudio_ec2_security_group
  ec2_iam_instance_profile = module.iam.rstudio_ec2_instance_profile
  ec2_ebs_size             = var.rstudio_ebs_size
  associated_emr           = module.emr.id
}