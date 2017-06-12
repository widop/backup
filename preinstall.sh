#!/bin/bash

# You should not change these variables
logrorateFolder="/etc/logrotate.d/"

binFolder=$(pwd)/bin/

ln -s $(pwd)/vendor/widop/backup/install.sh ${binFolder}backup-install
ln -s $(pwd)/vendor/widop/backup/backup.sh ${binFolder}backup

if [ -f $(pwd)/backup.conf ]; then
    sed  -i "/backupFile/c\source $(pwd)/backup.conf" ${binFolder}backup
fi

exit 0
