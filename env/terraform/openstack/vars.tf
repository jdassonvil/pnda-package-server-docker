variable "tenant_name" {
  type = "string"
  description = "targeted tenant for openstack api"
}

variable "auth_url" {
  type = "string"
  description = "authentication endpoint of openstack api"
}

variable "user_name" {
  type = "string"
  description = "username credential for openstack api"
}

variable "password" {
  type = "string"
  description = "password credential for openstack api"
}

variable "image" {
  type = "string"
  description = "the operating system image name, RHEL/Centos is preferred"
}

variable "flavor" {
  type = "string"
  description = "the instance flavor, should be at least 4GB RAM and 2 VCPU"
}

variable "id_rsa" {
  type = "string"
  description = "the public rsa key"
}

variable "router_id" {
  type = "string"
  description = "public router id"
}
