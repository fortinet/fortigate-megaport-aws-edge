output "mve-private-key" {
  value     = module.megaport.mve_private_key
  sensitive = true
}

output "mve-fortigate-ip" {
  value = var.megaport_architecture ? module.megaport.vxc_info : null
}

output "spoke-fortigate-ip" {
  value = module.spoke-fgt.eip_public_ip
}

output "test_instructions_hub" {
  description = "Output Commands"
  value = <<HUBCONFIG
    ########################################################################################
    To generate traffic from the Hub (Region) to the Spoke (Wavelength), start by logging into the Region-based bastion:
    eval $(ssh-agent)
    ssh-add aws-key-pair.pem
    ssh -i 'aws-key-pair.pem' -A ec2-user@${module.hub-fgt.bastion_fqdn}
    
    Once on the bastion, login to the hub client:
    ssh ubuntu@${module.hub-fgt.client_private_ip}
    
    Once on the hub client, to reach the spoke you can run:
    ping ${var.sslvpn_tunnel_ip}
    ########################################################################################
  HUBCONFIG
}

output "test_instructions_spoke" {
  description = "Output Commands"
  value = <<SPOKECONFIG
    ########################################################################################
    To generate traffic from the Spoke (Wavelength) to the Hub (Region), start by logging into the bastion in the Wavelength Zone:",
    eval $(ssh-agent)
    ssh-add aws-key-pair.pem
    ssh -i 'aws-key-pair.pem' -A ec2-user@${module.spoke-fgt.bastion_carrier_ip}
    
    Once on the bastion, login to the Wavelength Zone client:
    ssh ubuntu@${module.spoke-fgt.client_private_ip}
    
    Once on the Wavelength Zone client, to reach the Region-based client, you need the IP addres:
    HUB_CLIENT=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=fortigate-megaport-aws-edge-client-region"  --query "Reservations[*].Instances[*].PrivateIpAddress" --output text) && echo $HUB_CLIENT
    ping $HUB_CLIENT
    ########################################################################################
  SPOKECONFIG
}
