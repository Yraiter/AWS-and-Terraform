
##################################################################################
# NETWORK
##################################################################################
# Create VPC #
resource "aws_vpc" "whiskey-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "whiskey-vpc"
  }
}
# Create private subnets #
resource "aws_subnet" "whiskey-private" {
  count                   = length(var.private_cidr)
  vpc_id                  = aws_vpc.whiskey-vpc.id
  cidr_block              = element(var.private_cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "private-sub${count.index + 1}"
  }
}
# Create public subnets #
resource "aws_subnet" "whiskey-public" {
  count                   = length(var.public_cidr)
  vpc_id                  = aws_vpc.whiskey-vpc.id
  cidr_block              = element(var.public_cidr, count.index)
  availability_zone       = element(var.availability_zone, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-sub${count.index + 1}"
  }
}
# Create Internet gateway #
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.whiskey-vpc.id
  tags = {
    Name = "internet-gw"
  }
}
# Create EIP for NAT gatways #
resource "aws_eip" "nat-eip" {
  count      = length(var.availability_zone)
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gw]
  tags = {
    Name = "nat-eip${count.index + 1}"
  }
}
# Create NAT gatway for each AZ #
resource "aws_nat_gateway" "nat-gw" {
  count             = length(var.availability_zone)
  connectivity_type = "public"
  allocation_id     = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id         = element(aws_subnet.whiskey-public.*.id, count.index)
  depends_on        = [aws_internet_gateway.internet-gw]
  tags = {
    Name = "nat-gw${count.index + 1}"
  }
}
# Create public Route-Table #
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.whiskey-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }
  tags = {
    Name = "public-rt"
  }
}

# Create private Route-Table for each AZ#
resource "aws_route_table" "private-rt" {
  count  = length(var.availability_zone)
  vpc_id = aws_vpc.whiskey-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat-gw.*.id, count.index)
  }
  tags = {
    Name = "private-rt-${element(var.availability_zone, count.index)}"
  }
}


# create an association between a route table and a subnet or route table and an internet gateway or virtual private gateway
resource "aws_route_table_association" "rta-public" {
  count          = length(var.public_cidr)
  subnet_id      = element(aws_subnet.whiskey-public.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "rta-private" {
  count          = length(var.availability_zone)
  subnet_id      = element(aws_subnet.whiskey-private.*.id, count.index)
  route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}