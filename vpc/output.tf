output "aws_vpc_id" {
  value = aws_vpc.my_cloud1_vpc.id
}

output "aws_internet_gateway" {
  value = aws_internet_gateway.my_cloud1_igw.id
}

output "security_group" {
  value = aws_security_group.my_cloud1_ecs_sg.id
}

output "public_subnets" {
  value = aws_subnet.my_cloud1_public_subnet.*.id
}

output "subnet1" {
  value = element(aws_subnet.my_cloud1_public_subnet.*.id, 1)
}

output "subnet2" {
  value = element(aws_subnet.my_cloud1_public_subnet.*.id, 2)
}

output "private_subnet1" {
  value = element(aws_subnet.my_cloud1_private_subnet.*.id, 1)
}

output "private_subnet2" {
  value = element(aws_subnet.my_cloud1_private_subnet.*.id, 2)
}