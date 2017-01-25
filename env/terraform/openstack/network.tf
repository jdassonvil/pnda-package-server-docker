resource "openstack_networking_network_v2" "pkgserver-network" {
  name = "pkgserver-network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "pkgserver-subnet" {
  name = "pkgserver-subnet"
  network_id = "${openstack_networking_network_v2.pkgserver-network.id}"
  cidr = "192.168.10.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "route_internet" {
  router_id = "${var.router_id}"
  subnet_id = "${openstack_networking_subnet_v2.pkgserver-subnet.id}"
}

resource "openstack_networking_secgroup_v2" "pkgserver-sg" {
   name = "pkgserver-sg"
   description = "Package server security group"
}  

resource "openstack_networking_secgroup_rule_v2" "in-22" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.pkgserver-sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "in-8080" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 8080
  port_range_max = 8080
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.pkgserver-sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "in-3535" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 3535
  port_range_max = 3535
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.pkgserver-sg.id}"
}

resource "openstack_networking_secgroup_rule_v2" "in-5000" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 5000
  port_range_max = 5000
  remote_ip_prefix = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.pkgserver-sg.id}"
}
