resource "null_resource" "provision_tickler" {
  triggers = {
    linode_instance          = join(",", linode_instance.tickler.*.id)
    linode_inventory_content = local_file.linode_inventory.content
    linode_inventory_id      = local_file.linode_inventory.id
    azure_instance          = join(",", azurerm_linux_virtual_machine.tickler.*.id)
    azure_inventory_content = local_file.azure_inventory.content
    azure_inventory_id      = local_file.azure_inventory.id
    do_inventory_id = local_file.do_inventory.id
    do_inventory_content = local_file.do_inventory.content
  }

  provisioner "local-exec" {
    command     = "source ./venv/bin/activate && ansible-playbook -i ./inventory playbooks/tickler.yml"
    working_dir = "./ansible"
  }
}
