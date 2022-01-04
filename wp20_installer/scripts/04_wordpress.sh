#! /bin/bash
exec 2> /var/log/wp-install/04.log

###################################################################
# WordPress Installation Script
###################################################################
#
# Downloads wordpress into /tmp folder
cd /tmp && { curl -O https://wordpress.org/latest.tar.gz ; cd - || exit; } > /dev/null
# Unzips wordpress download into /tmp folder
tar xzvf /tmp/latest.tar.gz -C /tmp/.
# Creates .htaccess file for wordpress
touch /tmp/wordpress/.htaccess
#
# Defines .htaccess file
cat << EOF >> /tmp/wordpress/.htaccess
# BEGIN WordPress
# The directives (lines) between `BEGIN WordPress` and `END WordPress` are
# dynamically generated, and should only be modified via WordPress filters.
# Any changes to the directives between these markers will be overwritten.
#
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress

## BEGIN Custom PHP values
php_value upload_max_filesize 64M
php_value post_max_size 128M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300
## END Custom PHP values
EOF
#
# copies 'salts' for Wordpress encryption
# needed for wp-config.php
WPSALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
#
# creates the wp-config.php file
touch /tmp/wordpress/wp-config.php
# contents of wp-config.php
cat << EOF >> /tmp/wordpress/wp-config.php
<?php

// ** MySQL settings ** //
/** The name of the database for WordPress */
define( 'DB_NAME', '$WPHOSTNAME' );

/** MySQL database username */
define( 'DB_USER', '$WPUSERNAME' );

/** MySQL database password */
define( 'DB_PASSWORD', '$WPPASSWORD' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/** Update PHP memory limits for Wordpress */
define( 'WP_MEMORY_LIMIT', '256M' );

/** FS_METHOD forces the filesystem method. It should only be "direct", "ssh2",
* "ftpext", or "ftpsockets". Generally, you should only change this if you are
* experiencing update problems. If you change it and it doesn't help, change
* it back/remove it. Under most circumstances, setting it to 'ftpsockets' will
* work if the automatically chosen method does not.
* (Primary Preference) "direct" forces it to use Direct File I/O requests
* from within PHP, this is fraught with opening up security issues on poorly
* configured hosts, This is chosen automatically when appropriate. */
define( 'FS_METHOD', 'direct' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */

$WPSALT

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */

\$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */

define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

/** Sets up WordPress vars and included files. */
require_once( ABSPATH . 'wp-settings.php' );

EOF
#
# makes folder to host the wordpress files
mkdir /var/www/"$HOSTNAME"
# Creates needed folders and then moves everything to correct location
mkdir /tmp/wordpress/wp-content/upgrade
cp -a /tmp/wordpress/. /var/www/"$HOSTNAME"
#
# Updates ownerhip of folders
chown -R www-data:www-data /var/www/"$HOSTNAME"/
chmod -R 755 /var/www/"$HOSTNAME"/
find /var/www/"$HOSTNAME"/ -type d -exec chmod 750 {} \;
find /var/www/"$HOSTNAME"/ -type f -exec chmod 640 {} \;
find /var/www/"$HOSTNAME"/ -type d -exec chmod g+s {} \;
#
###################################################################
# Installs WP CLI Tool
###################################################################
# moves to tmp folder, downloads app, makes it executable and moves to PATH
cd /tmp || exit
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
cd - || exit
#
exit
