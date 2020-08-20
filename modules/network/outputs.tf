output "vpc_id" {
  value = aws_vpc.emr-cluster-vpc.id
}

output "subnet_id" {
  value = aws_subnet.emr-cluster-public-subnet.id
}

