/*provider "aws" {
  region = "ap-south-1" # or the region of your choice
}*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65.0"
    }
  }

  backend "s3" {
    bucket         	   = "NetSPI-tfstate"
    key              	   = "state/terraform.tfstate"
    region         	   = "ap-south-1"                      # or the region of your choice
    encrypt        	   = true
    dynamodb_table = "NetSPI_tf_lockid"
  }
}
