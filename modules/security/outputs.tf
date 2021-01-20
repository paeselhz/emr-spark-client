output "emr_master_security_group" {
  value = aws_security_group.emr_master.id
}

output "emr_master_additional_security_group" {
  value = aws_security_group.emr_master_ad_sg.id
}

output "emr_slave_security_group" {
  value = aws_security_group.emr_slave.id
}
