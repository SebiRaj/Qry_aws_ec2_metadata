
# DB - Security Group
resource "aws_security_group" "DB_security_group" {
  name = "mydb1"

  description = "RDS postgres server"
  vpc_id = aws_vpc.threetier_vpc.id

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.APP_instance_sg.id]
  } 
  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
