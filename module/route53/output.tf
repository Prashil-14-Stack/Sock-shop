output "aws_certificate" {
    value = aws_acm_certificate.cert-ssl.arn
}