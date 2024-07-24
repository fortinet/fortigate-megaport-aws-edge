resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-vpc"
  }
}
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-igw"
  }
}


# DX Setup 
resource "aws_vpn_gateway" "vpn_gw" {
  count = var.tag_name_unique=="hub" ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  amazon_side_asn = 64513
  tags = {
    Name = "demo-vgw"
  }
}


# Create Carrier Gateway
resource "aws_ec2_carrier_gateway" "cgw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "tf-carrier-gw"
  }
}


resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = var.tag_name_unique=="hub" ? var.availability_zone : var.wavelength_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = var.tag_name_unique=="hub" ? var.availability_zone : var.wavelength_zone
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-subnet"
  }
}

resource "aws_route_table" "public_rt_region" {
  count = var.tag_name_unique=="hub" ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
	  gateway_id = aws_internet_gateway.igw.id 
  }
  # propagating_vgws = aws_vpn_gateway.vpn_gw
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rt"
  }
}

resource "aws_route_table" "public_rt_wlz" {
  count = var.tag_name_unique=="hub" ? 0 : 1
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
	carrier_gateway_id = aws_ec2_carrier_gateway.cgw.id 
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
	network_interface_id = var.fgt_eni1_id
  }
  tags = {
    Name = "${var.tag_name_prefix}-${var.tag_name_unique}-private-rt"
  }
}

locals {
  selected_route_table_id = var.tag_name_unique=="hub" ? aws_route_table.public_rt_region[0].id : aws_route_table.public_rt_wlz[0].id
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id = aws_subnet.public_subnet.id  
  route_table_id = local.selected_route_table_id
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Create VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  count           = 1
  iam_role_arn    = aws_iam_role.flow_log_example_role.arn
  log_destination = aws_cloudwatch_log_group.cw_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id
}
resource "aws_cloudwatch_log_group" "cw_log_group" {
  name              = "cw_log_group-${aws_vpc.vpc.id}"
  kms_key_id        = aws_kms_key.cloudwatch.arn
  retention_in_days = 400
}
resource "aws_kms_key" "cloudwatch" {
  description             = "KMS key for Amazon CloudWatch"
  deletion_window_in_days = 7
  enable_key_rotation     = "true"
  policy                  = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_iam_role" "flow_log_example_role" {
  name               = "vpc_flow_log_example_role-${aws_vpc.vpc.id}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_log_example_policy" {
  name = "flow_log_example_policy-${aws_vpc.vpc.id}"
  role = aws_iam_role.flow_log_example_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "EC2VPCFlowLogs" {
  name = "EC2VPCFlowLogsPolicy"
  role = "${aws_iam_role.worker_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ],
        "Resource": [
            "arn:aws:logs:*:*:*"
        ]
    }]
}
EOF
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_policy_document" "cloudwatch" {
  policy_id = "key-policy-cloudwatch"
  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        format(
          "arn:%s:iam::%s:root",
          data.aws_partition.current.partition,
          data.aws_caller_identity.current.account_id
        )
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
      "kms:CreateKey*",
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        format(
          "logs.${var.region}.amazonaws.com",
        )
      ]
    }
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
    resources = ["*"]
  }
}

resource "aws_iam_role" "worker_role" {
  name = "ec2-iam-profile-${aws_vpc.vpc.id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}