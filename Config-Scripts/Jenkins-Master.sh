#!/bin/bash

set -e

# Cleanup and update system
dnf clean all
dnf -y update

# Install core tools
dnf install -y \
    dnf-plugins-core \
    sudo \
    git \
    wget \
    unzip \
    yum-utils \
    openssh \
    openssh-server \
    openssh-clients

dnf clean all


# Create Jenkins user and configure
useradd -m -s /bin/bash -d /var/lib/jenkins jenkins
echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
dnf upgrade -y
dnf install -y fontconfig java-21-openjdk jenkins
dnf clean all

# Fix permissions for Jenkins WAR file
chown jenkins:jenkins /usr/share/java/jenkins.war

# SSH Configuration
ssh-keygen -A

# Secure SSH config - Only public key authentication allowed
mkdir -p /etc/ssh/sshd_config.d

cat > /etc/ssh/sshd_config.d/custom.conf << EOF
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
UsePAM yes
EOF

# You may want to copy your authorized_keys for Jenkins user here
# For example:
mkdir -p /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh


# not mandatory if no-one is doing ssh into jenkins master
# # Place your public key here (replace 'your-public-key' with actual key)
# echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-public-key" > /var/lib/jenkins/.ssh/authorized_keys
# chmod 600 /var/lib/jenkins/.ssh/authorized_keys


chown -R jenkins:jenkins /var/lib/jenkins/.ssh


# make keys
ssh-keygen -t rsa -N "" -f /var/lib/jenkins/.ssh/id_rsa
chown -R jenkins:jenkins /var/lib/jenkins/.ssh/*
chmod 400 /var/lib/jenkins/.ssh/id_rsa

# if needed run sshd service, root will handle sshd
/usr/sbin/sshd -D &

# jenkins will be run as Jenkins user, jenkins will handle jenkins service
sudo -u jenkins java -jar /usr/share/java/jenkins.war &

# will get the initial admin pass here
# /var/lib/jenkins/.jenkins/secrets/initialAdminPassword


# run ctrl + p + q to escape without stopping the process.

# then from base os run: docker exec -it <cont_name> bash
