variable "resource_group_location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "network_security_group_id" {}
variable "public_key" {
  type    = list(string)
  default = []
}
variable "vm_count" {
  type = number
}

variable "vms_size" {
  default     = "Standard_B1ms"
  description = "Size for VMs"
}
variable "image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
    name      = string
    product   = string
  })
  default = {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-2023-3"
    version   = "latest"
    name      = "kali-2023-3"
    product   = "kali"
  }
}
variable "storage_os_disk" {
  type = object({
    caching           = string
    managed_disk_type = string
  })
  default = {
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }
}
variable "os_profile" {
  type        = string
  default     = "azroot"
  description = "Name of admin username"
}

variable "manage_prefix" {
  default     = "VM-MNG"
  description = "Manage servers prefix"
}

