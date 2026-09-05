#!/bin/bash
# install some stuff for development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

source base.sh

#install default stuff
array=(git tk jq bind pkgfile)

installPkgs "${array[@]}"

#install dev AUR stuff
yay -aS --sudoloop --noredownload --norebuild --noconfirm gstm gpgfrontend

read
