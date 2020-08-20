output "id" {
  value = aws_instance.rstudio-ec2-instance.id
}

output "name" {
  value = aws_instance.rstudio-ec2-instance.tags.Name
}

output "master_public_dns" {
  value = aws_instance.rstudio-ec2-instance.public_dns
}