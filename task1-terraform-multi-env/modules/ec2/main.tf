resource "aws_security_group" "alb_sg" {
name = "${var.env}-alb-sg"
vpc_id = var.vpc_id
  ingress {
    from_port = 80
      to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name = "${var.env}-ec2-sg"
    vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
      security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port = 0
    to_port = 0
      protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "alb" {
name = "${var.env}-alb"
load_balancer_type = "application"
security_groups = [aws_security_group.alb_sg.id]
subnets = [var.public_subnet1_id, var.public_subnet2_id]
}

resource "aws_lb_target_group" "tg" {
  name = "${var.env}-tg"
    port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
}
resource "aws_lb_listener" "http" {
load_balancer_arn = aws_lb.alb.arn
port = 80
protocol = "HTTP"
  default_action {
type = "forward"
target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_launch_template" "lt" {
  name_prefix = "${var.env}-lt"
  image_id = var.ami_id
    instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
EOF
  )
}

resource "aws_autoscaling_group" "asg" {
count = var.env == "prod" ? 1 : 0
desired_capacity = 2
min_size = 2
max_size = 5
target_group_arns = [aws_lb_target_group.tg.arn]
vpc_zone_identifier = [var.private_subnet1_id, var.private_subnet2_id]
  launch_template {
    id = aws_launch_template.lt.id
      version = "$Latest"
  }
}

resource "aws_instance" "dev_instance" {
  count = var.env == "dev" ? 1 : 0
    ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = var.private_subnet1_id
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data = <<EOF
#!/bin/bash
yum update -y
yum install nginx -y
systemctl start nginx
systemctl enable nginx
EOF
}
resource "aws_lb_target_group_attachment" "dev" {
count = var.env == "dev" ? 1 : 0
target_group_arn = aws_lb_target_group.tg.arn
target_id = aws_instance.dev_instance[0].id
port = 80
}
