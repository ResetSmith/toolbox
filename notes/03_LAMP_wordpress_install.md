# Installing WordPress on LAMP Server

For the final step in getting WordPress installed on our DigitalOcean LAMP VPS we need to install WordPress.

To download WordPress, we will first navigate to the /tmp folder on the server and then download
```
cd /tmp
curl -O https://wordpress.org/latest.tar.gz
```

WordPress comes downloaded in a compressed form (tar.gz) so we will unpack it with tar and leave it in it's own folder in /tmp
```
tar xzvf latest.tar.gz -C /tmp/.
```

With that you will have a new /tmp/wordpress folder and all the WordPress files and folders are in there. Now we will create a couple of files that are necessary for WordPress and make a copy of one that WordPress provides a template for.
update files and folders
```
sudo touch /tmp/wordpress/.htaccess
sudo mkdir /tmp/wordpress/wp-content/upgrade
sudo cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
```

Now that we have copied the WordPress wp-config.php template we need to do a bit of setup and configure it to talk to the MySql database that we created previously. For this you will need to know the WordPress database name, and the username and password we created in the previous steps, specifically the ones we used for $WPDBNAME, $WPUSERNAME, and $WPPASSWORD.

Open wp-config.php with a text editor
```
sudo vim /tmp/wordpress/wp-config.php
```
From there we'll begin replacing things, first thing is the MySql database name, $WPDBNAME. Find the line that matches below and replace database_name_here with your MySql WordPress database name (leave the '' ticks).
```
define( 'DB_NAME', 'database_name_here' );
```

Next we'll do the same with the MySql database user we created, $WPUSERNAME. Scroll down wp-config.php and find the matching line and replace username_here with your MySql user
```
define( 'DB_USER' 'username_here' );
```

And we'll do the same with the MySql user password, $WPPASSWORD, we created earlier as well. Find the matching line and replace password_here with the actual password
```
define( 'DB_PASSWORD', 'password_here' );
```

With that done we need to do one more thing for wp-config and that is download the Salts. Salts are what WordPress uses to cryptographically randomize yours and your users passwords when they are stored in memory. For our purposes you will run the command below and then copy the output which we will then paste into our wp-config.php file.
```
curl -s https://api.wordpress.org/secret-key/1.1/salt/
```
With the salt contents copied, we will open up the wp-config.php file one more time in our text editor
```
sudo vim /tmp/wordpress/wp-config.php
```
And then scroll down till you find the following section
```
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
```
Delete these 8 lines and replace them with the salt contents you copied earlier and then save the changes.

Our WordPress files are now ready to be copied to our live location. In the previous step when setting up our Apache VirtuaHost file we defined a DocumentRoot location, that is where you need to copy the WordPress files to. The command should look something like this
```
sudo cp -a /tmp/wordpress/. /var/www/$WPFOLDER
```

Once the files have been copied we need to update them to have the correct permissions. Run the following commands to update the permissions
```
sudo chown -R www-data:www-data /var/www/$WPFOLDER/
sudo chmod -R 755 /var/www/$WPFOLDER/
sudo find /var/www/$WPFOLDER/ -type d -exec chmod 750 {} \;
sudo find /var/www/$WPFOLDER/ -type f -exec chmod 640 {} \;
sudo find /var/www/$WPFOLDER/ -type d -exec chmod g+s {} \;
```

Now you should be able to navigate to your domain and see the WordPress welcome page.


## install wp-cli
```
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
```

Permisisons
```
chmod +x wp-cli.phar
```

Move to proper location
```
mv wp-cli.phar /usr/local/bin/wp
```
