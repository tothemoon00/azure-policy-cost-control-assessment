terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Deliberately no remote backend for this zero-cost assessment path.
  # Keep the ignored local state until Terraform has removed the demo resources.
}
