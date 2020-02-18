#!/bin/bash
# enable AUR and set AUR auto download key for the current user

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

#enable AUR
if grep -q "#EnableAUR" /etc/pamac.conf; then
  sudo sed -i -e 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf
  #enable color
  sudo sed -i -e 's/#Color/Color/g' /etc/pacman.conf
fi

# set AUR auto download key
mkdir ~/aur
echo "keyserver-options auto-key-retrieve" > ~/aur/gpg.conf
