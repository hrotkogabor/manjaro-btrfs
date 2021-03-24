#!/bin/bash
#install stuff for the kids

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu gcompris-qt gbrainy gnome-mines gnome-nibbles gnome-mahjongg gnome-sudoku gnome-taquin five-or-more palapeli ktuberling aisleriot frozen-bubble pingus xorg-fonts-misc ltris

# supertuxkart > 600MB!
# supertux > 200MB!
# extremetuxracer > 400MB!
# hedgewars > 180MB
yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu supertux supertuxkart extremetuxracer hedgewars

# tuxmath is out cos gcc9 dep
yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu lbreakouthd blockout2 xbill brainparty colorcode pinball freegemas

# jag:
# link : https://mirror.amdmi3.ru/distfiles/jag-0.3.2-data.zip https://mirror.amdmi3.ru/distfiles/jag-0.3.2-src.zip

echo -e "\nInstall for kids ready."

read
