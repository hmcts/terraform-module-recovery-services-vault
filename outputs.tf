# ---------------------------------------------------------------------------------------------------------------------
# RECOVERY SERVICES VAULT OUTPUTS
# Outputs for consumers to reference when enrolling resources in backup
# ---------------------------------------------------------------------------------------------------------------------

output "recovery_vault_name" {
  description = "The name of the Azure Recovery Services Vault."
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_id" {
  description = "The ID of the Azure Recovery Services Vault. Use as the scope for role assignments on the vault."
  value       = azurerm_recovery_services_vault.main.id
}

output "recovery_vault_resource_group_name" {
  description = "The resource group name of the Azure Recovery Services Vault. Use this alongside recovery_vault_name when enrolling VMs in backup."
  value       = var.resource_group_name
}

output "crit4_5_backup_policy_id" {
  description = "The ID of the crit4_5 VM backup policy. Use this as backup_policy_id when enrolling VMs in azurerm_backup_protected_vm."
  value       = var.enable_vm_crit4_5_policy ? azurerm_backup_policy_vm.crit4_5[0].id : null
}

output "file_share_crit4_5_backup_policy_id" {
  description = "The ID of the fileshare-crit4-5 backup policy. Use this as backup_policy_id when enrolling Azure File Shares in azurerm_backup_protected_file_share. Null when enable_file_share_crit4_5_policy is false."
  value       = var.enable_file_share_crit4_5_policy ? azurerm_backup_policy_file_share.crit4_5[0].id : null
}

output "file_share_test_backup_policy_id" {
  description = "The ID of the fileshare-test backup policy. Use this as backup_policy_id when enrolling Azure File Shares in azurerm_backup_protected_file_share. Null when enable_file_share_test_policy is false."
  value       = var.enable_file_share_test_policy ? azurerm_backup_policy_file_share.test[0].id : null
}
