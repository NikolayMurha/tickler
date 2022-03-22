resource "azurerm_resource_group" "tickler" {
  count    = var.azure_vm_count > 0 ? 1 : 0
  name     = "tickler_group"
  location = "japaneast"
}

resource "azurerm_virtual_network" "tickler" {
  count               = var.azure_vm_count > 0 ? 1 : 0
  name                = "tickler_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.tickler[0].location
  resource_group_name = azurerm_resource_group.tickler[0].name
}

resource "azurerm_subnet" "tickler" {
  count                = var.azure_vm_count > 0 ? 1 : 0
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.tickler[0].name
  virtual_network_name = azurerm_virtual_network.tickler[0].name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "tickler" {
  count               = var.azure_vm_count > 0 ? 1 : 0
  name                = "acceptanceSshSecurityGroup1"
  location            = azurerm_resource_group.tickler[0].location
  resource_group_name = azurerm_resource_group.tickler[0].name

  security_rule {
    name                       = "ssh"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_public_ip" "tickler" {
  count               = var.azure_vm_count
  name                = "acceptanceTestPublicIp${count.index}"
  resource_group_name = azurerm_resource_group.tickler[0].name
  location            = azurerm_resource_group.tickler[0].location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface" "tickler" {
  count               = var.azure_vm_count
  name                = "tickler${count.index}-nic"
  location            = azurerm_resource_group.tickler[0].location
  resource_group_name = azurerm_resource_group.tickler[0].name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tickler[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tickler[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "tickler" {
  count                     = var.azure_vm_count
  network_interface_id      = azurerm_network_interface.tickler[count.index].id
  network_security_group_id = azurerm_network_security_group.tickler[0].id
}

resource "azurerm_linux_virtual_machine" "tickler" {
  count                 = var.azure_vm_count
  name                  = "tickler${count.index}"
  resource_group_name   = azurerm_resource_group.tickler[0].name
  location              = azurerm_resource_group.tickler[0].location
  size                  = "Standard_D2s_v3"
  admin_username        = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.tickler[count.index].id
  ]

  priority        = "Spot"
  eviction_policy = "Deallocate"
#  custom_data     = "IyEvYmluL3NoCgpzdWRvIGFwdC1nZXQgaW5zdGFsbCAteSBcCiAgICBjYS1jZXJ0aWZpY2F0ZXMgXAogICAgY3VybCBcCiAgICBnbnVwZyBcCiAgICBsc2ItcmVsZWFzZSBcCiAgICB3Z2V0Cgp3Z2V0IC1PIC0gaHR0cHM6Ly9nZXQuZG9ja2VyLmNvbS8gfCBiYXNoCgpzdWRvIHN5c3RlbWN0bCBlbmFibGUgZG9ja2VyLnNlcnZpY2UKc3VkbyBzeXN0ZW1jdGwgc3RhcnQgZG9ja2VyLnNlcnZpY2UKCm1rZGlyIC1wIH4vLmRvY2tlci9jbGktcGx1Z2lucy8KY3VybCAtU0wgaHR0cHM6Ly9naXRodWIuY29tL2RvY2tlci9jb21wb3NlL3JlbGVhc2VzL2Rvd25sb2FkL3YyLjIuMy9kb2NrZXItY29tcG9zZS1saW51eC14ODZfNjQgLW8gfi8uZG9ja2VyL2NsaS1wbHVnaW5zL2RvY2tlci1jb21wb3NlCmNobW9kICt4IH4vLmRvY2tlci9jbGktcGx1Z2lucy9kb2NrZXItY29tcG9zZQpzdWRvIGNob3duICRVU0VSIC92YXIvcnVuL2RvY2tlci5zb2NrCgpzdWRvIGVjaG8gIgp2ZXJzaW9uOiBcIjMuM1wiCnNlcnZpY2VzOgogIHdvcmtlcjoKICAgIGltYWdlOiBnaGNyLmlvL29wZW5ncy91YXNoaWVsZDpsYXRlc3QKICAgIHJlc3RhcnQ6IGFsd2F5cwogICAgY29tbWFuZDoKICAgICAgLSBcIjc1MDBcIgogICAgICAtIFwidHJ1ZVwiIiA+PiAvaG9tZS9kb2NrZXItY29tcG9zZS55YW1sCgpzdWRvIGFwdCBpbnN0YWxsIC15IGRvY2tlci1jb21wb3NlCgpjZCAvaG9tZS8KCnN1ZG8gZG9ja2VyLWNvbXBvc2UgcHVsbCAmJiBzdWRvIGRvY2tlci1jb21wb3NlIHVwIC1kIC0tc2NhbGUgd29ya2VyPSQoZ3JlcCAtYyBecHJvY2Vzc29yIC9wcm9jL2NwdWluZm8pCgpzdWRvIGVjaG8gIiovMzAgKiAqICogKiBjZCAvaG9tZS8gJiYgc3VkbyBkb2NrZXItY29tcG9zZSBkb3duIC10IDEgJiYgc3VkbyBkb2NrZXItY29tcG9zZSBwdWxsICYmIHN1ZG8gZG9ja2VyLWNvbXBvc2UgdXAgLWQgLS1zY2FsZSB3b3JrZXI9JChncmVwIC1jIF5wcm9jZXNzb3IgL3Byb2MvY3B1aW5mbykiID4+IC9ob21lL2Nyb25qb2IKCiMgcmVzdGFydDphbHdheXMgc2hvdWxkIGRvIHRoZSBqb2IgdG8gcnVuIGNvbnRhaW5lciBvbiBzdGFydHVwLCBidXQgdGhlIGhhcmQgcmVzdGFydCBpcyBnb29kIGhlcmUgdG8gYXZvaWQgcHJvYmxlbXMKc3VkbyBlY2hvICJAcmVib290IGNkIC9ob21lLyAmJiBzdWRvIGRvY2tlci1jb21wb3NlIGRvd24gLXQgMSAmJiBzdWRvIGRvY2tlci1jb21wb3NlIHB1bGwgJiYgc3VkbyBkb2NrZXItY29tcG9zZSB1cCAtZCAtLXNjYWxlIHdvcmtlcj0kKGdyZXAgLWMgXnByb2Nlc3NvciAvcHJvYy9jcHVpbmZvKSIgPj4gL2hvbWUvY3JvbmpvYgpjcm9udGFiIC9ob21lL2Nyb25qb2IK"

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.authorized_keys[0]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

data "azurerm_virtual_machine" "tickler" {
  count               = var.azure_vm_count
  name                = azurerm_linux_virtual_machine.tickler[count.index].name
  resource_group_name = azurerm_resource_group.tickler[0].name
}

resource "local_file" "azure_inventory" {
  filename = "./ansible/inventory/tickler_azure"
  content  = templatefile("${path.module}/templates/azure_inventory.tftpl", {
    group                = "tickler"
    instances            = data.azurerm_virtual_machine.tickler
    admin_user = "adminuser"
    additional_variables = {
      ansible_become = "yes"
    }
  })
  depends_on = [
    azurerm_linux_virtual_machine.tickler
  ]
}

output "azure_virtual_machines" {
  value = data.azurerm_virtual_machine.tickler
}
