#!/bin/bash
# install some stuff for development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

source base.sh

#install default stuff
array=(git tk jq bind pkgfile)

installPkgs "${array[@]}"

# https://gitlab.gnome.org/GNOME/gcr/-/work_items/54
sudo systemctl --global enable gcr-ssh-agent.{socket,service}

# https://forum.manjaro.org/t/ssh-agent-not-working-via-gnome-keyring/158213/8
echo "export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh" | sudo tee -a /etc/profile.d/gcr-keyring.sh

git config --global credential.helper /usr/lib/git-core/git-credential-libsecret

#install dev AUR stuff
yay -aS --sudoloop --noredownload --norebuild --noconfirm gstm gpgfrontend

read
