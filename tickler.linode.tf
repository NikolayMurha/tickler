resource "linode_instance" "tickler" {
  count           = var.linode_vm_count
  label           = "tickler-${count.index}"
  image           = "linode/ubuntu20.04"
  region          = random_shuffle.regions.result[0]
  type            = var.linode_node_type
  root_pass       = random_password.password.result
  private_ip      = false
  authorized_keys = var.authorized_keys
}

resource "local_file" "linode_inventory" {
  count = var.linode_vm_count > 0 ? 1 : 0
  filename = "./ansible/inventory/tickler_linode"
  content  = templatefile("${path.module}/templates/linode_inventory.tftpl", {
    group                = "tickler"
    instances            = linode_instance.tickler
    additional_variables = {}
  })
  depends_on = [
    linode_instance.tickler
  ]
}
