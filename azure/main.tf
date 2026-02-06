locals{
  resource_group_name = "myrg"
  location = "southindia"

  virtual_network = {
    name = "v1-network"
    address_space = ["10.0.0.0/16"]
  }
  subnets =[
  {
    name = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  },
  ]


}
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location

}

# Virtual Network
resource "azurerm_virtual_network" "vnet1" {
  name                = local.virtual_network.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = local.virtual_network.address_space

  depends_on = [ azurerm_resource_group.rg ]

  tags = {
    environment = "test"
  }
}

# Subnet
resource "azurerm_subnet" "subnet-a" {
  name                 = local.subnets[0].name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.virtual_network.name
  address_prefixes     = local.subnets[0].address_prefixes
  
  depends_on = [ azurerm_virtual_network.vnet1 ]
}

# Network Interface
resource "azurerm_network_interface" "nic1" {
  name                = "nic"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = azurerm_subnet.subnet-a.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public-ip1.id
  }
  depends_on = [ azurerm_subnet.subnet-a ]
}

# Public IP
resource "azurerm_public_ip" "public-ip1" {
  name                = "TestPublicIp1"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"

  tags = {
    environment = "test"
  }
  depends_on = [ local.resource_group_name ]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "TestSecurityGroup1"
  location            = local.location
  resource_group_name = local.resource_group_name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags = {
    environment = "test"
  }

  depends_on = [ azurerm_resource_group.rg ]
}

resource "azurerm_subnet_network_security_group_association" "nsg-association1" {
  subnet_id                 = azurerm_subnet.subnet-a.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm1"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}