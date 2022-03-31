#!/bin/bash
#install custom AUR stuff

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

# gwenview imageviewer, with imageformats and video thumbnails, image rating will not work with all theme
echo "1" | sudo pacman -S --needed --noconfirm gwenview kio-extras qt5-imageformats kimageformats ffmpegthumbs byobu

yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu vivaldi vivaldi-ffmpeg-codecs

# install some stuff from AUR
export GNUPGHOME=~/aur
yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu youtube-dl-gui-git yad pdfchain caja-pdf-tools hardinfo-gtk3

if [ $(uname -m) = "x86_64" ]; then
	export GNUPGHOME=~/aur; yay -aS --sudoloop --noredownload --noconfirm --noeditmenu gnome-encfs-manager-bin
fi

echo -e "\nInstall custom stuff ready."

read
