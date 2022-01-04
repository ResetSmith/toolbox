#! /bin/bash

#####################################################################
# User account creation script
#####################################################################
#
#################################################
# Dependent Functions
#################################################
#
# defines 'pause' function which pauses script waiting for [enter] key to be pressed
# will display text inlcuded in the quotes
function pause () {
    read -rp "$*"
}
#
#################################################
#
clear
echo -e "\nThis script will assist with the creation of new users for Ubuntu servers. It creates the user, creates and allows you to input the user's SSH public keu, and can add them to the Sudo group if you wish. First you will be asked to create a temporary password for the user. This password is a temporary Sudo password that the user will be asked to update on their first login. Once you've setup the temporary password you will create a user name and be given the option to add them to the Sudo group. After that you will be prompted to input the public SSH key for the user, right now the SSH key prompt is set up for the key to be copy and pasted into the prompt." | fmt -w 70
#
pause '
Please press [Enter] to proceed.'
#
clear
#
echo -e "\nDefine a temporary Sudo password for the user. On their first login the user will be prompted for their SSH key password, and then prompted for this temporary Sudo password and asked to update it afterwards. You should define this password for both Sudo and non Sudo users.\n" | fmt -w 70
read -r TEMP_PASS # left off -s tag for end user simplicity for a temporary password
#
clear
echo -e "Will this user be added to the Sudo users list [y/n]?"
read -n 1 -r REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
  then
#################################################
# Creates Sudo user
#################################################
  clear
  echo "Please input a user name for the new sudo user:"
  read -r USERNAME
  clear
  echo "Please paste the user's SSH public key here, id_rsa.pub contents:"
  read -r PUBKEY
  #
  clear
  echo -e "\nThis script will now create a new Sudo user with username:  $USERNAME"
  sleep 1
  echo -e "The user will be assigned a temporary password:  $TEMP_PASS"
  sleep 1
  echo -e "The user will connect via SSH with the following public key:  $PUBKEY"
  sleep 4
  pause '
  If you need to restart this process and make corrections, press [Ctrl+C] to exit.
  If everything looks correct, press [Enter] to proceed.'
  # creates user, adds to sudo group, updates folder permissions, and
  # sets a temporary password for the user
  mkdir -p /home/"$USERNAME"/.ssh
  touch /home/"$USERNAME"/.ssh/authorized_keys
  useradd -d /home/"$USERNAME" "$USERNAME"
  usermod -aG sudo "$USERNAME"
  chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"
  chmod 700 /home/"$USERNAME"/.ssh
  chmod 644 /home/"$USERNAME"/.ssh/authorized_keys
  echo "$USERNAME":"$TEMP_PASS" | chpasswd
  passwd -e "$USERNAME"
  # customizes prompt for color and sets default shell to bash
  touch /home/"$USERNAME"/.bashrc
  cat << EOF >> /home/"$USERNAME"/.bashrc
# custom bash prompt
# shows username followed by server hostname and the current server time
# moves working prompt to line below the username and shows the current active folder
# the server hostname will show in green
export PS1="\u @\[$(tput sgr0)\]\[\033[38;5;10m\]\H\[$(tput sgr0)\] \A\n[\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]] \\$ \[$(tput sgr0)\]"
#
EOF
  chmod 644 /home/"$USERNAME"/.bashrc
  touch /home/"$USERNAME"/.bash_profile
  cat << EOF >> /home/"$USERNAME"/.bash_profile
# tells profile to check for .bashrc
[ -f "/home/$USERNAME/.bashrc" ] && source "/home/$USERNAME/.bashrc"
EOF
  chmod 644 /home/"$USERNAME"/.bash_profile
  usermod -s /bin/bash "$USERNAME"
  #
  cat <<< "$PUBKEY" > /home/"$USERNAME"/.ssh/authorized_keys
  #
  unset REPLY
  unset USERNAME
  unset PUBKEY
  clear
#################################################
#
else
#################################################
# Creates non Sudo users
#################################################
  clear
  echo "Please input a user name for the new user:"
  read -r USERNAME
  clear
  echo "Please paste the user's public SSH key here, id_rsa.pub contents:"
  read -r PUBKEY
  #
  clear
  echo -e "\nThis script will now create a new user with username:  $USERNAME"
  sleep 1
  echo -e "The user will be assigned a temporary password:  $TEMP_PASS"
  sleep 1
  echo -e "The user will connect via SSH with the following public key:  $PUBKEY"
  sleep 4
  pause '
  If you need to restart this process and make corrections, press [Ctrl+C] to exit.
  If everything looks correct, press [Enter] to proceed.'
  # creates user, adds to sudo group, updates folder permissions, and
  # sets a temporary password for the user
  mkdir -p /home/"$USERNAME"/.ssh
  touch /home/"$USERNAME"/.ssh/authorized_keys
  useradd -d /home/"$USERNAME" "$USERNAME"
  chown -R "$USERNAME":"$USERNAME" /home/"$USERNAME"
  chmod 700 /home/"$USERNAME"/.ssh
  chmod 644 /home/"$USERNAME"/.ssh/authorized_keys
  echo "$USERNAME":"$TEMP_PASS" | chpasswd
  passwd -e "$USERNAME"
  # customizes prompt for color and sets default shell to bash
  touch /home/"$USERNAME"/.bashrc
  cat << EOF >> /home/"$USERNAME"/.bashrc
# custom bash prompt
# shows username followed by server hostname and the current server time
# moves working prompt to line below the username and shows the current active folder
# the server hostname will show in green
export PS1="\u @\[$(tput sgr0)\]\[\033[38;5;10m\]\H\[$(tput sgr0)\] \A\n[\[$(tput sgr0)\]\[\033[38;5;10m\]\w\[$(tput sgr0)\]] \\$ \[$(tput sgr0)\]"
#
EOF
  chmod 644 /home/"$USERNAME"/.bashrc
  touch /home/"$USERNAME"/.bash_profile
  cat << EOF >> /home/"$USERNAME"/.bash_profile
# tells profile to check for .bashrc
[ -f "/home/$USERNAME/.bashrc" ] && source "/home/$USERNAME/.bashrc"
EOF
  chmod 644 /home/"$USERNAME"/.bash_profile
  usermod -s /bin/bash "$USERNAME"
  #
  cat <<< "$PUBKEY" > /home/"$USERNAME"/.ssh/authorized_keys
  #
  unset REPLY
  unset USERNAME
  unset PUBKEY
  clear
#################################################
#
fi
