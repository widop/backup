#!/bin/bash

# You should not change these variables
logrorateFolder="/etc/logrotate.d/"

echo "Project name : "
read projectName

# Load the backup configuration file
#source backup.conf
databaseType=null
while ! [ $databaseType = "mysql" ] && ! [ $databaseType = "mongo" ];
do
    echo "Database type (mysql|mongo) : ";
    read databaseType;
done

echo "Database user : "
read databaseUser;

echo "Database password : "
read databasePass;

echo "Database name : "
read databaseName;

# uploadsPath
uploadsPath=null
while ! [ -d $uploadsPath ] || ! [ -x $uploadsPath ];
do
    if [ $uploadsPath != null ]
    then
        echo "UploadsPath \"${uploadsPath}\" : No such file or directory";
    fi
    echo "Uploads path (use shared path and don't forget the trailing slash) : "
    read uploadsPath;
done

echo "Backup folder (don't forget the trailing slash) : "
read backupFolder;

cat > ../backup.conf << EOL
databaseType=${databaseType} # mysql|mongo
databaseUser=${databaseUser}
databasePass=${databasePass}
databaseName=${databaseName}
uploadsPath=${uploadsPath} # Do not remove the trailing slash
backupFolder=${backupFolder} # Do not remove the trailing slash
projectName=${projectName}
EOL

# Prepare new directories for the backup
mkdir -p ${backupFolder}
mkdir -p ${backupFolder}databases
touch ${backupFolder}databases/db-daily.sql.gz
touch ${backupFolder}databases/db-weekly.sql.gz
touch ${backupFolder}databases/db-monthly.sql.gz


# Install tools
apt-get update && apt-get install curl unzip -y && curl -O http://downloads.rclone.org/rclone-current-linux-amd64.zip && unzip rclone-current-linux-amd64.zip && rm rclone-current-linux-amd64.zip && cd rclone-*-linux-amd64 && cp rclone /usr/sbin/ && chown root:root /usr/sbin/rclone && chmod 755 /usr/sbin/rclone && rclone config


# Logrotate configuration
cat > ${logrorateFolder}widop-backup << EOL
${backupFolder}databases/db-daily.sql.gz {
    daily
    rotate 7
    nocompress
    create 640 root adm
    postrotate
       ${binFolder}backup.sh daily
    endscript
}

${backupFolder}databases/db-weekly.sql.gz {
    weekly
    rotate 4
    nocompress
    create 640 root adm
    postrotate
        ${binFolder}backup.sh weekly
    endscript
}

${backupFolder}databases/db-monthly.sql.gz {
    monthly
    rotate 12
    nocompress
    create 640 root adm
    postrotate
        ${binFolder}backup.sh monthly
    endscript
}
EOL

cat > ${binFolder}backup.sh << EOL
#!/bin/bash


# Sauvergarde de la base de donnée
# dump command choice
source ../backup.conf
if [ \$databaseType = "mysql" ]
then
    dumpCommand="mysqldump --user=${databaseUser} --password=${databasePass} ${databaseName} --single-transaction | gzip > ${backupFolder}databases/db-\${1}.sql.gz"
elif [ $databaseType = "mongo" ]
then
    dumpCommand="mongodump --username ${databaseUser} --password ${databasePass} --db ${databaseName} --out ${backupFolder}databases/db-${1}"
else
    echo "The database ${databaseType} is not a valid choice"
    exit 1
fi

rclone sync ${backupFolder}databases remote:${projectName}-db


# Dupliquer cette ligne pour sauvegarder d'autres dossiers. Et ajouter un chiffre pour chaque dossier après uploads
# Exemple : rclone sync /mon/dossier remote:${projectName}-uploads2
rclone sync ${uploadsPath} remote:${projectName}-uploads
EOL

chmod +x ${binFolder}backup.sh

echo "Backup OK"
exit 0
