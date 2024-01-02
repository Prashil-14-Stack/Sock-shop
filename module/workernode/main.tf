resource "aws_instance" "workernode" {
  count                       = var.instancecount
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = var.k8s-sg
  subnet_id                   = element(var.subnet_ids, count.index)
  associate_public_ip_address = true
  tags = {
    Name = "workernode"
  }
}