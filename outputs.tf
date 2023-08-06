# to get the id and cidr block of vpc
output "vpc_id" {
    description = "vpc id"
  value = aws_vpc.vpc_prac.id
}

output "vpc_cidr_block" {
    description = "cidr block for vpc"
  value = aws_vpc.vpc_prac.cidr_block
}

output "iam_role_id" {
    description = "iam role for instance- full access"
    value = aws_iam_role.test-ec2-role.id
}

output "elastic_ip_id" {
    description = "elastic ip id"
    value = aws_eip.test-eip.id
}

output "elastic_ip_availability_zone" {
    description = "availability zone of the elastic ip"
    value = aws_subnet.test-priv-sub1.availability_zone
}

output "elastic_ip_address" {
    description = "elastic ip address"
    value = aws_eip.test-eip.public_ip
}

output "NatGateway_id" {
    description = "Nat gateway id"
    value = aws_nat_gateway.test-Nat-gateway.id
}

output "NatGateway_cidr_block" {
    description = "cidr block for Nat gateway to know if it is public or private"
    value = aws_route.test-Nat-association.destination_cidr_block
}

output "private_compute_id" {
    description = "ec2 id with the elastic ip"
    value = aws_instance.test-compute-1.id
}

output "private_compute_name" {
    description = "ec2 name of private subnet"
    value = aws_instance.test-compute-1.tags.*
}

#to get the instance machine image
output "ec2_ami" {
    description = "instance machine image"
    value = aws_instance.test-compute-1.ami
}






