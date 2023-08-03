# creating vpc
resource "aws_vpc" "vpc_prac" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}
#provisioning 4 subnets with different cidr block specifications
#putting each subnet in different availability zones to make resource highl available
resource "aws_subnet" "test-public-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_1
  availability_zone = "eu-west-2a"

  tags = {
    Name = var.pub_name1
  }
}


resource "aws_subnet" "test-public-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_2
  availability_zone = "eu-west-2b"

  tags = {
    Name = var.pub_name2
  }
}

resource "aws_subnet" "test-priv-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_1
  availability_zone = "eu-west-2c"

  tags = {
    Name = var.priv_name1
  }
}

resource "aws_subnet" "test-priv-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_2
  availability_zone = "eu-west-2c"

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
##Creates a PEM (and OpenSSH) formatted private key
resource "tls_private_key" "private-test-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#Generates a local file (on pc) with the given content
resource "local_file" "local-test-key" {
    content  = tls_private_key.private-test-key.private_key_pem
    filename = "test_key"
}

#public key for ssh
resource "aws_key_pair" "test-key" {
  key_name   = "test-key"
  public_key =  tls_private_key.private-test-key.public_key_openssh
}

#creating iam roles for ec2 
resource "aws_iam_role" "test-ec2-role" {
  name = "test-ec2-role"

  # Terraform's "jsonencode" function converts a Terraform expression result to valid JSON syntax.
  #policy of AmazonEC2FullAccess from console
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "ec2:*",
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "autoscaling.amazonaws.com",
                        "ec2scheduled.amazonaws.com",
                        "elasticloadbalancing.amazonaws.com",
                        "spot.amazonaws.com",
                        "spotfleet.amazonaws.com",
                        "transitgateway.amazonaws.com"
                    ]
                }
            }
        }
    ]
})

  tags = {
    tag-key = "test-ec2-role"
  }
}

#provisioning 2 free tier ec2 using ubuntu ami

#putting this ec2 in the private subnet
resource "aws_instance" "test-compute-1" {
  ami           = "ami-0eb260c4d5475b901"        #picked free tier ubuntu id (eligible) from console
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.test-sec-group.id}"]
  key_name = "${aws_key_pair.test-key.id}"
  subnet_id     = "${aws_subnet.test-priv-sub1.id}"
  
   tags = {
    Name = "test-compute-1"
  }
}

#for the public
resource "aws_instance" "test-compute-2" {
  ami           = "ami-0eb260c4d5475b901"            #picked free tier ubuntu id (eligible) from console
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.test-sec-group.id}"]
  key_name = "${aws_key_pair.test-key.id}"
  subnet_id     = "${aws_subnet.test-public-sub1.id}"
  associate_public_ip_address = true


   tags = {
    Name = var.instance-Name
  }
}

