variable "subscription_id" {
  description = "Azure subscription ID that owns the policy definition and demo resource group."
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a valid Azure subscription GUID."
  }
}

variable "location" {
  description = "Azure region for the dedicated policy-assignment resource group."
  type        = string
  default     = "southeastasia"
}

variable "resource_group_name" {
  description = "Dedicated, disposable scope for the assessment policy assignment."
  type        = string
  default     = "rg-azure-policy-assessment"
}

variable "allowed_vm_skus" {
  description = "VM SKUs approved for the demo scope. Keep this list deliberately small to demonstrate cost governance."
  type        = list(string)
  default = [
    "Standard_B2s",
    "Standard_B2ms",
    "Standard_D2as_v5"
  ]

  validation {
    condition     = length(var.allowed_vm_skus) > 0
    error_message = "At least one approved VM SKU must be supplied."
  }
}

variable "policy_effect" {
  description = "Policy response. Begin with Audit, then use Deny only after confirming the allowed SKU list."
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.policy_effect)
    error_message = "policy_effect must be Audit, Deny, or Disabled."
  }
}
