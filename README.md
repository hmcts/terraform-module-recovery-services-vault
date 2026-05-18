# Azure Recovery Services Vault Terraform Module

Terraform module to create an Azure Recovery Services Vault with immutable backup policies for IaaS workloads (Azure Virtual Machines).

## Purpose

This module provisions an Azure Recovery Services Vault for Disaster Recovery (DR) protection of virtual machines.

It creates a Recovery Services Vault and MOJ-compliant backup policy for the service criticality level. The module outputs the vault name and resource group name, which are consumed by CNP/CPP Virtual Machine terraform modules to enrol virtual machines into backup.

### Backup Policies

| Policy Name | Purpose | Frequency | RPO | Daily Retention | Weekly Retention | Monthly Retention | Yearly Retention |
|-------------|---------|-----------|-----|-----------------|------------------|-------------------|------------------|
| `vm-crit4-5` | Criticality 4 & 5 VMs | Hourly (every 4h) | 4 hours | 56 days | 8 weeks | 2 months | 1 year |
| `vm-test` | Testing / non-prod VMs | Daily 03:00 | 24 hours | 7 days | N/A | N/A | N/A |

> The `vm-test` policy is opt-in (`enable_vm_test_policy = false` by default).

## Usage

### Basic Example

Call the module to create resources Policy & Recovery Service Vault:

```hcl
module "recovery_services_vault" {
  source = "git::https://github.com/hmcts/module-terraform-azurerm-recovery-services-vault.git?ref=main"

  name                = "{var.product}-rsv-{var.env}"
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.common_tags
}
```
Once in place follow the [terraform-module-virtual-machine readme](https://github.com/hmcts/terraform-module-virtual-machine) to enrol Virtual Machines

## DR Scenarios

This module supports the following DR scenarios:

### Scenario 1: Complete Azure Region Outage
- Vault uses GeoRedundant storage with cross-region restore enabled
- In case of a UK South long-term outage, Microsoft recovers the vault in the secondary GRS region
- Cross-region restore to UK West (or chosen region) can begin

### Scenario 2: Complete Azure Service Outage
- Wait for service restoration
- Restore from immutable backups once the service is available

### Scenario 3: Cyber Attack
- Immutable backups cannot be tampered with, modified, or deleted by attackers
- Only backup and restore operations are possible
- Backups are only deleted when they expire due to the retention period

## Retention Configuration

Default `vm-crit4-5` retention per CNP Baseline Policy:

| Retention Type | Count | Criteria |
|----------------|-------|----------|
| Daily | 56 days | Every day |
| Weekly | 8 weeks | First Sunday of week |
| Monthly (Extended) | 2 months | First Sunday of month |
| Yearly (Extended) | 1 year | First Sunday of January |

Extended retention (monthly and yearly) can be disabled via `crit4_5_enable_extended_retention = false`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the Recovery Services Vault | `string` | n/a | yes |
| `resource_group_name` | The name of the Resource Group | `string` | n/a | yes |
| `location` | The Azure Region | `string` | `"uksouth"` | no |
| `sku` | The SKU of the vault (`Standard` or `RS0`) | `string` | `"Standard"` | no |
| `storage_mode_type` | Storage redundancy (`GeoRedundant`, `LocallyRedundant`, `ZoneRedundant`) | `string` | `"GeoRedundant"` | no |
| `cross_region_restore_enabled` | Enable cross-region restore (GeoRedundant only) | `bool` | `true` | no |
| `immutability` | Immutability state (`Disabled`, `Unlocked`, `Locked`) | `string` | `"Locked"` | no |
| `enable_vm_crit4_5_policy` | Create the crit4_5 VM backup policy | `bool` | `true` | no |
| `enable_vm_test_policy` | Create the test VM backup policy | `bool` | `false` | no |
| `vm_policy_type` | Policy type for the test policy (`V1` or `V2`) | `string` | `"V1"` | no |
| `crit4_5_timezone` | Timezone for crit4_5 backup schedule | `string` | `"UTC"` | no |
| `crit4_5_backup_window_start` | Start time of the hourly backup window (HH:MM) | `string` | `"02:00"` | no |
| `crit4_5_hour_interval` | Hours between crit4_5 backups | `number` | `4` | no |
| `crit4_5_hour_duration` | Backup window duration in hours | `number` | `24` | no |
| `crit4_5_instant_restore_retention_days` | Days to retain instant restore snapshots | `number` | `7` | no |
| `crit4_5_daily_retention_count` | Days to retain daily backups | `number` | `56` | no |
| `crit4_5_weekly_retention_count` | Weeks to retain weekly backups | `number` | `8` | no |
| `crit4_5_weekly_retention_weekdays` | Weekdays for weekly retention | `list(string)` | `["Sunday"]` | no |
| `crit4_5_enable_extended_retention` | Enable monthly and yearly retention | `bool` | `true` | no |
| `crit4_5_monthly_retention_count` | Months to retain monthly backups | `number` | `2` | no |
| `crit4_5_yearly_retention_count` | Years to retain yearly backups | `number` | `1` | no |
| `test_timezone` | Timezone for test backup schedule | `string` | `"UTC"` | no |
| `test_backup_time` | Time of day for test backups (HH:MM) | `string` | `"03:00"` | no |
| `test_daily_retention_count` | Days to retain test backups | `number` | `7` | no |
| `tags` | Tags to assign to the vault | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `recovery_vault_name` | The name of the Recovery Services Vault. Pass to `rsv_name` in the VM module. |
| `recovery_vault_resource_group_name` | The resource group of the Recovery Services Vault. Pass to `rsv_resource_group_name` in the VM module. |
