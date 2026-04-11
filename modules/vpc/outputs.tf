output "vpc_ids"    { value = { for k, v in google_compute_network.vpc : k => v.id } }
output "vpc_names"  { value = { for k, v in google_compute_network.vpc : k => v.name } }
output "subnet_ids" { value = { for k, v in google_compute_subnetwork.subnet : k => v.id } }
