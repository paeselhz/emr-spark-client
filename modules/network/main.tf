// Creating the main VPC the will be used by the EMR Cluster
resource "aws_vpc" "emr-cluster-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "EMR Cluster VPC"
    }
}

// Creating the subnet which will be used by the gateway
resource "aws_subnet" "emr-cluster-public-subnet" {
  vpc_id            = aws_vpc.emr-cluster-vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "EMR Cluster Public Subnet"
  }
}

resource "aws_internet_gateway" "emr-cluster-gateway" {
  vpc_id = aws_vpc.emr-cluster-vpc.id

  tags = {
    Name = "EMR Cluster Gateway"
  }
}

resource "aws_route_table" "emr-cluster-public-routing-table" {
  vpc_id = aws_vpc.emr-cluster-vpc.id

  route {
    cidr_block = var.ingress_cidr_blocks
    gateway_id = aws_internet_gateway.emr-cluster-gateway.id
  }

  tags = {
    Name = "EMR Cluster Route Table"
  }
}

resource "aws_route_table_association" "public-route-association" {
  subnet_id      = aws_subnet.emr-cluster-public-subnet.id
  route_table_id = aws_route_table.emr-cluster-public-routing-table.id
}