terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "af-south-1"
  access_key = ""
  secret_key = ""
}

# Create vpc module and define init values
module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "ec2" {
  source         = "./ec2"
  my_public_key  = "./my_cloud1_terraform_key.pub"
  instance_type  = "t2.micro"
  security_group = module.vpc.security_group
  subnets        = module.vpc.subnets

}