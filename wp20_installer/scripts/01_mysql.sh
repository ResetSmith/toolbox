#! /bin/bash
exec 2> /var/log/wp-install/01.log

###################################################################
# MySql install script
###################################################################
#
# Downloads and installs mysql server
apt-get install -y mysql-server
#
# Updates the default mysql installation, creates 'root' user,
mysql -e "UPDATE mysql.user SET authentication_string= '$SQLPASS' WHERE User= 'root';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DELETE FROM mysql.user WHERE User='';"
# Creates the table needed for Wordpress, defines user and password, and grants permission
mysql -e "CREATE DATABASE $WPHOSTNAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
mysql -e "CREATE USER '$WPUSERNAME'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WPPASSWORD';"
mysql -e "GRANT ALL ON $WPHOSTNAME.* TO '$WPUSERNAME'@'localhost'"
# applies updates to mysql users
mysql -e "FLUSH PRIVILEGES;"
#
exit
