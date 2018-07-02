#!/bin/bash

#ps ax | egrep "samba|smbd|nmbd|winbindd"

#sudo systemctl stop smbd
#sudo systemctl stop nmbd
#sudo systemctl stop winbind

#ps ax | egrep "samba|smbd|nmbd|winbindd"

FILE=$(smbd -b | grep "CONFIGFILE"|cut -d\  -f5)
sudo rm -i $FILE

DIRS=$(smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR"|cut -d\  -f5)
echo $DIRS

for DIR in $DIRS
do
    sudo rm -i $DIR/*.tdb
    sudo rm -i $DIR/*.ldb
done
