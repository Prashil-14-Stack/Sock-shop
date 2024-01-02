output "masternode_host" {
  value = aws_instance.masternode.*.private_ip
}
output "masternode-id" {
  value = aws_instance.masternode.*.id
}
