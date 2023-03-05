
aws_region ="ap-south-1"

vpc_cidr_block ="10.0.0.0/16"

WEB_Public_Subnet = {
    "ap-south-1a" = "10.0.0.0/24"
    "ap-south-1b" = "10.0.1.0/24"
}

APP_Private_Subnet = {
    "ap-south-1a" = "10.0.101.0/24"
    "ap-south-1b" = "10.0.102.0/24"    
}

DB_Private_Subnet = {
    "ap-south-1a" = "10.0.201.0/24"
    "ap-south-1b" = "10.0.202.0/24"    
}

availability_zones = [
    "ap-south-1a",
    "ap-south-1b" 
]

