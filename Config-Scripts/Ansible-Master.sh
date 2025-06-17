#!/bin/bash

# Logged in as root by default
# Update system and install packages might come handy
dnf -y update
dnf -y install python3 net-tools iputils python3-pip openssh-clients openssh-server sudo
dnf clean all

# Install latest Ansible via pip
pip3 install --no-cache-dir ansible

# Create ansible user with sudo access
useradd -d /home/ansible -s /bin/bash ansible
echo "ansible:ansible123" | sudo chpasswd
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

# Create SSH directory for ansible user
mkdir -p /home/ansible/.ssh
chown ansible:ansible /home/ansible/.ssh
chmod 700 /home/ansible/.ssh

# Generate host keys for SSH server
ssh-keygen -A

# Configure sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

################## till Now can run together ########################
################ NEXT Manually run one by one ################################

# manualy put the id_rsa key from jenkins master to /home/ansible/id_rsa

echo "..........your private key content" > /home/ansible/.ssh/id_rsa
chmod 400 /home/ansible/.ssh/id_rsa
chown ansible:ansible /home/ansible/.ssh/id_rsa

# get the id_rsa.pub key from jenkins master and paste it
# Example key placement — replace with your actual key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-public-key" > /home/ansible/.ssh/authorized_keys
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh

# Start SSH service 
/usr/sbin/sshd -D &


# then manually login to ansible user, sudo is configured for ansible



