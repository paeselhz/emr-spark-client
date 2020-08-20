variable "name" {}
variable "region" {}
variable "subnet_id" {}
variable "vpc_id" {}
variable "key_name" {}
variable "release_label" {}
variable "applications" {
  type = list(string)
}
variable "master_instance_type" {}
variable "master_ebs_size" {}
variable "master_bid_price"{}
variable "core_instance_type" {}
variable "core_instance_count" {}
variable "core_bid_price" {}
variable "core_ebs_size" {}
variable "ingress_cidr_blocks" {}
variable "logging_bucket" {}