variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
default = "t2.micro"  
}

variable "key_name" {
    description = "SSH Key name"
    type = string
  
}

variable "efs_mount_point" {
default = "/data/test"

}
variable "project_tag" {
    default = "NetSPI_EIP"
  
}
