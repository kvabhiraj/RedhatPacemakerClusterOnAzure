resource "azurerm_linux_virtual_machine" "azure_vm" {
  count                           = var.Server_count
  name                            = "${var.server_name}0${count.index}"
  location                        = var.location
  resource_group_name             = var.RG
  network_interface_ids           = [azurerm_network_interface.nic[count.index].id]
  size                            = "Standard_B2ms"
  admin_username                  = "abhirajkv"
  admin_password                  = "Abhir12345678"
  disable_password_authentication = false
  computer_name                   = "${var.server_name}0${count.index}"
  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "810-gen2"
    version   = "latest"
  }
  os_disk {
    name                 = "${var.server_name}-${count.index}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.nfs_sa.primary_blob_endpoint
  }
  admin_ssh_key {
    username   = "abhirajkv"
    public_key = file("${path.module}/id_rsa.pub")
  }
  connection {
    type        = "ssh"
    host        = self.public_ip_address
    user        = "abhirajkv"
    private_key = file("${path.module}/id_rsa")
  }
}

resource "terraform_data" "force_trigger" {
  input = timestamp()
}

resource "local_file" "etc_hosts" {
  filename = "${path.module}/etc_hosts"
  content  = <<EOT
    %{for idx, nic in azurerm_network_interface.nic~}
    ${nic.private_ip_address} ${var.server_name}-${idx}
    %{endfor~}
    EOT
  lifecycle {
    replace_triggered_by = [terraform_data.force_trigger]
  }
}
resource "null_resource" "script_execution" {
  count      = var.Server_count
  depends_on = [azurerm_linux_virtual_machine.azure_vm]
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.azure_vm[count.index].public_ip_address
    user        = "abhirajkv"
    private_key = file("${path.module}/id_rsa")
  }
  provisioner "file" {
    source      = "${path.module}/etc_hosts"
    destination = "/home/abhirajkv/etc_hosts"
  }
  provisioner "file" {
    source      = "${path.module}/scripts/setup.sh"
    destination = "/home/abhirajkv/setup.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo cat /home/abhirajkv/etc_hosts | sudo tee -a /etc/hosts",
      "sudo /usr/bin/bash /home/abhirajkv/setup.sh > /home/abhirajkv/setup.log 2>&1",
      "sudo dnf update -y",
      "sudo dnf install -y nfs-utils pacemaker pcs fence-agents-all",
      "sudo systemctl enable pcsd",
      "sudo systemctl start pcsd",
      "sudo systemctl enable corosync",
      "sudo systemctl start corosync",
      "sudo systemctl enable pacemaker",
      "sudo systemctl start pacemaker",
      "sudo systemctl enable nfs-server",
      "sudo systemctl start nfs-server",
      "sudo firewall-cmd --permanent --add-service=nfs",
      "sudo firewall-cmd --permanent --add-service=mountd",
      "sudo firewall-cmd --permanent --add-service=rpc-bind",
      "sudo firewall-cmd --reload"
    ]
  }
}

resource "null_resource" "reboot" {
  triggers = {
    always_run = timestamp() # Change this or use a version trigger to force a reboot
  }
  count      = var.Server_count
  depends_on = [null_resource.script_execution]
  connection {
    type        = "ssh"
    user        = "abhirajkv"
    private_key = file("${path.module}/id_rsa")
    host        = azurerm_linux_virtual_machine.azure_vm[count.index].public_ip_address
  }

  # Trigger a delayed reboot and background it so SSH exits cleanly
  provisioner "remote-exec" {
    inline = [
      "sudo shutdown -r +1 'Rebooting via Terraform'; sleep 2"
    ]
  }

  # Wait for the machine to go down and come back up by polling port 22
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for server to go offline..."
      sleep 30
      echo "Waiting for server to come back online..."
      until nc -z -w5 ${azurerm_linux_virtual_machine.azure_vm[count.index].public_ip_address} 22; do
        sleep 5
      done
      echo "Server is back online!"
    EOT
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Reboot completed on ${azurerm_linux_virtual_machine.azure_vm[count.index].public_ip_address}'"
    ]
  }
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.azure_vm[*].public_ip_address
}
