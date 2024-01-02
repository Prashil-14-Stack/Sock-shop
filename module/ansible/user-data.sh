#!/bin/bash

sudo apt-get update -y 
sudo apt-get install software-properties-common -y
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible python3-pip -y
sudo bash -c 'echo "StrictHostingKeyChecking No" >> /etc/ssh/ssh_config'

echo "${key}" > /home/ubuntu/key.pem
sudo chmod 400 /home/ubuntu/key.pem
sudo chown ubuntu:ubuntu /home/ubuntu/key.pem


sudo touch /etc/ansible/hosts
sudo chown ubuntu:ubuntu /etc/ansible/hosts
sudo chown -R ubuntu:ubuntu /etc/ansible && chmod +x /etc/ansible


sudo chown -R ubuntu:ubuntu /etc/ansible
sudo chmod 777 /etc/ansible/hosts

sudo echo HAPROXY1: "${haproxy1}" > /home/ubuntu/ha-ip.yml
sudo echo HAPROXY1: "${haproxy2}" >> /home/ubuntu/ha-ip.yml


sudo echo "[haproxy1]" > /etc/ansible/hosts
sudo echo "${haproxy1} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "[haproxy2]" >> /etc/ansible/hosts
sudo echo "${haproxy2} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "[main-master]" >> /etc/ansible/hosts
sudo echo "${main-master} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "[member-master]" >> /etc/ansible/hosts
sudo echo "${member-master01} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "${member-master02} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "[worker]" >> /etc/ansible/hosts
sudo echo "${worker01} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "${worker02} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts
sudo echo "${worker03} ansible_ssh_private_key_file=/home/ubuntu/key.pem" >> /etc/ansible/hosts

sudo su -c "ansible-playbook /home/ubuntu/playbook/install.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/ha-keepalived.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/main-master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/member-master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/worker.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/ha-kubectl.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/stage.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/prod.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/monitoring.yml" ubuntu

#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/install.yml" ubuntu
#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/keepalived.yml" ubuntu
#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/main-master.yml" ubuntu
#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/member-master.yml" ubuntu
#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/worker.yml" ubuntu
#sudo su -c "ansible-playbook -i /etc/ansible/hosts /home/ubuntu/playbook/haproxy.yml" ubuntu

sudo hostnamectl set-hostname ansible