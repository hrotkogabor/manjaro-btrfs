#!/bin/bash
# Run this script after install, but before starting the installed system!!
# Otherwise it should be run within livecd.

# get the partitions by fstype
list=`blkid -t TYPE="btrfs"`

if [ -z "$list" ]
then
  echo "No btrfs partition found!"
  exit 0
fi

IFS=$'\n'

# count btrfs partitions
wc=$(echo "$list" | wc -l)

if [ $wc -eq "1" ]
then
	# use the one found
	p=$(echo $list | cut -d: -f1)
else
	# let the user choose
	echo "Please select the btrfs root partition!"
	
	select s in $list
	do
	p=$(echo $s | cut -d: -f1)
	if [ -z "$p" ]
	then
	  echo "Please choose a partition!"
	  exit 0
	fi
	break
	done	
fi

echo "Using $p"

sudo mount -o compress=lzo $p /mnt

# do the compressions
echo -e "\ncompressing files please wait"
sudo btrfs filesystem defragment -r -clzo /mnt/@
sudo btrfs filesystem defragment -r -clzo /mnt/@home
echo -e "compression done\n"

if ! grep -q compress /mnt/@/etc/fstab; then
	sudo sed -i -e 's/autodefrag/autodefrag,compress=lzo/g' /mnt/@/etc/fstab
fi

sudo sed -i -e 's/subvol=@,//g' /mnt/@/etc/fstab


# set default subvolume
sudo btrfs sub set-default `sudo btrfs sub list /mnt | grep 'path @$' | awk '{print $2}'` /mnt

myFstabLine=`grep /home /mnt/@/etc/fstab | grep UUID`



# create subvolume, and move existing data

# /var
sudo btrfs sub create /mnt/@var
sudo rsync -azh /mnt/@/var/ /mnt/@var/
sudo rm -rf /mnt/@/var/*
echo "${myFstabLine//home/var}" | sudo tee -a /mnt/@/etc/fstab

# move pacman db to /usr/var/pacman
sudo mkdir -p /mnt/@/usr/var/pacman
sudo rsync -azh /mnt/@var/lib/pacman/ /mnt/@/usr/var/pacman/
sudo rm -r /mnt/@var/lib/pacman
sudo sed -i -e 's/#DBPath *= \/var\/lib\/pacman\//#DBPath = \/var\/lib\/pacman\/\nDBPath = \/usr\/var\/pacman\//g' /mnt/@/etc/pacman.conf

# /usr/local
sudo mkdir /mnt/@usr
sudo btrfs sub create /mnt/@usr/local
sudo rsync -azh /mnt/@/usr/local/ /mnt/@usr/local/
sudo rm -rf /mnt/@/usr/local/*
echo "${myFstabLine//home/usr\/local}" | sudo tee -a /mnt/@/etc/fstab

sudo mkdir -p /mnt/@usr/local/bin


# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi


# copy these scripts to /usr/local/bin
sudo cp $MY_PATH/usr/*.sh /mnt/@usr/local/bin
sudo chmod +x /mnt/@usr/local/bin/*.sh

sudo umount /mnt

echo -e "\n"
echo -e "\033[5m!!\033[0m"
echo -e "\033[1mReboot to the installed system, and run manjaro_setup_btrfs_02_after_install_after_restart.sh\033[0m"
echo -e "\033[5m!!\033[0m"
read

