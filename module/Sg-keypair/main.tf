resource "tls_private_key" "key"{
    algorithm = "RSA"
    rsa_bits = 4096
} 

resource "local_file" "key"{
content  = tls_private_key.key.private_key_pem
filename = "keypair.pem"
file_permission = "600"
}

resource "aws_key_pair" "key"{
 key_name = "keypair"
 public_key = tls_private_key.key.public_key_openssh
}

resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "ansible-sg" {
  name        = "ansible-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "k8s-sg" {
  name        = "k8s-sg"
  description = "Allow inbound traffic"
  vpc_id      = var.vpc

  ingress {
    description      = "k8s port"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k8s-sg"
  }
}