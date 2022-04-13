#!/bin/bash
# install some stuff for development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

#install default stuff
yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu git gpa tk

#install dev AUR stuff
yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu gstm 

read
