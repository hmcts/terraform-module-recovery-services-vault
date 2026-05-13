# ---------------------------------------------------------------------------------------------------------------------
# RECOVERY SERVICES VAULT OUTPUTS
# Outputs for consumers to reference when enrolling resources in backup
# ---------------------------------------------------------------------------------------------------------------------

output "recovery_vault_name" {
  description = "The name of the Azure Recovery Services Vault."
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_resource_group_name" {
  description = "The resource group name of the Azure Recovery Services Vault. Use this alongside recovery_vault_name when enrolling VMs in backup."
  value       = var.resource_group_name
}
