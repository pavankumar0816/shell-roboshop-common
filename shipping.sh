#!/bin/bash

source ./common.sh
app_name=shipping

check_root
app_setup
java_setup
systemd_setup

dnf install mysql -y 
VALIDATE $? "Installing Mysql Client"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>> $LOGS_FILE
    VALIDATE $? "Loading Shipping Schema"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOGS_FILE
    VALIDATE $? "Loading Shipping Schema and User Data"
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOGS_FILE
    VALIDATE $? "Loading Shipping Master Data"
else 
    echo -e "Shipping Database already exists ... $Y Skipping $N"
fi

app_restart
print_total_time
