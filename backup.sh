#!/bin/bash


# Sauvergarde de la base de donnée
# dump command choice
source backupFile
if [ $databaseType = "mysql" ]
then
    dumpCommand="mysqldump --user=${databaseUser} --password=${databasePass} ${databaseName} --single-transaction | gzip > ${backupFolder}databases/db-${1}.sql.gz"
elif [ $databaseType = "mongo" ]
then
    dumpCommand="mongodump --username ${databaseUser} --password ${databasePass} --db ${databaseName} --out ${backupFolder}databases/db-${1}"
else
    echo "The database ${databaseType} is not a valid choice"
    exit 1
fi

rclone sync ${backupFolder}databases remote:${projectName}-db


# Dupliquer cette ligne pour sauvegarder d'autres dossiers. Et ajouter un chiffre pour chaque dossier après uploads
# Exemple : rclone sync /mon/dossier remote:\${projectName}-uploads2
rclone sync ${uploadsPath} remote:${projectName}-uploads
EOL
