output "haproxy1" {
    value = aws_instance.haproxy1.private_ip
  
}

output "haproxy2" {
    value = aws_instance.haproxy2.private_ip
  
}