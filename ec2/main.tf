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

# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}

#data "aws_ami" "debian_wordpress" {
#  owners      = ["939706979954"]
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["bitnami-wordpress-5.5.2-0-linux-debian-10-x86_64-hvm-ebs*"]
#  }
#
#  filter {
#    name   = "root-device-type"
#    values = ["ebs"]
#  }
#
#
#}

resource "aws_key_pair" "my_cloud1_key" {
  key_name   = "my_cloud1_terraform_key"
  public_key = file(var.my_public_key)
}

data "template_file" "init" {
  template = file("${path.module}/userdata.tpl")
}

resource "aws_instance" "my_wordpress_instance" {
  count                  = 2
  ami                    = "ami-054280160191ad136"
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_cloud1_key.id
  vpc_security_group_ids = [var.security_group]
  subnet_id              = element(var.subnets, count.index)
  user_data              = data.template_file.init.rendered

  tags = {
    Name = "my_wordpress_instance-${count.index + 1}"
  }
}


resource "aws_ebs_volume" "my_wordpress_ebs" {
  count             = 2
  availability_zone = data.aws_availability_zones.available.names[count.index]
  size              = 1
  type              = "gp2"
}


resource "aws_volume_attachment" "my-vol-attach" {
  count        = 2
  device_name  = "/dev/xvdh"
  instance_id  = aws_instance.my_wordpress_instance.*.id[count.index]
  volume_id    = aws_ebs_volume.my_wordpress_ebs.*.id[count.index]
  force_detach = true
}



