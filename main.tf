# creating vpc
resource "aws_vpc" "vpc_prac" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
}
#provisioning 4 subnets with different cidr block specifications
#putting each subnet in different availability zones to make resource highly available
resource "aws_subnet" "test-public-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_1
  availability_zone = var.az-a

  tags = {
    Name = var.pub_name1
  }
}


resource "aws_subnet" "test-public-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.pub_cidr_block_2
  availability_zone = var.az-b

  tags = {
    Name = var.pub_name2
  }
}

resource "aws_subnet" "test-priv-sub1" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_1
  availability_zone = var.az-c

  tags = {
    Name = var.priv_name1
  }
}

resource "aws_subnet" "test-priv-sub2" {
  vpc_id     = aws_vpc.vpc_prac.id
  cidr_block = var.priv_cidr_block_2
  availability_zone = var.az-c

  tags = {
    Name = var.priv_name2
  }
}

#provisioning  2 route table for public and private traffic/commun
resource "aws_route_table" "test-pub-route-table" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = var.pub-rt
  }
}

resource "aws_route_table" "test-priv-route-table" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = var.priv-rt
  }
}

#internet gateway provision
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.vpc_prac.id

  tags = {
    Name = var.igw
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
  name = var.sg-name
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
    Name = var.sg-name
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
    filename = var.key-pair-name
}

#public key for ssh
resource "aws_key_pair" "test-key" {
  key_name   = var.key-pair-name
  public_key =  tls_private_key.private-test-key.public_key_openssh
}

#creating iam roles for ec2 
resource "aws_iam_role" "test-ec2-role" {
  name = var.iam-role-name

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

  
}

#attaching iam role to instance profile
resource "aws_iam_instance_profile" "test-profile" {
  name = "test-profile"
  role = aws_iam_role.test-ec2-role.id
}
#provisioning 2 free tier ec2 using ubuntu ami

#putting this ec2 in the private subnet
resource "aws_instance" "test-compute-1" {
  #picked free tier ubuntu id (eligible) from console --Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ami           = var.ami-spec     
  instance_type = var.instance-type
  vpc_security_group_ids = ["${aws_security_group.test-sec-group.id}"]
  key_name               = "${aws_key_pair.test-key.id}"
  subnet_id              = "${aws_subnet.test-priv-sub1.id}"
  iam_instance_profile   = aws_iam_instance_profile.test-profile.id
  
   tags = {
    Name = var.compute-name1
  }
}

#for the public
resource "aws_instance" "test-compute-2" {
  #picked free tier ubuntu id (eligible) from console--Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
  ami           = var.ami-spec 
  instance_type = var.instance-type
  vpc_security_group_ids = ["${aws_security_group.test-sec-group.id}"]
  key_name               = "${aws_key_pair.test-key.id}"
  subnet_id              = "${aws_subnet.test-public-sub1.id}"
  iam_instance_profile   = aws_iam_instance_profile.test-profile.id
  associate_public_ip_address = true


   tags = {
    Name = var.compute-name2
  }
}

#provisioning elastic ip to associate with the nat gateway
resource "aws_eip" "test-eip" {
  instance = aws_instance.test-compute-1.id
  vpc      = true
  tags = {
    Name = var.eip-name
  }
}

#provisioning nat gateway
resource "aws_nat_gateway" "test-Nat-gateway" {
  allocation_id = aws_eip.test-eip.id
  subnet_id     = aws_subnet.test-priv-sub1.id

  tags = {
    Name = var.nat-gw
  }
}


#associating  the Nat gateway with the private route table
resource "aws_route" "test-Nat-association" {
  route_table_id            = aws_route_table.test-priv-route-table.id
  destination_cidr_block    = var.nat-gw-cidr-block        #public Nat gateway
  gateway_id                = aws_nat_gateway.test-Nat-gateway.id
}

