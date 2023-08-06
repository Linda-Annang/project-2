
Project-2

Provisioning infrastructure,using terraform, for Modern Cloud Consultancy Services (MCCS)

Creatng  a VPC in 1 region, eu-west-2 namely Prod-mccs-VPC.

With components as follows:

public subnets: (test-public-sub1, test -public-sub2)
2 private subnets: (test-priv-sub1, test-priv-sub2)
1 public route table: (test-pub-route-table)
1 private route table: ( test-priv-route-table)
 
 #Associating the subnets to their respective route tables
Creating Internet gateway: (test-igw)

#Associate with internet gateway with the public route table.
(test-igw-association)

#provisioning elastic ip address

#Creating NAT gateway.
(test-Nat-gateway)

#Associating with private route table.
(test-Nat-association)



#Creating Security groups with *port 80 and 22 opened for ingress.
( test-sec-group )
#creating key pair and ec2 iam role

#provisioning 2 EC2 server with Ubuntu Free Tier
Putting one in public subnet and one in private subnet
( test-compute-1)
( test-compute-2)


