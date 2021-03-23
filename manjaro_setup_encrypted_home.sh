#!/bin/bash
# this script set the ecryptfs pam moduls, and encrypt a home dir if the user has no running processes
# https://wiki.archlinux.org/index.php/ECryptfs#Encrypting_a_home_directory

sudo modprobe ecryptfs

if [ $(grep pam_ecryptfs /etc/pam.d/system-auth | wc -l) = "0" ]; then

  sudo sed -i '/^auth\s*\[default=die\]\s*pam_faillock.so\s*authfail/a auth [success=1 default=ignore] pam_succeed_if.so service = systemd-user quiet\nauth    required    pam_ecryptfs.so unwrap' /etc/pam.d/system-auth
  sudo sed -i '/^-password\s*\[success=1\s*default=ignore\]\s*pam_systemd_home.so/i password    optional    pam_ecryptfs.so' /etc/pam.d/system-auth
  sudo sed -i '/^session\s*required\s*pam_unix.so/a session [success=1 default=ignore] pam_succeed_if.so service = systemd-user quiet\nsession    optional    pam_ecryptfs.so unwrap' /etc/pam.d/system-auth
fi

list=`grep /bin/bash /etc/passwd | cut -d: -f1 | grep -v root`

echo "Please select a user to encrypt home!"

select s in $list
do
p=$(echo $s  | cut -d: -f1)
if [ -z "$p" ]
then
  echo "Please select a user!"
  exit 0
fi
break
done

echo "Using $p"

if [ -d /home/.ecryptfs/$p ]; then
    echo "User "$p"'s home directory already encrypted!"
else 

    if [ $(ps -U $p | wc -l) != "1" ]; then
        echo "User "$p" has running processes! Log out, or restart system!"
    else
        sudo ecryptfs-migrate-home -u $p
    fi
fi

read
