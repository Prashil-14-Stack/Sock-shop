output "bastionsg" {
    value = aws_security_group.bastion-sg.id
}
output "private-key" {
    value = tls_private_key.key.private_key_pem
}
  

output "key_name" {
    value = aws_key_pair.key.key_name
}

output "k8s-sg" {
    value = aws_security_group.k8s-sg.id
}

output "ansible-sg" {
    value = aws_security_group.ansible-sg.id
}

output "keypair" {
    value = aws_key_pair.key.key_pair_id
  
}