#!/bin/bash

source ./common.sh

check_root

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing MySQL Server"

systemctl enable mysqld &>> $LOGS_FILE
systemctl start mysqld  
VALIDATE $? "Enable and start Mysql Server"

# get the password from the user
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setup root password"

print_total_time