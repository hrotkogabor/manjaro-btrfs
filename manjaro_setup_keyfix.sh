#!/bin/bash
# if there are problems during update with the keys, this script will re-import the keys

# remove partially downloaded files from cache
rm /var/cache/pacman/pkg/*.part

sudo rm -fr /etc/pacman.d/gnupg
yes | LC_ALL=en_US.UTF-8 sudo pacman-key --init

if [ $(uname -m) = "i686" ]; then
	#yes | LC_ALL=en_US.UTF-8 sudo pacman -Sy archlinux32-keyring manjaro-keyring
	yes | LC_ALL=en_US.UTF-8 sudo pacman-key --populate archlinux32 manjaro
	yes | LC_ALL=en_US.UTF-8 sudo pacman -S archlinux32-keyring-transition
else
	yes | LC_ALL=en_US.UTF-8 sudo pacman-key --populate archlinux manjaro
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Sy archlinux-keyring manjaro-keyring
fi

yes | LC_ALL=en_US.UTF-8 sudo pacman-key --refresh-keys

# alternativly
#yes | LC_ALL=en_US.UTF-8 sudo pacman-key --keyserver hkps://sks.pod02.fleetstreetops.com --refresh-keys

yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu --needed --noconfirm

read
