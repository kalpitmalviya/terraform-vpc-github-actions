variable "sg_id" {
    description = "SG id for application load balancer"
    type = string


}

variable "subnets" {
    description = "Subnets for application load balancer"
    type = list(string)
  
}

variable "vpc_id" {
    description = "VPC application load balancer"
    type = string
  
}

variable "instances" {
    description = "Instance ID for target group attachment"
    type = list(string)
  
}