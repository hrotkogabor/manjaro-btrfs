#!/bin/bash
# install some xfce related package

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

# copy login/logout sound play
sudo cp $MY_PATH/*.desktop /etc/xdg/autostart

if [ $(uname -m) = "i686" ]; then
        # 32 bit

	#xfce stuff
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu manjaro-xfce-gtk3-settings xfwm4-themes xfce4-indicator-plugin-gtk3-git xfce4-screensaver dockbarx xfce4-dockbarx-plugin
	
	#xfce AUR stuff
	yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu multiload-ng-systray-gtk3
else
	#xfce stuff
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu manjaro-xfce-settings xfwm4-themes xfce4-screensaver
	
	#xfce AUR stuff
	yay -aS --sudoloop --noredownload --norebuild --noconfirm --noeditmenu dockbarx xfce4-dockbarx-plugin multiload-ng-systray-gtk3 xfce4-places-plugin xfce4-indicator-plugin
fi

echo -e "\nYou can run manjaro_setup_xfce_desktop.sh now."
read