# terraform-azure-virtual-machine
# Terraform-Azure-Virtual-Machine

## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [Examples](#examples)
- [License](#license)

## Introduction
This module provides a Terraform configuration for deploying various Azure resources as part of your infrastructure. The configuration includes the deployment of resource groups, virtual networks, subnets, network security groups, Azure Key Vault, and virtual machines.

## Usage

To use this module, you can create a Terraform configuration file and include the necessary modules. You can modify the parameters to suit your specific requirements.
- # linux-vm

```hcl
module "virtual-machine" {
  source = "git::https://github.com/opz0/terraform-azure-virtual-machine.git?ref=v1.0.0"

  # Tags
  name        = "app"
  environment = "test"
  label_order = ["environment", "name"]

  # Common configuration
  is_vm_linux                     = true
  enabled                         = true
  machine_count                   = 1
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  disable_password_authentication = true

  # Network Interface configuration
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Static"
  primary                       = true
  private_ip_addresses          = ["10.0.1.6"]

  # Network Security Group configuration
  network_interface_sg_enabled = true
  network_security_group_id    = module.network_security_group.id

  # Availability Set configuration
  availability_set_enabled     = true
  platform_update_domain_count = 7
  platform_fault_domain_count  = 3

  # Public IP configuration
  public_ip_enabled = true
  sku               = "Basic"
  allocation_method = "Static"
  ip_version        = "IPv4"

  # Virtual Machine configuration
  vm_size        = "Standard_B1s"
  public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBaGAWXkDdhpEcj61gTFCV0Y97sW2YX4aD0ydNsU44yl/OGA14P7sBnXCoDhIHp7xrIJeKuPuoCli9sO7zZXhICzYvIczX3U8oOtPifje08glKbYT00mrl4lGnfQOlr50mJuTIY6b7ocs9oGi1S+oH/H0r+pEr/9gJgdkk7jE/kQOY9OfC/tcoi0dgeYKFJYe2FCU6LI+ZZA6lsz31Zl1ymv1JnwCck7yY+OFtqHxjVsmDeFz99GLmhnlAB2DOTgaOJer4gjA6JQ6Ii97KuZiIWgCkW8DQcUNYhWhZHyH9w5KT8Ug6dlIjM1w95fadkHjpt0J1QEzPQp7lvhNj1IVOnZYfu5rw5HHHyhVoglSXbCcXj9xPyEH5Yq5wdYNBgi/Q6c31riOANppfn2R++VUMaVBPyglSrKS3r39EgwTnAwK1luS13YZAN8jh2p3r9hfCD5mw23g8Z5l1qrmXM7yye53jbEUEcCShV2TGdFA2cydWwR1G1/n7DM61+EFHLSc= arjun@arjun"
  admin_username = "ubuntu"
  caching      = "ReadWrite"
  disk_size_gb = 30

  # Storage Image Reference configuration
  storage_image_reference_enabled = true
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-focal"
  image_sku                       = "20_04-lts"
  image_version                   = "latest"

  # Disk Encryption configuration
  enable_disk_encryption_set     = true
  key_vault_id                   = module.vault.id
  addtional_capabilities_enabled = true
  ultra_ssd_enabled              = false
  enable_encryption_at_host      = true
  key_vault_rbac_auth_enabled    = false

  # Data Disks configuration
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    }
  ]

  # Extension configuration
  extensions = [{
    extension_publisher            = "Microsoft.Azure.Extensions"
    extension_name                 = "hostname"
    extension_type                 = "CustomScript"
    extension_type_handler_version = "2.0"
    auto_upgrade_minor_version     = true
    automatic_upgrade_enabled      = false
    settings                       = <<SETTINGS
    {
      "commandToExecute": "hostname && uptime"
     }
     SETTINGS
  }]

  # Diagnostic settings
  diagnostic_setting_enable  = false
  log_analytics_workspace_id = ""
}
```
This module deploys an Azure Virtual Machine.For Linux OS

- # Windows-vm

```hcl
module "virtual-machine" {
  source = "git::https://github.com/opz0/terraform-azure-virtual-machine.git?ref=v1.0.0"  # Replace with the path to the module source.

  # Resource Group, location, VNet and Subnet details
  ## Tags
  name        = "app"
  environment = "test"

  ## Common
  is_vm_windows       = true
  enabled             = true
  machine_count       = 1
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  create_option       = "Empty"
  disk_size_gb        = 128
  provision_vm_agent  = true

  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Dynamic"
  primary                       = true
  network_interface_sg_enabled   = true
  network_security_group_id      = module.network_security_group.id

  ## Availability Set
  availability_set_enabled     = true
  platform_update_domain_count = 7
  platform_fault_domain_count  = 3

  ## Public IP
  public_ip_enabled = true
  sku               = "Basic"
  allocation_method = "Static"
  ip_version        = "IPv4"

  os_type       = "windows"
  computer_name = "app-win-comp"

  vm_size         = "Standard_B1s"
  admin_username  = "azureadmin"
  admin_password  = "Password@123"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"
  image_version   = "latest"
  caching         = "ReadWrite"

  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 128
      storage_account_type = "StandardSSD_LRS"
    }
  ]

  # Extension
  extensions = [{
    extension_publisher            = "Microsoft.Azure.Security"
    extension_name                 = "CustomExt"
    extension_type                 = "IaaSAntimalware"
    extension_type_handler_version = "1.3"
    auto_upgrade_minor_version     = true
    automatic_upgrade_enabled      = false
    settings                       = <<SETTINGS
                                        {
                                          "AntimalwareEnabled": true,
                                          "RealtimeProtectionEnabled": "true",
                                          "ScheduledScanSettings": {
                                              "isEnabled": "false",
                                              "day": "7",
                                              "time": "120",
                                              "scanType": "Quick"
                                          },
                                          "Exclusions": {
                                              "Extensions": "",
                                              "Paths": "",
                                              "Processes": ""
                                          }
                                        }
                                      SETTINGS
  }]
}
```
This module deploys an Azure Virtual Machine.For Windows OS

## Module Inputs
- 'name': The name of the virtual machine.
- 'environment': The environment for the virtual machine.
- 'label_order': Label order for the virtual machine.
Various other configuration parameters for the virtual machine, including network settings, disk configuration, extensions, and diagnostics.
The module allows customization through variables. You can adjust the variables in the module to match your specific requirements.

## Module Outputs
The module also provides outputs that you can use to retrieve information about the created resources, such as VM information and public IP addresses.

## Examples
For detailed examples on how to use this module, please refer to the 'examples' directory within this repository.

## License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/opz0/terraform-azure-virtual-machine/blob/readme/LICENSE) file for more details.

## Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.
