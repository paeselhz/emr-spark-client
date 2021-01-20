terraform {
  backend "s3" {
    encrypt = true
    bucket  = "lhzpaese-terraform-states"
    key     = "terraform-emr-spark-client.tfstate"
    region  = "us-east-1"
  }
}

provider "aws" {
  version    = "3.24.0"
  region     = var.region
}