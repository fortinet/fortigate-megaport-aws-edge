#
# ca certificate
#
resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
}

/*
resource "local_file" "local_ca_private_key" {
  content  = tls_private_key.ca_private_key.private_key_pem
  filename = "${path.root}/ca.key"
}
*/

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_private_key.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "example-ca"
    organization = "example-org"
  }

  validity_period_hours = 43800 //  1825 days or 5 years
  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

/*
resource "local_file" "local_ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.root}/ca.cert"
}
*/

#
# hub fgt certificate
#
resource "tls_private_key" "hub_fgt_key" {
  algorithm = "RSA"
}

/*
resource "local_file" "local_hub_fgt_key" {
  content  = tls_private_key.hub_fgt_key.private_key_pem
  filename = "${path.root}/hub-fgt.key"
}
*/

resource "tls_cert_request" "hub_fgt_csr" {
  private_key_pem = tls_private_key.hub_fgt_key.private_key_pem
  #ip_addresses = ["1.2.3.4"]
  subject {
      common_name = "hub-fgt"
      organization = "example-org"
  }
}

resource "tls_locally_signed_cert" "hub_fgt" {
  cert_request_pem = tls_cert_request.hub_fgt_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 43800
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

/*
resource "local_file" "local_hub_fgt_cert" {
  content  = tls_locally_signed_cert.hub_fgt.cert_pem
  filename = "${path.root}/hub-fgt.cert"
}
*/

#
# spoke fgt certificate
#
resource "tls_private_key" "spoke_fgt_key" {
  algorithm = "RSA"
}

/*
resource "local_file" "local_spoke_fgt_key" {
  content  = tls_private_key.spoke_fgt_key.private_key_pem
  filename = "${path.root}/spoke-fgt.key"
}
*/

resource "tls_cert_request" "spoke_fgt_csr" {
  private_key_pem = tls_private_key.spoke_fgt_key.private_key_pem
  #ip_addresses = ["1.2.3.4"]
  subject {
      common_name = "spoke-fgt"
      organization = "example-org"
  }
}

resource "tls_locally_signed_cert" "spoke_fgt" {
  cert_request_pem = tls_cert_request.spoke_fgt_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem
  validity_period_hours = 43800
  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

/*
resource "local_file" "local_spoke_fgt_cert" {
  content  = tls_locally_signed_cert.spoke_fgt.cert_pem
  filename = "${path.root}/spoke-fgt.cert"
}
*/
