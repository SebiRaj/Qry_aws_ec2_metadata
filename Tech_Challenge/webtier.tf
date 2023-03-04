
#Web - ALB Security Group

resource "aws_security_group" "WEB_Instance_SG_http" {
    name = "alb_security_group"
    description = "Allowing HTTP requests to the application load balancer"
    vpc_id = aws_vpc.threetier_vpc.id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [ "0.0.0.0/0" ]
    } 
    
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
    }
    tags = {
      "Name" = "ALB-Security-Group"
    }
}

#Web - Application Load Balancer
resource "aws_lb" "app_lb" {
    name = "app-lb"
    internal = false
    load_balancer_type= "application"
    security_groups    = [aws_security_group.WEB_Instance_SG_http.id]
    subnets = [for subnet in aws_subnet.Web_Pub_Subnet : subnet.id] 
}

# Web - Target Group
resource "aws_lb_target_group" "WEB_target_group" {
    name     = "web-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = aws_vpc.threetier_vpc.id

    health_check {
        port     = 80
        protocol = "HTTP"
    }
}

# Web - Listener
resource "aws_lb_listener" "WEB_listener" {
    load_balancer_arn = aws_lb.app_lb.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.WEB_target_group.arn
    }
}

# Web - EC2 Instance Security Group
resource "aws_security_group" "WEB_instance_sg" {
    name        = "web-server-security-group"
    description = "Allowing requests to the web servers"
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
        Name = "WEB-server-security-group"
    }
}

# Web - Launch Template
resource "aws_launch_template" "WEB_launch_template" {
    name_prefix   = "web-launch-template"
    image_id      = "ami-0f8ca728008ff5af4"
    instance_type = "t2.micro"
}


# Web - Auto Scaling Group
resource "aws_autoscaling_group" "WEB_asg" {
  desired_capacity   = 0
  max_size           = 0
  min_size           = 0
  target_group_arns = [aws_lb_target_group.WEB_target_group.arn]
  vpc_zone_identifier = [for value in aws_subnet.Web_Pub_Subnet: value.id]

  launch_template {
    id      = aws_launch_template.WEB_launch_template.id
    version = "$Latest"
  }
}

