output "aws_vpc_id" {
  value = aws_vpc.my_cloud1_vpc.id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.my_cloud1_igw.id
}