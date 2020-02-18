#!/bin/bash
# install some stuff for development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

#install default stuff
yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu git gpa 

#install dev AUR stuff
pacaur -aS --noconfirm --noedit gstm 

read
