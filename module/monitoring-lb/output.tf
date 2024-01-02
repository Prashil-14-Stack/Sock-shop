
output "prom-zone-id" {
    value = aws_lb.prom-lb.zone_id
}

output "graf-zone-id" {
    value = aws_lb.graf-lb.zone_id
}

output "prom-dns-name" {
    value = aws_lb.prom-lb.dns_name
}

output "graf-dns-name" {
   value = aws_lb.graf-lb.dns_name
}
