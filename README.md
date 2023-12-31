# terraform-azure-virtual-machine

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
To use this module, you should have Terraform installed and configured for AZURE. This module provides the necessary Terraform configuration
for creating AZURE resources, and you can customize the inputs as needed. Below is an example of how to use this module:

# Examples

# Example: linux-vm

```hcl
module "virtual-machine" {
  source                          = "git::https://github.com/cypik/terraform-azure-virtual-machine.git?ref=v1.0.0"
  ## Tags
  name                            = "apouq"
  environment                     = "test"
  label_order                     = ["environment", "name"]
  ## Common
  is_vm_linux                     = true
  enabled                         = true
  machine_count                   = 1
  resource_group_name             = module.resource_group.resource_group_name
  location                        = module.resource_group.resource_group_location
  disable_password_authentication = true
  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Static"
  primary                       = true
  private_ip_addresses          = ["10.0.1.6"]
  #nsg
  network_interface_sg_enabled = true
  network_security_group_id    = module.network_security_group.id
  ## Availability Set
  availability_set_enabled     = true
  platform_update_domain_count = 7
  platform_fault_domain_count  = 3
  ## Public IP
  public_ip_enabled = true
  sku               = "Basic"
  allocation_method = "Static"
  ip_version        = "IPv4"
  ## Virtual Machine
  vm_size        = "Standard_B1s"
  public_key     = "ssh-rsa Cck7yYQ6c31e53jbEUEcCShV2TGdxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxEFHLSc= arjun@arjun"
  admin_username = "ubuntu"
  # admin_password                = "P@ssw0rd!123!" # It is compulsory when disable_password_authentication = false
  caching                         = "ReadWrite"
  disk_size_gb                    = 30
  storage_image_reference_enabled = true
  image_publisher                 = "Canonical"
  image_offer                     = "0001-com-ubuntu-server-focal"
  image_sku                       = "20_04-lts"
  image_version                   = "latest"
  enable_disk_encryption_set      = true
  key_vault_id                    = module.vault.id
  addtional_capabilities_enabled  = true
  ultra_ssd_enabled               = false
  enable_encryption_at_host       = false
  key_vault_rbac_auth_enabled     = false
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    }
  ]
  # Extension
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
}
```

# Example: Windows-vm

```hcl
module "virtual-machine" {
  source                        = "git::https://github.com/cypik/terraform-azure-virtual-machine.git?ref=v1.0.0"
  ## Tags
  name                          = "app"
  environment                   = "test"
  ## Common
  is_vm_windows                 = true
  enabled                       = true
  machine_count                 = 1
  resource_group_name           = module.resource_group.resource_group_name
  location                      = module.resource_group.resource_group_location
  create_option                 = "Empty"
  disk_size_gb                  = 128
  provision_vm_agent            = true
  ## Network Interface
  subnet_id                     = [module.subnet.default_subnet_id]
  private_ip_address_version    = "IPv4"
  private_ip_address_allocation = "Dynamic"
  primary                       = true
  network_interface_sg_enabled  = true
  network_security_group_id     = module.network_security_group.id
  ## Availability Set
  availability_set_enabled      = true
  platform_update_domain_count  = 7
  platform_fault_domain_count   = 3
  ## Public IP
  public_ip_enabled             = true
  sku                           = "Basic"
  allocation_method             = "Static"
  ip_version                    = "IPv4"
  os_type                       = "windows"
  computer_name                 = "app-win-comp"
  vm_size                       = "Standard_B1s"
  admin_username                = "azureadmin"
  admin_password                = "Password@123"
  image_publisher               = "MicrosoftWindowsServer"
  image_offer                   = "WindowsServer"
  image_sku                     = "2019-Datacenter"
  image_version                 = "latest"
  caching                       = "ReadWrite"

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
This example demonstrates how to create various AZURE resources using the provided modules. Adjust the input values to suit your specific requirements.

## Module Inputs
- 'name': The name of the virtual machine.
- 'environment': The environment for the virtual machine.
- 'label_order': Label order for the virtual machine.
Various other configuration parameters for the virtual machine, including network settings, disk configuration, extensions, and diagnostics.
The module allows customization through variables. You can adjust the variables in the module to match your specific requirements.

## Module Outputs
The module also provides outputs that you can use to retrieve information about the created resources, such as VM information and public IP addresses.

## Examples
For detailed examples on how to use this module, please refer to the '[examples](https://github.com/cypik/terraform-azure-virtual-machine/blob/master/_example)' directory within this repository.

## License
This Terraform module is provided under the '[License Name]' License. Please see the [LICENSE](https://github.com/cypik/terraform-azure-virtual-machine/blob/master/LICENSE) file for more details.

## Author
Your Name
Replace '[License Name]' and '[Your Name]' with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.
