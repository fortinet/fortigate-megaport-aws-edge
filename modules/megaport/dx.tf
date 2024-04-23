# DX Setup 
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "demo-vgw"
  }
}
resource "aws_dx_private_virtual_interface" "foo" {
  count          = var.connection_id == "" ? 0 : 1
  connection_id  = var.connection_id == "" ? 0 : 1
  name           = "vif-lz"
  vlan           = 4094
  address_family = "ipv4"
  bgp_asn        = 65352
  vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
}