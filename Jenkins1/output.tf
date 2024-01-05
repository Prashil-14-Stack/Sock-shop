output "vpc" {
    value = aws_vpc.vpc.id
}

output "pubsub01" {
    value = aws_subnet.pubsub01.id
}

output "pubsub02" {
    value = aws_subnet.pubsub02.id
}

output "pubsub03" {
    value = aws_subnet.pubsub03.id
}

output "prisub01" {
    value = aws_subnet.prisub01.id
}

output "prisub02" {
    value = aws_subnet.prisub02.id
}

output "prisub03" {
    value = aws_subnet.prisub03.id
}

output "jenkins_host" {
    value = aws_instance.jenkins.public_ip
}