#!/bin/bash
# install hungarian language packages
source base.sh

array=(qt5-translations firefox-i18n-hu thunderbird-i18n-hu aspell-hu hunspell-hu hyphen-hu hyphen-en aspell-en)

installPkgs "${array[@]}"

echo -e "\nHungarian lang setup ready."

read
