# VPC
# Defines a Virtual Private Cloud (VPC) with a specified CIDR block.
resource "aws_vpc" "my_vpc" {
    # The IP address range for the VPC. This is a required argument.
    cidr_block = var.vpc_cidr
    # Specifies if EC2 instances are launched on shared or dedicated tenancy. "default" means shared.
    instance_tenancy = "default"

    # A map of tags to assign to the VPC. Tags are key-value pairs that help with organization and management.
    tags = {
        "Name" = "my_vpc"
    }
}

# 2 Subnets
# Creates multiple subnets within the VPC. The 'count' meta-argument is used to create a specified number of identical resources.
resource "aws_subnet" "subnets" {
    # 'count' creates resources for each element in the 'subnet_cidr' list.
    count = length(var.subnet_cidr)
    # The ID of the VPC in which to create the subnet. It references the VPC created above.
    vpc_id = aws_vpc.my_vpc.id
    # The IP address range for the subnet. `count.index` refers to the current iteration of the loop.
    cidr_block = var.subnet_cidr[count.index]
    # The availability zone for the subnet. This fetches the list of available zones and assigns one per subnet.
    availability_zone = data.aws_availability_zones.available.names[count.index] 
    # Specifies whether to automatically assign a public IPv4 address to instances launched in this subnet. Setting it to true makes it a public subnet.
    map_public_ip_on_launch = true 

    tags = {
      # Assigns a unique name to each subnet based on the 'subnet_names' list.
      Name = var.subnet_names[count.index]
    }
}

# Internet Gateway
# Creates an Internet Gateway, which allows communication between the VPC and the internet.
resource "aws_internet_gateway" "igw" {
    # The ID of the VPC to attach the Internet Gateway to.
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        "Name" = "my-igw"
    }
}

# Route Table
# Creates a Route Table for the VPC.
resource "aws_route_table" "rt" {
    # The ID of the VPC in which to create the route table.
    vpc_id = aws_vpc.my_vpc.id

    # A route within the route table.
    route {
        # The destination CIDR block. "0.0.0.0/0" means all outbound traffic.
        cidr_block = "0.0.0.0/0" 
        # The ID of the Internet Gateway to which the traffic should be routed.
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
      Name = "my-routingTable"
    }
  
}

# Route table association
# Associates the route table with the subnets, directing traffic out through the Internet Gateway.
resource "aws_route_table_association" "rta" {
    # 'count' creates an association for each of the subnets.
    count = length(var.subnet_cidr)
    # The ID of the subnet to associate with the route table.
    subnet_id = aws_subnet.subnets[count.index].id
    # The ID of the route table to be associated.
    route_table_id = aws_route_table.rt.id 
}