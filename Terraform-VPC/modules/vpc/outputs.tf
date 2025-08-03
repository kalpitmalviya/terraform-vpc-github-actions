# using outputs we can use these values in other files

output "vpc_id" {
    value = aws_vpc.my_vpc.id
  
}

output "subnet_ids" {
  value = aws_subnet.subnets.*.id #list of subnet ids
}