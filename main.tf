### By using this file we can able to create VPC with "single subnet range" it menas in only one availability zone & and only one subnet range  ##############
### we can able to connect this ec2 on aws console.

data "aws_ami" "PS-am-block" {
    most_recent = true
    owners = ["amazon"]
   
    filter{
      name = "name"
      values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
      name = "root-device-type"
      values = ["ebs"]
    }
    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}
   


resource "aws_instance" "PS-EC2_block" {
     ami = data.aws_ami.PS-am-block.id
     instance_type = "t2.micro"
     vpc_security_group_ids = [aws_security_group.PS-SG-block.id]
     associate_public_ip_address = true
     subnet_id = aws_subnet.PS-subnet-block.id
     # key_name =

     tags = {
        Name = "PS-OS_BY"
     }
     depends_on = [
        aws_vpc.PS-vpc-block ,
        aws_subnet.PS-subnet-block ,
        aws_security_group.PS-SG-block
    ]
}

resource "aws_vpc" "PS-vpc-block" {
   cidr_block = "10.0.0.0/16"
   tags = {
     Name = "Pratik-Terra-VpC"
   }
}


resource "aws_internet_gateway" "PS-gateway-block" {
   vpc_id = aws_vpc.PS-vpc-block.id
   tags = {
      Name = "Pratik-terra-gateway"
   }
   depends_on = [
      aws_vpc.PS-vpc-block
   ]
}

resource "aws_subnet" "PS-subnet-block" {
   vpc_id = aws_vpc.PS-vpc-block.id
   cidr_block = "10.0.1.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true

   tags = {
      Name = "Pratik-subnet-terra"
   }
   depends_on = [
      aws_vpc.PS-vpc-block
   ]
}

resource "aws_route_table" "PS-route-block" {
   vpc_id = aws_vpc.PS-vpc-block.id
   
   route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.PS-gateway-block.id
   }
   tags = {
      Name = "Pratik-route-table"
   }
   depends_on = [
      aws_vpc.PS-vpc-block
    ]
}


resource  "aws_route_table_association" "PS-route-T-Asso-block" {
   subnet_id = aws_subnet.PS-subnet-block.id
   route_table_id = aws_route_table.PS-route-block.id
   
}


resource "aws_security_group" "PS-SG-block" {
   name = "Pratik-SG"
   description = "ALLow SG for Terra"
   vpc_id = aws_vpc.PS-vpc-block.id
 
   dynamic "ingress" {
      for_each = var.portValue
      iterator = port
      
      content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    depends_on = [
      aws_vpc.PS-vpc-block
    ] 
}


variable "portValue" {
   type = list(number)
   default = [22 , 80 , 443 , 8080]
}


########################################################################################################################
## Extra code for Elastic -IP 

#   resource "aws_eip" "PS-eip-block" {
#      domain = "vpc"
#      #vpc = true
#      tags = {
#         Name = "Pratik-EIP"
#      }
#   }

#    resource "aws_eip_association" "PS-eip-association-block" {
#        instance_id = aws_instance.PS-EC2_block.id
#        allocation_id = aws_eip.PS-eip-block.id
#    }
