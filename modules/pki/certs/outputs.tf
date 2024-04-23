output "ca_cert" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "hub_key" {
  value = tls_private_key.hub_fgt_key.private_key_pem
}

output "hub_cert" {
  value = tls_locally_signed_cert.hub_fgt.cert_pem
}

output "spoke_key" {
  value = tls_private_key.spoke_fgt_key.private_key_pem
}

output "spoke_cert" {
  value = tls_locally_signed_cert.spoke_fgt.cert_pem
}