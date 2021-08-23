# Creating VPC,name, CIDR and Tags
resource "aws_vpc" "terraform" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "SaltVPC"
  }
}

# Creating Public Subnets in VPC
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-1a"

  tags = {
    Name = "Salt Public A"
  }
}

output "public_subnet_a_output" {
  value = aws_subnet.public_subnet_a.id
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.terraform.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"

  tags = {
    Name = "Salt Public B"
  }
}

output "public_subnet_b_output" {
  value = aws_subnet.public_subnet_b.id
}


# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "salt-gw" {
  vpc_id = aws_vpc.terraform.id

  tags = {
    Name = "SaltIGW"
  }
}

# Creating Route Tables for Internet gateway
resource "aws_route_table" "salt-public" {
  vpc_id = aws_vpc.terraform.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.salt-gw.id
  }

  tags = {
    Name = "salt-route_public"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "salt-public-route-a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.salt-public.id
}

resource "aws_route_table_association" "salt-public-route-b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.salt-public.id
}

#Security Groups
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.terraform.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public security group"
  }
}

