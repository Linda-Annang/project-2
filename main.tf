# creating vpc
resource "aws_vpc" "vpc_prac" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}
#provisioning 4 subnets with different cidr block specifications
resource "aws_subnet" "test-public-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_1

  tags = {
    Name = var.pub_name1
  }
}


resource "aws_subnet" "test-public-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_2

  tags = {
    Name = var.pub_name2
  }
}

resource "aws_subnet" "test-priv-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_1

  tags = {
    Name = var.priv_name1
  }
}

resource "aws_subnet" "test-priv-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_2

  tags = {
    Name = var.priv_name2
  }
}

#provisioning  2 route table for public and private traffic/commun
resource "aws_route_table" "test-pub-route-table" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = "test-pub-route-table"
  }
}

resource "aws_route_table" "test-priv-route-table" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = "test-priv-route-table"
  }
}

#internet gateway provision
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = "test-igw"
  }
}

# route table association with the subnets, 2 subnets to each route table
resource "aws_route_table_association" "public-rta-a" {
  subnet_id      = aws_subnet.test-public-sub1.id
  route_table_id = aws_route_table.test-pub-route-table.id
}

resource "aws_route_table_association" "public-rta-b" {
  subnet_id      = aws_subnet.test-public-sub2.id
  route_table_id = aws_route_table.test-pub-route-table.id
}

resource "aws_route_table_association" "private-rta-a" {
  subnet_id      = aws_subnet.test-priv-sub1.id
  route_table_id = aws_route_table.test-priv-route-table.id
}

resource "aws_route_table_association" "private-rta-b" {
  subnet_id      = aws_subnet.test-priv-sub2.id
  route_table_id = aws_route_table.test-priv-route-table.id
}

# internet gateway route association to route table
resource "aws_route" "test-igw-association" {
  route_table_id            = aws_route_table.test-pub-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.test-igw.id
}
