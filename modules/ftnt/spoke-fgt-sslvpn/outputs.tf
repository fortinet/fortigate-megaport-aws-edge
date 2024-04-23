output "fgt_id" {
  value = aws_instance.fgt.id
}

output "eip_public_ip" {
  value = aws_eip.eip.carrier_ip
}

output "client_private_ip" {
  value = aws_instance.test_instance.private_ip
}

output "fgt_eni1_id" {
  value = aws_network_interface.fgt_eni1.id
}

output "bastion_carrier_ip" {
  value = aws_eip.eip_bastion.carrier_ip
}