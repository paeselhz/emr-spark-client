resource "aws_emr_cluster" "emr-spark-cluster" {

  //  Setting the main attributes of the cluster
  //  such as name, release label, applications included

  name                              = var.name
  release_label                     = var.release_label
  applications                      = var.applications
  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true

  custom_ami_id = var.ami_id

  //  Setting the EC2 attributes, as the subnet the cluster will be included
  //  The key name to ssh into the cluster, The cluster's security groups
  //  and instance profiles

  ec2_attributes {
    subnet_id                         = var.subnet_id
    key_name                          = var.key_name
    emr_managed_master_security_group = var.emr_master_security_group
    emr_managed_slave_security_group  = var.emr_slave_security_group
    additional_master_security_groups = var.emr_master_additional_sg
    instance_profile                  = var.emr_ec2_instance_profile
  }

  ebs_root_volume_size = "50"

  // The configuration of the master instance can be requested as spot
  //  Given the instance type and the preset ebs size
  //  As default, it should only include one instance count, but for more availability
  //  The user can chance this parameter to more instances until three

  master_instance_group {
    name           = "EMR master"
    instance_type  = var.master_instance_type
    instance_count = 1
    bid_price = var.master_bid_price

    ebs_config {
      size = var.master_ebs_size
      type = "gp2"
      volumes_per_instance = 1
    }

  }

  //  For the core instance groups the user can set the bid price
  //  So the request will be made for spot instances until the bid price is reached
  //  Also the user can change the number of instances in the core group

  core_instance_group {
    name = "EMR slave"
    instance_type = var.core_instance_type
    instance_count = var.core_instance_count
    bid_price = var.core_bid_price

    ebs_config {
      size = var.core_ebs_size
      type = "gp2"
      volumes_per_instance = 1
    }

  }

  //  Below are tags created to help identify the resources of this request in AWS Console
  //  Also is set the service role and autoscaling roles

  tags = {
    Name = "${var.name} - Spark cluster"
  }

  service_role     = var.emr_service_role
  autoscaling_role = var.emr_autoscaling_role

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "Setup Hadoop Debugging"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["state-pusher-script"]
    }
  }

  step {
      name              = "Copy script file from s3."
      action_on_failure = "CANCEL_AND_WAIT"
      hadoop_jar_step {
        jar  = "command-runner.jar"
        args = ["aws", "s3", "cp", "s3://${var.name}/scripts/post-installation-cfg.sh", "/tmp/"]
      }
  }

  step {
      name              = "Creating EMR users configuration"
      action_on_failure = "CANCEL_AND_WAIT"
      hadoop_jar_step {
        jar  = "command-runner.jar"
        args = ["sudo", "bash", "/tmp/post-installation-cfg.sh"]
      }
  }

  # Optional: ignore outside changes to running cluster steps
  lifecycle {
    ignore_changes = [step]
  }

//  If the user should want any bootstrap action to take place
//  this code should be uncommented
//  bootstrap_action {
//    name = "Bootstrap setup."
//    path = "s3://${var.name}/scripts/bootstrap_actions.sh"
//  }

  configurations_json = <<EOF
    [
    {
    "Classification": "spark-defaults",
      "Properties": {
      "maximizeResourceAllocation": "true",
      "spark.dynamicAllocation.enabled": "true",
      "spark.sql.catalogImplementation": "hive"
      }
    },
{
    "Classification": "hive-site",
    "Properties": {
      "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
    }
  },
{
    "Classification": "spark-hive-site",
    "Properties": {
      "hive.metastore.client.factory.class": "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
    }
  }
  ]
  EOF
}