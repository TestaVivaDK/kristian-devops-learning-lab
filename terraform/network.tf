resource "azurerm_virtual_network" "lab" {
  name                = "vnet-kristian-devops-lab"
  address_space       = ["10.50.0.0/16"]
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  tags                = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_subnet" "application" {
  name                 = "snet-application"
  resource_group_name  = azurerm_resource_group.lab.name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = ["10.50.1.0/24"]

  lifecycle {
    prevent_destroy = true
  }
}