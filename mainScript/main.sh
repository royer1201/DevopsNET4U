#!/bin/bash

echo "Choose an option:"
echo "1. Discover all IPs in network"
echo "2. install full packages Centos"
echo "3. install full packages Ubuntu"
echo "4. Install Jenkins Master - on a remote server"
echo "5. Create Ansible-Playbook "

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        sudo nmap -sn 192.168.29.0/24
        ;;
    2)
        # Update the system
        sudo yum -y update

        # Install Python 3.7
        sudo yum install -y epel-release
        sudo yum install -y python3
        sudo alternatives --set python /usr/bin/python3

        # Install Docker
        udo yum install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker

        # Install Ansible
       sudo yum install -y ansible

        # Install net-tools
        sudo yum install -y net-tools
        echo "Installed versions:"
        python --version
        docker --version
        ansible --version
        ;;
    3)
                # Update the system
        sudo apt update
        sudo apt upgrade -y

        # Install Python 3.7
        sudo apt install -y python3.7

        # Install Docker
        sudo apt install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker

        # Install Ansible
        sudo apt install -y ansible

        # Install net-tools
        sudo apt install -y net-tools
        echo "Installed versions:"
        python3.7 --version
        docker --version
        ansible --version
        ;;
    4)
        read -p "Enter the IP/NAME of the remote server: " server
        # Connect to the server and execute updates and Jenkins installation
        ssh $server << 'EOF'
            sudo apt update
            sudo apt install -y openjdk-8-jdk
            wget http://mirrors.jenkins.io/war-stable/latest/jenkins.war
            java -jar jenkins.war  
            curl http://localhost:8080



EOF
        
        ;;
    5)
        ansible-playbook  playbook.yaml
        ;;
    *)
        echo "Invalid choice. Please enter a number between 1 and 5."
        ;;
esac
