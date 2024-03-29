resource "azurerm_resource_group" "DevSecOpsProject" {
  name     = "DevSecOpsProject"
  location = "Central US"
}

resource "azurerm_virtual_network" "ProjectVNET" {
  name                = "ProjectVNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.DevSecOpsProject.location
  resource_group_name = azurerm_resource_group.DevSecOpsProject.name
}

resource "azurerm_subnet" "ProjectSubnet" {
  name                 = "ProjectSubnet"
  resource_group_name  = azurerm_resource_group.DevSecOpsProject.name
  virtual_network_name = azurerm_virtual_network.ProjectVNET.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "JenkinsIP" {
  name                = "JenkinsIP"
  location            = azurerm_resource_group.DevSecOpsProject.location
  resource_group_name = azurerm_resource_group.DevSecOpsProject.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Project"
  }
}

resource "azurerm_network_interface" "JenkinsNIC" {
  name                = "JenkinsNIC"
  location            = azurerm_resource_group.DevSecOpsProject.location
  resource_group_name = azurerm_resource_group.DevSecOpsProject.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ProjectSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.JenkinsIP.id
  }
}

resource "azurerm_linux_virtual_machine" "JenkinsVM" {
  name                = "JenkinsVM"
  resource_group_name = azurerm_resource_group.DevSecOpsProject.name
  location            = azurerm_resource_group.DevSecOpsProject.location
  size                = "Standard_DS3_v2"
  admin_username      = "adminuser"
  custom_data = var.startup_script
  network_interface_ids = [azurerm_network_interface.JenkinsNIC.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

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

resource "azurerm_network_security_group" "JenkinsNSG" {
  name                = "JenkinsNSG"
  location            = azurerm_resource_group.DevSecOpsProject.location
  resource_group_name = azurerm_resource_group.DevSecOpsProject.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Jenkins"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WebApp"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Mail"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Project"
  }
}

resource "azurerm_container_registry" "ProjectACR678" {
  name                     = "ProjectACR678"
  resource_group_name      = azurerm_resource_group.DevSecOpsProject.name
  location                 = azurerm_resource_group.DevSecOpsProject.location
  sku                      = "Standard"
  admin_enabled            = true
}

