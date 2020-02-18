#!/bin/bash
# Basic system setup, tipycally executed after an install.

if [ $(id -u) = "0" ]; then
    echo "Do not run this as root!"
    exit 0
fi

# sync time
# https://dev.to/setevoy/arch-linux-key-could-not-be-imported-required-key-missing-from-keyring-p34
# https://askubuntu.com/questions/254826/how-to-force-a-clock-update-using-ntp
echo -e "\nSyncing time"
sudo timedatectl set-ntp 1
sudo ntpdate time.nist.gov

#mirror update
echo -e "\nBlacklisting mirror from Iran"
# https://forum.manjaro.org/t/pacman-mirrors-freezes-on-iran/79700/15
echo "127.0.0.1    repo.sadjad.ac.ir" | sudo tee -a /etc/hosts
#sudo pacman-mirrors --country Germany,France,Austria
sudo pacman-mirrors --fasttrack --timeout 2 -m rank

# for 32 bit we need to update keys with this
# https://forum.manjaro.org/t/solved-manjaro-32-refuses-updates-no-matter-what/68522/2
if [ $(uname -m) = "i686" ]; then
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Rns manjaro-hello
	yes | LC_ALL=en_US.UTF-8 sudo pacman -S archlinux32-keyring-transition
fi

#install default stuff
yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu --overwrite /etc/skel/.config/autostart rsync lsof ecryptfs-utils acl mc mtools unarj activity-log-manager cronie at attr baobab bzip2 exempi caja caja-extensions-common caja-share caja-sendto caja-wallpaper caja-open-terminal caja-xattr-tags caja-image-converter catdoc catfish copyq doublecmd-gtk2 libunrar dstat gnome-disk-utility gnome-system-monitor gnupg gzip hardinfo hddtemp hdparm htop iotop keepassxc lshw meld gnome-nettool seahorse smplayer smtube strace tar unace unrar unzip wget youtube-dl zeitgeist-explorer pacaur synapse exfat-utils pdfmod fd mlocate manjaro-tools-base zenity lbzip2 compsize

# synapse vs ulauncher?

# set up bootsplash
if [ $(uname -m) = "x86_64" ]; then
    yes | LC_ALL=en_US.UTF-8 sudo pacman -Syyuu bootsplash-theme-manjaro bootsplash-systemd

    # set boot splash
    if ! grep -q bootsplash /etc/mkinitcpio.conf; then
        sudo sed -i 's/HOOKS="[^"]*/& bootsplash-manjaro/' /etc/mkinitcpio.conf
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& bootsplash.bootfile=bootsplash-themes\/manjaro\/bootsplash/' /etc/default/grub
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet /GRUB_CMDLINE_LINUX_DEFAULT="/' /etc/default/grub
        
        presets=''
        for i in `ls /etc/mkinitcpio.d/`;  do
            presets=${presets}' -p '`echo $i | sed 's/.preset//g'`
        done
        sudo mkinitcpio $presets
        
        sudo update-grub
    fi
fi


# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

# enable AUR and set AUR auto download key for the current user
sudo chmod +x $MY_PATH/manjaro_setup_base_settings.sh
$MY_PATH/manjaro_setup_base_settings.sh


# fix boot delay problem
# https://forum.manjaro.org/t/boot-delay-random-crng-init-done/47182
yes | LC_ALL=en_US.UTF-8 sudo pacman -S haveged
sudo systemctl enable haveged
sudo systemctl start haveged


# multi thread compress
cd /usr/local/bin
sudo ln -s /usr/bin/lbzip2 bzip2
sudo ln -s /usr/bin/lbzip2 bunzip2
sudo ln -s /usr/bin/lbzip2 bzcat
sudo ln -s /usr/bin/pigz gzip


# install some handy stuff from AUR
export GNUPGHOME=~/aur; pacaur -aS --noconfirm --noedit byobu youtube-dl-gui-git

if [ $(uname -m) = "x86_64" ]; then
	export GNUPGHOME=~/aur; pacaur -aS --noconfirm --noedit gnome-encfs-manager-bin
fi

# if you need acl managing gui
# eiciel


# not working:

# unknown public key:
# gnome-activity-journal

# could not download catalog
# command-not-found

# if needed
# magicrescue

# cert problem
# ttf-ms-fonts
