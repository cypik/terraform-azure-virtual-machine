provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "cypik/resource-group/azure"
  version     = "1.0.3"
  name        = "app"
  environment = "tested"
  location    = "North Europe"
}

module "vnet" {
  source                 = "cypik/vnet/azure"
  version                = "1.0.3"
  name                   = "app"
  environment            = "test"
  resource_group_name    = module.resource_group.resource_group_name
  location               = module.resource_group.resource_group_location
  address_space          = "10.0.0.0/16"
  enable_ddos_pp         = false
  enable_network_watcher = false
}

module "subnet" {
  source               = "cypik/subnet/azure"
  version              = "1.0.3"
  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.name
  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]
  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

module "network_security_group" {
  source                  = "cypik/network-security-group/azure"
  version                 = "1.0.3"
  name                    = "app"
  environment             = "test"
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = module.resource_group.resource_group_location
  subnet_ids              = [module.subnet.default_subnet_id]
  inbound_rules = [
    {
      name                       = "ssh"
      priority                   = 101
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "10.20.0.0/32"
      source_port_range          = "*"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    },
    {
      name                       = "https"
      priority                   = 102
      access                     = "Allow"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_range          = "80,443"
      destination_address_prefix = "0.0.0.0/0"
      destination_port_range     = "22"
      description                = "ssh allowed port"
    }
  ]
}

module "vault" {
  depends_on                  = [module.vnet]
  source                      = "cypik/key-vault/azure"
  version                     = "1.0.3"
  name                        = "apyg6886tfvgdp"
  environment                 = "test"
  sku_name                    = "standard"
  resource_group_name         = module.resource_group.resource_group_name
  subnet_id                   = module.subnet.default_subnet_id
  virtual_network_id          = module.vnet.id
  enable_private_endpoint     = true
  enable_rbac_authorization   = true
  purge_protection_enabled    = true
  enabled_for_disk_encryption = true
  principal_id                = ["xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
  role_definition_name        = ["Key Vault Administrator"]

}


module "virtual-machine" {
  source = "../../"
  ## Tags
  name        = "app"
  environment = "test"
  label_order = ["environment", "name"]
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
  private_ip_addresses          = ["10.0.1.6", "10.0.1.7", "10.0.1.8"]
  #nsg
  network_interface_sg_enabled = true
  network_security_group_id    = module.network_security_group.id
  ## Availability Set
  availability_set_enabled     = true
  platform_update_domain_count = 7
  platform_fault_domain_count  = 3
  ## Public IP
  public_ip_enabled = true
  sku               = "Standard"
  allocation_method = "Static"
  ip_version        = "IPv4"
  ## Virtual Machine
  vm_size        = "Standard_B1s"
  public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8oYJxtpAiBSQqVwdSlSxR2t0OVMexVPobyA/xaM1mC2ekdSzyRfEnMRJxxs6VPJ3zHYWd6SLLs0mrTnLf5SpMonb1UtHrVr6HS2HJtjc+3FxfiS4yg7EJgsHamNJbtAqmYda/iamZd9KHlDi6qIY0E48cF68i4qf5dqVFvPWd/nG2zq10etBuGwM7Uem8w/Apx6hop0InpcBi5zsD/rih4o+lcibhkG+hibD99pfGvefBZ/0arp3yRhbU4pD+95izgEPx+OCwxtYR9gY3mfhbkuh2mwm2e8yjeE9vD+SrUXYz3LNrarl/ACYJid7RU1VRjE5lyWMsanwCkQur9wUgOIrjr5rrnPalx3Kq7oI9Ls+iqMXpqsuAzSvPJPZU7kFCTWBwJ5gMMBNjfuki1vf4AmF5IkZsPnD1+nruCOTiO37Jh/WfufHCJii3tNksNzri4DdNGZssB5W8o8tybaGgj5SkaqzKno/REFHIqglohEKe/i3D4idDDAHXYsAWUbZ14dt/tY49P0q071PTtjLnM/c81D8m/EpCgnyIGmQ6TK6IYXh+t2d4H+4hNgpJMydUBjCVdYYny3fVkVcG+TBXDIZ+bedgWPdRkGLpsmM/QDG5MlQ9VZuKM5vkKR/zF4uoStz13P0Dewbzv3lsCxQcnubpTs1ltc+MQT5AZv4hbQ== example@cypik.com"
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
  key_vault_rbac_auth_enabled     = true
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