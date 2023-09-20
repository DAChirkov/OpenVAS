terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.63.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RG_OpenVAS"
    storage_account_name = "tfstate1518643090"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "azurerm_ssh_public_key" "ssh_servers_key" {
  depends_on          = [azurerm_resource_group.rg]
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  name                = var.resource_ssh_servers_key
  public_key          = var.resource_ssh_servers_public_key
}

resource "azurerm_virtual_network" "vnet" {
  depends_on          = [azurerm_resource_group.rg]
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  name                = var.resource_virtual_network
  address_space       = ["10.1.0.0/16"]
}
resource "azurerm_subnet" "snet1" {
  depends_on           = [azurerm_virtual_network.vnet]
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.resource_virtual_network
  name                 = var.resource_subnet1
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_network_security_group" "nsg_main" {
  depends_on          = [azurerm_resource_group.rg]
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  name                = var.resource_nsg_main
}
resource "azurerm_network_security_rule" "nsg_main_ssh" {
  depends_on                  = [azurerm_network_security_group.nsg_main]
  name                        = "SSH"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_nsg_main
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.1.0.4"
}
resource "azurerm_network_security_rule" "nsg_main_http" {
  depends_on                  = [azurerm_network_security_group.nsg_main]
  name                        = "WEB-access"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.resource_nsg_main
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9392"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.1.0.4"
}

#####################################################

module "vms_for_manage" {
  vm_count                  = var.count_vms_manage
  source                    = "./modules/vms_manage"
  resource_group_name       = azurerm_resource_group.rg.name
  resource_group_location   = azurerm_resource_group.rg.location
  subnet_id                 = azurerm_subnet.snet1.id
  network_security_group_id = azurerm_network_security_group.nsg_main.id
  public_key                = azurerm_ssh_public_key.ssh_servers_key.public_key
}
