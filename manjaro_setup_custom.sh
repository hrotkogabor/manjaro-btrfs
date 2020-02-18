#!/bin/bash
#install custom AUR stuff

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

pacaur -aS --noconfirm --noedit vivaldi

read
