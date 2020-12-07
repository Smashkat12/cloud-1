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
resource "aws_vpc" "my_cloud1_vpc" {
  cidr_block       = "${var.vpc_cidr}"
  enable_dns_hostname = true
  enable_dns_support = true

  tags = {
    Name = "my_cloud1_vpc"
  }
}



# Creating Internet Gateway
resource "aws_internet_gateway" "my_cloud1_igw" {
  vpc_id = "${aws_vpc.my_cloud1_vpc.id}"

  tags = {
    Name = "my_cloud1_igw"
  }
}



# Public Route Table
resource "aws_route_table" "my_public_route_table" {
  vpc_id = "${aws_vpc.my_cloud1_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_cloud1_igw.id}"
  }

  tags = {
    Name = "my_public_route_table"
  }
}


# Private Route Table
resource "aws_default_route_table" "my_private_route_table" {
  default_route_table_id = "${aws_vpc.my_cloud1_vpc.default_route_table_id}"

  route {
    nat_gateway_id = "${aws_nat_gateway.my_cloud1_nat_gateway.id}"
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "my_private_route_table"
  }
}


# Public Subnet
resource "aws_subnet" "my_cloud1_public_subnet" {
  count                   = 2
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.my_cloud1_vpc.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "my_cloud1_public_subnet.${count.index + 1}"
  }
}


# Private Subnet
resource "aws_subnet" "my_cloud1_private_subnet" {
  count             = 2
  cidr_block        = "${var.private_cidrs[count.index]}"
  vpc_id            = "${aws_vpc.my_cloud1_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = {
    Name = "my_cloud1_private_subnet.${count.index + 1}"
  }
}


# Associate Public Subnet with Public Route Table

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_route_table.my_public_route_table.id}"
  subnet_id      = "${aws_subnet.my_cloud1_public_subnet.*.id[count.index]}"
  depends_on     = ["aws_route_table.my_public_route_table", "aws_subnet.my_cloud1_public_subnet"]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_default_route_table.my_private_route_table.id}"
  subnet_id      = "${aws_subnet.my_cloud1_private_subnet.*.id[count.index]}"
  depends_on     = ["aws_default_route_table.my_private_route_table", "aws_subnet.my_cloud1_private_subnet"]
}
# Security Group Creation
resource "aws_security_group" "my_cloud1_sg" {
  name   = "my_cloud1_sg"
  vpc_id = "${aws_vpc.my_cloud1_vpc.id}"
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my_cloud1_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}



# Ingress Security Port 80 or 8080

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.my_cloud1_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}



# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.my_cloud1_sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


# Elastic IP for aws nat gateway
resource "aws_eip" "my_cloud1_eip" {
  vpc = true
}

# Nat gateway
resource "aws_nat_gateway" "my-test-nat-gateway" {
  allocation_id = "${aws_eip.my_cloud1_eip.id}"
  subnet_id     = "${aws_subnet.my_cloud1_public_subnet.0.id}"
}

# Adding Route for Transit Gateway
resource "aws_route" "my_tgw_route" {
  route_table_id         = "${aws_route_table.my_public_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = "${var.transit_gateway}"
}