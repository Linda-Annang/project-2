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

#creating security group with port 80 (http) and 22(ssh)

resource "aws_security_group" "test-sec-group" {
  name = "test-sec-group"
  description = "Allow HTTP and SSH traffic"
  vpc_id      = "${aws_vpc.vpc_prac.id}"

#inbound traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

 tags = {
    Name = "test-sec-group"
  } 
}


#creating key pair
#private key
resource "tls_private_key" "private-test-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "local-test-key" {
    content  = tls_private_key.test-private-key.private_key_pem
    filename = "test_key"
}

#public key for ssh
resource "aws_key_pair" "test-key" {
  key_name   = var.pub-key-Name
  public_key =  tls_private_key.test-private-key.public_key_openssh
}

