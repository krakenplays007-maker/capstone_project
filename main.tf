module "vpc" {
  source     = "./modules/vpc"
  vpcs       = var.vpcs
  gcp_region = var.gcp_region
}

module "firewall" {
  source                 = "./modules/firewall"
  firewall_ingress_rules = var.firewall_ingress_rules
  depends_on             = [module.vpc]
}

module "iam" {
  source                          = "./modules/iam"
  gcp_project_id                  = var.gcp_project_id
  project_iam_bindings            = var.project_iam_bindings
  vm_service_account_id           = var.vm_service_account_id
  vm_service_account_display_name = var.vm_service_account_display_name
  vm_service_account_roles        = var.vm_service_account_roles
}

module "vm" {
  source = "./modules/vm"
  vms = [
    for v in var.vms : merge(v, {
      instance_subnetwork = module.vpc.subnet_ids[v.instance_subnetwork_name]
    })
  ]
  vm_service_account_email = module.iam.vm_service_account_email
  vm_iam_bindings          = var.vm_iam_bindings
  gcp_project_id           = var.gcp_project_id
  depends_on               = [module.vpc, module.iam]
}
