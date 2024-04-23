provider "megaport" {
  access_key            = var.megaport_access_key
  secret_key            = var.megaport_secret_key
  accept_purchase_terms = true
  delete_ports          = true
  environment           = "production"
}
######### MVE #################################
data "megaport_location" "a_end" {
  name = "Digital Realty ATL1"
}
resource "megaport_mve" "test_mve" {
  location_id = data.megaport_location.a_end.id
  mve_name    = "kd-api-test-atl"
  image_id    = 33
  vendor      = "FORTINET"
  size        = "SMALL"

#   vendor_config = {
#     "sshPublicKey" = var.rsa_pub_key
#   }

  vnic {    
    description = "Port1"
  }
  vnic {
    description = "Port2"
  }
  vnic {
    description = "Port3"
  }
}
######### Internet VXC #########################
data "megaport_internet" "atl_red" {
  metro                    = "Atlanta"
  requested_diversity_zone = "red"
}

resource "megaport_vxc" "test_mve" {
  vxc_name   = "internet"
  rate_limit = 100

  a_end {
    mve_id         = megaport_mve.test_mve.id
    vnic_index     = megaport_mve.test_mve.vnic.0.index
    requested_vlan = megaport_mve.test_mve.vnic.0.vlan
  }

  b_end {
    port_id = data.megaport_internet.atl_red.id
  }
}
######### AWS DX VXC ###########################
data "megaport_location" "atl_tx1" {
  name = "Digital Realty ATL1"
}

data "megaport_partner_port" "aws_port" {
  connect_type = "AWS"
  company_name = "AWS"
  product_name = "US East (N. Virginia) (us-east-1)"
  location_id  = data.megaport_location.atl_tx1.id
}
resource "megaport_aws_connection" "aws_vxc" {
  vxc_name   = "FNT-Hub-LocalZone-DX"
  rate_limit = 100

  a_end {
    mve_id         = megaport_mve.test_mve.id
    vnic_index     = megaport_mve.test_mve.vnic.1.index
    inner_vlan = 100
  }

  csp_settings {
    requested_product_id = data.megaport_partner_port.aws_port.id
    requested_asn        = 64512
    amazon_asn           = 64516
    amazon_account       = data.aws_caller_identity.current.account_id
    auth_key             = "Megaport"
    customer_ip          = "169.254.1.1/30"
    amazon_ip            = "169.254.1.2/30"
    connection_name      = "FNT-Hub-LocalZone-DX"
  }
}
###############################################