resource "digitalocean_ssh_key" "tickler" {
  count = length(var.authorized_keys)
  name       = "tickler_ssh_key_${count.index}"
  public_key = var.authorized_keys[count.index]
}

resource "digitalocean_droplet" "tickler" {
  count = var.do_vm_count
  image  = "ubuntu-20-04-x64"
  name   = "tickler-${count.index}"
  region = "fra1"
  size   = "s-1vcpu-1gb"
  ssh_keys = digitalocean_ssh_key.tickler.*.fingerprint
}


resource "local_file" "do_inventory" {
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
