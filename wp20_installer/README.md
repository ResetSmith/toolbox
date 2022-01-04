# U18_WPInstall


This script was created to ensure we have a reproducible way to create uniform
WordPress installations on any Virtual Private Server(VPS) system. It was tested
on DigitalOcean on Ubuntu 18.04 and should potentially work on any similar system.
This script is designed to be run on a 'new' system with only Ubuntu 18 installed.

This script does several things, it will prompt the user for some basic input
about the website. It will then use the information provided to install and
configure the following MySql, Apache, PHP, and WordPress. The WordPress site will
be setup to default to HTTPS with a certificate generated from Let's Encrypt using
CertBot. After the site is setup the script will add two users to the server, and
security settings to comply with federal guidelines will be applied. Finally the
script will install and configure Prometheus Exporting tools so that the website
will report to the central monitoring server.

If there are any problems during the installation this script maintains 2 log
files. There is one main log for the install.sh process which can be found in
/var/log/wp-install/install.log. Each numbered 'sub-process' has it's own log
as well, these can be found in /var/log/wp-install/ and numbered appropriately.

###################################################################


## What to do prior to running this script

In order to use this script you will need to have a domain name ready, and the DNS
properly configured. For this script to work there should be 2 DNS 'A' records,
one for $DOMAIN.com and the other for www.$DOMAIN.com. Your DNS should look
something like this:
```

A.....$DOMAIN.com.........164.227.30.253.....3600

A.....www.$DOMAIN.com.....164.227.30.253.....3600
```

Even though this script doesn't support domains beginning with www, the www. 'A'
record allows www.$DOMAIN.com to redirect to $DOMAIN.com. Without the 'A' record
forwarding won't work properly.

You also need to update the 'index.conf.example' file located in /files/. The file
will need to be renamed to 'index.conf' and the variables filled in. The index.conf
file is separated into three sections; Root User Password, User Info, and Prometheus
Info.

Root User Password - is where you will set the password for the 'root' user on the
server. Remember that remote 'root' logins will be disabled, so this only applies
when logging in from the DigitalOcean terminal or elevating your user account on
the server after already logging in.

User Info - here you will fill in the info for up to two users. You will need to
create the usernames, create a temporary password, and add the id_rsa.pub data for
both users. If you only wish to create a single user, leave the USER2 data blank
and it will be skipped. Regardless you need to fill in the *TEMP_PASS* variable as
the script will set a temporary password shared by both users that they will be
prompted to update on first login. After running the script users will only be
able to login via SSH keys.

Prometheus Info - is the section that informs the script about the monitoring
server information. The *PROM_SERVER* should be the IP address of the remote server.
The SQL variables are used to generate SQL users for the Prometheus Export service.

###################################################################


## Cloning Existing WordPress Websites

Cloning WordPress websites is still a manual process that this script is just a
step during. The process below will go into detail about what needs to be done
to transfer an existing WordPress website to a new server or domain.

## I
  *This should be done on the new server*

Run the U18_WPInstall tool on the server. After the tool has completed running
log back into the server and update the sshd_config to allow remote 'root' logins
temporarily. This can be done with the following code:
```
vim /etc/ssh/sshd_config
```
Update the following lines to match below:
```
PermitRootLogin yes
PasswordAuthentication yes
```
Restart the sshd service
```
systemctl restart sshd
```

## II
  *This should be done on the server you want to move or copy*

The code below will walk you through making a copy of the website MySql database
and WordPress files. You can find the MySql database name, user, and password in
the website's /var/www/html/wp-config.php file. First thing is to move to a temp
folder and create a folder to house the files
```
cd /tmp
mkdir $HOSTNAME_COPY
```
Create a copy of the MySql database, and copy the WordPress files
```
mysqldump -u $USER -p $DATABASE_NAME > $HOSTNAME_COPY/$DATABASE_CLONE_NAME
cp -avr /var/www/html/wp-content $HOSTNAME_COPY
```
Then create a 'tarball' of the files and send them to the new server
```
tar -czvf $HOSTNAME.tar.gz $HOSTNAME_COPY
scp $HOSTNAME.tar.gz root@$NEWSERVER:~/tmp/
```
Finally remove the temporary files from the server
```
rm -rf $HOSTNAME.tar.gz $HOSTNAME_COPY
```

## III
  *This should be done on the new server*

The final steps on the new host are to unpack the tarball and import the MySql
database into our existing WordPress database on the server. Then remove the
existing /wp-content/ folder and replace it with the copy. If the website is
getting a new domain name then the links in MySql will also need to be updated.
Start with unpacking the tarball
```
tar -xzvf $HOSTNAME.tar.gz
```
Import the MySql database copy into the new server's existing database
```
mysql -u root -p WP_$EXISTINGDB < $DATABASE_CLONE_NAME
```
Remove existing /wp-content/ folder and replace it with the copy
```
rm -r /var/www/html/$HOSTNAME/wp-content/
cp -ar $HOSTNAME_COPY/wp-content /var/www/html/$HOSTNAME/
```
Since this folder is overwriting the old one the permissions will need to be updated
```
chown -R www-data:www-data /var/www/html/$HOSTNAME/
chmod -R 755 /var/www/html/$HOSTNAME/
```
If you are updating to a new domain name as well you will need to update the
MySql database links as well to point to the new domain name
```
mysql -u root -p

USE WP_$HOSTNAME;
UPDATE wp_options SET option_value = 'https://$DOMAIN_NAME' WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value = 'https://$DOMAIN_NAME' WHERE option_name = 'home';
exit;

systemctl restart mysql
```
After all of this you will want to disable 'root' logins to the server
```
vim /etc/ssh/sshd_config

PermitRootLogin No
PasswordAuthentication No

systemctl restart sshd
```
If you are updating the domain name you may need to do additional updates to the 
WordPress database. The easiest way to do this would be to run the 'Velvet_Blues'
WordPress add-on. The add-on will scan the database and update additional urls for
things like media and other files.

###################################################################
