##### Create a Virtual Network

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.server_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.RG
}

##### Create a Subnet

resource "azurerm_subnet" "subnet" {
  name                 = "${var.server_name}-subnet"
  resource_group_name  = var.RG
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

##### Create a Public IP Address

resource "azurerm_public_ip" "public_ip" {
  count               = var.Server_count
  name                = "${var.server_name}-${count.index}-public-ip"
  location            = var.location
  resource_group_name = var.RG
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

##### Create a Network Interface 

resource "azurerm_network_interface" "nic" {
  count               = var.Server_count
  name                = "${var.server_name}-${count.index}-nic"
  location            = var.location
  resource_group_name = var.RG

  ip_configuration {
    name                          = "private"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.${count.index + 10}"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}
### Connect the security group to the network interface

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = var.Server_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
