#vpc
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    name = "NetSPI_VPC"

  }
}

#Subnet
resource "aws_subnet" "main"{
    vpc_id = aws_vpc.main.id
    cidr_block = var.subnet_cidr
    availability_zone = "ap-south-1a" # Adjust according to your region
  
}

# Internet Gateway
resource "aws_internet_gateway" "IG_main" {
    vpc_id = aws_vpc.main.id
  
}

#Route Table
resource "aws_route_table" "rtmain" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.IG_main
    }
  
}

#Associate route table with subnet
resource "aws_route_table_association" "art_main" {
    subnet_id = aws_vpc.main.id
    route_table_id = aws_route_table.rtmain.id
  
}

#Security Group
resource "aws_security_group" "sg_main" {
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
  
    egress = {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0./0"]
    }
}

#S3 Bucket 

resource "aws_s3_bucket" "S3_main" {
    bucket = "netspi-s3-bucket-${random_id.bucket_id.hex}"
    acl = "private" 
}

resource "random_id" "bucket_id" {
    byte_length = 4
  
}

#EFS 
resource "aws_efs_file_system" "efs_main" {
    tags = {
      Name = "NetSPI_EFS"
    }
  
}
resource "aws_efs_mount_target" "efs_main" {
   file_system_id = aws_efs_file_system.efs_main.id
   subnet_id = aws_subnet.main.id
   security_groups = [aws_security_group.sg_main.id]
}

#Elastic IP
resource "aws_eip" "eip_main" {
    vpc = true

    tags = {
      Project = var.project_tag
    }
  
}

# EC2 Instance
resource "aws_instance" "EC2_main" {
  ami = "ami-0c55b159cbfafe1f0" 
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.main.id
  security_groups = [aws_security_group.sg_main.name]
  associate_public_ip_address = true
  ebs_optimized = true

  tags = {
    Name = "NetSPI_EC2"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y amazon-efs-utils",
      "sudo mkdir -p $(var.efs_mount_point)",
      "sudo mount -t efs $(aws_efs_file_system.main.id):/ ${var.efs_mount_point}",
      "sudo chown ec2-user:ec2-user ${var.efs_mount_point}"
  ]
  connection {
    type = "ssh"
    user = "ec2_user"
    private_key = file("~/.ssh/id_rsa")
    host = aws_instance.EC2_main.public_ip
}
}

ebs_block_device{
    device_name = "/dev/xvda"
    volume_size = 8
    delete_on_termination = true

}
}

#assign EIP to EC2 instance
resource "aws_eip_association" "eip_main" {
    instance_id = aws_instance.EC2_main.id
    allocation_id = aws_eid.EC2_main.id
  
}

