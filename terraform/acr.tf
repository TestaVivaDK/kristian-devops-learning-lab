resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false

  keepers = {
    resource_group_name = azurerm_resource_group.lab.name
  }
}

resource "azurerm_container_registry" "lab" {
  name                = format("acrkrist%s", random_string.acr_suffix.result)
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}