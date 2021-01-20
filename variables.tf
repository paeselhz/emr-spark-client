variable "name" {}
variable "region" {}
variable "key_name" {}
variable "release_label" {}
variable "applications" {
  type = list(string)
}
variable "master_instance_type" {}
variable "master_ebs_size" {}
variable "master_bid_price"{}
variable "master_ami" {}
variable "core_instance_type" {}
variable "core_instance_count" {}
variable "core_bid_price" {}
variable "core_ebs_size" {}
variable "ingress_cidr_blocks" {}
# RStudio variables
//variable "rstudio_instance_type" {}
//variable "rstudio_ebs_size" {}