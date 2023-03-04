
variable "aws_region"  {
    description = "AWS Region" 
}

variable "vpc_cidr_block" {
    description = "Main VPC CIDR Block"
}

variable "WEB_Public_Subnet" {
    type = map(string)
}

variable "APP_Private_Subnet" {
    type = map(string)
}

variable "DB_Private_Subnet" {
    type = map(string)
}

variable "availability_zones" {
    type = list(string)
  
}
