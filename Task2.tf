terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.75.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "codility"
  location = "uksouth"
}


# Define the Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Define the Subnets
resource "azurerm_subnet" "azure_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "app_subnet" {
  name                 = "app_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "db_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Define the Network Interfaces
resource "azurerm_network_interface" "app_vm_interface" {
  name                = "app_vm_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "app_ip_config"
    subnet_id                     = azurerm_subnet.app_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "db_vm_interface" {
  name                = "db_vm_interface"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "db_ip_config"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Define the Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = "app-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "adminPa$$word"
  network_interface_ids = [
    azurerm_network_interface.app_vm_interface.id
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-1ts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "db_vm" {
  name                = "db-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ms"
  admin_username      = "adminuser"
  admin_password      = "adminPa$$word"
  network_interface_ids = [
    azurerm_network_interface.db_vm_interface.id
  ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-1ts"
    version   = "latest"
  }
}

# Define Public IP for Bastion Host
resource "azurerm_public_ip" "public_ip_bastion" {
  name                = "public_ip_bastion"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                  = "Standard"
}

# Define Public IP for Load Balancer
resource "azurerm_public_ip" "public_ip_lb" {
  name                = "public_ip_lb"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                  = "Standard"
}

# Define the Bastion Host
resource "azurerm_bastion_host" "bastion" {
  name                     = "bastion"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                       = "Standard"
  ip_configuration {
    name                          = "bastion_config"
    subnet_id                     = azurerm_subnet.azure_bastion_subnet.id
    public_ip_address_id          = azurerm_public_ip.public_ip_bastion.id
  }
}

# Define the Load Balancer
resource "azurerm_lb" "app_1b" {
  name                     = "app_1b"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                       = "Standard"
  
  frontend_ip_configuration {
    name                 = "app_1b_config"
    public_ip_address_id = azurerm_public_ip.public_ip_lb.id
  }
}


# Define Load Balancer Backend Pool
resource "azurerm_lb_backend_address_pool" "app_lb_backend_pool" {
  name                 = "app_lb_backend_pool"

  loadbalancer_id      = azurerm_lb.app_1b.id
}

# Define Load Balancer Association
resource "azurerm_network_interface_backend_address_pool_association" "app_lb_association" {
  network_interface_id  = azurerm_network_interface.app_vm_interface.id
  ip_configuration_name   = "testconfiguration1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.app_lb_backend_pool.id
}

# Define Load Balancer Rules for TCP Ports 80 and 443
resource "azurerm_lb_rule" "app_tcp_80" {
  name                           = "app_tcp_80"
  loadbalancer_id                = azurerm_lb.app_1b.id
  frontend_ip_configuration_name  = "80port"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
}

resource "azurerm_lb_rule" "app_tcp_443" {
  name                           = "app_tcp_443"
  loadbalancer_id                = azurerm_lb.app_1b.id
  frontend_ip_configuration_name  = "443port"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
}
