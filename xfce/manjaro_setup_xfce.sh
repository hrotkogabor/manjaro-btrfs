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

source $MY_PATH/../base.sh

#xfce stuff
array=(xfce4-screensaver xfce4-places-plugin xfce4-indicator-plugin)
installPkgs "${array[@]}"

#xfce AUR stuff
yay -aS --sudoloop --noredownload --norebuild --noconfirm xfwm4-themes dockbarx xfce4-dockbarx-plugin multiload-ng-common xfce4-multiload-ng-plugin

echo -e "\nYou can run manjaro_setup_xfce_desktop.sh now."
read