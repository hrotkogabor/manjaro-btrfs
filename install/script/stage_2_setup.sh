#!/bin/bash
# stage 2 setup
 

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


# fix catfish # not needed, fixed upstream
#chmod +x $MY_PATH/fix_catfish.sh
#sudo $MY_PATH/fix_catfish.sh


# do full upgrade
sudo pacman -Syyuu --needed --noconfirm 

# remove timeshift, as we do it with snapper
yes | LC_ALL=en_US.UTF-8 sudo pacman -R timeshift-autosnap-manjaro timeshift

#install default stuff
yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm base-devel
yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --overwrite /etc/skel/.config/autostart binutils mc mtools unarj activity-log-manager at baobab exempi caja caja-extensions-common caja-share caja-sendto caja-wallpaper caja-open-terminal caja-xattr-tags caja-image-converter catdoc copyq doublecmd-gtk2 libunrar dstat gnome-disk-utility gnome-system-monitor hardinfo hddtemp iotop keepassxc lshw meld gnome-nettool seahorse smplayer smtube strace youtube-dl zeitgeist-explorer yay synapse fd manjaro-tools-base lbzip2 compsize filemanager-actions pigz gnome-calculator system-config-printer downgrade

# synapse vs ulauncher?

# change login greeter
yes | LC_ALL=en_US.UTF-8 sudo sudo pacman -R lightdm-gtk-greeter lightdm-gtk-greeter-settings
yes | LC_ALL=en_US.UTF-8 sudo sudo pacman -S --needed lightdm-settings lightdm-slick-greeter

sudo sed -i 's/greeter-session=lightdm-gtk-greeter/greeter-session=lightdm-slick-greeter/' /etc/lightdm/lightdm.conf


# set up bootsplash
if [ $(uname -m) = "x86_64" ]; then
    yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm bootsplash-theme-manjaro bootsplash-systemd

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


# multi thread compress
cd /usr/local/bin
sudo ln -s /usr/bin/lbzip2 bzip2
sudo ln -s /usr/bin/lbzip2 bunzip2
sudo ln -s /usr/bin/lbzip2 bzcat
sudo ln -s /usr/bin/pigz gzip

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

yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm snapper
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
yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed --noconfirm snap-pac grub-btrfs snapper-gui
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
