# Capstone Project — GCP Infrastructure with Terraform

**Student:** Devansh Tiwari
**Institution:** BITS Pilani
**Course:** Cloud Infrastructure Automation

---

## Overview

This project provisions Google Cloud Platform (GCP) infrastructure using Terraform modules. It supports three isolated environments — **dev**, **test**, and **prod** — each with its own split variable files and remote state. All shared Terraform configuration lives at the root level and is never duplicated across environments.

---

## Project Structure

```
capstone_project/
├── backend.tf                    # GCS remote state configuration
├── main.tf                       # Provider + all module calls
├── variables.tf                  # All variable declarations
├── outputs.tf                    # Root outputs
├── environments/
│   ├── dev/
│   │   ├── common.tfvars         # Project ID, region, env name
│   │   ├── vpc.tfvars            # Network name, subnet, CIDR
│   │   ├── firewall.tfvars       # Ingress rules
│   │   ├── vm.tfvars             # Machine type, disk, zone, tags
│   │   └── iam.tfvars            # Service account, roles, bindings
│   ├── test/                     # Same layout as dev
│   └── prod/                     # Same layout as dev
└── modules/
    ├── vpc/                      # VPC network and subnetwork
    ├── firewall/                 # Firewall ingress rules
    ├── vm/                       # Compute instance
    └── iam/                      # Service accounts and IAM bindings
```

---

## Modules

### `modules/vpc`
Creates a custom VPC network and a subnetwork.

| Variable | Type | Description |
|---|---|---|
| `network_name` | `string` | Name of the VPC network |
| `subnetwork_name` | `string` | Name of the subnetwork |
| `subnetwork_ip_cidr_range` | `string` | IP CIDR range (e.g. `10.0.0.0/24`) |
| `gcp_region` | `string` | GCP region for the subnetwork |

**Outputs:** `vpc_id`, `vpc_name`, `subnet_id`

---

### `modules/firewall`
Creates one or more firewall rules on the VPC using `for_each`.

| Variable | Type | Description |
|---|---|---|
| `target_network_name` | `string` | VPC network to attach rules to |
| `firewall_ingress_rules` | `list(object)` | List of rule objects |

Each rule object:
```hcl
{
  rule_name             = "allow-ssh"
  traffic_direction     = "INGRESS"
  rule_priority         = 1000
  allowed_protocol      = "tcp"
  allowed_ports         = ["22"]
  allowed_source_ranges = ["0.0.0.0/0"]
  applicable_tags       = ["ssh"]
}
```

**Outputs:** `firewall_rule_ids`

---

### `modules/vm`
Creates a GCP Compute Engine instance with an attached service account.

| Variable | Type | Description |
|---|---|---|
| `instance_name` | `string` | Name of the compute instance |
| `instance_machine_type` | `string` | Machine type (e.g. `e2-medium`) |
| `instance_zone` | `string` | GCP zone |
| `boot_disk_image` | `string` | OS image (e.g. `debian-cloud/debian-12`) |
| `boot_disk_size_gb` | `number` | Boot disk size in GB |
| `instance_subnetwork` | `string` | Subnetwork to attach the instance to |
| `enable_external_ip` | `bool` | Assign a public IP (`true`/`false`) |
| `instance_network_tags` | `list(string)` | Tags for firewall targeting |
| `instance_metadata` | `map(string)` | Key-value metadata map |
| `vm_service_account_email` | `string` | Service account email to attach |
| `vm_service_account_scopes` | `list(string)` | OAuth scopes for the service account |

**Outputs:** `instance_id`, `instance_name`, `internal_ip`

---

### `modules/iam`
Manages IAM at both project level and VM instance level, and creates a dedicated VM service account.

| Variable | Type | Description |
|---|---|---|
| `gcp_project_id` | `string` | GCP project ID |
| `instance_name` | `string` | VM instance name for instance-level bindings |
| `instance_zone` | `string` | Zone of the VM instance |
| `project_iam_bindings` | `list(object)` | `{iam_role, member_identity}` at project level |
| `vm_iam_bindings` | `list(object)` | `{iam_role, member_identity}` at VM level |
| `vm_service_account_id` | `string` | Service account ID (e.g. `prod-vm-sa`) |
| `vm_service_account_display_name` | `string` | Display name for the service account |
| `vm_service_account_roles` | `list(string)` | Roles granted to the SA at project level |

**Outputs:** `vm_service_account_email`, `vm_service_account_id`

---

## Environments

Each environment is fully isolated with its own remote state and split variable files. No Terraform configuration files are duplicated — only `.tfvars` files differ per environment.

| Setting | dev | test | prod |
|---|---|---|---|
| Machine type | `e2-small` | `e2-medium` | `e2-standard-4` |
| Disk size | 20 GB | 40 GB | 100 GB |
| Subnet CIDR | `10.0.0.0/24` | `10.1.0.0/24` | `10.2.0.0/24` |
| SSH source | `0.0.0.0/0` | `10.0.0.0/8` | `10.0.0.0/8` |
| External IP | Yes | Yes | No |
| HTTP port open | 80 + 443 | 80 + 443 | 443 only |
| State path | `dev/terraform.tfstate` | `test/terraform.tfstate` | `prod/terraform.tfstate` |

---

## Module Dependency Flow

```
iam module
  └── creates vm_service_account
        └── email passed to → vm module
                                └── attaches SA to compute instance

vpc module
  └── creates subnet_id
        └── passed to → vm module (instance_subnetwork)
        └── passed to → firewall module (target_network_name)
```

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and authenticated
- A GCP project per environment with billing enabled
- A GCS bucket named `capstone-terraform-state` for remote state storage
- Sufficient IAM permissions (`roles/editor` or equivalent)

---

## Getting Started

**1. Authenticate with GCP**
```bash
gcloud auth application-default login
```

**2. Create the remote state bucket** (one-time setup)
```bash
gsutil mb -p <your-project-id> gs://capstone-terraform-state
```

**3. Initialize Terraform with environment-specific state prefix**
```bash
terraform init -backend-config="prefix=dev/terraform.tfstate"
```

**4. Plan and apply using split tfvars**
```bash
terraform plan \
  -var-file="environments/dev/common.tfvars" \
  -var-file="environments/dev/vpc.tfvars" \
  -var-file="environments/dev/firewall.tfvars" \
  -var-file="environments/dev/vm.tfvars" \
  -var-file="environments/dev/iam.tfvars"

terraform apply \
  -var-file="environments/dev/common.tfvars" \
  -var-file="environments/dev/vpc.tfvars" \
  -var-file="environments/dev/firewall.tfvars" \
  -var-file="environments/dev/vm.tfvars" \
  -var-file="environments/dev/iam.tfvars"
```

Replace `dev` with `test` or `prod` as needed.

---

## Destroying an Environment

```bash
terraform destroy \
  -var-file="environments/dev/common.tfvars" \
  -var-file="environments/dev/vpc.tfvars" \
  -var-file="environments/dev/firewall.tfvars" \
  -var-file="environments/dev/vm.tfvars" \
  -var-file="environments/dev/iam.tfvars"
```

---

## Remote State

Each environment stores its Terraform state in a shared GCS bucket under a separate prefix:

| Environment | State Path |
|---|---|
| dev | `gs://capstone-terraform-state/dev/terraform.tfstate` |
| test | `gs://capstone-terraform-state/test/terraform.tfstate` |
| prod | `gs://capstone-terraform-state/prod/terraform.tfstate` |

---

## Notes

- All resource names are prefixed with the environment name (e.g. `dev-vpc`, `prod-vm`) to avoid conflicts across environments.
- `main.tf`, `variables.tf`, `outputs.tf`, and `backend.tf` are defined once at the root — never repeated per environment.
- Each environment only contains split `.tfvars` files: `common.tfvars`, `vpc.tfvars`, `firewall.tfvars`, `vm.tfvars`, `iam.tfvars`.
- Production has no external IP assigned to the VM — access should go through a bastion host or IAP tunnel.
- The GCS backend `prefix` is passed dynamically at `terraform init` time to isolate state per environment.
