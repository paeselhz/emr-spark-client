// Security group that will be used by the Master node in the cluster
resource "aws_security_group" "emr_master" {
  name                   = "${var.name} - EMR-master"
  description            = "Security group for EMR master."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

//  Allow SSH traffic from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

// Spark UI ingress
  ingress {
    from_port   = 4040
    to_port     = 4040
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

//  HUE ingress
  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

//  Yarn ingress
  ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "TCP"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

// Spark History
  ingress {
      from_port   = 18080
      to_port     = 18080
      protocol    = "TCP"
      cidr_blocks = [var.ingress_cidr_blocks]
  }

//  Zeppelin UI
  ingress {
      from_port   = 8890
      to_port     = 8890
      protocol    = "TCP"
      cidr_blocks = [var.ingress_cidr_blocks]
  }


  ingress {
    from_port   = 20888
    to_port     = 20888
    protocol    = "tcp"
    cidr_blocks = [
      var.ingress_cidr_blocks]
  }

//  Allow communication between nodes in VPC
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
      from_port   = "8443"
      to_port     = "8443"
      protocol    = "TCP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EMR_master"
  }
}

// Security group that will be used by the slave nodes in the cluster
resource "aws_security_group" "emr_slave" {
  name                   = "${var.name} - EMR-slave"
  description            = "Security group for EMR slave."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

//  Allow SSH traffic from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

  //  Allow communication between nodes in VPC
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

  ingress {
      from_port   = "8443"
      to_port     = "8443"
      protocol    = "TCP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EMR_slave"
  }
}

// Security group that will be used by the RStudio edge node

resource "aws_security_group" "rstudio_edge" {
  name                   = "${var.name} - RStudio"
  description            = "Security group for RStudio edge node."
  vpc_id                 = var.vpc_id
  revoke_rules_on_delete = true

//  Allow SSH traffic from VPN
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ingress_cidr_blocks]
  }

  //  Allow communication between nodes in VPC
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    self        = true
  }

//  Expose RStudio server Port
  ingress {
      from_port   = "8787"
      to_port     = "8787"
      protocol    = "TCP"
      cidr_blocks = [var.ingress_cidr_blocks]
  }

  tags = {
    Name = "RStudio_edge_node"
  }
}