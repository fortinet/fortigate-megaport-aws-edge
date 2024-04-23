output "fgt_login_info" {
  value = <<FGTLOGIN

  # hub-fgt username: admin
  # hub-fgt initial password: ${module.hub-fgt.fgt_id}
  # hub-fgt login url: https://${module.hub-fgt.eip_public_ip}:${var.fgt_gui_port}

  # spoke-fgt username: admin
  # spoke-fgt initial password: ${module.spoke-fgt.fgt_id}
  # spoke-fgt login url: https://${module.spoke-fgt.eip_public_ip}:${var.fgt_gui_port}

  FGTLOGIN
}

output "test_instructions" {
  description = "Output Commands"
  value = join("\n", flatten([
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
    "",
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
