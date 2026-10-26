output "resource_group_name" {
  description = "Name of the lab resource group."
  value       = azurerm_resource_group.lab.name
}

output "resource_group_id" {
  description = "Azure resource ID of the lab resource group."
  value       = azurerm_resource_group.lab.id
}

output "virtual_network_name" {
  description = "Name of the lab virtual network."
  value       = azurerm_virtual_network.lab.name
}

output "application_subnet_id" {
  description = "Azure resource ID of the application subnet."
  value       = azurerm_subnet.application.id
}

output "storage_account_name" {
  description = "Generated storage account name."
  value       = azurerm_storage_account.lab.name
}

output "storage_container_name" {
  description = "Private blob container name."
  value       = azurerm_storage_container.application.name
}

output "acr_name" {
  description = "Generated Azure Container Registry name."
  value       = azurerm_container_registry.lab.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.lab.login_server
}

