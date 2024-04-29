#!/bin/bash

echo "Hope you are running this script on Test server not on production server"
echo "If you executed on production server Don't panick !!  You can cancle it within next 30 Seconds."
sleep 30

echo "Advanced security configuration started ..!!!"

# Update package repositories and upgrade installed packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y unattended-upgrades fail2ban apparmor-utils

# Configure automatic security updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Secure SSH configuration
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# Configure Fail2ban to protect SSH
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Secure Apache configuration (if applicable)
sudo sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf
sudo systemctl restart apache2

# Secure PHP configuration (if applicable)
sudo sed -i 's/expose_php = On/expose_php = Off/' /etc/php/7.4/apache2/php.ini
sudo systemctl restart apache2

# Secure MySQL/MariaDB configuration (if applicable)
sudo mysql_secure_installation

# Configure firewall (if applicable)
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Harden network configurations
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.ip_forward=0
sudo sysctl -w net.ipv4.conf.all.send_redirects=0
sudo sysctl -w net.ipv4.conf.default.send_redirects=0
sudo sysctl -w net.ipv4.conf.all.accept_source_route=0
sudo sysctl -w net.ipv4.conf.default.accept_source_route=0
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0
sudo sysctl -w net.ipv4.conf.all.secure_redirects=0
sudo sysctl -w net.ipv4.conf.default.secure_redirects=0

# Enable and configure AppArmor (if applicable)
sudo aa-enforce /etc/apparmor.d/*
sudo systemctl restart apparmor

# Enable SELinux (if applicable)
# Uncomment the following lines if SELinux is available and desired
# sudo setenforce 1
# sudo sed -i 's/SELINUX=enforcing/SELINUX=enforcing/' /etc/selinux/config

# Enable auditd for auditing (if applicable)
sudo systemctl enable auditd
sudo systemctl start auditd

# Implement file integrity checking with AIDE
sudo apt install -y aide
sudo aideinit
sudo mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Implement log monitoring with rsyslog
# Configure rsyslog to forward logs to a central log server if applicable

echo "Advanced security configuration completed. Please review the changes and ensure the system is functioning as expected."
