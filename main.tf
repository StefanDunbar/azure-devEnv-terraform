terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0" #Set the version of azurevm
    }
  }
}

provider "azurerm" {
  features {}
}
#Create Azure Resource Group
resource "azurerm_resource_group" "aztf-rg" {
  name     = "${var.resource_group}"
  location = "UK West" #Set this to the location you want to create your Dev Env

  tags = {
    environment = "dev"
  }
}
#Create Azure Virtual Network
resource "azurerm_virtual_network" "aztf-vn" {
  name                = "${var.resource_group}-vn"
  resource_group_name = azurerm_resource_group.aztf-rg.name
  location            = azurerm_resource_group.aztf-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "dev"
  }
}
#Create Subnet for Virtual Network
resource "azurerm_subnet" "aztf-subnet" {
  name                 = "${var.resource_group}-subnet"
  resource_group_name  = azurerm_resource_group.aztf-rg.name
  virtual_network_name = azurerm_virtual_network.aztf-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}
#Create Network Security Group - Will be assigned to Subnet later
resource "azurerm_network_security_group" "aztf-nsg" {
  name                = "${var.resource_group}-nsg"
  resource_group_name = azurerm_resource_group.aztf-rg.name
  location            = azurerm_resource_group.aztf-rg.location

  tags = {
    environment = "dev"
  }
}
#Create Network Security Rule on NSG - Allowing access from your IP only
resource "azurerm_network_security_rule" "aztf-dev-rule" {
  name                        = "${var.resource_group}-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.personal_ip #Your IP declared as variable in variables.tf
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.aztf-rg.name
  network_security_group_name = azurerm_network_security_group.aztf-nsg.name
}
#Associate NSG with Subnet created above
resource "azurerm_subnet_network_security_group_association" "aztf-nsga" {
  subnet_id                 = azurerm_subnet.aztf-subnet.id
  network_security_group_id = azurerm_network_security_group.aztf-nsg.id
}
#Generate Public IP - set to be Dynamic
resource "azurerm_public_ip" "aztf-ip" {
  name                = "${var.resource_group}-ip"
  resource_group_name = azurerm_resource_group.aztf-rg.name
  location            = azurerm_resource_group.aztf-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}
#Create NIC - Use previously generated public IP
resource "azurerm_network_interface" "aztf-nic" {
  name                = "${var.resource_group}-nic"
  resource_group_name = azurerm_resource_group.aztf-rg.name
  location            = azurerm_resource_group.aztf-rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.aztf-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.aztf-ip.id
  }

  tags = {
    environment = "dev"
  }
}
#Create VM - Assign NIC from above
resource "azurerm_linux_virtual_machine" "aztf-vm" {
  name                = "${var.resource_group}-vm"
  resource_group_name = azurerm_resource_group.aztf-rg.name
  location            = azurerm_resource_group.aztf-rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.aztf-nic.id,
  ]

  custom_data = filebase64("customdata.tpl") #Run contents of customdata.tpl on startup (In this case it installs Docker)

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/aztf-key.pub") #Specify where to find public SSH key (This needs to be generated locally) so that we can connect via SSH
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  #Run script 'linux-ssh-script.tpl' locally (configuration script allowing us to use remote SSH extension with vscode)
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-script.tpl", { #Our host_os variable is set in terraform.tfvars
      hostname     = self.public_ip_address,                  #Grabs the public IP of the VM we are creating to use in our script
      user         = "adminuser",
      identityfile = "~/.ssh/aztf-key"
    })
    interpreter = var.host_os == "linux" ? ["bash", "-c"] : ["Powershell", "-Command"] #Example of Conditional Expression (condition ? true val : false val)
  }

  tags = {
    environment = "dev"
  }
}
#Data sources allows us to query items from the Provider API(In this case Azure)
data "azurerm_public_ip" "aztf-ip-data" {
  name                = azurerm_public_ip.aztf-ip.name
  resource_group_name = azurerm_resource_group.aztf-rg.name
}
#Example of how to generate an ouput from 'apply'
output "aztf-public-ip-address" {
  value = "${azurerm_linux_virtual_machine.aztf-vm.name}: ${data.azurerm_public_ip.aztf-ip-data.ip_address}"
}