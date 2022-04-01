#!/bin/bash
# set up x2go
sudo pacman -Syyuu --noconfirm --needed x2goserver

sudo x2godbadmin --createdb

sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl enable x2goserver
sudo systemctl start x2goserver

#https://wiki.archlinux.org/title/X2Go#Sessions_do_not_logoff_correctly
echo '#!/bin/sh
#
#xfce4-session spits out quite a bit of text during logout, which I guess
#confuses x2go so we would get a black screen and session hang.
#adding redirect to a logfile like "~/logfile" or "/dev/null" nicely solved it
# see https://bugs.x2go.org/cgi-bin/bugreport.cgi?bug=914
/usr/bin/xfce4-session > /dev/null' | sudo tee /usr/local/bin/xfce4-session-x2go.sh
sudo chmod +x /usr/local/bin/xfce4-session-x2go.sh

# to connect, use these settings in the client:
# - connection/compression: 256-png-jpeg
# - session/session type: custom desktop, command: dbus-launch /usr/local/bin/xfce4-session-x2go.sh
#
# also disable composition in xfce

echo -e "\nX2go setup ready."

read