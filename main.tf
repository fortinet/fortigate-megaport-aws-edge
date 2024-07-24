provider "aws" {
  profile = "default"
  region  = var.region
}

provider "tls" {
}

module "certs" {
  source = ".//modules/pki/certs"
}

module "hub-vpc" {
  source     = ".//modules/aws/vpc"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  availability_zone   = var.availability_zone
  wavelength_zone     = var.wavelength_zone
  vpc_cidr            = var.hub_vpc_cidr
  public_subnet_cidr  = var.hub_vpc_public_subnet_cidr
  private_subnet_cidr = var.hub_vpc_private_subnet_cidr
  fgt_eni1_id         = module.hub-fgt.fgt_eni1_id
  tag_name_prefix     = var.tag_name_prefix
  tag_name_unique     = "hub"
  bastion_subnet_cidr = var.hub_vpc_bastion_subnet_cidr
}

module "spoke-vpc" {
  source     = ".//modules/aws/vpc"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  availability_zone   = var.availability_zone
  wavelength_zone     = var.wavelength_zone
  vpc_cidr            = var.spoke_vpc_cidr
  public_subnet_cidr  = var.spoke_vpc_public_subnet_cidr
  private_subnet_cidr = var.spoke_vpc_private_subnet_cidr
  bastion_subnet_cidr = var.spoke_vpc_bastion_subnet_cidr
  fgt_eni1_id         = module.spoke-fgt.fgt_eni1_id
  tag_name_prefix     = var.tag_name_prefix
  tag_name_unique     = "spoke"
}

module "hub-fgt" {
  source     = ".//modules/ftnt/hub-fgt-sslvpn"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  availability_zone = var.availability_zone
  wavelength_zone   = var.wavelength_zone
  vpc_id            = module.hub-vpc.vpc_id
  vpc_cidr          = var.hub_vpc_cidr
  public_subnet_id  = module.hub-vpc.public_subnet_id
  private_subnet_id = module.hub-vpc.private_subnet_id

  keypair             = var.keypair
  encrypt_volumes     = var.encrypt_volumes
  fortios_version     = var.fortios_version
  cidr_for_access     = var.cidr_for_access
  instance_type       = var.instance_type
  license_type        = var.license_type
  fgt_byol_license    = var.hub_fgt_byol_license
  fgt_fortiflex_token = var.hub_fgt_fortiflex_token
  tag_name_prefix     = var.tag_name_prefix

  fgt_public_ip    = var.hub_fgt_public_ip
  fgt_private_ip   = var.hub_fgt_private_ip
  ca_cert          = module.certs.ca_cert
  fgt_key          = module.certs.hub_key
  fgt_cert         = module.certs.hub_cert
  fgt_gui_port     = var.fgt_gui_port
  sslvpn_username  = var.sslvpn_username
  sslvpn_port      = var.sslvpn_port
  sslvpn_tunnel_ip = var.sslvpn_tunnel_ip

  carrier_ip = module.spoke-fgt.eip_public_ip
  megaport_architecture = var.megaport_architecture
  mve_public_ip = module.megaport.vxc_info
}


module "spoke-fgt" {
  source     = ".//modules/ftnt/spoke-fgt-sslvpn"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region

  availability_zone = var.availability_zone
  wavelength_zone   = var.wavelength_zone
  vpc_id            = module.spoke-vpc.vpc_id
  vpc_cidr          = var.spoke_vpc_cidr
  public_subnet_id  = module.spoke-vpc.public_subnet_id
  private_subnet_id = module.spoke-vpc.private_subnet_id

  keypair             = var.keypair
  encrypt_volumes     = var.encrypt_volumes
  fortios_version     = var.fortios_version
  cidr_for_access     = var.cidr_for_access
  instance_type       = var.instance_type
  license_type        = var.license_type
  fgt_byol_license    = var.spoke_fgt_byol_license
  fgt_fortiflex_token = var.spoke_fgt_fortiflex_token
  tag_name_prefix     = var.tag_name_prefix

  fgt_public_ip    = var.spoke_fgt_public_ip
  fgt_private_ip   = var.spoke_fgt_private_ip
  ca_cert          = module.certs.ca_cert
  fgt_key          = module.certs.spoke_key
  fgt_cert         = module.certs.spoke_cert
  fgt_gui_port     = var.fgt_gui_port
  sslvpn_username  = var.sslvpn_username
  sslvpn_password  = module.hub-fgt.sslvpn_password
  sslvpn_port      = var.sslvpn_port
  sslvpn_public_ip = var.megaport_architecture ? module.megaport.vxc_info : module.hub-fgt.eip_public_ip
  sslvpn_tunnel_ip = var.sslvpn_tunnel_ip

  public_ip = module.spoke-fgt.eip_public_ip
}

module "megaport" {
  source              = "./modules/megaport"
  access_key          = var.access_key
  secret_key          = var.secret_key
  region              = var.region
  connection_id       = var.connection_id
  vgw_id              = module.hub-vpc.vgw_id
  megaport_access_key = var.megaport_access_key
  megaport_secret_key = var.megaport_secret_key
  ca_cert             = module.certs.ca_cert
  fgt_key             = module.certs.hub_key
  fgt_cert            = module.certs.hub_cert
  fgt_gui_port        = var.fgt_gui_port
  sslvpn_username     = var.sslvpn_username
  sslvpn_port         = var.sslvpn_port
  sslvpn_tunnel_ip    = var.sslvpn_tunnel_ip

  vpc_cidr            = var.hub_vpc_cidr
  license_type        = var.license_type
  fgt_byol_license    = var.spoke_fgt_byol_license
  fgt_fortiflex_token = var.spoke_fgt_fortiflex_token
}
