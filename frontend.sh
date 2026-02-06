#!/bin/bash

source ./common.sh
app_name=frontend
check_root

dnf module disable nginx -y
dnf module enable nginx:1.24 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Nginx 1.24 Version"

dnf install nginx -y &>> $LOGS_FILE
VALIDATE $? "Installing Nginx Web Server"

systemctl enable nginx &>> $LOGS_FILE 
systemctl start nginx 
VALIDATE $? "Enabled and Started Nginx Service"

rm -rf /usr/share/nginx/html/* &>> $LOGS_FILE
VALIDATE $? "Removing Default Nginx Content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>> $LOGS_FILE
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>> $LOGS_FILE
VALIDATE $? "Downloaded and Extracted Frontend App Content"

rm -rf /etc/nginx/nginx.conf

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>> $LOGS_FILE
VALIDATE $? "Copying Nginx Configuration File"

systemctl restart nginx
VALIDATE $? "Restarting Nginx Service"

print_total_time
