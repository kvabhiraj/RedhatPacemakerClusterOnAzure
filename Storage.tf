resource "azurerm_storage_account" "nfs_sa" {
  name                     = "nfsserversa"
  resource_group_name      = var.RG
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

