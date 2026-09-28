output "assessment_resource_group_id" {
  description = "Scope of the assessment policy assignment."
  value       = azurerm_resource_group.assessment.id
}

output "policy_definition_id" {
  description = "Subscription-level custom policy definition ID."
  value       = azurerm_policy_definition.allowed_vm_skus.id
}

output "policy_assignment_id" {
  description = "Resource-group policy assignment ID."
  value       = azurerm_resource_group_policy_assignment.allowed_vm_skus.id
}

output "policy_effect" {
  description = "Configured policy response."
  value       = var.policy_effect
}
