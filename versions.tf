terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60"
    }
    megaport = {
      source  = "megaport/megaport"
      version = ">=1.0.1"
    }
  }
}


