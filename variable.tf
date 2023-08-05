#creating variables in a string
#region and vpc name
variable "region" {
  description = "aws region"
  default     = "eu-west-2"
}

variable "vpc_name" {
  description = "vpc name"
  default     = "Prod-mccs-VPC"
}

#subnet names
variable "pub_name1" {
  description = "public_subnet_1_name"
  default     = "test-public-sub1"
}

variable "pub_name2" {
  description = "public_subnet_2_name"
  default     = "test-public-sub2"
}

variable "priv_name1" {
  description = "private_subnet_1_name"
  default     = "test-priv-sub1"
}

variable "priv_name2" {
  description = "private_subnet_2_name"
  default     = "test-priv-sub2"
}


#cidr_block variables for each subnet
variable "pub_cidr_block_1" {
  description = "public_cidr_block_subnet_1"
  default     = "10.0.1.0/26"
}

variable "pub_cidr_block_2" {
  description = "public_cidr_block_subnet_2"
  default     = "10.0.2.0/26"
}

variable "priv_cidr_block_1" {
  description = "private_cidr_block_subnet_3"
  default     = "10.0.3.0/26"
}

variable "priv_cidr_block_2" {
  description = "private_cidr_block_subnet_4"
  default     = "10.0.4.0/26"
}

#subnets availability zones
variable "az-a" {
  description = "availability zone a"
  default     = "eu-west-2a"
}
variable "az-b" {
  description = "availability zone b"
  default     = "eu-west-2b"
}

variable "az-c" {
  description = "availability zone c"
  default     = "eu-west-2c"
}

#route tables for public and private
variable "pub-rt" {
  description = "public route table"
  default     = "test-pub-route-table"
}

variable "priv-rt" {
  description = "private route table"
  default     = "test-priv-route-table"
}

#internet gateway name
variable "igw" {
  description = "internet gateway for public route"
  default     = "test-igw"
}

#security group name
variable "sg-name" {
  description = "security  group name"
  default     = "test-sec-group"
}

#key pair name and file name
variable "key-pair-name" {
  description = "key_pair_name_and_file_name"
  default     = "test_key"
}

#IAM role
variable "iam-role-name" {
  description = "IAM role name for ec2"
  default     = "test-ec2-role"
}

#instance details variables
variable "ami-spec" {
  description = "amazon machine image type"
  default     = "ami-0eb260c4d5475b901"
}

variable "instance-type" {
  description = "ec2 type or spec"
  default     = "t2.micro"
}

variable "compute-name1" {
  description = "ec2 name"
  default     = "test-compute-1"
}

variable "compute-name2" {
  description = "ec2 name"
  default     = "test-compute-2"
}

variable "eip-name" {
  description = "elastic ip name"
  default     = "test-eip"
}

#nat gateway
variable "nat-gw" {
  description = "nat gateway name"
  default     = "test-Nat-gateway"
}

variable "nat-gw-cidr-block" {
  description = "nat gateway cidr block name"
  default     = "0.0.0.0/0"
}







