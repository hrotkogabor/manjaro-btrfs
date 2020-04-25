#!/bin/bash
# This is the fix for catfish, to resolve the conflict with zeitgeist
# https://bugzilla.xfce.org/show_bug.cgi?id=16419
# 

# download older catfish
sudo wget https://archive.archlinux.org/packages/c/catfish/catfish-1.4.13-1-any.pkg.tar.zst -O /tmp/catfish-1.4.13-1-any.pkg.tar.zst
#install local package
yes | LC_ALL=en_US.UTF-8 sudo pacman -U /tmp/catfish-1.4.13-1-any.pkg.tar.zst
# ignore
sudo sed -i 's/#IgnorePkg\s*=/IgnorePkg = catfish/' /etc/pacman.conf
# apply patch

# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

sudo patch /usr/lib/python3.8/site-packages/catfish/CatfishSearchEngine.py $MY_PATH/catfish_16419.patch
