#!/bin/bash
# Run this script after the first boot into the new system, but not as root.
# 

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


# call second stage setup
chmod +x $MY_PATH/script/stage_2_setup.sh
sudo $MY_PATH/script/stage_2_setup.sh

mkdir -p ~/aur
export GNUPGHOME=~/aur
yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu snap-pac-grub

echo -e "\nBtrfs with snapper and grub ready. You should restart."
read
