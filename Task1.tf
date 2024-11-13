terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.56.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "codility"
  location = "West Europe"
}

# 1. Define the storage account
resource "azurerm_storage_account" "upload_storage_account" {
  name                     = "uploadstorageaccount"  # Azure storage account name must be globally unique
  resource_group_name       = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type = "LRS"
}

# 2. Define the storage container
resource "azurerm_storage_container" "upload_container" {
  name                  = "upload-container"  # Azure container name must be globally unique
  storage_account_name  = azurerm_storage_account.upload_storage_account.name
  container_access_type = "blob"
}

# 3. Define the Service Bus namespace
resource "azurerm_servicebus_namespace" "upload_queue_ns" {
  name                = "upload-queue-ns"  # Azure Service Bus namespace name must be globally unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                  = "Standard"
}

# 4. Define the Service Bus queue
resource "azurerm_servicebus_queue" "upload_queue" {
  name                         = "upload-queue"
  namespace_name               = azurerm_servicebus_namespace.upload_queue_ns.name
  resource_group_name         = azurerm_resource_group.rg.name
  enable_partitioning         = true
}

# 5. Create an Event Grid event subscription
resource "azurerm_eventgrid_event_subscription" "upload_subscription" {
  name                      = "upload-event-subscription"
  scope                     = azurerm_storage_container.upload_container.id
  event_delivery_schema     = "EventGridSchema"
  service_bus_queue_endpoint_id = azurerm_servicebus_queue.upload_queue.id
  included_event_types = [
    "Microsoft.Storage.BlobCreated",  # Trigger event on blob creation
  ]
}
