# Configuring LAMP server for WordPress

Now that there is a LAMP server setup we need to configure Apache, Mysql, and PHP for WordPress. For these steps it's best if you already have a web address registered (www.google.com, casat.org, etc...) and DNS already setup to point to the correct server. From here on the web address will be referred to as the FQDN (fully qualified domain name).

### Configuring MySql for Wordpress

The first thing we will do is setup a MySql database and a user for WordPress to access the database from. For this particular section you will be providing 3 variables, $WPDBNAME is the name for the WordPress database we'll be creating, I like them to reference the website to keep it simple (something like wp_google), $WPUSERNAME is the name for the user that WordPress uses to interact with the database and again I typically reference the FQDN to keep it simple (ex: user_google), last you will need to come up with a password for that user account it will be referred to as $WPPASSWORD. When you see one of these variables in the commands you should replace it with the correct information.

Connect to your server via SSH or the Droplet Console, and then connect to the MySql app by typing in
```
sudo mysql -u root
```
If you are prompted for a password, it is looking for your Ubuntu 'Sudo' password.

Now we'll create the database that WordPress will store all of your website data and users. Make sure to replace $WPDBNAME with an appropriate name for your WordPress website database.
```
CREATE DATABASE $WPDBNAME DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```
This will create a database in MySql named '$WPDBNAME' and then set the Character Set and Collate options to utf8 which is what WordPress needs.

Then we will create a user that WordPress can use to access the database. For this command you will need to replace the variables $WPUSERNAME and $WPPASSWORD with a Username and Password respectively. Make sure to copy down what the Username and Password are as they will be used later in the WordPress installation.
```
CREATE USER '$WPUSERNAME'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WPPASSWORD';
```
This creates a user named $WPUSERNAME and only allows that account to connect to the database Locally, which prevents someone from connecting to the database remotely using that account. It then sets the user's password to $WPPASSWORD. The mysql_native_password modifier tells MySql to create the user with the older, less secure, password hashing format that is necessary for WordPress as of right now.

Next we will grant permission for the user account we just made to access the database. For this you will need the database name you created, and the username.
```
GRANT ALL ON $WPDBNAME.* TO '$WPUSERNAME'@'localhost';
```

For the final MySql steps we will reset the user permissions and then exit the MySql interface and return to the Ubuntu terminal using the following commands
```
FLUSH PRIVILEGES;
EXIT;
```
Now you should be back in the regular Ubuntu terminal. Next we'll fix our PHP installation to serve up WordPress content.

### Apache configuration for WordPress

In order to configure Apache for WordPress we will create a new VirtualHost file, enable that VirtualHost, check our Apache setup for errors and then enable the new Apache configuration.

First thing is to create a new VirtualHost file for the website. The file can be named whatever you want it to be, as long as it ends with the .conf suffix. I prefer to use the name of the website to keep it simple. In this example replace the $VHOSTNAME variable with your website (ie: google.conf, digitalocean.conf)
```
sudo touch /etc/apache2/sites-available/$VHOSTNAME.conf
```

Next we will fill the content of the VirtualHost file by opening it with a text editor. Personally I like to use vim, but nano works just as well if that's what you are familar with. Use this command to open the VirtualHost file, replace vim with the text editor of choice if you'd like to use something different, and $VHOSTNAME with the name of the file you just created.
```
sudo vim /etc/apache2/sites-available/$VHOSTNAME.conf
```

Now we will create the VirtualHost content. I'm including a very basic VirtualHost example below that can be copy and pasted. However there are several variables that need to be edited to work with your respective website. In the top section the variable $ADMIN_EMAIL should be replaced with an active email address. The $DOMAIN_NAME variable should be replaced with your domain name (ie: google.com).

**Note** *In my example the website is being setup for non-www, if you would prefer your site to be www then you should put www.$DOMAIN_NAME in the ServerName field and the non-www in the ServerAlias field.*

The other variable you need to define is $WPFOLDER. This folder does not exist yet, we will create it later when we do our actual WordPress installation. Typically I name this folder the same as my website which helps keeps things straight if you will eventually host multiple sites from the same server. If this is not a concern for you, you can just name this folder wordpress. Whatever you choose make sure you remember what it is, as we will need to reference it later.
```
<VirtualHost *:80>
ServerAdmin  $ADMIN_EMAIL
ServerName   $DOMAIN_NAME
ServerAlias  www.$DOMAIN_NAME
DocumentRoot /var/www/$WPFOLDER

 <Directory /var/www/$WPFOLDER/>
  Options FollowSymLinks
  AllowOverride All
  Require all granted
 </Directory>

ErrorLog  ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```

Once we have our VirtualHost file created we need to tell Apache to enable that VirtualHost.
```
sudo a2ensite $VHOSTNAME.conf
```

Then we need to disable the default VirtualHost file that Apache comes with.
```
sudo a2dissite 000-default.conf
```

Before proceeding further you can check the syntax of your Apache Virtualhost file by running this command. If you receive any errors you will need to correct them before moving on.
```
sudo apache2ctl configtest
```

You will get a warning that the current DocumentRoot folder does not exist. That is correct, we will create that folder in a later step. Now we will enable the rewrite module in Apache that is required for WordPress.
```
sudo a2enmod rewrite
```

And finally we will restart Apache to apply the new settings.
```
sudo systemctl restart apache2
```

At this point we are now ready to install WordPress.
