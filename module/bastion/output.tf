output "bastion_host" {
    value = aws_instance.bastion.public_ip
  
}

output "bastion_host_pri" {
    value = aws_instance.bastion.private_ip
  
}