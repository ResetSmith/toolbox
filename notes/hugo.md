# permissions for content folder for Hugo
sudo chmod 755 /var/www/$HUGO_FOLDER
find /var/www/$HUGO_FOLDER/ -type f -exec chmod 644 {} \;
sudo chown -R www-data:www-data /var/www/$HUGO_FOLDER
