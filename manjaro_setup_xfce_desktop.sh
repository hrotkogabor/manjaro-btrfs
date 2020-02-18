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

# unzip settings
sudo tar xf xfce_skeleton.tar.bz2 -C $homedir

# change ownership
sudo chown $p:$p -R $homedir

echo -e '\nReady. You should restart now.'
read

