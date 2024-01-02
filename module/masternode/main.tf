resource "aws_instance" "masternode" {
  count                       = var.instancecount
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = var.ms-sg
  subnet_id                   = element(var.subnet_id, count.index)
  associate_public_ip_address = true
  tags = {
    Name = "masternode"
  }
}