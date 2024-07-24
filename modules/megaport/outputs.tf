output "vxc_info" {
  value = cidrhost(megaport_vxc.transit_vxc.csp_connections[0].customer_ip4_address,1)
}

output "mve_private_key" {
  value = tls_private_key.ed25519-example.private_key_pem
}

output "megaport_data" {
  value = "fgt_inner_ip = ${cidrhost(megaport_vxc.aws_vxc.csp_connections[0].customer_ip_address,1)} \n inner_vlan = ${megaport_vxc.aws_vxc.a_end.inner_vlan} \n fortigate_asn = ${megaport_vxc.aws_vxc.b_end_partner_config.aws_config.asn} \n bgp_ip = ${cidrhost(megaport_vxc.aws_vxc.b_end_partner_config.aws_config.amazon_ip_address,1)} \n vgw_asn = ${megaport_vxc.aws_vxc.b_end_partner_config.aws_config.amazon_asn}"
}

output "sslvpn_password" {
  value = random_password.spoke-fgt.result
}