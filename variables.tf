variable "access_key" {}
variable "secret_key" {}
variable "megaport_access_key" {}
variable "megaport_secret_key" {}

variable "region" {
  description = "Provide the region to deploy the VPC in"
  default     = "us-east-1"
}
variable "availability_zone" {
  description = "Provide the first availability zone to create the subnets in"
  default     = "us-east-1a"
}

################################################################################
variable "wavelength_zone" {
  description = "Provide the first wavelength zone to create the subnets in"
  default     = "us-east-1-wl1-bna-wlz-1"
}
variable "mec" {
  description = "Boolean determining whether VPC will include Wavelength Zone"
  default     = false
}
variable "connection_id" {
  description = "Provide the Direct Connect Connection ID for Megaport Module"
  default     = ""
}
################################################################################

variable "hub_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.1.0.0/16"
}
variable "hub_vpc_public_subnet_cidr" {
  description = "Provide the network CIDR for the public subnet1 in hub vpc"
  default     = "10.1.1.0/24"
}
variable "hub_vpc_private_subnet_cidr" {
  description = "Provide the network CIDR for the private subnet1 in hub vpc"
  default     = "10.1.2.0/24"
}

variable "hub_vpc_bastion_subnet_cidr" {
  description = "Provide the network CIDR for the bastion subnet1 in hub vpc"
  default     = "10.1.3.0/24"
}
variable "spoke_vpc_bastion_subnet_cidr" {
  description = "Provide the network CIDR for the bastion subnet1 in spoke vpc"
  default     = "10.2.3.0/24"
}

variable "spoke_vpc_cidr" {
  description = "Provide the network CIDR for the VPC"
  default     = "10.2.0.0/16"
}
variable "spoke_vpc_public_subnet_cidr" {
  description = "Provide the network CIDR for the public subnet1 in spoke vpc"
  default     = "10.2.1.0/24"
}
variable "spoke_vpc_private_subnet_cidr" {
  description = "Provide the network CIDR for the private subnet1 in spoke vpc"
  default     = "10.2.2.0/24"
}
variable "instance_type" {
  description = "Provide the instance type for the FortiGate instances"
  default     = "t3.xlarge"
}
variable "keypair" {
  description = "Provide a keypair for accessing the FortiGate instances"
  default     = "kp-poc-common"
}
variable "encrypt_volumes" {
  description = "Provide 'true' to encrypt the FortiGate instances OS and Log volumes with your account's KMS default master key for EBS.  Otherwise provide 'false' to leave unencrypted"
  default     = "true"
}
variable "cidr_for_access" {
  description = "Provide a network CIDR for accessing the FortiGate instances"
  default     = "0.0.0.0/0"
}
variable "fortios_version" {
  description = "Provide the verion of FortiOS to use (latest GA AMI will be used), 7.0, 7.2, or 7.4"
  default     = "7.2"
}
variable "license_type" {
  description = "Provide the license type for the FortiGate instances, byol or ond"
  default     = "ond"
}
variable "hub_fgt_byol_license" {
  description = "Provide the BYOL license filename for fgt1 and place the file in the root module folder"
  default     = ""
}
variable "spoke_fgt_byol_license" {
  description = "Provide the BYOL license filename for fgt2 and place the file in the root module folder"
  default     = ""
}
variable "hub_fgt_fortiflex_token" {
  description = "[FortiFlex only]Provide the FortiFlex Token for hub fgt (ie 1A2B3C4D5E6F7G8H9I0J)"
  default     = ""
}
variable "spoke_fgt_fortiflex_token" {
  description = "[FortiFlex only]Provide the FortiFlex Token for spoke fgt (ie 2B3C4D5E6F7G8H9I0J1K)"
  default     = ""
}
variable "hub_fgt_public_ip" {
  description = "Provide the IP address in CIDR form for the public interface of hub fgt (IP from hub_vpc_public_subnet)"
  default     = "10.1.1.10/24"
}
variable "hub_fgt_private_ip" {
  description = "Provide the IP address in CIDR form for the private interface of hub fgt (IP from hub_vpc_private_subnet)"
  default     = "10.1.2.10/24"
}
variable "spoke_fgt_public_ip" {
  description = "Provide the IP address in CIDR form for the public interface of spoke fgt (IP from spoke_vpc_public_subnet)"
  default     = "10.2.1.10/24"
}
variable "spoke_fgt_private_ip" {
  description = "Provide the IP address in CIDR form for the private interface of spoke fgt (IP from spoke_vpc_private_subnet)"
  default     = "10.2.2.10/24"
}
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "stack-1"
}
variable "ca_cert" {
  default = "automatically handled by terraform modules"
}
variable "fgt_key" {
  default = "automatically handled by terraform modules"
}
variable "fgt_cert" {
  default = "automatically handled by terraform modules"
}
variable "fgt_gui_port" {
  description = "Provide a gui port for both fgts"
  default     = "8443"
}
variable "vpn_type" {
  description = "Provide VPN type, SSL or IPsecOverTCP [IPsecOverTCP requires FortiOS version 7.4]"
  default     = "SSL"
}
variable "vpn_remote_ip" {
  default = "automatically handled by terraform modules"
}
variable "sslvpn_username" {
  description = "Provide a sslvpn username for the spoke fgt"
  default     = "spoke-fgt"
}
variable "sslvpn_password" {
  default = "automatically handled by terraform modules"
}
variable "sslvpn_public_ip" {
  default = "automatically handled by terraform modules"
}
variable "sslvpn_port" {
  description = "Provide a sslvpn port for the hub fgt"
  default     = "10443"
}
variable "sslvpn_tunnel_ip" {
  description = "Provide a sslvpn tunnel ip to use for the spoke fgt"
  default     = "10.212.134.210"
}
variable "tag_name_unique" {
  default = "automatically handled by terraform modules"
}

variable "megaport_architecture" {
  default = true
  description = "Boolean to determine whether to integrate AWS Region or Local Zone as hub via Megaport MVE"
}