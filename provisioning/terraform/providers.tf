terraform {
  required_providers {
    hyperv = {
      source  = "community/hyperv" # or whichever Hyper-V provider you use
      version = ">= 0.1.0"
    }
  }
}

# Note: provider aliases are created dynamically in main.tf from var.hyperv_hosts
