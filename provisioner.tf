resource "null_resource" "provision_tickler" {
  triggers = {
    linode_inventory_content = join(",", local_file.linode_inventory.*.content)
    azure_inventory_content = join(",", local_file.azure_inventory.*.content)
    do_inventory_content = join(",", local_file.do_inventory.*.content)
  }

  provisioner "local-exec" {
    command     = "source ./venv/bin/activate && ansible-playbook -i ./inventory playbooks/tickler.yml"
    working_dir = "./ansible"
  }
}
