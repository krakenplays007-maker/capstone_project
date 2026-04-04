module "vpc" {
  source                   = "./modules/vpc"
  network_name             = var.network_name
  subnetwork_name          = var.subnetwork_name
  subnetwork_ip_cidr_range = var.subnetwork_ip_cidr_range
  gcp_region               = var.gcp_region
}

module "firewall" {
  source                 = "./modules/firewall"
  target_network_name    = module.vpc.vpc_name
  firewall_ingress_rules = var.firewall_ingress_rules
}

module "iam" {
  source                          = "./modules/iam"
  gcp_project_id                  = var.gcp_project_id
  instance_name                   = var.instance_name
  instance_zone                   = var.instance_zone
  project_iam_bindings            = var.project_iam_bindings
  vm_iam_bindings                 = var.vm_iam_bindings
  vm_service_account_id           = var.vm_service_account_id
  vm_service_account_display_name = var.vm_service_account_display_name
  vm_service_account_roles        = var.vm_service_account_roles
}

module "vm" {
  source                      = "./modules/vm"
  instance_name               = var.instance_name
  instance_machine_type       = var.instance_machine_type
  instance_zone               = var.instance_zone
  boot_disk_image             = var.boot_disk_image
  boot_disk_size_gb           = var.boot_disk_size_gb
  instance_subnetwork         = module.vpc.subnet_id
  enable_external_ip          = var.enable_external_ip
  instance_network_tags       = var.instance_network_tags
  instance_metadata           = var.instance_metadata
  vm_service_account_email    = module.iam.vm_service_account_email
  vm_service_account_scopes   = var.vm_service_account_scopes
}
