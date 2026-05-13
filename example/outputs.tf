# ---------------------------------------------------------------------------------------------------------------------
# EXAMPLE OUTPUTS
# Outputs from the example deployment showing what consumers need
# ---------------------------------------------------------------------------------------------------------------------

output "recovery_vault_name" {
  description = "The name of the Recovery Services Vault - pass to rsv_name in the VM module"
  value       = module.recovery_services_vault.recovery_vault_name
}

output "recovery_vault_resource_group_name" {
  description = "The resource group of the Recovery Services Vault - pass to rsv_resource_group_name in the VM module"
  value       = module.recovery_services_vault.recovery_vault_resource_group_name
}

