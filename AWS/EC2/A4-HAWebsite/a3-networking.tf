# Internet gateway to reach the internet
resource "aws_internet_gateway" "igw_for_web" {
  vpc_id = aws_vpc.vpc_for_web.id
}

# Route table with a route to the internet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_for_web.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_for_web.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

# Subnets with routes to the internet
resource "aws_subnet" "subnet_for_public" {

  # Use the count meta-parameter to create multiple copies
  count = 2

  vpc_id            = aws_vpc.vpc_for_web.id
  cidr_block        = cidrsubnet(var.network_cidr_block, 2, count.index + 2)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Associate public route table with the public subnets
resource "aws_route_table_association" "rta_subnet_for_public" {
  count          = 2
  subnet_id      = aws_subnet.subnet_for_public.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}
