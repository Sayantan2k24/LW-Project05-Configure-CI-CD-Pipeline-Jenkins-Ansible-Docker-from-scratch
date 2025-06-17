#!/bin/bash

set -e

# Update and install dependencies
dnf clean all
dnf -y update
dnf -y install \
    dnf-plugins-core \
    sudo \
    git \
    wget \
    unzip \
    yum-utils \
    openssh \
    openssh-server \
    openssh-clients \
    java-21-openjdk \
    iputils \
    net-tools

# Install Docker-CE
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
dnf clean all

# Create Jenkins agent user
useradd -m -s /bin/bash -d /home/jenkinsAgent jenkinsAgent
echo "jenkinsAgent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
usermod -aG docker jenkinsAgent

# Prepare SSH
ssh-keygen -A
mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/custom.conf <<EOF
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
UsePAM yes
EOF

# Setup authorized_keys (You must manually copy your public key here later)
mkdir -p /home/jenkinsAgent/.ssh
chmod 700 /home/jenkinsAgent/.ssh

################## till Now can run together ########################
################ NEXT Manually run one by one ################################

# get the id_rsa.pub key from jenkins master and paste it
# Example key placement — replace with your actual key
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-public-key" > /home/jenkinsAgent/.ssh/authorized_keys
chmod 600 /home/jenkinsAgent/.ssh/authorized_keys
chown -R jenkinsAgent:jenkinsAgent /home/jenkinsAgent/.ssh

# Start Docker daemon in background
dockerd &

# Start SSH daemon as root user
/usr/sbin/sshd -D &

# jenkinsAgent can run docker cli commands without using sudo