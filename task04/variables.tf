variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "vm_password" {
  description = "Admin password for the virtual machine"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags for the Azure resources"
  type        = map(string)
}
variable "public_ip_name" {
  description = "The name of the public IP address"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
}
variable "vnet_address_space" {
  description = "The address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"] # Default value for the VNet's address space
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"] # Default value for the Subnet's address prefixes
}

variable "nic_name" {
  description = "Name of the network interface"
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
}

variable "pip_name" {
  description = "Name of the public IP"
  type        = string
}

variable "dns_name_label" {
  description = "DNS name label for the public IP"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "vm_sku" {
  description = "Size of the virtual machine"
  type        = string
}

variable "vm_os_version" {
  description = "OS version of the virtual machine"
  type        = string
}


variable "nsg_rule_allow_http" {
  description = "Name of the Network Security Group rule to allow HTTP"
  type        = string
  default     = "AllowHTTP"
}

variable "nsg_rule_allow_ssh" {
  description = "Name of the Network Security Group rule to allow SSH"
  type        = string
  default     = "AllowSSH"
}

variable "os_disk_caching" {
  description = "Caching value for the OS Disk"
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for the OS Disk (e.g., 'Standard_LRS')"
  type        = string
  default     = "Standard_LRS"
}

variable "ip_configuration_name" {
  description = "Name of the IP configuration for the NIC"
  type        = string
  default     = "internal"
}

variable "nginx_commands" {
  description = "Commands for installing and starting the NGINX service"
  type        = list(string)
  default = [
    "sudo apt-get update",
    "sudo apt-get install -y nginx",
    "sudo systemctl start nginx",
    "sudo systemctl enable nginx"
  ]
}
