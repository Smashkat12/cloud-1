terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "af-south-1"
  access_key = ""
  secret_key = ""
}

# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}


# VPC Creation
# Creating Internet Gateway
# Public Route Table
# Private Route Table
# Public Subnet
# Private Subnet
# Associate Public Subnet with Public Route Table
# Associate Private Subnet with Private Route Table
# Security Group Creation
# Ingress Security Port 22
# Ingress Security Port 80 or 8080
# Egress Security All OutBound Access
# Adding Route for Transit Gateway