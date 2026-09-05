#!/bin/bash
function installPkgs() {

  declare -a pkgs pkgs_200 pkgs_202 pkgs_404
  declare -A pkgs_301

  #pkgs=(foo bar baz grep bgrep bingrep)
  #pkgs=(binutils mc mtools unarj activity-log-manager at baobab exempi caja caja-extensions-common caja-share caja-sendto caja-wallpaper caja-open-terminal caja-xattr-tags caja-image-converter  catdoc copyq doublecmd-gtk2 libunrar dool gnome-disk-utility gnome-system-monitor hddtemp iotop keepassxc lshw meld gnome-nettool seahorse smplayer strace zeitgeist-explorer yay synapse fd manjaro-tools-base lbzip2 compsize pigz gnome-calculator system-config-printer downgrade bash-completion iftop net-tools hunspell-en_us ncdu okular rebuild-detector yay)
  #pkgs=(gcompris-qt gbrainy gnome-mines gnome-nibbles gnome-mahjongg gnome-sudoku gnome-taquin five-or-more palapeli ktuberling aisleriot frozen-bubble pingus xorg-fonts-misc ltris)
  
  pkgs=("$@")
  pkgs=($(printf '%s\n' "${pkgs[@]}"|sort -u))
  pkgs_200=($(comm -12 <(pacman -Slq|sort -u) <(printf '%s\n' "${pkgs[@]}")))
  pkgs_202=($(comm -23 <(printf '%s\n' "${pkgs[@]}") <(printf '%s\n' "${pkgs_200[@]}")))
  for pkg in "${pkgs_202[@]}"; do
    pkgname=$(pacman -Spdd --print-format %n "$pkg" 2> /dev/null)
    if [[ -n $pkgname ]]; then
      pkgs_301[$pkg]=$pkgname
    else
      pkgs_404+=("$pkg")
    fi
  done

  #pacman -S "${pkgs_200[@]}" "${pkgs_301[@]}"
  echo "installing packages: ${pkgs_200[*]}" >&2
  echo "1" | sudo pacman -Syyuu --needed --noconfirm --quiet --overwrite /etc/skel/.config/autostart "${pkgs_200[@]}" "${pkgs_301[@]}"

  #printf "\n200 Found:\n" >&2
  #printf "%s\n" "${pkgs_200[@]}" >&2

  if (( ${#pkgs_301[@]} )); then
    printf "\nMoved Permanently packages:\n" >&2
    paste -d : <(printf "%s\n" "${!pkgs_301[@]}") <(printf "%s\n" "${pkgs_301[@]}") >&2
    printf "\n"
  fi

  if (( ${#pkgs_404[@]} )); then
    printf "\nNot Found packages:\n" >&2
    printf "%s\n" "${pkgs_404[@]}" >&2
    printf "\n"
  fi

   #arr=("$@")
   #for i in "${arr[@]}";
   #   do
   #       echo "$i"
   #   done

}