
#VPC Resource
resource "aws_vpc" "threetier_vpc" {
cidr_block = var.vpc_cidr_block

    tags = {
        Name="3tier_vpc"
    }
}

#Internet gateway
resource "aws_internet_gateway" "threetier_igw" {
    vpc_id = aws_vpc.threetier_vpc.id

    tags = {
      "Name" = "threetier_igw"
    }
}

#Subnets
resource "aws_subnet" "Web_Pub_Subnet" {
    for_each = var.WEB_Public_Subnet

    vpc_id = aws_vpc.threetier_vpc.id
    availability_zone = each.key
    cidr_block = each.value
    
    tags = {
      "Name" = "WEB_Pub_Subnet-${each.key}"
    }
}

resource "aws_subnet" "App_Priv_Subnet" {
    for_each = var.APP_Private_Subnet

    vpc_id = aws_vpc.threetier_vpc.id
    availability_zone = each.key
    cidr_block = each.value
    
    tags = {
      "Name" = "APP_Priv_Subnet-${each.key}"
    }    
}

resource "aws_subnet" "DB_Priv_Subnet" {
    for_each = var.DB_Private_Subnet

    vpc_id = aws_vpc.threetier_vpc.id
    availability_zone = each.key
    cidr_block = each.value
    
    tags = {
      "Name" = "DB_Priv_Subnet-${each.key}"
    }
}

#Route Tables

resource "aws_route_table" "Web_Pub_Subnet_Routetable" {
     vpc_id = aws_vpc.threetier_vpc.id

     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.threetier_igw.id
     }
    tags = {
      "Name" = "Web_Pub_subnet_routetables"
    }
}

#WEB Public subnet route table association

resource "aws_route_table_association" "Web_Pub_Subnet_RT_Assoc" {
    for_each = var.WEB_Public_Subnet

    subnet_id = aws_subnet.Web_Pub_Subnet[each.key].id
    route_table_id = aws_route_table.Web_Pub_Subnet_Routetable.id  
    }



