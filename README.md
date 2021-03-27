# RStudio Server in AWS EMR easy, reproducible, and fast

In a previous post that I’ve written [(which can be found here)](https://towardsdatascience.com/data-science-meets-infrastructure-as-code-d2f62328646c)
, I shared my views on the use of 
Infrastructure as Code tools, such as Packer and Terraform, to create Amazon Machine Images (AMI),
creating a reproducible environment for data scientists and data analysts to explore Cloud 
resources with many tools pre-installed in the machine (Jupyterhub and RStudio Server).

I shall not extend myself in this post, since it has already been covered, but the repository 
associated with the other blog post uses Ansible playbooks to install the required packages and
libraries to develop analysis and models using both R and Python, however, the main reason
that I’ve explored the possibilities of creating custom AMIs is to use them as base images
in the deployment of AWS EMR Clusters.

### The reasoning

Many people that have deployed EMR Clusters in the past, already know that the deployment of 
the cluster can be associated with bootstrap scripts that will provide the necessary tools 
that the Data Scientist, Analyst, or Engineer will use in their work, and even though this
is a significant solution, it adds a time penalty to the deployment of the server (the more
packages and libraries associated with the cluster initialization, the higher will be the
time of deployment of the cluster).

The default deployment of EMR allows the provisioning of Jupyter Notebooks or Zeppelin notebooks
along with the initialization of the cluster, however, R and RStudio users are left lagging
behind since both solutions are not available natively in the EMR Cluster, so I felt
compelled to explore other solutions that were both scalable and fast allowing every 
analyst/scientist/engineer to deploy their own cluster, do their work in what language best suits
their needs, and then shut down the cluster when they are done.

After some digging, I found out that after the release of EMR 5.7 (and later), the cluster could
be deployed using a custom Amazon Machine image, only by following a few recommendations and
best practices as suggested [here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-custom-ami.html), like using an Amazon Linux 2 for EMR releases greater
than EMR 5.30 and 6.x. This was the trigger that led me to first, create a custom 
Amazon Machine Image using Packer and Ansible (to ensure the installation and configuration of
an RStudio Server), and later on use this image to deploy an EMR Cluster, and
do a few more configurations to ensure that the RStudio user would have access to 
the Spark environments, Hadoop and other features available by using an EMR Cluster.

### The How-To

As with my other blog post, this is associated with a [repository](https://github.com/paeselhz/emr-spark-client) that helps the user to:

* Deploy an EMR Cluster using Terraform and using a custom AMI
* Configure the default RStudio Server user to access the Hadoop File System and Spark environments
* Use the AWS Glue Metastore along with the Spark cluster, so that data catalogs that already exist
  in Glue can be accessed by the EMR Cluster

Beware that this deployment is AWS-focused, and I don’t have plans to develop this same project
in other clouds, even though I know it is possible by using tools that are available from
both Google Cloud Platform and Azure.

### Deploying the EMR Cluster using Terraform

In the project [repository](https://github.com/paeselhz/emr-spark-client), we have a stack to deploy 
the EMR cluster using Terraform scripts that are modularized, so any adaptations necessary to
suit your infrastructure needs (such as the creation of keys, or permission of roles) can be
implemented separately. As of today, Terraform expects the variables as described below, to 
allow the creation of the cluster master server and core nodes along with it.

This implementation also supports the use of spot instances in the master and core nodes,
however, in any production environment, it is recommended that at least the master node be
deployed as an On-Demand instance, since, if it shuts down, the whole cluster would be terminated.

The variables available in my Terraform configuration are as below:

```terraform
# EMR general configurations
name = "" # Name of the EMR Cluster
region = "us-east-1" # Region of the cluster, must be the same region that the AMI was built
key_name = "" # The name of the key pair that can be used to SSH into the cluster
//ingress_cidr_blocks = "0.0.0.0/0" # This has been deprecated since EMR clusters are not allowed
                                    # to be exposed to the internet completely (you have to manually)
                                    # allow some ports
ingress_cidr_blocks = ""  # Your IP address to connect to the cluster
release_label = "emr-6.1.0" # The release of EMR of your choice
applications = ["Hadoop", "Spark", "Hive"] # The applications to be available as the cluster starts up

# Master node configurations
master_instance_type = "m5.xlarge" # EC2 instance type of the master node
                                   # The underlying architecture of the machine must be compatible
                                   # with the one used to build the custom AMI
master_ebs_size = "50" # Size in GiB of the EBS disk allocated to master instance
master_ami = "ami-0c881554a879a06a4" # ID of the AMI created with the custom installation of R
                                     # and RStudio
# If the user chooses to set a bid price, it will implicitly create a SPOT Request
# If left empty, it will default to On-Demand instances
master_bid_price = ""

# Core nodes configurations
core_instance_type = "m5.xlarge"  # EC2 instance type of the master node
                                   # The underlying architecture of the machine must be compatible
                                   # with the one used to build the custom AMI
core_ebs_size = "50"
core_instance_count = 1 # Number of core instances that the cluster can scale
# If the user chooses to set a bid price, it will implicitly create a SPOT Request
# If left empty, it will default to On-Demand instances
core_bid_price = "0.10"
```
These configurations should be enough to get you up and running with a custom EMR cluster.

### Allowing custom ports in AWS EMR

A few changes to enhance security were added since December 2020, that require the user
to manually allow ports to be publically available as can be found [here](https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-man-sec-groups.html).
If this is not your case, you can skip to the next session, but, if you desire to expose 
your RStudio Server instance to be publically accessible through the internet, you have
to follow the steps described below:

* Go into the [AWS Console > EMR](https://console.aws.amazon.com/elasticmapreduce/home?region=us-east-1#block-public-access:)
* Select Block Public Access (which should be activated)
* Edit the port interval to allow port 8787 to be used publically by RStudio Server

If your desire is to deploy a custom server that will be available only to a few IP addresses, 
you can skip this step and set the `ingress_cidr_blocks` to your personal IP address.

### Configure the RStudio Server to use the full extent of AWS EMR resources

The steps described below are already embedded in the Terraform scripts that deploy the 
cluster and are here merely for informational purposes if someone wishes to tweak with
it and customize it.

After the deployment of the server is added a further step that configures the environment
variables that make it easier for RStudio to find the necessary files to run smoothly with
Spark, Hive, Hadoop, and other tools available in the cluster. Also, this step adds RStudio
users to the Hadoop group and allows it to modify the HDFS.

This step can be found [here](https://github.com/paeselhz/emr-spark-client/blob/master/scripts/post-installation-cfg.sh).

### AWS Glue Metastore as JSON configuration in Terraform module

With the rising of off-the-shelf tools, such as AWS Glue, that allow the transformation of 
data and storing both the data and its metadata in an easy way, there was a need to
integrate the EMR Cluster with this stack. This is also already been done in the Terraform
stack, so if the user desire to use a Hive Metastore instead of a managed AWS Glue Metastore,
this part of the code needs to be removed.

This step is done by a `configurations_json` inside the EMR main Terraform, which receives 
multiple inputs about how the cluster should be configured, changing spark-defaults 
(allowing different SQL catalog implementations for example), hive-site configurations 
to use the AWS Glue Metastore as default hive-site, and so on. The list of possibilities to be
configured can be found [here](https://docs.aws.amazon.com/emr/latest/ReleaseGuide/emr-configure-apps.html).

### Final remarks

The deployment of this project aims to close the gap between the provisioning of Data Science 
related stacks, trying to ensure that, no matter the tool that the Data Scientists/Analyst/Engineer
aims to use, they will have the opportunity to use it. By the end of the deployment, one should
be able to access, in less than 10 minutes, a fully functional EMR cluster with R and RStudio
server installed and configured in the master node of the EMR.

Any issues related to this project, including suggestions, can be added to the Github repository.

 