#!/bin/bash

# You can change theses variables to fit your needs
databaseUser='php'
databasePass='password'
databaseName='database_name'
uploadsPath='/var/www/projet/shared/web/uploads/' # Do not remove the trailing slash
backupFolder='/home/admin/backups/' # Do not remove the trailing slash
projectName='project_name'

# You should not change these variables
logrorateFolder='/etc/logrotate.d/'

# Prepare new directories for the backup
mkdir -p ${backupFolder}
mkdir -p ${backupFolder}databases
touch ${backupFolder}databases/db-daily.sql.gz
touch ${backupFolder}databases/db-weekly.sql.gz
touch ${backupFolder}databases/db-monthly.sql.gz


# Install tools
apt-get update && apt-get install curl unzip -y && curl -O http://downloads.rclone.org/rclone-current-linux-amd64.zip && unzip rclone-current-linux-amd64.zip && cd rclone-*-linux-amd64 && cp rclone /usr/sbin/ && chown root:root /usr/sbin/rclone && chmod 755 /usr/sbin/rclone && rclone config


# Logrotate configuration
cat > ${logrorateFolder}widop-backup << EOL
${backupFolder}databases/db-daily.sql.gz {
    daily
    rotate 7
    nocompress
    create 640 root adm
    postrotate
       ${backupFolder}backup.sh daily
    endscript
}

${backupFolder}databases/db-weekly.sql.gz {
    weekly
    rotate 4
    nocompress
    create 640 root adm
    postrotate
        ${backupFolder}backup.sh weekly
    endscript
}

${backupFolder}databases/db-monthly.sql.gz {
    monthly
    rotate 12
    nocompress
    create 640 root adm
    postrotate
        ${backupFolder}backup.sh monthly
    endscript
}
EOL


# backup.sh
# FOR MONGO : mongodump --username ${databaseUser} --password ${databasePass} --db ${databaseName} --out ${backupFolder}/databases/db-${1}
# FOR MYSQL : mysqldump --user=${databaseUser} --password=${databasePass} ${databaseName} --single-transaction | gzip > ${backupFolder}/databases/db-${1}.sql.gz

cat > ${backupFolder}backup.sh << EOL
#!/bin/bash


# Sauvergarde de la base de donnée
mysqldump --user=${databaseUser} --password=${databasePass} ${databaseName} --single-transaction | gzip > ${backupFolder}databases/db-\${1}.sql.gz
rclone sync ${backupFolder}databases remote:${projectName}-db


# Dupliquer cette ligne pour sauvegarder d'autres dossiers. Et ajouter un chiffre pour chaque dossier après uploads
# Exemple : rclone sync /mon/dossier remote:${projectName}-uploads2
rclone sync ${uploadsPath} remote:${projectName}-uploads
EOL

chmod +x ${backupFolder}backup.sh

echo "Backup OK"
exit 0
