provider "aws" {
region = "us-east-1"  # change to your preferred region
}

# Create VPC

resource "aws_vpc" "my_vpc" {
cidr_block           = "10.0.0.0/16"
enable_dns_support   = true
enable_dns_hostnames = true

tags = {
Name = "my_vpc"
}
}

# Create Subnet

resource "aws_subnet" "my_subnet" {
vpc_id                  = aws_vpc.my_vpc.id
cidr_block              = "10.0.1.0/24"
map_public_ip_on_launch = true

tags = {
Name = "my_subnet"
}
}

# Create Internet Gateway

resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.my_vpc.id

tags = {
Name = "my_igw"
}
}

# Create Route Table

resource "aws_route_table" "rt" {
vpc_id = aws_vpc.my_vpc.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.igw.id
}

tags = {
Name = "my_route_table"
}
}

# Associate Route Table with Subnet

resource "aws_route_table_association" "rta" {
subnet_id      = aws_subnet.my_subnet.id
route_table_id = aws_route_table.rt.id
}

# Security Group

resource "aws_security_group" "sg" {
name        = "ec2_sg"
description = "Allow SSH and all internal traffic"
vpc_id      = aws_vpc.my_vpc.id

ingress {
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port       = 0
to_port         = 0
protocol        = "-1"
cidr_blocks     = ["10.0.0.0/16"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "ec2_sg"
}
}

# Key Pair (replace with your public key)

data "aws_key_pair" "my_key" {
key_name   = "abokhaled"
# public_key = file("abokhaled.pub") # replace with your public key
}

# EC2 Instances

resource "aws_instance" "master" {
ami                    = "ami-0ecb62995f68bb549"  # Amazon Linux 2, change if needed
instance_type          = "t2.micro"
subnet_id              = aws_subnet.my_subnet.id
vpc_security_group_ids = [aws_security_group.sg.id]
key_name               = data.aws_key_pair.my_key.key_name

tags = {
Name = "master"
}
}

resource "aws_instance" "worker" {
ami                    = "ami-0ecb62995f68bb549"
instance_type          = "t2.micro"
subnet_id              = aws_subnet.my_subnet.id
vpc_security_group_ids = [aws_security_group.sg.id]
key_name               = data.aws_key_pair.my_key.key_name

tags = {
Name = "worker"
}
}
