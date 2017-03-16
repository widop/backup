#!/bin/bash

# You should not change these variables
logrorateFolder="/etc/logrotate.d/"

binFolder=$(pwd)/bin/

mkdir -p ${binFolder}backup
ln -s $(pwd)/vendor/widop/backup/install.sh ${binFolder}backup/install.sh
ln -s $(pwd)/vendor/widop/backup/backup.sh ${binFolder}backup/backup.sh

exit 0
