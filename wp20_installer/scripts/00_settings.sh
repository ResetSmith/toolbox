#! /bin/bash
exec 2> /var/log/wp-install/00.log

###################################################################
# Server settings
###################################################################
#
# Updates server
apt-get -y upgrade
# Turns on colored propmts in terminal
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
# adds custom prompt for root
cat << EOF >> ~/.bashrc
# Custom prompt
export PS1="\[$(tput bold)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\] @\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;10m\]\H\[$(tput sgr0)\] \A\n[\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]] \\$ \[$(tput sgr0)\]"
#
EOF
#
# Sets timezone to pacific time
timedatectl set-timezone America/Los_Angeles
# Updates the MOTD
cd /etc/update-motd.d/ || exit
rm 00-header 10-help-text 50-landscape-sysinfo 50-motd-news 80-esm 80-livepatch 90-updates-available; cd - || exit;
rm /etc/legal
cp ./files/50-casat-motd /etc/update-motd.d/50-casat-motd
# makes the motd file executable
chmod +x /etc/update-motd.d/50-casat-motd
#
###################################################################
# STIG compliance section
# these are additional settings as recommended by the
# Security Technical implementation Guide for Ubuntu 16.04
###################################################################
#
# sets maxlogins limit per STIG
sed -i '6s/.*/*          hard     maxlogins     10\n&/' /etc/security/limits.conf
#
# updates UNMASK permissions to 077 per STIG
sed -i '151s/022/077/g' /etc/login.defs
#
# the Ubuntu operating system must require users to re-authenticate for
# privilege escalation and changing roles per STIG V-75489
# sed -i '4s/NOPASSWD:ALL//' /etc/sudoers/90-cloud-init-users
# Updates internal server logging per STIG
cat << EOF >> /etc/rsyslog.d/50-default.conf

###################################################################
#
# Configure the Ubuntu operating system to monitor all remote access methods
# by adding the following lines to the /etc/rsyslog.d/50-default.conf file
# per STIG V-75863
#
auth.*,authpriv.*               /var/log/secure
daemon.notice                   /var/log/messages
#
# Configure rsyslog to log all cron messages - per STIG V-75865
cron.*                           /var/log/cron.log
#
EOF
#
# updates log file ownership
chmod 0770 /var/log
#
# creates script to log users out after 15 minutes of inactivity
touch /etc/profile.d/autologout.sh
#
cat << EOF > /etc/profile.d/autologout.sh
#! /bin/sh
#
# Script created to auto logout users after 15 minutes of inactivity
# per STIG V-75441
#
TMOUT=900
readonly TMOUT
export TMOUT
#
EOF
chmod +x /etc/profile.d/autologout.sh
#
# PAM
# the system must use a sufficient number of hashing rounds to ensure the required
# level of entropy per STIG V-75463
sed -i '25s/$/ rounds=5000/' /etc/pam.d/common-password
# overwrites existing pam common-auth file
cat << EOF > /etc/pam.d/common-auth
#
# /etc/pam.d/common-auth - authentication settings common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of the authentication modules that define
# the central authentication scheme for use on the system
# (e.g., /etc/shadow, LDAP, Kerberos, etc.).  The default is to use the
# traditional Unix authentication mechanisms.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.
#
# here are the per-package modules (the "Primary" block)
auth	[success=1 default=ignore]	pam_unix.so nullok_secure
# here's the fallback if no module succeeds
auth	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
auth	required			pam_permit.so
# and here are more per-package modules (the "Additional" block)
auth	optional			pam_cap.so
#
###################################################################
# additional settings recommended - per STIG
# limit login attempts to '3'
#auth      required                       pam_tally2.so onerr=fail deny=3
# limits login to delay of 4 seconds after failure
#auth      required                       pam_faildelay.so delay=4000000
# checks newly created passwords against dictionary attacks and asks to recreate if needed
#password  required                       pam_cracklib.so retry=3
# end of pam-auth-update config
# removed 'nullok_secure' reference to limit 'nopassword' logins - per STIG
#auth      [success=1 default=ignore]    pam_unix.so
#
EOF
#
# additons to existing sshd_config
cat << EOF >> /etc/ssh/sshd_config

###################################################################
#
# Additional settings defined by STIGs
#
# Update sshd_config to enforce SSHv2 for network access to all accounts
# per STIG V-75823
Protocol 2
#
# Allow the SSH daemon to only implement DoD-approved encryption
# per STIG V-75829
Ciphers aes128-ctr,aes192-ctr,aes256-ctr
#
# Allow the SSH daemon to only use Message Authentication Codes (MACs) that
# employ FIPS 140-2 approved ciphers
# per STIG V-75831
MACs hmac-sha2-256,hmac-sha2-512
#
# The system must display the date and time of the last successful account logon
# upon an SSH logon
# per STIG V-75835
PrintLastLog yes
#
# Unattended or automatic login via ssh must not be allowed
# per STIG V-75833
PermitEmptyPasswords no
PermitUserEnvironment no
#
# Automatically terminate all network connections associated with SSH traffic at
# the end of a session or after a '10' minute period of inactivity
# per STIG V-75837
ClientAliveInterval 600
#
# The SSH daemon must not allow authentication using known hosts authentication
IgnoreUserKnownHosts yes
#
# The SSH daemon must perform strict mode checking of home directory configuration files
# per STIG V-75847
StrictModes yes
#
# The SSH daemon must use privilege separation
# SSH daemon privilege separation causes the SSH process to drop root privileges
# when not needed, which would decrease the impact of software vulnerabilities
# in the unprivileged section.
# per STIG V-75849
UsePrivilegeSeparation yes
#
# The SSH daemon must not allow compression or must only allow compression
# after successful authentication
# per STIG V-75851
Compression delayed
#
EOF
#
# sysctl.conf
# additions to existing sysctl.conf
cat << EOF >> /etc/sysctl.conf

###################################################################
# Additional settings defined by STIGs
#
# Configure the Ubuntu operating system to use TCP syncookies
# per STIG V-75869
net.ipv4.tcp_syncookies=1
#
# Configure Ubuntu to not forward IPv4 source-routed packets
# per STIG V-75873
net.ipv4.conf.all.accept_source_route=0
#
# Configure Ubuntu to not forward IPv4 source-routed packets by default
# per STIG V-75875
net.ipv4.conf.default.accept_source_route=0
#
# Configure Ubuntu to not respond to IPv4 ICMP echoes sent to a broadcast address
# per STIG V-75877
net.ipv4.icmp_echo_ignore_broadcasts=1
#
# Configure Ubuntu to prevent IPv4 ICMP redirect messages from being accepted
# per STIG V-75879
net.ipv4.conf.default.accept_redirects=0
#
# Configure Ubuntu to ignore IPv4 ICMP redirect messages
# per STIG V-75881
net.ipv4.conf.all.accept_redirects=0
#
EOF
#
exit
