# Cheat Sheet for Ubuntu

Change hostname
```
hostnamectl set-hostname $HOSTNAME
```
Must also check the following files and update if necessary
```
vim /etc/hostname
vim /etc/hosts
```
Restart server to take effect
Set servertime
```
timedatectl
```
sets server time to local 'Pacific' time
```
sudo timedatectl set-timezone America/Los_Angeles
```
Turns on colored propmts in terminal
```
sed -i 's/#force_color_prompt=yes/force_color_prompt=yes/g' ~/.bashrc
```

### ~/.bashrc custom prompts
For users:
```
export PS1="\u @\[$(tput sgr0)\]\[\033[38;5;10m\]\H\[$(tput sgr0)\] \A\n[\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]] \\$ \[$(tput sgr0)\]"
```
For root:
```
export PS1="\[$(tput bold)\]\[\033[38;5;10m\]\u\[$(tput sgr0)\] @\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;10m\]\H\[$(tput sgr0)\] \A\n[\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]] \\$ \[$(tput sgr0)\]"
```
if you see a permission denied error, update permissions of .bashrc
```
chmod 644 ~/.bashrc
```
Set bash as the default shell on ssh login
```
chsch -s /bin/bash
```
need to create a ~/.bash_profile file to load custom prompts with the following
```
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"
```
or through root
```
usermod -s /bin/bash $USERNAME
```

### Create users
Create user 'home' and '.ssh' folders
```
sudo mkdir -p /home/$USERNAME/.ssh
```
Create 'authorized keys' file
```
sudo touch /home/$USERNAME/.ssh/authorized_keys
```
Create user
```
sudo useradd -d /home/$USERNAME $USERNAME
```
Add user to 'sudo' group (alllows sudo privileges)
```
sudo usermod -aG sudo $USERNAME
```
Give user permission over own home folder
```
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME
```
Give root permission of users home folder
```
sudo chown root:root /home/$USERNAME
```
Update permissions on '.ssh' folder and 'authorized_keys' file
```
sudo chmod 700 /home/$USERNAME/.ssh
sudo chmod 644 /home/$USERNAME/.ssh/authorized_keys
```
Set user 'sudo' password for user
```
passwd $USERNAME
```

### Copy SSH key to server
Need to enable 'password authentication' on the server by opening sshd_config
```
sudo vim /etc/ssh/sshd_config
```
Look for 'Passwordauthentication' and update 'no' to 'yes'
Reload sshd
```
sudo service sshd restart
```
On LOCAL MACHINE run
```
ssh-copy-id $USERNAME@$DOMAIN_NAME
```
Alternatively if you get errors you may need to specify the public key file
```
ssh-copy-id -i /home/$USER/.ssh/id_rsa.pub $USER@$DOMAIN_NAME
```
You will be prompted for the 'sudo' password defined earlier
Need to disable 'password authentication'
```
sudo vim /etc/ssh/sshd_config
```
Update 'Passwordauthentication' back to 'no'
Reload sshd
```
sudo service sshd restart
```
---

## Hash a password
Use mkpasswd
May need to install whois package first

Run with -m help to see hashing method options
```
mkpasswd -m help
mkpasswd -m sha512crypt
```
Output is the hashed password

---

### Update SSH Key on server
Check apache site config file for key file locations
```
vim /etc/apache2/sites-available/$HOSTNAME.conf
```
Ideally move all key files to /etc/ssl/www/$KEY_FILES
Make the folder if it doesn't exist
```
mkdir /etc/ssl/www
```
Generate SSL CSR and Key
```
openssl req \
-newkey rsa:2048 -nodes \
-keyout /etc/ssl/www/$YEAR.$DOMAIN_NAME.key \
-out /etc/ssl/www/$YEAR.$DOMAIN_NAME.csr
```
fill out questions, only lowercase letters, no spaces
do not fill out the 'extra attributes' section, leave it blank
Copy CSR for the certificate request
```
cat /etc/ssl/www/$YEAR.$DOMAIN_NAME.csr
```
When using Namecheap to purchase certificates use DNS validation
Remove prior CNAME record in DNS and create a new one
Once validated the validated certificate will be emailed
Use FTP to move the *.crt and *.ca-bundle files to the server
Will need to enable pasword authentication on server to FTP in
```
vim /etc/ssh/sshd_config
```
update Passwordauthentication to 'no'
restart sshd service
```
sudo systemctl restart sshd
```
FTP to server over port 22, copy files to /etc/ssl/www
Update the apache vhost file to reflect the new certificate files
```
vim /etc/apache2/sites-available/$HOSTNAME.conf
```
Update the following sections to reflect the new keyfiles
```apache
SSLCertificateFile  /etc/ssl/www/$YEAR.$DOMAIN_NAME.crt
SSLCertificateKeyFile /etc/ssl/www/$YEAR.$DOMAIN_NAME.key
SSLCACertificateFile /etc/ssl/www/$YEAR.$DOMAIN_NAME.ca-bundle
```
Check apache for errors
```
apache2ctl configtest
```
If no errors then retart apache
```
sudo systemctl restart apache2
```
---


## Apache Notes
Show active Vhost configuration in Apache
```
apache2ctl -S
```
Enable vhost in apache
```
a2ensite $VHOST.conf
```
Disable vhost in apache
```
a2dissite $VHOST.conf
```
Enable SSL in apache
```
a3enmod ssl
```
Check for errors in apache
```
apache2ctl configtest
```

### Access control via Apache VirtualHost
*Note This will NOT work while using wordpress with .htaccess file*
Install Apache utils package
```
apt-get update
apt-get install apache2-utils
```
create password file and user
```
htpasswd -c /etc/apache2/.htpasswd $USERNAME
```
LEAVE OFF -c for additional users
```
htpasswd /etc/apache2/.htpasswd $USERNAME2
```
*Must be added to the 'Directory' section of the Apache VirtualHost file*
```
  AuthType Basic
  AuthName "Restricted Content"
  AuthUserFile /etc/apache2/.htpasswd
  Require valid-user
```
check apache configuration
```
apache2ctl configtest
```
restart apache
```
systemctl restart apache
```
if seeing misconfiguration errors, may need to update ownership of .htpasswd
```
chown www-data:www-data /etc/apache2/.htpasswd
```
---


## Fail2Ban
check status
```
fail2ban-client status
```
check ban list in iptables
```
iptables -L -n
```
unban IP address
*V0.8.8 and later*
```
fail2ban-client set $JAILNAME unbanip $IPADDRESS
```
*Prior to V0.8.8*
```
fail2ban-client get $JAILNAME actionunban $IPADDRESS
```
---


## UFW
allow SSH access from specific IP
```
ufw allow from $IP to any port 22
```
allow incoming Rsync access from specific IP
```
ufw allow from $IP to any port 873
```
Reject access to specific IP
Reject is preferable to Deny, Reject returns an error message to the requestor

Deny just drops the packets from the requestor who will eventually time out

the requestor will not see an error message when using Deny
```
ufw reject from $IP to any
```
---


### setting up FTP access on servers
```
apt install vsftpd
cp /etc/vsftpd.conf /etc/vsftpd.conf.old
ufw allow 20/tcp
ufw allow 21/tcp
```
configure FTP access
```
vim /etc/vsftpd.conf
```
Update to match the following
```
# Allow anonymous FTP? (Disabled by default).
anonymous_enable=NO
# Uncomment this to allow local users to log in.
local_enable=YES
write_enable=YES
chroot_local_user=YES
```
*ADD*
```
user_sub_token=$USER
local_root=/home/$USER # set to '/' for unlimited access
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
```
restart VSFTP
```
systemctl restart vsftpd
```
Creating users for FTP access
```
adduser $USER
mkdir /home/$USER/
chown $GROUP:$GROUP /home/$USER/
chmod a-w /home/$USER/
```
add user to userlist file
```
echo "$USER" | tee -a /etc/vsftpd.userlist
```
---


## CERTBOT
requesting 'cert only'
```
certbot certonly --noninteractive --agree-tos -m webmaster@casat.org \
-d "$FQDN" --webroot -w /var/www/html/"$HOSTNAME"
```
renewals
```
certbot renew
```
renew certificate on apache configuration
```
certbot renew --apache
```
test certbot renewal on apache server
```
certbot renew --apache --dry-run
```
---


### .htaccess file notes
*write code in blocks that are bookended by BEGIN and END like below INCLUDING HASHES*
```
# BEGIN $CODE DESCRIPTION
instructions go here
# END $CODE DESCRIPTION
```

Adding custom PHP values needed for many modern themes
```
## BEGIN Custom PHP values
php_value upload_max_filesize 64M
php_value post_max_size 128M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300
## END Custom PHP values
```
### Adding a password using htpasswd
Install Apache utils package
```
apt-get update
apt-get install apache2-utils
```
create password file and user
```
htpasswd -c /etc/apache2/.htpasswd $USERNAME
```
LEAVE OFF -c for additional users
```
htpasswd /etc/apache2/.htpasswd $USERNAME2
```
update permissions to .htpasswd file
```
chmod 644 /etc/apache2/.htpasswd
```
add following to .htaccess file
```
## BEGIN password
AuthType Basic
AuthName "Authorized Users"
AuthUserFile /etc/apache2/.htpasswd
Require valid-user
## END password
```
Restart apache service
```
systemctl restart apache2
```
---


## MySql Notes
connect to mysql app
```
mysql -u $USERNAME -p
```
list databases
```
SHOW DATABASES;
```
select database for use
```
USE $DATABASE;
```
list tables
```
SHOW TABLES;
```
### Reset root user password
open mysqld.cnf
```
vim /etc/mysql/mysql.conf.d/mysqld.cnf
```
under [mysqld] add:
```
skip-grant-tables = 1
plugin-load-add = auth_socket.so
```
restart mysql
```
sudo systemctl restart mysql
```
connect to mysql
```
mysql -u root
```
run in sql
```
UPDATE mysql.user SET authentication_string=null WHERE User='root';
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$PASSWORD';
```
undo changes to mysql.cnf
```
vim /etc/mysql/mysql.conf.d/mysqld.cnf
```
add hashes to prior additions to comment out

**If you receive ERROR while installing mysql-server-8.0**

>E: Sub-process /usr/bin/dpkg returned an error code (1)

Run install configuration tool - as sudo
```
dpkg --configure -a
```
---


## PHP notes
updating 7.2 > 7.4 on Ubuntu 18.04
```
apt install software-properties-common
add-apt-repository ppa:ondrej/php
apt update
apt upgrade
```
check current php version
```
php -v
```
if still showing 7.2 try
```
apt install php7.4
```
enable 7.4 in Apache and disable old version
```
a2enmod php7.4
a2dismod php7.2
systemctl restart apache2
```
---

## Auth.log notes
search auth.log for mentions of a particular IP
```
grep "$IP" /var/log/auth.log
```
search auth.log for the term "Connection closed" and make a list of the IP addresses
```
grep "Connection closed" /var/log/auth.log | grep -Po "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort | uniq -c
```
