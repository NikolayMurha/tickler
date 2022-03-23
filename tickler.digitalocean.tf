resource "digitalocean_ssh_key" "tickler" {
  count = var.do_vm_count > 0 ? length(var.authorized_keys) : 0
  name       = "tickler_ssh_key_${count.index}"
  public_key = var.authorized_keys[count.index]
}

resource "digitalocean_droplet" "tickler" {
  count = var.do_vm_count
  image  = "ubuntu-20-04-x64"
  name   = "tickler-${count.index}"
  region = var.do_region
  size   = var.do_node_size
  ssh_keys = digitalocean_ssh_key.tickler.*.fingerprint
}

resource "local_file" "do_inventory" {
  count = var.do_vm_count > 0 ? 1 : 0
  filename = "./ansible/inventory/tickler_do"
  content  = templatefile("${path.module}/templates/do_inventory.tftpl", {
    group                = "tickler"
    instances            = digitalocean_droplet.tickler
    additional_variables = {}
  })
  depends_on = [
    digitalocean_droplet.tickler
  ]
}
