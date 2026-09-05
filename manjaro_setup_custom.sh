#!/bin/bash
#install custom AUR stuff

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

source base.sh

array=(hardinfo2 ffmpegthumbs pdfarranger vivaldi vivaldi-ffmpeg-codecs)

installPkgs "${array[@]}"

# install some stuff from AUR
export GNUPGHOME=~/aur
yay -aS --sudoloop --noredownload --norebuild --noconfirm vido xnviewmp byobu

echo -e "\nInstall custom stuff ready."

read
