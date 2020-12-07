variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type = "list"
}

variable "private_cidrs" {
  type = "list"
}

variable "transit_gateway" {}