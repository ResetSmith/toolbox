#! /bin/bash
exec 2> /var/log/wp-install/03.log

###################################################################
# PHP
###################################################################
#
# downloads and installs PHP and necessary add-ons
apt-get install -y php libapache2-mod-php php-mysql php-curl \
php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
#
# Updates dir.conf file to put index.php at the front
sed -i '2s/.*/     DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
#
exit
