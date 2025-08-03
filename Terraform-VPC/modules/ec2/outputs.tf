output "instances" {
    value = aws_instance.my_ec2.*.id
}