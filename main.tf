# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rhel-vm" {
  name = "rhel-vm-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet1"
  location = azurerm_resource_group.rhel-vm.location
  resource_group_name = azurerm_resource_group.rhel-vm.name
  address_space = ["10.0.0.0/16"]
  

}

resource "azurerm_subnet" "subnet1" {
    name = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
    resource_group_name = azurerm_resource_group.rhel-vm.name
    virtual_network_name = azurerm_virtual_network.vnet.name

  } 

resource "azurerm_network_interface" "rhel-nic1" {
    name = "rhel-nic"
    location = azurerm_resource_group.rhel-vm.location
    resource_group_name = azurerm_resource_group.rhel-vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.rhel_pub.id
  }
}

resource "azurerm_public_ip" "rhel_pub" {
  name                = "rhel_pub_ipp1"
  resource_group_name = azurerm_resource_group.rhel-vm.name
  location            = azurerm_resource_group.rhel-vm.location
  allocation_method   = "Dynamic"

}
resource "azurerm_linux_virtual_machine" "rhelvm" {
    name = "rhelvm"
    resource_group_name = azurerm_resource_group.rhel-vm.name
    location = azurerm_resource_group.rhel-vm.location
    size = "Standard_DS1_V2"
    admin_username = "tory.admin"
    network_interface_ids = [
        azurerm_network_interface.rhel-nic1.id
    ]

    admin_ssh_key {
      username = "tory.admin"
      public_key = file("/home/tory215/.ssh/id_rsa.pub")
    }
    os_disk {
        caching = "ReadWrite"
        storage_account_type = "Standard_LRS"

    }
    source_image_reference {
      publisher = "redhat"
      offer = "RHEL"
      sku = "96-gen2"
      version = "latest"
    }   
}
