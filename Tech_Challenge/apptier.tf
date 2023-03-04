
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


