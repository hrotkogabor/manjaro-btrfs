#!/bin/bash
# install some stuff for development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

# Aero45
rm -f /tmp/aero45-for-gtk3-and-gtk4-main.tar.gz
wget https://gitlab.com/hrotkogabor/aero45-for-gtk3-and-gtk4/-/archive/main/aero45-for-gtk3-and-gtk4-main.tar.gz -O /tmp/aero45-for-gtk3-and-gtk4-main.tar.gz
rm -f /tmp/aero45-for-gtk3-and-gtk4-main
tar -zxvf /tmp/aero45-for-gtk3-and-gtk4-main.tar.gz -C /tmp
sudo rm -frd /usr/share/themes/Aero45
sudo mv /tmp/aero45-for-gtk3-and-gtk4-main /usr/share/themes/Aero45

#Win10OS-cursors
sudo rm -frd /usr/share/icons/Win10OS-cursors
sudo tar -zxvf $MY_PATH/data/Win10OS-cursors.tar.gz -C /usr/share/icons

#install from AUR
yay -aS --sudoloop --noredownload --norebuild --noconfirm themechanger

echo -e "\nYou can now change theme with themechanger."

read
