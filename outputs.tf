output "id" {
  value = module.emr.id
}

output "name" {
  value = module.emr.name
}

output "master_public_dns" {
  value = module.emr.master_public_dns
}

//output "rstudio_public_dns" {
//  value = module.rstudio.master_public_dns
//}