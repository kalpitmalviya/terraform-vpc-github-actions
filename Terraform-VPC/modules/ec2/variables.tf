variable "sg_id" {
    description = "Security Group ID"
    type = string
}

variable "subnets" {
    description = "Subnets for Ec2"
    type = list(string)  
}

variable "ec2_names" {
    description = "EC2 names"
    type = list(string)
    default = ["ec2-1", "ec2-2"]
  
}