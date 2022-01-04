# Installing Linux Apache Mysql and PHP on a DigitalOcean VPS

This tutorial will walkthrough the process of installing Apache, MySql, and PHP on an Ubuntu 20.04 DigitalOcean Droplet. The server created here will eventually host a WordPress website, I will indicate when settings are specific to WordPress and you can alternate from there if you are doing something different. These directions are for DigitalOcean but should be similar for most VPS providers. Before starting this process you should obtain an [Ubuntu 20.04 droplet](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-ubuntu-20-04-server-on-a-digitalocean-droplet) from DigitalOcean and make sure your [SSH access is working.](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/)

I recommend starting with an Ubuntu 20.04 (LTS) server instead of other versions because the LTS version is the 'Long Term Support' version of Ubuntu, meaning it is supported with at least 5 years of updates. Non-LTS releases are only guaranteed to receive 9 months of updates.

### Apache

By starting out with a Linux (Ubuntu) server from DigitalOcean we already have the 'L' for our 'LAMP' server, now we'll move onto the 'A'. Apache is the most common web server in use with WordPress websites, and the one we'll be using for this tutorial. To begin with we'll need to download and install Apache onto our server. The first step is to make sure you are connected to your webserver [over SSH](https://docs.digitalocean.com/products/droplets/how-to/connect-with-ssh/) or through the ['Droplet Console'](https://docs.digitalocean.com/products/droplets/how-to/connect-with-console/).

Once you are connected to your server, the first thing you should do is check for updates and then run any updates. You will check for updates with the following command:
```
sudo apt update
```
Once that is down checking, we'll run the waiting updates with
```
sudo apt upgrade
```
If you are asked to confirm any updates, just go with 'yes' or whatever default is already checked. Since it is a new server there are no settings we need to worry about preserving.

With the server updated we can get Apache installed. We'll run this command to download it
```
sudo apt install apache2
```

And when once that is completed you can navigate to the IP address of the server in your web browser and should be greeted with the Apache2 Default Page. There is still some work to be done in order to get Apache to properly serve up a webpage. But this is all we need for now, we'll create VirtualHosts and configure it on a later step.

### MySql

Next up for our LAMP is the 'M', MySql. MySql is a Database application that help us organize our content for our future website. There are many Database options, but MySql is the most common for WordPress so that's what we'll use here.

First up is to download the mysql-server app by running
```
sudo apt install mysql-server
```
Once MySql is downloaded we should go through the initial setup. Run this command to have MySql walk you through the initial settings
```
mysql_secure_installation
```

You will be prompted through a series of questions, the first should be if you would like to enforce password strength requirements (I recommend yes). Next you will be prompted to define a 'root' password, make sure you copy this down you will most likely need it in the future. After you set the password you will be asked to remove anonymous users, you should. You should also disallow remote root logins, and finally go ahead and reload the privilege tables when prompted which updates the currently logged in accounts to match the new settings.

After that we'll be done with MySql for now.

### PHP

The final piece of our LAMP server is the 'P', for PHP. PHP is a programming scripting language that WordPress and many other Web applications are built on. Since this tutorial is about getting WordPress installed we'll be installing PHP and some necessary add-ons for WordPress.

```
sudo apt install php php-mysql php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip
```

These are some of the commonly needed PHP extensions. It's possible that you may need other or additional extensions for particular WordPress plugins, make sure to check your documentation.
