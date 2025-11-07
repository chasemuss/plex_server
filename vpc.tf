# File: vpc.tf
# Purpose: Create minimal VPC with public subnet for simplicity and low cost.
#          Plex requires inbound access for remote clients (ports 32400, etc.).
#          Single AZ to minimize cost.

resource "aws_vpc" "plex_vpc" {
  cidr_block           = "10.0.0.0/24"  # Small CIDR to reduce cost
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.global_tags, {
    Name = "plex-vpc"
  })
}

resource "aws_subnet" "plex_public_subnet" {
  vpc_id                  = aws_vpc.plex_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"  # Low-cost AZ

  tags = merge(var.global_tags, {
    Name = "plex-public-subnet"
  })
}

resource "aws_internet_gateway" "plex_igw" {
  vpc_id = aws_vpc.plex_vpc.id

  tags = merge(var.global_tags, {
    Name = "plex-igw"
  })
}

resource "aws_route_table" "plex_public_rt" {
  vpc_id = aws_vpc.plex_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.plex_igw.id
  }

  tags = merge(var.global_tags, {
    Name = "plex-public-rt"
  })
}

resource "aws_route_table_association" "plex_public_rta" {
  subnet_id      = aws_subnet.plex_public_subnet.id
  route_table_id = aws_route_table.plex_public_rt.id
} 