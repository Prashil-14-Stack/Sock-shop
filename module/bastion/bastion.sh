#!/bin/bash
exec > >(/tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "${key}" >> /home/ubuntu/keypair.pem
sudo chmod 400 /home/ubuntu/keypair.pem
sudo chown ubuntu:ubuntu /home/ubuntu/keypair.pem
sudo hostnamectl set-hostname bastion