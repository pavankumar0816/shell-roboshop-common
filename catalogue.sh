#!/bin/bash

source ./common.sh
app_name=catalogue


check_root
app_setup
nodejs_setup
systemd_setup

# Loading data into Mongodb
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y

INDEX=$(mongosh --host $MONGODB_HOST --quiet --eval 'db.getMongo().getDBNames().indexOf("catalogue")') # Mongodb shell command to check db exists ot not db.getMongo().getDBNames() will list all the dbs and indexOf("catalogue") will check if catalogue db is there or not if it is there it will return index number 1 if not it will return -1

if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js
    VALIDATE $? "Loading Products"
else
    echo -e "$(date "+%Y-%m-%d %H:%M:%S") | Products are already loaded ... $Y Skipping $N"  
fi
