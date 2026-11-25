terraform {
  required_version = ">= 1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.58.0" # backup_tier on azurerm_backup_policy_file_share
    }
  }
}
