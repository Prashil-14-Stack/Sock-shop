locals{
 jenkins-user-data= <<-EOF
#!/bin/bash
# Update the package list
sudo yum update -y
sudo yum install git -y
sudo yum install wget -y
# Install Java (Jenkins requires Java)
sudo yum install java-17-openjdk -y
# Import the Jenkins repository key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# Add the Jenkins repository
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# Install Jenkins
sudo yum install jenkins -y
sudo yum upgrade -y
# Start Jenkins service
sudo systemctl start jenkins
sudo systemctl daemon-reload
# Enable Jenkins service to start on boot
sudo systemctl enable jenkins
sudo systemctl hostname jenkins
EOF
}

