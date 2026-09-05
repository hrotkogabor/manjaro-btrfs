#!/bin/bash
# install some stuff for odoo development

if [ $(id -u) = "0" ]; then
	echo "Do not run this as root!"
	exit 0
fi

source base.sh

#install default stuff
array=(sassc pyenv postgresql)

installPkgs "${array[@]}"

sudo su -l postgres -c "initdb --locale=C.UTF-8 --encoding=UTF8 -D '/var/lib/postgres/data'"

#install dev AUR stuff
yay -aS --sudoloop --noredownload --norebuild --noconfirm nodejs-less pyenv-virtualenv pycharm pgadmin4-bin

# wkhtml should be unpacked from https://github.com/odoo/wkhtmltopdf/releases/download/nightly/odoo-wkhtmltopdf-arch-x86_64-0.13.0-nightly.pkg.tar.xz

read
