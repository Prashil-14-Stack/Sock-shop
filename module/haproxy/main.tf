resource "aws_instance" "haproxy1" {
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.haproxysg]
  subnet_id                   = var.subnet1
  associate_public_ip_address = true
  user_data                   = templatefile("./module/haproxy/haproxy1.sh",{
    master1 = var.master1
    master2 = var.master2
    master3 = var.master3
  })
  tags = {
    Name = "haproxy1"
  }
}


resource "aws_instance" "haproxy2" {
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.haproxysg]
  subnet_id                   = var.subnet2
  associate_public_ip_address = true
  user_data                   = templatefile("./module/haproxy/haproxy2.sh",{
    master1 = var.master1
    master2 = var.master2
    master3 = var.master3
  })
  tags = {
    Name = "haproxy2"
  }
}