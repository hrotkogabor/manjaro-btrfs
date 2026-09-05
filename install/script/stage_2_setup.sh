#!/bin/bash
# stage 2 setup

MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized

source $MY_PATH/../../base.sh 

# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
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
#sudo pacman-mirrors --fasttrack --timeout 2 -m rank
sudo pacman-mirrors --continent --timeout 2 -m rank


# for 32 bit we need to update keys with this
# https://forum.manjaro.org/t/solved-manjaro-32-refuses-updates-no-matter-what/68522/2
if [ $(uname -m) = "i686" ]; then
	yes | LC_ALL=en_US.UTF-8 sudo pacman -Rns manjaro-hello
	yes | LC_ALL=en_US.UTF-8 sudo pacman -S archlinux32-keyring-transition
fi


# remove timeshift, as we do it with snapper
yes | LC_ALL=en_US.UTF-8 sudo pacman -R timeshift-autosnap-manjaro timeshift

# do full upgrade
sudo pacman -Syyuu --needed --noconfirm 

#install default stuff
#yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm base-devel
#yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --overwrite /etc/skel/.config/autostart binutils mc mtools unarj activity-log-manager at baobab exempi caja caja-extensions-common caja-share caja-sendto caja-wallpaper caja-open-terminal caja-xattr-tags caja-image-converter  catdoc copyq doublecmd-gtk2 libunrar dool gnome-disk-utility gnome-system-monitor hddtemp iotop keepassxc lshw meld gnome-nettool seahorse smplayer strace zeitgeist-explorer yay synapse fd manjaro-tools-base lbzip2 compsize pigz gnome-calculator system-config-printer downgrade bash-completion iftop net-tools hunspell-en_us ncdu okular rebuild-detector yay
array=(base-devel binutils mc mtools unarj activity-log-manager at baobab exempi caja caja-extensions-common caja-share caja-sendto caja-wallpaper caja-open-terminal caja-xattr-tags caja-image-converter  catdoc copyq doublecmd-qt5 libunrar dool gnome-disk-utility gnome-system-monitor hddtemp iotop keepassxc lshw meld gnome-nettool seahorse smplayer strace zeitgeist-explorer yay synapse fd manjaro-tools-base-git lbzip2 compsize pigz gnome-calculator system-config-printer downgrade bash-completion iftop net-tools hunspell-en_us ncdu okular rebuild-detector yay lightdm-settings lightdm-slick-greeter zenity)
installPkgs "${array[@]}"

# synapse vs ulauncher?

# change login greeter
#yes | LC_ALL=en_US.UTF-8 sudo sudo pacman -S --needed lightdm-settings lightdm-slick-greeter

sudo sed -i 's/greeter-session=lightdm-gtk-greeter/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf


# multi thread compress
#cd /usr/local/bin
#sudo ln -s /usr/bin/lbzip2 bzip2
#sudo ln -s /usr/bin/lbzip2 bunzip2
#sudo ln -s /usr/bin/lbzip2 bzcat
#sudo ln -s /usr/bin/pigz gzip

# disable speaker
echo "blacklist pcspkr"  | sudo tee -a /etc/modprobe.d/nobeep.conf

#enable AUR
if grep -q "#EnableAUR" /etc/pamac.conf; then
  sudo sed -i -e 's/#EnableAUR/EnableAUR/g' /etc/pamac.conf
  #enable color
  sudo sed -i -e 's/#Color/Color/g' /etc/pacman.conf
fi


# fix the "sparse file not allowed" error message on startup
sudo sed -i -e 's/GRUB_SAVEDEFAULT=true/#GRUB_SAVEDEFAULT=true/g' /etc/default/grub
echo "GRUB_REMOVE_LINUX_ROOTFLAGS=true" | sudo tee -a /etc/default/grub
sudo sed -i -e 's/GRUB_TIMEOUT=[[:digit:]]/GRUB_TIMEOUT=2/g' /etc/default/grub
sudo update-grub

# to see snapshot size in snapper list, this will slow down snapshot list
#sudo btrfs quota enable /

array=(snapper)
installPkgs "${array[@]}"

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
yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm snap-pac grub-btrfs
sudo sed -i -e 's/#GRUB_BTRFS_SUBMENUNAME="Arch Linux snapshots"/GRUB_BTRFS_SUBMENUNAME="Select snapshot"/g' /etc/default/grub-btrfs/config

# disable core dump
sudo mkdir -p /etc/systemd/coredump.conf.d
sudo touch /etc/systemd/coredump.conf.d/custom.conf
echo -e "[Coredump]\nStorage=none" | sudo tee /etc/systemd/coredump.conf.d/custom.conf
sudo systemctl daemon-reload

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

# 10-udisks2.rules: do not ask admin passwd on disk mount
sudo cp -R $MY_PATH/etc/* /etc
