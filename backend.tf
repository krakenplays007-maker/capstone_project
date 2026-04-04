terraform {
  backend "gcs" {
    bucket = "capstone-terraform-state"
    # prefix is passed at init time:
    # terraform init -backend-config="prefix=dev/terraform.tfstate"
    # terraform init -backend-config="prefix=test/terraform.tfstate"
    # terraform init -backend-config="prefix=prod/terraform.tfstate"
  }
}
