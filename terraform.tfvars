/*
Please update the example values here to override the default values in variables.tf.
Any variables in variables.tf can be overridden here.
Overriding variables here keeps the variables.tf as a clean local reference.
*/

# [MODIFICATION REQUIRED] Provide the credentials to access the AWS account
access_key = ""
secret_key = ""

# [MODIFICATION REQUIRED] Provide the credentials to access the Megaport account
megaport_access_key = ""
megaport_secret_key = ""

# Specify the region and AZs to use.
region            = "us-east-1"
availability_zone = "us-east-1a"
wavelength_zone   = "us-east-1-wl1-bna-wlz-1"

# Specify the DX connection ID
connection_id = ""

# [MODIFICATION REQUIRED] Specify the name of the EXISTING keypair created in the prerequisites step in the README.MD. The AWS EC2 instances will use this (ie Spoke FGT, Bastion, and Client instances. Megaport MVE to use it's own.).
keypair = "aws-key-pair"

# Specify the CIDR block which you will be logging into the FGTs from.
cidr_for_access = "0.0.0.0/0"

# Specify a tag prefix that will be used to name resources.
tag_name_prefix = "fortigate-megaport-aws-edge"

# Specify the FortiOS version to use 7.0, 7.2, or 7.4
fortios_version = "7.4"

/* [MODIFICATION REQUIRED]
For license_type, specify byol, flex, or payg.

To use traditional byol license files, place the license files in this root directory (same as this file) and specify the file names.
Otherwise, leave these as empty strings.
fgt1_byol_license = "fgt1-license.lic"
fgt2_byol_license = "fgt2-license.lic"

To use FortiFlex tokens, please provide the token values like so.
Otherwise, leave these as empty strings.
fgt1_fortiflex_token = "1A2B3C4D5E6F7G8H9I0J"
fgt2_fortiflex_token = "2B3C4D5E6F7G8H9I0J1K"
*/
license_type = "payg"

hub_fgt_byol_license   = "hub-fgt-license.lic"
spoke_fgt_byol_license = "spoke-fgt-license.lic"

hub_fgt_fortiflex_token   = ""
spoke_fgt_fortiflex_token = ""
