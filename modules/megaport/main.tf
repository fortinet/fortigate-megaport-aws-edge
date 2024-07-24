terraform {
  required_providers {
    megaport = {
      source = "megaport/megaport"
      version = "1.0.1"
    }
  }
}

provider "megaport" {
  access_key            = var.megaport_access_key
  secret_key            = var.megaport_secret_key
  accept_purchase_terms = true
  environment           = "production"
}
######### MVE #################################
data "megaport_location" "a_end" {
  name = "Digital Realty ATL1"
}

resource "megaport_mve" "test_mve" {
  location_id          = data.megaport_location.a_end.id
  product_name         = "hybrid-edge-demo-mve-atl"  
  contract_term_months = 1

  vendor_config = {
  vendor              = "fortinet"
  license_data        = " "
  image_id            = 58
  product_size        = "SMALL"
  ssh_public_key =  data.tls_public_key.private_key_pem-example.public_key_openssh
  }

  vnics = [
      {
      description = "Port1"
      },
      {
      description = "Port2"
      },
      {
      description = "Port3"
      },
  ]
}
######### INTERNET #################################

data "megaport_location" "atl" {
  name = "Digital Realty ATL1"
}

data "megaport_partner" "internet_port" {
  connect_type = "TRANSIT"
  company_name = "Networks"
  product_name = "Megaport Internet"
  location_id  = data.megaport_location.atl.id
}


resource "megaport_vxc" "transit_vxc" {
  product_name         = "Transit VXC Example"
  rate_limit           = 100
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.test_mve.product_uid
    vnic_index            = 0
  }

  b_end = {
    requested_product_uid = data.megaport_partner.internet_port.product_uid
  }

  b_end_partner_config = {
    partner = "transit"
  }
}


######### AWS HOSTED VIF #################################

data "megaport_location" "atl_dx" {
  name = "Digital Realty ATL1"
}

data "megaport_partner" "aws_port" {
  connect_type = "AWS"
  company_name = "AWS"
  product_name = "US East (N. Virginia) (us-east-1)"
  location_id  = data.megaport_location.atl_dx.id
}

data "aws_caller_identity" "current" {}
resource "megaport_vxc" "aws_vxc" {
  product_name         = "AWS-DX"
  rate_limit           = 100
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mve.test_mve.product_uid
    inner_vlan            = 100
    vnic_index            = 1
  }

  b_end = {
    requested_product_uid = data.megaport_partner.aws_port.product_uid
  }

  b_end_partner_config = {
    partner = "aws"
    aws_config = {
      name          = "AWS-DX"
      asn           = 64512
      type          = "private"
      connect_type  = "AWSHC"
      amazon_asn    = 64513
      owner_account = data.aws_caller_identity.current.account_id
      auth_key             = "Megaport"
      customer_ip_address          = "169.254.1.1/30"
      amazon_ip_address            = "169.254.1.2/30"
      AWS_label = "FNT-Hub-LocalZone-DX"
    }
  }
}


resource "tls_private_key" "ed25519-example" {
  algorithm = "RSA"
}
data "tls_public_key" "private_key_pem-example" {
  private_key_pem = tls_private_key.ed25519-example.private_key_pem
}


#################################################################################
resource "random_password" "spoke-fgt" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()"
}
resource "local_file" "mve_user_data_file" {
  content  = templatefile("${path.module}/fgt-userdata.tpl",
  {
    ca_cert        = var.ca_cert
    fgt_key        = var.fgt_key
    fgt_cert       = var.fgt_cert
    gui_port       = var.fgt_gui_port
    sv_user        = var.sslvpn_username
    sv_passwd      = random_password.spoke-fgt.result
    sv_tunnel_ip   = var.sslvpn_tunnel_ip

    fgt_inner_ip   = element(split("/", megaport_vxc.aws_vxc.csp_connections[0].customer_ip_address), 0) #We expect 169.254.1.1
    inner_vlan     = 100 # Looking for megaport_vxc.aws_vxc.a_end.inner_vlan
    fgt_asn        = 64512 #Should be b_end_partner_config.aws_config.asn
    aws_bgp_ip     = element(split("/", megaport_vxc.aws_vxc.csp_connections[0].amazon_address), 0) #We expect 169.254.1.2
    vgw_asn        = 64513 #Should be b_end_partner_config.aws_config.amazon_asn
    dx_password    = "Megaport" #Should be b_end_partner_config.aws_config.auth_key

    sv_port        = var.sslvpn_port
    vpc_cidr       = var.vpc_cidr
    license_type   = var.license_type
    license_file   = "${path.root}/${var.fgt_byol_license}"
    license_token  = var.fgt_fortiflex_token
  })
  filename = "${path.root}/modules/megaport/mve_userdata.sh"
}

# resource "null_resource" "execute_user_data" {
#   depends_on = [local_file.mve_user_data_file,megaport_mve.test_mve]

#   provisioner "remote-exec" {
#     inline = [local_file.mve_user_data_file.content]
#     connection {
#       type        = "ssh"
#       user        = "admin"
#       private_key = tls_private_key.ed25519-example.private_key_pem
#       host        = cidrhost(megaport_vxc.transit_vxc.csp_connections[0].customer_ip4_address,1)
#     }
#   }
# }