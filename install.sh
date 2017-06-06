#!/bin/bash

#source vendor/widop/backup/functions.sh
source functions.sh

# Check if user is root
checkUserRoot

# You should not change these variables
logrorateFolder="/etc/logrotate.d/"

echo "Project name : "
read projectName

# Load the backup configuration file
#source backup.conf
databaseType=`askDatabaseType`
echo $databaseType

echo "Database user : "
read databaseUser

echo "Database password : "
read databasePass

echo "Database name : "
read databaseName

uploadsPath=`askRepository "Uploads path (use shared upload repository)"`
currentPath=`askRepository "Current path"`
binPath=`askBinPath $currentPath`

echo "Backup folder : "
read backupFolder;
backupFolder=$(trailingSlash $backupFolder)

cat > ${currentPath}backup.conf << EOL
projectName=${projectName}
databaseType=${databaseType} # mysql|mongo
databaseUser=${databaseUser}
databasePass=${databasePass}
databaseName=${databaseName}
uploadsPath=${uploadsPath} # Do not remove the trailing slash
backupFolder=${backupFolder} # Update this line needs to reinstall backup logrotate, do not remove the trailing slash
currentFolder=${currentPath} # Update this line needs to reinstall backup logrotate, do not remove the trailing slash
binFolder=${binPath} # Update this line needs to reinstall backup logrotate, do not remove the trailing slash
EOL

# Prepare new directories for the backup
mkdir -p ${backupFolder}
mkdir -p ${backupFolder}databases
touch ${backupFolder}databases/db-daily.sql.gz
touch ${backupFolder}databases/db-weekly.sql.gz
touch ${backupFolder}databases/db-monthly.sql.gz

sed  -i "/backupFile/c\source ${currentPath}backup.conf" ${currentPath}/bin/backup

# Install tools
apt-get update && apt-get install curl unzip -y && curl -O -L http://downloads.rclone.org/rclone-current-linux-amd64.zip && unzip rclone-current-linux-amd64.zip && rm rclone-current-linux-amd64.zip && cd rclone-*-linux-amd64 && cp rclone /usr/sbin/ && chown root:root /usr/sbin/rclone && chmod 755 /usr/sbin/rclone && rclone config

# Logrotate configuration
cat > ${logrorateFolder}${projectName}widop-backup << EOL
${backupFolder}databases/db-daily.sql.gz {
    daily
    rotate 7
    nocompress
    create 640 root adm
    postrotate
       ${binPath}backup daily
    endscript
}

${backupFolder}databases/db-weekly.sql.gz {
    weekly
    rotate 4
    nocompress
    create 640 root adm
    postrotate
        ${binPath}backup weekly
    endscript
}

${backupFolder}databases/db-monthly.sql.gz {
    monthly
    rotate 12
    nocompress
    create 640 root adm
    postrotate
        ${binPath}backup monthly
    endscript
}
EOL

echo "Backup installation complete"
exit 0
