output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "bastion_subnet_id" {
  value = aws_subnet.private_subnet.id
}

output "vgw_id" {
  value = var.tag_name_unique=="hub" ? aws_vpn_gateway.vpn_gw[0].id : null
}
