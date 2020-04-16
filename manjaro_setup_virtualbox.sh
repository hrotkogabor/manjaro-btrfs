#!/bin/bash
# for virtualbox guest

sudo pacman -Syyuu --noconfirm --needed linux-latest-virtualbox-guest-modules
sudo pacman -Syyuu --noconfirm --needed virtualbox-guest-utils

sudo sed -i -e 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=1280x1024x32/g' /etc/default/grub

sudo update-grub

echo -e "\nVirtualbox install ready."

read
