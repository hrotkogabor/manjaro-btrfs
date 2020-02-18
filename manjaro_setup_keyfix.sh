#!/bin/bash
# if there are problems during update with the keys, this script will re-import the keys

sudo rm -fr /etc/pacman.d/gnupg
yes | LC_ALL=en_US.UTF-8 sudo pacman-key --init

if [ $(uname -m) = "i686" ]; then
	yes | LC_ALL=en_US.UTF-8 sudo pacman -S archlinux32-keyring-transition
	#yes | LC_ALL=en_US.UTF-8 sudo pacman -Sy archlinux32-keyring manjaro-keyring
	yes | LC_ALL=en_US.UTF-8 sudo pacman-key --populate archlinux32 manjaro
else
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Sy archlinux-keyring manjaro-keyring
	yes | LC_ALL=en_US.UTF-8 sudo pacman-key --populate archlinux manjaro
fi

yes | LC_ALL=en_US.UTF-8 sudo pacman-key --refresh-keys
yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu

read
