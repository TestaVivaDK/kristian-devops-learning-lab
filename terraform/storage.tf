resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false

  keepers = {
    resource_group_name = azurerm_resource_group.lab.name
  }
}

resource "azurerm_storage_account" "lab" {
  name                             = format("stkris%s", random_string.storage_suffix.result)
  resource_group_name              = azurerm_resource_group.lab.name
  location                         = azurerm_resource_group.lab.location
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = false
  default_to_oauth_authentication  = true
  public_network_access_enabled    = false
  cross_tenant_replication_enabled = false
  tags                             = local.common_tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_container" "application" {
  name                  = "application"
  storage_account_id    = azurerm_storage_account.lab.id
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}