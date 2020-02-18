#!/bin/bash
# for virtualbox guest

sudo pacman -Syyuu --noconfirm linux-latest-virtualbox-guest-modules
sudo pacman -Syyuu --noconfirm virtualbox-guest-utils

sudo sed -i -e 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1280x1024x32/g' /etc/default/grub

sudo update-grub
read
