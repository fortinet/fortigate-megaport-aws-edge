provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "random_password" "spoke-fgt" {
  length           = 16
  special          = true
  override_special = "!@#$%^&*()"
}

resource "aws_iam_role" "iam-role" {
  name = "${var.tag_name_prefix}-hub-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
    name = "${var.tag_name_prefix}-hub-iam-instance-profile"
    role = "${var.tag_name_prefix}-hub-iam-role"
}

resource "aws_iam_role_policy" "iam-role-policy" {
  name = "${var.tag_name_prefix}-iam-role-policy"
  role = aws_iam_role.iam-role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SDNConnectorFortiView",
	  "Effect": "Allow",
      "Action": [
		"ec2:DescribeInstances",
		"ec2:DescribeNetworkInterfaces",
		"ec2:DescribeRegions",
		"ec2:DescribeVpcEndpoints",
		"eks:DescribeCluster",
		"eks:ListClusters",
		"inspector:DescribeFindings",
		"inspector:ListFindings"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

variable "fgtami" {
  type = map(any)
  default = {
    "7.0" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.0.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.0.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.0.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.0.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.0.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.0.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.2" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.2.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.2.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex" = "FortiGate-VM64-AWS *(7.2.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.2.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    },
    "7.4" = {
      "arm" = {
        "byol" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
		"flex" = "FortiGate-VMARM64-AWS *(7.4.*)*|33ndn84xbrajb9vmu5lxnfpjq"
        "payg" = "FortiGate-VMARM64-AWSONDEMAND *(7.4.*)*|8gc40z1w65qjt61p9ps88057n"
      },
      "intel" = {
        "byol" = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
		"flex"  = "FortiGate-VM64-AWS *(7.4.*)*|dlaioq277sglm5mw1y1dmeuqa"
        "payg" = "FortiGate-VM64-AWSONDEMAND *(7.4.*)*|2wqkpek696qhdeo7lbbjncqli"
      }
    }
  }
}

locals {
  instance_family = split(".", "${var.instance_type}")[0]
  graviton = (local.instance_family == "c6g") || (local.instance_family == "c6gn") || (local.instance_family == "c7g") || (local.instance_family == "c7gn") ? true : false
  arch = local.graviton == true ? "arm" : "intel"
  ami_search_string = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[0]
  product_code = split("|", "${var.fgtami[var.fortios_version][local.arch][var.license_type]}")[1]
}

data "aws_ami" "fortigate_ami" {
  most_recent      = true
  owners           = ["aws-marketplace"]

  filter {
    name   = "name"
    values = [local.ami_search_string]
  }
  filter {
    name   = "product-code"
    values = [local.product_code]
  }
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

output "my_public_ip" {
  value = "${data.external.myipaddr.result.ip}"
}


resource "aws_security_group_rule" "allow_vpn" {
  type              = "ingress"
  from_port         = 10443
  to_port           = 10443
  protocol          = "tcp"
  cidr_blocks       = ["${var.carrier_ip}/32"]
  security_group_id = aws_security_group.secgrp.id
}

resource "aws_security_group" "secgrp" {
  name = "${var.tag_name_prefix}-secgrp"
  description = "secgrp"
  vpc_id = var.vpc_id
  ingress {
    description = "Allow web server traffic"
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    cidr_blocks = ["${data.external.myipaddr.result.ip}/32"]
  }
  ingress {
    description = "Allow local VPC access to FGT"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow ICMP traffic"
  }
  egress {
    description = "Allow egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-fgt-secgrp"
  }
}

resource "aws_network_interface" "fgt_eni0" {
  subnet_id = var.public_subnet_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt_public_ip)}", 0)}" ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt-eni0"
  }
}

resource "aws_network_interface" "fgt_eni1" {
  subnet_id = var.private_subnet_id
  security_groups = [ aws_security_group.secgrp.id ]
  private_ips = [ "${element("${split("/", var.fgt_private_ip)}", 0)}", ]
  source_dest_check = false
  tags = {
    Name = "${var.tag_name_prefix}-fgt-eni1"
  }
}

resource "aws_eip" "eip" {
  domain = "vpc"
  network_interface = aws_network_interface.fgt_eni0.id
  associate_with_private_ip = element("${split("/", var.fgt_public_ip)}", 0)
  tags = {
    Name =  "${var.tag_name_prefix}-fgt-eip"
  }
}

resource "aws_instance" "fgt" {
  ami = data.aws_ami.fortigate_ami.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  key_name = var.keypair
  iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.id
  ebs_optimized = true
  monitoring = true
  user_data = templatefile("${path.module}/fgt-userdata.tpl", {
    ca_cert        = var.ca_cert
    fgt_key        = var.fgt_key
    fgt_cert       = var.fgt_cert
    gui_port       = var.fgt_gui_port
    sv_user        = var.sslvpn_username
    sv_passwd      = random_password.spoke-fgt.result
    sv_tunnel_ip   = var.sslvpn_tunnel_ip
    sv_port        = var.sslvpn_port
    vpc_cidr       = var.vpc_cidr
    license_type   = var.license_type
    license_file   = "${path.root}/${var.fgt_byol_license}"
    license_token  = var.fgt_fortiflex_token
  })
  root_block_device {
    volume_type = "gp2"
    encrypted = true
    volume_size = "2"
  }
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "30"
    volume_type = "gp2"
    encrypted = true
  }
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.fgt_eni0.id
  }
  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.fgt_eni1.id
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  tags = {
	Name = "${var.tag_name_prefix}-hub-fgt"
  }
}

# Test Instance
data "aws_ssm_parameter" "linux-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "test_instance" {
  tags = {
    Name = "fortigate-megaport-aws-edge-client-region"
  }
  ami      = data.aws_ssm_parameter.linux-ami.value
  instance_type = "t3.medium"
  key_name      = var.keypair
  security_groups = [aws_security_group.secgrp.id]
  subnet_id = var.private_subnet_id
  iam_instance_profile = "Edge-EC2-Instance-Profile"
  root_block_device {
    volume_size = "20"
    encrypted   = true
    volume_type = "gp2"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring = true
}

##############################################

resource "aws_instance" "bastion" {
  tags = {
    Name = "fortigate-megaport-aws-edge-bastion-region"
  }
  ami      = data.aws_ssm_parameter.linux-ami.value
  instance_type = "t3.medium"
  key_name      = var.keypair
  security_groups = [aws_security_group.bastion-secgrp.id]
  subnet_id = var.public_subnet_id
  iam_instance_profile = "Edge-EC2-Instance-Profile"
  root_block_device {
    volume_size = "20"
    encrypted   = true
    volume_type = "gp2"
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }
  monitoring = true
}
resource "aws_eip" "eip_bastion" {
  instance = aws_instance.bastion.id
  tags = {
    Name =  "bastion-region-eip"
  }
}
resource "aws_security_group" "bastion-secgrp" {
  name = "${var.tag_name_prefix}-bastion-secgrp"
  description = "bastion-sg"
  vpc_id = var.vpc_id
  ingress {
    description = "Allow SSH traffic"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.external.myipaddr.result.ip}/32"]
  }
  egress {
    description = "Allow egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.tag_name_prefix}-bastion-secgrp"
  }
}
resource "aws_security_group_rule" "allow_bastion" {
  type              = "ingress"
  to_port           = 22
  protocol          = "tcp"
  from_port         = 22
  security_group_id = aws_security_group.secgrp.id
  source_security_group_id = aws_security_group.bastion-secgrp.id
}
