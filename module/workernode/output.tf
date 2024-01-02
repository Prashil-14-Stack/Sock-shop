output "workernode_host" {
  value = aws_instance.workernode.*.private_ip
}
output "workernode-id" {
  value = aws_instance.workernode.*.id
}
output "worker" {
  value = aws_instance.workernode.ami
  
}