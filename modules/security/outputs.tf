output "emr_master_security_group" {
  value = aws_security_group.emr_master.id
}

output "emr_slave_security_group" {
  value = aws_security_group.emr_slave.id
}

output "rstudio_ec2_security_group" {
  value = aws_security_group.rstudio_edge.id
}