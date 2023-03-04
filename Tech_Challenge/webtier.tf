
#Web - ALB Security Group

resource "aws_security_group" "WEB_ALB_SG_http" {
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
    security_groups    = [aws_security_group.WEB_ALB_SG_http.id]
    subnets = [for subnet in aws_subnet.Web_Pub_Subnet : subnet.id] 
}


