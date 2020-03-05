#!/bin/bash
# this script will update and re-install grub
# it should be run in the chroot to the default subvolume
# two parameters are required:
# $1 : LANG variable of the host
# $2 : device to install grub on, e.g.: /dev/sda
# https://bbs.archlinux.org/viewtopic.php?pid=1615373
# Normally this script is called by the rollback script.

if [ -z $1 ]
then
  echo "First parameter LANG is required! e.g. hu_HU.UTF-8"
  exit 0
fi

if [ -z $1 ]
then
  echo "Second parameter DEVICE is required! e.g. /dev/sda"
  exit 0
fi


export LANG=$1                                                                                                                                                                    
mount /.snapshots
update-grub                                                                                                                                                                       
grub-install $2
read
