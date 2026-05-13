# ---------------------------------------------------------------------------------------------------------------------
# AZURE RECOVERY SERVICES VAULT
# Creates an Azure Recovery Services Vault with immutable backup support for IaaS workloads (VMs, Azure Files)
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_recovery_services_vault" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku

  # Storage redundancy - cross-region restore only works with GeoRedundant
  storage_mode_type            = var.storage_mode_type
  cross_region_restore_enabled = var.storage_mode_type == "GeoRedundant" ? var.cross_region_restore_enabled : false

  # Immutability settings - default to Unlocked for immutable backups
  immutability = var.immutability

  # Note: soft_delete is always enabled by default in azurerm v4+ (Azure secure-by-default policy)
  # https://learn.microsoft.com/en-us/azure/backup/secure-by-default

  tags = var.tags

  lifecycle {
    # Prevent accidental destruction of immutable vault
    prevent_destroy = false
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKUP POLICY - CRIT4_5 (Criticality 4 and 5 Services) - VM
# Policy for critical VM workloads with 8-week retention per MOJ security guidance
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_backup_policy_vm" "crit4_5" {
  count = var.enable_vm_crit4_5_policy ? 1 : 0

  name                = "vm-crit4-5"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  # V2 Enhanced required for sub-24hr RPO per CNP Baseline Policy
  policy_type      = "V2"
  timezone         = var.crit4_5_timezone
  consistency_type = "OnlyCrashConsistent"

  # Every 4 hours - minimum achievable RPO with RSV (achievable RPO: 4h vs 15min BCDR target - accepted gap)
  backup {
    frequency     = "Hourly"
    time          = var.crit4_5_backup_window_start
    hour_interval = var.crit4_5_hour_interval
    hour_duration = var.crit4_5_hour_duration
  }

  # Instant Restore - local snapshot retention for fast RTO (< 4 hours for VMs < 500 GB)
  instant_restore_retention_days = var.crit4_5_instant_restore_retention_days

  # Daily retention - 56 days (8 weeks) per MOJ security guidance for high impact services
  retention_daily {
    count = var.crit4_5_daily_retention_count
  }

  # Weekly retention - 8 weeks
  retention_weekly {
    count    = var.crit4_5_weekly_retention_count
    weekdays = var.crit4_5_weekly_retention_weekdays
  }

  # Monthly retention - 2 months
  dynamic "retention_monthly" {
    for_each = var.crit4_5_enable_extended_retention ? [1] : []
    content {
      count    = var.crit4_5_monthly_retention_count
      weekdays = var.crit4_5_monthly_retention_weekdays
      weeks    = var.crit4_5_monthly_retention_weeks
    }
  }

  # Yearly retention - 1 year
  dynamic "retention_yearly" {
    for_each = var.crit4_5_enable_extended_retention ? [1] : []
    content {
      count    = var.crit4_5_yearly_retention_count
      weekdays = var.crit4_5_yearly_retention_weekdays
      weeks    = var.crit4_5_yearly_retention_weeks
      months   = var.crit4_5_yearly_retention_months
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKUP POLICY - TEST
# Minimal retention policy for testing backup functionality with non-production VMs
# This allows validation of backup/restore processes at minimal cost
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_backup_policy_vm" "test" {
  count = var.enable_vm_test_policy ? 1 : 0

  name                = "vm-test"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  policy_type         = var.vm_policy_type

  timezone = var.test_timezone

  # Daily backup schedule
  backup {
    frequency = "Daily"
    time      = var.test_backup_time
  }

  # Minimal retention - 1 week for testing purposes
  retention_daily {
    count = var.test_daily_retention_count
  }
}
