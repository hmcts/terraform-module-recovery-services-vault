# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# These variables must be set when using this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  type        = string
  description = "The name of the Recovery Services Vault. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the Recovery Services Vault should exist."
}

variable "location" {
  type        = string
  description = "The Azure Region where the Recovery Services Vault should exist."
  default     = "uksouth"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES - Vault Configuration
# These variables have reasonable defaults but can be overridden.
# ---------------------------------------------------------------------------------------------------------------------

variable "sku" {
  type        = string
  description = "The SKU of the Recovery Services Vault. Possible values are Standard and RS0. Standard is recommended for most use cases."
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "RS0"], var.sku)
    error_message = "sku must be one of: Standard, RS0."
  }
}

variable "storage_mode_type" {
  type        = string
  description = "The storage redundancy type for the Recovery Services Vault. Possible values are GeoRedundant, LocallyRedundant and ZoneRedundant. Defaults to GeoRedundant for cross-region restore capability."
  default     = "GeoRedundant"

  validation {
    condition     = contains(["GeoRedundant", "LocallyRedundant", "ZoneRedundant"], var.storage_mode_type)
    error_message = "storage_mode_type must be one of: GeoRedundant, LocallyRedundant, ZoneRedundant."
  }
}

variable "cross_region_restore_enabled" {
  type        = bool
  description = "Whether to enable cross-region restore for the Recovery Services Vault. Only applicable when storage_mode_type is GeoRedundant. Once enabled, it cannot be disabled."
  default     = true
}

variable "immutability" {
  type        = string
  description = "The state of immutability for this Recovery Services Vault. Possible values are Disabled, Locked, and Unlocked. Defaults to Unlocked for immutable backups that can be configured but not tampered with. WARNING: Locked cannot be changed once set."
  default     = "Locked"

  validation {
    condition     = contains(["Disabled", "Locked", "Unlocked"], var.immutability)
    error_message = "immutability must be one of: Disabled, Locked, Unlocked."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES - Backup Policies
# Feature flags to enable/disable specific backup policies
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_vm_crit4_5_policy" {
  type        = bool
  description = "Whether to create the crit4_5 backup policy for Azure Virtual Machines. This policy is for Criticality 4 and 5 services with 8-week daily retention and extended long-term retention."
  default     = true
}

variable "enable_vm_test_policy" {
  type        = bool
  description = "Whether to create a test backup policy for Azure Virtual Machines. This policy has minimal retention for testing purposes only."
  default     = false
}

variable "vm_policy_type" {
  type        = string
  description = "The type of the VM backup policy for the test policy. Possible values are V1 (Standard) and V2 (Enhanced). Defaults to V1. Note: the crit4_5 policy always uses V2 Enhanced as required by the CNP Baseline Policy."
  default     = "V1"

  validation {
    condition     = contains(["V1", "V2"], var.vm_policy_type)
    error_message = "vm_policy_type must be one of: V1, V2."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES - crit4_5 Policy Configuration
# Configuration for the criticality 4/5 VM backup policy based on MOJ security guidance
# ---------------------------------------------------------------------------------------------------------------------

variable "crit4_5_timezone" {
  type        = string
  description = "Timezone for the crit4_5 backup schedule."
  default     = "UTC"
}

variable "crit4_5_hour_interval" {
  type        = number
  description = "The interval in hours between crit4_5 backups. Default is 4 (minimum achievable RPO with RSV per CNP Baseline Policy)."
  default     = 4

  validation {
    condition     = contains([4, 6, 8, 12], var.crit4_5_hour_interval)
    error_message = "crit4_5_hour_interval must be one of: 4, 6, 8, 12."
  }
}

variable "crit4_5_backup_window_start" {
  type        = string
  description = "The start time of the crit4_5 hourly backup window in HH:MM 24-hour format. Default is 02:00 UTC."
  default     = "02:00"
}

variable "crit4_5_hour_duration" {
  type        = number
  description = "The backup window duration in hours for crit4_5 backups. Default is 24 hours."
  default     = 24

  validation {
    condition     = var.crit4_5_hour_duration >= 4 && var.crit4_5_hour_duration <= 24
    error_message = "crit4_5_hour_duration must be between 4 and 24."
  }
}

variable "crit4_5_instant_restore_retention_days" {
  type        = number
  description = "The number of days to retain instant restore snapshots for crit4_5 workloads. Default is 7 days per CNP Baseline Policy. Instant Restore enables fast RTO by restoring from local snapshot rather than vault."
  default     = 7

  validation {
    condition     = var.crit4_5_instant_restore_retention_days >= 1 && var.crit4_5_instant_restore_retention_days <= 30
    error_message = "crit4_5_instant_restore_retention_days must be between 1 and 30."
  }
}

variable "crit4_5_daily_retention_count" {
  type        = number
  description = "The number of daily recovery points to retain for crit4_5 workloads. Default is 56 days (8 weeks) per MOJ security guidance for high impact services."
  default     = 56

  validation {
    condition     = var.crit4_5_daily_retention_count >= 7 && var.crit4_5_daily_retention_count <= 9999
    error_message = "crit4_5_daily_retention_count must be between 7 and 9999."
  }
}

variable "crit4_5_weekly_retention_count" {
  type        = number
  description = "The number of weekly backups to retain for crit4_5 workloads. Default is 8 weeks (P56D) per MOJ security guidance, matching the backup vault policy."
  default     = 8

  validation {
    condition     = var.crit4_5_weekly_retention_count >= 1 && var.crit4_5_weekly_retention_count <= 9999
    error_message = "crit4_5_weekly_retention_count must be between 1 and 9999."
  }
}

variable "crit4_5_weekly_retention_weekdays" {
  type        = list(string)
  description = "The weekday(s) to retain weekly backups. Default is Sunday."
  default     = ["Sunday"]
}

variable "crit4_5_enable_extended_retention" {
  type        = bool
  description = "Whether to enable extended long-term retention (monthly and yearly). Defaults to true for crit4_5 services but can be opted out."
  default     = true
}

variable "crit4_5_monthly_retention_count" {
  type        = number
  description = "The number of monthly backups to retain for crit4_5 workloads. Default is 2 months (P2M) per MOJ security guidance, matching the backup vault policy."
  default     = 2

  validation {
    condition     = var.crit4_5_monthly_retention_count >= 1 && var.crit4_5_monthly_retention_count <= 9999
    error_message = "crit4_5_monthly_retention_count must be between 1 and 9999."
  }
}

variable "crit4_5_monthly_retention_weekdays" {
  type        = list(string)
  description = "The weekday(s) to use when selecting the monthly retention backup."
  default     = ["Sunday"]
}

variable "crit4_5_monthly_retention_weeks" {
  type        = list(string)
  description = "The week(s) of the month to use when selecting the monthly retention backup. Possible values are First, Second, Third, Fourth, Last."
  default     = ["First"]
}

variable "crit4_5_yearly_retention_count" {
  type        = number
  description = "The number of yearly backups to retain for crit4_5 workloads. Default is 1 year (P1Y) per MOJ security guidance, matching the backup vault policy."
  default     = 1

  validation {
    condition     = var.crit4_5_yearly_retention_count >= 1 && var.crit4_5_yearly_retention_count <= 9999
    error_message = "crit4_5_yearly_retention_count must be between 1 and 9999."
  }
}

variable "crit4_5_yearly_retention_weekdays" {
  type        = list(string)
  description = "The weekday(s) to use when selecting the yearly retention backup."
  default     = ["Sunday"]
}

variable "crit4_5_yearly_retention_weeks" {
  type        = list(string)
  description = "The week(s) of the month to use when selecting the yearly retention backup."
  default     = ["First"]
}

variable "crit4_5_yearly_retention_months" {
  type        = list(string)
  description = "The month(s) of the year to use when selecting the yearly retention backup. Default is January."
  default     = ["January"]
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES - Test Policy Configuration
# Configuration for the test backup policy with minimal retention
# ---------------------------------------------------------------------------------------------------------------------

variable "test_timezone" {
  type        = string
  description = "Timezone for the test backup schedule."
  default     = "UTC"
}

variable "test_backup_time" {
  type        = string
  description = "The time of day to take the test VM backup in HH:MM 24-hour format. Default is 03:00 UTC."
  default     = "03:00"
}

variable "test_daily_retention_count" {
  type        = number
  description = "The number of daily backups to retain for test workloads. Default is 7 days (1 week) for minimal cost during testing."
  default     = 7

  validation {
    condition     = var.test_daily_retention_count >= 7 && var.test_daily_retention_count <= 9999
    error_message = "test_daily_retention_count must be between 7 and 9999."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES - Tags
# ---------------------------------------------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Recovery Services Vault resource."
  default     = {}
}


