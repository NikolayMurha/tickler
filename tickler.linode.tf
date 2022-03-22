resource "linode_instance" "tickler" {
  count          = var.linode_vm_count
  label          = "k8s${count.index}"
  image          = "linode/ubuntu20.04"
  region         = random_shuffle.regions.result[0]
  type           = "g6-nanode-1"
  root_pass      = "root_pass_987654321aв65654sdasd"
  private_ip     = false
  authorized_keys = var.authorized_keys
}

resource "local_file" "linode_inventory" {
  filename = "./ansible/inventory/tickler_linode"
  content  = templatefile("${path.module}/templates/linode_inventory.tftpl", {
    group                = "tickler"
    instances            = linode_instance.tickler,
    additional_variables = {}
  })
}
