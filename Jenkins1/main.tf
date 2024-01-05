locals {
  name="sock-shop"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "pubsub01" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${local.name}-pubsub01"
  }
}

resource "aws_subnet" "pubsub02" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "${local.name}-pubsub02"
  }
}

resource "aws_subnet" "pubsub03" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1c"
  tags = {
    Name = "${local.name}-pubsub03"
  }
}

resource "aws_subnet" "prisub01" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "${local.name}-prisub01"
  }
}

resource "aws_subnet" "prisub02" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "eu-west-1b"
  tags = {
    Name = "${local.name}-prisub02"
  }
}

resource "aws_subnet" "prisub03" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "eu-west-1c"
  tags = {
    Name = "${local.name}-prisub03"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.name}-gw"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsub01.id

  tags = {
    Name = "${local.name}-NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

#Create a elastic IP
resource "aws_eip" "eip" {
  domain   = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "pri_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id =aws_nat_gateway.nat-gw.id
  }
}

resource "aws_route_table_association" "pub-rt-ass01" {
  subnet_id      = aws_subnet.pubsub01.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub-rt-ass02" {
  subnet_id      = aws_subnet.pubsub02.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pub-rt-ass03" {
  subnet_id      = aws_subnet.pubsub03.id
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_route_table_association" "pri-rt-ass01" {
  subnet_id      = aws_subnet.prisub01.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_route_table_association" "pri-rt-ass02" {
  subnet_id      = aws_subnet.prisub02.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_route_table_association" "pri-rt-ass03" {
  subnet_id      = aws_subnet.prisub03.id
  route_table_id = aws_route_table.pri_rt.id
}

resource "aws_security_group" "jenkins-sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }
  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name}-jenkins"
  }
}

#instance for vault
resource "aws_instance" "jenkins" {
  ami           = "ami-049b0abf844cab8d7"
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  key_name               = aws_key_pair.key.key_name
  associate_public_ip_address = true 
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.id
  subnet_id = aws_subnet.pubsub01.id
  user_data              = local.jenkins-user-data
  tags = {
    Name = "${local.name}-jenkins"
  }
}

resource "tls_private_key" "key"{
    algorithm = "RSA"
    rsa_bits = 4096
} 

resource "local_file" "key"{
content  = tls_private_key.key.private_key_pem
filename = "sock.pem"
file_permission = "600"
}

resource "aws_key_pair" "key"{
 key_name = "sock-key"
 public_key = tls_private_key.key.public_key_openssh
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"
  assume_role_policy = "${file("${path.root}/ec2-assume.json")}"
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile2"
  role = aws_iam_role.ec2_role.name
}