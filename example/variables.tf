# ---------------------------------------------------------------------------------------------------------------------
# EXAMPLE VARIABLES
# Variables for the example deployment
# ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
  default     = "rg-rsv-test"
}

variable "location" {
  type        = string
  description = "The Azure region for resources"
  default     = "uksouth"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "name" {
  type        = string
  description = "Product or service name used in the RSV name."
  default     = "platform"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to all resources."
  default     = {}
}
