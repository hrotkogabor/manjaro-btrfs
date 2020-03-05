#!/bin/bash
# customize xfce desktop

list=`grep /bin/bash /etc/passwd | cut -d: -f1 | grep -v root`

echo "Please select a user!"

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

# get home dir of user
homedir=`grep /bin/bash /etc/passwd | grep $p: | cut -d: -f6`
echo 'homedir is '$homedir

# get path of the currently running script
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$MY_PATH" ] ; then
  # error; for some reason, the path is not accessible
  # to the script (e.g. permissions re-evaled after suid)
  exit 1  # fail
fi

# unzip settings
sudo tar xf $MY_PATH/xfce_skeleton.tar.bz2 -C $homedir

# change ownership
sudo chown $p:$p -R $homedir

echo -e '\nReady. You should restart now.'
read

