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

output "crit4_5_backup_policy_id" {
  description = "The ID of the crit4_5 VM backup policy. Use this as backup_policy_id when enrolling VMs in azurerm_backup_protected_vm."
  value       = var.enable_vm_crit4_5_policy ? azurerm_backup_policy_vm.crit4_5[0].id : null
}
