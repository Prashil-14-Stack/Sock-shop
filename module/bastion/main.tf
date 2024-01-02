resource "aws_instance" "bastion" {
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = var.bastionsg
  subnet_id                   = var.subnets
  associate_public_ip_address = true
  user_data                   = templatefile("./module/bastion/bastion.sh",{
    key = var.private-key
  })
  tags = {
    Name = "bastion"
  }
}