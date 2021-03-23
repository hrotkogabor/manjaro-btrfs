#!/bin/bash
# this script will do a snapper rollback, and then upfdate and re-install grub to use the proper snapshot

echo "calling snapper rollback"
sudo snapper --ambit classic rollback

echo "updating and re-installing grub"
p=$(mount | grep ' on / ' | cut -d' ' -f1)
parent=$(lsblk -no pkname $p)

echo "Using $p, and /dev/$parent as parent."

sudo mount $p /mnt

sudo manjaro-chroot /mnt 'mount /usr/local'
sudo manjaro-chroot /mnt '/usr/local/bin/btrfs_grub_install_chroot.sh '$LANG' /dev/'$parent

echo -e "\nGrub updated. You can reboot now to the restored snapshot."
read
