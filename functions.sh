#!/usr/bin/env bash
function trailingSlash () {
    if [ ${1: -1} != "/" ]
    then
        echo $1/
    else
        echo $1
    fi
}

function askRepository() {
    repositoryPath=null
    while ! [ -d $repositoryPath ] || ! [ -x $repositoryPath ];
    do
        if [ $repositoryPath != null ]
        then
            echo "$1 \"${repositoryPath}\" : No such file or directory" >&2
        fi
        echo "$1 :" >&2
        read repositoryPath;
    done
        echo $(trailingSlash $repositoryPath);
}

function askDatabaseType() {
    databaseType=null
    while ! [ $databaseType = "mysql" ] && ! [ $databaseType = "mongo" ];
    do
        echo "Database type (mysql|mongo) : " >&2
        read databaseType
    done

    echo $databaseType
}

function askBinPath() {
    binPath=$(trailingSlash $(trailingSlash $1)bin)
    if ! [ -d $binPath ] || ! [ -x $binPath ];
    then
        echo -e "\"$binPath\" does not exist, you want to create it?\n - (y) Yes, create it\n - (n) No, I want to specify the bin path" >&2
        read answer
        if [ $answer == "y" ]
        then
            mkdir $binPath
        else
            binPath=`askRepository "Bin asbolute path"`
        fi
    fi

    echo $binPath
}

function checkUserRoot() {
    if [ $(whoami) != "root" ];
    then
        echo "Les droits root sont nécessaires." >&2
        exit 1
    fi
}
