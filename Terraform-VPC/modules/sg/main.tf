resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  description       = "HTTP from anywhere"
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0" # Corrected CIDR block for all IPv4 addresses
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  description       = "SSH from anywhere"
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0" # Corrected CIDR block for all IPv4 addresses
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  description       = "Allow all outbound IPv4 traffic"
  security_group_id = aws_security_group.sg.id # Corrected reference to the created security group
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports and protocols
}

/*

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  description       = "SSH from anywhere via IPv6"
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = "::/0" // Correct CIDR for all IPv6 addresses
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv6" {
  description       = "HTTP from anywhere via IPv6"
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = "::/0" // Correct CIDR for all IPv6 addresses
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv6" {
  description       = "Allow all outbound IPv6 traffic"
  security_group_id = aws_security_group.sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
*/