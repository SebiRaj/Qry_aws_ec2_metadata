
# App - ALB Security Group
resource "aws_security_group" "ALB_app_http" {
  name        = "alb-app-security-group"
  description = "Allowing HTTP requests to the app tier application load balancer"
  vpc_id = aws_vpc.threetier_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.WEB_Instance_SG_http.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-app-security-group"
  }
}


# App - Application Load Balancer
resource "aws_lb" "APP_app_lb" {
  name = "app-app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.ALB_app_http.id]
  subnets = [for value in aws_subnet.App_Priv_Subnet: value.id]
}

# App - Target Group
resource "aws_lb_target_group" "APP_target_group" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.threetier_vpc.id

  health_check {
    port     = 80
    protocol = "HTTP"
  }
}

# App - Listener
resource "aws_lb_listener" "APP_listener" {
  load_balancer_arn = aws_lb.APP_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.APP_target_group.arn
  }
}


# App - EC2 Instance Security Group
resource "aws_security_group" "APP_instance_sg" {
  name        = "app-server-security-group"
  description = "Allowing requests to the app servers"
  vpc_id = aws_vpc.threetier_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.ALB_app_http.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-server-security-group"
  }
}

# App - Launch Template
resource "aws_launch_template" "APP_launch_template" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-0f8ca728008ff5af4"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.APP_instance_sg.id]
}

# App - Auto Scaling Group
resource "aws_autoscaling_group" "APP_asg" {
  desired_capacity   = 0
  max_size           = 0
  min_size           = 0
  target_group_arns = [aws_lb_target_group.APP_target_group.arn]
  vpc_zone_identifier = [for value in aws_subnet.App_Priv_Subnet: value.id]

  launch_template {
    id      = aws_launch_template.APP_launch_template.id
    version = "$Latest"
  }
}
