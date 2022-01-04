#! /bin/bash
exec 2> /var/log/wp-install/07.log

#########################################
# Cleanup and restarts etc...
#########################################
#
apt-get -y remove telnet
apt-get -y remove nis
apt-get -y remove rsh-server
#
# UFW
ufw allow in "Apache Full" # Allows HTTP/HTTPS access
ufw allow OpenSSH          # Opens ports for ssh access
yes | ufw enable
#
# Service restarts
systemctl restart ufw
systemctl restart fail2ban
systemctl restart mysql
systemctl restart apache2
#
exit
