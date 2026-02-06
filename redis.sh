#!/bin/bash

source ./common.sh
check_root

if command -v redis-server &>/dev/null && redis-server -v | grep -q "v=7"; then
    echo -e "Already Installed ... $Y Skipping $N" | tee -a $LOGS_FILE
else
    dnf module disable redis -y &>> $LOGS_FILE
    VALIDATE $? "Disabling Default Redis Module"
    dnf module enable redis:7 -y &>> $LOGS_FILE
    VALIDATE $? "Enabling Redis 7 Module"
    dnf install redis -y &>> $LOGS_FILE
    VALIDATE $? "Installing Redis"
fi

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote Connections"

systemctl enable redis &>> $LOGS_FILE
systemctl start redis 
VALIDATE $? "Enable and Started Redis"

print_total_time