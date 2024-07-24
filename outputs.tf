output "my-private-key" {
  value     = module.megaport.mve_private_key
  sensitive = true
}

output "mve-info" {
  value = module.megaport.megaport_data
}

output "hub_fgt_login_info" {
  value = var.megaport_architecture ? null : <<FGTLOGIN
  # hub-fgt username: admin
  # hub-fgt initial password: ${module.hub-fgt.fgt_id}
  # hub-fgt login url: https://${module.hub-fgt.eip_public_ip}:${var.fgt_gui_port}
  FGTLOGIN
}

output "spoke_fgt_login_info" {
  value = <<FGTLOGIN
  # spoke-fgt username: admin
  # spoke-fgt initial password: ${module.spoke-fgt.fgt_id}
  # spoke-fgt login url: https://${module.spoke-fgt.eip_public_ip}:${var.fgt_gui_port}
  FGTLOGIN
}

output "megaport_config" {
  value = <<MEGAPORTCONFIG
  # To start, query the Virtual Interface ID of the Meagport VXC
  VIF_ID=$(aws directconnect describe-virtual-interfaces --query "virtualInterfaces[?virtualInterfaceName=='AWS-DX'].virtualInterfaceId" --output text)
 
  # Next, accept the VIF by querying the VGW
  VGW_ID=$(aws ec2 describe-vpn-gateways --filters "Name=attachment.vpc-id,Values=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=fortigate-megaport-aws-edge-hub-vpc" --query "Vpcs[0].VpcId" --output text)" --query "VpnGateways[0].VpnGatewayId" --output text)
  aws directconnect confirm-private-virtual-interface --virtual-interface-id $VIF_ID --virtual-gateway-id $VGW_ID
  
  # Next, login to the Fortigate
  terraform output my-private-key > mve-private-key.pem
  chmod 400 mve-private-key.pem
  ssh -i mve-private-key.pem admin@${module.megaport.vxc_info}
  # Be sure to copy the files from mve_userdata.sh to the Fortigate

  # Next, update the routing of the client private subnet
  route_table_id=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=fortigate-megaport-aws-edge-hub-private-rt" --query "RouteTables[0].RouteTableId" --output text)
  aws ec2 delete-route --route-table-id "$route_table_id" --destination-cidr-block 0.0.0.0/0
  aws ec2 create-route \
    --route-table-id "$route_table_id" \
    --destination-cidr-block "0.0.0.0/0" \
    --gateway-id "$VGW_ID"
  aws ec2 enable-vgw-route-propagation \
    --route-table-id "$route_table_id" \
    --gateway-id "$VGW_ID"
  MEGAPORTCONFIG
}


output "test_instructions_hub" {
  description = "Output Commands"
  value = var.megaport_architecture ? null : join("\n", flatten([
    "########################################################################################",
    "# To generate traffic from the hub (Region) to the spoke (Wavelength), start by logging into the bastion:",
    "eval $(ssh-agent)",
    "ssh-add kp-poc-common.pem",
    "",
    "ssh -i 'kp-poc-common.pem' -A ec2-user@${module.hub-fgt.bastion_fqdn}",
    "",
    "# Once on the bastion, login to the hub client:",
    "ssh ec2-user@${module.hub-fgt.client_private_ip}",
    "",
    "# Once on the hub client, to reach the spoke you can run",
    "ping ${var.sslvpn_tunnel_ip}",
    "",])
  )
}

output "test_instructions_spoke" {
  description = "Output Commands"
  value = join("\n", flatten([
    "########################################################################################",
    "# To generate traffic from the spoke (Wavelength) to the hub (Region), start by logging into the bastion:",
    "eval $(ssh-agent)",
    "ssh-add kp-poc-common.pem",
    "",
    "ssh -i 'kp-poc-common.pem' -A ec2-user@${module.spoke-fgt.bastion_carrier_ip}",
    "",
    "# Once on the bastion, login to the hub client:",
    "ssh ec2-user@${module.spoke-fgt.client_private_ip}",
    "",
    "# Once on the hub client, to reach the spoke you can run",
    "ping 10.1.2.10",
    "",
    "########################################################################################",
    ])
  )
}

