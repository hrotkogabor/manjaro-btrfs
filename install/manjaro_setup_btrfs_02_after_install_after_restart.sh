#!/bin/bash
# Run this script after the first boot into the new system, but not as root.
# 

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

# set basic settings and install some base stuff
chmod +x $MY_PATH/manjaro_setup_base.sh
$MY_PATH/manjaro_setup_base.sh


# fix the "sparse file not allowed" error message on startup
sudo sed -i -e 's/GRUB_SAVEDEFAULT=true/#GRUB_SAVEDEFAULT=true/g' /etc/default/grub
echo "GRUB_REMOVE_LINUX_ROOTFLAGS=true" | sudo tee -a /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=10/GRUB_TIMEOUT=2/g' /etc/default/grub
sudo update-grub

# to see snapshot size in snapper list, this will slow down snapshot list
#sudo btrfs quota enable /

yes | LC_ALL=en_US.UTF-8 sudo pacman -S snapper
sudo snapper -c root create-config /
sudo snapper -c root set-config NUMBER_LIMIT=6 NUMBER_LIMIT_IMPORTANT=4

p=`mount | grep ' on / ' | cut -d' ' -f1`

# move snapshots to a separate subvolume
sudo btrfs sub del /.snapshots
sudo mount -o subvolid=0 $p /mnt
sudo btrfs sub create /mnt/@.snapshots
myFstabLine=`grep /home /mnt/@/etc/fstab | grep UUID`
echo "${myFstabLine//home/.snapshots}" | sudo tee -a /mnt/@/etc/fstab
sudo mkdir -p /mnt/@/.snapshots
sudo mount /.snapshots

# skip snapshots from updatedb
sudo sed -i -e 's/PRUNENAMES = "/PRUNENAMES = ".snapshots /g' /etc/updatedb.conf

# install btrfs stuff
yes | LC_ALL=en_US.UTF-8 sudo pacman -S snap-pac grub-btrfs snapper-gui pacaur
sudo sed -i -e 's/#GRUB_BTRFS_SUBMENUNAME="Arch Linux snapshots"/GRUB_BTRFS_SUBMENUNAME="Select snapshot"/g' /etc/default/grub-btrfs/config

# install btrfs stuff from aur
export GNUPGHOME=~/aur; pacaur -aS --noconfirm --noedit snap-pac-grub

# run btrfs read-only check after login
echo '[Desktop Entry]
Type=Application
Encoding=UTF-8
Exec=/usr/local/bin/btrfs_ro_alert.sh
Name=Btrfs read only check
NoDisplay=true
X-GNOME-AutoRestart=true
Terminal=false
X-GNOME-Autostart-Delay=5' | sudo tee /etc/xdg/autostart/btrfs-ro-alert.desktop

echo -e "\nBtrfs with snapper and grub ready."
read