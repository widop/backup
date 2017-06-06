#!/bin/bash

# You should not change these variables
logrorateFolder="/etc/logrotate.d/"

binFolder=$(pwd)/bin/

ln -s $(pwd)/vendor/widop/backup/install.sh ${binFolder}backup-install
ln -s $(pwd)/vendor/widop/backup/backup.sh ${binFolder}backup

exit 0
