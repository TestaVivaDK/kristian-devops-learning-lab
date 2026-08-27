resource "azurerm_resource_group" "lab" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}