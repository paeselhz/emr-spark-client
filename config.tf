terraform {
  backend "s3" {
    encrypt = true
    bucket  = var.logging_bucket
    key     = "terraform-emr-cluster.tfstate"
    region  = var.region
  }
}

provider "aws" {
  version    = "~> 1.0"
  region     = var.region
}