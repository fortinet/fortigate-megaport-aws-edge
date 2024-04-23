# Resiliency at the Edge with AWS Hybrid & Edge, Fortinet and Megaport

## Introduction

In this repository, learn how to automate the deployment of a highly available architecture across AWS Hybrid & Edge Services. Using AWS Wavelength Zones (WLZ) and the parent AWS Region, we deploy a SSL VPN initiated by the WLZ to create a secure, high-bandwidth east-west traffic flow.

## Terraform Build
After all of this is configured, you are ready to run the terraform modules. To do so, run the following commands from this repository's directory:

```
terraform init -upgrade
terraform plan
terraform apply
```

Once complete, your outputs might resemble the following:
```
Password = "i-01234567890123456"
Username = "admin"
Wavelength-Fortigate-DNS = "ec2-abc-def-efg-hij.compute-1.amazonaws.com"
lz_subnets = "10.0.20.0/24"
vpc_id = "vpc-01234567890123456"
vpc_range = "10.0.0.0/16"
wlz_subnets = "10.0.0.0/24"
```

**Note:** You might encounter the following error, which requires you to opt-in to the Fortigate AWS Marketplace offering. Follow the instructions below to remediate the error.
```
Error: creating EC2 Instance: OptInRequired: In order to use this AWS Marketplace product you need to accept terms and subscribe. To do so please visit https://aws.amazon.com/marketplace/pp?sku=2wqkpek696qhdeo7lbbjncqli
```

## Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/fortigate-megaport-aws-edge/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](LICENSE) © Fortinet Technologies. All rights reserved.