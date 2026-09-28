locals {
  common_tags = {
    assessment = "azure-policy-cost-control"
    managed_by = "terraform"
    purpose    = "interview-demo"
  }
}

resource "azurerm_resource_group" "assessment" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_policy_definition" "allowed_vm_skus" {
  name         = "asmt-allowed-vm-skus"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Assessment - allow approved virtual machine SKUs"
  description  = "Controls virtual machine spend by auditing or denying SKUs outside an approved list."

  metadata = jsonencode({
    category = "Cost Management"
    version  = "1.0.0"
    owner    = "Cloud Governance"
  })

  parameters  = file("${path.module}/policy/allowed-vm-skus.parameters.json")
  policy_rule = file("${path.module}/policy/allowed-vm-skus.policy_rule.json")
}

resource "azurerm_resource_group_policy_assignment" "allowed_vm_skus" {
  name                 = "asmt-allowed-vm-skus"
  display_name         = "Assessment - approved VM SKU cost control"
  description          = "Starts in Audit mode so policy impact is visible before enforcement."
  resource_group_id    = azurerm_resource_group.assessment.id
  policy_definition_id = azurerm_policy_definition.allowed_vm_skus.id
  enforce              = true

  parameters = jsonencode({
    allowedVmSkus = {
      value = var.allowed_vm_skus
    }
    effect = {
      value = var.policy_effect
    }
  })
}
