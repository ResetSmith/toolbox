#! /bin/bash
exec 2> /var/log/wp-install/05.log

###################################################################
# Fail2Ban
###################################################################
#
apt-get -y install fail2ban
#
curl https://plugins.svn.wordpress.org/wp-fail2ban/trunk/filters.d/wordpress-hard.conf > /etc/fail2ban/filter.d/wordpress-hard.conf
curl https://plugins.svn.wordpress.org/wp-fail2ban/trunk/filters.d/wordpress-soft.conf > /etc/fail2ban/filter.d/wordpress-soft.conf
#
# makes logfile for separate wordpress logs
touch /var/log/wpauth.log
###################################################################
# jail.local definition
###################################################################
cat << EOF >> /etc/fail2ban/jail.local
#
# Default banning action (e.g. iptables, iptables-new,
# iptables-multiport, shorewall, etc) It is used to define
# action_* variables. Can be overridden globally or per
# section within jail.local file
#
# set fail2ban to use ufw instead of iptables
[DEFAULT]
banaction = ufw

# SSH jail
#
[sshd]
enabled   = true
port      = ssh
filter    = sshd
logpath   = /var/log/auth.log
maxretry  = 3
findtime  = 43200
bantime   = 43200
ignoreip  = 134.197.13.0/24

[sshd-long]
enabled   = true
port      = ssh
filter    = sshd
logpath   = /var/log/auth.log
maxretry  = 30
findtime  = 259200
bantime   = 608400
ignoreip  = 134.197.13.0/24

# Apache jail
#
[apache]
enabled   = true
port      = http,https
filter    = apache-auth
logpath   = /var/log/apache*/*error.log
maxretry  = 3

[apache-overflows]
enabled   = true
filter    = apache-overflows
logpath   = /var/log/apache*/*error.log

[apache-badbots]
enabled   = true
filter    = apache-badbots
logpath   = /var/log/apache*/*access.log

# WordPress jail
#
[wordpress-hard]
enabled   = true
filter    = wordpress-hard
logpath   = /var/log/auth.log
port      = http,https
maxretry  = 10
bantime   = 10800
ignoreip  = 134.197.13.0/24
action = ufw[application="OpenSSH", blocktype=reject]
         mail-whois[name=Wordpress-Hard, dest=webmaster@casat.org]

[wordpress-soft]
enabled   = true
filter    = wordpress-soft
logpath   = /var/log/auth.log
port      = http,https
maxretry  = 10
bantime   = 300
ignoreip  = 134.197.13.0/24
action = ufw[application="OpenSSH", blocktype=reject]
         mail-whois[name=Wordpress-Soft, dest=webmaster@casat.org]
EOF
#
exit
