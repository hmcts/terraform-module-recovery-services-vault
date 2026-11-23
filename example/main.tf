# ---------------------------------------------------------------------------------------------------------------------
# EXAMPLE: Azure Recovery Services Vault for VM Immutable Backups
# This example demonstrates how to create a centralised Recovery Services Vault with immutable backup policies
# for Criticality 4/5 Azure Virtual Machines.
#
# Use Case:
# - DR protection for critical IaaS virtual machines
# - Immutable backups protected from cyber attacks
# - Cross-region restore capability (UK South -> UK West)
# - 8-week retention per MOJ security guidance
# ---------------------------------------------------------------------------------------------------------------------

# Create a resource group for the Recovery Services Vault
resource "azurerm_resource_group" "rsv" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Create the centralised Recovery Services Vault with immutable backup policies
module "recovery_services_vault" {
  source = "../"

  name                = "rsv-${var.name}-vm-${var.environment}"
  resource_group_name = azurerm_resource_group.rsv.name
  location            = azurerm_resource_group.rsv.location

  # Vault settings - defaults are already set for immutable, geo-redundant storage
  # Uncomment to override defaults:
  # sku                          = "Standard"      # Default
  # storage_mode_type            = "GeoRedundant"  # Default - enables cross-region restore
  # cross_region_restore_enabled = true            # Default - for UK South -> UK West DR scenario
  # immutability                 = "Unlocked"      # Default - immutable but can be configured

  # Enable both policies - crit4_5 for production, test for validation
  enable_vm_crit4_5_policy = true
  enable_vm_test_policy    = true

  # crit4_5 policy uses sensible defaults per CNP Baseline Policy:
  # - Hourly backups (every 4h) starting 02:00 UTC
  # - 56-day (8-week) daily retention
  # - 8-week weekly retention
  # - 2-month monthly extended retention
  # - 1-year yearly extended retention

  tags = var.tags
}
