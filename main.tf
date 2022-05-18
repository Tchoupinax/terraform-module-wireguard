resource "null_resource" "install_wireguard" {
  depends_on = [var.depends_on_]

  connection {
    type        = "ssh"
    host        = var.server_ssh_ip
    user        = var.server_ssh_user
    private_key = var.server_ssh_private_key
  }

  provisioner "file" {
    source      = "${path.module}/templates/install.sh"
    destination = "/tmp/wireguard-script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/wireguard-script.sh",
      "sudo /tmp/wireguard-script.sh ${var.clients_count + 1}",
    ]
  }

  provisioner "local-exec" {
    command = "echo '${var.server_ssh_private_key}' > tmp_private_key.txt && chmod 700 tmp_private_key.txt && scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i tmp_private_key.txt ${var.server_ssh_user}@${var.server_ssh_ip}:/tmp/{server_private_key,server_public_key,client*_private_key,client*_public_key} ${path.module} && rm -f tmp_private_key.txt"
  }
}

##
## Create reference for temp files
##

data "local_file" "server_private_key" {
  depends_on = [null_resource.install_wireguard]
  filename   = "${path.module}/server_private_key"
}

data "local_file" "server_public_key" {
  depends_on = [null_resource.install_wireguard]
  filename   = "${path.module}/server_public_key"
}

data "local_file" "client_private_key" {
  count      = var.clients_count
  depends_on = [null_resource.install_wireguard]
  filename   = "${path.module}/client${count.index + 1}_private_key"
}

data "local_file" "client_public_key" {
  count      = var.clients_count
  depends_on = [null_resource.install_wireguard]
  filename   = "${path.module}/client${count.index + 1}_public_key"
}

##
## Compute configuration files
##

data "template_file" "server_config" {
  depends_on = [data.local_file.server_private_key, data.local_file.client_public_key]

  template = file("${path.module}/templates/server.tpl")

  vars = {
    server_private_key = chomp(data.local_file.server_private_key.content)
    ip_on_the_vpn      = replace(var.CIDR, "/\\d*/0/", "1/24")
    peers = jsonencode([
      for index, peer in data.local_file.client_public_key : { public_key = chomp(data.local_file.client_public_key[index].content), ip_on_the_vpn = replace(var.CIDR, "/\\d*/0/", "${index + 2}/24") }
    ])
  }
}

data "template_file" "client_config" {
  count      = var.clients_count
  depends_on = [data.local_file.client_private_key, data.local_file.server_public_key]

  template = file("${path.module}/templates/client.tpl")

  vars = {
    client_private_key = chomp(data.local_file.client_private_key[count.index].content)
    server_public_key  = chomp(data.local_file.server_public_key.content)
    server_ip          = var.server_ssh_ip
    ip_on_the_vpn      = replace(var.CIDR, "/\\d*/0/", "${count.index + 2}/24")
  }
}

##
## Write config files
##

resource "local_file" "server" {
  depends_on = [data.template_file.server_config]

  content  = data.template_file.server_config.rendered
  filename = "${path.module}/live/wg0.conf"
}

resource "local_file" "client" {
  depends_on = [data.template_file.client_config]
  count      = var.clients_count

  content  = data.template_file.client_config[count.index].rendered
  filename = "${path.module}/live/client${count.index + 1}.conf"
}

##
## Remove temp files
##

# resource "null_resource" "clean-local" {
#   depends_on = [data.template_file.server_config, data.template_file.client_config]

#   provisioner "local-exec" {
#     command = "rm -f ${path.module}/server_private_key ${path.module}/server_public_key ${path.module}/client*_private_key ${path.module}/client*_public_key"
#   }
# }

##
## Copy configuration on the server and restart wireguard
##

resource "null_resource" "configure_wireguard_server" {
  depends_on = [data.template_file.server_config, data.template_file.client_config]

  provisioner "file" {
    source      = "${path.module}/live/wg0.conf"
    destination = "/tmp/wg0.conf"
  }

  connection {
    type        = "ssh"
    host        = var.server_ssh_ip
    user        = var.server_ssh_user
    private_key = var.server_ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/wg0.conf /etc/wireguard/wg0.conf",
      "sudo systemctl restart wg-quick@wg0"
    ]
  }
}
