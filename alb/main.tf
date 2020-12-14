#load balancer target group
resource "aws_lb_target_group" "my_cloud1_target_group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-cloud1-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

#my load balance
resource "aws_lb" "my_cloud1_aws_alb" {
  name     = "my-cloud1-alb"
  internal = false

  security_groups = [
    "${aws_security_group.my_cloud1_alb_sg.id}"
  ]

  subnets = [
    "${var.subnet1}",
    "${var.subnet2}",
  ]

  tags = {
    Name = "my_cloud1_alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

#attach alb to target group instances
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.my_cloud1_target_group.arn
  target_id        = var.instance1_id
  port             = 80
}
resource "aws_lb_target_group_attachment" "my-alb-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.my_cloud1_target_group.arn
  target_id        = var.instance2_id
  port             = 80
}

#set up listen at port 80 of alb
resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = aws_lb.my_cloud1_aws_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_cloud1_target_group.arn
  }
}


#security group
resource "aws_security_group" "my_cloud1_alb_sg" {
  name   = "my_cloud1_alb_sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
