#!/bin/bash
# Alert after boot if the btrfs filesystem is read only.
# Specify the command to rollback.
if btrfs property get -ts / | grep -q 'ro=true'
then
	zenity --width=400 --warning --text="This is a read only snapshot. You can't modify your system,\nfor example install packages.\n\nTo rollback to this snapshot as a new writeable system, run:\n\n<b>sudo btrfs_snapper_do_rollback.sh</b>\n\n in the terminal and reboot." --title="Read only snapshot loaded! "
fi