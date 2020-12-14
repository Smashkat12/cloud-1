output "instance1_id" {
  value = element(aws_instance.my_wordpress_instance.*.id, 1)
}


output "instance2_id" {
  value = element(aws_instance.my_wordpress_instance.*.id, 2)
}


output "server_ip" {
  value = join(",", aws_instance.my_wordpress_instance.*.public_ip)
}


output "instance_id" {
  value = aws_instance.my_wordpress_instance.*.id
}
