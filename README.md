# EMR Spark Client Deploy

This project is a **work in progress** and addresses the automation through 
Terraform of the creation of an EMR Cluster, and it's deployment of client
configuration in a S3 bucket.

## Getting Started

This project is inspired by [this project](https://github.com/idealo/terraform-emr-pyspark)
and it aims to help users in the deployment of an EMR Cluster, and the
export of the cluster's configuration archives. It is in constant development
and user suggestions are welcome.

Also, it requires a basic knowledge of Terraform and it's configuration in AWS
environments. 

Below is an example of the `terraform.tfvars` file that should be added by the
user in the root of this project:

```
# EMR general configurations
name = "spark-app"
region = "us-east-1"
key_name = <key_name> 
ingress_cidr_blocks = "0.0.0.0/0"
release_label = "emr-6.0.0"
applications = ["Hadoop", "Spark", "Livy", "Hive"]

# Master node configurations
master_instance_type = "m4.xlarge"
master_ebs_size = "50"
# If the user chooses to set a bid price, it will implicitly create a SPOT Request
master_bid_price = "0.10"

# Slave nodes configurations
core_instance_type = "m4.xlarge"
core_instance_count = 1
# If the user chooses to set a bid price, it will implicitly create a SPOT Request
core_bid_price = "0.10"
core_ebs_size = "50"
```

## Copyright

See LICENSE for details.