# server migration notes
# 12/01/20
#

# 1. prep new server
# 2. create premigration snapshot in DigitalOcean
# 3. SSH into server to be copied
# 4.


# I. remove password from .htaccess file
vim /var/www/$HOSTNAME
# Remove the section starting with ##BEGIN password
# Restart Apache
systemctl restart apache2
#
# II. update apache VHOST
vim /etc/apache2/sites-available/$HOSTNAME.conf
# Remove dev. from each mention of the FQDN
# Restart Apache
systemctl restart apache2
#
# III. update mysql links
# Open MySql
sudo mysql -u root -p
# First time around we'll set the links for http
# Tell MySql to use the wordpress table for the website
USE wp_$HOSTNAME;
# Update the links to the new FQDN - fill in correct $DOMAIN_NAME
UPDATE wp_options SET option_value = 'http://$DOMAIN_NAME' WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value = 'http://$DOMAIN_NAME' WHERE option_name = 'home';
# Leave MySql
exit;
# Restart MySql
systemctl restart mysql
#
# IV. update DNS
# In DigitalOcean find the relevant domain name under the 'DOMAINS' section
# The 'A' records are the ones which direct website traffic
# Find both the $DOMAIN.org and www.$DOMAIN.org A records and update the
# IP address that they are pointing to and update that to the new server
# Below is an example of what it should look like
A       $HOSTNAME.org       directs to 192.168.1.1       36000
#
# V. create cert
# VI. enable SSL in Apache
# IV. update MYSQL links for https
