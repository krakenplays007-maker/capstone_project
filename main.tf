module "vpc" {
  count      = var.vpcs != null && var.gcp_region != null ? 1 : 0
  source     = "./modules/vpc"
  vpcs       = var.vpcs
  gcp_region = var.gcp_region
}

module "firewall" {
  count                  = var.firewall_ingress_rules != null ? 1 : 0
  source                 = "./modules/firewall"
  firewall_ingress_rules = var.firewall_ingress_rules
  depends_on             = [module.vpc]
}

module "iam" {
  count                           = var.vm_service_account_id != null && var.gcp_project_id != null ? 1 : 0
  source                          = "./modules/iam"
  gcp_project_id                  = var.gcp_project_id
  project_iam_bindings            = var.project_iam_bindings
  vm_service_account_id           = var.vm_service_account_id
  vm_service_account_display_name = var.vm_service_account_display_name
  vm_service_account_roles        = var.vm_service_account_roles
}

module "vm" {
  count  = var.vms != null && length(module.vpc) > 0 && length(module.iam) > 0 ? 1 : 0
  source = "./modules/vm"
  vms = [
    for v in var.vms : merge(v, {
      instance_subnetwork = module.vpc[0].subnet_ids[v.instance_subnetwork_name]
    })
  ]
  vm_service_account_email = module.iam[0].vm_service_account_email
  vm_iam_bindings          = var.vm_iam_bindings
  gcp_project_id           = var.gcp_project_id
  depends_on               = [module.vpc, module.iam]
}
