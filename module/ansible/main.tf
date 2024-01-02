resource "aws_instance" "ansible" {
  ami                         = var.ami
  instance_type               = var.instance
  key_name                    = var.key_name
  vpc_security_group_ids      = var.ansible-sg
  subnet_id                   = var.subnet07
  associate_public_ip_address = true
  user_data                   = templatefile("./module/ansible/user-data.sh",{
    key = var.private-key,
    haproxy1 = var.haproxy1,
    haproxy2 = var.haproxy2,
    main-master = var.main-master,
    member-master01 = var.member-master1,
    member-master02 = var.member-master2,
    worker01 = var.worker01,
    worker02 = var.worker02,
    worker03 = var.worker03
  })
  tags = {
    Name = "ansible"
  }
}

resource "null_resource" "copy-playbook-dir" {
    connection {
        type = "ssh"
        host = aws_instance.ansible.private_ip
        user = "ubuntu"
        private_key = var.private-key
        bastion_host = var.bastion_host_2
        bastion_user = "ubuntu"
        bastion_private_key = var.private-key
    }
    provisioner "file" {
        source = "./module/ansible/playbook"
        destination = "/home/ubuntu/playbook"
    }
}
