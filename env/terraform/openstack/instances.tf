resource "openstack_compute_keypair_v2" "pkgserver-key" {
  name = "pkgserver-key"
  public_key = "${var.id_rsa}"
}

resource "openstack_compute_floatingip_v2" "pkgserver-fip" {
  pool = "public-floating-601"
}

resource "openstack_compute_instance_v2" "pkgserver-instance" {
  name = "pnda-pkgserver"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  key_pair = "${openstack_compute_keypair_v2.pkgserver-key.name}"
  security_groups = ["${openstack_networking_secgroup_v2.pkgserver-sg.name}"]

  network {
    name = "${openstack_networking_network_v2.pkgserver-network.name}"
    floating_ip = "${openstack_compute_floatingip_v2.pkgserver-fip.address}"
    access_network = true
  }

 connection {
   type = "ssh"
   user = "cloud-user"
   private_key = "${file("pkgserver.pem")}"
 }

  provisioner "file" {
    source = "../../salt"
    destination = "/home/cloud-user"
  }

  provisioner "remote-exec" {                                                                                           
  inline = [                                                                                                          
     "sudo mkdir -p /etc/salt",
     "sudo mv /home/cloud-user/salt/etc/minion /etc/salt/minion",
     "sudo mkdir -p /srv/salt",
     "sudo mv /home/cloud-user/salt/roots/* /srv/salt",
     "rm -rf /home/cloud-user/salt",
     "sudo curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com",
     "sudo sh bootstrap-salt.sh",
     "sudo salt-call state.apply",
     "sudo usermod -G docker cloud-user",
   ]                                                                                                                   
  }                                                                                                                     
}

output "ip" {
    value = "${openstack_compute_floatingip_v2.pkgserver-fip.address}"
}
