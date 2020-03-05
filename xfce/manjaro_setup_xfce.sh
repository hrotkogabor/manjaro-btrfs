#!/bin/bash
# install some xfce related package

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

 

if [ $(uname -m) = "i686" ]; then
	#xfce stuff
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu manjaro-xfce-gtk3-settings xfwm4-themes xfce4-indicator-plugin-gtk3-git xfce4-screensaver dockbarx xfce4-dockbarx-plugin
	
	#xfce AUR stuff
	pacaur -aS --noconfirm --noedit multiload-ng-systray-gtk3
else
	#xfce stuff
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu manjaro-xfce-gtk3-settings xfwm4-themes xfce4-indicator-plugin-gtk3-git xfce4-screensaver
	
	#xfce AUR stuff
	pacaur -aS --noconfirm --noedit dockbarx xfce4-dockbarx-plugin multiload-ng-systray-gtk3 xfce4-places-plugin
fi

echo -e "\nYou can run manjaro_setup_xfce_desktop.sh now."
read