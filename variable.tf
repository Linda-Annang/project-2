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
