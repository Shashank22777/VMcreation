provider "azurerm" {
  features {}
}

# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  address_space       = var.vnet_address_space
  tags                = var.tags
}

# Create Subnet
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefixes
}

# Create Public IP
resource "azurerm_public_ip" "main" {
  name                = var.public_ip_name # Parameterized name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.dns_name_label
  tags                = var.tags
}

# Create Network Security Group
resource "azurerm_network_security_group" "main" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# HTTP Inbound Rule
resource "azurerm_network_security_rule" "http" {
  name                        = var.nsg_rule_allow_http
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# SSH Inbound Rule
resource "azurerm_network_security_rule" "ssh" {
  name                        = var.nsg_rule_allow_ssh
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Create Network Interface
resource "azurerm_network_interface" "main" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = var.ip_configuration_name # Parameterized IP config name
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
  tags = var.tags
}

# Associate NIC with NSG
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Data block to retrieve the Public IP address
data "azurerm_public_ip" "main" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}

# Create Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = var.location
  size                            = var.vm_sku
  admin_username                  = "azureuser"
  admin_password                  = var.vm_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = var.tags

  depends_on = [
    azurerm_public_ip.main,
    azurerm_network_interface_security_group_association.main
  ]

  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = data.azurerm_public_ip.main.ip_address
      user     = "azureuser"
      password = var.vm_password
    }

    inline = var.nginx_commands
  }
}

# Null resource to wait for SSH
resource "null_resource" "wait_for_ssh" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      host     = data.azurerm_public_ip.main.ip_address
      user     = "azureuser"
      password = var.vm_password
    }

    inline = [
      "echo Waiting for SSH to be available...",
      "sleep 10"
    ]
  }

  depends_on = [azurerm_linux_virtual_machine.main]
}
