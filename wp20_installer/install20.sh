#! /bin/bash
set -euo pipefail
clear
#
# defines 'pause' function which pauses script waiting for [enter] key to be pressed
# will display text inlcuded in the quotes
function pause () {
    read -rp "$*"
}
#
###################################################################
# User interactive section
# Asks questions to guide installation
###################################################################
#
echo "
This script was created to automate the installation and configuration of WordPress
sites. It will ask a few questions and then use that information to download, install,
and configure MySql, Apache2, PHP, WordPress, and CertBot. It will also configure
the system files for the website based on security recommendations from the federal
government's Security Technical implementation Guide (STIG). If there are errors during
the install process log files can be found in /var/log/wp-install/.
At any time during this installation, press [ctrl-c] to immediately stop."
#
pause '

Please press [enter] to proceed.'
#
clear
echo "
Please input the 'Fully Qualified Domain Name' (FQDN) for the new site. The
FQDN is the complete domain name and suffix, ie: 'casat.org'. At this time the
script does not support domains beginning with www."
# 'checker' and 'flag' variables are used to check inputs for spaces
CHECKER="[[:space:]]+"
FLAG=1
while [ ${FLAG} -eq 1 ];
do
  echo  "
  What is the FQDN of this site?"
  read -r FQDN
  if [[ "${FQDN}" =~ $CHECKER ]];
    then
    echo ""
    echo "The FQDN cannot contain spaces. Please re-enter a valid site name."
    echo ""
  else
    sleep 2
    FLAG=0
    clear
  fi
done

echo "
Please input a password for the MySql database root user. The root user is the
maintenance account for the database. This is similar to an admin account."
FLAG=1
while [ ${FLAG} -eq 1 ];
do
  echo  "
  What should the database root password be?"
  read -r SQLPASS
  if [[ "${SQLPASS}" =~ $CHECKER ]];
    then
    echo ""
    echo "The Password cannot contain spaces. Please re-enter a valid Password."
    echo ""
  else
    sleep 2
    FLAG=0
    clear
  fi
done

echo "
Please input a password for the Wordpress MySql user. This password is for the
user that wordpress uses to write to the database and edit the site. It should
be different from the root user password. The Wordpress username will be auto
generated based on the website name."
FLAG=1
while [ ${FLAG} -eq 1 ];
do
  echo  "
  What should the Wordpress User password be?"
  read -r WPPASSWORD
  if [[ "${WPPASSWORD}" =~ $CHECKER ]];
    then
    echo ""
    echo "The Password cannot contain spaces. Please re-enter a valid Password."
    echo ""
  else
    sleep 2
    FLAG=0
    clear
  fi
done
#
###################################################################
# takes FQDN and removes the suffix to create the hostname
# removes the last 4 characters from the FQDN
# this willnot work if suffix is longer than .com/.org etc...
HOSTNAME=$(sed 's/....$//' <<< "$FQDN")
# generates the wordpress database and user names
# capitalizes the hostname variable
WPHOSTNAME="wp_${HOSTNAME,,}"
WPUSERNAME="user_${HOSTNAME,,}"
###################################################################
#
echo "This script will create a Wordpress site using the following information.
Be sure to review these fields before continuing."

echo "
The FQDN (site address) will be:
$FQDN"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""

echo "
The Hostname will be:
$HOSTNAME"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""

echo "
The MySql Wordpress database will be:
$WPHOSTNAME"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""

echo "
The MySql root user password will be:
$SQLPASS"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""

echo "
The MySql Wordpress user will be:
$WPUSERNAME"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""

echo "
The MySql Wordpress user password will be:
$WPPASSWORD"
echo -ne ".\r"
sleep .5
echo -ne "..\r"
sleep .5
echo -ne "...\r"
sleep .5
echo ""
# calls the pause function
pause '

Copy this information down before proceeding.
Press [Enter] key to continue with the installation.
Or press [Ctrl-C] to stop the installation.'

clear

#
###################################################################
# begin installation section
###################################################################
#
echo "Installing the dependencies needed for this script"
echo -ne ".\r"
sleep 1
echo -ne "..\r"
sleep 1
echo -ne "...\r"
sleep 1
echo -ne "....\r"
sleep 1
echo -ne ".....\r\n"
# sets up the updates to be done unattended
# set back to default at end of script
export DEBIAN_FRONTEND=noninteractive
# checks for log folder and creates one if it doesn't already exist
if [ ! -d /var/log/wp-install ]; then
    mkdir -p /var/log/wp-install
fi
# checks for updates
apt-get -y update
# installs 'pv' to act as progress bar during installation
apt-get -y install pv
#
clear
#
echo "Running Installation Scripts for WordPress and Site Configuration"
sleep 5
#
###################################################################
# script loading section
###################################################################
#
# Amends a line to the logfile to make it easier to read
echo -e "\n\n\n----------Server Updates----------\n" >> /var/log/wp-install/install.log
# Adds line to screen to label the loading bar
echo -e "\n00 Server Updates and Settings"
# Runs script file while using pv to draw loading bar, saves any output to logfile
while source ./scripts/00_settings.sh; do echo "server"; sleep 1; done|pv -N Server_Updates >> /var/log/wp-install/install.log
# Pauses before moving onto next section
sleep 5
#
echo -e "\n\n\n----------MySql Installation----------\n" >> /var/log/wp-install/install.log
echo -e "\n01 MySql Installation"
while source ./scripts/01_mysql.sh; do echo "mysql"; sleep 1; done|pv -N MySql_Install >> /var/log/wp-install/install.log
sleep 5
#
echo -e "\n\n\n----------Apache Installation----------\n" >> /var/log/wp-install/install.log
echo -e "\n02 Apache2 Installation"
while source ./scripts/02_apache.sh; do echo "apache"; sleep 1; done|pv -N Apache_Install >> /var/log/wp-install/install.log
sleep 5
#
echo -e "\n\n\n----------PHP Installation----------\n" >> /var/log/wp-install/install.log
echo -e "\n03 PHP Installation"
while source ./scripts/03_php.sh; do echo "php"; sleep 1; done|pv -N PHP_Install >> /var/log/wp-install/install.log
sleep 5
#
echo -e "\n\n\n----------WordPress Installation----------\n" >> /var/log/wp-install/install.log
echo -e "\n04 WordPress Installation"
while source ./scripts/04_wordpress.sh; do echo "wordpress"; sleep 1; done|pv -N WordPress_Install >> /var/log/wp-install/install.log
sleep 5
#
echo -e "\n\n\n----------Fail2Ban Installation----------\n" >> /var/log/wp-install/install.log
echo -e "\n05 Fail2Ban Installation"
while source ./scripts/05_fail2ban.sh; do echo "fail2ban"; sleep 1; done|pv -N Fail2Ban_Install >> /var/log/wp-install/install.log
sleep 5
#
echo -e "\n\n\n----------Firewall Settings and Service Restarts----------\n" >> /var/log/wp-install/install.log
echo -e "\n06 Settings and Restarts"
while source ./scripts/06_cleanup.sh; do echo "settings"; sleep 1; done|pv -N Settings_Install >> /var/log/wp-install/install.log
sleep 5
#
# changes interactive updates back to default
unset DEBIAN_FRONTEND
#
# calls pause function to wait for [enter] to continue to reboot
pause '

Installation has completed. After the reboot you will no longer be able to
connect over ssh as root. You will need to use one of the logins setup during
the install process.
Please press [enter] to continue.'

echo -e "\nInstallation has completed. Server will reboot in 25 seconds."
echo -ne '[.........................]\r'
sleep 5
echo -ne '[#####....................]\r'
sleep 5
echo -ne '[##########...............]\r'
sleep 5
echo -ne '[###############..........]\r'
sleep 5
echo -ne '[####################.....]\r'
sleep 5
echo -ne '[#########################]\r'
sleep 2
echo -e "\nGood Bye"
#
reboot

###################################################################
# NOTE SECTION
###################################################################
#
